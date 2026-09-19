#!/usr/bin/env python3
import sys
import email
import re
import urllib.parse
import tempfile
import subprocess
import os
import datetime
import icalendar

def process_html(payload):
    with tempfile.NamedTemporaryFile(delete=False, suffix='.html', mode='wb') as f:
        f.write(payload)
        temp_path = f.name
    subprocess.run(['xdg-open', temp_path])

def format_gcal_datetime(dt_obj):
    if dt_obj is None:
        return ""
    dt = dt_obj.dt if hasattr(dt_obj, 'dt') else dt_obj
    if isinstance(dt, datetime.datetime):
        if dt.tzinfo is not None:
            # Convert timezone aware to UTC
            dt_utc = dt.astimezone(datetime.timezone.utc)
            return dt_utc.strftime("%Y%m%dT%H%M%SZ")
        else:
            return dt.strftime("%Y%m%dT%H%M%S")
    elif isinstance(dt, datetime.date):
        return dt.strftime("%Y%m%d")
    return ""

def process_gcal(raw_email):
    msg = email.message_from_bytes(raw_email)
    ics_content = None

    for part in msg.walk():
        content_type = part.get_content_type()
        if content_type in ['text/calendar', 'application/ics']:
            payload = part.get_payload(decode=True)
            if payload:
                ics_content = payload
                break

    if not ics_content:
        # Fallback if raw email contains calendar directly
        if b"BEGIN:VCALENDAR" in raw_email:
            start_idx = raw_email.find(b"BEGIN:VCALENDAR")
            end_idx = raw_email.find(b"END:VCALENDAR")
            if start_idx != -1 and end_idx != -1:
                ics_content = raw_email[start_idx:end_idx + len(b"END:VCALENDAR")]

    if not ics_content:
        print("[!] No calendar invite (.ics) found in this email.")
        try:
            subprocess.run(["notify-send", "NeoMutt Calendar", "No .ics calendar invite found in this email."], check=False)
        except Exception:
            pass
        return

    try:
        cal = icalendar.Calendar.from_ical(ics_content)
    except Exception as e:
        print(f"[!] Failed to parse calendar invite: {e}")
        return

    event = None
    for comp in cal.walk('VEVENT'):
        event = comp
        break

    if not event:
        print("[!] No event (VEVENT) found in calendar invite.")
        return

    summary = str(event.get('summary', 'New Event'))
    location = str(event.get('location', '')).strip()
    description = str(event.get('description', '')).strip()
    
    dtstart = event.get('dtstart')
    dtend = event.get('dtend')

    start_str = format_gcal_datetime(dtstart)
    end_str = format_gcal_datetime(dtend)

    if start_str and not end_str:
        # Default to 1 hour duration if end time is missing
        dt = dtstart.dt if hasattr(dtstart, 'dt') else dtstart
        if isinstance(dt, datetime.datetime):
            end_dt = dt + datetime.timedelta(hours=1)
            end_str = format_gcal_datetime(end_dt)
        elif isinstance(dt, datetime.date):
            end_str = start_str

    dates_param = f"{start_str}/{end_str}" if (start_str and end_str) else start_str

    params = {
        'action': 'TEMPLATE',
        'text': summary,
    }
    if dates_param:
        params['dates'] = dates_param
    if location:
        params['location'] = location
    if description:
        # Limit description to 2000 characters to keep URL valid across browsers
        params['details'] = description[:2000]

    gcal_url = "https://calendar.google.com/calendar/render?" + urllib.parse.urlencode(params)
    subprocess.run(['xdg-open', gcal_url])

if __name__ == '__main__':
    if len(sys.argv) < 2:
        sys.exit(1)

    mode = sys.argv[1]
    raw_email = sys.stdin.buffer.read()

    if mode == '--html':
        msg = email.message_from_bytes(raw_email)
        for part in msg.walk():
            if part.get_content_type() == 'text/html':
                process_html(part.get_payload(decode=True))
                sys.exit(0)
    elif mode == '--gcal':
        process_gcal(raw_email)
        sys.exit(0)
