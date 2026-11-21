{
  config,
  pkgs,
  lib,
  ...
}:
{
  environment.systemPackages = with pkgs; [
    davinci-resolve
  ];
}
