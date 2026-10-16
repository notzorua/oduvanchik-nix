{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Lsp
    nixd # nix
    nil

    ## javascript
    vtsls
    typescript

    claude-code

    ## formating
    shfmt
    treefmt
    nixfmt

    ## C / C++
    gcc
    gdb
    gef
    cmake
    gnumake
    valgrind
    llvmPackages_20.clang-tools

    #rust
    cargo
    rust-analyzer
    rustc
    rustfmt
    # rustup
    
    go

    ## Python
    python3

    python3Packages.pip
    python3Packages.tkinter
    python3Packages.ipython
    python3Packages.python-lsp-server
    python3Packages.python-lsp-jsonrpc
    python3Packages.python-lsp-black
   #python3Packages.python-lsp-ruff    # временно: не собирается, тесты не проходят с ruff 0.16
    python3Packages.pyls-isort
    python3Packages.pyls-flake8
    python3Packages.flake8
    python3Packages.isort
    python3Packages.black

    # Node.js
    ##nodejs_20
    nodejs

    pyright

    universal-ctags

    lua-language-server # for lua_ls
    ruff
    linux-wifi-hotspot
    cool-retro-term

    arduino
    arduino-cli

    omnisharp-roslyn # Language Server (LSP)
    netcoredbg # Debugger (DAP)
    # ripgrep (нужен AstroNvim) — в cli.nix
    #csharp-ls

    #dotnet-sdk_10

    #(with pkgs.dotnetCorePackages; combinePackages [
    #  sdk_9_0
    #  sdk_10_0
    #])

    mono
    roslyn-ls
    #xdotool
    # Библиотеки для .NET (fontconfig, icu, libGL…) — в programs.nix-ld.libraries (modules/core/dev.nix):
    # в home.packages программам они не видны.
  ];
}
