{ pkgs, ... }:
{
  home.packages = with pkgs; [
    lutris
    wineWow64Packages.stagingFull
    ## Minecraft
    prismlauncher

    ## Cli games
    vitetris
    nethack

    osu-lazer-bin
  ];
}
