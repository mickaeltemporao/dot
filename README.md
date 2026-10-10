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

## Keybindings & Core Workflows

Workstation keybindings follow a clear ergonomic hierarchy: `Alt` manages the window manager (`dwm`), `Ctrl` handles tmux pane navigation and NeoMutt sidebar movement, and `,` serves as the non-colliding leader for application-level jumps.

### Window Manager (`dwm`) — `MODKEY = Alt`

| Keybinding | Action | Target / Command |
| :--- | :--- | :--- |
| `Alt + Shift + Enter` | Terminal | Standard `st` instance |
| `Alt + Ctrl + Enter` | Tmux Terminal | `st -e tm` (attaches to or starts `main` tmux session) |
| `Alt + Enter` | Zoom Master | Swap focused window with master pane |
| `Alt + j` / `Alt + k` | Focus Stack | Focus next / previous window |
| `Alt + p` | Run Launcher | `fzfexec` |
| `Alt + Shift + p` | Pass Menu | `passmenu` (GPG password selector) |
| `Alt + e` | File Manager | `st -e vifmrun` |
| `Alt + o` | Document Reader | `zathura /tmp/output.pdf` |
| `Alt + n` | Quick Notes | `st -e nvim -c WikiIndex` |
| `Alt + s` | Scratchpad | `scratchpad` toggle |
| `Alt + w` | Browser Bookmarks | `bkmenu` |
| `Alt + Shift + w` | Private Browser | `qutebrowser :open -p` |
| `Alt + b` | Toggle Bar | Show / hide `dwm` top statusbar |
| `Print` / `Alt + Print` | Screenshot | Full screen (`printscreen`) / Area select (`printarea`) |

### Terminal Multiplexer (`tmux`) — `Prefix = Ctrl-a`

| Keybinding | Scope | Action |
| :--- | :--- | :--- |
| `Ctrl-h` / `j` / `k` / `l` | Global | Smart pane navigation (Vim & NeoMutt aware) |
| `Prefix + v` | Window | Split pane horizontally (`-h`, side-by-side) |
| `Prefix + h` | Window | Split pane vertically (`-v`, stacked) |
| `Prefix + c` | Session | Create new window |
| `Prefix + Ctrl-h` / `Ctrl-l` | Session | Cycle previous / next window |
| `Prefix + r` | Session | Reload `~/.config/tmux/tmux.conf` |

### Email Client (`neomutt`)

| Keybinding | Menu / Scope | Action |
| :--- | :--- | :--- |
| `X` or `,x` | Index / Pager | **Dynamic Account Toggle**: Flips between Work $\leftrightarrow$ Personal INBOX |
| `c` | Index / Pager | **Mailbox Browser**: Interactive list of all 8 mailboxes (`j`/`k` + `<Enter>`) |
| `C` | Index / Pager | Native manual path prompt (`<change-folder>`) |
| `Ctrl-j` / `Ctrl-k` | Index / Pager | Navigate sidebar down / up (passes through tmux) |
| `Ctrl-o` | Index / Pager | Open selected sidebar mailbox |
| `B` | Index / Pager | Toggle sidebar visibility |
| `,a` | Index / Pager | Jump to Archive (`Archive` in Work, `[Gmail]/All Mail` in Personal) |
| `,s` | Index / Pager | Jump to Sent (`Sent` in Work, `[Gmail]/Sent Mail` in Personal) |
| `,d` | Index / Pager | Jump to Drafts |
| `,i` | Index / Pager | Jump to current account's INBOX |
| `s` | Index / Pager | Instant Archive email (Work: `=Archive`, Personal: `=[Gmail]/All Mail`) |
| `S` | Index / Pager | Native save/move message prompt (`<save-message>`) |
| `g` / `r` / `R` | Index / Pager | Default reply actions: `g` (reply-all), `r` (reply to sender), `R` (recall draft) |
| `G` | Index / Pager | Force sync all mailboxes (`~/.config/isync/sync-mail.sh`) |
| `H` | Index / Pager | View HTML email part in web browser |
| `I` | Index / Pager | Add `.ics` calendar attachment to Google Calendar |
| `A` | Index / Pager | Add sender to Khard address book |
| `Y` | Compose | Schedule email delivery (inserts pre-filled `X-Send-At` header) |

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
  neomutt msmtp isync khal khard vdirsyncer pamixer bat

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
  bash git neovim tmux vifm zathura dunst fzf pass gnupg neomutt msmtp isync khal khard vdirsyncer

# Fedora:
sudo dnf install -y \
  bash git neovim tmux vifm zathura dunst fzf pass gnupg neomutt msmtp isync khal khard vdirsyncer
```

#### Option C: macOS (Darwin)
The modular bash scripts and `~/.bashrc` detect macOS and Homebrew automatically (`brew shellenv` and completion integrations):
```bash
# Install Homebrew if not present:
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install CLI toolchain:
brew install bash bash-completion@2 git neovim tmux vifm pass gnupg neomutt msmtp isync fzf pyenv bat

# Set Homebrew Bash as your default user shell (macOS ships with outdated Bash 3.2):
sudo sh -c 'echo "$(brew --prefix)/bin/bash" >> /etc/shells'
chsh -s "$(brew --prefix)/bin/bash"
```
*(Note: Linux-only components such as `systemd/user`, `dwm`, `st`, `slstatus`, `xrandr`, and direct sysfs battery/backlight readers in `status.sh` are bypassed on macOS, while Neovim, Bash, tmux, vifm, and NeoMutt function identically).*

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
If migrating from an existing machine, export your active configurations directly inside an encrypted GPG envelope. Using `-C "$HOME"` creates relative paths inside the archive (avoiding leading-slash stripping issues):

**On the source machine (Export):**
```bash
tar -czf - -C "$HOME" \
  .config/davmail.properties \
  .config/isync/mbsyncrc \
  .config/msmtp/config \
  .config/vdirsyncer/config \
  .config/neomutt/accounts \
  .config/neomutt/signature_work \
  .config/passwords | gpg -e -r <YOUR-GPG-KEY> -o ~/dotfiles-secrets.tar.gz.gpg
```

**On the new machine (Import):**
```bash
# Decrypt and unpack directly into $HOME
gpg -d ~/dotfiles-secrets.tar.gz.gpg | tar -xzf - -C "$HOME"

# Enforce least-privilege permissions
chmod 600 ~/.config/davmail.properties ~/.config/isync/mbsyncrc ~/.config/msmtp/config ~/.config/neomutt/accounts/*
chmod 700 ~/.config/msmtp ~/.config/isync ~/.config/neomutt ~/.config/vdirsyncer ~/.config/passwords
```

---

### 4. Enable Background Mail Sync & Services

#### Linux (Systemd)
Enable background Exchange gateway and automatic mailbox synchronization timers:
```bash
systemctl --user daemon-reload
systemctl --user enable --now davmail.service
systemctl --user enable --now mbsync.timer
```

#### macOS (Launchd & `setup-mac-mail`)
On macOS, run the automated setup helper to install dependencies and configure a native `launchd` user agent syncing every 60 seconds:
```bash
setup-mac-mail
```
*(This creates and loads `~/Library/LaunchAgents/org.dotfiles.mbsync.plist` executing `~/.config/isync/sync-mail.sh` every 60 seconds).*

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
