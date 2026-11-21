{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      
      # Временно используем стандартный Steam, чтобы исключить влияние Millennium
      package = pkgs.millennium-steam;
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };

    # Feral GameMode: на время игры — governor performance, renice и т. п.
    # Запуск в Steam: `gamemoderun %command%` (на fluff: `nvidia-offload gamemoderun %command%`)
    gamemode.enable = true;
  };

  hardware.steam-hardware.enable = true;
  services.joycond.enable = true;

  # Для новых версий NixOS используем hardware.graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Критично для Proton!
  };
}
