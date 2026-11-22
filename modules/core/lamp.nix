{ pkgs, username, ... }:
# Учебная лаба «Серверная архитектура»: Apache 2.4 + PHP 8.3 + MySQL 8.4 LTS, только localhost.
# Включается импортом в hosts/fluff/default.nix; выключить — закомментировать импорт.
# Данные MySQL (/var/lib/mysql) и файлы в /var/www/lab при выключении остаются на диске.
let
  docRoot = "/var/www/lab";
in
{
  services.httpd = {
    enable = true;
    adminAddr = "${username}@localhost";
    enablePHP = true;
    # Модуль httpd сам добавляет apxs2Support (и вместе с ним ztsSupport) через override.
    phpPackage = pkgs.php83.buildEnv {
      extensions = { enabled, all }: enabled ++ (with all; [ mysqli pdo_mysql mbstring ]);
    };
    virtualHosts.localhost = {
      documentRoot = docRoot;
      # Только loopback: порт 80 в firewall открыт глобально (modules/core/network.nix),
      # поэтому ограничиваем сам Apache, а не firewall.
      listen = [
        {
          ip = "127.0.0.1";
          port = 80;
        }
      ];
      extraConfig = ''
        DirectoryIndex index.php index.html
        <Directory "${docRoot}">
          Options Indexes FollowSymLinks
          AllowOverride All
          Require local
        </Directory>
      '';
    };
  };

  services.mysql = {
    enable = true;
    package = pkgs.mysql84; # 8.4 LTS
    settings.mysqld.bind-address = "127.0.0.1"; # TCP только с localhost (сокет /run/mysqld/mysqld.sock — как обычно)
  };

  # Учебный пользователь lab / lab123 со всеми правами на базы lab_*.
  # ensureUsers модуля mysql создаёт пользователей только с входом по сокету (auth_socket, без пароля),
  # а для phpMyAdmin нужен пароль — поэтому отдельная служба. Она идемпотентна (IF NOT EXISTS):
  # пароль задаётся только при создании, сменённый в phpMyAdmin не перезапишется.
  # Пароль лежит в /nix/store (читается всеми) — допустимо только для учебного пароля.
  # root@localhost не трогаем: модуль оставляет ему auth_socket (вход только `sudo mysql`).
  systemd.services.mysql-lab-user = {
    description = "Create MySQL lab user";
    after = [ "mysql.service" ];
    requires = [ "mysql.service" ];
    wantedBy = [ "multi-user.target" ];
    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
    };
    script = ''
      ${pkgs.mysql84}/bin/mysql -u root -N <<'SQL'
      CREATE USER IF NOT EXISTS 'lab'@'localhost' IDENTIFIED BY 'lab123';
      GRANT ALL PRIVILEGES ON `lab\_%`.* TO 'lab'@'localhost';
      SQL
    '';
  };

  # Владелец zoroa — файлы можно класть без sudo; 0755 — Apache (wwwrun) читает.
  systemd.tmpfiles.rules = [
    "d /var/www 0755 root root -"
    "d ${docRoot} 0755 ${username} users -"
  ];
}
