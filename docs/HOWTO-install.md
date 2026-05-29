# NixOS Installation Guide — nixos9310

Step-by-step guide for installing NixOS on the Dell laptop (Intel i7-1165G7)
using this flake configuration.

---

## Pre-Install Checklist

Before booting the installer, complete these steps on your running Arch system:

- [ ] **Back up `/home/tom`** to an external drive or remote storage
- [ ] **Note your WiFi SSID and password** — NetworkManager connections live in
  `/etc/NetworkManager/system-connections/` and are not migrated; you re-enter them on first boot
- [ ] **Export your 1Password Emergency Kit** (PDF) — needed to re-authenticate on the new system
- [ ] **Note your Tailscale auth key** or have access to tailscale.com/admin
- [ ] **Back up your age key** (`~/.age/key.txt`) somewhere safe — required to decrypt chezmoi
  dotfiles; without it you cannot run `chezmoi apply`
- [ ] **Back up SSH keys** (`~/.ssh/`) — or confirm they are in your chezmoi repo / 1Password
- [ ] **Copy your wallpaper** (`~/Documents/wallpaper/wallpaper_dark.jpg`) — hyprpaper and
  hyprlock reference this path; Hyprland will show a black screen without it
- [ ] **Push any uncommitted git work** in `~/repos/`
- [ ] **Record your pipx-managed tools** — run `pipx list` and note the output; all pipx tools
  need reinstalling after migration
- [ ] **Note your npm global installs** (`npm list -g --depth=0`) — `claude-code` and any other
  global npm tools need reinstalling
- [ ] **Note your uv-managed Python tools** (`uv tool list`) — reinstall with `uv tool install`
- [ ] **Set your current password** somewhere accessible — you will need to know it to
  set `passwd tom` on the new system (or choose a new one)

---

## Step 1 — Download the NixOS Installer

Download the minimal or graphical ISO from https://nixos.org/download:

```bash
# Download latest NixOS unstable ISO (graphical installer recommended)
# Verify the SHA256 from the NixOS website
```

Write to USB (replace `/dev/sdX` with your USB device):

```bash
sudo dd if=nixos-*.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

---

## Step 2 — Boot the Installer

1. Plug in the USB drive
2. Power on the Dell and press **F12** to open the boot menu
3. Select the USB drive (UEFI mode)
4. **Check BIOS settings** if the USB doesn't appear:
   - BIOS → Security → Secure Boot → **Disable** (NixOS installer doesn't require Secure Boot)
   - BIOS → Boot → Legacy/UEFI → Set to **UEFI only**

---

## Step 3 — Partition Strategy

You have two options. **Option A** is recommended to preserve `/home` data.

### Option A — Reuse Existing Partitions (preserves `/home`)

This keeps `/dev/nvme0n1p1` (EFI) and the LVM volume group `ArchinstallVg`,
but reinstalls NixOS into the `/@` Btrfs subvolume only. Your `/@home` data
(and `/@log`) survive the reinstall.

In the live installer terminal:

```bash
# Activate the existing LVM group
vgchange -ay ArchinstallVg

# Mount the root subvolume
mount -o subvol=/@,compress=zstd:3,ssd,discard=async /dev/ArchinstallVg/root /mnt

# Mount EFI partition
mkdir -p /mnt/boot
mount /dev/nvme0n1p1 /mnt/boot

# Mount /home subvolume (preserving your data)
mkdir -p /mnt/home
mount -o subvol=/@home,compress=zstd:3,ssd,discard=async /dev/ArchinstallVg/root /mnt/home

# Mount /var/log subvolume
mkdir -p /mnt/var/log
mount -o subvol=/@log,compress=zstd:3,ssd,discard=async /dev/ArchinstallVg/root /mnt/var/log
```

### Option B — Fresh Install (wipes everything)

Use the NixOS graphical installer or `disko` to create new partitions. After
install you will need to update `hardware-configuration.nix` with the new UUIDs:

```bash
# Find new UUIDs after partitioning
blkid /dev/nvme0n1p1   # EFI
blkid /dev/ArchinstallVg/root  # or new LVM/Btrfs device
```

Update `nixos/hardware-configuration.nix`:
- `fileSystems."/boot".device` → new EFI UUID
- `fileSystems."/"` etc. → new LVM device path or UUID

---

## Step 4 — Copy the Flake Config

```bash
# In the live installer, get network access first:
# If WiFi: nmtui or nmcli device wifi connect "SSID" password "PASS"

# Copy your config repo into the target system
mkdir -p /mnt/etc/nixos
cp -r /path/to/nixos-config/* /mnt/etc/nixos/

# Or clone directly if you have network:
git clone <your-repo-url> /mnt/etc/nixos
```

---

## Step 5 — Generate and Reconcile hardware-configuration.nix

```bash
# Generate a fresh hardware-configuration.nix from the running installer
nixos-generate-config --root /mnt

# Compare with the one in this repo:
diff /mnt/etc/nixos/hardware-configuration.nix \
     /mnt/etc/nixos/nixos/hardware-configuration.nix
```

The generated file will be at `/mnt/etc/nixos/hardware-configuration.nix`.
Key things to reconcile:

1. If the LVM VG is still named `ArchinstallVg` → the repo's `hardware-configuration.nix`
   should already be correct.
2. If you did a fresh install with new partitions → update the EFI UUID in
   `fileSystems."/boot".device`.
3. Replace the generated `hardware-configuration.nix` with the one from this repo,
   or copy any missing hardware-specific settings (e.g., new firmware) into the repo version.

```bash
# Use the repo's hardware-configuration.nix (if doing Option A reuse)
cp /mnt/etc/nixos/nixos/hardware-configuration.nix /mnt/etc/nixos/hardware-configuration.nix
```

---

## Step 6 — Install NixOS

```bash
# From within the live installer with the flake config in /mnt/etc/nixos:
nixos-install --flake /mnt/etc/nixos#nixos9310

# You will be prompted to set the root password.
# Set a temporary root password — you can change it after first boot.
```

If nixos-install can't fetch flake inputs (no network), ensure WiFi is connected:
```bash
nmcli device wifi connect "YourSSID" password "YourPassword"
```

---

## Step 7 — First Boot

1. Remove the USB drive and reboot
2. GDM login screen should appear — it shows both **GNOME** and **Hyprland** as session options
3. **You cannot log in as `tom` yet** — no password has been set for the user account.
   Log in as `root` using the root password you set during `nixos-install`, then:

```bash
# Set the password for the tom user
passwd tom

# Then log out of the root session
exit
```

4. Log in as `tom` — select either **GNOME** or **Hyprland** from the GDM session menu
5. Verify Hyprland loads: waybar should appear, monitor layout should match `hyprland.lua`

> **Why no password?** NixOS configuration files are stored world-readable in `/nix/store`.
> Putting a password there would expose it to any user on the system. Passwords are always
> set interactively with `passwd` after first boot.
>
> If you need a password baked in for automated installs, you can temporarily add
> `users.users.tom.initialPassword = "changeme";` to `nixos/modules/users.nix`, rebuild,
> then remove it and run `passwd tom` to set a real password. Never commit this to a
> public repository.

---

## Step 8 — Post-Install Steps

Run these after first login. Order matters — chezmoi and 1Password depend on the age key.

### 8a — Restore secrets and credentials

```bash
# 1. Copy your wallpaper — hyprpaper and hyprlock reference this path;
#    without it Hyprland shows a black screen and hyprlock crashes on lock
mkdir -p ~/Documents/wallpaper
cp /path/to/backup/wallpaper_dark.jpg ~/Documents/wallpaper/

# 2. Restore your age key — required before chezmoi can decrypt anything
mkdir -p ~/.age
cp /path/to/backup/key.txt ~/.age/key.txt
chmod 600 ~/.age/key.txt

# 3. Sign in to 1Password (open the GUI app, sign in with your account key + password)
#    SSH agent and CLI (op) won't work until signed in

# 4. Apply chezmoi dotfiles — decrypts and places all managed dotfiles.
#    chezmoi.toml (age encryption settings, 1Password command, git settings)
#    is NOT managed by Nix; this recreates it from your chezmoi source repo.
chezmoi init --apply <your-chezmoi-source-repo-url>
#    Verify the config was restored:
cat ~/.config/chezmoi/chezmoi.toml

# 5. Restore SSH keys (if not in chezmoi repo — check first)
ls ~/.ssh/   # chezmoi may have already placed these
# If missing, copy from backup:
cp /path/to/backup/id_ed25519_github ~/.ssh/
cp /path/to/backup/id_ed25519_gitea  ~/.ssh/
chmod 600 ~/.ssh/id_ed25519_*

# 6. Connect to Tailscale
tailscale up
```

### 8b — Authenticate developer tools

```bash
# 7. Re-authenticate GitHub CLI
gh auth login

# 8. Set up Rust toolchain (rustup is installed; toolchain is not)
rustup default stable
rustup component add rust-analyzer clippy rustfmt

# 9. Install claude-code (not in nixpkgs — must be installed via npm)
npm install -g @anthropic-ai/claude-code
```

### 8c — Restore Python environment

Python virtual environments from Arch **cannot be migrated** — they contain hardcoded
paths to the Arch Python interpreter (`/usr/bin/python3.12`) which does not exist on NixOS.
All virtual environments must be recreated.

```bash
# Reinstall pipx-managed tools (run `pipx list` on Arch first to get the list)
pipx install black
pipx install ruff
# ... add any others from your `pipx list` output

# Recreate per-project virtual environments with uv
cd ~/repos/myproject
uv venv
uv pip install -r requirements.txt   # or: uv sync (if using uv.lock)

# uv-managed tools
uv tool install ruff   # if you used `uv tool install` rather than pipx
```

> **Why can't venvs be migrated?** A virtual environment hard-codes the absolute path
> to the Python binary it was created with (e.g. `/usr/bin/python3.12`). On NixOS,
> Python lives at a path like `/nix/store/abc123.../bin/python3`. The old venv's
> `python` symlink will be broken. Always recreate them with `uv venv` in each project.

### 8d — Hardware setup

```bash
# 10. Enrol fingerprint (must be done once per device, not stored in config)
fprintd-enroll tom
fprintd-verify tom   # test it worked

# 11. Register YubiKey for PAM U2F (sudo + login)
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
```

### 8e — Display and appearance

```bash
# 12. Apply kitty colour theme (theme.conf is not tracked in this repo)
kitten themes   # pick a theme; it writes ~/.config/kitty/theme.conf

# 13. GNOME monitor layout — if you use the GNOME session, configure monitors
#     in Settings → Displays. GNOME stores display config in dconf (runtime state,
#     not managed by Nix). It does not read hyprland.lua.
#     Hyprland monitor layout is already correct via hyprland.lua.
```

### 8f — Firmware updates

```bash
# 14. Update firmware (BIOS, NVMe, WiFi — fwupd is enabled in the config)
fwupdmgr refresh
fwupdmgr get-updates
fwupdmgr update   # prompts for reboot if BIOS update is available
```

---

## Updating the Config Later

```bash
# After editing any .nix file in ~/repos/nixos-config:
sudo nixos-rebuild switch --flake ~/repos/nixos-config#nixos9310

# Update all flake inputs to latest:
cd ~/repos/nixos-config
nix flake update
sudo nixos-rebuild switch --flake .#nixos9310
```
