/* implement packet mirroring */
action act_clone_packet() {
    modify_field(mirror_meta.mirror_type, 0);
    modify_field(mirror_meta.ingress_port, ig_intr_md.ingress_port);
    modify_field(mirror_meta.mirror_sess, 100);
    clone_egress_pkt_to_egress(100, mirror_list);
}

table tab_clone_packet {
    actions {
        act_clone_packet;
    }
    default_action: act_clone_packet;
}