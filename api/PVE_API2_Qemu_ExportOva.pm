package PVE::API2::Qemu::ExportOva;

use strict;
use warnings;
use PVE::RESTHandler;
use base qw(PVE::RESTHandler);

__PACKAGE__->register_method ({
    name => 'export_ova',
    path => 'export-ova',
    method => 'POST',
    description => "Export VM to OVA",
    permissions => {
        check => ['perm', '/nodes/{node}/qemu/{vmid}', ['VM.Audit']],
    },
    parameters => {
        additionalProperties => 0,
        properties => {},
    },
    returns => { type => 'string' },
    code => sub {
        my ($param) = @_;

        my $node = PVE::RESTHandler::path_param('node');
        my $vmid = PVE::RESTHandler::path_param('vmid');

        my $cmd = "/usr/local/bin/export_to_ova_plus.sh $vmid /var/lib/vz/dump";

        system("$cmd &"); # Run async

        return "Export started for VM $vmid";
    }
});

1;