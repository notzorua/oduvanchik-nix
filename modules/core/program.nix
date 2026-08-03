{ inputs, pkgs, ... }:
let
  pkgs-throne = import inputs.nixpkgs-throne {
    inherit (pkgs.stdenv.hostPlatform) system;
    config.allowUnfree = true;
  };
in
{
  imports = [
    "${inputs.nixpkgs-throne}/nixos/modules/programs/throne.nix"
  ];

  disabledModules = [ "programs/throne.nix" ];

  virtualisation.waydroid.enable = true;
  boot.kernelModules = [ "tun" ];
  environment.systemPackages = with pkgs; [
    mihomo
  ];
  programs = {
    throne.enable = true;
    throne.tunMode.enable = true;
    throne.tunMode.setuid = true;
    throne.package = pkgs-throne.throne;
    dconf.enable = true;
    zsh.enable = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    appimage.enable = true;
  };
}
