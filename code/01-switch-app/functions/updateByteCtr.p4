register reg_byte_counter {
    width: 32;
    instance_count: REGISTER_SIZE;
}

// register reg_byte_minimum_counter {
//     width: 16;
//     instance_count: REGISTER_SIZE;
// }

// register reg_byte_maximum_counter {
//     width: 16;
//     instance_count: REGISTER_SIZE;
// }

table tab_update_byte_counter {
    actions {act_update_byte_counter;}
    default_action: act_update_byte_counter;
}

// table tab_update_byte_minimum_counter {
//     actions {act_update_byte_minimum_counter;}
//     default_action: act_update_byte_minimum_counter;
// }

// table tab_update_byte_maximum_counter {
//     actions {act_update_byte_maximum_counter;}
//     default_action: act_update_byte_maximum_counter;
// }

table tab_clear_byte_counter {
    actions {act_clear_byte_counter;}
    default_action: act_clear_byte_counter;
}

// table tab_clear_byte_minimum_counter {
//     actions {act_clear_byte_minimum_counter;}
//     default_action: act_clear_byte_minimum_counter;
// }

// table tab_clear_byte_maximum_counter {
//     actions {act_clear_byte_maximum_counter;}
//     default_action: act_clear_byte_maximum_counter;
// }

action act_update_byte_counter() {
    salu_update_byte_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

// action act_update_byte_minimum_counter() {
//     salu_update_byte_minimum_counter.execute_stateful_alu(mirror_meta.hash_crc32);
// }

// action act_update_byte_maximum_counter() {
//     salu_update_byte_maximum_counter.execute_stateful_alu(mirror_meta.hash_crc32);
// }

action act_clear_byte_counter() {
    salu_clear_byte_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

// action act_clear_byte_minimum_counter() {
//     salu_clear_byte_minimum_counter.execute_stateful_alu(mirror_meta.hash_crc32);
// }

// action act_clear_byte_maximum_counter() {
//     salu_clear_byte_maximum_counter.execute_stateful_alu(mirror_meta.hash_crc32);
// }

blackbox stateful_alu salu_update_byte_counter {
    reg : reg_byte_counter;
    update_lo_1_value : register_lo + ipv4.totalLen;
    output_value: alu_lo;
    output_dst: udp_flow_meta.byte_ctr;
}

// blackbox stateful_alu salu_update_byte_minimum_counter {
//     reg : reg_byte_minimum_counter;
//     condition_lo: ipv4.totalLen < register_lo;
//     update_lo_1_predicate: condition_lo;
//     update_lo_1_value : ipv4.totalLen;
//     update_lo_2_predicate: not condition_lo;
//     update_lo_2_value: register_lo;
//     output_value: alu_lo;
//     output_dst: udp_flow_meta.byte_minimum_ctr;
// }

// blackbox stateful_alu salu_update_byte_maximum_counter {
//     reg : reg_byte_maximum_counter;
//     condition_lo: ipv4.totalLen > register_lo;
//     update_lo_1_predicate: condition_lo;
//     update_lo_1_value : ipv4.totalLen;
//     update_lo_2_predicate: not condition_lo;
//     update_lo_2_value: register_lo;
//     output_value: alu_lo;
//     output_dst: udp_flow_meta.byte_maximum_ctr;
// }

blackbox stateful_alu salu_clear_byte_counter {
    reg : reg_byte_counter;
    update_lo_1_value : ipv4.totalLen;
    output_value: register_lo;
    output_dst: udp_flow_meta.byte_ctr;
}

// blackbox stateful_alu salu_clear_byte_minimum_counter {
//     reg : reg_byte_minimum_counter;
//     update_lo_1_value : ipv4.totalLen;
//     output_value: register_lo;
//     output_dst: udp_flow_meta.byte_minimum_ctr;
// }

// blackbox stateful_alu salu_clear_byte_maximum_counter {
//     reg : reg_byte_maximum_counter;
//     update_lo_1_value : ipv4.totalLen;
//     output_value: register_lo;
//     output_dst: udp_flow_meta.byte_maximum_ctr;
// }