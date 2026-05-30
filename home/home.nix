{ pkgs, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/waybar.nix
    ./modules/git.nix
  ];

  home.username    = "tom";
  home.homeDirectory = "/home/tom";
  home.stateVersion  = "25.05";

  nixpkgs.config.allowUnfree = true;

  home.packages = with pkgs; [
    # Development tools
    github-cli
    lazygit
    lazydocker
    lazysql
    # lazyssh     # check if in nixpkgs; install manually if not
    cmake
    nodejs
    python3
    uv
    rustup
    just        # command runner (simpler make alternative)
    tokei       # count lines of code by language
    hyperfine   # CLI benchmarking

    # Container tools (podman is enabled system-wide; desktop + CLI helpers here)
    podman-compose
    podman-desktop

    # Editors / IDEs
    vscode   # unfree

    # CLI utilities
    btop
    htop
    tmux
    stow
    chezmoi
    duf
    dust
    ncdu

    # File navigation & search
    eza         # modern ls with icons and git status
    yazi        # terminal file manager with kitty image preview
    fd          # faster, friendlier find
    ripgrep     # faster grep with sane defaults
    bat         # cat with syntax highlighting (integrates with fzf preview)
    glow        # render markdown in the terminal

    # Data wrangling
    yq-go       # like jq but for YAML and TOML
    fx          # interactive JSON explorer

    # System & network monitoring
    bandwhich   # network usage broken down by process
    procs       # better ps with colour and tree view

    # Media
    mpv
    spotify   # unfree
    yt-dlp    # download YouTube/etc. video and audio
    ffmpeg    # video/audio processing

    # Apps
    chromium
    obsidian  # unfree
    steam     # managed system-wide via programs.steam, but listed for awareness
    ncspot    # Spotify TUI client

    # Remote access
    wayvnc
    weylus
    rustdesk

    # Security
    _1password-cli  # unfree; GUI managed at system level

    # Fonts
    nerd-fonts.jetbrains-mono
    noto-fonts
    noto-fonts-cjk-sans

    # GNOME extras (useful even in Hyprland session)
    gnome-calculator
    gnome-system-monitor

    # Miscellaneous
    wget
    jq
    fzf   # also configured via programs.fzf in shell.nix
  ];

  # direnv with nix-direnv: auto-load per-project environments on cd
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };

  # GTK theming (matches current nwg-look settings)
  gtk = {
    enable = true;
    theme = {
      name    = "Adwaita-dark";
      package = pkgs.gnome-themes-extra;
    };
    iconTheme = {
      name    = "Adwaita";
      package = pkgs.adwaita-icon-theme;
    };
    font = {
      name = "Adwaita Sans";
      size = 11;
    };
    cursorTheme = {
      name = "default";
      size = 24;
    };
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4.extraConfig.gtk-application-prefer-dark-theme = 1;
  };

  # XDG user directories
  xdg = {
    enable           = true;
    userDirs.enable  = true;
    userDirs.createDirectories = true;
  };

  programs.home-manager.enable = true;
}
