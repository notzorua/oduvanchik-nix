{ pkgs, ... }:
let
  # Имя интерфейса. Файл настроек ищется по пути
  # /etc/amnezia/amneziawg/ИМЯ.conf
  iface = "awg0";
in
{
  environment.systemPackages = with pkgs; [
    amneziawg-tools
    amneziawg-go
  ];

  # Модуль ядра не нужен: amneziawg-go работает в пространстве пользователя.
  # Медленнее ядерного варианта, но не ломается при обновлении ядра,
  # а для обычного интернета скорости хватает с запасом.

  systemd.services."amneziawg-${iface}" = {
    description = "AmneziaWG tunnel ${iface}";
    after = [ "network-online.target" ];
    wants = [ "network-online.target" ];

    # Не стартует сам при загрузке: включается вручную,
    # когда нужен. Убери эту строку, если хочешь автозапуск.
    wantedBy = [ ];

    path = with pkgs; [
      amneziawg-tools
      amneziawg-go
      iproute2
      iptables
    ];

    environment = {
      # Заставляет awg-quick использовать реализацию без модуля ядра.
      AWG_QUICK_USERSPACE_IMPLEMENTATION = "amneziawg-go";
      AWG_SUDO = "1";
    };

    serviceConfig = {
      Type = "oneshot";
      RemainAfterExit = true;
      ExecStart = "${pkgs.amneziawg-tools}/bin/awg-quick up ${iface}";
      ExecStop = "${pkgs.amneziawg-tools}/bin/awg-quick down ${iface}";
    };
  };
}
