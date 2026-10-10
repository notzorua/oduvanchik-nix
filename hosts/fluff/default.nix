{
  pkgs,
  inputs,
  ...
}:
{
  imports = [
    ./hardware-configuration.nix
    ../../modules/core
    ../../modules/core/virtualbox.nix
  ];

  powerManagement.cpuFreqGovernor = "performance";

  # Яркость: вместо nvidia_wmi_ec_backlight (не управляет экраном) — родной регулятор amdgpu (iGPU 780M)
  boot.kernelParams = [ "acpi_backlight=native" ];

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

  nixpkgs.overlays = [ inputs.millennium.overlays.default ];
  services.asusd = {
    enable = true;
};
}
