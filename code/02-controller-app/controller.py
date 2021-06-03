from datetime import datetime
from scapy.layers.inet import Ether, IP, UDP
from scapy.sendrecv import sendp
from struct import *
import numpy as np
import threading

# constant definitions
REGISTER_SIZE = 65536
FLOW_INACTIVITY_MICROSEC = 45000000
POLLING_INTERVAL_SEC = 5.0
HASH_COLLISION_INDICATOR = 2
THIS_SWITCH_ID = 1
THIS_SOURCE_IP = "10.23.42.122"
THIS_DESTINATION_IP = "10.23.42.123"
THIS_IPV4_PROTO = 253

class aggregation():
    
    def __init__(self):
        print("Controller started")
    
    def run(self):  
        # repeat this process every n seconds (if desired, otherwise run as fast as possible)
        # threading.Timer(POLLING_INTERVAL_SEC, self.run).start()
        while True:
            # fetch last system time
            reg_time_high = p4_pd.register_read_reg_time_high(sess_hdl, mypipe, 0, hw_sync_flag)
            reg_time_low = p4_pd.register_read_reg_time_low(sess_hdl, mypipe, 0, hw_sync_flag)
            
            last_system_time = (reg_time_high[0] << 22) + reg_time_low[0]

            # fetch all last timestamps
            reg_last_timestamp = p4_pd.register_range_read_reg_last_timestamp(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_fin_counter = p4_pd.register_range_read_reg_fin_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_rst_counter = p4_pd.register_range_read_reg_rst_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)

            # add all inactive flows to list
            inactive_flows = []       
            for i in range(len(reg_last_timestamp)):
                if reg_last_timestamp[i] != 0:
                    if (last_system_time - reg_last_timestamp[i] >= FLOW_INACTIVITY_MICROSEC) or (reg_fin_counter[i] >= 1) or (reg_rst_counter[i] >= 1):
                        inactive_flows.append(i)
            # print("inactive flows: ", len(inactive_flows))

            # read all registers
            reg_ack_counter = []
            reg_byte_counter = []
            reg_byte_counter_sq_sum = []
            reg_dst_ip = []
            reg_dst_port = []
            reg_fin_counter = []
            reg_first_timestamp = []
            reg_ipv4_proto = []
            reg_last_timestamp = []
            reg_pkt_counter = []
            reg_rst_counter = []
            reg_src_ip = []
            reg_src_port = []
            reg_syn_counter = []
            reg_byte_minimum_counter = []
            reg_byte_maximum_counter = []
            reg_rx_window_minimum = []
            reg_rx_window_maximum = []
            reg_cwr_ctr = []
            reg_ece_ctr = []
            reg_urg_ctr = []
            reg_psh_ctr = []
            reg_iat_min = []
            reg_iat_max = []
            reg_iat_sum = []
            reg_iat_sq_sum = []

            reg_ack_counter = p4_pd.register_range_read_reg_ack_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_byte_counter = p4_pd.register_range_read_reg_byte_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_byte_counter_sq_sum = p4_pd.register_range_read_reg_byte_counter_sqsum(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_dst_ip = p4_pd.register_range_read_reg_dst_ip(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_dst_port = p4_pd.register_range_read_reg_dst_port(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_fin_counter = p4_pd.register_range_read_reg_fin_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_first_timestamp = p4_pd.register_range_read_reg_first_timestamp(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_ipv4_proto = p4_pd.register_range_read_reg_ipv4_proto(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_last_timestamp = p4_pd.register_range_read_reg_last_timestamp(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_pkt_counter = p4_pd.register_range_read_reg_pkt_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_rst_counter = p4_pd.register_range_read_reg_rst_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_src_ip = p4_pd.register_range_read_reg_src_ip(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_src_port = p4_pd.register_range_read_reg_src_port(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            reg_syn_counter = p4_pd.register_range_read_reg_syn_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_byte_minimum_counter = p4_pd.register_range_read_reg_byte_minimum_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_byte_maximum_counter = p4_pd.register_range_read_reg_byte_maximum_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_rx_window_minimum = p4_pd.register_range_read_reg_rx_window_minimum(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_rx_window_maximum = p4_pd.register_range_read_reg_rx_window_maximum(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_cwr_ctr = p4_pd.register_range_read_reg_cwr_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_ece_ctr = p4_pd.register_range_read_reg_ece_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_urg_ctr = p4_pd.register_range_read_reg_urg_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_psh_ctr = p4_pd.register_range_read_reg_psh_counter(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_iat_min = p4_pd.register_range_read_reg_iat_min(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_iat_max = p4_pd.register_range_read_reg_iat_max(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_iat_sum = p4_pd.register_range_read_reg_iat_sum(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)
            # reg_iat_sq_sum = p4_pd.register_range_read_reg_iat_sqsum(sess_hdl, mypipe, 0, REGISTER_SIZE, hw_sync_flag)

            # clear metadata for all inactive flows (batch operation)
            conn_mgr.begin_batch(sess_hdl)
            for i in range(len(inactive_flows)):
                # clear
                p4_pd.register_write_reg_ack_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_byte_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_byte_counter_sqsum(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_dst_ip(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_dst_port(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_fin_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_first_timestamp(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_ipv4_proto(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_last_timestamp(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_pkt_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_rst_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_src_ip(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_src_port(sess_hdl, allpipe, inactive_flows[i], 0)
                p4_pd.register_write_reg_syn_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_byte_minimum_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_byte_maximum_counter(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_rx_window_minimum(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_rx_window_maximum(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_cwr_ctr(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_ece_ctr(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_urg_ctr(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_psh_ctr(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_iat_min(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_iat_max(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_iat_sum(sess_hdl, allpipe, inactive_flows[i], 0)
                # p4_pd.register_write_reg_iat_sum_sq(sess_hdl, allpipe, inactive_flows[i], 0)
            conn_mgr.end_batch(sess_hdl, hwSynchronous = True)
            conn_mgr.complete_operations(sess_hdl) 
            
            # send one metadata packet for each inactive flow
            packets = []

            for i in range(len(inactive_flows)):
                # prepare values
                # global features
                hash_crc32 = np.uint16(inactive_flows[i])
                switch_id = np.uint8(THIS_SWITCH_ID)
                hash_collision = np.uint8(HASH_COLLISION_INDICATOR)
                # # per packet features
                ingress_global_timestamp = np.uint64(0)
                egress_global_timestamp = np.uint64(0)
                enq_qdepth = np.uint32(0)
                enq_congest_stat = np.uint8(0)
                enq_timestamp = np.uint32(0)
                deq_qdepth = np.uint32(0)
                deq_congest_stat = np.uint8(0)
                deq_timedelta = np.uint32(0)
                pkt_length  = np.uint16(0)
                ipv4_src_ip = np.uint32(reg_src_ip[inactive_flows[i]])
                ipv4_dst_ip = np.uint32(reg_dst_ip[inactive_flows[i]])
                tcp_src_port = np.uint16(reg_src_port[inactive_flows[i]])
                tcp_dst_port = np.uint16(reg_dst_port[inactive_flows[i]])
                ipv4_protocol = np.uint8(reg_ipv4_proto[inactive_flows[i]])
                # per flow features
                pkt_ctr = np.uint32(reg_pkt_counter[inactive_flows[i]])
                byte_ctr = np.uint32(reg_byte_counter[inactive_flows[i]])
                byte_minimum_ctr = np.uint16(0) # = np.uint16(reg_byte_minimum_counter[inactive_flows[i]])
                byte_maximum_ctr = np.uint16(0) # = np.uint16(reg_byte_maximum_counter[inactive_flows[i]])
                rx_window_minimum = np.uint16(0) # = np.uint16(reg_rx_window_minimum[inactive_flows[i]])
                rx_window_maximum = np.uint16(0) # = np.uint16(reg_rx_window_maximum[inactive_flows[i]])
                cwr_ctr = np.uint16(0) # = np.uint16(reg_cwr_counter[inactive_flows[i]])
                ece_ctr = np.uint16(0) # = np.uint16(reg_ece_counter[inactive_flows[i]])
                urg_ctr = np.uint16(0) # = np.uint16(reg_urg_counter[inactive_flows[i]])
                ack_ctr = np.uint16(reg_ack_counter[inactive_flows[i]])
                psh_ctr = np.uint16(0) # = np.uint16(reg_psh_counter[inactive_flows[i]])
                rst_ctr = np.uint16(reg_rst_counter[inactive_flows[i]])
                syn_ctr = np.uint16(reg_syn_counter[inactive_flows[i]])
                fin_ctr = np.uint16(reg_fin_counter[inactive_flows[i]])
                actual_timestamp = np.uint32(last_system_time)
                first_timestamp = np.uint32(reg_first_timestamp[inactive_flows[i]])
                last_timestamp = np.uint32(reg_last_timestamp[inactive_flows[i]])
                iat = np.uint32(last_system_time) - np.uint32(reg_last_timestamp[inactive_flows[i]])
                iat_min = np.uint32(0) # = np.uint32(reg_iat_min[inactive_flows[i]])
                iat_max = np.uint32(0) # = np.uint32(reg_iat_max[inactive_flows[i]])
                iat_sum = np.uint32(0) # = np.uint32(reg_iat_sum[inactive_flows[i]])
                iat_sum_sq = np.uint32(0) # = np.uint32(reg_iat_sq_sum[inactive_flows[i]])
                byte_ctr_sq = np.uint32(reg_byte_counter_sq_sum[inactive_flows[i]])
                flow_duration = np.uint32(last_system_time) - np.uint32(reg_first_timestamp[inactive_flows[i]]) 
                
                # pack data according to the metadata packet definition
                data = pack('!HBBQQIBIIBIHIIHHBIIHHHHHHHHHHHHIIIIIIIIII', hash_crc32, switch_id, hash_collision, ingress_global_timestamp, egress_global_timestamp, enq_qdepth, enq_congest_stat, enq_timestamp, deq_qdepth, deq_congest_stat, deq_timedelta, pkt_length, ipv4_src_ip, ipv4_dst_ip, tcp_src_port, tcp_dst_port, ipv4_protocol, pkt_ctr, byte_ctr, byte_minimum_ctr, byte_maximum_ctr, rx_window_minimum, rx_window_maximum, cwr_ctr, ece_ctr, urg_ctr, ack_ctr, psh_ctr, rst_ctr, syn_ctr, fin_ctr, actual_timestamp, first_timestamp, last_timestamp, iat, iat_min, iat_max, iat_sum, iat_sum_sq, byte_ctr_sq, flow_duration)
                packet = Ether()/IP(src=THIS_SOURCE_IP, dst=THIS_DESTINATION_IP, proto=THIS_IPV4_PROTO)/Raw(load=data)
                packets.append(packet)
            
            sendp(packets, iface="enp1s0")

            time.sleep(.500)

# run
mypipe = dev_pipe(3)
allpipe = dev_all()
hw_sync_flag = p4_pd.register_flags_t(read_hw_sync=True)

mirror.session_create(sess_hdl, allpipe, mirror.MirrorSessionInfo_t(mir_type=mirror.MirrorType_e.PD_MIRROR_TYPE_NORM, direction=mirror.Direction_e.PD_DIR_BOTH, mir_id=100, egr_port=428, egr_port_v=True, max_pkt_len=16384))

aggregator = aggregation()
aggregator.run()