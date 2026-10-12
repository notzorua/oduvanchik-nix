{ pkgs, ... }:
{
  # Локальная языковая модель. Слушает только 127.0.0.1:11434,
  # наружу ничего не торчит.
  services.ollama = {
    enable = true;

    # Обычный ollama-cuda: готовый лежит в cache.nixos-cuda.org (архитектуры 7.5…12.1, в т.ч.
    # 8.9 — RTX 4060). Своё cudaArches меняет derivation → кэш мимо, локальная сборка после
    # каждого обновления nixpkgs. Цена — ~300 МиБ на диске за лишние архитектуры.
    package = pkgs.ollama-cuda;

    # Модель скачается при первой пересборке, около 5 ГБ.
    loadModels = [ "qwen3:8b" ];
  };

  # Известный баг: служба стартует раньше, чем видеокарта готова,
  # и модель молча уезжает на процессор. Ждём появления устройства.
  systemd.services.ollama = {
    after = [ "dev-nvidia0.device" ];
    wants = [ "dev-nvidia0.device" ];
  };

  # Бинарный кэш CUDA. Без него ollama-cuda собирается из исходников.
  # Адрес сменился в ноябре 2025, старый cuda-maintainers.cachix.org устарел.
  nix.settings = {
    substituters = [ "https://cache.nixos-cuda.org" ];
    trusted-public-keys = [
      "cache.nixos-cuda.org:74DUi4Ye579gUqzH4ziL9IyiJBlDpMRn9MBN8oNan9M="
    ];
  };
}
