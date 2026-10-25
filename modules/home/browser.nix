{ inputs, pkgs, ... }:
{
  imports = [ inputs.zen-browser.homeModules.beta ];

  programs.zen-browser = {
    enable = true;
    # about:config через policies.json: не трогает profiles.ini и профиль
    policies.Preferences = {
      # без всплывающих подсказок (и title на сайтах)
      "browser.chrome.toolbar_tips" = {
        Value = false;
        Status = "default";
      };
    };
  };

  xdg.mimeApps =
    let
      value =
        let
          system = pkgs.stdenv.hostPlatform.system;
          zen-browser = inputs.zen-browser.packages.${system}.beta;
        in
        "zen.desktop";

      associations = builtins.listToAttrs (
        map (name: { inherit name value; }) [
          "application/x-extension-shtml"
          "application/x-extension-xhtml"
          "application/x-extension-html"
          "application/x-extension-xht"
          "application/x-extension-htm"
          "x-scheme-handler/unknown"
          "x-scheme-handler/mailto"
          "x-scheme-handler/chrome"
          "x-scheme-handler/about"
          "x-scheme-handler/https"
          "x-scheme-handler/http"
          "application/xhtml+xml"
          "application/json"
          "text/html"
        ]
      );
    in
    {
      associations.added = associations;
      defaultApplications = associations;
    };
}
