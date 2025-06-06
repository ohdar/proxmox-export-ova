#!/bin/bash
set -euo pipefail

# Usage: export_to_ova_plus.sh <vmid> <output_dir>

VMID="$1"
OUTPUT_DIR="$2"
NODE=$(hostname)
TMPDIR="/tmp/pve-export-ova-${VMID}"

if [[ -z "$VMID" || -z "$OUTPUT_DIR" ]]; then
    echo "Usage: $0 <vmid> <output_dir>"
    exit 1
fi

echo "Exporting VM $VMID on node $NODE to OVA..."

mkdir -p "$TMPDIR"
mkdir -p "$OUTPUT_DIR"

# Get VM config
CONF="/etc/pve/qemu-server/${VMID}.conf"
if [[ ! -f "$CONF" ]]; then
    echo "VM config $CONF not found!"
    exit 1
fi

# Extract disk and NIC info
DISKS=()
NICs=()
while read -r line; do
    # Disk example: scsi0: local-lvm:vm-100-disk-0,size=32G
    if [[ "$line" =~ ^(scsi|ide|virtio|sata)[0-9]+: ]]; then
        DISKS+=("$line")
    elif [[ "$line" =~ ^net[0-9]+: ]]; then
        NICs+=("$line")
    fi
done < "$CONF"

# Export disks
OVADIR="${TMPDIR}/ova"
mkdir -p "$OVADIR"

# Convert disks to raw and prepare OVA structure
OVF_FILE="${OVADIR}/vm${VMID}.ovf"
VMDK_FILES=()

echo "<Envelope xmlns=\"http://schemas.dmtf.org/ovf/envelope/1\">" > "$OVF_FILE"
echo "<References>" >> "$OVF_FILE"

for diskline in "${DISKS[@]}"; do
    diskdev=$(echo "$diskline" | cut -d':' -f1)
    diskinfo=$(echo "$diskline" | cut -d':' -f2-)
    diskfile=$(echo "$diskinfo" | cut -d',' -f1)
    
    # Resolve full disk path (assuming local-lvm or local storage)
    if [[ "$diskfile" == local-lvm:* ]]; then
        volname=${diskfile#local-lvm:}
        rawfile="/dev/mapper/pve-${volname}"
    elif [[ "$diskfile" == local:* ]]; then
        volname=${diskfile#local:}
        rawfile="/var/lib/vz/images/${VMID}/${volname}"
    else
        rawfile="$diskfile"  # fallback
    fi

    vmdk="${OVADIR}/${diskdev}.vmdk"
    echo "Converting disk $diskdev ($rawfile) to VMDK..."
    qemu-img convert -O vmdk "$rawfile" "$vmdk"
    VMDK_FILES+=("$vmdk")

    # Add to OVF References
    echo "<File ovf:href=\"$(basename $vmdk)\"/>" >> "$OVF_FILE"
done

echo "</References>" >> "$OVF_FILE"
echo "</Envelope>" >> "$OVF_FILE"

# Create OVA archive
OVA_FILE="${OUTPUT_DIR}/vm${VMID}.ova"
tar -cf "$OVA_FILE" -C "$OVADIR" .

# Cleanup
rm -rf "$TMPDIR"

echo "Export complete: $OVA_FILE"