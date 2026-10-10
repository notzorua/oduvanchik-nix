{
  pkgs,
  lib,
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

  # Гибридная графика: всё рисует iGPU AMD 780M (к ней подключён eDP-1),
  # RTX 3050 — только по запросу: nvidia-offload <программа>.
  # Только для fluff: у stem (i5-12400F) встроенной графики нет.
  hardware.nvidia = {
    # mkForce: в общем modules/core/hardware.nix стоит false (для stem)
    powerManagement.finegrained = lib.mkForce true; # RTX засыпает (D3cold), когда не нужна
    prime = {
      offload.enable = true;
      offload.enableOffloadCmd = true;
      amdgpuBusId = "PCI:5@0:0:0"; # 0000:05:00.0
      nvidiaBusId = "PCI:1@0:0:0"; # 0000:01:00.0
    };
  };

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
