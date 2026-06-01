_:

{
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;

    settings = {
      # 1Password is the default SSH agent for all connections
      "*" = {
        IdentityAgent = "~/.1password/agent.sock";
      };

      "github.com" = {
        User           = "git";
        IdentityFile   = "~/.ssh/id_ed25519_github";
        IdentitiesOnly = "yes";
      };

      "gitea" = {
        Hostname       = "omv";
        Port           = 3000;
        User           = "git";
        IdentityFile   = "~/.ssh/id_ed25519_gitea";
        IdentitiesOnly = "yes";
      };

      "omv" = {
        Hostname = "omv";
        User     = "tom";
      };
    };
  };
}
