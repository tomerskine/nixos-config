_:

{
  programs.ssh = {
    enable = true;

    # 1Password is the default SSH agent for all connections
    extraConfig = "IdentityAgent ~/.1password/agent.sock";

    matchBlocks = {
      "github.com" = {
        user           = "git";
        identityFile   = "~/.ssh/id_ed25519_github";
        identitiesOnly = true;
      };

      "gitea" = {
        hostname       = "omv";
        port           = 3000;
        user           = "git";
        identityFile   = "~/.ssh/id_ed25519_gitea";
        identitiesOnly = true;
      };

      "omv" = {
        hostname = "omv";
        user     = "tom";
        # key provided by 1Password agent via global IdentityAgent
      };
    };
  };
}
