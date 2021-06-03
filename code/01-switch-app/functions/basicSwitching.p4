/* implement basic host/lpm based switching */
action send(port) {
    modify_field(ig_intr_md_for_tm.ucast_egress_port, port);
}

action discard() {
    modify_field(ig_intr_md_for_tm.drop_ctl, 1);
}

table ipv4_host {
    reads {
        ipv4.dstAddr : exact;
    }
    actions {
        send;
        discard;
    }
    size : 4096;
}

table ipv4_lpm {
    reads {
        ipv4.dstAddr : lpm;
    }
    actions {
        send;
        discard;
    }
    default_action: discard;
    size : 4096;
}