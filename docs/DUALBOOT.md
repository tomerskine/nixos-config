# Dual-Boot Setup — Arch + NixOS on nvme0n1

How to split the 1TB NVMe in half, shrink the existing Arch install to ~476 GiB,
and install NixOS on the freed space with systemd-boot dual-boot (NixOS as default).

---

## Current Disk Layout

```
nvme0n1 (953.9 GiB)
├── nvme0n1p1    1 GiB   vfat (EFI)   UUID:6948-9FC4    ← systemd-boot lives here
└── nvme0n1p2  ~952 GiB  LVM2 PV      ArchinstallVg
    └── ArchinstallVg/root  btrfs     @, @home, @log, @pkg
```

Only ~18 GiB of the 952 GiB is actually used — plenty of room to shrink.

---

## Target Disk Layout

```
nvme0n1 (953.9 GiB)
├── nvme0n1p1    1 GiB   vfat (EFI)   UUID:6948-9FC4     ← shared, unchanged
├── nvme0n1p2  ~476 GiB  LVM2 PV      ArchinstallVg      ← Arch, shrunk from 952 GiB
│   └── ArchinstallVg/root  btrfs     @, @home, @log, @pkg
└── nvme0n1p3  ~476 GiB  btrfs                           ← NixOS, new
    └── subvolumes: @, @home, @nix, @log
```

NixOS uses a plain btrfs partition (no LVM). The `/nix` subvolume gets `noatime`
because the Nix store sees very high read traffic and `atime` updates are wasted I/O.

---

## Answering the Approach Questions

### Can this be done via Nix configs?

**Partially.** The NixOS side is fully declarative:
- `hardware-configuration.nix` references the new partition by UUID and declares all subvolume mounts
- `boot.nix` sets the systemd-boot timeout so the boot menu appears

The Arch shrink cannot be declarative — resizing an existing partition requires offline tools
regardless of approach.

### Can this be done via a custom install image?

Yes, but it adds unnecessary complexity. A disko config baked into a custom ISO would
auto-partition the NixOS half, but you still need to shrink Arch first. The stock NixOS
live USB with manual steps is simpler and just as reliable.

### Can this be done from the running Arch install?

**Not safely.** Btrfs technically supports online resize, but shrinking a live root
filesystem is dangerous. The safe approach is a NixOS live USB: one session handles
both the Arch resize and the NixOS install offline.

**Recommended: use a NixOS live USB for the entire operation.**

---

## Phase 1 — Partition Work (NixOS live USB)

Boot the NixOS minimal or graphical ISO. All commands run as root in the live terminal.

```bash
# Activate the existing Arch LVM
modprobe dm-mod
vgchange -ay ArchinstallVg

# Verify Arch filesystem integrity and used space before touching anything
mkdir -p /mnt/arch
mount -o subvol=/@,ro /dev/ArchinstallVg/root /mnt/arch
df -h /mnt/arch           # should show ~18 GiB used
btrfs filesystem show /mnt/arch
umount /mnt/arch

# --- Shrink order: always FS → LV → PV → partition ---

# Shrink the btrfs filesystem to 460 GiB
mount -o subvol=/@ /dev/ArchinstallVg/root /mnt/arch
btrfs filesystem resize 460G /mnt/arch
umount /mnt/arch

# Shrink the LVM logical volume to match
lvresize -L 460G /dev/ArchinstallVg/root

# Shrink the LVM physical volume (slight padding for LVM metadata)
pvresize --setphysicalvolumesize 461G /dev/nvme0n1p2

# Shrink the partition and create the NixOS partition
parted /dev/nvme0n1
  (parted) unit GiB
  (parted) print                           # note current end of nvme0n1p2
  (parted) resizepart 2 477GiB            # shrink Arch partition to 477 GiB
  (parted) mkpart primary btrfs 477GiB 100%  # create NixOS partition
  (parted) print                           # verify nvme0n1p3 was created
  (parted) quit

# Verify Arch btrfs is still intact after resize
mount -o subvol=/@,ro /dev/ArchinstallVg/root /mnt/arch
btrfs check --readonly /dev/ArchinstallVg/root
umount /mnt/arch

# Format the new NixOS partition
mkfs.btrfs -L nixos /dev/nvme0n1p3

# Create subvolumes
mount /dev/nvme0n1p3 /mnt/nixos-btrfs
btrfs subvolume create /mnt/nixos-btrfs/@
btrfs subvolume create /mnt/nixos-btrfs/@home
btrfs subvolume create /mnt/nixos-btrfs/@nix
btrfs subvolume create /mnt/nixos-btrfs/@log
umount /mnt/nixos-btrfs

# Record the UUID — you will need it in hardware-configuration.nix
blkid /dev/nvme0n1p3
# → UUID="xxxxxxxx-xxxx-xxxx-xxxx-xxxxxxxxxxxx"
```

---

## Phase 2 — Update the Nix Config

Two files need updating before `nixos-install`. Do this while still in the live environment
after cloning/copying the config repo.

### `nixos/hardware-configuration.nix`

Replace the LVM-based device paths with the new btrfs partition. Key changes:
- Remove `boot.initrd.kernelModules = [ "dm-mod" ]` — no LVM on the NixOS partition
- Remove `boot.initrd.services.lvm.enable = true`
- Replace every `device = "/dev/ArchinstallVg/root"` with `device = "/dev/disk/by-uuid/<uuid>"`
  where `<uuid>` is the UUID from `blkid /dev/nvme0n1p3`
- Add a `fileSystems."/nix"` entry mounting `subvol=/@nix` with `noatime`
- Leave `/boot` EFI mount unchanged (UUID `6948-9FC4`)
- Leave Intel GPU/CPU/firmware hardware config unchanged

Example filesystem entries:
```nix
fileSystems."/" = {
  device = "/dev/disk/by-uuid/<nvme0n1p3-uuid>";
  fsType = "btrfs";
  options = [ "subvol=/@" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
};

fileSystems."/home" = {
  device = "/dev/disk/by-uuid/<nvme0n1p3-uuid>";
  fsType = "btrfs";
  options = [ "subvol=/@home" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
};

fileSystems."/nix" = {
  device = "/dev/disk/by-uuid/<nvme0n1p3-uuid>";
  fsType = "btrfs";
  options = [ "subvol=/@nix" "compress=zstd:3" "ssd" "discard=async" "noatime" "space_cache=v2" ];
};

fileSystems."/var/log" = {
  device = "/dev/disk/by-uuid/<nvme0n1p3-uuid>";
  fsType = "btrfs";
  options = [ "subvol=/@log" "compress=zstd:3" "ssd" "discard=async" "space_cache=v2" ];
};

fileSystems."/boot" = {
  device = "/dev/disk/by-uuid/6948-9FC4";  # unchanged
  fsType = "vfat";
};
```

### `nixos/modules/boot.nix`

Add the boot menu timeout so you can select Arch on reboot:
```nix
boot.loader.systemd-boot.timeout = 5;
```

systemd-boot auto-discovers Arch's existing `/boot/loader/entries/arch-linux.conf`.
NixOS sets itself as the default entry via `nixos-install` / `nixos-rebuild switch`.
`canTouchEfiVariables = true` is kept so NixOS can write its default entry to EFI NVRAM.

---

## Phase 3 — Install NixOS

Continuing in the live environment after Phase 1 and 2:

```bash
# Mount NixOS subvolumes under /mnt
mount -o subvol=/@,compress=zstd:3,ssd,discard=async,space_cache=v2 \
    /dev/nvme0n1p3 /mnt

mkdir -p /mnt/{boot,home,nix,var/log}
mount -o subvol=/@home,compress=zstd:3,ssd,discard=async,space_cache=v2 \
    /dev/nvme0n1p3 /mnt/home
mount -o subvol=/@nix,compress=zstd:3,ssd,discard=async,noatime,space_cache=v2 \
    /dev/nvme0n1p3 /mnt/nix
mount -o subvol=/@log,compress=zstd:3,ssd,discard=async,space_cache=v2 \
    /dev/nvme0n1p3 /mnt/var/log
mount /dev/nvme0n1p1 /mnt/boot

# Get the config (clone from remote or copy from the running Arch system)
git clone <repo-url> /mnt/etc/nixos
# OR copy from Arch if network is unavailable:
# cp -r /run/media/.../nixos-config/* /mnt/etc/nixos/

# Substitute the real nvme0n1p3 UUID into hardware-configuration.nix
nano /mnt/etc/nixos/nixos/hardware-configuration.nix

# Install
nixos-install --flake /mnt/etc/nixos#nixos9310
# You will be prompted to set the root password.

# After install completes, remove the USB and reboot
```

systemd-boot is written to `/mnt/boot/EFI/systemd/`. It preserves Arch's existing
`/boot/loader/entries/arch-linux.conf` and adds NixOS generation entries alongside it.

---

## After First Boot

See `docs/HOWTO-install.md` → Step 7 and Step 8 for the full post-install checklist
(set `tom` user password, restore wallpaper, apply chezmoi, authenticate tools, etc.).

---

## Dual Boot Behavior

| Scenario | Behavior |
|---|---|
| Normal boot | systemd-boot menu appears for 5 seconds |
| Default selection | NixOS latest generation |
| Arch entry | Auto-discovered; appears as "Arch Linux" |
| NixOS rollback | Previous NixOS generations listed in the boot menu |
| Change default | Edit `/boot/loader/loader.conf` or set `boot.loader.systemd-boot.defaultLoader` in `boot.nix` |

---

## Verification Checklist

After install, confirm everything is working:

```bash
# From NixOS — verify disk layout
lsblk
# nvme0n1p1 (EFI), nvme0n1p2 (Arch LVM), nvme0n1p3 (NixOS btrfs) all present

# Check NixOS mount layout
df -h
# /, /home, /nix, /var/log all mounted from nvme0n1p3

# Verify Hyprland session starts (see TROUBLESHOOTING.md if blank screen)
# Verify Waybar appears

# Reboot and select Arch from the boot menu
# From Arch: verify btrfs is intact
btrfs filesystem show /dev/ArchinstallVg/root
# No errors; used space should be the same as before
```

---

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Arch data loss during resize | Only 18 GiB used of 829 GiB free; **back up `/home` first regardless** |
| Btrfs FS inconsistency after resize | Shrink FS → LV → PV → partition in that order; run `btrfs check --readonly` after |
| Partition table corruption | Verify with `parted /dev/nvme0n1 print` before and after each step |
| EFI partition conflicts | systemd-boot handles multiple OS entries cleanly on a shared EFI partition |
| NixOS install overwrites Arch boot entry | systemd-boot preserves existing `.conf` files in `/boot/loader/entries/` |
| Forgetting to update hardware-configuration.nix UUID | `nixos-install` will fail to find the root partition — double-check before running |
