{ inputs, ... }:

{
  imports = [ inputs.noctalia.homeModules.default ];

  programs.noctalia-shell = {
    enable = true;

    settings = {
      bar = {
        position = "top";
        rightClickAction = "none";
        widgets = {
          left = [
            { id = "Workspace"; labelMode = "name"; characterCount = 12; }
          ];
          center = [
            { id = "ActiveWindow"; }
          ];
          right = [
            # Media — icon only when playing, expands to panel on click
            { id = "MediaMini"; hideWhenIdle = true; compactMode = true; }

            # Tailscale — official plugin (auto-installed on first launch)
            { id = "plugin:tailscale"; }

            # Connectivity
            { id = "Network"; }
            { id = "Bluetooth"; }

            # Audio + brightness
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

            # System tray + session menu
            { id = "Tray"; }
            { id = "SessionMenu"; }

            { id = "Clock"; formatHorizontal = "HH:mm"; }
          ];
        };
      };

      dock = {
        enabled = false;
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

      wallpaper = {
        enabled = false;
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
