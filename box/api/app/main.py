"""HeyEddi Doomsday Box — on-device API."""

from __future__ import annotations

import hashlib
import json
import os
import platform
import secrets
import shutil
import subprocess
import urllib.error
import urllib.request
from datetime import datetime, timedelta, timezone
from pathlib import Path
from typing import Any

from fastapi import FastAPI, Header, HTTPException, Request, Response
from fastapi.middleware.cors import CORSMiddleware
from pydantic import BaseModel, Field

APP_VERSION = "0.3.0"
STORAGE = Path(os.environ.get("DOOMBOX_STORAGE", "/mnt/storage"))
DATA = STORAGE / "compose"
STATE_FILE = DATA / "setup-state.json"
CLAIM_FILE = DATA / "setup-claim.json"
PIN_PLAINTEXT_FILE = DATA / "SETUP_PIN.txt"  # host/console/kiosk only — never over LAN API
SESSIONS_FILE = DATA / "sessions.json"
APPS_FILE = DATA / "apps.json"
HOST_STATE_DIR = Path(os.environ.get("DOOMBOX_HOST_STATE", "/var/lib/doombox"))
REMOTE_ADMIN_MARKER = HOST_STATE_DIR / "remote-admin-enabled"
SESSION_COOKIE = "doombox_session"
SESSION_DAYS = 14
BOX_ROOT = Path(os.environ.get("DOOMBOX_BOX_ROOT", "/box"))
DOCKER_CONTROL = os.environ.get("DOOMBOX_DOCKER_CONTROL", "0").strip() in {
    "1",
    "true",
    "yes",
}
REMOTE_DESKTOP_URL = os.environ.get(
    "DOOMBOX_REMOTE_DESKTOP_URL",
    "http://remote-desktop:3000/desktop/",
)
REMOTE_DESKTOP_PATH = "/desktop/"

app = FastAPI(
    title="HeyEddi Doomsday Box API",
    version=APP_VERSION,
    docs_url="/api/docs",
    openapi_url="/api/openapi.json",
)

# Starlette rejects allow_origins=["*"] with allow_credentials=True.
_LOCAL_ORIGIN_RE = (
    r"https?://("
    r"localhost|127\.0\.0\.1|"
    r"box\.local|doomsday\.local|"
    r"box\.heyeddi\.local|doomsday\.heyeddi\.local"
    r")(:\d+)?$"
)
app.add_middleware(
    CORSMiddleware,
    allow_origin_regex=_LOCAL_ORIGIN_RE,
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


class Health(BaseModel):
    ok: bool = True
    version: str = APP_VERSION
    arch: str
    skin_hint: str | None = None


class Status(BaseModel):
    product: str = "HeyEddi Doomsday Box"
    version: str = APP_VERSION
    arch: str
    setup_complete: bool
    setup_open: bool
    claim_required: bool = True
    authenticated: bool = False
    auth_required: bool = False
    hostnames: list[str]
    skin: str


class SetupPayload(BaseModel):
    claim_code: str = Field(min_length=6, max_length=32)
    admin_password: str = Field(min_length=8, max_length=128)
    network_mode: str = Field(default="lan", pattern="^(lan|bridge|ap)$")


class SetupResult(BaseModel):
    ok: bool
    setup_complete: bool
    message: str


class LoginPayload(BaseModel):
    password: str = Field(min_length=1, max_length=128)


class LoginResult(BaseModel):
    ok: bool
    message: str


class Me(BaseModel):
    authenticated: bool
    setup_complete: bool
    role: str = "admin"


class OperatorStatus(BaseModel):
    remote_admin_enabled: bool
    maker_user: str = "heyeddi"
    notes: list[str]
    # Explicitly document what the web UI must never do:
    factory_reset_via_api: bool = False
    claim_pin_via_api: bool = False


class RemoteDesktopStatus(BaseModel):
    id: str = "remote-desktop"
    desired: bool
    running: bool
    path: str = REMOTE_DESKTOP_PATH
    docker_control: bool
    message: str


class RemoteDesktopPayload(BaseModel):
    enabled: bool


def _arch() -> str:
    machine = platform.machine().lower()
    if machine in {"x86_64", "amd64"}:
        return "amd64"
    if machine in {"aarch64", "arm64"}:
        return "arm64"
    return machine


def _skin_from_host(host: str | None) -> str:
    h = (host or "").split(":")[0].lower()
    if "doomsday" in h:
        return "doomsday"
    return "hub"


def _ensure_storage() -> None:
    DATA.mkdir(parents=True, exist_ok=True)


def _setup_complete() -> bool:
    if not STATE_FILE.is_file():
        return False
    try:
        data = json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return False
    return bool(data.get("setup_complete"))


def _load_state() -> dict[str, Any]:
    if not STATE_FILE.is_file():
        return {}
    try:
        return json.loads(STATE_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {}


_PBKDF2_ROUNDS = 600_000


def _hash_secret(value: str, salt: str) -> str:
    dk = hashlib.pbkdf2_hmac(
        "sha256",
        value.encode("utf-8"),
        salt.encode("utf-8"),
        _PBKDF2_ROUNDS,
    )
    return dk.hex()


def _generate_claim_pin() -> str:
    alphabet = "ABCDEFGHJKLMNPQRSTUVWXYZ23456789"
    return "".join(secrets.choice(alphabet) for _ in range(8))


def _mint_claim() -> dict:
    pin = _generate_claim_pin()
    salt = secrets.token_hex(16)
    claim = {
        "salt": salt,
        "pin_hash": _hash_secret(pin, salt),
        "created_at": datetime.now(timezone.utc).isoformat(),
        "consumed": False,
    }
    CLAIM_FILE.write_text(json.dumps(claim, indent=2) + "\n", encoding="utf-8")
    PIN_PLAINTEXT_FILE.write_text(pin + "\n", encoding="utf-8")
    try:
        PIN_PLAINTEXT_FILE.chmod(0o600)
        CLAIM_FILE.chmod(0o600)
    except OSError:
        pass
    return claim


def _ensure_claim() -> dict:
    _ensure_storage()
    if CLAIM_FILE.is_file():
        try:
            claim = json.loads(CLAIM_FILE.read_text(encoding="utf-8"))
        except (OSError, json.JSONDecodeError):
            claim = {}
        if claim.get("consumed") or _setup_complete():
            return claim if claim else {"consumed": True}
        if PIN_PLAINTEXT_FILE.is_file():
            return claim
        try:
            CLAIM_FILE.unlink(missing_ok=True)
        except OSError:
            pass
        return _mint_claim()
    return _mint_claim()


def _load_claim() -> dict:
    _ensure_claim()
    return json.loads(CLAIM_FILE.read_text(encoding="utf-8"))


def _verify_claim(pin: str) -> bool:
    claim = _load_claim()
    if claim.get("consumed"):
        return False
    expected = claim.get("pin_hash", "")
    salt = claim.get("salt", "")
    got = _hash_secret(pin.strip().upper(), salt)
    return secrets.compare_digest(got, expected)


def _verify_admin_password(password: str) -> bool:
    state = _load_state()
    salt = state.get("admin_password_salt", "")
    expected = state.get("admin_password_hash", "")
    if not salt or not expected:
        return False
    got = _hash_secret(password, salt)
    return secrets.compare_digest(got, expected)


def _load_sessions() -> dict[str, Any]:
    if not SESSIONS_FILE.is_file():
        return {"sessions": {}}
    try:
        return json.loads(SESSIONS_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {"sessions": {}}


def _save_sessions(data: dict[str, Any]) -> None:
    _ensure_storage()
    SESSIONS_FILE.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    try:
        SESSIONS_FILE.chmod(0o600)
    except OSError:
        pass


def _create_session() -> str:
    token = secrets.token_urlsafe(32)
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    data = _load_sessions()
    sessions = data.setdefault("sessions", {})
    exp = datetime.now(timezone.utc) + timedelta(days=SESSION_DAYS)
    sessions[token_hash] = {"expires_at": exp.isoformat()}
    # prune expired
    now = datetime.now(timezone.utc)
    keep = {}
    for h, meta in sessions.items():
        try:
            if datetime.fromisoformat(meta["expires_at"]) > now:
                keep[h] = meta
        except (KeyError, ValueError, TypeError):
            continue
    data["sessions"] = keep
    data["sessions"][token_hash] = {"expires_at": exp.isoformat()}
    _save_sessions(data)
    return token


def _revoke_session(token: str | None) -> None:
    if not token:
        return
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    data = _load_sessions()
    data.get("sessions", {}).pop(token_hash, None)
    _save_sessions(data)


def _session_valid(request: Request) -> bool:
    token = request.cookies.get(SESSION_COOKIE)
    if not token:
        return False
    token_hash = hashlib.sha256(token.encode("utf-8")).hexdigest()
    meta = _load_sessions().get("sessions", {}).get(token_hash)
    if not meta:
        return False
    try:
        return datetime.fromisoformat(meta["expires_at"]) > datetime.now(timezone.utc)
    except (KeyError, ValueError, TypeError):
        return False


def _set_session_cookie(response: Response, token: str) -> None:
    response.set_cookie(
        key=SESSION_COOKIE,
        value=token,
        httponly=True,
        samesite="lax",
        max_age=SESSION_DAYS * 24 * 3600,
        path="/",
    )


def _clear_session_cookie(response: Response) -> None:
    response.delete_cookie(SESSION_COOKIE, path="/")


def _require_auth(request: Request) -> None:
    if not _setup_complete():
        return
    if not _session_valid(request):
        raise HTTPException(status_code=401, detail="Sign in required.")


def _load_apps() -> dict[str, Any]:
    if not APPS_FILE.is_file():
        return {"remote_desktop": False}
    try:
        data = json.loads(APPS_FILE.read_text(encoding="utf-8"))
    except (OSError, json.JSONDecodeError):
        return {"remote_desktop": False}
    if not isinstance(data, dict):
        return {"remote_desktop": False}
    return data


def _save_apps(data: dict[str, Any]) -> None:
    _ensure_storage()
    APPS_FILE.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
    try:
        APPS_FILE.chmod(0o600)
    except OSError:
        pass


def _remote_desktop_running() -> bool:
    """True when the webtop container is up.

    Prefer a local docker compose probe — HTTP to the service hostname can hang
    for a long time on DNS when the profile container is not running (urlopen
    timeouts do not always cover getaddrinfo).
    """
    try:
        result = subprocess.run(
            _compose_cmd("ps", "--status", "running", "-q", "remote-desktop"),
            check=False,
            capture_output=True,
            text=True,
            timeout=5,
        )
        if (result.stdout or "").strip():
            return True
        if result.returncode == 0:
            return False
    except (OSError, subprocess.TimeoutExpired):
        pass

    # Fallback for environments without a working docker CLI in the API image.
    # Use urlopen timeout only — never mutate socket.setdefaulttimeout (process-global).
    try:
        req = urllib.request.Request(REMOTE_DESKTOP_URL, method="GET")
        with urllib.request.urlopen(req, timeout=2) as resp:
            return 200 <= int(resp.status) < 500
    except (urllib.error.URLError, TimeoutError, ValueError, OSError):
        return False


def _compose_cmd(*extra: str) -> list[str]:
    compose_file = BOX_ROOT / "compose" / "docker-compose.yml"
    env_file = BOX_ROOT / ".env"
    standalone = shutil.which("docker-compose")
    if standalone:
        cmd = [
            standalone,
            "-f",
            str(compose_file),
            "--profile",
            "remote-desktop",
        ]
    else:
        docker = shutil.which("docker") or "/usr/local/bin/docker"
        cmd = [
            docker,
            "compose",
            "-f",
            str(compose_file),
            "--profile",
            "remote-desktop",
        ]
    if env_file.is_file():
        cmd.extend(["--env-file", str(env_file)])
    cmd.extend(extra)
    return cmd


def _sync_remote_desktop_cache() -> None:
    """Flush apt software cache before stopping the desktop."""
    try:
        subprocess.run(
            _compose_cmd(
                "exec",
                "-T",
                "remote-desktop",
                "/usr/local/bin/doombox-sync-apt-cache",
            ),
            check=False,
            capture_output=True,
            text=True,
            timeout=180,
        )
    except (OSError, subprocess.TimeoutExpired):
        return


def _apply_remote_desktop(enabled: bool) -> str:
    """Start/stop compose profile when docker control is enabled."""
    if not DOCKER_CONTROL:
        if enabled:
            return (
                "Desired state saved. Start the desktop with "
                "sudo doombox-enable-remote-desktop "
                "(or compose --profile remote-desktop up -d)."
            )
        return (
            "Desired state saved. Stop the desktop with "
            "sudo doombox-disable-remote-desktop."
        )

    if enabled:
        # Ensure host dirs exist for webtop mounts (API sees STORAGE path).
        (STORAGE / "remote-desktop").mkdir(parents=True, exist_ok=True)
        (STORAGE / "workspace").mkdir(parents=True, exist_ok=True)
        try:
            subprocess.Popen(
                _compose_cmd("up", "-d", "remote-desktop"),
                stdout=subprocess.DEVNULL,
                stderr=subprocess.DEVNULL,
                start_new_session=True,
            )
        except OSError as exc:
            raise HTTPException(
                status_code=503,
                detail=f"Docker control failed: {exc}",
            ) from exc
        return (
            "Remote desktop starting. Refresh status or wait for Ready, "
            "then open /desktop/."
        )

    # Stop in the background (same as enable) so Settings never hits a gateway 504.
    # Apt-cache sync stays on the host disable script; API path prioritizes a fast reply.
    try:
        subprocess.Popen(
            _compose_cmd("stop", "remote-desktop"),
            stdout=subprocess.DEVNULL,
            stderr=subprocess.DEVNULL,
            start_new_session=True,
        )
    except OSError as exc:
        raise HTTPException(
            status_code=503,
            detail=f"Docker control failed: {exc}",
        ) from exc

    return "Remote desktop stop requested. Status updates when the container exits."


@app.on_event("startup")
def on_startup() -> None:
    _ensure_claim()


@app.get("/api/health", response_model=Health)
def health(
    x_doombox_host: str | None = Header(default=None),
    host: str | None = Header(default=None),
) -> Health:
    return Health(
        arch=_arch(),
        skin_hint=_skin_from_host(x_doombox_host or host),
    )


@app.get("/api/status", response_model=Status)
def status(
    request: Request,
    x_doombox_host: str | None = Header(default=None),
) -> Status:
    host = x_doombox_host or request.headers.get("host")
    complete = _setup_complete()
    authed = _session_valid(request) if complete else False
    return Status(
        arch=_arch(),
        setup_complete=complete,
        setup_open=not complete,
        claim_required=True,
        authenticated=authed,
        auth_required=complete,
        hostnames=[
            "box.heyeddi.local",
            "doomsday.heyeddi.local",
            "box.local",
            "doomsday.local",
        ],
        skin=_skin_from_host(host),
    )


@app.post("/api/setup", response_model=SetupResult)
def setup(payload: SetupPayload, response: Response) -> SetupResult:
    """Claim with physical PIN. No HTTP factory-reset exists."""
    _ensure_storage()

    if _setup_complete():
        raise HTTPException(
            status_code=403,
            detail="Setup already completed. Factory reset required to reclaim.",
        )

    claim = _load_claim()
    if claim.get("consumed"):
        raise HTTPException(status_code=403, detail="Claim code already used.")

    if not _verify_claim(payload.claim_code):
        raise HTTPException(
            status_code=403,
            detail="Invalid claim code. Use the code from the box console/kiosk/sticker — it is never shown in the browser.",
        )

    pw_salt = secrets.token_hex(16)
    pw_hash = _hash_secret(payload.admin_password, pw_salt)

    claim["consumed"] = True
    claim["consumed_at"] = datetime.now(timezone.utc).isoformat()
    CLAIM_FILE.write_text(json.dumps(claim, indent=2) + "\n", encoding="utf-8")

    STATE_FILE.write_text(
        json.dumps(
            {
                "setup_complete": True,
                "network_mode": payload.network_mode,
                "admin_password_salt": pw_salt,
                "admin_password_hash": pw_hash,
                "claimed_at": datetime.now(timezone.utc).isoformat(),
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    try:
        STATE_FILE.chmod(0o600)
    except OSError:
        pass

    try:
        PIN_PLAINTEXT_FILE.unlink(missing_ok=True)
    except OSError:
        pass

    token = _create_session()
    _set_session_cookie(response, token)

    return SetupResult(
        ok=True,
        setup_complete=True,
        message="Box claimed. You are signed in. Claim code is no longer valid.",
    )


@app.post("/api/login", response_model=LoginResult)
def login(payload: LoginPayload, response: Response) -> LoginResult:
    if not _setup_complete():
        raise HTTPException(status_code=403, detail="Box is not claimed yet. Use /setup.")
    if not _verify_admin_password(payload.password):
        raise HTTPException(status_code=403, detail="Invalid password.")
    token = _create_session()
    _set_session_cookie(response, token)
    return LoginResult(ok=True, message="Signed in.")


@app.post("/api/logout", response_model=LoginResult)
def logout(request: Request, response: Response) -> LoginResult:
    _revoke_session(request.cookies.get(SESSION_COOKIE))
    _clear_session_cookie(response)
    return LoginResult(ok=True, message="Signed out.")


@app.get("/api/me", response_model=Me)
def me(request: Request) -> Me:
    complete = _setup_complete()
    if complete:
        _require_auth(request)
    return Me(authenticated=_session_valid(request) or not complete, setup_complete=complete)


def _remote_admin_enabled() -> bool:
    try:
        return REMOTE_ADMIN_MARKER.is_file()
    except OSError:
        return False


@app.get("/api/operator-status", response_model=OperatorStatus)
def operator_status(request: Request) -> OperatorStatus:
    """Read-only Advanced panel data. Never enables SSH or exposes claim PIN."""
    _require_auth(request)
    enabled = _remote_admin_enabled()
    notes = [
        "Remote shell is opt-in on the local console: doombox-enable-operator --pubkey … --enable-ssh",
        "Disable on the local console: doombox-disable-remote-admin",
        "Factory reset and claim PIN are never available in this API or dashboard.",
        "Maker account has no full root and no docker group - see README-MAKER.txt",
        "Browser remote desktop is separate: Settings → Remote desktop (no SSH).",
    ]
    return OperatorStatus(remote_admin_enabled=enabled, notes=notes)


@app.get("/api/auth/session")
def auth_session(request: Request) -> Response:
    """Used by gateway auth_request for /desktop/. 200 if signed in."""
    if not _setup_complete():
        raise HTTPException(status_code=401, detail="Box not claimed.")
    if not _session_valid(request):
        raise HTTPException(status_code=401, detail="Sign in required.")
    return Response(status_code=200)


@app.get("/api/apps/remote-desktop", response_model=RemoteDesktopStatus)
def remote_desktop_status(request: Request) -> RemoteDesktopStatus:
    _require_auth(request)
    apps = _load_apps()
    desired = bool(apps.get("remote_desktop"))
    running = _remote_desktop_running()
    if desired and running:
        message = "Desktop is up. Open /desktop/ in this browser (same sign-in)."
    elif desired and not running:
        message = (
            "Enabled in settings; container not reachable yet. "
            "Wait, or run sudo doombox-enable-remote-desktop on the box."
        )
    elif running:
        message = "Desktop container is running (desired state is off)."
    else:
        message = "Remote desktop is off (safe default)."
    return RemoteDesktopStatus(
        desired=desired,
        running=running,
        docker_control=DOCKER_CONTROL,
        message=message,
    )


@app.post("/api/apps/remote-desktop", response_model=RemoteDesktopStatus)
def remote_desktop_set(
    payload: RemoteDesktopPayload,
    request: Request,
) -> RemoteDesktopStatus:
    """Toggle browser remote desktop. Does not enable SSH."""
    _require_auth(request)
    apps = _load_apps()
    apps["remote_desktop"] = bool(payload.enabled)
    apps["remote_desktop_updated_at"] = datetime.now(timezone.utc).isoformat()
    _save_apps(apps)
    message = _apply_remote_desktop(bool(payload.enabled))
    running = _remote_desktop_running()
    return RemoteDesktopStatus(
        desired=bool(payload.enabled),
        running=running,
        docker_control=DOCKER_CONTROL,
        message=message,
    )
