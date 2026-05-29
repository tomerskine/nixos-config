{ pkgs, inputs, ... }:

{
  # X server / keyboard layout (also used by Wayland compositors)
  services.xserver = {
    enable          = true;
    xkb.layout      = "us";
    xkb.model       = "pc105+inet";
    xkb.options     = "terminate:ctrl_alt_bksp";
  };

  # GDM display manager with Wayland support
  services.displayManager.gdm = {
    enable  = true;
  };

  # GNOME desktop environment
  services.desktopManager.gnome.enable = true;

  # Hyprland from the official flake (required for Lua config support)
  programs.hyprland = {
    enable        = true;
    package       = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # XDG portals
  xdg.portal = {
    enable      = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };

  # Power management
  services.power-profiles-daemon.enable = true;

  # Firmware updates via `fwupdmgr` (BIOS, NVMe, WiFi firmware, etc.)
  # (Also set by nixos-hardware.nixosModules.dell-xps-13-9310.)
  services.fwupd.enable = true;

  # PolicyKit (required by hyprpolkitagent and GNOME)
  security.polkit.enable = true;

  # uinput group for Hyprland input control
  users.groups.uinput = { };
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard
    xwaylandvideobridge
    grim
    slurp
    cliphist
    swaybg

    # Hyprland ecosystem
    hyprpaper
    hypridle
    hyprlock
    hyprpolkitagent

    # Status bar and notifications
    waybar
    dunst
    mako

    # Launchers
    rofi-wayland
    wofi
    fuzzel

    # File managers
    nemo
    nautilus
    dolphin
    udiskie

    # System tray applets
    network-manager-applet
    blueman

    # Qt Wayland integration + theming
    libsForQt5.qt5ct
    qt6ct
    nwg-look

    # Brightness control (laptop + external)
    brightnessctl

    # Media key support
    playerctl
  ];
}
