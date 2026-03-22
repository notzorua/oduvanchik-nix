{ pkgs, ... }:
{
  services = {
    asusd.enable = true;
    gvfs.enable = true;
            
    timesyncd.enable = true;      # Keep the time exact (seconds/minutes)
    automatic-timezoned.enable = true; # Change the hour when you travel
    geoclue2.enable = true;       # Let the PC find your location

    gnome = {
      tinysparql.enable = true;
      gnome-keyring.enable = true;
    };

    dbus.enable = true;
    fstrim.enable = true;

    # needed for GNOME services outside of GNOME Desktop
    dbus.packages = with pkgs; [
      gcr
      gnome-settings-daemon
    ];

    logind.settings.Login = {
      # don’t shutdown when power button is short-pressed
      HandlePowerKey = "ignore";

      # ignore lid close when docked/external monitor conected
      HandleLidSwitchDocked = "ignore";
    };

    udisks2.enable = true;
  };
}
