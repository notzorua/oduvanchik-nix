package main

import (
	"os"
	"path/filepath"
	"strings"
)

// leftover это папка от загрузчика, который больше не используется.
type leftover struct {
	path string
	what string
	size uint64
}

// checkStaleLoaders ищет файлы чужих загрузчиков на разделе EFI.
//
// Каждый загрузчик кладёт ядра к себе. Когда загрузчик меняют,
// его копии ядер остаются лежать и занимать место, при этом
// проверка целостности их не замечает: GRUB на них не ссылается,
// а значит с его точки зрения всё в порядке.
func checkStaleLoaders(bootDir, varsDir string) result {
	// Проверка имеет смысл только если сейчас используется GRUB.
	if _, err := os.Stat(filepath.Join(bootDir, "grub", "grub.cfg")); err != nil {
		okf("остатки: GRUB не используется, проверка пропущена")
		return result{}
	}

	// Если прошивка до сих пор знает про systemd-boot, он ещё живой.
	if inUse, name := systemdBootInUEFI(varsDir); inUse {
		okf("остатки: в UEFI есть запись %q, systemd-boot ещё нужен", name)
		return result{}
	}

	efiDir := filepath.Join(bootDir, "EFI")
	candidates := []struct{ path, what string }{
		{filepath.Join(efiDir, "systemd"), "сам systemd-boot"},
		{filepath.Join(efiDir, "nixos"), "ядра systemd-boot"},
		{filepath.Join(efiDir, "Linux"), "ядра одним файлом"},
		{filepath.Join(bootDir, "loader"), "настройки systemd-boot"},
	}

	var found []leftover
	var total uint64
	for _, c := range candidates {
		st, err := os.Stat(c.path)
		if err != nil || !st.IsDir() {
			continue
		}
		// Папку с ядрами трогаем только если внутри правда файлы .efi,
		// чтобы случайно не приписать лишнего.
		if strings.HasSuffix(c.path, "nixos") && !hasEFIFiles(c.path) {
			continue
		}
		sz := dirSize(c.path)
		found = append(found, leftover{path: c.path, what: c.what, size: sz})
		total += sz
	}

	if len(found) == 0 {
		sumf("остатки: чужих загрузчиков на разделе нет")
		return result{}
	}

	warnf("остатки: %s от systemd-boot %s %s",
		plural(len(found), "папка", "папки", "папок"),
		form(len(found), "занимает", "занимают", "занимают"),
		human(total))
	for _, l := range found {
		notef("%s, %s, %s", l.path, l.what, human(l.size))
	}
	notef("GRUB на эти файлы не ссылается, их можно удалить")
	return result{warned: true}
}

// systemdBootInUEFI говорит, ссылается ли прошивка на systemd-boot.
func systemdBootInUEFI(varsDir string) (bool, string) {
	entries, err := readBootEntries(varsDir)
	if err != nil {
		return false, ""
	}
	for _, e := range entries {
		d := strings.ToLower(e.desc)
		if strings.Contains(d, "linux boot manager") || strings.Contains(d, "systemd") {
			return true, e.desc
		}
	}
	return false, ""
}

// hasEFIFiles говорит, лежат ли в папке образы .efi.
func hasEFIFiles(dir string) bool {
	entries, err := os.ReadDir(dir)
	if err != nil {
		return false
	}
	for _, e := range entries {
		if !e.IsDir() && strings.HasSuffix(strings.ToLower(e.Name()), ".efi") {
			return true
		}
	}
	return false
}

// dirSize складывает размеры всех файлов внутри папки.
func dirSize(dir string) uint64 {
	var total uint64
	filepath.WalkDir(dir, func(_ string, d os.DirEntry, err error) error {
		if err != nil || d.IsDir() {
			return nil
		}
		if info, err := d.Info(); err == nil {
			total += uint64(info.Size())
		}
		return nil
	})
	return total
}
