{ inputs, ... }:
{
  imports = [ inputs.nix-flatpak.nixosModules.nix-flatpak ];

  # Только то, чего нет в nixpkgs. Anki и Lutris — из nixpkgs (gui.nix, gaming.nix).
  services.flatpak = {
    enable = true;
    remotes = [
      {
        name = "flathub";
        location = "https://dl.flathub.org/repo/flathub.flatpakrepo";
      }
    ];
    packages = [
      "com.github.tchx84.Flatseal" # просмотр прав Flatpak-программ
      "org.vinegarhq.Sober" # Roblox; переопределения для fluff — в hosts/fluff
    ];
    # Программы и репозитории, поставленные руками (flatpak install / remote-add), удаляются при switch.
    # Данные в ~/.var/app не трогаются (uninstall без --delete-data).
    uninstallUnmanaged = true;
    # Таймер systemd раз в неделю; при switch не обновляет (update.onActivation = false по умолчанию).
    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
    overrides.settings.global = {
      # Force Wayland by default
      Context.sockets = [
        "wayland"
        "!x11"
        "!fallback-x11"
      ];
    };
  };
}
