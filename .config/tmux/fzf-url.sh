#!/usr/bin/env bash
# ==============================================================================
# Cross-Platform tmux URL Picker (macOS & Linux)
# Grabs all URLs visible on the active tmux pane and opens them via fzf.
# Intelligently reassembles URLs split across lines by terminal word wrapping.
# ==============================================================================

# 1. Grab strictly the currently visible screen (no old scrollback history)
# Process with Python to accurately unwrap split URLs and clean punctuation
URLS=$(tmux capture-pane -J -p | python3 -c '
import sys
import re

content = sys.stdin.read()

# 1. Reassemble URLs that were hard-wrapped or line-split by w3m/terminal
# Matches http(s)://... ending at end of line followed immediately by continuation characters on the next line
unwrapped = re.sub(
    r"(https?://[^\s<>\"\x27]+)\n\s*([a-zA-Z0-9_\-.~%?&=+#/]+)",
    r"\1\2",
    content
)

# 2. Extract all URLs
pattern = r"(https?|ftp|file)://[a-zA-Z0-9+&@#/%?=~_|!:,.;\-]+[a-zA-Z0-9+&@#/%=~_|\-]"
raw_matches = re.finditer(pattern, unwrapped)

seen = set()
for m in raw_matches:
    url = m.group(0)
    # Strip common trailing punctuation/delimiters
    url = re.sub(r"[.,;:)>\]\x27\"]+$", "", url)
    if url not in seen:
        seen.add(url)
        print(url)
')

if [ -z "$URLS" ]; then
    tmux display-message "tmux: No URLs found on screen."
    exit 0
fi

# 2. Determine open and copy commands (cross-platform macOS & Linux)
OPEN_CMD="xdg-open"
COPY_CMD="xclip -in -selection clipboard"

if command -v open >/dev/null 2>&1; then
    OPEN_CMD="open"
elif [ -n "$BROWSER" ]; then
    OPEN_CMD="$BROWSER"
fi

if command -v pbcopy >/dev/null 2>&1; then
    COPY_CMD="pbcopy"
elif command -v wl-copy >/dev/null 2>&1; then
    COPY_CMD="wl-copy"
elif command -v xsel >/dev/null 2>&1; then
    COPY_CMD="xsel --clipboard --input"
fi

# 3. Write URLs to a temporary file
TMP_URLS=$(mktemp /tmp/tmux_urls.XXXXXX)
echo "$URLS" > "$TMP_URLS"

# 4. Display sleek tmux popup running fzf
tmux display-popup -E -w 80% -h 14 -b rounded \
    -T " Follow URL (Enter: Open in Browser | Ctrl+Y: Copy | Esc: Cancel) " \
    "fzf --reverse --cycle --prompt='URL > ' \
         --bind \"ctrl-y:execute-silent(printf '%s' {} | $COPY_CMD)+abort\" \
         < '$TMP_URLS' | while read -r url; do [ -n \"\$url\" ] && $OPEN_CMD \"\$url\"; done; rm -f '$TMP_URLS'"
