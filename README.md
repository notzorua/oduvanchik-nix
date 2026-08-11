# oduvanchik-nix

This is my NixOS configuration, and I think it turned out great.

Everything here is declarative. The whole desktop, down to the shell prompt and
the wallpaper, is described in Nix files and rebuilt with a single command. No
manual tweaking that gets forgotten by next month, no half configured machine
after a reinstall. Clone the repository, run one rebuild, and the system comes
back exactly as it was.

The desktop runs Hyprland with Waybar along the bottom of the screen rather
than the top, because that is where a bar belongs. Rofi launches things,
Ghostty runs the shell, zsh handles the rest. VSCodium for editing, Hyprlock
for locking, SwayNC for notifications, Nemo for files. Everything wears Gruvbox
Dark Hard, which is where the repository gets its name.

Keybinds follow vim directions, so moving focus, swapping windows and resizing
all live under the same four keys. Pressing the mod key with F1 prints the full
list from inside the system, which beats keeping a cheat sheet in a README that
slowly goes stale.

The configuration is split by host and by scope. System level settings sit in
one place, user level settings in another, and each program keeps its own file
instead of everything piling into one enormous module. Adding a machine means
adding a host, not rewriting anything.

Installing takes three steps: clone it into the home directory, enter the
folder, and rebuild with the desktop flake target.

It started as a fork of adarkaz/nixos-configuration, which in turn grew out of
Frost-Phoenix/nixos-config. Good ideas travel, and I have kept the ones that
worked while replacing the rest.
