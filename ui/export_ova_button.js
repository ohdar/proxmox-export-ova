{
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