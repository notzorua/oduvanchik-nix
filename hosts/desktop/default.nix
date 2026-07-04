{ ... }:
{
  imports = [
    ./hardware-configuration.nix
    ./../../modules/core
  ];

  powerManagement.cpuFreqGovernor = "performance";

  fileSystems."/run/media/zoroa/6ACE40E5CE40AAE1" = {
    device = "/dev/disk/by-uuid/6ACE40E5CE40AAE1";
    fsType = "ntfs3";
    options = [
      "force" 
      "nofail" 
      "uid=1000" 
      "gid=100" 
      "fmask=0022" 
      "dmask=0022" 
      "windows_names" 
      "rw"
    ];
  };

  security.polkit.extraConfig = ''
    polkit.addRule(function(action, subject) {
        if ((action.id == "org.freedesktop.udisks2.filesystem-mount" ||
             action.id == "org.freedesktop.udisks2.filesystem-mount-system" ||
             action.id == "org.freedesktop.udisks2.encrypted-unlock" ||
             action.id == "org.freedesktop.udisks2.eject-media" ||
             action.id == "org.freedesktop.udisks2.power-off-drive") &&
            subject.isInGroup("users")) {
            return polkit.Result.YES;
        }
    });
  '';
  networking.firewall.trustedInterfaces = [ "virbr0" ];
}
