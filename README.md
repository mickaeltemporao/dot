# Dotfiles (`~/.dot`)

Minimalist, modular, and security-hardened Linux configuration. Tracked using a bare Git repository with `$HOME` as the working tree.

---

## Architecture & Toolchain

- **Shell**: Modular Bash (`~/.config/bash/*.bash` loaded by minimal `~/.bashrc`)
- **Terminal & Multiplexer**: `st` (Simple Terminal) / `tmux`
- **Editor**: Neovim (Modular Lua architecture under `~/.config/nvim/`)
- **Window Manager**: `dwm` / `slstatus` (X11)
- **File Management**: `vifm` (with custom image previewers)
- **Mail & PIM**: NeoMutt, `isync` (`mbsync`), `msmtp`, `davmail`, `khal`, `khard`, `vdirsyncer`
- **Security & Privacy**: Zero secrets in Git. Passwords managed via `pass` (GnuPG). Account configs separated using sanitized `.example` templates with `0600` permissions.
- **Theming & Aesthetics**: **Medallion Dark** — Minimalist, high-contrast theme inspired by NYC Medallion Taxis (deep asphalt `#101214` and taxi yellow `#f5b700`).

---

## Theming & Aesthetics: Medallion Dark

The desktop and CLI environment adhere to the **Medallion Dark** palette. Built on a philosophy of **restraint over noise**, the theme rejects multi-colored visual candy in favor of a nocturnal New York City aesthetic: a deep, non-reflective asphalt canvas (`#101214`) punctuated by functional, high-visibility beacons in NYC Taxi Yellow (`#f5b700`) and Canary Yellow (`#ffd13b`). 90% of the interface (inactive borders, tags, status metrics, comments) recedes into muted slate, directing focus exclusively to active work.

### Master Palette

| Color Name | Hex Code | Category | Core Role & Applied Tools |
| :--- | :--- | :--- | :--- |
| **Deep Asphalt** | `#101214` | Base Canvas | Universal background (`st`, `dwm`, `tmux`, `nvim`, `qutebrowser`, `zathura`, wallpapers) |
| **Night Pavement** | `#16181b` / `#181a1d` | Surface Elevation | Floating menus, statusbar elevation, command bars, constructivist wallpaper slabs |
| **Steel Border** | `#23272e` | Structural Mute | Inactive window borders in `dwm` & `tmux`, split delimiters |
| **Pavement Seam** | `#2c313a` | Visual Selection | Editor visual selection, subtle fills |
| **Dark Slate** | `#484f58` | Dividers & Ticks | Pipe separators (`\|`) in tmux statusline, wallpaper coordinate ticks |
| **Muted Slate** | `#6e7681` | Passive Info | Inactive tags (`dwm`), comments (`nvim`), sysfs status metrics (battery, disk, wifi) |
| **Off-White** | `#e6e8eb` | Primary Text | Foreground text in all terminals, reader text in `zathura` (90% luminance) |
| **Pure White** | `#ffffff` | Critical Foreground | Error badges, high-priority notifications in `dunst` |
| **Medallion Yellow** | `#f5b700` | Signature Hero | Active window borders (`dwm`/`tmux`), active tag (`dwm`), active tab (`qutebrowser`), prompt glyphs |
| **Canary Yellow** | `#ffd13b` | Spotlight Beacon | Terminal cursor (`st`), search match highlights, glowing Glider nodes |
| **Warm Amber** | `#ff9800` | Caution / Warning | Compiler warnings, alert status badges, numeric literals |
| **Subway Green** | `#98c379` | Positive Status | Code strings, git additions, HTTPS security lock, executable files (`vifm`) |
| **Stoplight Red** | `#e06c75` | Critical Alert | Compiler errors, git deletions, battery critical alerts, broken symlinks |
| **Street Sign Blue**| `#61afef` | Structural Logic | Functions, identifiers, directory links |
| **Metro Cyan** | `#56b6c2` | Typographic Accent | Types, operators, technical specifications |
| **Civic Magenta** | `#c678dd` | Control Flow | Keywords, conditionals, imports, macros |

---

## Bootstrapping a New Machine

### 1. Clone the Bare Repository

```bash
# Clone as a bare repository into ~/.dot
git clone --bare git@github.com:mickaeltemporao/cfg.git $HOME/.dot
# (Fallback if SSH keys are not yet configured: https://github.com/mickaeltemporao/cfg.git)

# Define the working alias for the current shell
alias dot='/usr/bin/git --git-dir=$HOME/.dot/ --work-tree=$HOME'

# Backup any pre-existing default dotfiles that would conflict with checkout
mkdir -p $HOME/.dot-backup
dot checkout 2>&1 | grep -E "^\s+\." | awk '{print $1}' | xargs -I{} mv -f {} $HOME/.dot-backup/{}

# Check out the tracked files into $HOME
dot checkout

# Hide untracked files from 'dot status'
dot config --local status.showUntrackedFiles no
```

---

### 2. Install Packages by Platform

#### Option A: Arch Linux (Primary Target)
```bash
# Install core CLI and workstation utilities
sudo pacman -S --needed \
  bash bash-completion git neovim tmux vifm zathura zathura-pdf-mupdf \
  dunst xwallpaper unclutter udiskie xcompmgr fzf pyenv pass gnupg \
  msmtp isync khal vdirsyncer

# Suckless builds (dwm, st, slstatus):
# Recompile from your custom build sources (e.g. ~/Templates/{dwm,st,slstatus})
cd ~/Templates/dwm && sudo make clean install
cd ~/Templates/st && sudo make clean install
cd ~/Templates/slstatus && sudo make clean install
```

#### Option B: Other Linux Distributions (Debian, Ubuntu, Fedora)
The modular Bash, Neovim, tmux, vifm, and PIM configurations adhere strictly to the XDG Base Directory specification and run natively across any Linux distribution:
```bash
# Debian / Ubuntu:
sudo apt update && sudo apt install -y \
  bash git neovim tmux vifm zathura dunst fzf pass gnupg msmtp isync

# Fedora:
sudo dnf install -y \
  bash git neovim tmux vifm zathura dunst fzf pass gnupg msmtp isync
```

#### Option C: macOS (Darwin)
The modular bash scripts and `~/.bashrc` detect macOS and Homebrew automatically (`brew shellenv` and completion integrations):
```bash
# Install Homebrew if not present:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install CLI toolchain:
brew install bash git neovim tmux vifm pass gnupg msmtp isync fzf pyenv

# Set Homebrew Bash as your default user shell:
sudo chsh -s /opt/homebrew/bin/bash $USER
```
*(Note: Linux-only services like `systemd/user`, `dwm`, and `slstatus` are bypassed on macOS, while Neovim, Bash, and tmux function identically).*

---

### 3. Restoring Private Accounts & Services

Private configuration files (`davmail.properties`, `neomutt` accounts, `mbsyncrc`, `msmtp/config`, `vdirsyncer/config`) contain usernames and endpoints and are intentionally excluded from Git.

Choose **Method 1** for manual setup from templates, or **Method 2** for automated transfer.

#### Method 1: Initialize from Templates (`setup-accounts`)
Run the built-in generator script:
```bash
setup-accounts
```
- Copies `.example` files to active configurations with strict `0600` permissions (and `0700` directories).
- Safely skips any file that already exists locally.
- Edit the generated files with your specific endpoints, usernames, and `pass` targets:
  - `~/.config/davmail.properties`
  - `~/.config/isync/mbsyncrc`
  - `~/.config/msmtp/config`
  - `~/.config/neomutt/accounts/work`
  - `~/.config/neomutt/accounts/personal`
  - `~/.config/vdirsyncer/config`

#### Method 2: Encrypted Vault Transfer (Zero-Touch)
If migrating from an existing machine, export your active configurations directly inside an encrypted GPG envelope:

**On the source machine (Export):**
```bash
tar -czf - \
  ~/.config/davmail.properties \
  ~/.config/isync/mbsyncrc \
  ~/.config/msmtp/config \
  ~/.config/vdirsyncer/config \
  ~/.config/neomutt/accounts \
  ~/.config/neomutt/signature_work | gpg -e -r <YOUR-GPG-KEY> -o ~/dotfiles-secrets.tar.gz.gpg
```

**On the new machine (Import):**
```bash
# Decrypt and unpack into root of home directory
gpg -d ~/dotfiles-secrets.tar.gz.gpg | tar -xzf - -C /

# Enforce least-privilege permissions
chmod 600 ~/.config/davmail.properties ~/.config/isync/mbsyncrc ~/.config/msmtp/config ~/.config/neomutt/accounts/*
chmod 700 ~/.config/msmtp ~/.config/isync ~/.config/neomutt ~/.config/vdirsyncer
```

---

### 4. Enable User Daemons (Linux only)

Enable background Exchange gateway and automatic mailbox synchronization timers:
```bash
systemctl --user daemon-reload
systemctl --user enable --now davmail.service
systemctl --user enable --now mbsync.timer
```

---

## Daily Dotfiles Workflow

All dotfiles management is executed through the `dot` alias (defined in `~/.config/bash/20-aliases.bash`):

```bash
# Check status
dot status

# Stage specific configuration files only (never 'dot add .')
dot add .config/nvim/init.lua

# Commit and push
dot commit -m "feat: update neovim settings"
dot push
```
