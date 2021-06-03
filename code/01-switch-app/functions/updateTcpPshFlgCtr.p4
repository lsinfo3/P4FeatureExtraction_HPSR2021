/*register reg_psh_counter {
    width: 16;
    instance_count: REGISTER_SIZE;
}

table tab_update_psh_counter {
    actions {act_update_psh_counter;}
    default_action: act_update_psh_counter;
}

table tab_clear_psh_counter {
    actions {act_clear_psh_counter;}
    default_action: act_clear_psh_counter;
}

action act_update_psh_counter() {
    salu_update_psh_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

action act_clear_psh_counter() {
    salu_clear_psh_counter.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_psh_counter {
    reg : reg_psh_counter;
    //condition: psh flag is set
    condition_lo: mirror_meta.tmp_psh == 1; 
    //if true
    update_lo_1_predicate : condition_lo;
    //increment value
    update_lo_1_value : register_lo + 1;
    output_value: alu_lo;
    output_dst: udp_flow_meta.psh_ctr;
}

blackbox stateful_alu salu_clear_psh_counter {
    reg : reg_psh_counter;
    //condition: psh flag is set
    condition_lo: mirror_meta.tmp_psh == 1; 
    //if true
    update_lo_1_predicate: condition_lo;
    //set to 1
    update_lo_1_value : 1;
    //else
    update_lo_2_predicate: not condition_lo;
    //set to 0
    update_lo_2_value: 0;
    output_value: register_lo;
    output_dst: udp_flow_meta.psh_ctr;
}*/

