{ pkgs, ... }:
{
  imports = [
    ./nixpkgs.nix
    ./bootloader.nix
    ./bootcheck.nix
    ./hardware.nix
    ./xserver.nix
    ./network.nix
    ./bluetooth.nix
    ./davinchi.nix
    ./nh.nix
    ./pipewire.nix
    ./dev.nix
    ./program.nix
    ./security.nix
    ./services.nix
    ./steam.nix
    ./system.nix
    ./flatpak.nix
    ./user.nix
    ./wayland.nix
    ./virtualization.nix
    ./qmk.nix
    ./ollama.nix
    ./amneziawg.nix
    ./own-tools.nix
  ];

  # This adds the package to your global system environment
  environment.systemPackages = [
    (pkgs.callPackage ./nvimunity.nix { })
  ];
}
