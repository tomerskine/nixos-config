{ pkgs, config, ... }:

{
  programs.zsh = {
    enable = true;
    dotDir = config.home.homeDirectory;  # keep dotfiles in ~ (pin legacy default)

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

  # fzf (fuzzy finder) — Ctrl+T previews files with bat, Alt+C previews dirs with eza
  programs.fzf = {
    enable               = true;
    enableZshIntegration = true;
    defaultCommand       = "fd --type f --hidden --follow --exclude .git";
    fileWidgetCommand    = "fd --type f --hidden --follow --exclude .git";
    fileWidgetOptions    = [ "--preview 'bat --color=always --style=numbers --line-range=:200 {}'" ];
    changeDirWidgetCommand  = "fd --type d --hidden --follow --exclude .git";
    changeDirWidgetOptions  = [ "--preview 'eza --tree --level=2 --color=always {}'" ];
  };

  # Place the existing starship config verbatim
  xdg.configFile."starship.toml".source = ../files/starship.toml;
}
