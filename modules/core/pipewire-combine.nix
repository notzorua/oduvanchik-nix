# Только stem (импорт в hosts/stem/default.nix): выход «Speakers + Headphones» — звук
# одновременно в колонки (Line Out, зелёный разъём) и Bluetooth-наушники Redmi Buds 4 Active.
#
# libpipewire-module-combine-stream (опции сверены с документацией PipeWire 1.6.9 —
# комментарий в src/modules/module-combine-stream.c):
# - combine.latency-compensate — буферы задержки: колонки задерживаются до задержки
#   Bluetooth, звук в обоих совпадает. Цена — весь выход запаздывает на задержку наушников
#   (SBC — ~0.3 с, замер 18.10.2026), для ритм-игр (osu!) — прямой выход на колонки.
# - stream.rules — выходы по правилам совпадения. Модуль следит за реестром PipeWire:
#   подключились наушники — создаёт для них поток, отключились — убирает; без наушников
#   звук идёт только в колонки.
# - Наушники — регуляркой по MAC: суффикс .1 в имени узла — номер профиля Bluetooth,
#   может смениться (например, на гарнитурный HFP).
# - Ручное смещение задержки не задаём — полагаемся на автокомпенсацию. Задержка Bluetooth
#   зависит от кодека и может меняться между подключениями: подобранные −50 мс после
#   переподключения стали лишними. Если появился рассинхрон — pavucontrol → «Смещение
#   задержки» у наушников. Значение хранится в ~/.local/state/wireplumber/default-routes
#   (latencyOffsetNsec маршрута), не в репозитории: свойством узла в правиле WirePlumber
#   его не задать (node.latency-offset-msec в WirePlumber 0.5 — только для BLE MIDI).
{
  services.pipewire.extraConfig.pipewire."60-combine-speakers-headphones" = {
    "context.modules" = [
      {
        name = "libpipewire-module-combine-stream";
        args = {
          "combine.mode" = "sink";
          "node.name" = "combine_speakers_headphones";
          "node.description" = "Speakers + Headphones";
          "combine.latency-compensate" = true;
          "combine.props" = {
            "audio.position" = [
              "FL"
              "FR"
            ];
          };
          "stream.props" = { };
          "stream.rules" = [
            {
              matches = [
                {
                  "media.class" = "Audio/Sink";
                  "node.name" = "alsa_output.pci-0000_00_1f.3.analog-stereo";
                }
                {
                  "media.class" = "Audio/Sink";
                  "node.name" = "~bluez_output\\.14_0A_29_EB_04_97\\..*";
                }
              ];
              actions = {
                create-stream = { };
              };
            }
          ];
        };
      }
    ];
  };
}
