/* calc modulo of 2^n with bitshifts
   can be used to sample every n-th packet from a flow */

// action act_modulo() {
//     shift_left(mirror_meta.modulo, udp_flow_meta.pkt_ctr, 29);
// }

// table tab_modulo {
//     actions {
//         act_modulo;
//     }
//     default_action: act_modulo;
// }

/* code snippet to be inserted in control flow */

// apply(tab_modulo);
// if (mirror_meta.modulo != 0)
// {
//     apply(tab_egress_drop);
// }

/* code snippet to be inserted in header definitions */

// add metadata field
// modulo : 32;