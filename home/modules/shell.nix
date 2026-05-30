{ pkgs, ... }:

{
  programs.zsh = {
    enable = true;

    oh-my-zsh = {
      enable  = true;
      theme   = "";  # Starship handles the prompt
      plugins = [ "git" "fzf" ];
    };

    # zsh-autosuggestions and zsh-syntax-highlighting from nixpkgs
    plugins = [
      {
        name = "zsh-autosuggestions";
        src  = pkgs.zsh-autosuggestions;
        file = "share/zsh-autosuggestions/zsh-autosuggestions.zsh";
      }
      {
        name = "zsh-syntax-highlighting";
        src  = pkgs.zsh-syntax-highlighting;
        file = "share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh";
      }
    ];

    shellAliases = {
      ls   = "eza";
      ll   = "eza -l";
      la   = "eza -la";
      tree = "eza --tree";
      grep = "grep --color=auto";
      nixos-switch = "sudo nixos-rebuild switch --flake /etc/nixos#nixos9310";
      nixos-test   = "sudo nixos-rebuild test   --flake /etc/nixos#nixos9310";
    };

    initContent = ''
      export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
    '';
  };

  # Starship prompt — existing starship.toml is placed via xdg.configFile
  programs.starship = {
    enable                = true;
    enableZshIntegration  = true;
    # Settings are read from ~/.config/starship.toml (placed in hyprland.nix area)
    settings = { };
  };

  # zoxide (smart cd)
  programs.zoxide = {
    enable               = true;
    enableZshIntegration = true;
  };

  # fzf (fuzzy finder)
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
  };

  # Place the existing starship config verbatim
  xdg.configFile."starship.toml".source = ../files/starship.toml;
}
