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

    # 4. Boot splash
    plymouth = {
      enable = true;
      theme = "spin";
      themePackages = [
        # The package ships ~100 themes; keeping only the one in use
        # avoids dragging the rest into the initrd.
        (pkgs.adi1090x-plymouth-themes.override { selected_themes = [ "spin" ]; })
      ];
    };

    # `quiet` is left out on purpose: the boot messages stay visible.
    # `boot.shell_on_fail` gives a rescue shell if something goes wrong,
    # which matters because a splash screen otherwise hides the error.
    kernelParams = [ "splash" "boot.shell_on_fail" ];

    # Your existing settings
    kernelPackages = pkgs.linuxPackages_latest;
    kernelModules = [ "hid-nintendo" ];
    supportedFilesystems = [ "ntfs" ];
  };
}