from __future__ import annotations

from tests.conftest import claim_pin


def test_wrong_claim_code_rejected(box):
    client, storage, _, _ = box
    assert claim_pin(storage)
    res = client.post(
        "/api/setup",
        json={
            "claim_code": "WRONGPIN",
            "admin_password": "securepass1",
            "network_mode": "lan",
        },
    )
    assert res.status_code == 403
    assert "Invalid claim code" in res.json()["detail"]


def test_claim_success(box):
    client, storage, _, main = box
    pin = claim_pin(storage)
    res = client.post(
        "/api/setup",
        json={
            "claim_code": pin,
            "admin_password": "securepass1",
            "network_mode": "lan",
        },
    )
    assert res.status_code == 200
    body = res.json()
    assert body["ok"] is True
    assert body["setup_complete"] is True
    assert client.cookies.get(main.SESSION_COOKIE)

    assert not (storage / "compose" / "SETUP_PIN.txt").exists()

    status = client.get("/api/status").json()
    assert status["setup_complete"] is True
    assert status["authenticated"] is True


def test_double_claim_rejected(box):
    client, storage, _, _ = box
    pin = claim_pin(storage)
    payload = {
        "claim_code": pin,
        "admin_password": "securepass1",
        "network_mode": "lan",
    }
    assert client.post("/api/setup", json=payload).status_code == 200
    res = client.post("/api/setup", json=payload)
    assert res.status_code == 403
    assert "already completed" in res.json()["detail"].lower()


def test_claim_remints_when_pin_file_missing(box):
    client, storage, _, main = box
    pin_old = claim_pin(storage)
    claim_file = storage / "compose" / "setup-claim.json"
    pin_file = storage / "compose" / "SETUP_PIN.txt"
    assert claim_file.is_file()
    pin_file.unlink()

    res = client.post(
        "/api/setup",
        json={
            "claim_code": pin_old,
            "admin_password": "securepass1",
            "network_mode": "lan",
        },
    )
    assert res.status_code == 403

    pin_new = claim_pin(storage)
    assert pin_new != pin_old

    res = client.post(
        "/api/setup",
        json={
            "claim_code": pin_new,
            "admin_password": "securepass1",
            "network_mode": "lan",
        },
    )
    assert res.status_code == 200
    assert client.cookies.get(main.SESSION_COOKIE)
