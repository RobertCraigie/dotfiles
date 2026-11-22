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

  # Without a cursor theme Hyprland falls back to a fixed 32px bitmap that
  # changes size with the highest monitor scale (e.g. when the laptop panel
  # is disabled with the lid closed).
  home.pointerCursor = {
    enable = true;
    name = "Adwaita";
    package = pkgs.adwaita-icon-theme;
    size = 24;
    gtk.enable = true;
  };

  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = "prefer-dark";
    gtk-theme = "adw-gtk3-dark";
  };

  programs.glide-browser.enable = true;
  # GTK <= 3.24.52 keeps a removed monitor's zxdg_output_v1 alive with a
  # dangling pointer to it, so Glide segfaults in xdg_output_handle_name once
  # Hyprland updates outputs after eDP-1 is disabled (hypr/hyprland.lua).
  # Fixed on gtk-3-24 (MR !10014) but unreleased; patched for Glide only to
  # avoid rebuilding everything that depends on gtk3. wrapGAppsHook3 needs it
  # too: it propagates its own gtk3, which autoPatchelf would otherwise pick.
  programs.glide-browser.package =
    let
      gtk3 = pkgs.gtk3.overrideAttrs (old: {
        patches = (old.patches or [ ]) ++ lib.optionals (lib.versionOlder old.version "3.24.53") [
          (pkgs.fetchpatch {
            url = "https://gitlab.gnome.org/GNOME/gtk/-/commit/692439ec8d41008f9d9726359013f44d8473ad7b.patch";
            hash = "sha256-cdEFKDeSkdU16jPXWpfaOvNgxqgbBpFUFM7WN8MW9Mw=";
          })
        ];
      });
    in
    pkgs.wrapFirefox
      (pkgs.callPackage "${inputs.glide}/package.nix" {
        policies = config.programs.glide-browser.policies;
        ffmpeg_9 = pkgs.ffmpeg_9 or pkgs.ffmpeg_7;
        inherit gtk3;
        wrapGAppsHook3 = pkgs.wrapGAppsHook3.override { inherit gtk3; };
      })
      { pname = "glide-browser-bin"; };

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
      "x-scheme-handler/sift" = "sift.desktop";
    };
  };
}
