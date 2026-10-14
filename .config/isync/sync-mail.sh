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
export PATH="$PATH:/usr/local/bin:/usr/bin:/bin"
export GPG_TTY=$(tty 2>/dev/null || echo "")
[ -f ~/.bash_profile ] && source ~/.bash_profile
[ -f ~/.profile ] && source ~/.profile
[ -f ~/.bashrc ] && source ~/.bashrc
export PASSWORD_STORE_DIR="${PASSWORD_STORE_DIR:-$HOME/.config/passwords}"
# -----------------------------------------------------

CONFIG_FILE="$HOME/.config/isync/mbsyncrc"

# Check arguments
MANUAL_NOTIFY=false
for arg in "$@"; do
    if [ "$arg" = "--notify" ] || [ "$arg" = "-n" ]; then
        MANUAL_NOTIFY=true
    fi
done

# Ensure single-instance execution (cross-platform atomic lock)
LOCK_DIR="${XDG_RUNTIME_DIR:-/tmp}/sync-mail.lockdir"
if ! mkdir "$LOCK_DIR" 2>/dev/null; then
    # Check if prior process is still alive
    if [ -f "$LOCK_DIR/pid" ]; then
        OLD_PID=$(cat "$LOCK_DIR/pid" 2>/dev/null || echo "")
        if [ -n "$OLD_PID" ] && kill -0 "$OLD_PID" 2>/dev/null; then
            if [ "$MANUAL_NOTIFY" = true ] && command -v notify-send >/dev/null 2>&1; then
                notify-send -u low -i mail-unread "NeoMutt" "Mail sync is already in progress..."
            fi
            exit 0
        fi
    fi
    # Clear stale lock
    rm -rf "$LOCK_DIR"
    if ! mkdir "$LOCK_DIR" 2>/dev/null; then
        exit 0
    fi
fi
echo $$ > "$LOCK_DIR/pid"
trap 'rm -rf "$LOCK_DIR"' EXIT INT TERM

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

# Sync Contacts (CardDAV via DavMail to local VCF)
if command -v vdirsyncer >/dev/null 2>&1; then
    run_timeout vdirsyncer sync contacts >/dev/null 2>&1 &
fi

# Flush any pending offline/queued outbound emails
python3 ~/.config/neomutt/smart_sendmail.py --flush >/dev/null 2>&1 &

echo "[$(date)] Mail sync complete!"

# Send cross-platform desktop & in-tmux notifications
notify_user() {
    local title="$1"
    local message="$2"
    local urgency="${3:-normal}"

    # 1. In-tmux status bar toast (instant feedback across Linux & macOS)
    if [ -n "$TMUX" ] || tmux info >/dev/null 2>&1; then
        tmux display-message -d 3500 "${title}: ${message}" 2>/dev/null || true
    fi

    # 2. Linux desktop notification (Dunst)
    if command -v notify-send >/dev/null 2>&1; then
        notify-send -u "$urgency" -i mail-unread "$title" "$message"
    fi

    # 3. macOS native Notification Center
    if [ "$(uname)" = "Darwin" ]; then
        osascript -e "display notification \"$message\" with title \"$title\"" 2>/dev/null || true
    fi
}

NEW_COUNT=$(find "$HOME/Mail/work/INBOX/new" "$HOME/Mail/personal/INBOX/new" -type f 2>/dev/null | wc -l)
if [ "$MANUAL_NOTIFY" = true ]; then
    if [ "$NEW_COUNT" -gt 0 ]; then
        notify_user "NeoMutt" "Sync complete: $NEW_COUNT new email(s)" "normal"
    else
        notify_user "NeoMutt" "Sync complete: No new email" "low"
    fi
elif [ "$NEW_COUNT" -gt 0 ]; then
    notify_user "NeoMutt" "$NEW_COUNT new email(s) received" "normal"
fi
