/* Ethernet header */
header_type ethernet_t {
    fields {
        dstAddr   : 48;
        srcAddr   : 48;
        etherType : 16;
    }
}

/* IPv4 header */
header_type ipv4_t {
    fields {
        version        : 4;
        ihl            : 4;
        diffserv       : 8;
        totalLen       : 16;
        identification : 16;
        flags          : 3;
        fragOffset     : 13;
        ttl            : 8;
        protocol       : 8;
        hdrChecksum    : 16;
        srcAddr        : 32;
        dstAddr        : 32;
    }
}

/* Combined TCP/UDP header (first 32 bit) */ 
header_type tcp_udp_t {
    fields {
        srcPort         : 16;
        dstPort         : 16;
    }
}

/* TCP header */
header_type tcp_t {
    fields {
        seqNo           : 32;
        ackNo           : 32;
        dataOffset      : 4;
        res             : 4;
        ctrlFlags       : 8;
        window          : 16;
        checksum        : 16;
        urgentPtr       : 16;
    }
}

/* UDP header */
header_type udp_t {
    fields {
        udpLength       : 16;   //length is keyword in P4
        checksum        : 16;
    }
}

/* ICMP header */
header_type icmp_t {
    fields {
        icmpType        : 8;
        icmpCode        : 8;
        checksum        : 16;
        /* up to 32 bit may follow, ignore */
    }
}

/* Custom UDP metadata header (to send metadata to collection server) */
header_type udp_meta_t {
    fields {
        /* global features */
        hash_crc32                  : 16;
        switch_id                   : 8;
        hash_collision              : 8;
        /* per packet features */
        ingress_global_timestamp    : 64;   // using 64 instead of 48 b/c DPDK has no 48-bit variables
        egress_global_timestamp     : 64;   // see above
        enq_qdepth                  : 32;
        enq_congest_stat            : 8;
        enq_timestamp               : 32;
        deq_qdepth                  : 32;
        deq_congest_stat            : 8;
        deq_timedelta               : 32;
        pkt_length                  : 16;
        ipv4_src_ip                 : 32;
        ipv4_dst_ip                 : 32;
        tcp_src_port                : 16;
        tcp_dst_port                : 16;
        ipv4_protocol               : 8;
    }
}

header_type udp_flow_meta_t {
    fields{
        /* per flow features */
        pkt_ctr                     : 32;
        byte_ctr                    : 32;
        byte_minimum_ctr            : 16; //
        byte_maximum_ctr            : 16; //
        rx_window_minimum           : 16; //
        rx_window_maximum           : 16; //
        cwr_ctr                     : 16; //
        ece_ctr                     : 16; //
        urg_ctr                     : 16; //
        ack_ctr                     : 16;
        psh_ctr                     : 16; //
        rst_ctr                     : 16;
        syn_ctr                     : 16;
        fin_ctr                     : 16;
        actual_timestamp            : 32;
        first_timestamp             : 32;
        last_timestamp              : 32;
        iat                         : 32;
        iat_min                     : 32; //
        iat_max                     : 32; //
        iat_sum                     : 32; //
        iat_sum_sq                  : 32; //
        byte_ctr_sq                 : 32;
        flow_duration               : 32;
    }
}

/* Metadata header used to mirror packets */
header_type mirror_meta_t {
    fields {
        /* internal values */
        mirror_type                 : 1;
        mirror_sess                 : 10;
        ingress_port                : 9;
        _padding1                   : 12;
        /* packet values */
        hash_crc32                  : 16;
        src_ip                      : 32;
        dst_ip                      : 32;
        src_port                    : 16;
        dst_port                    : 16;
        ipv4_proto                  : 8;
        hash_collision              : 8;
        /* temp values */
        tmp_time_trunc              : 32;
        tmp_time_low                : 32;
        tmp_time_overflow_yesno     : 8;
        tmp_time_high               : 32;
        tmp_sys_time                : 32;
        tmp_cwr                     : 8;
        tmp_ece                     : 8;
        tmp_urg                     : 8;
        tmp_ack                     : 8;
        tmp_psh                     : 8;
        tmp_rst                     : 8;
        tmp_syn                     : 8;
        tmp_fin                     : 8;
        tmp_byte_ctr_sq             : 32;   
        tmp_iat_sum_sq              : 32;
    }
}

field_list mirror_list {
    /* limit of 13 values (?) */
    /* internal values */
    mirror_meta.mirror_type;
    mirror_meta.mirror_sess;
    mirror_meta.ingress_port;
    mirror_meta.hash_crc32;
    mirror_meta.hash_collision;
}

header ethernet_t       ethernet;
header ipv4_t           ipv4;
header tcp_udp_t        tcp_udp;
header tcp_t            tcp;
header udp_t            udp;
header icmp_t           icmp;
header udp_meta_t       udp_meta;
header udp_flow_meta_t  udp_flow_meta;

metadata mirror_meta_t mirror_meta;