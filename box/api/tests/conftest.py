"""Isolated API tests — temp storage per test via module reload."""

from __future__ import annotations

import importlib
from collections.abc import Iterator
from pathlib import Path

import pytest
from starlette.testclient import TestClient


@pytest.fixture()
def box(tmp_path, monkeypatch) -> Iterator[tuple[TestClient, Path, Path, object]]:
    storage = tmp_path / "storage"
    host_state = tmp_path / "host_state"
    host_state.mkdir(parents=True)

    monkeypatch.setenv("DOOMBOX_STORAGE", str(storage))
    monkeypatch.setenv("DOOMBOX_HOST_STATE", str(host_state))

    import app.main as main

    importlib.reload(main)

    with TestClient(main.app) as client:
        yield client, storage, host_state, main


def claim_pin(storage: Path) -> str:
    return (storage / "compose" / "SETUP_PIN.txt").read_text(encoding="utf-8").strip()


def session_cookie(client: TestClient) -> str | None:
    return client.cookies.get("doombox_session")
