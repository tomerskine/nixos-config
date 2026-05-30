{ pkgs, lib, ... }:

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

  # Goodix fingerprint reader — TOD disabled for now.
  # nixos-hardware.nixosModules.dell-xps-13-9310 sets tod.enable = true and
  # tod.driver = pkgs.libfprint-2-tod1-goodix; that package is unavailable in current
  # nixpkgs-unstable and causes a build failure. mkForce false overrides nixos-hardware.
  # Re-enable once the correct driver package is confirmed (run `fprintd-enroll` after).
  services.fprintd.enable     = true;
  services.fprintd.tod.enable = lib.mkForce false;

  # GNOME keyring for libsecret (git credentials, etc.)
  services.gnome.gnome-keyring.enable = true;

  environment.systemPackages = with pkgs; [
    age
    yubikey-manager
    yubikey-personalization
  ];
}
