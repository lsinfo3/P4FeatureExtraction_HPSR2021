/* egress processing */
control egress {
    /* check if packet is already mirrored or needs to be cloned */
    if (not pkt_is_mirrored)
    {
        if (not ipv4.protocol == 253)
        {
            apply(tab_clone_packet);
        }
        /* end, send unmodified packet */
    }
    else
    {
        /* perform hash collision check */
        collisionCheck();

        /* attach metadata header */
        apply(tab_attach_meta);

        /* calculate own system time */
        calcSystemTime();
        /* prepare several temp values */
        apply(tab_prepare_tcp_flags);
        apply(tab_prepare_tcp_flags_2);

        /* if hash collision happened, clear registers and send metadata packet (do nothing, is processed to egress) */
        if (mirror_meta.hash_collision == 0) // 0 if values didn't match => hash collision has happened
        {
            clearRegisters();
        }
        /* else update registers*/
        else 
        {
            updateRegisters();
        } 
        /* insert per-packet metadata into metadata header */
        apply(tab_insert_metadata);

        /* if conditions are true, drop the packet actively (no metadata packet is emitted) */
        if (mirror_meta.hash_collision == 1)
        {
            apply(tab_egress_drop);
        }  
        /* remove unnecessary headers and set protocol to 253 */
        apply(tab_remove_headers);    
    }
}