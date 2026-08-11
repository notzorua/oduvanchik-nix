{ inputs, pkgs, ... }:
{
  # Bootloader check, source lives at github.com/notzorua/bootcheck
  environment.systemPackages = [
    inputs.bootcheck.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
