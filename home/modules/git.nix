{ ... }:

{
  programs.git = {
    enable    = true;
    userName  = "Tom Erskine";
    userEmail = "erskine.tom@gmail.com";

    delta = {
      enable  = true;
      options = {
        navigate    = true;   # n/N to move between diff sections
        side-by-side = true;
        line-numbers = true;
      };
    };

    extraConfig = {
      # libsecret stores credentials in GNOME keyring
      credential.helper = "libsecret";

      # GitHub CLI as the credential helper for github.com and gist.github.com
      "credential \"https://github.com\"".helper =
        "!/run/current-system/sw/bin/gh auth git-credential";
      "credential \"https://gist.github.com\"".helper =
        "!/run/current-system/sw/bin/gh auth git-credential";

      merge.conflictstyle = "diff3";
      diff.colorMoved     = "default";
    };
  };
}
