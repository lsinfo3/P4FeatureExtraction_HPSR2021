table tab_egress_drop {
    actions {
        act_egress_drop;
    }
    default_action: act_egress_drop;
}

action act_egress_drop() {
    modify_field(eg_intr_md_for_oport.drop_ctl, 1); 
    exit();
}