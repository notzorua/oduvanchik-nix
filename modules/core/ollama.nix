{ pkgs, ... }:
{
  # Локальная языковая модель. Слушает только 127.0.0.1:11434,
  # наружу ничего не торчит.
  services.ollama = {
    enable = true;

    # Собираем только под RTX 4060 (вычислительная способность 8.9).
    # Без этого сборка идёт под все карты сразу и занимает часы.
    package = pkgs.ollama-cuda.override {
      cudaArches = [ "89" ];
    };

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
