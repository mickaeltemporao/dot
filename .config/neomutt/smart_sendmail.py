#!/usr/bin/env python3
import sys
import re
import os
import time
import subprocess
import uuid
import glob
from datetime import datetime, timedelta
import email.utils
import dateutil.parser

LOG_FILE = os.path.expanduser("~/.config/neomutt/schedule.log")
QUEUE_DIR = os.path.expanduser("~/.mail_queue")

def log(msg):
    timestamp = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
    line = f"[{timestamp}] {msg}\n"
    sys.stderr.write(line)
    try:
        with open(LOG_FILE, "a", encoding="utf-8") as f:
            f.write(line)
    except Exception:
        pass

def notify(title, msg):
    # In-tmux status bar notification (center display, cross-platform Linux & macOS)
    try:
        text = f"{title}: {msg}"
        subprocess.run(["tmux", "set", "-g", "@notification", text], capture_output=True, check=False)
        subprocess.run(["tmux", "refresh-client", "-S"], capture_output=True, check=False)
        subprocess.run(["tmux", "run-shell", "-b", "sleep 5 && tmux set -gu @notification && tmux refresh-client -S"], capture_output=True, check=False)
    except Exception:
        pass

def get_env():
    env = os.environ.copy()
    home_dir = os.path.expanduser("~")
    pass_dir = os.environ.get("PASSWORD_STORE_DIR", os.path.join(home_dir, ".config/passwords"))
    env["HOME"] = home_dir
    env["PASSWORD_STORE_DIR"] = pass_dir
    brew_bin = "/opt/homebrew/bin"
    if "PATH" not in env:
        env["PATH"] = f"{brew_bin}:/usr/local/bin:/usr/bin:/bin"
    else:
        env["PATH"] = f"{brew_bin}:/usr/local/bin:/usr/bin:/bin:{env['PATH']}"
    return env

def determine_account(raw_email):
    account = "work"
    from_match = re.search(r"^From:\s*(.*)$", raw_email, re.MULTILINE | re.IGNORECASE)
    if from_match and "gmail.com" in from_match.group(1).lower():
        account = "personal"
    return account

def update_email_date(raw_email):
    now_date_str = email.utils.formatdate(localtime=True)
    if re.search(r"^Date:\s*[^\r\n]*", raw_email, flags=re.MULTILINE | re.IGNORECASE):
        return re.sub(r"^Date:\s*[^\r\n]*", f"Date: {now_date_str}", raw_email, count=1, flags=re.MULTILINE | re.IGNORECASE)
    else:
        delim = "\r\n" if "\r\n" in raw_email else "\n"
        return f"Date: {now_date_str}{delim}" + raw_email

def parse_schedule_time(time_str):
    time_str = time_str.strip()
    if not time_str or time_str.lower() in ["default", ""]:
        time_str = "tomorrow 8:00"

    now = datetime.now()

    # 1. Relative offset: "+5m", "in 5 minutes", "10m", "+1h", "in 2 hours", "+1d"
    m_rel = re.match(r"^(?:\+|\bin\s+)?(\d+)\s*(m(?:in(?:ute)?s?)?|h(?:(?:ou)?rs?)?|d(?:ays?)?)$", time_str, re.IGNORECASE)
    if m_rel:
        val = int(m_rel.group(1))
        unit = m_rel.group(2).lower()
        if unit.startswith("m"):
            return now + timedelta(minutes=val)
        elif unit.startswith("h"):
            return now + timedelta(hours=val)
        elif unit.startswith("d"):
            return now + timedelta(days=val)

    # 2. "tomorrow [H]H[:MM] [am|pm]"
    m_tom = re.match(r"^tomorrow(?:\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?)?$", time_str, re.IGNORECASE)
    if m_tom:
        hour = int(m_tom.group(1)) if m_tom.group(1) else 8
        minute = int(m_tom.group(2)) if m_tom.group(2) else 0
        ampm = m_tom.group(3)
        if ampm:
            if ampm.lower() == "pm" and hour < 12:
                hour += 12
            elif ampm.lower() == "am" and hour == 12:
                hour = 0
        return (now + timedelta(days=1)).replace(hour=hour, minute=minute, second=0, microsecond=0)

    # 3. "today [H]H[:MM] [am|pm]"
    m_today = re.match(r"^today\s+(\d{1,2})(?::(\d{2}))?\s*(am|pm)?$", time_str, re.IGNORECASE)
    if m_today:
        hour = int(m_today.group(1))
        minute = int(m_today.group(2)) if m_today.group(2) else 0
        ampm = m_today.group(3)
        if ampm:
            if ampm.lower() == "pm" and hour < 12:
                hour += 12
            elif ampm.lower() == "am" and hour == 12:
                hour = 0
        target = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
        if target < now:
            target += timedelta(days=1)
        return target

    # 4. "[H]H:MM [am|pm]" (e.g. "21:55", "9:55pm")
    m_time = re.match(r"^(\d{1,2}):(\d{2})\s*(am|pm)?$", time_str, re.IGNORECASE)
    if m_time:
        hour = int(m_time.group(1))
        minute = int(m_time.group(2))
        ampm = m_time.group(3)
        if ampm:
            if ampm.lower() == "pm" and hour < 12:
                hour += 12
            elif ampm.lower() == "am" and hour == 12:
                hour = 0
        target = now.replace(hour=hour, minute=minute, second=0, microsecond=0)
        if target < now:
            target += timedelta(days=1)
        return target

    # 5. Fuzzy parser fallback (normalize seconds to 0 if not provided)
    dt = dateutil.parser.parse(time_str, default=now.replace(second=0, microsecond=0))
    if dt < now:
        dt += timedelta(days=1)
    return dt

def flush_queue():
    os.makedirs(QUEUE_DIR, exist_ok=True)
    eml_files = sorted(glob.glob(os.path.join(QUEUE_DIR, "*.eml")))
    if not eml_files:
        return

    now_ts = int(datetime.now().timestamp())
    env = get_env()

    for file_path in eml_files:
        filename = os.path.basename(file_path)
        
        # Check if file is a scheduled mail: mail_<timestamp>_<uuid>.eml
        m_sched = re.match(r"^mail_(\d+)_[a-f0-9]+\.eml$", filename)
        if m_sched:
            sched_ts = int(m_sched.group(1))
            if sched_ts > now_ts:
                # Scheduled for future, leave it
                continue

        # Read content to determine account
        try:
            with open(file_path, "rb") as f:
                raw_bytes = f.read()
            raw_email = raw_bytes.decode("utf-8", errors="surrogateescape")
        except Exception as e:
            log(f"Error reading queued email '{file_path}': {e}")
            continue

        account = determine_account(raw_email)

        # Rewrite Date: header to reflect actual dispatch timestamp
        send_email = update_email_date(raw_email)
        send_bytes = send_email.encode("utf-8", errors="surrogateescape")

        subj_match = re.search(r"^Subject:\s*(.*)$", raw_email, re.MULTILINE | re.IGNORECASE)
        subj_title = f"'{subj_match.group(1).strip()}'" if subj_match and subj_match.group(1).strip() else filename

        # Attempt send via msmtp
        try:
            proc = subprocess.Popen(
                ["msmtp", "-a", account, "-t"],
                stdin=subprocess.PIPE,
                stdout=subprocess.PIPE,
                stderr=subprocess.PIPE,
                env=env
            )
            _, stderr = proc.communicate(input=send_bytes)
            if proc.returncode == 0:
                os.remove(file_path)
                success_msg = f"Sent: {subj_title} ({account})"
                log(f"Queued email sent successfully (Account: {account}, File: {filename}, Subject: {subj_title})")
                notify("NeoMutt Outbox", success_msg)
            else:
                err_text = stderr.decode("utf-8", errors="ignore").strip()
                log(f"Flush retry failed for {filename} (code {proc.returncode}): {err_text}")
                # If network/server is still failing, stop flushing loop
                break
        except Exception as e:
            log(f"Flush exception for {filename}: {e}")
            break

def main():
    if len(sys.argv) > 2 and sys.argv[1] == "--wait-and-flush":
        try:
            target_ts = int(sys.argv[2])
            delay = target_ts - int(datetime.now().timestamp())
            if delay > 0:
                time.sleep(delay)
            flush_queue()
        except Exception as e:
            log(f"Error in --wait-and-flush: {e}")
        sys.exit(0)
    if len(sys.argv) > 1 and sys.argv[1] in ["--flush", "-f", "flush"]:
        flush_queue()
        sys.exit(0)
    if len(sys.argv) > 1 and sys.argv[1] in ["--next-morning", "--schedule-default"]:
        tomorrow = datetime.now() + timedelta(days=1)
        print(tomorrow.strftime("%Y-%m-%d 08:00"))
        sys.exit(0)

    raw_bytes = sys.stdin.buffer.read()
    if not raw_bytes:
        sys.exit(0)
    raw_email = raw_bytes.decode("utf-8", errors="surrogateescape")

    account = determine_account(raw_email)
    env = get_env()

    # Check for X-Send-At header (must have non-empty value)
    send_at_match = re.search(r"^X-Send-At:\s*(.+)$", raw_email, re.MULTILINE | re.IGNORECASE)

    if send_at_match and send_at_match.group(1).strip():
        time_str = send_at_match.group(1).strip()
        # Remove the X-Send-At header line
        clean_email = re.sub(r"^X-Send-At:.+\r?\n?", "", raw_email, flags=re.MULTILINE | re.IGNORECASE)

        try:
            target_dt = parse_schedule_time(time_str)
        except Exception as e:
            err_msg = f"Error parsing schedule time '{time_str}': {e}"
            log(err_msg)
            notify("NeoMutt Schedule ERROR", err_msg)
            sys.exit(1)

        # Save to queue directory
        os.makedirs(QUEUE_DIR, exist_ok=True)
        target_ts = int(target_dt.timestamp())
        job_id = f"mail_{target_ts}_{uuid.uuid4().hex[:6]}"
        file_path = os.path.join(QUEUE_DIR, f"{job_id}.eml")

        with open(file_path, "wb") as f:
            f.write(clean_email.encode("utf-8", errors="surrogateescape"))
        os.chmod(file_path, 0o600)

        # Spawn detached exact-time background worker
        try:
            subprocess.Popen(
                [sys.executable, os.path.abspath(__file__), "--wait-and-flush", str(target_ts)],
                start_new_session=True,
                stdin=subprocess.DEVNULL,
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL
            )
        except Exception as e:
            log(f"Failed to spawn background dispatch worker: {e}")

        calendar_str = target_dt.strftime("%Y-%m-%d %H:%M:%S")
        log(f"Email queued in {QUEUE_DIR} for delivery at {calendar_str}.")
        success_msg = f"Email scheduled for {calendar_str} (Account: {account})"
        log(success_msg)
        notify("NeoMutt Scheduled Send", success_msg)
        print(success_msg)
    else:
        # Immediate send
        log(f"Sending email immediately via msmtp (Account: {account})...")
        proc = subprocess.Popen(
            ["msmtp", "-a", account, "-t"],
            stdin=subprocess.PIPE,
            stdout=subprocess.PIPE,
            stderr=subprocess.PIPE,
            env=env
        )
        _, stderr = proc.communicate(input=raw_bytes)

        if proc.returncode == 0:
            log(f"Email sent successfully via msmtp (Account: {account}).")
            # Try flushing any older pending queued emails in the background
            try:
                flush_queue()
            except Exception:
                pass
        else:
            err_text = stderr.decode("utf-8", errors="ignore").strip()
            log(f"msmtp failed (exit code {proc.returncode}): {err_text}")
            
            # Save to offline queue so email is never lost
            os.makedirs(QUEUE_DIR, exist_ok=True)
            job_id = f"offline_{account}_{int(datetime.now().timestamp())}_{uuid.uuid4().hex[:6]}"
            file_path = os.path.join(QUEUE_DIR, f"{job_id}.eml")
            
            with open(file_path, "wb") as f:
                f.write(raw_bytes)
            os.chmod(file_path, 0o600)
            
            queue_msg = f"Network unavailable or send failed (code {proc.returncode}). Email saved to queue: {job_id}.eml"
            log(queue_msg)
            notify("NeoMutt: Offline - Email Queued", "No network connection. Email was saved locally and will send automatically when online.")
            
            # Return 0 to NeoMutt so the draft is safely handled and not discarded on reboot
            print("No connection. Email saved to offline queue and will be sent automatically.")
            sys.exit(0)

if __name__ == "__main__":
    main()

