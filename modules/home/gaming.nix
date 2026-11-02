{ pkgs, inputs, ... }:
{
  home.packages = with pkgs; [

    (pkgs.lutris.override {
      # Intercept buildFHSEnv to modify target packages
      buildFHSEnv =
        args:
        pkgs.buildFHSEnv (
          args
          // {
            multiPkgs =
              envPkgs:
              let
                # Fetch original package list
                originalPkgs = args.multiPkgs envPkgs;

                # Disable tests for openldap
                customLdap = envPkgs.openldap.overrideAttrs (_: {
                  doCheck = false;
                });
              in
              # Replace broken openldap with the custom one;
              # gtk2 — broken в nixpkgs (issue 410814), нужен только старым нативным играм
              builtins.filter (
                p:
                !(builtins.elem (p.pname or "") [
                  "openldap"
                  "gtk+"
                ])
              ) originalPkgs
              ++ [ customLdap ];
          }
        );
    })

    #wineWow64Packages.stable
    #wineWow64Packages.stable
    #wineWow64Packages.waylandFull
    #winetricks
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.winetricks-git
    inputs.nix-gaming.packages.${pkgs.stdenv.hostPlatform.system}.wine-ge
    vulkan-tools
    samba

    cabextract

    heroic-unwrapped

    mangohud
    protontricks
    samrewritten

    ## Minecraft
    prismlauncher

    ## Cli games
    vitetris
    nethack

  ];

}
