{ ... }:
{
  fileSystems."/mnt/additional" = {
    device = "/dev/disk/by-uuid/8A06FBC006FBAAF9";
    fsType = "ntfs3";
    options = [
      "uid=1000"     # Replace with your actual UID
      "gid=100"      # Replace with your actual GID (usually 100 or 1000)
      "users"      # Allows any user to mount/unmount
      "nofail"     # Prevents boot failure if the drive is missing
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
