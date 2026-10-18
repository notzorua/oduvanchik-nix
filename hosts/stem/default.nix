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