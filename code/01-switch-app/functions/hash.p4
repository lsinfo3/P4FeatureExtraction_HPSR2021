/* hash-related fields */

field_list ipv4_hash_fields {
    ipv4.srcAddr;
    ipv4.dstAddr;
    ipv4.protocol;
    tcp_udp.srcPort;
    tcp_udp.dstPort;
}

field_list_calculation ipv4_hash {
    input { ipv4_hash_fields; }
    algorithm: crc_32;
    output_width: REGISTER_BITS;
}

action act_compute_hash() {
    modify_field_with_hash_based_offset(mirror_meta.hash_crc32, 0, ipv4_hash, REGISTER_SIZE);
}

table tab_compute_hash {
    actions {
        act_compute_hash;
    }
    default_action: act_compute_hash;
}
