/* implement packet modification to insert metadata */

action act_attach_meta() {
    add_header(udp_meta);
    add_header(udp_flow_meta);
}

action act_remove_meta() {
    remove_header(udp_meta);
    remove_header(udp_flow_meta);
}

action act_insert_metadata() {
    /* per packet features */
    /* global features */
    modify_field(udp_meta.hash_crc32, mirror_meta.hash_crc32);
    modify_field(udp_meta.switch_id, SWITCH_ID);
    modify_field(udp_meta.hash_collision, mirror_meta.hash_collision);
    /* per packet features */
    modify_field(udp_meta.ingress_global_timestamp, ig_intr_md_from_parser_aux.ingress_global_tstamp); 
    modify_field(udp_meta.egress_global_timestamp, eg_intr_md_from_parser_aux.egress_global_tstamp);
    modify_field(udp_meta.enq_qdepth, eg_intr_md.enq_qdepth);
    modify_field(udp_meta.enq_congest_stat, eg_intr_md.enq_congest_stat);
    modify_field(udp_meta.enq_timestamp, eg_intr_md.enq_tstamp);
    modify_field(udp_meta.deq_qdepth, eg_intr_md.deq_qdepth);
    modify_field(udp_meta.deq_congest_stat, eg_intr_md.deq_congest_stat);
    modify_field(udp_meta.deq_timedelta, eg_intr_md.deq_timedelta);
    modify_field(udp_meta.pkt_length, eg_intr_md.pkt_length);
    modify_field(udp_meta.ipv4_src_ip, mirror_meta.src_ip);
    modify_field(udp_meta.ipv4_dst_ip, mirror_meta.dst_ip);
    modify_field(udp_meta.tcp_src_port, mirror_meta.src_port);
    modify_field(udp_meta.tcp_dst_port, mirror_meta.dst_port);
    modify_field(udp_meta.ipv4_protocol, mirror_meta.ipv4_proto);
}

action act_remove_headers() {
    remove_header(tcp_udp);
    remove_header(tcp);
    remove_header(udp);
    remove_header(icmp);
    modify_field(ipv4.protocol, 253);
    modify_field(ipv4.totalLen, METADATA_PACKET_LENGTH);
}

table tab_attach_meta {
    actions {
        act_attach_meta;
    }
    default_action: act_attach_meta;
}

table tab_remove_meta {
    actions {
        act_remove_meta;
    }
    default_action: act_remove_meta;
}

table tab_insert_metadata {
    actions {
        act_insert_metadata;
    }
    default_action: act_insert_metadata;
}

table tab_remove_headers {
    actions {
        act_remove_headers;
    }
    default_action: act_remove_headers;
}