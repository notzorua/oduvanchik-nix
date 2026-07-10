{ pkgs, ... }:
{
  programs.vscode = {
    enable = true;
    package = pkgs.vscodium;
    extensions = with pkgs.vscode-extensions; [
      golang.go
    ];
  };

  home.packages = with pkgs; [
    pipes-rs
    cbonsai     
    cmatrix     
    samrewritten
    asciiquarium-transparent
    protontricks
    chromium
    gh
    obsidian
    virt-manager
    tesseract
    cool-retro-term
    (pkgs.ollama.override { acceleration = "cuda"; })
  ];
}
