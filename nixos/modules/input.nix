# logiops daemon for Logitech MX Master 3S
# services.logiops NixOS module is not present at the locked nixpkgs rev.
# Using a manual systemd service with /etc/logid.cfg instead.
# Config syntax uses = (logiops v0.3+ / libconfig format); old Arch config used :
{ pkgs, ... }:

let
  logidConfig = ''
    devices = (
    {
        name = "MX Master 3S";

        smartshift = {
            on = true;
            threshold = 30;
        };

        hiresscroll = {
            hires = true;
            invert = false;
            target = false;
        };

        dpi = 1000;

        buttons = (
            {
                cid = 0xc3;
                action = {
                    type = "Gestures";
                    gestures = (
                        { direction = "None"; mode = "OnRelease";
                          action = { type = "Keypress";
                                     keys = ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_T"]; }; },
                        { direction = "Up"; mode = "OnRelease";
                          action = { type = "Keypress";
                                     keys = ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_F"]; }; },
                        { direction = "Down"; mode = "OnRelease";
                          action = { type = "Keypress";
                                     keys = ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_DOWN"]; }; },
                        { direction = "Left"; mode = "OnRelease";
                          action = { type = "Keypress";
                                     keys = ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_LEFT"]; }; },
                        { direction = "Right"; mode = "OnRelease";
                          action = { type = "Keypress";
                                     keys = ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_RIGHT"]; }; }
                    );
                };
            },
            {
                cid = 0x53;
                action = {
                    type = "Keypress";
                    keys = ["KEY_LEFTMETA", "KEY_LEFTBRACE"];
                };
            },
            {
                cid = 0x56;
                action = {
                    type = "Keypress";
                    keys = ["KEY_LEFTMETA", "KEY_RIGHTBRACE"];
                };
            },
            {
                cid = 0xc4;
                action = {
                    type = "CycleDPI";
                    dpis = [800, 1600, 3200];
                    sensor = 0;
                };
            }
        );
    }
    );
  '';
in
{
  environment.systemPackages = [ pkgs.logiops ];

  environment.etc."logid.cfg".text = logidConfig;

  services.dbus.packages = [ pkgs.logiops ];

  systemd.services.logid = {
    description = "Logiops daemon for Logitech HID++ devices";
    wantedBy = [ "graphical.target" ];
    serviceConfig = {
      ExecStart = "${pkgs.logiops}/bin/logid -c /etc/logid.cfg";
      Restart = "on-failure";
      RestartSec = "1s";
    };
  };
}
