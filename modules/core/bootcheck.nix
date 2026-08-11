{ pkgs, ... }:
{
  # Проверка загрузчика перед перезагрузкой.
  # Исходники лежат в pkgs/bootcheck, там же описание сборки.
  environment.systemPackages = [
    (pkgs.callPackage ../../pkgs/bootcheck { })
  ];
}
