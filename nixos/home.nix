{ config, pkgs, lib, inputs, ... }:

{
  imports = [ inputs.glide.homeModules.default ];

  home.username = "robert";
  home.homeDirectory = "/home/robert";
  home.stateVersion = "25.11";

  programs.home-manager.enable = true;

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
}
