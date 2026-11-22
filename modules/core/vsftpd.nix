{ username, ... }:
# FTP-сервер для учебной лабы: доступ с телефона по Wi-Fi.
# Включается импортом в hosts/fluff/default.nix; выключить — закомментировать импорт
# (служба, PAM и порты в firewall уйдут вместе с модулем).
# Вход: логин и пароль пользователя ${username}. FTP без TLS — пароль идёт открытым текстом,
# поэтому только в доверенной сети и только на время лабы.
let
  ftpRoot = "/home/${username}/ftp-share";
  pasvMin = 50000;
  pasvMax = 50010;
in
{
  services.vsftpd = {
    enable = true;
    localUsers = true; # вход под обычными пользователями системы
    writeEnable = true; # загрузка, удаление, mkdir
    anonymousUser = false; # анонимный вход выключен (явно, хотя это и так по умолчанию)
    userlistEnable = true; # пускать только пользователей из userlist
    userlistDeny = false; # userlist — список разрешённых, а не запрещённых
    userlist = [ username ];
    localRoot = ftpRoot; # после входа — сразу в ~/ftp-share
    chrootlocalUser = true; # выше ~/ftp-share клиент не поднимется
    allowWriteableChroot = true; # без этого vsftpd отказывает во входе: корень chroot доступен на запись
    extraConfig = ''
      pasv_enable=YES
      pasv_min_port=${toString pasvMin}
      pasv_max_port=${toString pasvMax}
      local_umask=022
    '';
  };

  # Модуль vsftpd из nixpkgs создаёт /etc/pam.d/vsftpd только для виртуальных пользователей.
  # Без этой строки сработает /etc/pam.d/other (pam_deny) → «530 Login incorrect».
  security.pam.services.vsftpd = { };

  systemd.tmpfiles.rules = [ "d ${ftpRoot} 0755 ${username} users -" ];

  networking.firewall = {
    allowedTCPPorts = [ 21 ];
    allowedTCPPortRanges = [
      {
        from = pasvMin;
        to = pasvMax;
      }
    ];
  };
}
