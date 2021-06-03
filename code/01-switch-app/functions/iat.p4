/* implement iat and derived features */

register reg_last_timestamp {
    width: 32;
    instance_count: REGISTER_SIZE;
}

register reg_first_timestamp {
    width: 32;
    instance_count: REGISTER_SIZE;
}

// register reg_iat_min {
//     width: 32;
//     instance_count: REGISTER_SIZE;
// }

// register reg_iat_max {
//     width: 32;
//     instance_count: REGISTER_SIZE;
// }

table tab_update_last_timestamp {
    actions {act_update_last_timestamp;}
    default_action: act_update_last_timestamp;
}

table tab_clear_last_timestamp {
    actions {act_clear_last_timestamp;}
    default_action: act_clear_last_timestamp;
}

table tab_update_first_timestamp {
    actions {act_update_first_timestamp;}
    default_action: act_update_first_timestamp;
}

table tab_clear_first_timestamp {
    actions {act_clear_first_timestamp;}
    default_action: act_clear_first_timestamp;
}

// table tab_update_iat_min {
//     actions {act_update_iat_min;}
//     default_action: act_update_iat_min;
// }

// table tab_clear_iat_min {
//     actions {act_clear_iat_min;}
//     default_action: act_clear_iat_min;
// }

// table tab_update_iat_max {
//     actions {act_update_iat_max;}
//     default_action: act_update_iat_max;
// }

// table tab_clear_iat_max {
//     actions {act_clear_iat_max;}
//     default_action: act_clear_iat_max;
// }

table tab_calc_iat {
    actions {act_calc_iat;}
    default_action: act_calc_iat;
}

table tab_calc_iat_2 {
    actions {act_calc_iat_2;}
    default_action: act_calc_iat_2;
}

action act_update_last_timestamp() {
    salu_update_last_timestamp.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_last_timestamp() {
    salu_clear_last_timestamp.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_update_first_timestamp() {
    salu_update_first_timestamp.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_first_timestamp() {
    salu_clear_first_timestamp.execute_stateful_alu(mirror_meta.hash_crc32);
}

// action act_update_iat_min() {
//     salu_update_iat_min.execute_stateful_alu(mirror_meta.hash_crc32);
// }

// action act_clear_iat_min() {
//     salu_clear_iat_min.execute_stateful_alu(mirror_meta.hash_crc32);
// }

// action act_update_iat_max() {
//     salu_update_iat_max.execute_stateful_alu(mirror_meta.hash_crc32);
// }

// action act_clear_iat_max() {
//     salu_clear_iat_max.execute_stateful_alu(mirror_meta.hash_crc32);
// }

action act_calc_iat() {
    //subtract(udp_flow_meta.iat, mirror_meta.tmp_sys_time, udp_flow_meta.last_timestamp);
    subtract(udp_flow_meta.flow_duration, udp_flow_meta.last_timestamp, udp_flow_meta.first_timestamp);
}

action act_calc_iat_2() {
    subtract(udp_flow_meta.iat, mirror_meta.tmp_sys_time, udp_flow_meta.last_timestamp);
    subtract(udp_flow_meta.flow_duration, udp_flow_meta.actual_timestamp, udp_flow_meta.first_timestamp);
}

blackbox stateful_alu salu_update_last_timestamp {
    reg : reg_last_timestamp;
    update_lo_1_value : mirror_meta.tmp_sys_time;
    output_value: register_lo; //sic! LAST timestamp!
    output_dst: udp_flow_meta.last_timestamp;
}

blackbox stateful_alu salu_clear_last_timestamp {
    reg : reg_last_timestamp;
    update_lo_1_value : mirror_meta.tmp_sys_time;
    output_value: register_lo;
    output_dst: udp_flow_meta.last_timestamp;
}

blackbox stateful_alu salu_update_first_timestamp {
    reg : reg_first_timestamp;
    output_value: register_lo;
    output_dst: udp_flow_meta.first_timestamp;
}

blackbox stateful_alu salu_clear_first_timestamp {
    reg : reg_first_timestamp;
    update_lo_1_value : mirror_meta.tmp_sys_time;
    output_value: register_lo;
    output_dst: udp_flow_meta.first_timestamp;
}

// blackbox stateful_alu salu_update_iat_min {
//     reg : reg_iat_min;
//     condition_lo: udp_flow_meta.iat < register_lo;
//     update_lo_1_predicate: condition_lo;
//     update_lo_1_value : udp_flow_meta.iat;
//     update_lo_2_predicate: not condition_lo;
//     update_lo_2_value: register_lo;
//     output_value: alu_lo;
//     output_dst: udp_flow_meta.iat_min;
// }

// blackbox stateful_alu salu_clear_iat_min {
//     reg : reg_iat_min;
//     update_lo_1_value : udp_flow_meta.iat;
//     output_value: register_lo;
//     output_dst: udp_flow_meta.iat_min;
// }

// blackbox stateful_alu salu_update_iat_max {
//     reg : reg_iat_max;
//     condition_lo: udp_flow_meta.iat > register_lo;
//     update_lo_1_predicate: condition_lo;
//     update_lo_1_value : udp_flow_meta.iat;
//     update_lo_2_predicate: not condition_lo;
//     update_lo_2_value: register_lo;
//     output_value: alu_lo;
//     output_dst: udp_flow_meta.iat_max;
// }

// blackbox stateful_alu salu_clear_iat_max {
//     reg : reg_iat_max;
//     update_lo_1_value : udp_flow_meta.iat;
//     output_value: register_lo;
//     output_dst: udp_flow_meta.iat_max;
// }

/*register reg_iat_sum {
    width: 32;
    instance_count: REGISTER_SIZE;
}

table tab_update_iat_sum {
    actions {act_update_iat_sum;}
    default_action: act_update_iat_sum;
}

action act_update_iat_sum() {
    salu_update_iat_sum.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_iat_sum {
    reg : reg_iat_sum;
    update_lo_1_value : register_lo + udp_flow_meta.iat;
    output_value: alu_lo;
    output_dst: udp_flow_meta.iat_sum;
}*/