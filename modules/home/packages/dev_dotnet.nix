{ pkgs, ... }:

let
  myDotnetBundle = with pkgs.dotnetCorePackages; combinePackages [
    sdk_9_0-bin
    sdk_10_0-bin
  ];
in
{
  home.packages = [
    myDotnetBundle
  ];

  # Глобального LD_LIBRARY_PATH нет: nixpkgs сам прописывает SDK и собранным приложениям
  # загрузчик и пути к библиотекам (консольные приложения и ICU работают без него).
  # Переменная на весь сеанс подсовывала эти библиотеки всем программам — например, Chromium
  # из чужого nixpkgs падал с «GLIBC_2.43 not found». Если понадобится графика (Avalonia,
  # SkiaSharp), библиотеки давать только dotnet — обёрткой wrapProgram, не глобально.
  home.sessionVariables = {
    DOTNET_ROOT = "${myDotnetBundle}/share/dotnet";
  };
}
