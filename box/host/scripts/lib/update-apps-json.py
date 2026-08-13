#!/usr/bin/env python3
"""Update one flag in compose apps.json with an exclusive lock.

Refuses to overwrite the file when existing content is corrupt JSON so we
never wipe sibling app state on a partial write or parse failure.
"""
from __future__ import annotations

import argparse
import fcntl
import json
import os
import sys
from pathlib import Path

DEFAULT_PATH = Path("/mnt/storage/compose/apps.json")


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--path", type=Path, default=DEFAULT_PATH)
    parser.add_argument("--key", required=True)
    parser.add_argument("--value", required=True, choices=("true", "false"))
    args = parser.parse_args()

    path: Path = args.path
    path.parent.mkdir(parents=True, exist_ok=True)
    lock_path = path.with_name(f"{path.name}.lock")
    enabled = args.value == "true"

    with lock_path.open("a+", encoding="utf-8") as lockf:
        fcntl.flock(lockf, fcntl.LOCK_EX)
        data: dict = {}
        if path.is_file():
            raw = path.read_text(encoding="utf-8")
            if raw.strip():
                try:
                    parsed = json.loads(raw)
                except json.JSONDecodeError as exc:
                    print(
                        f"ERROR: refusing to overwrite corrupt {path}: {exc}",
                        file=sys.stderr,
                    )
                    return 1
                if not isinstance(parsed, dict):
                    print(
                        f"ERROR: {path} must be a JSON object",
                        file=sys.stderr,
                    )
                    return 1
                data = parsed
        data[args.key] = enabled
        path.write_text(json.dumps(data, indent=2) + "\n", encoding="utf-8")
        try:
            os.chmod(path, 0o600)
        except OSError:
            pass
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
