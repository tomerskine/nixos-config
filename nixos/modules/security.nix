{ pkgs, ... }:

{
  security.sudo.enable            = true;
  security.sudo.wheelNeedsPassword = true;

  # 1Password — CLI + GUI with polkit integration
  programs._1password.enable = true;
  programs._1password-gui = {
    enable                 = true;
    polkitPolicyOwners     = [ "tom" ];
  };

  # YubiKey PAM U2F (sudo + login)
  security.pam.u2f = {
    enable        = true;
    settings.cue  = true;
  };

  # Smartcard daemon (required for YubiKey PIV/FIDO2)
  services.pcscd.enable = true;

  # Goodix fingerprint reader (USB 27c6:533c — run `fprintd-enroll` after first login)
  # TOD (Touch-on-Display) driver required for this specific Goodix sensor variant.
  # (nixos-hardware.nixosModules.dell-xps-13-9310 also sets these — explicit here for clarity.)
  services.fprintd.enable          = true;
  services.fprintd.tod.enable      = true;
  services.fprintd.tod.driver      = pkgs.libfprint-2-tod1-goodix;

  # GNOME keyring for libsecret (git credentials, etc.)
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    age
    yubikey-manager
    yubikey-personalization
  ];
}
