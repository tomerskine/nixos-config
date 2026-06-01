_:

{
  programs.waybar.enable = true;

  # Full config and style placed verbatim (complex JSON with custom scripts)
  xdg.configFile."waybar/config.jsonc".source = ../files/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source    = ../files/waybar/style.css;

  # Custom scripts — all need to be executable
  xdg.configFile."waybar/scripts/tailscale-status.sh" = {
    source     = ../files/waybar/scripts/tailscale-status.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/tailscale-menu.sh" = {
    source     = ../files/waybar/scripts/tailscale-menu.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/wifi-menu.sh" = {
    source     = ../files/waybar/scripts/wifi-menu.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/power-menu.sh" = {
    source     = ../files/waybar/scripts/power-menu.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/clipboard.sh" = {
    source     = ../files/waybar/scripts/clipboard.sh;
    executable = true;
  };
  xdg.configFile."waybar/scripts/rename-workspace.sh" = {
    source     = ../files/waybar/scripts/rename-workspace.sh;
    executable = true;
  };
}
