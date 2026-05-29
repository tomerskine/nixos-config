# Arch Backup & NixOS Restore Guide

A full backup of the Arch Linux install was taken on 2026-05-29 to an SD card
before beginning the dual-boot NixOS installation. This document describes what
was backed up and the exact commands to restore each item after the first NixOS boot.

---

## Backup Location

**SD card UUID:** `0123-4567`
**Backup directory:** `arch-backup-20260529/`

On NixOS the SD card will auto-mount at:
```
/run/media/tom/0123-4567/
```

All restore commands below use `$BACKUP` as a shorthand — set it once:

```bash
BACKUP=/run/media/tom/0123-4567/arch-backup-20260529
```

---

## What Was Backed Up

| Item | Backup path | Notes |
|---|---|---|
| SSH private keys | `secrets.tar.gz` → `~/.ssh/` | permissions preserved in tar |
| age encryption key | `secrets.tar.gz` → `~/.age/key.txt` | required before chezmoi can decrypt |
| GPG keyring | `secrets.tar.gz` → `~/.gnupg/` | permissions preserved in tar |
| chezmoi config | `secrets.tar.gz` → `~/.config/chezmoi/` | `chezmoi.toml` + state db |
| chezmoi source repo | `secrets.tar.gz` → `~/.local/share/chezmoi/` | the managed dotfiles source |
| Obsidian vaults | `Documents/obsidian_vaults/` | personal notes |
| Wallpaper | `Documents/wallpaper/wallpaper_dark.jpg` | required by hyprpaper + hyprlock |
| Git repos | `repos/` | `.venv` dirs excluded — non-migratable |
| WiFi connections | `system/NetworkManager-connections/` | 2 saved connections |
| Tool inventory | `tool-inventory.txt` | pipx, uv, npm, rustup, go versions |

**Not backed up (intentionally):**
- `~/.cache/` — regenerated automatically
- `~/.local/share/Steam/` — Steam re-downloads game data
- Python virtual environments (`.venv/`) — hardcoded Arch interpreter paths; must be recreated

---

## Repos With Uncommitted Files

These files exist only on the SD card backup (not pushed to any remote):

| Repo | Untracked files |
|---|---|
| `snyk` | `.gitignore`, `.python-version`, `README.md`, `main.py`, `pyproject.toml`, `uv.lock` |
| `tom-erskine-swigger-snack-security` | `.coverage`, `.understand-anything/` |

If you need these files, copy them out of the backup before or after setting up NixOS:
```bash
cp -r $BACKUP/repos/snyk ~/repos/snyk
cp -r $BACKUP/repos/tom-erskine-swigger-snack-security ~/repos/tom-erskine-swigger-snack-security
```

---

## Restore Steps After First NixOS Boot

Run these in order — the age key must be in place before chezmoi, and chezmoi must
run before SSH keys (if SSH keys are managed by chezmoi).

### 1. Set the SD card path

```bash
BACKUP=/run/media/tom/0123-4567/arch-backup-20260529
# Confirm the card is mounted:
ls "$BACKUP"
```

### 2. Restore secrets (SSH keys, age key, GPG, chezmoi)

The `secrets.tar.gz` archive preserves unix permissions. Extract it from your home directory:

```bash
cd ~
tar -xzf "$BACKUP/secrets.tar.gz"
```

This restores:
- `~/.ssh/` — with `600` permissions on private keys
- `~/.age/key.txt` — with `600` permissions
- `~/.gnupg/` — with correct permissions
- `~/.config/chezmoi/chezmoi.toml` — chezmoi config
- `~/.local/share/chezmoi/` — chezmoi dotfiles source

Verify:
```bash
ls -la ~/.ssh/          # id_ed25519_github, id_ed25519_gitea should be mode 600
ls -la ~/.age/key.txt   # should be mode 600
cat ~/.config/chezmoi/chezmoi.toml
```

### 3. Restore the wallpaper

Required before starting Hyprland — hyprpaper and hyprlock reference this path:

```bash
mkdir -p ~/Documents/wallpaper
cp "$BACKUP/Documents/wallpaper/wallpaper_dark.jpg" ~/Documents/wallpaper/
```

Without this file, hyprpaper silently shows a black background and hyprlock crashes on lock.

### 4. Restore WiFi connections

```bash
sudo cp "$BACKUP/system/NetworkManager-connections/"* \
    /etc/NetworkManager/system-connections/
sudo chmod 600 /etc/NetworkManager/system-connections/*
sudo systemctl restart NetworkManager
```

Verify connectivity:
```bash
nmcli connection show
nmcli device status
```

### 5. Restore Obsidian vaults

```bash
mkdir -p ~/Documents
cp -r "$BACKUP/Documents/obsidian_vaults" ~/Documents/
```

### 6. Sign in to 1Password

Open the 1Password GUI app and sign in with your account key and password.
The SSH agent and `op` CLI won't work until signed in.

### 7. Apply chezmoi

Decrypts and places all managed dotfiles (requires the age key from step 2
and 1Password from step 6 if any secrets are 1Password-backed):

```bash
chezmoi apply
# Or re-init from source if the local source wasn't restored:
# chezmoi init --apply <your-chezmoi-source-repo-url>
```

### 8. Authenticate developer tools

```bash
# GitHub CLI
gh auth login

# Tailscale
tailscale up

# Rust toolchain (rustup is installed by Nix; the toolchain is not)
rustup default stable
rustup component add rust-analyzer clippy rustfmt
```

### 9. Reinstall runtime tools

Reference `tool-inventory.txt` for the exact versions:
```bash
cat "$BACKUP/tool-inventory.txt"
```

```bash
# pipx tools
pipx install black

# uv tools
uv tool install ruff

# npm global tools
npm install -g @anthropic-ai/claude-code
```

### 10. Restore repos (if needed)

All repos were clean at backup time except `snyk` and `tom-erskine-swigger-snack-security`
(see above). Clone from remotes where possible; copy uncommitted files from the backup:

```bash
# Example: restore uncommitted snyk files
cp -r "$BACKUP/repos/snyk" ~/repos/snyk-restored
```

### 11. Recreate Python virtual environments

Virtual environments cannot be restored — the Arch interpreter path (`/usr/bin/python3`)
does not exist on NixOS. Recreate them per project:

```bash
cd ~/repos/<project>
uv venv
uv sync   # or: uv pip install -r requirements.txt
```

---

## Verification Checklist

- [ ] SSH keys present and `600`: `ls -la ~/.ssh/`
- [ ] age key present and `600`: `ls -la ~/.age/key.txt`
- [ ] chezmoi applied cleanly: `chezmoi status` (should show no diff)
- [ ] Wallpaper present: `ls ~/Documents/wallpaper/wallpaper_dark.jpg`
- [ ] WiFi connects: `nmcli device status`
- [ ] Hyprland starts without black screen or lock crash
- [ ] `gh auth status` shows authenticated
- [ ] `tailscale status` shows connected
- [ ] `black --version` and `ruff --version` work
- [ ] `claude` command works (npm global install)
