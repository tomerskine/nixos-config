# New Packages

Tools added to this configuration beyond the initial install. Installed via Home Manager unless noted.

---

## Shell & Terminal Productivity

| Package | Command | Description |
|---|---|---|
| `atuin` | `Ctrl+R` | Replaces shell history with a searchable SQLite database. `Ctrl+R` becomes dramatically better. Can sync history across machines. Configured via `programs.atuin`. |
| `zellij` | `zellij` | Modern terminal multiplexer with a more approachable UX than tmux, built-in layouts, and a plugin system. Configured via `programs.zellij`. |
| `noti` | `noti` | Sends a desktop notification when a command finishes. Usage: `nixos-switch; noti` or `noti sleep 10`. |
| `pueue` | `pueue` | Background task queue manager. Run commands in the background, view them, retry failures. Daemon (`pueued`) managed via `services.pueue`. |
| `mprocs` | `mprocs` | Run multiple processes in a single TUI with individual output panes. Useful for running a dev server, watcher, and tests simultaneously. |
| `watchexec` | `watchexec` | Rerun a command on file change. `watchexec -e py pytest` reruns pytest whenever a `.py` file changes. |
| `fastfetch` | `fastfetch` | Fast system info display (neofetch successor). |

---

## Editors

| Package | Command | Description |
|---|---|---|
| `helix` | `hx` | Modern modal editor with built-in LSP and tree-sitter, zero config needed. Worth trying even as a VS Code user — great for quick terminal edits. Configured via `programs.helix`. |
| `neovim` | `nvim` | Available alongside `vim`. Configured via `programs.neovim`. |

---

## File Navigation & Search

| Package | Command | Description |
|---|---|---|
| `eza` | `ls`, `ll`, `la`, `tree` | Modern `ls` replacement with icons, git status, and tree view. Replaces the `ls --color=auto` alias. |
| `yazi` | `yazi` | Terminal file manager written in Rust. Has native image preview in kitty via the kitty protocol. |
| `fd` | `fd` | Better `find` — faster and with saner syntax (e.g. `fd pattern` instead of `find . -name '*pattern*'`). |
| `ripgrep` | `rg` | Faster grep with sane defaults; respects `.gitignore` automatically. Essential for code search. |
| `bat` | `bat` | `cat` with syntax highlighting and line numbers. Integrates with fzf's preview pane automatically. |
| `glow` | `glow` | Renders markdown in the terminal. Useful for reading READMEs without leaving the shell. |

---

## Git

| Package | Notes |
|---|---|
| `delta` | Better diff viewer; configured as git's pager via `programs.delta`. Features: side-by-side diffs, line numbers, `n`/`N` navigation between hunks. lazygit uses it automatically. |

---

## Development Workflow

| Package | Command | Description |
|---|---|---|
| `direnv` + `nix-direnv` | automatic on `cd` | Per-directory env vars activated on `cd`. Add a `shell.nix` or `flake.nix` to a project and `direnv allow` once — the right toolchain loads and unloads automatically. |
| `just` | `just` | Simpler `make` alternative for project task runners. Write a `justfile` with recipes like `just build`, `just test`, `just fmt`. |
| `tokei` | `tokei` | Counts lines of code broken down by language. Run in any repo for a quick overview. |
| `hyperfine` | `hyperfine` | CLI benchmarking tool: `hyperfine 'python script.py'`. |
| `lazysql` | `lazysql` | TUI client for SQL databases (Postgres, MySQL, SQLite). Same laziness as lazygit/lazydocker. |

---

## Data & Config Wrangling

| Package | Command | Description |
|---|---|---|
| `yq-go` | `yq` | Like `jq` but for YAML and TOML. Same query syntax as `jq`. Pairs well with the existing `jq` for JSON. |
| `fx` | `fx` | Interactive JSON explorer in the terminal. Pipe JSON into it: `cat data.json \| fx`. |

---

## System & Network Monitoring

| Package | Command | Description |
|---|---|---|
| `lsof` | `lsof` | List open files, sockets, and ports by process. System package. Essential for debugging port conflicts and open file handles. |
| `bandwhich` | `bandwhich` | Shows network usage broken down by process and remote connection in real time. Requires sudo. |
| `procs` | `procs` | Better `ps` with colour, search, and tree view. `procs python` to find a process, `procs --tree` for parent/child view. |

---

## Network & HTTP

| Package | Command | Description |
|---|---|---|
| `xh` | `xh` | Friendlier curl/httpie clone written in Rust. `xh get httpbin.org/json`, `xh post api.example.com key=value`. |
| `doggo` | `doggo` | Better `dig` with colour output and DNS-over-HTTPS support. `doggo example.com`, `doggo example.com MX`. |
| `gping` | `gping` | Ping with a live terminal graph. `gping google.com`. |
| `trippy` | `trip` | Combines traceroute and ping into a single TUI. Good for diagnosing network paths and packet loss. |

---

## Document Processing

| Package | Command | Description |
|---|---|---|
| `pandoc` | `pandoc` | Universal document converter. `pandoc README.md -o README.pdf`, `pandoc notes.md -o notes.docx`. |
| `qrencode` | `qrencode` | Generate QR codes from the terminal. `qrencode -t UTF8 'https://example.com'`. |

---

## Terminal Recording & Presentations

| Package | Command | Description |
|---|---|---|
| `asciinema` | `asciinema` | Record terminal sessions as lightweight text files. Share at asciinema.org or embed in docs. |
| `vhs` | `vhs` | Write a script of keystrokes and terminal commands, get a GIF back. Great for documenting CLI tools. |
| `presenterm` | `presenterm` | Markdown-driven terminal presentations with syntax highlighting and image support (kitty-native). |

---

## Media

| Package | Command | Description |
|---|---|---|
| `yt-dlp` | `yt-dlp` | Download video and audio from YouTube and hundreds of other sites. Pairs with `mpv`: `mpv $(yt-dlp -g URL)` to stream without saving. |
| `ffmpeg` | `ffmpeg` | Video and audio processing. Useful for converting formats, trimming clips, extracting audio. |
| `ncspot` | `ncspot` | Spotify TUI client. Keyboard-driven and much faster than the GUI for browsing and queuing. |

---

## Shell Aliases Added

```zsh
ls   → eza
ll   → eza -l
la   → eza -la
tree → eza --tree
```
