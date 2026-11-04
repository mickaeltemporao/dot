#!/usr/bin/env python3
"""
html2markdown.py: High-fidelity HTML-to-Markdown email renderer for NeoMutt.
Preserves French accents, handles varied encodings (UTF-8, ISO-8859-1, Windows-1252),
cleans HTML tables into aligned ASCII, and ensures URLs stay unbroken on single lines.
"""

import sys
import os
import re
import codecs

try:
    import html2text
except ImportError:
    # If html2text is missing, exit 1 to trigger mailcap fallback (e.g. w3m)
    sys.exit(1)


def decode_html_bytes(data: bytes, hint_charset: str = None) -> str:
    """Intelligently decode raw HTML bytes across email encodings."""
    candidates = []

    # 1. MIME charset hint from NeoMutt
    if hint_charset:
        c = hint_charset.strip().lower().strip("\"'")
        if c and c not in ("us-ascii", "ascii", "unknown-8bit", "x-unknown"):
            try:
                codecs.lookup(c)
                candidates.append(c)
            except LookupError:
                pass

    # 2. Check HTML <meta> tags in first 2KB
    head = data[:2048]
    meta_match = re.search(rb"""<meta[^>]+charset=['"]?([a-zA-Z0-9_\-]+)""", head, re.I)
    if meta_match:
        m_enc = meta_match.group(1).decode("ascii", errors="ignore").lower()
        if m_enc not in ("us-ascii", "ascii"):
            try:
                codecs.lookup(m_enc)
                if m_enc not in candidates:
                    candidates.append(m_enc)
            except LookupError:
                pass

    # 3. Always test UTF-8 as preferred modern standard
    if "utf-8" not in candidates:
        candidates.append("utf-8")

    # 4. European email standard fallbacks (Windows-1252 is a superset of ISO-8859-1 / Latin1)
    for fb in ("windows-1252", "iso-8859-15"):
        if fb not in candidates:
            candidates.append(fb)

    # Attempt strict decoding in priority order
    for enc in candidates:
        try:
            return data.decode(enc)
        except (UnicodeDecodeError, LookupError):
            continue

    # Final resilient fallback
    return data.decode("utf-8", errors="replace")


def main():
    hint_charset = None
    if len(sys.argv) > 2 and sys.argv[2]:
        hint_charset = sys.argv[2]

    # Read from file argument or stdin
    if len(sys.argv) > 1 and sys.argv[1] != "-":
        filepath = os.path.expanduser(sys.argv[1])
        try:
            with open(filepath, "rb") as f:
                raw_bytes = f.read()
        except OSError:
            sys.exit(1)
    else:
        raw_bytes = sys.stdin.buffer.read()

    decoded_html = decode_html_bytes(raw_bytes, hint_charset)

    # Configure html2text
    h = html2text.HTML2Text()
    h.body_width = 0                 # Never break lines arbitrarily
    h.unicode_snob = True           # Keep Unicode accents intact (é, è, à, ç, ô, etc.)
    h.dash_unordered_list = True    # Use '-' for lists
    h.pad_tables = True             # Align tables neatly
    h.wrap_links = False            # Never wrap URLs across lines
    h.images_to_alt = True          # Display [alt text] rather than giant image URLs
    h.backquote_code_style = True   # Code blocks using ```

    rendered_markdown = h.handle(decoded_html)

    # Output strictly UTF-8 bytes to stdout
    sys.stdout.buffer.write(rendered_markdown.encode("utf-8", errors="replace"))


if __name__ == "__main__":
    main()
