#!/bin/bash
# Single-execution parallel mail synchronization script
# Runs once and exits. Relies on systemd timer for recurring execution.

# --- CRITICAL FIX FOR SYSTEMD BACKGROUND EXECUTION ---
# Systemd has a very limited environment. We must manually expose the PATH
# and load your Bash profiles so custom variables (like PASSWORD_STORE_DIR) exist!
# Ensure standard and Homebrew binary paths are available (Linux & macOS)
if [ -d "/opt/homebrew/bin" ]; then
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:$PATH"
fi
export PATH="/usr/local/bin:/usr/bin:/bin:$PATH"
export GPG_TTY=$(tty 2>/dev/null || echo "")
[ -f ~/.bash_profile ] && source ~/.bash_profile
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bashrc ] && source ~/.bashrc
export PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.config/passwords}"
# -----------------------------------------------------

CONFIG_FILE="$HOME/.config/isync/mbsyncrc"

# Portable timeout wrapper (GNU timeout, gtimeout on macOS, or direct execution)
run_timeout() {
    if command -v timeout >/dev/null 2>&1; then
        timeout -k 15s 180s "$@"
    elif command -v gtimeout >/dev/null 2>&1; then
        gtimeout -k 15s 180s "$@"
    else
        "$@"
    fi
}

echo "Starting parallel mail sync..."

echo "[$(date)] Syncing Work..."
run_timeout mbsync -c "$CONFIG_FILE" work &
PID_WORK=$!

echo "[$(date)] Syncing Personal..."
run_timeout mbsync -c "$CONFIG_FILE" personal &
PID_PERSONAL=$!

# Wait for both background jobs to finish
wait $PID_WORK
wait $PID_PERSONAL

# Flush any pending offline/queued outbound emails
python3 ~/.config/neomutt/smart_sendmail.py --flush >/dev/null 2>&1 &

echo "[$(date)] Mail sync complete!"

