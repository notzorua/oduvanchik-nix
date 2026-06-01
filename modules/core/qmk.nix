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
}
