{ inputs, pkgs, ... }:
let
  system = pkgs.stdenv.hostPlatform.system;
in
{
  # Собственные утилиты, живут в отдельных репозиториях.
  # Обновляются по одной: nix flake update ИМЯ
  environment.systemPackages = [
    inputs.flakeguard.packages.${system}.default
    inputs.hyprtime.packages.${system}.default
  ];
}
