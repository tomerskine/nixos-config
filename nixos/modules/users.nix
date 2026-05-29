{ pkgs, ... }:

{
  # Enable zsh system-wide so it can be set as the login shell
  programs.zsh.enable = true;

  users.users.tom = {
    isNormalUser = true;
    description  = "Tom Erskine";
    extraGroups  = [
      "wheel"           # sudo
      "networkmanager"  # manage WiFi without sudo
      "video"           # brightness control
      "audio"           # audio devices
      "uinput"          # Hyprland input emulation
      "input"           # evdev access
    ];
    shell = pkgs.zsh;
  };
}
