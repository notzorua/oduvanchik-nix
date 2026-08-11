// bootcheck проверяет, доживёт ли машина до рабочего стола после перезагрузки.
//
// Версия 0.4. Шесть проверок:
//  1. ядра и initrd, на которые ссылается GRUB, лежат на разделе EFI;
//  2. запись загрузчика жива в переменных UEFI и стоит первой в BootOrder;
//  3. меню GRUB указывает на ту же систему, которая собрана;
//  4. на разделе EFI хватает места ещё на несколько поколений;
//  5. на разделе нет следов повреждения файловой системы;
//  6. на разделе не валяются файлы загрузчиков, которыми не пользуются.
package main

import (
	"flag"
	"fmt"
	"os"
	"path/filepath"
)

// result это итог одной проверки.
type result struct {
	failed bool
	warned bool
}

func (r *result) merge(o result) {
	r.failed = r.failed || o.failed
	r.warned = r.warned || o.warned
}

var verbose bool

func main() {
	bootDir := flag.String("boot", "/boot", "точка монтирования раздела EFI")
	cfgPath := flag.String("config", "", "путь к grub.cfg (по умолчанию BOOT/grub/grub.cfg)")
	varsDir := flag.String("efivars", efiVarsDir, "каталог с переменными UEFI")
	loader := flag.String("loader", "NixOS", "часть названия записи UEFI, которую ищем")
	profiles := flag.String("profiles", defaultProfilesDir, "каталог с поколениями системы")
	flag.BoolVar(&verbose, "v", false, "показывать в том числе успешные проверки")
	flag.Parse()

	cfg := *cfgPath
	if cfg == "" {
		cfg = filepath.Join(*bootDir, "grub", "grub.cfg")
	}

	var total result
	total.merge(checkKernels(*bootDir, cfg))
	fmt.Println()
	total.merge(checkUEFI(*varsDir, *loader))
	fmt.Println()
	total.merge(checkGenerations(*profiles, cfg))
	fmt.Println()
	total.merge(checkESPSpace(*bootDir))
	fmt.Println()
	total.merge(checkESPHealth(*bootDir))
	fmt.Println()
	total.merge(checkStaleLoaders(*bootDir, *varsDir))

	fmt.Println()
	switch {
	case total.failed:
		fmt.Println("ИТОГ: есть поломки, перезагружаться нельзя")
		os.Exit(1)
	case total.warned:
		fmt.Println("ИТОГ: загрузиться должно, но есть на что посмотреть")
		os.Exit(0)
	default:
		fmt.Println("ИТОГ: всё в порядке, можно перезагружаться")
		os.Exit(0)
	}
}

func okf(format string, a ...any) {
	if verbose {
		fmt.Printf("[ok]   "+format+"\n", a...)
	}
}

func sumf(format string, a ...any) {
	fmt.Printf("[ok]   "+format+"\n", a...)
}

func warnf(format string, a ...any) {
	fmt.Printf("[warn] "+format+"\n", a...)
}

func failf(format string, a ...any) {
	fmt.Printf("[FAIL] "+format+"\n", a...)
}

func notef(format string, a ...any) {
	fmt.Printf("       "+format+"\n", a...)
}
