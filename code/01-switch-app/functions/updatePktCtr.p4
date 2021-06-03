register reg_pkt_counter {
    width: 32;
    instance_count: REGISTER_SIZE;
}

table tab_update_pkt_counter {
    actions {act_update_pkt_counter;}
    default_action: act_update_pkt_counter;
}

table tab_clear_pkt_counter {
    actions {act_clear_pkt_counter;}
    default_action: act_clear_pkt_counter;
}

action act_update_pkt_counter() {
    salu_update_pkt_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_pkt_counter() {
    salu_clear_pkt_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_pkt_counter {
    reg : reg_pkt_counter;
    update_lo_1_value : register_lo + 1;
    output_value: alu_lo;
    output_dst: udp_flow_meta.pkt_ctr;
}

blackbox stateful_alu salu_clear_pkt_counter {
    reg : reg_pkt_counter;
    update_lo_1_value : 1;
    output_value: register_lo;
    output_dst: udp_flow_meta.pkt_ctr;
}
