
{ inputs, ... }: {
  imports = [
    inputs.noctalia.homeModules.default
  ];

  programs.noctalia = {
    enable = true;
    systemd.enable = true;

    settings = {
      theme = {
        source = "builtin";
        builtin = "Rosé Pine";
        mode = "dark";
      };

      wallpaper = {
        enabled = true;
        directory = "/home/zoroa/nixos-configuration/wallpapers";
        fill_mode = "crop";

        automation = {
          enabled = false;
        };
      };
    };
  };
}
