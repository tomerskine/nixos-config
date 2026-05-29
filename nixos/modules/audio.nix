{ pkgs, ... }:

{
  # PipeWire replaces PulseAudio — provides Pulse, ALSA, and JACK compat layers
  services.pipewire = {
    enable            = true;
    alsa.enable       = true;
    alsa.support32Bit = true;  # for Steam and 32-bit apps
    pulse.enable      = true;
    jack.enable       = true;
    wireplumber.enable = true;
  };

  hardware.pulseaudio.enable = false;

  # Real-time scheduling for audio — required by PipeWire
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    pavucontrol
    pulseaudio
  ];
}
