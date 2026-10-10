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

  # Стабильные имена карт для AQ_DRM_DEVICES: номера cardN могут меняться между загрузками,
  # а пути /dev/dri/by-path содержат «:», который в AQ_DRM_DEVICES — разделитель списка.
  services.udev.extraRules = ''
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="0000:05:00.0", SYMLINK+="dri/amd-igpu"
    SUBSYSTEM=="drm", KERNEL=="card[0-9]*", KERNELS=="0000:01:00.0", SYMLINK+="dri/nvidia-dgpu"
  '';

  # Hyprland (Aquamarine) открывает только AMD — иначе держит card1 и RTX не засыпает.
  # Читается до hyprland.lua, поэтому задаётся здесь (PAM-окружение сеанса lightdm), а не в конфиге Hyprland.
  # Цена: HDMI подключён к NVIDIA и в Hyprland не работает. Временно вернуть HDMI:
  #   "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu" (AMD первой — рендер остаётся на ней) или убрать переменную;
  #   затем nh os boot . и перезагрузка (Hyprland выбирает карты только при запуске).
  environment.sessionVariables.AQ_DRM_DEVICES = "/dev/dri/amd-igpu";

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
