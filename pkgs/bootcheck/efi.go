package main

import (
	"encoding/binary"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"strconv"
	"strings"
	"unicode/utf16"
)

// Ядро выкладывает переменные UEFI сюда обычными файлами.
const efiVarsDir = "/sys/firmware/efi/efivars"

// Идентификатор набора стандартных переменных загрузки.
// Имена файлов выглядят как BootOrder-8be4df61-93ca-11d2-aa0d-00e098032b8c.
const globalGUID = "8be4df61-93ca-11d2-aa0d-00e098032b8c"

// Бит "запись включена" в атрибутах пункта загрузки.
const loadOptionActive = 0x00000001

var bootVarRe = regexp.MustCompile(`^Boot([0-9A-Fa-f]{4})-` + globalGUID + `$`)

// bootEntry это одна запись загрузки из UEFI.
type bootEntry struct {
	num    uint16
	desc   string
	active bool
}

func (b bootEntry) label() string {
	return fmt.Sprintf("Boot%04X", b.num)
}

// checkUEFI смотрит, найдёт ли прошивка нужный загрузчик.
func checkUEFI(varsDir, want string) result {
	if _, err := os.Stat(varsDir); err != nil {
		if os.IsNotExist(err) {
			warnf("UEFI: каталог %s отсутствует", varsDir)
			notef("система загружена не через UEFI, проверка пропущена")
			return result{warned: true}
		}
		failf("UEFI: %v", err)
		return result{failed: true}
	}

	entries, err := readBootEntries(varsDir)
	if err != nil {
		failf("UEFI: %v", err)
		return result{failed: true}
	}

	order, err := readBootOrder(varsDir)
	if err != nil {
		failf("UEFI: %v", err)
		return result{failed: true}
	}
	if len(order) == 0 {
		failf("UEFI: BootOrder пуст, прошивке нечего загружать")
		return result{failed: true}
	}

	// Показываем порядок загрузки целиком.
	for i, num := range order {
		e, known := entries[num]
		switch {
		case !known:
			warnf("UEFI: %d место, Boot%04X, записи с таким номером нет", i+1, num)
		case !e.active:
			okf("UEFI: %d место, %s, %q (выключена)", i+1, e.label(), e.desc)
		default:
			okf("UEFI: %d место, %s, %q", i+1, e.label(), e.desc)
		}
	}

	// Ищем нашу запись в порядке загрузки.
	pos := -1
	var found bootEntry
	for i, num := range order {
		e, known := entries[num]
		if known && strings.Contains(strings.ToLower(e.desc), strings.ToLower(want)) {
			pos = i
			found = e
			break
		}
	}

	if pos < 0 {
		// Может быть, запись есть, но выпала из BootOrder.
		for _, e := range entries {
			if strings.Contains(strings.ToLower(e.desc), strings.ToLower(want)) {
				failf("UEFI: запись %s %q существует, но её нет в BootOrder", e.label(), e.desc)
				notef("прошивка её не увидит, порядок надо восстановить")
				return result{failed: true}
			}
		}
		failf("UEFI: записи с названием %q не найдено вообще", want)
		notef("всего в BootOrder: %s", plural(len(order), "запись", "записи", "записей"))
		return result{failed: true}
	}

	res := result{}
	if !found.active {
		failf("UEFI: запись %s %q выключена", found.label(), found.desc)
		res.failed = true
	}
	if pos > 0 {
		prev := "неизвестная запись"
		if e, ok := entries[order[0]]; ok {
			prev = fmt.Sprintf("%q", e.desc)
		}
		warnf("UEFI: %q стоит на %d месте, первой идёт %s", found.desc, pos+1, prev)
		notef("порядок задаётся в BIOS: Settings, Boot, UEFI Hard Disk Drive BBS Priorities")
		res.warned = true
	}
	if !res.failed && !res.warned {
		sumf("UEFI: запись %s %q найдена и стоит первой", found.label(), found.desc)
	}
	return res
}

// readBootOrder возвращает номера записей в порядке, который перебирает прошивка.
func readBootOrder(varsDir string) ([]uint16, error) {
	data, err := readVar(varsDir, "BootOrder")
	if err != nil {
		return nil, err
	}
	if len(data)%2 != 0 {
		return nil, fmt.Errorf("BootOrder имеет нечётную длину %d байт", len(data))
	}
	out := make([]uint16, 0, len(data)/2)
	for i := 0; i+1 < len(data); i += 2 {
		out = append(out, binary.LittleEndian.Uint16(data[i:i+2]))
	}
	return out, nil
}

// readBootEntries собирает все переменные вида Boot####.
func readBootEntries(varsDir string) (map[uint16]bootEntry, error) {
	names, err := os.ReadDir(varsDir)
	if err != nil {
		if os.IsPermission(err) {
			return nil, fmt.Errorf("нет прав на чтение %s, запусти через sudo", varsDir)
		}
		return nil, err
	}

	out := map[uint16]bootEntry{}
	for _, n := range names {
		m := bootVarRe.FindStringSubmatch(n.Name())
		if m == nil {
			continue
		}
		num64, err := strconv.ParseUint(m[1], 16, 16)
		if err != nil {
			continue
		}
		data, err := readVar(varsDir, fmt.Sprintf("Boot%s", m[1]))
		if err != nil {
			continue // одна битая запись не повод падать целиком
		}
		desc, active, err := parseLoadOption(data)
		if err != nil {
			continue
		}
		out[uint16(num64)] = bootEntry{num: uint16(num64), desc: desc, active: active}
	}
	return out, nil
}

// readVar читает переменную UEFI и отрезает четыре байта её атрибутов,
// которые efivarfs дописывает в начало каждого файла.
func readVar(varsDir, name string) ([]byte, error) {
	path := filepath.Join(varsDir, name+"-"+globalGUID)
	data, err := os.ReadFile(path)
	if err != nil {
		if os.IsPermission(err) {
			return nil, fmt.Errorf("нет прав на чтение %s, запусти через sudo", path)
		}
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("переменная %s не найдена", name)
		}
		return nil, err
	}
	if len(data) < 4 {
		return nil, fmt.Errorf("переменная %s слишком короткая: %d байт", name, len(data))
	}
	return data[4:], nil
}

// parseLoadOption разбирает структуру EFI_LOAD_OPTION.
// Раскладка: 4 байта атрибутов, 2 байта длины пути, дальше название
// в UTF-16 с нулевым окончанием, а за ним путь к файлу загрузчика.
func parseLoadOption(data []byte) (desc string, active bool, err error) {
	if len(data) < 6 {
		return "", false, fmt.Errorf("пункт загрузки короче шести байт")
	}
	attrs := binary.LittleEndian.Uint32(data[0:4])
	active = attrs&loadOptionActive != 0

	rest := data[6:]
	var units []uint16
	for i := 0; i+1 < len(rest); i += 2 {
		u := binary.LittleEndian.Uint16(rest[i : i+2])
		if u == 0 {
			return string(utf16.Decode(units)), active, nil
		}
		units = append(units, u)
	}
	return "", false, fmt.Errorf("название пункта загрузки не завершено нулём")
}
