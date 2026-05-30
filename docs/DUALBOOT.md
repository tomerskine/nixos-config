# Dual-Boot Setup — Arch + NixOS on nvme0n1

How to split the 1TB NVMe in half, shrink the existing Arch install to ~476 GiB,
and install NixOS on the freed space with systemd-boot dual-boot (NixOS as default).

---

## Reading This Guide From the NixOS Installer

Open a terminal in the live environment, then use one of these two options:

**Option A — clone from GitHub** (needs WiFi first):
```bash
# Connect to WiFi
nmtui   # or: nmcli device wifi connect "SSID" password "PASSWORD"

# Clone the repo and read docs with less
git clone https://github.com/tomerskine/nixos-config ~/nixos-config
less ~/nixos-config/docs/DUALBOOT.md    # this file
less ~/nixos-config/docs/HOWTO-install.md
less ~/nixos-config/docs/BACKUP-RESTORE.md
```

**Option B — read from the Arch partition** (no network needed):
```bash
# Activate the Arch LVM and mount the home subvolume read-only
modprobe dm-mod
vgchange -ay ArchinstallVg
mkdir -p /mnt/arch-home
mount -o subvol=/@home,ro /dev/ArchinstallVg/root /mnt/arch-home

# Docs are at:
less /mnt/arch-home/tom/repos/nixos-config/docs/DUALBOOT.md
less /mnt/arch-home/tom/repos/nixos-config/docs/HOWTO-install.md
less /mnt/arch-home/tom/repos/nixos-config/docs/BACKUP-RESTORE.md

# When done reading, unmount before using /mnt for the NixOS install
umount /mnt/arch-home
```

> Option A is preferred — you need WiFi for `nixos-install` anyway (to fetch packages),
> so connecting first and cloning gives you the latest version of the docs. Use Option B
> if you want to read ahead before setting up networking.

---

## Status (2026-05-30)

| Phase | Status | Notes |
|---|---|---|
| Phase 1 — Partition work | **Complete** | Done from running Arch, not live USB |
| Phase 2 — Nix config updates | **Complete** | UUID committed to repo; config errors fixed |
| Phase 3 — Mount + nixos-install | **Retry needed** | First attempt failed (see below); config fixes pushed |

### Actual disk layout (verified 2026-05-30)

```
nvme0n1 (953.9 GiB)
├── nvme0n1p1    1 GiB    vfat (EFI)   UUID:6948-9FC4          ← shared, unchanged
├── nvme0n1p2  476 GiB    LVM2 PV      ArchinstallVg           ← Arch
│   └── ArchinstallVg-root  460 GiB btrfs  @, @home, @log, @pkg
└── nvme0n1p3  476.9 GiB  btrfs        UUID:eb705586-089c-4730-b134-60130a55b353  ← NixOS
    └── subvolumes: @, @home, @nix, @log
        @nix has ~4 GiB of partially downloaded Nix store (reusable)
```

**What's done:**
- btrfs filesystem resized to 460 GiB (`lvresize -L 460G --resizefs`)
- PV resized (`pvresize --setphysicalvolumesize 461G`)
- Partition nvme0n1p2 shrunk to 476 GiB, nvme0n1p3 created at 476.9 GiB
- nvme0n1p3 formatted btrfs with label `nixos`, subvolumes @, @home, @nix, @log created
- `hardware-configuration.nix` updated with real UUID `eb705586-...`
- `boot.nix` updated with `systemd-boot.timeout = 5`
- First nixos-install attempt — failed with drive-addressing errors (block/segment errors)
- Fixed config errors from first attempt: wrong package names (rofi, dolphin, qt6ct,
  networkmanagerapplet), removed xwaylandvideobridge, stripped inline logiops config,
  removed unavailable fprintd-tod driver, removed libva-intel-driver/vaapiIntel

---

## Next Step — Retry the Installer (Phase 3)

The NixOS partition already has a partial Nix store from the first attempt (~4 GiB in
`@nix`). `nixos-install` will reuse cached store paths — no need to wipe first.

Boot the NixOS live USB (`sda` — nixos-graphical-25.11-x86_64), then run as root:

```bash
# Mount NixOS subvolumes
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

# The config was already cloned during the first attempt — pull latest instead of re-cloning:
# If /mnt/etc/nixos already exists:
git -C /mnt/etc/nixos pull

# If /mnt/etc/nixos is missing or broken:
# rm -rf /mnt/etc/nixos
# git clone https://github.com/tomerskine/nixos-config /mnt/etc/nixos

# Install (config fixes are in — no manual edits needed)
nixos-install --flake /mnt/etc/nixos#nixos9310
# You will be prompted to set the root password.

# Remove the USB and reboot
```

systemd-boot is written to `/mnt/boot/EFI/systemd/`. It preserves Arch's existing
`/boot/loader/entries/arch-linux.conf` and adds NixOS generation entries alongside it.

---

## After First Boot

1. Log in as `root` (user `tom` has no password yet), then:
   ```bash
   passwd tom
   ```
2. Log in as `tom`, select Hyprland from GDM session menu
3. Follow `docs/HOWTO-install.md` → Step 8 for the full post-install checklist
   (restore wallpaper, age key, chezmoi, SSH keys, tool installs, etc.)
4. Follow `docs/BACKUP-RESTORE.md` for the SD card restore steps

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

After first NixOS boot:

```bash
# Verify disk layout
lsblk
# nvme0n1p1 (EFI), nvme0n1p2 (Arch LVM), nvme0n1p3 (NixOS btrfs) all present

# Check mount layout
df -h
# /, /home, /nix, /var/log all mounted from nvme0n1p3 (eb705586-...)

# Verify Hyprland starts and Waybar appears
# See TROUBLESHOOTING.md if blank screen or missing waybar

# Reboot, select Arch from the 5-second menu
# From Arch: verify btrfs is still intact
btrfs filesystem show /
# Should show: devid 1 size 460.00GiB, no errors
```

---

## Original Approach Notes

The original plan called for doing all partition work from the NixOS live USB.
In practice, it was done from the running Arch system:

- The `usb_storage` kernel module was missing (kernel updated but not rebooted), so the
  live USB couldn't be used for the initial attempt
- After rebooting into the updated kernel, the partition work was done from Arch instead
- `lvresize --resizefs` proved simpler than the two-step btrfs-resize + lvresize sequence
- The running system handled the online resize without issues

The live USB is still required for `nixos-install` itself (you cannot install NixOS onto
a mounted root partition from within that same system).

---

## Risks and Mitigations

| Risk | Mitigation |
|---|---|
| Arch data loss during resize | Full backup taken to SD card (see BACKUP-RESTORE.md) before any partition work |
| Btrfs FS inconsistency | Used `--resizefs` flag; system rebooted cleanly post-resize confirming integrity |
| Partition table corruption | Verified with `lsblk` after partprobe; all partitions visible and correct |
| EFI partition conflicts | systemd-boot handles multiple OS entries cleanly on a shared EFI partition |
| NixOS install overwrites Arch boot entry | systemd-boot preserves existing `.conf` files in `/boot/loader/entries/` |
