# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, inputs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
      inputs.direnv-instant.nixosModules.direnv-instant
    ];

  programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
  };
  programs.direnv-instant.enable = true;

  # The NixOS module's wrapped output only ships bin/, so expose the
  # nushell hook (shipped in share/ of the unwrapped package) at a
  # stable path for the nushell config to source.
  environment.etc."direnv-instant/nushell.nu".source =
    "${config.programs.direnv-instant.package}/share/direnv-instant/nushell.nu";

  # Replace interactive bash with nushell, keeping bash as the POSIX login shell.
  programs.bash.interactiveShellInit = ''
    if [[ $(${pkgs.procps}/bin/ps --no-header --pid=$PPID --format=comm) != "nu" && -z ''${BASH_EXECUTION_STRING} ]]
    then
      shopt -q login_shell && LOGIN_OPTION='--login' || LOGIN_OPTION=""
      exec ${pkgs.nushell}/bin/nu $LOGIN_OPTION
    fi
  '';

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Use latest kernel.
  boot.kernelPackages = pkgs.linuxPackages_latest;

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  nix.settings.experimental-features = [
    "nix-command"
    "flakes"
  ];

  # Silence "Git tree is dirty"
  nix.settings.warn-dirty = false;

  # Set your time zone.
  time.timeZone = "Europe/London";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_GB.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "en_GB.UTF-8";
    LC_IDENTIFICATION = "en_GB.UTF-8";
    LC_MEASUREMENT = "en_GB.UTF-8";
    LC_MONETARY = "en_GB.UTF-8";
    LC_NAME = "en_GB.UTF-8";
    LC_NUMERIC = "en_GB.UTF-8";
    LC_PAPER = "en_GB.UTF-8";
    LC_TELEPHONE = "en_GB.UTF-8";
    LC_TIME = "en_GB.UTF-8";
  };

  # Keyboard layout (also used by the console via console.useXkbConfig).
  services.xserver.xkb = {
    layout = "us";
    variant = "";
    options = "ctrl:nocaps";
  };
  console.useXkbConfig = true;

  # Caps Lock: hold = Ctrl, tap = Esc (keyd intercepts below xkb, so this
  # supersedes ctrl:nocaps when running; xkb remains a fallback.)
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings.main.capslock = "overload(control, esc)";
    };
  };

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # UPower exposes battery/AC state over D-Bus.
  services.upower.enable = true;

  # Enable sound with pipewire.
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.robert = {
    isNormalUser = true;
    description = "robert";
    extraGroups = [ "networkmanager" "wheel" ];
    packages = with pkgs; [
      restic
      git
      gh
      lazygit
      fzf
      ripgrep
      delta
      gnupg
      yq
      go
      deno
      pnpm
      nodejs_24
      python314
      uv
      docker
      jetbrains-mono
      cmake
      gcc
      gnumake
      cargo
      unzip
      sublime-merge
      signal-desktop
      obsidian
      poppler-utils
      spotify
    ];
  };

  # Run unpatched dynamically-linked binaries (e.g. prebuilt node_modules tools like dprint).
  programs.nix-ld.enable = true;

  # Install firefox.
  programs.firefox.enable = true;

  environment.sessionVariables.TERMINAL = "kitty";
  nixpkgs.config.allowUnfree = true;

  # Hyprland desktop (default). UWSM gives us proper graphical-session.target
  # activation, which the noctalia user service below depends on.
  programs.hyprland.enable = true;
  programs.uwsm.enable = true;

  services.gnome.gnome-keyring.enable = true;

  programs.ssh.askPassword = "${pkgs.lxqt.lxqt-openssh-askpass}/bin/lxqt-openssh-askpass";
  programs.ssh.enableAskPassword = true;

  # greetd launches the UWSM Hyprland session straight from the TTY —
  # works more reliably with Wayland than lightdm.
  services.greetd = {
    enable = true;
    settings.default_session = {
      command = "${pkgs.tuigreet}/bin/tuigreet --time --remember --cmd 'uwsm start hyprland-uwsm.desktop'";
      user = "greeter";
    };
  };

  security.pam.services.greetd.enableGnomeKeyring = true;

  # Run noctalia-shell as a supervised user service so a crash doesn't
  # leave the session without a bar/launcher/lock screen.
  systemd.user.services.noctalia-shell = {
    description = "Noctalia desktop shell";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    wantedBy = [ "graphical-session.target" ];
    path = with pkgs; [
      bash coreutils
      # screen-toolkit dependencies:
      hyprpicker slurp grim wl-clipboard
      tesseract imagemagick zbar curl
      translate-shell wl-screenrec ffmpeg gifski jq
      python3 python3Packages.pygobject3
    ];
    serviceConfig = {
      ExecStart = "${pkgs.noctalia-shell}/bin/noctalia-shell";
      Restart = "always";
      RestartSec = "1";
    };
  };

  systemd.user.services.vicinae = {
    description = "Vicinae launcher daemon";
    partOf = [ "graphical-session.target" ];
    after = [ "graphical-session.target" ];
    requires = [ "dbus.socket" ];
    wantedBy = [ "graphical-session.target" ];
    path = with pkgs; [ noctalia-shell ];
    serviceConfig = {
      ExecStart = "${pkgs.vicinae}/bin/vicinae server --replace";
      ExecReload = "${pkgs.coreutils}/bin/kill -HUP $MAINPID";
      Restart = "always";
      RestartSec = "60";
      KillMode = "process";
    };
  };

  # Native Wayland for Electron/Chromium apps.
  environment.sessionVariables.NIXOS_OZONE_WL = "1";

  fonts.packages = [
    (pkgs.stdenvNoCC.mkDerivation {
      pname = "berkeley-mono";
      version = "1.0";
      src = inputs.berkeley-mono;
      dontUnpack = true;
      installPhase = ''
        mkdir -p $out/share/fonts/opentype
        cp $src/*.otf $out/share/fonts/opentype/
      '';
    })
  ];

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    kitty
    nushell
    neovim
    claude-code
    # Hyprland desktop bits:
    noctalia-shell
    vicinae
    wl-clipboard
    fuzzel
    libnotify
    grim
    slurp
    brightnessctl
    kdePackages.breeze-icons
    kdePackages.dolphin
    adw-gtk3
    # Noctalia screen-toolkit plugin deps:
    hyprpicker
    tesseract
    imagemagick
    zbar
    curl
    translate-shell
    wl-screenrec
    ffmpeg
    gifski
    jq
    python3
    python3Packages.pygobject3
    xdg-desktop-portal
  ];

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "25.11"; # Did you read the comment?

  # Tag the default (Hyprland) boot entry so it's distinguishable in systemd-boot.
  system.nixos.tags = [ "hyprland" ];

  # I tried out xfce first, so just gonna keep this around for a little while.
  specialisation.xfce.configuration = {
    system.nixos.tags = lib.mkForce [ "xfce" ];

    # Take Hyprland/greetd/noctalia out of this profile.
    programs.hyprland.enable = lib.mkForce false;
    programs.uwsm.enable = lib.mkForce false;
    services.greetd.enable = lib.mkForce false;
    systemd.user.services.noctalia-shell.enable = lib.mkForce false;

    # Electron/Chromium apps shouldn't try Wayland under X11.
    environment.sessionVariables.NIXOS_OZONE_WL = lib.mkForce "";

    # Enable XFCE + lightdm + X11.
    services.xserver.enable = true;
    services.xserver.displayManager.lightdm.enable = true;
    services.xserver.desktopManager.xfce.enable = true;

    # XFCE picks the preferred terminal from helpers.rc, not $TERMINAL.
    environment.etc."xdg/xfce4/helpers.rc".text = "TerminalEmulator=kitty\n";
  };
}
