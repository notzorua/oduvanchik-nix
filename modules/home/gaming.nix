{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    lutris

    
    #wineWow64Packages.stable
    #wineWow64Packages.stable
    #wineWow64Packages.waylandFull
    #winetricks
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.winetricks-git
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-ge
    vulkan-tools


    cabextract

    heroic-unwrapped

    ## Minecraft
    prismlauncher

    ## Cli games
    vitetris
    nethack

    osu-lazer-bin
  ];
}
