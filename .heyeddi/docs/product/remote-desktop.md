# Remote desktop (browser workspace)

**Last updated:** 2026-08-11  
**Status:** MVP — enable from Settings UI

## What this is

An authenticated **full Linux desktop in the browser** (`linuxserver/webtop` ubuntu-xfce, KasmVNC). Use it to install and run **Cursor** on the box. This is not code-server and not a Cursor VS Code extension.

Default: **off**. Gateway path: `/desktop/`.

## Is it protected?

**Yes.** Flow: **hub address → sign in → open remote desktop**. Unsigned `/desktop/` does not work.

| Layer | Behavior |
|-------|----------|
| Gateway | `auth_request` checks dashboard session before proxying `/desktop/` |
| No cookie / signed out | **302** to `/login?next=/desktop/` — after sign-in, desktop opens |
| Host ports | Desktop is **not** published on the host; only via gateway |
| Toggle API | `POST /api/apps/remote-desktop` requires signed-in admin |

Anyone on the LAN who is **not** signed into the hub cannot open the desktop. (LAN HTTPS/TLS still later; treat LAN as trusted perimeter for v0.)

## Enable from the UI

1. Sign in to `http://box.local/` (or `:8080` in compose dev).
2. **Settings → Remote desktop** → flip **Enable remote desktop**.
3. Wait until status shows **Ready** (first pull can take several minutes).
4. Click **Open remote desktop** (opens `/desktop/` in a **new tab**).

Home also shows **Open remote desktop** when the box is claimed (active once Ready).

## Console fallback

```bash
sudo doombox-enable-remote-desktop
sudo doombox-disable-remote-desktop
```

## Install VS Code or Cursor

Ubuntu Software / PackageKit **will fail** here (`GDBus` / `_apt` cannot read `~/Downloads`). Use the terminal:

```bash
# after downloading the .deb into ~/Downloads
~/bin/install-linux-editor.sh ~/Downloads/code_*.deb
# or
~/bin/install-linux-editor.sh ~/Downloads/cursor*.deb
```

Manual equivalent:

```bash
cp ~/Downloads/code_*.deb /tmp/
chmod a+r /tmp/code_*.deb
sudo apt-get update
sudo apt-get install -y /tmp/code_*.deb
```

Ignore PackageKit “Permission denied” and “unsandboxed as root” notices.

**Apt restore (N150-friendly):** syncs on **desktop start**, immediately after each `apt install`, **once per day** (sleeping 24h — ~0 CPU), and when the **desktop stops** (Disable / compose stop). Closing a browser tab is not a stop.

| Path | What |
|------|------|
| `~/cache/apt/extra-packages.txt` | Packages you installed beyond the stock webtop image |
| `~/cache/debs/` + `~/cache/apt-archives/` | `.deb` files for offline/recreate restore |

After a desktop **container recreate**, init reinstalls those extra packages (Cursor, VS Code, anything else you `apt install`’d). Projects stay in `~/workspace`; settings stay in home (`~/.config`).

Does **not** snapshot pip/npm global tools or Flatpaks — apt/debs only for this MVP.

Keep projects in `~/workspace` (persists on the box). Desktop also has `INSTALL-EDITORS.txt` after a container restart.

## Resources

Defaults: 2 CPUs, 4GB RAM, 1GB shm (`.env` → `REMOTE_DESKTOP_*`).

## Related

- Compose: `box/compose/services/remote-desktop.yml`
- Backlog: `.heyeddi/docs/product/backlog.md`
