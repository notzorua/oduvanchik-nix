{ pkgs, ... }:
{
  home.packages = with pkgs; [
    discord-canary

    (makeDesktopItem {
      name = "discord-canary-proxy";
      desktopName = "Discord Canary (Proxy)";
      genericName = "Internet Messenger";
      icon = "discord-canary";
      categories = [ "Network" "InstantMessaging" ];
      terminal = false;
    })
  ];
}
