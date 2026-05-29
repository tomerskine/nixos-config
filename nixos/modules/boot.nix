{ pkgs, ... }:

{
  # systemd-boot — matches current Arch setup (Dell UEFI, no Secure Boot)
  boot.loader.systemd-boot.enable      = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Latest kernel (matches Arch linux-latest)
  boot.kernelPackages = pkgs.linuxPackages_latest;

  # zswap disabled (matches current `zswap.enabled=0` kernel param)
  # i915.enable_psr=0 — disables Panel Self-Refresh on Intel Iris Xe; without this
  #   the display can freeze or flicker, particularly on Tiger Lake (XPS 9310).
  boot.kernelParams = [
    "zswap.enabled=0"
    "i915.enable_psr=0"
  ];

  # Modern systemd-based initrd (replaces mkinitcpio)
  boot.initrd.systemd.enable = true;

  # psmouse blacklisted: XPS 9310 touchpad routes over i2c, not PS/2.
  # Without this: dmesg errors on boot and hangs on shutdown.
  # (Also set by nixos-hardware.nixosModules.dell-xps-13-9310 — kept here for clarity.)
  boot.blacklistedKernelModules = [ "psmouse" ];
}
