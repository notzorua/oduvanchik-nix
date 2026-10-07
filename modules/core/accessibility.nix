{ pkgs, ... }:
{
  # Orca screen reader (for testing sites in Zen/Firefox).
  # The nixpkgs module also enables services.gnome.at-spi2-core (org.a11y.Bus)
  # and services.speechd (speech-dispatcher + espeak-ng).
  services.orca.enable = true;

  # AT-SPI tree inspector: shows roles/names the browser exposes to Orca
  environment.systemPackages = [ pkgs.accerciser ];
}
