# NixOS partition: /dev/nvme0n1p3 (btrfs, ~476 GiB)
# Replace NIXOS-BTRFS-UUID below with the output of:
#   blkid /dev/nvme0n1p3
# See docs/DUALBOOT.md for the full partitioning procedure.
{ config, lib, pkgs, modulesPath, ... }:

{
  imports = [ (modulesPath + "/installer/scan/not-detected.nix") ];

  # Hardware: Dell laptop, Intel i7-1165G7 Tiger Lake, Intel Iris Xe
  boot.initrd.availableKernelModules = [
    "xhci_pci" "thunderbolt" "nvme" "usb_storage" "sd_mod"
  ];
  boot.initrd.kernelModules = [ ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  # Btrfs subvolumes on /dev/nvme0n1p3 (no LVM — plain btrfs partition)
  fileSystems."/" = {
    device  = "/dev/disk/by-uuid/NIXOS-BTRFS-UUID";
    fsType  = "btrfs";
    options = [ "subvol=/@" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
  };

  fileSystems."/home" = {
    device  = "/dev/disk/by-uuid/NIXOS-BTRFS-UUID";
    fsType  = "btrfs";
    options = [ "subvol=/@home" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
  };

  # /nix gets noatime: the Nix store is read-heavy and atime updates add pointless I/O
  fileSystems."/nix" = {
    device  = "/dev/disk/by-uuid/NIXOS-BTRFS-UUID";
    fsType  = "btrfs";
    options = [ "subvol=/@nix" "compress=zstd:3" "ssd" "discard=async" "noatime" "space_cache=v2" ];
  };

  fileSystems."/var/log" = {
    device  = "/dev/disk/by-uuid/NIXOS-BTRFS-UUID";
    fsType  = "btrfs";
    options = [ "subvol=/@log" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
  };

  # Shared EFI partition — UUID unchanged from Arch install
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
