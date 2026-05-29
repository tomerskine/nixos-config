# Generated from current Arch Linux disk layout.
# After running `nixos-generate-config --root /mnt` during install, compare
# the generated file with this one and reconcile any UUID/path differences.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Hardware: Dell laptop, Intel i7-1165G7 Tiger Lake, Intel Iris Xe
  boot.initrd.availableKernelModules = [
    "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ "dm-mod" ];   # LVM device mapper
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # LVM support in initrd
  boot.initrd.services.lvm.enable = true;

  # Btrfs subvolumes on LVM (matches current /etc/fstab exactly)
  fileSystems."/" = {
    device  = "/dev/ArchinstallVg/root";
    fsType  = "btrfs";
    options = [ "subvol=/@" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device  = "/dev/ArchinstallVg/root";
    fsType  = "btrfs";
    options = [ "subvol=/@home" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/var/log" = {
    device  = "/dev/ArchinstallVg/root";
    fsType  = "btrfs";
    options = [ "subvol=/@log" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
  };

  # EFI boot partition — UUID matches current /dev/nvme0n1p1
  fileSystems."/boot" = {
    device  = "/dev/disk/by-uuid/6948-9FC4";
    fsType  = "vfat";
    options = [ "fmask=0022" "dmask=0022" ];
  };

  swapDevices = [ ];

  # Intel Tiger Lake microcode updates
  hardware.cpu.intel.updateMicrocode =
    lib.mkDefault config.hardware.enableRedistributableFirmware;

  # Intel Iris Xe (Tiger Lake) graphics
  hardware.graphics = {
    enable = true;
    extraPackages = with pkgs; [
      intel-media-driver    # iHD VAAPI driver (Tiger Lake+)
      libva-intel-driver    # legacy i965 VAAPI driver
      intel-compute-runtime # OpenCL
      vaapiIntel
    ];
  };

  # Firmware for Intel AX201 WiFi + Bluetooth
  hardware.enableRedistributableFirmware = true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
