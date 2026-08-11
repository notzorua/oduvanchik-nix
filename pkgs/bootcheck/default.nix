{ lib, buildGoModule }:

buildGoModule {
  pname = "bootcheck";
  version = "0.4.0";

  src = ./.;

  # Программа обходится стандартной библиотекой, сторонних модулей нет.
  vendorHash = null;

  # Убираем таблицу символов и отладочные данные, файл становится вдвое меньше.
  ldflags = [ "-s" "-w" ];

  meta = with lib; {
    description = "Проверка загрузчика перед перезагрузкой NixOS";
    longDescription = ''
      Проверяет шесть вещей: файлы ядер из меню GRUB лежат на разделе EFI,
      запись загрузчика жива в переменных UEFI, меню указывает на собранную
      систему, на разделе хватает места, нет следов повреждения FAT и нет
      файлов от загрузчиков, которыми система больше не пользуется.
    '';
    license = licenses.mit;
    platforms = platforms.linux;
    mainProgram = "bootcheck";
  };
}
