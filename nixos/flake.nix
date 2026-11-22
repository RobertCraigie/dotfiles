{
  description = "NixOS configuration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    # packages held at the June nixpkgs (see the overlay in configuration.nix)
    nixpkgs-held.url = "github:NixOS/nixpkgs/567a49d1913ce81ac6e9582e3553dd90a955875f";

    direnv-instant.url = "github:Mic92/direnv-instant";
    direnv-instant.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };

    # not in dotfiles as its licensed
    berkeley-mono = {
      url = "path:/home/robert/.fonts/berkeley-mono";
      flake = false;
    };
    # The desktop apps (sift, todo, ...) are built on the system's nixpkgs, not
    # the box's nixos-26.05: GL apps load the system mesa from
    # /run/opengl-driver, and a mesa built on a newer glibc than the app's
    # won't load ("Could not create default EGL display", a grey window).
    server = {
      url = "git+file:///home/robert/code/server";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs@{ self, nixpkgs, ... }: {
    nixosConfigurations.nixos = nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = { inherit inputs; };
      modules = [
        ./configuration.nix
        inputs.home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs = true;
          home-manager.useUserPackages = true;
          home-manager.backupFileExtension = "hm-backup";
          home-manager.extraSpecialArgs = { inherit inputs; };
          home-manager.users.robert = import ./home.nix;
        }
      ];
    };
  };
}
