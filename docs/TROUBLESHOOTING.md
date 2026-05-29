# Troubleshooting — nixos9310

Common issues and fixes specific to this hardware and configuration.

---

## Dell XPS 13 9310 Hardware Quirks

These are known issues specific to this laptop model on Linux. All of them are
addressed in the config (via `nixos-hardware.nixosModules.dell-xps-13-9310` plus
the XPS-specific settings in `boot.nix` and `networking.nix`), but documented here
so you know what to check if something regresses.

### Screen flickering or display freeze (Intel Iris Xe PSR)

**Cause:** Panel Self-Refresh (PSR) on the i915 driver causes periodic display
freeze or flickering on Tiger Lake Iris Xe hardware.

**Fix in config:** `boot.kernelParams = [ "i915.enable_psr=0" ]` in `nixos/modules/boot.nix`.

If flickering persists, also try disabling Frame Buffer Compression:
```nix
boot.kernelParams = [ "i915.enable_psr=0" "i915.enable_fbc=0" ];
```

---

### Touchpad errors in dmesg / system hangs on shutdown

**Cause:** The XPS 9310 touchpad connects over I2C, not PS/2. The `psmouse`
kernel module tries to claim it anyway, causing boot errors and — critically —
**hangs on shutdown/reboot**.

**Fix in config:** `boot.blacklistedKernelModules = [ "psmouse" ]` in `nixos/modules/boot.nix`
(also applied by `nixos-hardware.nixosModules.dell-xps-13-9310`).

If you see shutdown hangs, verify the blacklist is active:
```bash
lsmod | grep psmouse   # should return nothing
```

---

### WiFi drops / packet loss / poor performance

**Cause:** The Intel AX201 WiFi firmware's power-saving features cause connection
instability — packet loss at rest, slow reconnection after screen wake, and
occasional firmware stalls.

**Fix in config:** `boot.extraModprobeConfig` in `nixos/modules/networking.nix` sets:
```
options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
```

To verify the options are applied:
```bash
cat /sys/module/iwlwifi/parameters/power_save   # should show: 0
```

If WiFi disappears after waking from sleep:
```bash
# Manual reload (temporary)
sudo modprobe -r iwlwifi && sudo modprobe iwlwifi
# Or restart NetworkManager
sudo systemctl restart NetworkManager
```

---

### Suspend / resume issues

**Important:** The XPS 9310 **does not support S3 deep sleep**. It only supports
`s2idle` (modern standby / Windows Connected Standby). The kernel parameter
`mem_sleep_default=deep` has no effect on this hardware — do not add it.

```bash
# Confirm only s2idle is available (this is normal for the 9310):
cat /sys/power/mem_sleep
# Expected output: [s2idle]
```

With a recent kernel and the iwlwifi power-saving disabled (see above), s2idle
works reasonably well. If suspend still fails:

```bash
# Check what prevented suspend
journalctl -b | grep -i "suspend\|sleep\|wakeup\|failed" | tail -30

# Test suspend
systemctl suspend
```

Known issue: if Bluetooth is active during suspend, it can time out and block
sleep entry. Workaround:
```bash
# Disable Bluetooth before suspending
bluetoothctl power off
systemctl suspend
```
A more permanent fix is to add a sleep hook — add to `nixos/modules/bluetooth.nix`:
```nix
systemd.services.bluetooth-pre-sleep = {
  description = "Power off Bluetooth before suspend";
  before = [ "sleep.target" ];
  wantedBy = [ "sleep.target" ];
  serviceConfig.ExecStart = "${pkgs.bluez}/bin/bluetoothctl power off";
  serviceConfig.Type = "oneshot";
};
```

---

### Firmware updates (BIOS, NVMe, WiFi)

`services.fwupd.enable = true` is set in the config. After first boot:

```bash
# Refresh firmware metadata
fwupdmgr refresh

# Check for updates
fwupdmgr get-updates

# Apply updates (will prompt to reboot)
fwupdmgr update
```

Keep the BIOS firmware up to date — Dell has released fixes for suspend and WiFi
stability in BIOS versions ≥ 1.2.5.

---

### Fingerprint reader: fprintd TOD build failure

The `libfprint-2-tod1-goodix` TOD driver occasionally fails to build in nixpkgs
due to dependency issues (NSS/libfprint version mismatches).

```bash
# Check if fprintd is working
systemctl status fprintd
fprintd-list tom   # lists enrolled fingers
```

If the build fails during `nixos-rebuild`:
1. Temporarily disable: comment out `services.fprintd.tod.enable = true;` in `security.nix`
2. Rebuild and boot normally
3. Re-enable after the nixpkgs issue is resolved (check https://github.com/NixOS/nixpkgs/issues)

---

## Hyprland

### Hyprland starts but waybar is missing or screen is blank

**Cause:** `hyprland.lua` not being read, or a Lua runtime error.

```bash
# Check Hyprland logs
journalctl --user -u hyprland -b
# Or look at the most recent log:
cat ~/.local/share/hyprland/hyprland.log | tail -50

# Verify the Lua config was placed correctly
ls -la ~/.config/hypr/hyprland.lua
```

If the file is missing, Home Manager didn't apply:
```bash
home-manager switch --flake ~/repos/nixos-config#nixos9310
```

If Lua reports a syntax error: check that the Hyprland flake version in `flake.lock`
supports Lua configs. Run `nix flake update` to pull the latest Hyprland.

---

### GDM doesn't show a Hyprland session option

**Cause:** `programs.hyprland.enable = true` not set at system level, or the package
isn't installed.

```bash
# Check if hyprland session file exists
ls /run/current-system/sw/share/wayland-sessions/
# Should include hyprland.desktop

# Verify the system config is applied
nixos-rebuild switch --flake ~/repos/nixos-config#nixos9310
```

---

### Hyprland: permission denied on input devices

**Cause:** User not in `input` or `uinput` groups.

```bash
groups tom  # should include: input uinput
# If missing, re-apply config or add manually:
sudo usermod -aG input,uinput tom
# Then log out and back in
```

---

## Audio

### No sound / PipeWire not running

```bash
systemctl --user status pipewire pipewire-pulse wireplumber
# All three should be active

# If not running:
systemctl --user restart pipewire wireplumber
```

Ensure `security.rtkit.enable = true` is in the config — PipeWire needs real-time
scheduling to function correctly.

```bash
# Check active audio sinks
wpctl status
wpctl inspect @DEFAULT_AUDIO_SINK@
```

---

### VA-API / hardware video decoding not working

**Cause:** Wrong VAAPI driver loaded (i965 vs iHD).

```bash
vainfo
# Should show: VA-API version, "Driver version: Intel iHD ..."
# If it shows i965 or errors:
export LIBVA_DRIVER_NAME=iHD
vainfo
```

To make this permanent, add to `home.sessionVariables` in `home/home.nix`:
```nix
home.sessionVariables.LIBVA_DRIVER_NAME = "iHD";
```

---

## WiFi

### WiFi not connecting / adapter not found after install

```bash
dmesg | grep -i iwlwifi
# Look for "loaded firmware" — if firmware is missing:
# Ensure hardware.enableRedistributableFirmware = true in hardware-configuration.nix
```

If the adapter is missing entirely:
```bash
ip link show  # wlp0s20f3 should appear
lspci | grep -i network
```

---

## Bluetooth

### Bluetooth not available

```bash
systemctl status bluetooth
rfkill list
# If bluetooth shows "blocked": rfkill unblock bluetooth
```

---

## MX Master 3S / logiops

### Mouse buttons not working (gestures not triggering Hyprland keybinds)

```bash
systemctl status logid
# If not running:
sudo systemctl start logid
sudo systemctl enable logid
```

The mouse must be **paired via Bluetooth first** before logiops can control it.
Pair in Blueman or:
```bash
bluetoothctl
# power on; scan on; connect <MAC>
```

Then restart logid:
```bash
sudo systemctl restart logid
```

Check `/etc/logid.cfg` was placed (it's managed by `services.logiops.extraConfig`):
```bash
cat /etc/logid.cfg | head -5
# Should show: devices: ( { name: "MX Master 3S"; ...
```

---

## 1Password

### 1Password SSH agent / browser extension not working

```bash
# Verify polkit policy is in place
ls /etc/polkit-1/rules.d/ | grep 1password

# Verify user can access the 1Password socket
ls -la ~/.1password/agent.sock

# Restart 1Password
systemctl --user restart 1password
```

Ensure `programs._1password-gui.polkitPolicyOwners = ["tom"]` is set and
`nixos-rebuild switch` has been run.

---

## Security / Authentication

### Fingerprint enrolment fails

```bash
systemctl status fprintd
fprintd-enroll   # enrol right index finger by default
fprintd-verify   # test the enrolled finger
```

The Goodix fingerprint reader (USB 27c6:533c) requires the `libfprint-2-tod1-goodix`
TOD driver, which is configured in `security.nix`. If the build fails, see the
**Fingerprint reader: fprintd TOD build failure** section above.

---

### YubiKey not recognised for sudo

```bash
# Check pcscd is running
systemctl status pcscd
# Check the YubiKey is detected
ykman info

# Verify PAM U2F config
cat /etc/pam.d/sudo | grep u2f
```

If you haven't registered the YubiKey yet:
```bash
mkdir -p ~/.config/Yubico
pamu2fcfg > ~/.config/Yubico/u2f_keys
```

---

## LVM / Boot

### LVM volumes not found at boot (dracut/initrd error)

**Cause:** `dm-mod` kernel module not loaded in initrd.

Check `nixos/hardware-configuration.nix` has:
```nix
boot.initrd.kernelModules = [ "dm-mod" ];
boot.initrd.services.lvm.enable = true;
```

Rebuild and reinstall:
```bash
sudo nixos-rebuild switch --flake ~/repos/nixos-config#nixos9310
```

---

### Btrfs subvolumes missing after fresh install

```bash
# List existing subvolumes on the Btrfs volume
btrfs subvolume list /

# Expected subvolumes: @, @home, @log
# If missing, create them:
mount /dev/ArchinstallVg/root /mnt/btrfs-root
btrfs subvolume create /mnt/btrfs-root/@
btrfs subvolume create /mnt/btrfs-root/@home
btrfs subvolume create /mnt/btrfs-root/@log
```

---

## Packages

### Unfree packages (Spotify, VS Code, 1Password, Obsidian) blocked

```bash
error: ... is marked as unfree
```

Ensure both files set `allowUnfree = true`:
- `nixos/configuration.nix`: `nixpkgs.config.allowUnfree = true`
- `home/home.nix`: `nixpkgs.config.allowUnfree = true`

---

### `nixos-rebuild` fails fetching Hyprland flake

**Cause:** No internet connection, or flake input cache expired.

```bash
# Pre-fetch all inputs while online:
cd ~/repos/nixos-config
nix flake update   # updates flake.lock
nix flake archive  # caches inputs locally

# Then rebuild:
sudo nixos-rebuild switch --flake .#nixos9310
```

---

## General

### Home Manager changes not applied after nixos-rebuild

Home Manager runs as part of `nixos-rebuild switch` when wired in as a NixOS module.
If you run it standalone instead:

```bash
home-manager switch --flake ~/repos/nixos-config#nixos9310
```

---

### Check what generation is active

```bash
nixos-rebuild list-generations
# Roll back to the previous generation if something is broken:
sudo nixos-rebuild switch --rollback
```
