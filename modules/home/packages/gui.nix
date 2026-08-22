{ pkgs, ... }:
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
    ayugram-desktop
    osu-lazer-bin
    bottles
    github-desktop
    bottles
    github-desktop
  ];
}
