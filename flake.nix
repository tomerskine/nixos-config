{
  description = "Tom's NixOS configuration — nixos9310";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hyprland flake tracks the latest release and supports the Lua config format
    hyprland.url = "github:hyprwm/Hyprland";
    hyprland.inputs.nixpkgs.follows = "nixpkgs";

    # Hardware-specific modules: Dell XPS 13 9310 quirks (psmouse, fprintd TOD, fwupd, fstrim, Intel GPU)
    nixos-hardware.url = "github:NixOS/nixos-hardware";
  };

  outputs = { self, nixpkgs, home-manager, hyprland, nixos-hardware, ... } @ inputs:
  let
    system = "x86_64-linux";
    pkgs   = nixpkgs.legacyPackages.${system};
  in
  {
    # `nix fmt` uses nixfmt-rfc-style (the official Nix formatter)
    formatter.x86_64-linux = pkgs.nixfmt-rfc-style;

    nixosConfigurations.nixos9310 = nixpkgs.lib.nixosSystem {
      inherit system;
      specialArgs = { inherit inputs; };
      modules = [
        # Dell XPS 13 9310 hardware quirks (see docs/TROUBLESHOOTING.md for details)
        nixos-hardware.nixosModules.dell-xps-13-9310
        ./nixos/configuration.nix
        home-manager.nixosModules.home-manager
        {
          home-manager.useGlobalPkgs    = true;
          home-manager.useUserPackages  = true;
          home-manager.users.tom        = import ./home/home.nix;
          home-manager.extraSpecialArgs = { inherit inputs; };
        }
      ];
    };
  };
}
