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
    anki-bin # официальная сборка, та же версия, что была во Flatpak (anki из исходников отстаёт)
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
    discord-canary
    inputs.ayugram-desktop.packages.${pkgs.stdenv.hostPlatform.system}.default
    osu-lazer-bin
    bottles
    github-desktop
    tor-browser
    librewolf
    qutebrowser
  ];
}
