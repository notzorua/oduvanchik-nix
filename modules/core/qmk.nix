{ pkgs, ... }:
{
  environment.systemPackages = with pkgs; [
    via
    vial
    qmk
    qmk-udev-rules

    waydroid-helper
  ];

  services.udev.packages = with pkgs; [
    via
    vial
    qmk-udev-rules
  ];

  # Правила udev от QMK написаны в расчёте на эту группу,
  # в NixOS её по умолчанию нет.
  users.groups.plugdev = { };
}
