"""Remote desktop app API + gateway auth_session contract."""

from __future__ import annotations

from pathlib import Path

from starlette.testclient import TestClient

from tests.conftest import claim_pin


def _claim(client: TestClient, storage: Path) -> None:
    pin = claim_pin(storage)
    res = client.post(
        "/api/setup",
        json={
            "claim_code": pin,
            "admin_password": "test-password-99",
            "network_mode": "lan",
        },
    )
    assert res.status_code == 200


def test_auth_session_requires_login(box):
    client, storage, _host, _main = box
    assert client.get("/api/auth/session").status_code == 401
    _claim(client, storage)
    assert client.get("/api/auth/session").status_code == 200
    client.post("/api/logout")
    assert client.get("/api/auth/session").status_code == 401


def test_remote_desktop_requires_auth(box):
    client, storage, _host, _main = box
    _claim(client, storage)
    client.cookies.clear()
    assert client.get("/api/apps/remote-desktop").status_code == 401
    assert client.post("/api/apps/remote-desktop", json={"enabled": True}).status_code == 401


def test_remote_desktop_toggle_desired_state(box):
    client, storage, _host, main = box
    _claim(client, storage)

    res = client.get("/api/apps/remote-desktop")
    assert res.status_code == 200
    body = res.json()
    assert body["desired"] is False
    assert body["path"] == "/desktop/"
    assert body["docker_control"] is False

    on = client.post("/api/apps/remote-desktop", json={"enabled": True})
    assert on.status_code == 200
    assert on.json()["desired"] is True
    apps = (storage / "compose" / "apps.json").read_text(encoding="utf-8")
    assert '"remote_desktop": true' in apps

    off = client.post("/api/apps/remote-desktop", json={"enabled": False})
    assert off.status_code == 200
    assert off.json()["desired"] is False
