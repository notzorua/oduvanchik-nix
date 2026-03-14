{ username, ... }:
{
  services = {
    xserver = {
      videoDrivers = [ "nvidia" ];
      enable = true;

      xkb = {
        layout = "us,ru";
        options = "grp:alt_caps_toggle";
      };
    };

    displayManager.autoLogin = {
      enable = true;
      user = "${username}";
    };
    libinput = {
      enable = true;
    };
  };
  # To prevent getting stuck at shutdown
  systemd.settings.Manager.DefaultTimeoutStopSec = "10s";
}
