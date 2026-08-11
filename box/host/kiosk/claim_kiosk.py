#!/usr/bin/env python3
"""Claim PIN kiosk — localhost only. Never bind to LAN interfaces.

Serves a full-screen claim code for HDMI/console browsers pointed at
http://127.0.0.1:7901/ . After claim, shows “already claimed”.
"""
from __future__ import annotations

import json
import os
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer
from pathlib import Path

STORAGE = Path(os.environ.get("DOOMBOX_STORAGE", "/mnt/storage"))
DATA = STORAGE / "compose"
PIN_FILE = DATA / "SETUP_PIN.txt"
STATE_FILE = DATA / "setup-state.json"
HOST = os.environ.get("DOOMBOX_KIOSK_HOST", "127.0.0.1")
PORT = int(os.environ.get("DOOMBOX_KIOSK_PORT", "7901"))


def setup_complete() -> bool:
    if not STATE_FILE.is_file():
        return False
    try:
        data = json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return False
    return bool(data.get("setup_complete"))


def read_pin() -> str | None:
    if setup_complete():
        return None
    if not PIN_FILE.is_file():
        return None
    try:
        return PIN_FILE.read_text(encoding="utf-8").strip().upper() or None
    except OSError:
        return None


HTML_CLAIM = """<!DOCTYPE html>
<html lang="en">
<head>
<meta charset="utf-8"/>
<meta name="viewport" content="width=device-width, initial-scale=1"/>
<meta http-equiv="refresh" content="15"/>
<title>Claim this box</title>
<style>
  html,body {{ height:100%; margin:0; background:#0e1014; color:#e8e6e1;
    font-family:"IBM Plex Sans",system-ui,sans-serif; }}
  main {{ min-height:100%; display:flex; flex-direction:column; align-items:center;
    justify-content:center; padding:2rem; text-align:center; }}
  .brand {{ letter-spacing:.12em; text-transform:uppercase; color:#c4a574; font-size:.85rem; }}
  h1 {{ font-family:"IBM Plex Serif",Georgia,serif; font-weight:600; font-size:clamp(1.6rem,4vw,2.4rem); margin:.6rem 0 1rem; }}
  .pin {{ font-family:ui-monospace,monospace; font-size:clamp(2.4rem,8vw,4.5rem);
    letter-spacing:.22em; font-weight:600; margin:1rem 0; color:#c4a574; }}
  p {{ color:#9a968c; max-width:36rem; line-height:1.5; }}
  code {{ color:#e8e6e1; }}
</style>
</head>
<body>
<main>
  <p class="brand">HeyEddi Doomsday Box</p>
  <h1>Claim code</h1>
  <div class="pin">{pin}</div>
  <p>Enter this on a phone or laptop at <code>http://box.local/setup</code>.
  This screen is only on the box display (localhost). It is not on your LAN.</p>
</main>
</body>
</html>
"""

HTML_DONE = """<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"/><title>Claimed</title>
<style>body{{margin:0;min-height:100vh;display:grid;place-items:center;background:#0e1014;color:#9a968c;font-family:system-ui,sans-serif}}</style>
</head><body><p>This box is already claimed. Factory reset is local-console only.</p></body></html>
"""

HTML_WAIT = """<!DOCTYPE html>
<html lang="en"><head><meta charset="utf-8"/><meta http-equiv="refresh" content="5"/><title>Waiting</title>
<style>body{{margin:0;min-height:100vh;display:grid;place-items:center;background:#0e1014;color:#9a968c;font-family:system-ui,sans-serif}}</style>
</head><body><p>Waiting for claim PIN… start the appliance API/compose stack.</p></body></html>
"""


class Handler(BaseHTTPRequestHandler):
    def log_message(self, fmt: str, *args) -> None:  # quieter journal
        return

    def do_GET(self) -> None:  # noqa: N802
        if self.path not in ("/", "/index.html", "/pin"):
            self.send_error(404)
            return
        if setup_complete():
            body = HTML_DONE.encode()
        else:
            pin = read_pin()
            if not pin:
                body = HTML_WAIT.encode()
            elif self.path == "/pin":
                body = (pin + "\n").encode()
                self.send_response(200)
                self.send_header("Content-Type", "text/plain; charset=utf-8")
                self.send_header("Cache-Control", "no-store")
                self.send_header("Content-Length", str(len(body)))
                self.end_headers()
                self.wfile.write(body)
                return
            else:
                body = HTML_CLAIM.format(pin=pin).encode()
        self.send_response(200)
        self.send_header("Content-Type", "text/html; charset=utf-8")
        self.send_header("Cache-Control", "no-store")
        self.send_header("Content-Length", str(len(body)))
        self.end_headers()
        self.wfile.write(body)


def main() -> None:
    # Refuse non-loopback binds unless explicitly overridden for rare serial-bridge setups
    if HOST not in ("127.0.0.1", "::1", "localhost") and os.environ.get("DOOMBOX_KIOSK_ALLOW_NONLOCAL") != "1":
        raise SystemExit(
            f"Refusing to bind kiosk to {HOST!r}. Claim PIN must stay on-loopback. "
            "Set DOOMBOX_KIOSK_HOST=127.0.0.1"
        )
    httpd = ThreadingHTTPServer((HOST, PORT), Handler)
    print(f"doombox-claim-kiosk on http://{HOST}:{PORT}/ (loopback only)", flush=True)
    httpd.serve_forever()


if __name__ == "__main__":
    main()
