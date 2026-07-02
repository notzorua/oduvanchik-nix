{ ... }:
let
  custom = {
    font = "Maple Mono";
    font_size = "16px";
    font_weight = "bold";
    text_color = "#A89984";
    background_0 = "#1D2021";
    background_1 = "#282828";
    border_color = "#3C3836";
    red = "#CC241D";
    green = "#98971A";
    yellow = "#FABD2F";
    blue = "#458588";
    magenta = "#B16286";
    cyan = "#689D6A";
    orange = "#D65D0E";
    orange_bright = "#FE8019";
    opacity = "0.7";
    indicator_height = "2px";
  };
in
{
  programs.waybar.style = with custom; ''
    * {
      border: none;
      border-radius: 0;
      padding: 0;
      margin: 0;
      font-family: ${font};
      font-weight: ${font_weight};
      font-size: ${font_size};
      min-height: 0;
    }
    window#waybar {
      background: #161819;
      color: ${text_color};
    }
    #custom-launcher {
      font-size: 18px;
      color: #504945;
      padding: 0 12px 0 12px;
      margin: 0;
    }
    #custom-launcher:hover { color: #D65D0E; }
    #workspaces { padding: 0 4px; }
    #workspaces button {
      color: #504945;
      padding: 0 8px;
      font-size: 14px;
    }
    #workspaces button.active {
      color: #A89984;
    }
    #workspaces button.empty { color: #32302F; }
    #workspaces button:hover { color: #7C6F64; }
    #tray { padding: 0 8px; border-left: 1px solid #32302F; }
    #clock {
      color: #7C6F64;
      padding: 0 16px;
      border-left: 1px solid #32302F;
      border-right: 1px solid #32302F;
    }
    #cpu { color: #665C54; padding: 0 8px; }
    #memory { color: #665C54; padding: 0 8px; }
    #pulseaudio { color: #665C54; padding: 0 8px; }
    #network { color: #665C54; padding: 0 8px; }
    #language { color: #665C54; padding: 0 8px; }
    #custom-notification { color: #665C54; padding: 0 8px; }
    #custom-power-menu { color: #504945; padding: 0 10px; }
    #custom-power-menu:hover { color: #CC241D; }
    tooltip { background: #1D2021; border: 1px solid #3C3836; }
    tooltip label { margin: 4px; color: #A89984; }
    #tray menu { background: #1D2021; border: 1px solid #3C3836; padding: 6px; }
    #tray menuitem { padding: 2px 6px; color: #A89984; }
  '';
}
