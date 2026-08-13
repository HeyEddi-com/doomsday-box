#!/usr/bin/env bash
# Disable XFCE compositing — software GL in QEMU/webtop often crashes xfwm4
# and leaves a blank screen with only a cursor.
set -euo pipefail

CFG="/config/.config/xfce4/xfconf/xfce-perchannel-xml"
mkdir -p "${CFG}"

# Seed defaults if missing (same as webtop startwm.sh)
if [[ ! -f "${CFG}/xfwm4.xml" ]] && [[ -d /defaults/xfce ]]; then
  cp /defaults/xfce/* "${CFG}/" 2>/dev/null || true
fi

python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET

path = Path("/config/.config/xfce4/xfconf/xfce-perchannel-xml/xfwm4.xml")
path.parent.mkdir(parents=True, exist_ok=True)

if path.is_file():
    tree = ET.parse(path)
    root = tree.getroot()
else:
    root = ET.Element("channel", {"name": "xfwm4", "version": "1.0"})
    tree = ET.ElementTree(root)

props = {p.get("name"): p for p in root.findall("property")}
# Ensure /general exists
gen = props.get("/general")
if gen is None:
    gen = ET.SubElement(root, "property", {"name": "/general", "type": "empty"})

# Find or create use_compositing under /general as nested props, or flat name.
# linuxserver defaults use nested <property name="general" type="empty"> children.
general = None
for p in root.findall("property"):
    if p.get("name") in ("general", "/general"):
        general = p
        break
if general is None:
    general = ET.SubElement(root, "property", {"name": "general", "type": "empty"})

comp = None
for p in general.findall("property"):
    if p.get("name") == "use_compositing":
        comp = p
        break
if comp is None:
    ET.SubElement(
        general,
        "property",
        {"name": "use_compositing", "type": "bool", "value": "false"},
    )
else:
    comp.set("type", "bool")
    comp.set("value", "false")

tree.write(path, encoding="UTF-8", xml_declaration=True)
print("compositing disabled in", path)
PY

# Drop leftover crash cores so they don't fill the config volume
rm -f /config/core /config/core.* 2>/dev/null || true

if id abc >/dev/null 2>&1; then
  chown -R abc:abc /config/.config || true
fi
