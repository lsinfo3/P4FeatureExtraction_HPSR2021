/* implement some preparatory operations to read out the TCP flags */

action act_prepare_tcp_flags() {
    bit_and(mirror_meta.tmp_cwr, tcp.ctrlFlags, 128);
    bit_and(mirror_meta.tmp_ece, tcp.ctrlFlags, 64);
    bit_and(mirror_meta.tmp_urg, tcp.ctrlFlags, 32);
    bit_and(mirror_meta.tmp_ack, tcp.ctrlFlags, 16);
    bit_and(mirror_meta.tmp_psh, tcp.ctrlFlags, 8);
    bit_and(mirror_meta.tmp_rst, tcp.ctrlFlags, 4);
    bit_and(mirror_meta.tmp_syn, tcp.ctrlFlags, 2);
    bit_and(mirror_meta.tmp_fin, tcp.ctrlFlags, 1);
}

table tab_prepare_tcp_flags {
    actions {
        act_prepare_tcp_flags;
    }
    default_action: act_prepare_tcp_flags;
}

action act_prepare_tcp_flags_2() {
    shift_right(mirror_meta.tmp_cwr, mirror_meta.tmp_cwr, 7);
    shift_right(mirror_meta.tmp_ece, mirror_meta.tmp_ece, 6);
    shift_right(mirror_meta.tmp_urg, mirror_meta.tmp_urg, 5);
    shift_right(mirror_meta.tmp_ack, mirror_meta.tmp_ack, 4);
    shift_right(mirror_meta.tmp_psh, mirror_meta.tmp_psh, 3);
    shift_right(mirror_meta.tmp_rst, mirror_meta.tmp_rst, 2);
    shift_right(mirror_meta.tmp_syn, mirror_meta.tmp_syn, 1);
    //shift_right(mirror_meta.tmp_fin, mirror_meta.tmp_fin, 0); //not necessary obviously
}

table tab_prepare_tcp_flags_2 {
    actions {
        act_prepare_tcp_flags_2;
    }
    default_action: act_prepare_tcp_flags_2;
}


