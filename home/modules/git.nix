{ ... }:

{
  programs.git = {
    enable = true;

    settings = {
      user.name  = "Tom Erskine";
      user.email = "erskine.tom@gmail.com";

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

  programs.delta = {
    enable               = true;
    enableGitIntegration = true;
    options = {
      navigate     = true;   # n/N to move between diff sections
      side-by-side = true;
      line-numbers = true;
    };
  };
}
