package main

import (
	"bufio"
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strings"
)

// ref это одна ссылка на файл из конфига GRUB.
type ref struct {
	path    string   // путь относительно раздела EFI, например /kernels/abc-bzImage
	entries []string // названия пунктов меню, которые на него ссылаются
}

// checkKernels проверяет, что все файлы из grub.cfg реально лежат на диске.
func checkKernels(bootDir, cfg string) result {
	refs, err := parseGrubConfig(cfg)
	if err != nil {
		failf("ядра и initrd: %v", err)
		return result{failed: true}
	}
	if len(refs) == 0 {
		failf("ядра и initrd: в %s нет ни одной строки linux или initrd", cfg)
		return result{failed: true}
	}

	missing := 0
	defaultBroken := false

	for _, r := range refs {
		full := filepath.Join(bootDir, r.path)
		if _, err := os.Stat(full); err != nil {
			missing++
			if isDefaultEntry(r.entries) {
				defaultBroken = true
			}
			failf("нет файла %s", full)
			notef("на него ссылается: %s", describe(r.entries))
			continue
		}
		okf("%s (ссылок: %d)", full, len(r.entries))
	}

	if missing == 0 {
		sumf("ядра и initrd: проверено %s, все на месте", plural(len(refs), "файл", "файла", "файлов"))
		return result{}
	}

	failf("ядра и initrd: не хватает %s из %d", plural(missing, "файла", "файлов", "файлов"), len(refs))
	if defaultBroken {
		notef("сломан пункт по умолчанию, машина упадёт в консоль grub>")
	} else {
		notef("пункт по умолчанию цел, но старые поколения не загрузятся")
	}
	return result{failed: true}
}

// isDefaultEntry говорит, попал ли файл в самый первый пункт меню.
// В конфиге NixOS он называется просто "NixOS" и грузится без выбора.
func isDefaultEntry(entries []string) bool {
	for _, e := range entries {
		if e == "NixOS" {
			return true
		}
	}
	return false
}

// parseGrubConfig читает grub.cfg и возвращает уникальные ссылки на файлы,
// сохраняя порядок первого появления.
func parseGrubConfig(path string) ([]ref, error) {
	f, err := os.Open(path)
	if err != nil {
		if os.IsPermission(err) {
			return nil, fmt.Errorf("нет прав на чтение %s, запусти через sudo", path)
		}
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("файл %s не найден, укажи путь через -config", path)
		}
		return nil, err
	}
	defer f.Close()

	var (
		order   []string
		byPath  = map[string]*ref{}
		current = "(вне пунктов меню)"
	)

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024)

	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())

		if title, ok := menuTitle(line); ok {
			current = title
			continue
		}

		raw, ok := fileArg(line)
		if !ok {
			continue
		}
		p := espPath(raw)
		if p == "" {
			continue
		}

		r, seen := byPath[p]
		if !seen {
			r = &ref{path: p}
			byPath[p] = r
			order = append(order, p)
		}
		if !contains(r.entries, current) {
			r.entries = append(r.entries, current)
		}
	}
	if err := sc.Err(); err != nil {
		return nil, err
	}

	out := make([]ref, 0, len(order))
	for _, p := range order {
		out = append(out, *byPath[p])
	}
	return out, nil
}

// menuTitle достаёт название пункта меню из строки menuentry "...".
func menuTitle(line string) (string, bool) {
	if !strings.HasPrefix(line, "menuentry") {
		return "", false
	}
	start := strings.Index(line, "\"")
	if start < 0 {
		return "", false
	}
	end := strings.Index(line[start+1:], "\"")
	if end < 0 {
		return "", false
	}
	return line[start+1 : start+1+end], true
}

// fileArg возвращает первый аргумент строк linux и initrd.
// Из "linux ($drive1)//kernels/abc init=..." вернёт "($drive1)//kernels/abc".
func fileArg(line string) (string, bool) {
	fields := strings.Fields(line)
	if len(fields) < 2 {
		return "", false
	}
	switch fields[0] {
	case "linux", "linux16", "linuxefi", "initrd", "initrd16", "initrdefi":
		return fields[1], true
	}
	return "", false
}

// espPath превращает путь из конфига GRUB в путь относительно раздела EFI.
// Убирает указание диска в скобках и схлопывает повторяющиеся слэши.
func espPath(raw string) string {
	s := raw
	if strings.HasPrefix(s, "(") {
		i := strings.Index(s, ")")
		if i < 0 {
			return ""
		}
		s = s[i+1:]
	}
	for strings.Contains(s, "//") {
		s = strings.ReplaceAll(s, "//", "/")
	}
	if s == "" || s == "/" {
		return ""
	}
	if !strings.HasPrefix(s, "/") {
		s = "/" + s
	}
	return s
}

func contains(list []string, v string) bool {
	for _, s := range list {
		if s == v {
			return true
		}
	}
	return false
}

// describe красиво перечисляет пункты меню, обрезая длинный список.
func describe(entries []string) string {
	e := append([]string(nil), entries...)
	sort.Strings(e)
	if len(e) <= 3 {
		return strings.Join(e, "; ")
	}
	return fmt.Sprintf("%s и ещё %s", strings.Join(e[:3], "; "), plural(len(e)-3, "пункт", "пункта", "пунктов"))
}

// initPathRe достаёт путь к системе из параметра init=/nix/store/HASH-.../init.
var initPathRe = regexp.MustCompile(`(?:^|\s)init=(\S+)/init(?:\s|$)`)

// defaultSystemPath возвращает путь в хранилище, на который ведёт
// самый первый пункт меню, то есть тот, что грузится без выбора.
func defaultSystemPath(cfg string) (string, error) {
	f, err := os.Open(cfg)
	if err != nil {
		return "", fmt.Errorf("не читается %s: %w", cfg, err)
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024)

	inFirst := false
	for sc.Scan() {
		line := strings.TrimSpace(sc.Text())
		if _, ok := menuTitle(line); ok {
			if inFirst {
				break // первый пункт кончился, дальше не смотрим
			}
			inFirst = true
			continue
		}
		if !inFirst {
			continue
		}
		if m := initPathRe.FindStringSubmatch(line); m != nil {
			return m[1], nil
		}
	}
	if err := sc.Err(); err != nil {
		return "", err
	}
	return "", fmt.Errorf("в первом пункте меню нет параметра init=")
}

// menuEntryCount считает пункты меню, которые ведут на поколения системы.
// Самый первый пункт, который грузится по умолчанию, не в счёт:
// он дублирует последнее поколение.
func menuEntryCount(cfg string) (int, error) {
	f, err := os.Open(cfg)
	if err != nil {
		return 0, err
	}
	defer f.Close()

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 0, 64*1024), 1024*1024)

	n := 0
	for sc.Scan() {
		title, ok := menuTitle(strings.TrimSpace(sc.Text()))
		if !ok {
			continue
		}
		if strings.Contains(title, "Configuration") {
			n++
		}
	}
	return n, sc.Err()
}
