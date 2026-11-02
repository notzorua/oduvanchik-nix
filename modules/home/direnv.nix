{ config, lib, ... }:
let
  direnv = lib.getExe config.programs.direnv.package;
in
{
  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    # штатный хук стоит после p10k instant prompt — вывод direnv при старте
    # даёт предупреждение «console output during zsh initialization»
    enableZshIntegration = false;
  };

  # как советует powerlevel10k: export — до instant prompt (окружение .envrc
  # грузится, пока вывод ещё можно печатать), hook — после;
  # instant prompt в zsh.nix идёт с порядком по умолчанию (1000)
  programs.zsh.initContent = lib.mkMerge [
    (lib.mkOrder 500 ''
      emulate zsh -c "$(${direnv} export zsh)"
    '')
    (lib.mkOrder 1500 ''
      emulate zsh -c "$(${direnv} hook zsh)"
    '')
  ];
}
