{ pkgs, lib, ... }:

{
  imports = [
    ./modules/shell.nix
    ./modules/helix.nix
    ./modules/hyprland.nix
    ./modules/kitty.nix
    ./modules/waybar.nix
    ./modules/git.nix
  ];

  home.username    = "tom";
  home.homeDirectory = "/home/tom";
  home.stateVersion  = "25.05";

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
    noti        # desktop notification when a command finishes: `nixos-switch; noti`
    watchexec   # rerun a command on file change (generic entr alternative)
    mprocs      # run multiple processes in a single TUI with per-process output panes
    fastfetch   # fast system info display (neofetch successor)

    # File navigation & search
    eza         # modern ls with icons and git status
    yazi        # terminal file manager with kitty image preview
    fd          # faster, friendlier find
    ripgrep     # faster grep with sane defaults
    glow        # render markdown in the terminal

    # Data wrangling
    yq-go       # like jq but for YAML and TOML
    fx          # interactive JSON explorer

    # System & network monitoring
    bandwhich   # network usage broken down by process
    procs       # better ps with colour and tree view

    # Network & HTTP
    xh          # friendlier curl/httpie: `xh get httpbin.org/json`
    doggo       # better dig with colour and DoH support
    gping       # ping with a live terminal graph
    trippy      # traceroute + ping combined into a TUI (command: trip)

    # Document processing
    pandoc      # universal document converter (markdown → PDF, DOCX, HTML, etc.)
    qrencode    # generate QR codes from the terminal

    # Terminal recording & presentations
    asciinema   # record terminal sessions as shareable text files
    vhs         # write a script of keystrokes, get a GIF back
    presenterm  # markdown-driven terminal presentations with images (kitty-native)

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

  # yt-dlp config
  xdg.configFile."yt-dlp/config".text = ''
    # Output
    -o ~/yt/%(title)s [%(id)s].%(ext)s

    # Best quality, prefer MP4 to avoid re-encoding
    -f bestvideo[ext=mp4]+bestaudio[ext=m4a]/bestvideo+bestaudio/best
    --merge-output-format mp4

    # SponsorBlock: silently remove sponsored segments, self-promo, and interaction reminders
    --sponsorblock-remove sponsor,selfpromo,interaction

    # Subtitles: English, prefer manual over auto-generated, embed in file
    --write-subs
    --write-auto-subs
    --sub-langs en
    --embed-subs

    # Metadata
    --embed-thumbnail
    --embed-metadata
    --embed-chapters

    # Safety: don't silently download an entire playlist when given a single video URL
    # Use --yes-playlist explicitly when you want a full playlist
    --no-playlist
  '';

  # bat: syntax-highlighted cat, Dracula theme, wired into fzf preview
  programs.bat = {
    enable = true;
    config = {
      theme  = "Dracula";
      style  = "numbers,changes,header-filename";
      pager  = "less -FR";
      italic-text = "always";
    };
  };

  # direnv with nix-direnv: auto-load per-project environments on cd
  programs.direnv = {
    enable            = true;
    nix-direnv.enable = true;
  };

  # atuin recreates its config on every shell start via the zsh hook,
  # so force = true is needed to let home-manager own the file.
  xdg.configFile."atuin/config.toml".force = lib.mkForce true;

  # atuin: searchable, syncable shell history (replaces Ctrl+R)
  programs.atuin = {
    enable               = true;
    enableZshIntegration = true;
    settings = {
      sync_address   = "http://omv:8000";
      auto_sync      = true;
      sync_frequency = "5m";
      search_mode    = "fuzzy";
      filter_mode    = "global";  # search across all hosts
      style          = "compact";
      show_help      = false;
      enter_accept   = true;      # Enter runs immediately; Tab puts in prompt for editing
      sync.records   = true;      # sync v2
    };
  };

  # zellij: modern terminal multiplexer
  programs.zellij.enable = true;

  # neovim: available as nvim alongside vim
  programs.neovim = {
    enable      = true;
    withRuby    = false;  # adopt new default; no Ruby plugins needed
    withPython3 = true;   # keep Python3 support for Python-based plugins
  };

  # pueue: background task queue daemon (client: pueue, daemon: pueued)
  services.pueue.enable = true;

  # mako: Wayland notification daemon (config from Arch chezmoi backup)
  services.mako = {
    enable          = true;
    font            = "JetBrainsMono Nerd Font 11";
    backgroundColor = "#1a1a1aff";
    textColor       = "#ffffffff";
    borderColor     = "#2980b9ff";
    borderSize      = 2;
    borderRadius    = 8;
    width           = 350;
    height          = 150;
    margin          = "8";
    padding         = "10,15";
    icons           = true;
    maxIconSize     = 48;
    markup          = true;
    actions         = true;
    format          = "<b>%s</b>\\n%b";
    defaultTimeout  = 5000;
    ignoreTimeout   = true;
    layer           = "overlay";
    anchor          = "top-right";
    extraConfig = ''
      outer-margin=10
      text-alignment=left
      icon-border-radius=4
      group-by=app-name
      max-visible=5
      history=1
      max-history=10
      sort=-time

      on-button-left=invoke-default-action
      on-button-middle=dismiss-all
      on-button-right=dismiss

      [mode=do-not-disturb]
      invisible=1

      [urgency=low]
      border-color=#64727dff
      default-timeout=5000

      [urgency=normal]
      border-color=#2980b9ff
      default-timeout=5000

      [urgency=critical]
      background-color=#c0392bff
      border-color=#e74c3cff
      default-timeout=0
    '';
  };

  # Cursor theme — propagates to Wayland, GTK, and X11
  home.pointerCursor = {
    gtk.enable = true;
    name       = "Adwaita";
    size       = 24;
    package    = pkgs.adwaita-icon-theme;
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
    gtk3.extraConfig.gtk-application-prefer-dark-theme = 1;
    gtk4 = {
      theme = null;  # GTK4/libadwaita ignores external themes; dark mode via extraConfig
      extraConfig.gtk-application-prefer-dark-theme = 1;
    };
  };

  # XDG user directories
  xdg = {
    enable                        = true;
    userDirs.enable               = true;
    userDirs.createDirectories    = true;
    userDirs.setSessionVariables  = false;  # adopt new default (was true pre-26.05)
  };

  programs.home-manager.enable = true;
}
