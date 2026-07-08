{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.glide.homeModules.default ];

  home.username = "robert";
  home.homeDirectory = "/home/robert";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

  home.packages = [ pkgs.sccache ];

  home.file = {
    ".thunderbird/28ga8wbb.default/chrome/userChrome.css".source =
      ./thunderbird/userChrome.css;
    ".thunderbird/28ga8wbb.default/user.js".source = ./thunderbird/user.js;
  };

  gtk = {
    enable = true;
    theme = {
      name = "adw-gtk3-dark";
      package = pkgs.adw-gtk3;
    };
    gtk4.theme = config.gtk.theme;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
  };

  programs.glide-browser.enable = true;

  xdg.mimeApps = {
    enable = true;
    defaultApplications = {
      "text/html" = "glide.desktop";
      "x-scheme-handler/http" = "glide.desktop";
      "x-scheme-handler/https" = "glide.desktop";
      "x-scheme-handler/about" = "glide.desktop";
      "x-scheme-handler/unknown" = "glide.desktop";
      "x-scheme-handler/gemini" = "glide.desktop";
      "application/xhtml+xml" = "glide.desktop";
      "x-scheme-handler/claude-cli" = "claude-code-url-handler.desktop";
    };
  };
}
