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
  ];
}
