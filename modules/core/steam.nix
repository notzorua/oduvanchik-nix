{ pkgs, ... }:
{
  programs = {
    steam = {
      enable = true;
      gamescopeSession.enable = true;
      extraCompatPackages = [ pkgs.proton-ge-bin ];
      
      # Временно используем стандартный Steam, чтобы исключить влияние Millennium
      package = pkgs.steam; 
    };

    gamescope = {
      enable = true;
      capSysNice = true;
      args = [
        "--rt"
        "--expose-wayland"
      ];
    };
  };

  hardware.steam-hardware.enable = true;
  services.joycond.enable = true;

  # Для новых версий NixOS используем hardware.graphics
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # Критично для Proton!
  };
}
