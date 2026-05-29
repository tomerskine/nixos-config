{ config, ... }:

{
  networking.hostName              = "nixos9310";
  networking.networkmanager.enable = true;

  # Intel AX201 WiFi — disable power saving to prevent packet loss and connection
  # drops on resume from s2idle. d0i3_disable=1 stops the deep D0i3 low-power
  # state that causes firmware stalls; uapsd_disable=1 prevents U-APSD buffering
  # issues with some APs.
  boot.extraModprobeConfig = ''
    options iwlwifi power_save=0 d0i3_disable=1 uapsd_disable=1
  '';

  # Tailscale VPN
  services.tailscale.enable            = true;
  services.tailscale.useRoutingFeatures = "client";

  # Firewall — trust the Tailscale interface
  networking.firewall.enable             = true;
  networking.firewall.trustedInterfaces  = [ "tailscale0" ];
  networking.firewall.allowedUDPPorts    = [ config.services.tailscale.port ];
}
