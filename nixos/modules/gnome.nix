{ pkgs, ... }:

{
  # X server / keyboard layout (used by GDM and Wayland compositors)
  services.xserver = {
    enable      = true;
    xkb.layout  = "us";
    xkb.model   = "pc105+inet";
    xkb.options = "terminate:ctrl_alt_bksp";
  };

  # GDM display manager with Wayland support
  services.displayManager.gdm.enable = true;

  # GNOME desktop environment
  services.desktopManager.gnome.enable = true;

  # PolicyKit (required by GNOME and hyprpolkitagent)
  security.polkit.enable = true;

  # Power management
  services.power-profiles-daemon.enable = true;

  # Firmware updates via `fwupdmgr` (BIOS, NVMe, WiFi firmware, etc.)
  # (Also set by nixos-hardware.nixosModules.dell-xps-13-9310.)
  services.fwupd.enable = true;

  # GTK XDG portal (GNOME/GTK app integration; Hyprland portal added in hyprland-system.nix)
  xdg.portal = {
    enable       = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
  };
}
