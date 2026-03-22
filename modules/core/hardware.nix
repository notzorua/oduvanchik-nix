{ ... }:
{
  fileSystems."/mnt/additional" = {
    device = "/dev/disk/by-uuid/8A06FBC006FBAAF9";
    fsType = "ntfs-3g";
    options = [
      "rw"
      "uid=1000"     # Replace with your actual UID
      "gid=100"      # Replace with your actual GID (usually 100 or 1000)
      "users"      # Allows any user to mount/unmount
      "umask=000"      # Ensures files are executable by Steam
      "nofail"     # Prevents boot failure if the drive is missing
      "exec"
      "x-gvfs-show" # MANDATORY: Makes it visible in File Explorers
    ];
  };
  
  hardware.nvidia = {
    powerManagement.enable = true;
    open = false;
  };
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.enableRedistributableFirmware = true;
}
