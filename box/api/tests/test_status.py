from __future__ import annotations


def test_status_unclaimed(box):
    client, _, _, main = box
    res = client.get("/api/status", headers={"Host": "box.local"})
    assert res.status_code == 200
    body = res.json()
    assert body["setup_complete"] is False
    assert body["setup_open"] is True
    assert body["claim_required"] is True
    assert body["auth_required"] is False
    assert body["authenticated"] is False
    assert body["skin"] == "hub"
    assert body["version"] == main.APP_VERSION
    assert "box.local" in body["hostnames"]


def test_status_skin_doomsday(box):
    client, _, _, _ = box
    res = client.get("/api/status", headers={"Host": "doomsday.local"})
    assert res.json()["skin"] == "doomsday"
