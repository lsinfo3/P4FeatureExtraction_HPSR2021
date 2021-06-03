/* implement approx. system time in microsec precision */

control calcSystemTime {
    apply(tab_prepare_timestamp);
    apply(tab_prepare_timestamp_2);
    apply(tab_check_time_overflow);
    apply(tab_increment_time_high);
    apply(tab_calc_system_time);
    apply(tab_calc_system_time_2);
    apply(tab_calc_system_time_3);
}

/*****************************/

table tab_prepare_timestamp {
    actions {act_prepare_timestamp;}
    default_action: act_prepare_timestamp;
}

action act_prepare_timestamp() {
    // get 64-bit global timestamp and truncate it, the 32 LSBs remain
    modify_field(mirror_meta.tmp_time_trunc, eg_intr_md_from_parser_aux.egress_global_tstamp);    
}

table tab_prepare_timestamp_2 {
    actions {act_prepare_timestamp_2;}
    default_action: act_prepare_timestamp_2;
}

action act_prepare_timestamp_2() {
    // shift right by 10, micro-second precision (22 LSBs) remain
    shift_right(mirror_meta.tmp_time_low, mirror_meta.tmp_time_trunc, 10);     
}

/*****************************/

register reg_time_low {
    width: 32;
    instance_count: 1;
}

table tab_check_time_overflow {
    actions {act_check_time_overflow;}
    default_action: act_check_time_overflow;
}

action act_check_time_overflow() {
    salu_check_time_overflow.execute_stateful_alu(0);
}

blackbox stateful_alu salu_check_time_overflow {
    reg : reg_time_low;
    condition_lo: mirror_meta.tmp_time_low <= register_lo; 
    update_lo_1_predicate : condition_lo;
    update_lo_1_value : mirror_meta.tmp_time_low;
    update_lo_2_predicate : not condition_lo;
    update_lo_2_value: mirror_meta.tmp_time_low;
    //increment value
    update_hi_1_predicate: condition_lo;
    update_hi_1_value: 1; //overflow happened
    update_hi_2_predicate: not condition_lo;
    update_hi_2_value: 0; //no overflow

    output_value: alu_hi;
    output_dst: mirror_meta.tmp_time_overflow_yesno;
}

/*****************************/

register reg_time_high {
    width: 32;
    instance_count: 1;
}

table tab_increment_time_high {
    actions {act_increment_time_high;}
    default_action: act_increment_time_high;
}

action act_increment_time_high() {
    salu_increment_time_high.execute_stateful_alu(0);
}

blackbox stateful_alu salu_increment_time_high {
    reg : reg_time_high;
    condition_lo: mirror_meta.tmp_time_overflow_yesno == 1; 
    update_lo_1_predicate : condition_lo;
    update_lo_1_value : register_lo + 1;
    update_lo_2_predicate : not condition_lo;
    update_lo_2_value: register_lo;

    output_value: alu_lo;
    output_dst: mirror_meta.tmp_time_high;
}

/*****************************/

table tab_calc_system_time {
    actions {act_calc_system_time;}
    default_action: act_calc_system_time;
}

action act_calc_system_time() {
    shift_left(mirror_meta.tmp_time_high, mirror_meta.tmp_time_high, 22);   
}

table tab_calc_system_time_2 {
    actions {act_calc_system_time_2;}
    default_action: act_calc_system_time_2;
}

action act_calc_system_time_2() {
    add(mirror_meta.tmp_sys_time, mirror_meta.tmp_time_high, mirror_meta.tmp_time_low);  
}

table tab_calc_system_time_3 {
    actions {act_calc_system_time_3;}
    default_action: act_calc_system_time_3;
}

action act_calc_system_time_3() {
    modify_field(udp_flow_meta.actual_timestamp, mirror_meta.tmp_sys_time);
}