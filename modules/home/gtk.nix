{ lib, pkgs, host, ... }:
let
  gtk-theme-name = "Colloid-Green-Dark-Gruvbox";
  gtk-theme = pkgs.colloid-gtk-theme.override {
    colorVariants = [ "dark" ];
    themeVariants = [ "green" ];
    tweaks = [
      "gruvbox"
      "rimless"
      "float"
    ];
  };
  icon-theme-name = "Papirus-Dark";
in
{
  fonts.fontconfig.enable = true;
  home.packages = with pkgs; [
    nerd-fonts.jetbrains-mono
    nerd-fonts.fira-code
    nerd-fonts.caskaydia-cove
    nerd-fonts.symbols-only
    twemoji-color-font
    noto-fonts-color-emoji
    fantasque-sans-mono
    maple-mono-custom
    corefonts
  ];

  gtk = {
    enable = true;
    font = {
      name = "Maple Mono";
      size = 12;
    };
    theme = {
      name = gtk-theme-name;
      package = gtk-theme;
    };
    iconTheme = {
      name = icon-theme-name;
      package = pkgs.papirus-icon-theme.override { color = "green"; };
    };
    cursorTheme = {
      name = "Qogir-Light";
      package = pkgs.qogir-icon-theme;
      size = 48;
    };

    gtk3 = {
      extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkForce true;
      };
    };

    gtk4 = {
      theme = {
        name = gtk-theme-name;
        package = gtk-theme;
      };
      extraConfig = {
        gtk-application-prefer-dark-theme = lib.mkForce true;
      };
    };
  };

  dconf.settings = {
    "org/gnome/desktop/interface" = {
      gtk-theme = gtk-theme-name;
      icon-theme = icon-theme-name;
      color-scheme = "prefer-dark";
    };
  };

  home.pointerCursor = {
    enable = true;
    name = "Qogir-Light";
    package = pkgs.qogir-icon-theme;
    size = 48;
    gtk.enable = true;
    x11 = {
      enable = true;
      defaultCursor = "left_ptr";
    };
  };
  xresources.properties = {
    "Xcursor.size" = 48;
    "Xcursor.theme" = "Qogir-Light";
  };
}
