{ inputs, pkgs, ... }:
let
  pkgs-throne = import inputs.nixpkgs-throne {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    "${inputs.nixpkgs-throne}/nixos/modules/programs/throne.nix"
  ];

  disabledModules = [ "programs/throne.nix" ];

  # nix-daemon качает исходники (fetchurl, unfree-пакеты вроде discord-canary)
  # сам, без окружения пользователя, — заблокированные домены давали timeout.
  # Пускаем его через смешанный прокси Throne. Бинарные кэши — напрямую:
  # через прокси cache.nixos.org очень медленный. Суффикс «.cachix.org»
  # libcurl (а через него и Nix) понимает как все поддомены — проверено.
  # Если Throne не запущен (он стартует из автозапуска Hyprland, от пользователя),
  # всё, что не из no_proxy, падает с «Connection refused» на 127.0.0.1:2080 —
  # запустить Throne или убрать этот блок.
  systemd.services.nix-daemon.environment = {
    http_proxy = "http://127.0.0.1:2080";
    https_proxy = "http://127.0.0.1:2080";
    no_proxy = "127.0.0.1,localhost,::1,cache.nixos.org,cache.nixos-cuda.org,.cachix.org";
  };

  virtualisation.waydroid.enable = true;
  boot.kernelModules = [ "tun" ];
  environment.systemPackages = with pkgs; [
    mihomo
  ];
  programs = {
    throne.enable = true;
    throne.tunMode.enable = true;
    throne.tunMode.setuid = true;
    throne.package = pkgs-throne.throne;
    dconf.enable = true;
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    appimage.enable = true;
  };
}
