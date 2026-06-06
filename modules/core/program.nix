{ pkgs, ... }:
{
  virtualisation.waydroid.enable = true;
  programs = {
    throne.enable = true;

    throne.tunMode.enable = true;
    throne.tunMode.setuid = true;

    dconf.enable = true;
    zsh.enable = true;

    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
      # pinentryFlavor = "";
    };

    appimage.enable = true;
  };
}
