# oduvanchik-nix

[![Stars](https://img.shields.io/github/stars/notzorua/oduvanchik-nix?color=FABD2F&labelColor=282828&style=for-the-badge&logo=starship&logoColor=FABD2F)](https://github.com/notzorua/oduvanchik-nix/stargazers)
[![Repo size](https://img.shields.io/github/repo-size/notzorua/oduvanchik-nix?color=FE8019&labelColor=282828&style=for-the-badge&logo=github&logoColor=FE8019)](https://github.com/notzorua/oduvanchik-nix)
[![NixOS](https://img.shields.io/badge/NixOS-unstable-blue.svg?style=for-the-badge&labelColor=282828&logo=NixOS&logoColor=458588&color=458588)](https://nixos.org)

My NixOS and Hyprland setup, themed Gruvbox Dark Hard. Started as a fork of
[adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration)
and has been drifting my way ever since.

```
zoroa @ desktop
─────────────────
OS      NixOS (unstable)
WM      Hyprland
Shell   zsh
Theme   Gruvbox Dark Hard
Bar     Waybar
Term    Ghostty
```

Waybar sits at the bottom, not the top. Rofi launches things, Ghostty runs the
shell, VSCodium edits, Hyprlock locks, SwayNC notifies, Nemo handles files.

Keybinds live in [binds.nix](modules/home/hyprland/binds.nix). Inside the
system, `$mod F1` prints the full list.

## Install

```sh
git clone git@github.com:notzorua/oduvanchik-nix.git ~/nixos-configuration
cd ~/nixos-configuration
sudo nixos-rebuild switch --flake .#desktop
```

## Thanks

[adarkaz/nixos-configuration](https://github.com/adarkaz/nixos-configuration),
which in turn grew out of
[Frost-Phoenix/nixos-config](https://github.com/Frost-Phoenix/nixos-config).
