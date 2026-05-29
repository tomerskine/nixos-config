# logiops daemon for Logitech MX Master 3S
# Buttons map to Hyprland keybindings defined in hyprland.lua
{ ... }:

{
  services.logiops = {
    enable = true;
    extraConfig = ''
      devices: (
      {
          name: "MX Master 3S";

          smartshift: {
              on: true;
              threshold: 30;
          };

          hiresscroll: {
              hires: true;
              invert: false;
              target: false;
          };

          dpi: 1000;

          buttons: (
              // Gesture button (large thumb button) — window management
              {
                  cid: 0xc3;
                  action: {
                      type: "Gestures";
                      gestures: (
                          {
                              direction: "None";
                              mode: "OnRelease";
                              action: {
                                  type: "Keypress";
                                  keys: ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_T"];
                              };
                          },
                          {
                              direction: "Up";
                              mode: "OnRelease";
                              action: {
                                  type: "Keypress";
                                  keys: ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_F"];
                              };
                          },
                          {
                              direction: "Down";
                              mode: "OnRelease";
                              action: {
                                  type: "Keypress";
                                  keys: ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_DOWN"];
                              };
                          },
                          {
                              direction: "Left";
                              mode: "OnRelease";
                              action: {
                                  type: "Keypress";
                                  keys: ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_LEFT"];
                              };
                          },
                          {
                              direction: "Right";
                              mode: "OnRelease";
                              action: {
                                  type: "Keypress";
                                  keys: ["KEY_LEFTMETA", "KEY_LEFTSHIFT", "KEY_RIGHT"];
                              };
                          }
                      );
                  };
              },
              // Back button — previous workspace
              {
                  cid: 0x53;
                  action: {
                      type: "Keypress";
                      keys: ["KEY_LEFTMETA", "KEY_LEFTBRACE"];
                  };
              },
              // Forward button — next workspace
              {
                  cid: 0x56;
                  action: {
                      type: "Keypress";
                      keys: ["KEY_LEFTMETA", "KEY_RIGHTBRACE"];
                  };
              },
              // Mode button — cycles DPI 800/1600/3200
              {
                  cid: 0xc4;
                  action: {
                      type: "CycleDPI";
                      dpis: [800, 1600, 3200];
                      sensor: 0;
                  };
              }
          );
      }
      );
    '';
  };
}
