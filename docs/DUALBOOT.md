# Dual-Boot Setup — Arch + NixOS on nvme0n1

How to split the 1TB NVMe in half, shrink the existing Arch install to ~476 GiB,
and install NixOS on the freed space with systemd-boot dual-boot (NixOS as default).

---

## Status (2026-05-29)

| Phase | Status | Notes |
|---|---|---|
| Phase 1 — Partition work | **Complete** | Done from running Arch, not live USB |
| Phase 2 — Nix config updates | **Complete** | UUID committed to repo |
| Phase 3 — Mount + nixos-install | **Next step** | Boot NixOS live USB and run install |

### Actual disk layout as of 2026-05-29

```
nvme0n1 (953.9 GiB)
├── nvme0n1p1    1 GiB    vfat (EFI)   UUID:6948-9FC4          ← shared, unchanged
├── nvme0n1p2  476 GiB    LVM2 PV      ArchinstallVg           ← Arch
│   └── ArchinstallVg-root  460 GiB btrfs  @, @home, @log, @pkg
└── nvme0n1p3  476.9 GiB  btrfs        UUID:eb705586-089c-4730-b134-60130a55b353  ← NixOS
    └── subvolumes: @, @home, @nix, @log  (formatted, ready)
```

**What's done:**
- btrfs filesystem resized to 460 GiB (`btrfs filesystem resize --resizefs`)
- LV resized to 460 GiB (`lvresize -L 460G --resizefs`)
- PV resized (`pvresize --setphysicalvolumesize 461G`)
- Partition nvme0n1p2 shrunk to 476 GiB, nvme0n1p3 created at 476.9 GiB
- nvme0n1p3 formatted btrfs with label `nixos`, subvolumes @, @home, @nix, @log created
- `hardware-configuration.nix` updated with real UUID `eb705586-...`
- `boot.nix` updated with `systemd-boot.timeout = 5`

**Note:** The partition resize was done from the running Arch system (not the live USB as
originally planned). The btrfs online resize succeeded; `lvresize --resizefs` handled both
the LV and btrfs in one step. The system rebooted cleanly.

---

## Next Step — Run the Installer (Phase 3)

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

# Clone the config (UUID already set in hardware-configuration.nix — no manual edits needed)
git clone https://github.com/tomerskine/nixos-config /mnt/etc/nixos

# Install
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
