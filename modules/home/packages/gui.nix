{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [
    ## Multimedia
    amberol # music player
    audacity
    gimp
    media-downloader
    obs-studio
    pavucontrol
    soundwireserver
    video-trimmer
    vlc

    ## Office
    libreoffice
    gnome-calculator

    ## Utility
    dconf-editor
    gnome-disk-utility
    popsicle
    mission-center # GUI resources monitor
    zenity
    chromium
    qbittorrent
    virt-manager
    discord-canary
    inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
    osu-lazer-bin
    bottles
    github-desktop
    bottles
    github-desktop
    tor-browser
    librewolf
    qutebrowser
  ];
}
