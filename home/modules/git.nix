{ ... }:

{
  programs.git = {
    enable    = true;
    userName  = "Tom Erskine";
    userEmail = "erskine.tom@gmail.com";

    extraConfig = {
      # libsecret stores credentials in GNOME keyring
      credential.helper = "libsecret";

      # GitHub CLI as the credential helper for github.com and gist.github.com
      "credential \"https://github.com\"".helper =
        "!/run/current-system/sw/bin/gh auth git-credential";
      "credential \"https://gist.github.com\"".helper =
        "!/run/current-system/sw/bin/gh auth git-credential";
    };
  };
}
