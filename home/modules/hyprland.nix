# Hyprland uses a Lua config (hyprland.lua). The Home Manager module is enabled
# for its session entry and env-var wiring, but config generation is bypassed —
# Hyprland auto-detects and loads hyprland.lua when present, taking priority
# over the generated hyprland.conf.
{ pkgs, inputs, ... }:

{
  wayland.windowManager.hyprland = {
    enable        = true;
    package       = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
    configType    = "lua";
    systemd.enable = false;  # config is managed via xdg.configFile (hyprland.lua), not HM options
  };

  # Lua config and all helper files placed verbatim
  xdg.configFile."hypr/hyprland.lua".source        = ../files/hypr/hyprland.lua;
  xdg.configFile."hypr/hypridle.conf".source        = ../files/hypr/hypridle.conf;
  xdg.configFile."hypr/hyprlock.conf".source        = ../files/hypr/hyprlock.conf;
  xdg.configFile."hypr/hyprpaper.conf".source       = ../files/hypr/hyprpaper.conf;
  xdg.configFile."hypr/opacity-manager.py".source   = ../files/hypr/opacity-manager.py;
  xdg.configFile."hypr/should-lock.sh" = {
    source     = ../files/hypr/should-lock.sh;
    executable = true;
  };
  xdg.configFile."hypr/monitor-workspaces.sh" = {
    source     = ../files/hypr/monitor-workspaces.sh;
    executable = true;
  };

  # Qt platform theme (set in hyprland.lua via hl.env)
  home.sessionVariables = {
    QT_QPA_PLATFORMTHEME = "qt6ct";
    XCURSOR_SIZE         = "24";
    HYPRCURSOR_SIZE      = "24";
  };
}
