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
      offload.enableOffloadCmd = false; # свой nvidia-offload ниже: штатный не снимает переменные сеанса
      amdgpuBusId = "PCI:5@0:0:0"; # 0000:05:00.0
      nvidiaBusId = "PCI:1@0:0:0"; # 0000:01:00.0
    };
    # Без KMS на NVIDIA: с modeset=1 nvidia_drm поднимает NVKMS, тот создаёт дисплейный канал
    # и блокирует сон (GC6), пока считает какой-то выход активным → runtime_usage=1, RTX не засыпает.
    # Экраны fluff — на AMD; offload (renderD128, PRIME) должен работать и без KMS.
    # mkForce: NixOS ставит modeset=1 и fbdev=1 при prime.offload / modesetting (общий hardware.nix).
    moduleParams.nvidia-drm = {
      modeset = lib.mkForce 0;
      fbdev = lib.mkForce 0;
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
  # Цена: HDMI и USB-C DP подключены к NVIDIA и в Hyprland не работают. Временно вернуть HDMI:
  #   1) убрать moduleParams.nvidia-drm выше (без KMS на NVIDIA выходов нет вообще);
  #   2) здесь "/dev/dri/amd-igpu:/dev/dri/nvidia-dgpu" (AMD первой — рендер остаётся на ней) или убрать переменную;
  #   затем nh os boot . и перезагрузка (Hyprland выбирает карты только при запуске). RTX тогда не будет засыпать.
  environment.sessionVariables = {
    AQ_DRM_DEVICES = "/dev/dri/amd-igpu";

    # EGL и Vulkan видят только Mesa/AMD — иначе каждое GL/Vulkan-приложение (Hyprland, swaync, GTK4)
    # при запуске грузит библиотеки NVIDIA, держит /dev/nvidia0 и RTX не засыпает.
    # Оба пути — 64 и 32 бит: в 50_mesa.json полный путь к 64-битной libEGL_mesa.
    # Снимаются в nvidia-offload. Откат: убрать обе переменные и вернуть enableOffloadCmd = true.
    __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/50_mesa.json:/run/opengl-driver-32/share/glvnd/egl_vendor.d/50_mesa.json";
    VK_DRIVER_FILES = "/run/opengl-driver/share/vulkan/icd.d/radeon_icd.x86_64.json:/run/opengl-driver-32/share/vulkan/icd.d/radeon_icd.i686.json";
  };

  # Как штатный nvidia-offload из nixpkgs (те же 4 переменные), но сначала снимает ограничения сеанса выше.
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "nvidia-offload" ''
      unset __EGL_VENDOR_LIBRARY_FILENAMES VK_DRIVER_FILES
      export __NV_PRIME_RENDER_OFFLOAD=1
      export __NV_PRIME_RENDER_OFFLOAD_PROVIDER=NVIDIA-G0
      export __GLX_VENDOR_LIBRARY_NAME=nvidia
      export __VK_LAYER_NV_optimus=NVIDIA_only
      exec "$@"
    '')
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

  nixpkgs.overlays = [ inputs.millennium.overlays.default ];
  services.asusd = {
    enable = true;
};
}
