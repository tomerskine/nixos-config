{ pkgs, ... }:

{
  hardware.bluetooth = {
    enable       = true;
    powerOnBoot  = true;
    settings.General.Experimental = true;  # matches /etc/bluetooth/main.conf
  };

  # Blueman system tray + manager
  services.blueman.enable = true;

  environment.systemPackages = with pkgs; [
    bluez-tools
    bluetui
  ];
}
