/*register reg_ece_counter {
    width: 16;
    instance_count: REGISTER_SIZE;
}

table tab_update_ece_counter {
    actions {act_update_ece_counter;}
    default_action: act_update_ece_counter;
}

table tab_clear_ece_counter {
    actions {act_clear_ece_counter;}
    default_action: act_clear_ece_counter;
}

action act_update_ece_counter() {
    salu_update_ece_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_ece_counter() {
    salu_clear_ece_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_ece_counter {
    reg : reg_ece_counter;
    //condition: ece flag is set
    condition_lo: mirror_meta.tmp_ece == 1; 
    //if true
    update_lo_1_predicate : condition_lo;
    //increment value
    update_lo_1_value : register_lo + 1;
    output_value: alu_lo;
    output_dst: udp_flow_meta.ece_ctr;
}

blackbox stateful_alu salu_clear_ece_counter {
    reg : reg_ece_counter;
    //condition: ece flag is set
    condition_lo: mirror_meta.tmp_ece == 1; 
    //if true
    update_lo_1_predicate: condition_lo;
    //set to 1
    update_lo_1_value : 1;
    //else
    update_lo_2_predicate: not condition_lo;
    //set to 0
    update_lo_2_value: 0;
    output_value: register_lo;
    output_dst: udp_flow_meta.ece_ctr;
}*/

