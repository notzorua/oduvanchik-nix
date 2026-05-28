{ pkgs, ... }:
{
  hardware.opentabletdriver.enable = true;
  environment.systemPackages = [ pkgs.opentabletdriver ];

  # This must be at the top level of your NixOS configuration
  programs.nix-ld.enable = true;
  programs.nix-ld.libraries = with pkgs; [
    # Packages explicitly requested in the Nitrox script:
    stdenv.cc.cc.lib # Provides libstdc++.so.6
    fontconfig # For text rendering
    libx11 # (formerly xorg.libX11)
    libice # (formerly xorg.libICE)
    # Add other common dependencies if needed
    libsm # (formerly xorg.libSM)

    claude-code
    gemini-cli

    libadwaita
    gtk4
    pango
    gdk-pixbuf
    # Essential .NET/SkiaSharp extras not in that script but required for it to actually run:
    icu # Required for .NET globalization
    openssl # Required for .NET networking/auth
    zlib # Common compression dependency
    libGL # Required for SkiaSharp hardware acceleration
  ];

  #environment.systemPackages = with pkgs; [
  #  #dotnet-sdk_9_0-bin  # Use the -bin version you mentioned
  #  #dotnet-sdk_10_0-bin
  #  fontconfig        # Essential for SkiaSharp
  #  xorg.libX11       # Essential for Avalonia
  #  icu               # Essential for .NET Globalization
  #  zlib              # Common compression
  #  libGL             # Hardware acceleration
  #  openssl           # Networking/Auth
  #];
}
