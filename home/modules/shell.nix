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
      # Evaluate the full NixOS config without building — fast sanity check (~5s)
      nixos-eval   = "nix eval '/etc/nixos#nixosConfigurations.nixos9310.config.system.build.toplevel.drvPath'";
      # Show what would be fetched/built without actually building it
      nixos-dry    = "nix build '/etc/nixos#nixosConfigurations.nixos9310.config.system.build.toplevel' --dry-run --no-link";
    };

    initContent = ''
      export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

      # Format, lint, and evaluate the NixOS flake without building.
      # Applies nix fmt + statix fixes in-place, then checks for dead code
      # and evaluates the full config. Safe to run repeatedly.
      nix-chk() {
        (
          cd /etc/nixos &&
          echo "==> fmt (check)" && nix fmt -- --check $(git ls-files '*.nix') 2>&1 || echo "  ↳ formatting issues found — run 'nix fmt' to fix" &&
          echo "==> statix fix" && statix fix . &&
          echo "==> deadnix" && deadnix . &&
          echo "==> nix flake check" && nix flake check --no-build
        ) && echo "\n✓ All checks passed"
      }

      # Run all checks (nix-chk) and, only if they pass, rebuild + switch.
      nrs() {
        nix-chk && sudo nixos-rebuild switch --flake /etc/nixos#nixos9310
      }
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
