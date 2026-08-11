from __future__ import annotations

from tests.conftest import claim_pin


def _claim(client, storage, password: str = "securepass1") -> None:
    pin = claim_pin(storage)
    res = client.post(
        "/api/setup",
        json={
            "claim_code": pin,
            "admin_password": password,
            "network_mode": "lan",
        },
    )
    assert res.status_code == 200


def test_login_before_claim_rejected(box):
    client, _, _, _ = box
    res = client.post("/api/login", json={"password": "anything"})
    assert res.status_code == 403
    assert "not claimed" in res.json()["detail"].lower()


def test_login_wrong_password(box):
    client, storage, _, _ = box
    _claim(client, storage)
    client.cookies.clear()
    res = client.post("/api/login", json={"password": "wrongpass"})
    assert res.status_code == 403


def test_login_logout_cycle(box):
    client, storage, _, main = box
    _claim(client, storage, "mypassword1")
    client.cookies.clear()

    res = client.post("/api/login", json={"password": "mypassword1"})
    assert res.status_code == 200
    assert client.cookies.get(main.SESSION_COOKIE)

    assert client.get("/api/me").json()["authenticated"] is True

    res = client.post("/api/logout")
    assert res.status_code == 200
    assert client.get("/api/me").status_code == 401


def test_me_requires_auth_when_claimed(box):
    client, storage, _, _ = box
    _claim(client, storage)
    client.cookies.clear()
    assert client.get("/api/me").status_code == 401


def test_operator_status_requires_auth(box):
    client, storage, _, _ = box
    _claim(client, storage)
    client.cookies.clear()
    assert client.get("/api/operator-status").status_code == 401


def test_operator_status_security_contract(box):
    client, storage, host_state, _ = box
    _claim(client, storage)
    res = client.get("/api/operator-status")
    assert res.status_code == 200
    body = res.json()
    assert body["factory_reset_via_api"] is False
    assert body["claim_pin_via_api"] is False
    assert body["remote_admin_enabled"] is False

    marker = host_state / "remote-admin-enabled"
    marker.write_text("enabled\n", encoding="utf-8")
    assert client.get("/api/operator-status").json()["remote_admin_enabled"] is True


def test_operator_status_unreadable_host_state(box):
    client, storage, host_state, _ = box
    _claim(client, storage)
    host_state.chmod(0o000)
    try:
        res = client.get("/api/operator-status")
        assert res.status_code == 200
        assert res.json()["remote_admin_enabled"] is False
    finally:
        host_state.chmod(0o700)
