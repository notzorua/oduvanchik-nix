{ inputs, pkgs, ... }:
{
  programs.waybar = {
    enable = true;
    # Waybar из nixpkgs шлёт старый синтаксис dispatch — кнопки рабочих столов не работают с Lua-конфигом.
    package = inputs.waybar.packages.${pkgs.stdenv.hostPlatform.system}.waybar;
  };
}
