/*register reg_rx_window_minimum {
    width: 16;
    instance_count: REGISTER_SIZE;
}

register reg_rx_window_maximum {
    width: 16;
    instance_count: REGISTER_SIZE;
}

table tab_update_rx_window_minimum {
    actions {act_update_rx_window_minimum;}
    default_action: act_update_rx_window_minimum;
}

table tab_update_rx_window_maximum {
    actions {act_update_rx_window_maximum;}
    default_action: act_update_rx_window_maximum;
}

table tab_clear_rx_window_minimum {
    actions {act_clear_rx_window_minimum;}
    default_action: act_clear_rx_window_minimum;
}

table tab_clear_rx_window_maximum {
    actions {act_clear_rx_window_maximum;}
    default_action: act_clear_rx_window_maximum;
}

action act_update_rx_window_minimum() {
    salu_update_rx_window_minimum.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_update_rx_window_maximum() {
    salu_update_rx_window_maximum.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_rx_window_minimum() {
    salu_clear_rx_window_minimum.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_rx_window_maximum() {
    salu_clear_rx_window_maximum.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_rx_window_minimum {
    reg : reg_rx_window_minimum;
    condition_lo: tcp.window < register_lo;
    update_lo_1_predicate: condition_lo;
    update_lo_1_value : tcp.window;
    update_lo_2_predicate: not condition_lo;
    update_lo_2_value: register_lo;
    output_value: alu_lo;
    output_dst: udp_flow_meta.rx_window_minimum;
}

blackbox stateful_alu salu_update_rx_window_maximum {
    reg : reg_rx_window_maximum;
    condition_lo: tcp.window > register_lo;
    update_lo_1_predicate: condition_lo;
    update_lo_1_value : tcp.window;
    update_lo_2_predicate: not condition_lo;
    update_lo_2_value: register_lo;
    output_value: alu_lo;
    output_dst: udp_flow_meta.rx_window_maximum;
}

blackbox stateful_alu salu_clear_rx_window_minimum {
    reg : reg_rx_window_minimum;
    update_lo_1_value : tcp.window;
    output_value: register_lo;
    output_dst: udp_flow_meta.rx_window_minimum;
}

blackbox stateful_alu salu_clear_rx_window_maximum {
    reg : reg_rx_window_maximum;
    update_lo_1_value : tcp.window;
    output_value: register_lo;
    output_dst: udp_flow_meta.rx_window_maximum;
}*/