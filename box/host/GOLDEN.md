# Golden disk image (later)

**Status:** deferred until bootstrap is boring on ≥1 sample PC **per arch you ship**  
**v0 method remains:** Debian install + `scripts/bootstrap.sh`  
**Arches:** bake **separate** images for `amd64` and `arm64` — same scripts, different disk blobs

## When to bake

Bake a flashable image only after:

1. `smoke-check.sh` passes on real hardware for that arch (N100/N150 and/or ARM64 board)  
2. Bootstrap has been re-run cleanly on a fresh install once  
3. You are preparing friend-seed or factory clones (MOQ-scale)

## Suggested bake flow (outline)

1. Install Debian + run bootstrap on a reference unit.  
2. Clear machine-id, SSH host keys, and unique state so clones regenerate:

   ```bash
   sudo truncate -s 0 /etc/machine-id
   sudo rm -f /var/lib/dbus/machine-id
   sudo rm -f /etc/ssh/ssh_host_*
   # clear claim + identity so clones mint fresh PIN + HHDB serial:
   #   /mnt/storage/compose/{SETUP_PIN.txt,setup-*.json,BOX_ID,OEM_SERIAL,identity.json,sessions.json}
   # optionally: clear founder bash history, wipe other /mnt/storage/* contents
   ```

3. Power off; image the disk:

   ```bash
   # from a second machine / USB boot environment — verify device names
   sudo dd if=/dev/nvme0n1 bs=64M status=progress | gzip -c > doombox-host-bookworm-YYYYMMDD.img.gz
   ```

4. Flash clones; first boot regenerates SSH keys + machine-id (add a first-boot oneshot when you automate this).

## Do not

- Ship Arch/CachyOS as the customer image  
- Bake before Docker/mDNS/stub are stable  
- Commit multi‑GB `.img` files into this git repo
