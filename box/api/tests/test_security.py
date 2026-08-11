from __future__ import annotations

from starlette.middleware.cors import CORSMiddleware


def test_no_factory_reset_endpoint(box):
    client, _, _, _ = box
    for method, path in (
        ("GET", "/api/factory-reset"),
        ("POST", "/api/factory-reset"),
    ):
        res = client.request(method, path)
        assert res.status_code == 404


def test_cors_allows_local_origin_with_credentials(box):
    client, _, _, main = box
    res = client.get(
        "/api/health",
        headers={
            "Origin": "http://box.local",
            "Host": "box.local",
        },
    )
    assert res.status_code == 200
    assert res.headers.get("access-control-allow-origin") == "http://box.local"
    assert res.headers.get("access-control-allow-credentials") == "true"

    cors_layers = [m.cls for m in main.app.user_middleware if m.cls is CORSMiddleware]
    assert cors_layers, "CORSMiddleware must be installed"


def test_cors_rejects_unlisted_origin(box):
    client, _, _, _ = box
    res = client.get(
        "/api/health",
        headers={"Origin": "https://evil.example"},
    )
    assert res.status_code == 200
    assert "access-control-allow-origin" not in res.headers
