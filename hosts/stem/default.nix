{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/core/ollama.nix # только stem: собран под RTX 4060 (cudaArches 89)
    ../../modules/core/pipewire-combine.nix # только stem: выход «Speakers + Headphones»
  ];

  powerManagement.cpuFreqGovernor = "performance";

  # Dual boot с Windows 11: Windows держит аппаратные часы в местном времени.
  # Без этого после загрузки Windows время в NixOS сдвигается на часовой пояс (и наоборот).
  time.hardwareClockInLocalTime = true;

  # Подкачка — файлом (раздела подкачки на stem нет). У fluff свой раздел (hardware-configuration.nix).
  swapDevices = [
    {
      device = "/var/lib/swapfile";
      size = 16 * 1024; # 16 GiB
    }
  ];

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
             action.id == "org.freedesktop.udisks2.eject-media" ||
             action.id == "org.freedesktop.udisks2.power-off-drive") &&
            subject.isInGroup("users")) {
            return polkit.Result.YES;
        }
    });
  '';

  networking.firewall.trustedInterfaces = [ "virbr0" ];

}