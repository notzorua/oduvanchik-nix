{ pkgs, ... }:
{
  programs.vscodium = {
    enable = true;
    profiles.default.extensions = with pkgs.vscode-extensions; [
      golang.go
      ms-dotnettools.csharp
      ms-dotnettools.vscode-dotnet-runtime
    ];
  };
}
