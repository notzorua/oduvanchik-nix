{ pkgs, config, ... }:
# GigaIDE (Сбер, GitVerse) — сборка IntelliJ IDEA Community 2026.1 (IC-261.*)
# со своей JBR 25 (JetBrains Runtime) и JCEF внутри архива; плагины ставятся
# с gigaide.ru/marketplace, а не с JetBrains Marketplace.
# Архив не в Nix: распаковать в ~/.local/share/gigaide и сделать ссылку current:
#   mkdir -p ~/.local/share/gigaide
#   tar -xzf ~/Downloads/gigaide-261.26222.65.2.tar.gz -C ~/.local/share/gigaide
#   ln -sfn gigaide-261.26222.65.2 ~/.local/share/gigaide/current
# Обновление — так же (новая папка + ссылка), пересборка конфига не нужна.
# Запуск — в FHS-окружении (обычные /usr/lib, /lib64/ld-linux…): бинарники из
# архива собраны под обычный Linux. Список — все NEEDED из ELF-файлов архива
# (bin/idea, jbr/lib, lib/*.so) + то, что грузится через dlopen (gtk3, libsecret).
let
  dir = "${config.home.homeDirectory}/.local/share/gigaide/current";

  gigaide = pkgs.buildFHSEnv {
    name = "gigaide";
    targetPkgs =
      pkgs: with pkgs; [
        # JBR: AWT/Swing (X11 и Wayland), звук, шрифты
        stdenv.cc.cc.lib
        zlib
        freetype
        fontconfig
        alsa-lib
        cups
        libx11
        libxext
        libxi
        libxrender
        libxtst
        libxrandr
        libxcursor
        libxxf86vm
        libxcb
        libxkbcommon
        wayland
        libGL
        libdrm
        libgbm
        glib
        gtk3 # dlopen: GTK-вид, системные диалоги
        # JCEF (встроенный Chromium: превью Markdown, окна плагинов)
        nss
        nspr
        atk
        at-spi2-atk
        at-spi2-core
        cairo
        pango
        dbus
        expat
        libxcomposite
        libxdamage
        libxfixes
        udev
        libsecret # dlopen: пароли (Git, GitVerse) в gnome-keyring
      ];
    runScript = pkgs.writeShellScript "gigaide-run" ''
      exec ${dir}/bin/idea "$@"
    '';
  };
in
{
  home.packages = [ gigaide ];

  xdg.desktopEntries.gigaide = {
    name = "GigaIDE";
    genericName = "IDE";
    exec = "gigaide %F";
    icon = "${dir}/bin/idea.svg";
    terminal = false;
    categories = [
      "Development"
      "IDE"
    ];
    # startupWmClass из product-info.json
    settings.StartupWMClass = "giga-ide-2026.1";
  };
}
