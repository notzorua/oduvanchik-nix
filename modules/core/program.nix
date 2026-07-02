{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  boot.kernelModules = [ "tun" ];
  environment.systemPackages = with pkgs; [
    mihomo
  ];
  programs = {
    throne.enable = true;
    throne.tunMode.enable = true;
    throne.tunMode.setuid = true;
    dconf.enable = true;
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    appimage.enable = true;
  };
}
