/* checks if a collision occured based on the 5-tuple */

control collisionCheck {
    /* compute hash */
    apply(tab_compute_hash);
    /* check if the 5-tuple is already stored */
    apply(tab_check_src_ip);
    apply(tab_check_dst_ip);
    apply(tab_check_src_port);
    apply(tab_check_dst_port);
    apply(tab_check_ipv4_proto);
    /* check for hash collision */
    if (ipv4.srcAddr == mirror_meta.src_ip) {
        if (ipv4.dstAddr == mirror_meta.dst_ip) {
            if (tcp_udp.srcPort == mirror_meta.src_port) {
                if (tcp_udp.dstPort == mirror_meta.dst_port) {
                    if (ipv4.protocol == mirror_meta.ipv4_proto) {
                        apply(tab_hash_collision_true); //ambiguous name!
                    }
                }
            }
        }
    }
}

register reg_src_ip {
    width: 32;
    instance_count: REGISTER_SIZE;
}

register reg_dst_ip {
    width: 32;
    instance_count: REGISTER_SIZE;
}

register reg_src_port {
    width: 16;
    instance_count: REGISTER_SIZE;
}

register reg_dst_port {
    width: 16;
    instance_count: REGISTER_SIZE;
}

register reg_ipv4_proto {
    width: 8;
    instance_count: REGISTER_SIZE;
}

blackbox stateful_alu salu_src_ip {
    reg: reg_src_ip;
    //condition: packet.src_ip matches register.src_ip 
    condition_lo : register_lo == ipv4.srcAddr;
    update_lo_1_predicate : not condition_lo;
    update_lo_1_value : ipv4.srcAddr;
    output_value: register_lo;
    output_dst: mirror_meta.src_ip;
}

blackbox stateful_alu salu_dst_ip {
    reg: reg_dst_ip;
    condition_lo : register_lo == ipv4.dstAddr;
    update_lo_1_predicate : not condition_lo;
    update_lo_1_value : ipv4.dstAddr;
    output_value: register_lo;
    output_dst: mirror_meta.dst_ip;
}

blackbox stateful_alu salu_src_port {
    reg: reg_src_port;
    condition_lo : register_lo == tcp_udp.srcPort;
    update_lo_1_predicate : not condition_lo;
    update_lo_1_value : tcp_udp.srcPort;
    output_value: register_lo;
    output_dst: mirror_meta.src_port;
}

blackbox stateful_alu salu_dst_port {
    reg: reg_dst_port;
    condition_lo : register_lo == tcp_udp.dstPort;
    update_lo_1_predicate : not condition_lo;
    update_lo_1_value : tcp_udp.dstPort;
    output_value: register_lo;
    output_dst: mirror_meta.dst_port;
}

blackbox stateful_alu salu_ipv4_proto {
    reg: reg_ipv4_proto;
    condition_lo : register_lo == ipv4.protocol;
    update_lo_1_predicate : not condition_lo;
    update_lo_1_value : ipv4.protocol;
    output_value: register_lo;
    output_dst: mirror_meta.ipv4_proto;
}

action act_check_src_ip() {
    salu_src_ip.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_check_dst_ip() {
    salu_dst_ip.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_check_src_port() {
    salu_src_port.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_check_dst_port() {
    salu_dst_port.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_check_ipv4_proto() {
    salu_ipv4_proto.execute_stateful_alu(mirror_meta.hash_crc32);
}

table tab_check_src_ip {
    actions {
        act_check_src_ip;
    }
    default_action: act_check_src_ip;
}

table tab_check_dst_ip {
    actions {
        act_check_dst_ip;
    }
    default_action: act_check_dst_ip;
}

table tab_check_src_port {
    actions {
        act_check_src_port;
    }
    default_action: act_check_src_port;
}

table tab_check_dst_port {
    actions {
        act_check_dst_port;
    }
    default_action: act_check_dst_port;
}

table tab_check_ipv4_proto {
    actions {
        act_check_ipv4_proto;
    }
    default_action: act_check_ipv4_proto;
}

// action act_hash_collision_false() {
//     modify_field(mirror_meta.hash_collision, 0);
// }

// table tab_hash_collision_false {
//     actions {
//         act_hash_collision_false;
//     }
//     default_action: act_hash_collision_false;
// }

action act_hash_collision_true() {
    modify_field(mirror_meta.hash_collision, 1);
}

table tab_hash_collision_true {
    actions {
        act_hash_collision_true;
    }
    default_action: act_hash_collision_true;
}