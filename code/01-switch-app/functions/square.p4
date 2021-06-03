/* implement sqaure operations (approx.) to calculate variance/stddev later */

register reg_byte_counter_sq {
    width: 32;
    instance_count: REGISTER_SIZE;
}

table tab_update_byte_counter_sq {
    actions {act_update_byte_counter_sq;}
    default_action: act_update_byte_counter_sq;
}

action act_update_byte_counter_sq() {
    salu_update_byte_ctr_sq.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_byte_ctr_sq {
    reg : reg_byte_counter_sq;
    update_lo_2_value: math_unit;
    output_value: alu_lo;
    output_dst: mirror_meta.tmp_byte_ctr_sq;

    math_unit_input: ipv4.totalLen;
    math_unit_exponent_shift: 1;
    math_unit_exponent_invert: false;
    math_unit_output_scale: -6;
    math_unit_lookup_table: 225 196 169 144 121 100 81 64 49 36 25 16 9 4 1 0;
}

register reg_byte_counter_sqsum {
    width: 32;
    instance_count: REGISTER_SIZE;
}

table tab_update_byte_counter_sqsum {
    actions {act_update_byte_counter_sqsum;}
    default_action: act_update_byte_counter_sqsum;
}

action act_update_byte_counter_sqsum() {
    salu_update_byte_ctr_sqsum.execute_stateful_alu(mirror_meta.hash_crc32);
}

table tab_clear_byte_counter_sqsum {
    actions {act_clear_byte_counter_sqsum;}
    default_action: act_clear_byte_counter_sqsum;
}

action act_clear_byte_counter_sqsum() {
    salu_clear_byte_ctr_sqsum.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_byte_ctr_sqsum {
    reg : reg_byte_counter_sqsum;
    update_lo_1_value : register_lo + mirror_meta.tmp_byte_ctr_sq;
    output_value: alu_lo;
    output_dst: udp_flow_meta.byte_ctr_sq;
}

blackbox stateful_alu salu_clear_byte_ctr_sqsum {
    reg : reg_byte_counter_sqsum;
    update_lo_1_value : 0;
    output_value: register_lo;
    output_dst: udp_flow_meta.byte_ctr_sq;
}

/*****/

/*register reg_iat_sq {
    width: 32;
    instance_count: REGISTER_SIZE;
}

table tab_update_iat_sq {
    actions {act_update_iat_sq;}
    default_action: act_update_iat_sq;
}

action act_update_iat_sq() {
    salu_update_iat_sq.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_iat_sq {
    reg : reg_iat_sq;
    update_lo_2_value: math_unit;
    output_value: alu_lo;
    output_dst: mirror_meta.tmp_iat_sum_sq;

    math_unit_input: udp_flow_meta.iat;
    math_unit_exponent_shift: 1;
    math_unit_exponent_invert: false;
    math_unit_output_scale: -6;
    math_unit_lookup_table: 225 196 169 144 121 100 81 64 49 36 25 16 9 4 1 0;
}

register reg_iat_sqsum {
    width: 32;
    instance_count: REGISTER_SIZE;
}

table tab_update_iat_sqsum {
    actions {act_update_iat_sqsum;}
    default_action: act_update_iat_sqsum;
}

action act_update_iat_sqsum() {
    salu_update_iat_sqsum.execute_stateful_alu(mirror_meta.hash_crc32);
}

table tab_clear_iat_sqsum {
    actions {act_clear_iat_sqsum;}
    default_action: act_clear_iat_sqsum;
}

action act_clear_iat_sqsum() {
    salu_clear_iat_sqsum.execute_stateful_alu(mirror_meta.hash_crc32);
}

blackbox stateful_alu salu_update_iat_sqsum {
    reg : reg_iat_sqsum;
    update_lo_1_value : register_lo + mirror_meta.tmp_iat_sum_sq;
    output_value: alu_lo;
    output_dst: udp_flow_meta.iat_sum_sq;
}

blackbox stateful_alu salu_clear_iat_sqsum {
    reg : reg_iat_sqsum;
    update_lo_1_value : 0;
    output_value: register_lo;
    output_dst: udp_flow_meta.iat_sum_sq;
}*/


