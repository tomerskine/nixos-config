{ pkgs, ... }:

{
  imports = [
    ./hardware-configuration.nix
    ./modules/boot.nix
    ./modules/networking.nix
    ./modules/gnome.nix
    ./modules/hyprland-system.nix
    ./modules/audio.nix
    ./modules/bluetooth.nix
    ./modules/security.nix
    ./modules/input.nix
    ./modules/users.nix
  ];

  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];

      # Deduplicate identical files in the Nix store (saves significant disk space)
      auto-optimise-store = true;

      # Binary caches — avoids compiling Hyprland and devenv packages from source.
      # Without this, the first nixos-rebuild takes ~20-40 minutes on this hardware.
      substituters = [
        "https://cache.nixos.org"
        "https://hyprland.cachix.org"
        "https://devenv.cachix.org"
      ];
      trusted-public-keys = [
        "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
        "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        "devenv.cachix.org-1:w1cLUi8dv3hnoSPGAuibQv+f9TZLr6cv/Hm9XgU50cw="
      ];
    };

    # Automatic weekly garbage collection — removes generations older than 30 days.
    # Without this, old system generations accumulate and the /nix/store grows unbounded.
    gc = {
      automatic = true;
      dates     = "weekly";
      options   = "--delete-older-than 30d";
    };
  };

  # Allow unfree packages (1Password, Spotify, VS Code, Obsidian, Steam, etc.)
  nixpkgs.config.allowUnfree = true;

  # Locale and timezone
  time.timeZone       = "America/Chicago";
  i18n.defaultLocale  = "en_US.UTF-8";
  i18n.extraLocaleSettings.LC_ALL = "en_US.UTF-8";

  # Console keymap (matches /etc/vconsole.conf)
  console = {
    keyMap  = "us";
    font    = "default8x16";
  };

  # Zram swap (replaces zram-generator; 25% of 15GB ≈ 3.75GB)
  zramSwap = {
    enable        = true;
    memoryPercent = 25;
  };

  # nix-ld: run unpatched binaries that expect a standard FHS /lib layout.
  # Required for: downloaded VS Code extensions with bundled binaries, some npm
  # packages that ship native addons, Python packages with C extensions installed
  # outside nixpkgs, and other pre-compiled dev tools.
  programs.nix-ld.enable = true;

  # Steam (needs system-level config for 32-bit libs + udev rules)
  programs.steam.enable = true;

  # Podman with Docker CLI compatibility
  virtualisation.podman = {
    enable       = true;
    dockerCompat = true;
    defaultNetwork.settings.dns_enabled = true;
  };

  # Base system CLI tools
  environment.systemPackages = with pkgs; [
    wget
    curl
    git
    vim
    nano
    less
    jq
    lsof
    smartmontools
    btrfs-progs
    lvm2
    efibootmgr
    pciutils
    usbutils
  ];

  # This value determines the NixOS release to track for stateful data.
  # Do not change this after the initial install.
  system.stateVersion = "25.05";
}
