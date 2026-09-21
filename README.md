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
