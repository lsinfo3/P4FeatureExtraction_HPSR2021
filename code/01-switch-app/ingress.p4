/* ingress processing */
control ingress {
    /* basic switching */
    apply(ipv4_host) {
        miss {
            apply(ipv4_lpm);
        }
    }  
}
