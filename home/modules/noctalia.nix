{ inputs, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;

    settings = {
      bar = {
        position = "top";
        widgets = {
          left = [
            { id = "Workspace"; }
          ];
          center = [
            { id = "ActiveWindow"; }
          ];
          right = [
            # Media — replaces mpris
            { id = "MediaMini"; hideWhenIdle = true; }

            # Tailscale — official plugin (auto-installed on first launch)
            { id = "tailscale"; }

            # Connectivity
            { id = "Network"; }
            { id = "Bluetooth"; }

            # Audio + brightness (new)
            { id = "Volume"; }
            { id = "Brightness"; }

            # Power
            { id = "Battery"; showPowerProfiles = false; }
            { id = "PowerProfile"; }

            # Controls — replaces idle_inhibitor, custom/dnd
            { id = "KeepAwake"; }
            { id = "NotificationHistory"; }

            # Clipboard — reuses existing cliphist+rofi script
            {
              id = "CustomButton";
              icon = "clipboard";
              showIcon = true;
              leftClickExec = "~/.config/noctalia/scripts/clipboard.sh";
              generalTooltipText = "Clipboard history";
            }

            # System tray + session menu (replaces custom/power rofi script)
            { id = "Tray"; }
            { id = "SessionMenu"; }

            { id = "Clock"; }
          ];
        };
      };

      idle = {
        # hypridle handles idle detection so Noctalia's built-in idle is disabled.
        # This preserves the trusted-network suppression in should-lock.sh.
        enabled = false;
      };

      general = {
        # Noctalia locks the session on system suspend
        lockOnSuspend = true;
      };

      colorSchemes = {
        darkMode = true;
      };
    };

    # Enable the Tailscale plugin from noctalia-dev/noctalia-plugins
    plugins = {
      sources = [
        {
          enabled = true;
          name = "Noctalia Plugins";
          url = "https://github.com/noctalia-dev/noctalia-plugins";
        }
      ];
      states = {
        tailscale = {
          enabled = true;
          sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
        };
      };
      version = 2;
    };

    pluginSettings = {
      tailscale = {
        refreshInterval = 5000;
        compactMode = false;
        showIpAddress = true;
        showPeerCount = true;
        terminalCommand = "kitty";
        taildropEnabled = true;
        taildropDownloadDir = "~/Downloads";
      };
    };
  };

  # Custom scripts — reused from the old Waybar setup
  xdg.configFile."noctalia/scripts/clipboard.sh" = {
    source = ../files/waybar/scripts/clipboard.sh;
    executable = true;
  };
  xdg.configFile."noctalia/scripts/rename-workspace.sh" = {
    source = ../files/waybar/scripts/rename-workspace.sh;
    executable = true;
  };
}
