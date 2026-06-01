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

  # YubiKey PAM U2F (sudo + login) — enroll with: pamu2fcfg | sudo tee /etc/security/u2f_keys
  security.pam.u2f = {
    enable              = true;
    settings.cue        = true;
    settings.authFile   = "/etc/security/u2f_keys";
  };

  # Fingerprint PAM auth for login, sudo, and polkit
  # mkForce needed: gdm.nix sets login.fprintAuth = false
  security.pam.services.login.fprintAuth    = lib.mkForce true;
  security.pam.services.sudo.fprintAuth     = lib.mkForce true;
  security.pam.services.polkit-1.fprintAuth = lib.mkForce true;

  # Smartcard daemon (required for YubiKey PIV/FIDO2)
  services.pcscd.enable = true;

  # Goodix fingerprint reader — nixos-hardware already sets tod.enable + tod.driver
  # for the Dell XPS 13 9310. We previously forced tod.enable = false because the
  # driver was unavailable; now it's in nixpkgs so just enable fprintd and let
  # nixos-hardware handle the rest.
  # After rebuild: fprintd-enroll -f right-index-finger tom
  services.fprintd.enable = true;

  # GNOME keyring for libsecret (git credentials, etc.)
  # SSH agent component disabled — 1Password handles SSH via ~/.1password/agent.sock
  services.gnome.gnome-keyring.enable = true;
  programs.ssh.startAgent = false;

  environment.systemPackages = with pkgs; [
    age
    yubikey-manager
    yubikey-personalization
  ];
}
