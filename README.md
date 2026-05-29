# nixos9310 — NixOS Configuration

NixOS flake configuration for Tom's Dell laptop (Dell XPS 13 9310, Intel i7-1165G7 Tiger Lake).
Migrated from Arch Linux. Hostname: **nixos9310**.

Uses [`nixos-hardware.nixosModules.dell-xps-13-9310`](https://github.com/NixOS/nixos-hardware/tree/master/dell/xps/13-9310)
for hardware quirks (psmouse blacklist, fprintd TOD driver, fwupd, fstrim, common Intel config),
plus additional XPS 9310-specific fixes for Iris Xe PSR flicker and AX201 WiFi stability.
See `docs/TROUBLESHOOTING.md` for the full list of known hardware issues.

---

## Repository Layout

```
nixos-config/
├── flake.nix                   # Entry point: inputs (nixpkgs, home-manager, hyprland flake, nixos-hardware)
├── nixos/
│   ├── configuration.nix       # Top-level system config; imports all modules
│   ├── hardware-configuration.nix  # Disk layout, CPU/GPU, firmware
│   └── modules/
│       ├── boot.nix            # systemd-boot, kernel, initrd
│       ├── networking.nix      # NetworkManager, Tailscale, firewall
│       ├── desktop.nix         # GNOME + Hyprland (from flake), GDM, portals
│       ├── audio.nix           # PipeWire + ALSA/Pulse/JACK compat
│       ├── bluetooth.nix       # BlueZ, Blueman
│       ├── security.nix        # sudo, 1Password, YubiKey PAM, fprintd
│       ├── input.nix           # logiops daemon (MX Master 3S)
│       └── users.nix           # User "tom" with groups and zsh shell
└── home/
    ├── home.nix                # Home Manager root: packages, GTK theming, XDG
    ├── modules/
    │   ├── shell.nix           # Zsh + oh-my-zsh + Starship + zoxide + fzf
    │   ├── hyprland.nix        # Hyprland session entry + Lua config placement
    │   ├── kitty.nix           # Kitty terminal (JetBrainsMono, opacity)
    │   ├── waybar.nix          # Waybar + 5 custom scripts
    │   └── git.nix             # Git identity + credential helpers
    └── files/                  # Raw config files placed verbatim by Home Manager
        ├── hypr/               # hyprland.lua, hypridle, hyprlock, hyprpaper, scripts
        ├── waybar/             # config.jsonc, style.css, scripts/
        ├── starship.toml       # Starship prompt config
        └── kitty/              # (placeholder for theme.conf — see below)
```

---

## What's Included

### Desktop Environment

| Component | Arch Package | NixOS / Config Location |
|---|---|---|
| Hyprland (Lua config) | `hyprland` (AUR latest) | `programs.hyprland` + Hyprland flake input |
| Hyprland Lua config | `~/.config/hypr/hyprland.lua` | `home/files/hypr/hyprland.lua` (placed verbatim) |
| hypridle | `hypridle` | `home/files/hypr/hypridle.conf` |
| hyprlock | `hyprlock` | `home/files/hypr/hyprlock.conf` |
| hyprpaper | `hyprpaper` | `home/files/hypr/hyprpaper.conf` |
| opacity manager | custom script | `home/files/hypr/opacity-manager.py` |
| GNOME Shell | `gnome-shell` | `services.desktopManager.gnome.enable` |
| GDM | `gdm` | `services.displayManager.gdm` |
| Waybar | `waybar` | `programs.waybar` + verbatim config |
| Waybar scripts (5) | custom | `home/files/waybar/scripts/` |
| Rofi | `rofi` | `rofi-wayland` package |
| Dunst / Mako | `dunst` `mako` | system packages in `desktop.nix` |
| udiskie | `udiskie` | system package |

### Shell & Terminal

| Component | Arch Package | NixOS / Config Location |
|---|---|---|
| Zsh | `zsh` | `programs.zsh` in `users.nix` + `home/modules/shell.nix` |
| oh-my-zsh | `oh-my-zsh-git` (AUR) | `programs.zsh.oh-my-zsh` |
| zsh-autosuggestions | AUR | `programs.zsh.plugins` |
| zsh-syntax-highlighting | AUR | `programs.zsh.plugins` |
| Starship prompt | `starship` | `programs.starship` + `home/files/starship.toml` |
| zoxide | `zoxide` | `programs.zoxide` |
| fzf | `fzf` | `programs.fzf` |
| Kitty | `kitty` | `home/modules/kitty.nix` |
| tmux | `tmux` | `home.packages` |

### Development

| Component | Arch Package | NixOS |
|---|---|---|
| Git | `git` | `programs.git` in `home/modules/git.nix` |
| GitHub CLI | `github-cli` | `github-cli` package |
| lazygit | `lazygit` | `lazygit` package |
| lazydocker | `lazydocker` | `lazydocker` package |
| Rust | `rustup` | `rustup` package |
| Node.js | `npm` | `nodejs` package |
| pnpm | `pnpm-bin` (AUR) | `nodePackages.pnpm` |
| Python | `python3` | `python3` + `python3Packages.pipx` |
| uv | `uv` | `uv` package |
| VS Code | `visual-studio-code-bin` (AUR) | `vscode` (unfree) |
| cmake | `cmake` | `cmake` package |
| Podman | `podman` | `virtualisation.podman` (system) + `podman-desktop` |

### System Services

| Service | Arch | NixOS Config |
|---|---|---|
| NetworkManager | `networkmanager` | `networking.networkmanager.enable` |
| Tailscale | `tailscale` | `services.tailscale.enable` |
| PipeWire | `pipewire` + stack | `services.pipewire.*` in `audio.nix` |
| WirePlumber | `wireplumber` | `services.pipewire.wireplumber.enable` |
| Bluetooth | `bluez` | `hardware.bluetooth.enable` |
| logiops (mouse) | `logiops` (AUR) | `services.logiops.enable` in `input.nix` |
| power-profiles-daemon | `power-profiles-daemon` | `services.power-profiles-daemon.enable` |
| fprintd (fingerprint) | implied | `services.fprintd.enable` |
| pcscd (smartcard) | implied | `services.pcscd.enable` |
| GNOME keyring | `gnome-keyring` | `services.gnome.gnome-keyring.enable` |

### Hardware

| Feature | Detail | NixOS Config |
|---|---|---|
| CPU | Intel i7-1165G7 Tiger Lake | `hardware.cpu.intel.updateMicrocode` |
| GPU | Intel Iris Xe | `hardware.graphics` + `intel-media-driver` |
| WiFi | Intel AX201 | `hardware.enableRedistributableFirmware` |
| Bluetooth | Intel AX201 | `hardware.bluetooth.enable` |
| Fingerprint | Goodix 27c6:533c | `services.fprintd.enable` |
| Storage | NVMe + LVM + Btrfs subvols | `nixos/hardware-configuration.nix` |
| Boot | systemd-boot (UEFI) | `boot.loader.systemd-boot.enable` |
| Zram swap | 25% of RAM | `zramSwap` |

### Security & Credentials

| Component | NixOS Config |
|---|---|
| 1Password GUI + CLI | `programs._1password-gui` + `programs._1password` in `security.nix` |
| YubiKey PAM U2F | `security.pam.u2f.enable` |
| YubiKey smartcard | `services.pcscd.enable` |
| age encryption | `age` package |
| chezmoi | `chezmoi` package in `home.nix` |

---

## Coverage Notes

### Git config ✅ Fully declarative
`home/modules/git.nix` generates `~/.gitconfig` with your name, email, libsecret
credential helper, and `gh auth git-credential` for GitHub/Gist. No manual steps needed
beyond re-authenticating `gh auth login` after first boot.

---

### Chezmoi ⚠️ Binary installed; config is NOT managed by Nix
`chezmoi` is installed as a package. However, `~/.config/chezmoi/chezmoi.toml`
(containing your age encryption identity, 1Password command, and git settings)
is **intentionally not in this repo** — it references `~/.age/key.txt` which is a
secret and must never enter the Nix store (all Nix store paths are world-readable).

**After first login:**
```bash
# 1. Restore your age key first
mkdir -p ~/.age && cp /path/to/backup/key.txt ~/.age/key.txt && chmod 600 ~/.age/key.txt

# 2. Init chezmoi — this recreates chezmoi.toml and applies all managed dotfiles
chezmoi init --apply <your-chezmoi-source-repo-url>
```

---

### Python virtual environments ❌ Cannot be migrated
`python3`, `uv`, and `pipx` are installed. However, virtual environments created
under Arch **cannot be reused** — they contain hardcoded paths to the Arch Python
binary (e.g. `/usr/bin/python3.12`) which does not exist on NixOS. The venv's
internal `python` symlink will be broken.

**After first login:**
```bash
# Reinstall pipx tools (get the list first: `pipx list` on Arch)
pipx install black ruff   # etc.

# Recreate per-project venvs
cd ~/repos/myproject && uv venv && uv sync
```

> Record your current `pipx list` and `uv tool list` output before migrating.

---

### Hyprland ✅ Fully covered
Your exact `hyprland.lua` (monitors, keybinds, animations, window rules) is placed
verbatim at `~/.config/hypr/hyprland.lua`. All supporting files are included:
`hypridle.conf`, `hyprlock.conf`, `hyprpaper.conf`, `opacity-manager.py`,
`should-lock.sh`, `monitor-workspaces.sh`.

**One manual step:** The wallpaper file is referenced by path but is a binary asset
that cannot go in the Nix store. Copy it from backup:
```bash
mkdir -p ~/Documents/wallpaper
cp /path/to/backup/wallpaper_dark.jpg ~/Documents/wallpaper/
```
Without the wallpaper, `hyprpaper` will fail silently (black background) and
`hyprlock` will crash on lock attempt.

---

### Waybar ✅ Fully covered
`config.jsonc`, `style.css`, and all 5 custom scripts are placed verbatim with
correct executable permissions. No manual steps needed.

---

### Display config ✅ / ⚠️ Depends on session
- **Hyprland:** Monitor layout (DP-1/DP-3 at 3840×2160 scale 1.5, eDP-1 at 1920×1200
  scale 1.5, workspace assignments 1–5 external / 6–10 laptop) is fully covered via
  `hyprland.lua`. Works out of the box.
- **GNOME:** GNOME stores display configuration in dconf (a runtime database), not in
  Nix config files. On first GNOME login, go to **Settings → Displays** and configure
  monitor layout and scaling manually. This only needs to be done once; GNOME remembers it.

---

### Username ✅ Fully covered
`nixos/modules/users.nix` creates user `tom` with the correct groups
(`wheel networkmanager video audio uinput input`) and `zsh` as the login shell.

---

### Password ❌ Must be set manually after first boot
NixOS config files are world-readable in `/nix/store` — passwords cannot be stored
there. The `tom` user account has **no password set** after install.

```bash
# After nixos-install, before first user login:
# Log in as root (using the password set during nixos-install), then:
passwd tom
```

> If you need an automated bootstrap password (e.g. for a headless install), you can
> temporarily add `users.users.tom.initialPassword = "changeme";` to `users.nix`,
> rebuild, then immediately run `passwd tom` to replace it. Remove the line from
> `users.nix` and rebuild again afterwards. Never commit this to a public repository.

---

### Login manager ✅ Fully covered
GDM is configured with Wayland enabled. On first boot it presents the login screen
with both **GNOME** and **Hyprland** as selectable sessions. Your last-used session
is remembered between logins.

---

## What's NOT Included / Manual Steps Required

Items that are structurally impossible or unsafe to manage declaratively:

| Item | Reason | Action |
|---|---|---|
| User password | Nix store is world-readable | `passwd tom` as root after first boot |
| chezmoi config (`chezmoi.toml`) | References secret age key path | `chezmoi init --apply <repo>` after restoring `~/.age/key.txt` |
| Python virtual environments | Hardcoded Arch interpreter paths; invalid on NixOS | Recreate with `uv venv` per project; reinstall `pipx` tools |
| Wallpaper (`wallpaper_dark.jpg`) | Binary asset — cannot go in Nix store | Copy from backup to `~/Documents/wallpaper/` |
| GNOME display layout | dconf runtime state, not a config file | Set once in Settings → Displays after first GNOME login |
| SSH private keys | Secrets — must not go in Nix store | Restore from backup or via chezmoi after first login |
| WiFi passwords | Stored in NetworkManager runtime state | Re-enter on first connection |
| Tailscale auth | Requires device authentication | `tailscale up` after first boot |
| 1Password vault | Requires interactive sign-in | Open 1Password app, sign in with account key |
| kitty `theme.conf` | Not tracked (set interactively) | `kitten themes` to pick and apply |
| `claude-code` | Not in nixpkgs | `npm install -g @anthropic-ai/claude-code` |
| Fingerprint enrolment | Per-device biometric data | `fprintd-enroll tom` after first login |
| YubiKey PAM registration | Per-device key registration | `pamu2fcfg > ~/.config/Yubico/u2f_keys` |
| `lazysql` / `lazyssh` | May not be in nixpkgs | `nix search nixpkgs lazysql`; build from source if missing |
| Steam games | User data / large binaries | Steam re-downloads; or restore `~/.local/share/Steam` from backup |
| pipx tools (`black`, `ruff`, etc.) | Installed at runtime, not declaratively | Reinstall with `pipx install` after migration |

---

## Quick Start (after NixOS install)

```bash
# 1. Set your user password (as root, before first user login)
passwd tom

# 2. Log in as tom, then restore the wallpaper (Hyprland needs it on first start)
mkdir -p ~/Documents/wallpaper
cp /path/to/backup/wallpaper_dark.jpg ~/Documents/wallpaper/

# 3. Restore age key (required for chezmoi to decrypt dotfiles)
mkdir -p ~/.age && cp /path/to/backup/key.txt ~/.age/key.txt && chmod 600 ~/.age/key.txt

# 4. Apply chezmoi (restores chezmoi.toml, SSH keys, and all managed dotfiles)
chezmoi init --apply <your-chezmoi-repo>

# 5. Sign in to 1Password, then authenticate remaining tools
gh auth login
tailscale up

# 6. Reinstall runtime tools not managed by Nix
npm install -g @anthropic-ai/claude-code
pipx install black ruff   # and any others from your `pipx list`
rustup default stable

# 7. Hardware setup
fprintd-enroll tom
pamu2fcfg > ~/.config/Yubico/u2f_keys

# 8. Kitty theme (not tracked in repo)
kitten themes
```

See `docs/HOWTO-install.md` for the complete step-by-step installation walkthrough,
including partition setup, hardware-configuration.nix reconciliation, and all
post-install steps with explanations.
