from __future__ import annotations


def test_health_ok(box):
    client, _, _, main = box
    res = client.get("/api/health")
    assert res.status_code == 200
    body = res.json()
    assert body["ok"] is True
    assert body["version"] == main.APP_VERSION
    assert body["arch"] in {"amd64", "arm64", "x86_64", "aarch64"}


def test_health_skin_hint_from_host(box):
    client, _, _, _ = box
    res = client.get("/api/health", headers={"Host": "doomsday.local"})
    assert res.json()["skin_hint"] == "doomsday"

    res = client.get("/api/health", headers={"Host": "box.local"})
    assert res.json()["skin_hint"] == "hub"
