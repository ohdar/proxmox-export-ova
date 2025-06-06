#!/bin/bash
set -euo pipefail

echo "Building the .deb package..."
dpkg-deb --build pve-export-ova

echo "Installing the .deb package..."
dpkg -i pve-export-ova.deb

echo "Copying ExportOva.pm to API2 directory..."
# cp patch/PVE_API2_Qemu_ExportOva.pm /usr/share/perl5/PVE/API2/Qemu/ExportOva.pm
cp api/PVE_API2_Qemu_ExportOva.pm /usr/share/perl5/PVE/API2/Qemu/ExportOva.pm

echo "Backing up original Qemu.pm..."
cp /usr/share/perl5/PVE/API2/Qemu.pm /usr/share/perl5/PVE/API2/Qemu.pm.bak

echo "Applying patch to Qemu.pm..."
# patch /usr/share/perl5/PVE/API2/Qemu.pm < patch/Qemu_pm.patch
patch /usr/share/perl5/PVE/API2/Qemu.pm < api/Qemu_pm.patch

echo "Restarting pveproxy service..."
systemctl restart pveproxy

echo "Deployment complete."
echo "Please manually add the UI button in pvemanagerlib.js or automate separately."