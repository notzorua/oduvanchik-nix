{ host, lib, pkgs, ... }:
let
  roseFrost = host == "stem";
in
{
  home.packages = with pkgs; [ rofi ];

  xdg.configFile = {
    "rofi/theme.rasi".text = builtins.readFile ./theme.rasi + lib.optionalString roseFrost ''
      * {
        bg-col: #33263ADB;
        bg-col-light: #3E2D46;
        border-col: #78617F;
        selected-col: #63445E;
        green: #D4C5E9;
        fg-col: #F6EEE8;
        fg-col2: #FAEFEA;
        grey: #DDD0DF;
        element-bg: transparent;
        element-alternate-bg: transparent;
      }
    '';

    "rofi/config.rasi".text =
      let
        base = builtins.readFile ./config.rasi;
      in
      if roseFrost then
        lib.replaceStrings [ "run,drun,window" "lines: 5" "sidebar-mode: true" ]
          [ "run,window" "lines: 7" "sidebar-mode: false" ] base
        + ''
          window {
            width: 640px;
            height: 0px;
            padding: 16px;
            border: 1px;
            border-radius: 16px;
          }
          mainbox { spacing: 12px; background-color: transparent; }
          inputbar { padding: 6px 10px; border-radius: 10px; }
          prompt { margin: 0px 8px 0px 0px; padding: 6px; border-radius: 6px; }
          entry { margin: 0px; padding: 6px; background-color: transparent; }
          listview { spacing: 4px; background-color: transparent; }
          element { padding: 10px 12px; border-radius: 9px; cursor: pointer; }
          element selected.normal { background-color: @selected-col; text-color: @fg-col2; }
        ''
      else
        base;

    "rofi/powermenu-theme.rasi".text = builtins.readFile ./powermenu-theme.rasi + lib.optionalString roseFrost ''
      window { padding: 12px; border: 1px solid; border-radius: 16px; }
      mainbox { background-color: transparent; }
      listview { spacing: 6px; }
      element { padding: 20px 0px; border-radius: 9px; }
      element selected.normal { text-color: @fg-col2; }
    '';
  };
}
