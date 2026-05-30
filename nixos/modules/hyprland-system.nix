{ pkgs, inputs, ... }:

{
  # Hyprland from the official flake (required for Lua config support)
  programs.hyprland = {
    enable        = true;
    package       = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
    xwayland.enable = true;
  };

  # uinput group for Hyprland input control
  users.groups.uinput = { };
  services.udev.extraRules = ''
    KERNEL=="uinput", GROUP="uinput", MODE="0660"
  '';

  environment.systemPackages = with pkgs; [
    # Wayland utilities
    wl-clipboard
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
    rofi
    wofi
    fuzzel

    # File managers
    nemo
    nautilus
    kdePackages.dolphin
    udiskie

    # System tray applets
    networkmanagerapplet
    blueman

    # Qt Wayland integration + theming
    libsForQt5.qt5ct
    qt6Packages.qt6ct
    nwg-look

    # Brightness control (laptop + external)
    brightnessctl

    # Media key support
    playerctl
  ];
}
