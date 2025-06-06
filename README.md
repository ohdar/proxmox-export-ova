# Proxmox Export to OVA Feature

Adds a new API endpoint and UI button to export VM directly to OVA format.

## Contents

- `bin/export_to_ova_plus.sh`: Export shell script
- `api/PVE_API2_Qemu_ExportOva.pm`: Perl API patch module
- `api/Qemu.pm.patch`: Patch file for Proxmox's Qemu.pm
- `ui/export_ova_button.js`: UI button snippet
- `debian/`: Packaging files

## Build and deploy

1. Build deb package with `dpkg-deb --build .`
2. Install deb on Proxmox node.
3. Copy API module and patch Qemu.pm.
4. Patch UI JavaScript with `ui_patch.sh`.
5. Restart services: `systemctl restart pveproxy`.