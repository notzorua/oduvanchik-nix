package main

import (
	"fmt"
	"os"
	"path/filepath"
	"sort"
	"strings"
	"syscall"
)

// checkESPSpace смотрит, хватит ли места на разделе EFI ещё на несколько поколений.
// Когда место кончается, новое ядро записывается наполовину и загрузчик ломается.
func checkESPSpace(bootDir string) result {
	var st syscall.Statfs_t
	if err := syscall.Statfs(bootDir, &st); err != nil {
		failf("место на %s: %v", bootDir, err)
		return result{failed: true}
	}

	bs := uint64(st.Bsize)
	total := st.Blocks * bs
	free := st.Bavail * bs
	used := total - free

	pair := kernelPairSize(bootDir)
	okf("место: занято %s из %s, свободно %s", human(used), human(total), human(free))

	if pair == 0 {
		sumf("место: свободно %s из %s", human(free), human(total))
		return result{}
	}

	fits := free / pair
	okf("место: одно поколение весит примерно %s", human(pair))

	switch {
	case fits < 2:
		failf("место: свободно %s, это меньше двух поколений по %s", human(free), human(pair))
		notef("следующая пересборка может не записаться целиком")
		return result{failed: true}
	case fits < 5:
		warnf("место: свободно %s, хватит примерно на %s", human(free), plural(int(fits), "поколение", "поколения", "поколений"))
		notef("уменьши configurationLimit или почисти старые поколения")
		return result{warned: true}
	default:
		sumf("место: свободно %s из %s, хватит примерно на %s", human(free), human(total), plural(int(fits), "поколение", "поколения", "поколений"))
		return result{}
	}
}

// kernelPairSize оценивает, сколько весит одно поколение:
// самое большое ядро плюс самый большой initrd.
func kernelPairSize(bootDir string) uint64 {
	entries, err := os.ReadDir(filepath.Join(bootDir, "kernels"))
	if err != nil {
		return 0
	}
	var maxKernel, maxInitrd uint64
	for _, e := range entries {
		info, err := e.Info()
		if err != nil {
			continue
		}
		sz := uint64(info.Size())
		name := e.Name()
		switch {
		case strings.HasSuffix(name, "-bzImage"):
			if sz > maxKernel {
				maxKernel = sz
			}
		case strings.HasSuffix(name, "-initrd"):
			if sz > maxInitrd {
				maxInitrd = sz
			}
		}
	}
	return maxKernel + maxInitrd
}

// checkESPHealth ищет следы того, что раздел EFI когда-то чинили,
// и мусор от загрузчиков, которыми ты больше не пользуешься.
func checkESPHealth(bootDir string) result {
	res := result{}

	// Файлы вида FSCK0000.REC создаёт проверка FAT, складывая туда
	// потерянные куски данных. Их наличие значит, что раздел был повреждён.
	recs, _ := filepath.Glob(filepath.Join(bootDir, "*.REC"))
	sort.Strings(recs)
	if len(recs) > 0 {
		warnf("целостность: найдено %s от восстановления FAT", plural(len(recs), "файл", "файла", "файлов"))
		for _, r := range recs {
			notef("%s", r)
		}
		notef("раздел EFI когда-то чинили, обычно после жёсткого выключения")
		notef("сами файлы бесполезны и их можно удалить")
		res.warned = true
	} else {
		okf("целостность: следов восстановления FAT нет")
	}

	// Папка loader остаётся от systemd-boot. Если рядом лежит grub,
	// значит загрузчик меняли, а старое не убрали.
	loaderDir := filepath.Join(bootDir, "loader")
	grubDir := filepath.Join(bootDir, "grub")
	_, loaderErr := os.Stat(loaderDir)
	_, grubErr := os.Stat(grubDir)
	if loaderErr == nil && grubErr == nil {
		warnf("мусор: рядом лежат %s и %s", grubDir, loaderDir)
		notef("папка loader осталась от systemd-boot, загрузке не мешает")
		res.warned = true
	}

	if !res.warned && !res.failed {
		sumf("целостность: следов повреждения и мусора не найдено")
	}
	return res
}

// human переводит байты в понятный вид.
func human(b uint64) string {
	const unit = 1024
	if b < unit {
		return fmt.Sprintf("%d Б", b)
	}
	div, exp := uint64(unit), 0
	for n := b / unit; n >= unit; n /= unit {
		div *= unit
		exp++
	}
	names := []string{"КБ", "МБ", "ГБ", "ТБ"}
	if exp >= len(names) {
		exp = len(names) - 1
	}
	return fmt.Sprintf("%.1f %s", float64(b)/float64(div), names[exp])
}
