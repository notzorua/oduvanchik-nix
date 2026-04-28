#{ pkgs, ... }:
#{
#  boot = {
#    loader = {
#      systemd-boot.enable = true;
#      efi.canTouchEfiVariables = true;
#      systemd-boot.configurationLimit = 10;
#    };
#
#    kernelPackages = pkgs.linuxPackages_latest;
#    kernelModules = [ "hid-nintendo" ];
#    supportedFilesystems = [ "ntfs" ];
#  };
#}

{ pkgs, inputs, ... }:
{
  boot = {
    loader = {
      # 1. Disable systemd-boot
      systemd-boot.enable = false;

      # 2. Enable GRUB for UEFI
      grub = {
        enable = true;
        device = "nodev"; # Required for UEFI
        efiSupport = true;
        useOSProber = true; # Automatically finds Windows/other OSs
        
        theme = let
          colorsheme = "night";
          layout = "teleport";
          resolution = "1920x1080";
        in inputs.grubshin-bootpact.packages.${pkgs.stdenv.hostPlatform.system}.${colorsheme}.${layout}.${resolution};
      };

      # 3. Keep EFI settings
      efi = {
        canTouchEfiVariables = true;
      };
    };

    # Your existing settings
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "hid-nintendo" ];
    supportedFilesystems = [ "ntfs" ];
  };
}
