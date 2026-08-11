package main

import "fmt"

// plural подставляет к числу нужную форму слова.
// Формы задаются для 1, для 2 и для 5: файл, файла, файлов.
func plural(n int, one, few, many string) string {
	return fmt.Sprintf("%d %s", n, form(n, one, few, many))
}

// form выбирает форму слова без самого числа.
func form(n int, one, few, many string) string {
	if n < 0 {
		n = -n
	}
	mod100 := n % 100
	if mod100 >= 11 && mod100 <= 14 {
		return many
	}
	switch n % 10 {
	case 1:
		return one
	case 2, 3, 4:
		return few
	default:
		return many
	}
}
