{ pkgs, config, user, inputs, ... }:
{
 # home.packages = [
#    inputs.nixvim.packages.x86_64-linux.default
 # ];
  
  #imports = [
   #   inputs.nixvim.packages.x86_64-linux.default
  #];

  
    
  programs.neovim = {
    enable = true;
  #  
  # withPython3 = true;
  #  withNodeJs = true;
    
  #  # This tells Nix to bake pynvim into the Neovim environment
  #  extraPython3Packages = ps: with ps; [
  #      python-lsp-server
  #      python-lsp-jsonrpc
  #      python-lsp-black
  #     python-lsp-ruff
  #      pyls-isort
  #      pyls-flake8
  #      flake8
  #      isort
  #      black
  #  ];
  };
}
