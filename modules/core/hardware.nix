{ config, ... }:
{
  #fileSystems."/mnt/additional" = {
    #device = "/dev/disk/by-uuid/8A06FBC006FBAAF9";
    #fsType = "ntfs-3g";
    #options = [
      #"rw"
      #"uid=1000"     # Replace with your actual UID
      #"gid=100"      # Replace with your actual GID (usually 100 or 1000)
      #"users"      # Allows any user to mount/unmount
      #"umask=000"      # Ensures files are executable by Steam
      #"nofail"     # Prevents boot failure if the drive is missing
      #"exec"
      #"x-gvfs-show" # MANDATORY: Makes it visible in File Explorers
      #];
    #};
  
  fileSystems."/mnt/additional" = {
    device = "/dev/disk/by-uuid/8A06FBC006FBAAF9";
    fsType = "ntfs-3g"; # Use 'ntfs3' instead of 'ntfs-3g'
    options = [
      "rw"
      "uid=1000"
      "gid=100"
      "nofail"
      "umask=000"
      "prealloc"     # Helps with Steam disk allocation
      "user"         # Allow users to mount
      "exec"
      "x-gvfs-show"
    ];
  };

  # Enable the Xorg Xserver
  services.xserver.enable = true;
  # Load nvidia driver for Xorg and Wayland
  services.xserver.videoDrivers = ["nvidia"];

  hardware.nvidia = {
    # Modesetting is required.
    modesetting.enable = true;
    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    powerManagement.enable = false;
    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;
    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of
    # supported GPUs is at:
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus
    # Only available from driver 515.43.04+
    # Do not disable this unless your GPU is unsupported or if you have a good reason to.
    open = true;
    # Enable the Nvidia settings menu,
  	# accessible via `nvidia-settings`.
    nvidiaSettings = true;
    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
  };

  hardware.enableRedistributableFirmware = true;
}
