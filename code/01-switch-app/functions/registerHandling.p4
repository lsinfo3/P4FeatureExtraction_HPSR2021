/* control flows that update and clear the registers */

control clearRegisters {
    apply(tab_clear_pkt_counter);
    apply(tab_clear_byte_counter);
    //apply(tab_clear_byte_minimum_counter);
    //apply(tab_clear_byte_maximum_counter);
    //apply(tab_clear_rx_window_minimum);
    //apply(tab_clear_rx_window_maximum);
    //apply(tab_clear_cwr_counter);
    //apply(tab_clear_ece_counter);
    //apply(tab_clear_urg_counter);
    apply(tab_clear_ack_counter);
    //apply(tab_clear_psh_counter);
    apply(tab_clear_rst_counter);
    apply(tab_clear_syn_counter);
    apply(tab_clear_fin_counter);
    apply(tab_clear_last_timestamp);
    apply(tab_clear_first_timestamp);
    apply(tab_calc_iat);
    //apply(tab_clear_iat_min);
    //apply(tab_clear_iat_max);
    //iat_sum doesn't need to be cleared since it is a math unit
    //apply(tab_clear_iat_sqsum);
    //byte_counter_sq doesn't need to be cleared since it is a math unit
    apply(tab_clear_byte_counter_sqsum);
}

control updateRegisters {
    apply(tab_update_pkt_counter);
    apply(tab_update_byte_counter);
    //apply(tab_update_byte_minimum_counter);
    //apply(tab_update_byte_maximum_counter);
    //apply(tab_update_rx_window_minimum);
    //apply(tab_update_rx_window_maximum);
    //apply(tab_update_cwr_counter);
    //apply(tab_update_ece_counter);
    //apply(tab_update_urg_counter);
    apply(tab_update_ack_counter);
    //apply(tab_update_psh_counter);
    apply(tab_update_rst_counter);
    apply(tab_update_syn_counter);
    apply(tab_update_fin_counter);
    apply(tab_update_last_timestamp);
    apply(tab_update_first_timestamp);
    apply(tab_calc_iat_2);
    //apply(tab_update_iat_min);
    //apply(tab_update_iat_max);
    //apply(tab_update_iat_sum);
    //apply(tab_update_iat_sqsum);
    apply(tab_update_byte_counter_sq);
    apply(tab_update_byte_counter_sqsum);
}