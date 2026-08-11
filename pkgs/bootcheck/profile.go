package main

import (
	"fmt"
	"os"
	"path/filepath"
	"regexp"
	"sort"
	"strconv"
)

const defaultProfilesDir = "/nix/var/nix/profiles"

var genLinkRe = regexp.MustCompile(`^system-(\d+)-link$`)

// checkGenerations сравнивает собранную систему с тем, что записано в меню GRUB,
// и заодно считает, сколько поколений вообще есть.
func checkGenerations(profilesDir, cfg string) result {
	res := result{}

	nums, err := listGenerations(profilesDir)
	if err != nil {
		warnf("поколения: %v", err)
		return result{warned: true}
	}
	if len(nums) == 0 {
		warnf("поколения: в %s ничего не найдено", profilesDir)
		return result{warned: true}
	}
	newest := nums[len(nums)-1]
	okf("поколения: всего %s, последнее номер %d", plural(len(nums), "штука", "штуки", "штук"), newest)

	// В меню GRUB попадают не все поколения, а сколько разрешает
	// configurationLimit в настройках загрузчика. Остальные живут
	// в хранилище и доступны через nixos-rebuild, но не при загрузке.
	inMenuCount, menuErr := menuEntryCount(cfg)
	if menuErr == nil && inMenuCount > 0 && inMenuCount < len(nums) {
		okf("поколения: в меню GRUB попало %d из %d, остальные ограничены configurationLimit", inMenuCount, len(nums))
	}

	// Куда указывает профиль системы прямо сейчас.
	built, err := os.Readlink(filepath.Join(profilesDir, "system"))
	if err != nil {
		warnf("поколения: не читается ссылка system: %v", err)
		res.warned = true
		built = ""
	} else if !filepath.IsAbs(built) {
		built = filepath.Join(profilesDir, built)
	}

	// Куда ведёт пункт меню по умолчанию.
	inMenu, err := defaultSystemPath(cfg)
	if err != nil {
		warnf("поколения: %v", err)
		return mergeInto(res, result{warned: true})
	}

	if built == "" || inMenu == "" {
		sumf("поколения: всего %s, сравнить с меню не удалось", plural(len(nums), "поколение", "поколения", "поколений"))
		return mergeInto(res, result{warned: true})
	}

	// Профиль это ссылка на ссылку, разворачиваем до конца.
	if real, err := filepath.EvalSymlinks(built); err == nil {
		built = real
	}
	if abs, err := filepath.Abs(built); err == nil {
		built = abs
	}
	if abs, err := filepath.Abs(inMenu); err == nil {
		inMenu = abs
	}

	if built != inMenu {
		failf("загрузчик отстал от системы")
		notef("собрано:  %s", built)
		notef("в меню:   %s", inMenu)
		notef("пересборка прошла, а установка загрузчика нет")
		notef("после перезагрузки ты окажешься в старой системе")
		res.failed = true
	} else {
		okf("поколения: меню указывает на ту же систему, что собрана")
	}

	// Много поколений это не поломка, но раздел EFI не резиновый.
	if len(nums) > 40 {
		warnf("поколения: их %s, каждое держит систему в хранилище", plural(len(nums), "штука", "штуки", "штук"))
		notef("почистить: sudo nix-collect-garbage --delete-older-than 30d")
		res.warned = true
	}

	if !res.failed && !res.warned {
		if menuErr == nil && inMenuCount > 0 && inMenuCount < len(nums) {
			sumf("поколения: всего %s, в меню GRUB %d, меню совпадает с собранной системой", plural(len(nums), "штука", "штуки", "штук"), inMenuCount)
		} else {
			sumf("поколения: всего %s, меню совпадает с собранной системой", plural(len(nums), "поколение", "поколения", "поколений"))
		}
	}
	return res
}

// listGenerations возвращает номера поколений системы по возрастанию.
func listGenerations(profilesDir string) ([]int, error) {
	entries, err := os.ReadDir(profilesDir)
	if err != nil {
		if os.IsNotExist(err) {
			return nil, fmt.Errorf("каталог %s не найден", profilesDir)
		}
		if os.IsPermission(err) {
			return nil, fmt.Errorf("нет прав на чтение %s, запусти через sudo", profilesDir)
		}
		return nil, err
	}
	var nums []int
	for _, e := range entries {
		m := genLinkRe.FindStringSubmatch(e.Name())
		if m == nil {
			continue
		}
		n, err := strconv.Atoi(m[1])
		if err != nil {
			continue
		}
		nums = append(nums, n)
	}
	sort.Ints(nums)
	return nums, nil
}

func mergeInto(a, b result) result {
	a.merge(b)
	return a
}
