{ ... }:
{
  programs.zsh = {
    shellAliases = {
      # Utils
      c = "clear";
      cd = "z";
      tt = "gtrash put";
      cat = "bat";
      #nano = "micro";
      code = "codium";
      diff = "delta --diff-so-fancy --side-by-side";
      less = "bat";
      copy = "wl-copy";
      f = "superfile";
      py = "python";
      ipy = "ipython";
      icat = "kitten icat";
      dsize = "du -hs";
      pdf = "tdf";
      open = "xdg-open";
      space = "ncdu";
      man = "batman";

      l = "eza --icons -a --group-directories-first -1 --no-user --long"; # EZA_ICON_SPACING=2
      tree = "eza --icons --tree --group-directories-first";

      # Nixos
      cdnix = "builtin cd ~/nixos-configuration && codium ~/nixos-configuration";
      ns = "nom-shell --run zsh";
      nsp = "nom-shell --run zsh -p";
      nd = "nom develop --command zsh";
      nb = "nom build";
      nc = "nh-notify nh clean all --keep 5";
      nft = "nh-notify nh os test";
      nfs = "nh-notify nh os switch";
      nfu = "nh-notify nh os switch --update";
      nsearch = "nh search";

      nixup-profile = "NIXPKGS_ALLOW_UNFREE=1 nix profile upgrade --all --impure";
      nixup = "builtin cd ~/nixos-configuration && git add -A && nh os switch .";
      # python
      piv = "python -m venv .venv";
      psv = "source .venv/bin/activate";
    };
  };
}
