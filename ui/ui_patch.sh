#!/bin/bash
set -euo pipefail

UI_FILE="/usr/share/pve-manager/js/pvemanagerlib.js"
BACKUP_FILE="${UI_FILE}.bak.$(date +%F-%T)"

if [[ ! -f "$UI_FILE" ]]; then
    echo "ERROR: UI file not found: $UI_FILE"
    exit 1
fi

echo "Backing up $UI_FILE to $BACKUP_FILE"
cp "$UI_FILE" "$BACKUP_FILE"

# Our export button snippet (escaped for sed)
read -r -d '' EXPORT_BUTTON <<'EOF'
,{
    text: gettext('Export to OVA'),
    iconCls: 'fa fa-fw fa-download',
    handler: function() {
        var vmid = this.up('menu').vmid;
        Ext.Msg.confirm(gettext('Export VM'), 
            gettext('Are you sure you want to export VM ' + vmid + ' to OVA?'), 
            function(btn) {
                if (btn === 'yes') {
                    Ext.Msg.wait(gettext('Exporting...'));
                    Proxmox.Utils.API2Request({
                        url: '/nodes/' + PVE.Utils.getNode() + '/qemu/' + vmid + '/export-ova',
                        method: 'POST',
                        success: function(response) {
                            Ext.Msg.alert(gettext('Success'), gettext('Export started.'));
                        },
                        failure: function(response) {
                            Ext.Msg.alert(gettext('Failed'), gettext('Export failed: ') + response.htmlStatus);
                        }
                    });
                }
            }
        );
    }
}
EOF

# Insert after "Backup" menu item line containing text: gettext('Backup')
# Assumes menu items are comma-separated JSON objects

sed -i "/gettext('Backup')/a $EXPORT_BUTTON" "$UI_FILE"

echo "UI patch applied successfully."
echo "Restart pveproxy to reload the UI."