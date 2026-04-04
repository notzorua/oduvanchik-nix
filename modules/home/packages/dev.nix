{ pkgs, ... }:
{
  home.packages = with pkgs; [
    ## Lsp
    nixd # nix

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

    ## Python
    python3
    
    python3Packages.pip
    python3Packages.ipython
    python3Packages.python-lsp-server
    python3Packages.python-lsp-jsonrpc
    python3Packages.python-lsp-black
    python3Packages.python-lsp-ruff
    python3Packages.pyls-isort
    python3Packages.pyls-flake8
    python3Packages.flake8
    python3Packages.isort
    python3Packages.black

    # Node.js
    nodejs_20
    nodePackages.vim-language-server
    nodePackages.bash-language-server  # for bashls
    nodePackages.yaml-language-server  # for yamlls
    
    pyright
    
    universal-ctags
    ripgrep
    
    lua-language-server                # for lua_ls
    ruff
    linux-wifi-hotspot
    cool-retro-term

    arduino
    arduino-cli

    omnisharp-roslyn    # Language Server (LSP)
    netcoredbg          # Debugger (DAP)
    ripgrep             # Required by many AstroNvim features
    #csharp-ls
    
    #dotnet-sdk_10

    #(with pkgs.dotnetCorePackages; combinePackages [
    #  sdk_9_0
    #  sdk_10_0
    #])

    netcoredbg
    mono
    roslyn-ls
    omnisharp-roslyn
    fontconfig
    freetype
    skia
    #xdotool
    libx11       # Essential for Avalonia
    icu               # Essential for .NET Globalization
    zlib              # Common compression
    libGL             # Hardware acceleration
    openssl           # Networking/Auth
  ];
}
