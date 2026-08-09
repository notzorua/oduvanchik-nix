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
        device = "nodev";
        efiSupport = true;
        useOSProber = false;
        configurationLimit = 10;

        theme = pkgs.runCommand "oneshot-grub-theme" { } ''
          mkdir -p $out
          tar xzf ${pkgs.fetchurl {
            url = "https://raw.githubusercontent.com/Maplesyrup2080/oneshot-grub-theme/6a0c69cbc559ce56d810fe82930a9a75e153f553/niko-theme.tar.gz";
            hash = "sha256-x8qZNVNZeLScrpPTKKbEsIVbiyniXRztPjPgC/gvh6o=";
          }} -C $out --strip-components=1
        '';

        gfxmodeEfi = "2560x1440";
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
