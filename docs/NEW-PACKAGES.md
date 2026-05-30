# New Packages

Tools added to this configuration beyond the initial install. Installed via Home Manager unless noted.

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
| `delta` | Better diff viewer; configured as git's pager via `programs.git.delta`. Features: side-by-side diffs, line numbers, `n`/`N` navigation between hunks. lazygit uses it automatically. |

---

## Development Workflow

| Package | Command | Description |
|---|---|---|
| `direnv` + `nix-direnv` | automatic on `cd` | Per-directory env vars activated on `cd`. Add a `shell.nix` or `flake.nix` to a project and `direnv allow` once — the right toolchain loads and unloads automatically. |
| `just` | `just` | Simpler `make` alternative for project task runners. Write a `justfile` with recipes like `just build`, `just test`, `just fmt`. |
| `tokei` | `tokei` | Counts lines of code broken down by language. Run in any repo for a quick overview. |
| `hyperfine` | `hyperfine` | CLI benchmarking tool. Useful for Rust perf work: `hyperfine 'cargo run --release'`. |
| `lazysql` | `lazysql` | TUI client for SQL databases (Postgres, MySQL, SQLite). Same laziness as lazygit/lazydocker. |

---

## Data & Config Wrangling

| Package | Command | Description |
|---|---|---|
| `yq-go` | `yq` | Like `jq` but for YAML and TOML. Same query syntax as `jq`. Pairs well with the existing `jq` for JSON. |
| `fx` | `fx` | Interactive JSON explorer in the terminal. Pipe JSON into it: `cat data.json \| fx`. |

---

## System & Network

| Package | Command | Description |
|---|---|---|
| `lsof` | `lsof` | List open files, sockets, and ports by process. System package. Essential for debugging port conflicts and open file handles. |
| `bandwhich` | `bandwhich` | Shows network usage broken down by process and remote connection in real time. Requires sudo. |
| `procs` | `procs` | Better `ps` with colour, search, and tree view. `procs firefox` to find a process, `procs --tree` for parent/child view. |

---

## Media

| Package | Command | Description |
|---|---|---|
| `yt-dlp` | `yt-dlp` | Download video and audio from YouTube and hundreds of other sites. Pairs with the existing `mpv`: `mpv $(yt-dlp -g URL)` to stream without saving. |
| `ffmpeg` | `ffmpeg` | Video and audio processing. Useful for converting formats, trimming clips, extracting audio. |

---

## TUI Apps

| Package | Command | Description |
|---|---|---|
| `ncspot` | `ncspot` | Spotify TUI client. Keyboard-driven and much faster than the GUI for browsing and queuing. |

---

## Shell Aliases Added

```zsh
ls   → eza
ll   → eza -l
la   → eza -la
tree → eza --tree
```
