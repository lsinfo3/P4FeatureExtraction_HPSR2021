/* 
 * This application has been forked from basicfwd.c and eal_common_hexdump.c
 */

#include <stdint.h>
#include <stdio.h>
#include <stdlib.h>
#include <inttypes.h>
#include <rte_eal.h>
#include <rte_ethdev.h>
#include <rte_cycles.h>
#include <rte_lcore.h>
#include <rte_mbuf.h>
#include <byteswap.h>
#include <math.h>
#include <signal.h>
#include <stdbool.h>

static volatile bool force_quit;

// DPDK-related parameters
#define RX_RING_SIZE 512
#define TX_RING_SIZE 2048 // won't be used, defined anyway
#define NUM_MBUFS 8191
#define MBUF_CACHE_SIZE 512
#define BURST_SIZE 32
// metadata-related parameters
#define HEADER_OFFSET 34 // size of the header that is ignored when parsing the packet
#define METADATA_QUEUE 50000000 // size of the pre-allocated storage; in metadata packets

static const struct rte_eth_conf port_conf_default = {
	.rxmode = {
		.max_rx_pkt_len = RTE_ETHER_MAX_LEN
	},
};

/*
 * Initial declarations
 */ 

// format of the incoming packet
typedef struct payload {
	//global features
	uint16_t hash_crc32;
	uint8_t switch_id;
	uint8_t hash_collision;
	//per packet features
	uint64_t ingress_global_timestamp;
	uint64_t egress_global_timestamp;
	uint32_t enq_qdepth;
	uint8_t enq_congest_stat;
	uint32_t enq_timestamp;
	uint32_t deq_qdepth;
	uint8_t deq_congest_stat;
	uint32_t deq_timedelta;
	uint16_t pkt_length;
	uint32_t ipv4_src_ip;
	uint32_t ipv4_dst_ip;
	uint16_t tcp_src_port;
	uint16_t tcp_dst_port;
	uint8_t ipv4_protocol;
	//per flow features
	uint32_t pkt_ctr;
	uint32_t byte_ctr;
	uint16_t byte_minimum_ctr;
	uint16_t byte_maximum_ctr;
	uint16_t rx_window_minimum;
	uint16_t rx_window_maximum;
	uint16_t cwr_ctr;
	uint16_t ece_ctr;
	uint16_t urg_ctr;
	uint16_t ack_ctr;
	uint16_t psh_ctr;
	uint16_t rst_ctr;
	uint16_t syn_ctr;
	uint16_t fin_ctr;
	uint32_t actual_timestamp;
	uint32_t first_timestamp;
	uint32_t last_timestamp;
	uint32_t iat;
	uint32_t iat_min;
	uint32_t iat_max;
	uint32_t iat_sum;
	uint32_t iat_sum_sq;
	uint32_t byte_ctr_sq;
	uint32_t flow_duration;

} __attribute__((packed)); //needed because compiler will apply padding otherwise

static struct payload myPayload;
static struct payload metadata[METADATA_QUEUE];
int counter = 0;

static uint32_t tmp_src_ip;
static uint32_t tmp_pkt_ctr;
static uint32_t tmp_byte_sum;
static uint32_t tmp_byte_sqsum;
static uint32_t tmp_iat_sum;
static uint32_t tmp_iat_sqsum;
static uint32_t tmp_flow_duration;

static float inf_byte_avg;
static float inf_byte_sd;
static float inf_iat_avg;
static float inf_iat_sd;
static float inf_bps;
static float inf_pps;

/*
 * Initializes a given port using global settings and with the RX buffers
 * coming from the mbuf_pool passed as a parameter.
 */
static inline int
port_init(uint16_t port, struct rte_mempool *mbuf_pool)
{
	struct rte_eth_conf port_conf = port_conf_default;
	const uint16_t rx_rings = 1, tx_rings = 1;
	uint16_t nb_rxd = RX_RING_SIZE;
	uint16_t nb_txd = TX_RING_SIZE;
	int retval;
	uint16_t q;
	struct rte_eth_dev_info dev_info;
	struct rte_eth_txconf txconf;

	port_conf.rxmode.max_rx_pkt_len = RTE_ETHER_MAX_JUMBO_FRAME_LEN;

	if (!rte_eth_dev_is_valid_port(port))
		return -1;

	retval = rte_eth_dev_info_get(port, &dev_info);
	if (retval != 0) {
		printf("Error during getting device (port %u) info: %s\n",
				port, strerror(-retval));
		return retval;
	}

	if (dev_info.tx_offload_capa & DEV_TX_OFFLOAD_MBUF_FAST_FREE)
		port_conf.txmode.offloads |=
			DEV_TX_OFFLOAD_MBUF_FAST_FREE;

	/* Configure the Ethernet device. */
	retval = rte_eth_dev_configure(port, rx_rings, tx_rings, &port_conf);
	if (retval != 0)
		return retval;

	retval = rte_eth_dev_adjust_nb_rx_tx_desc(port, &nb_rxd, &nb_txd);
	if (retval != 0)
		return retval;

	/* Allocate and set up 1 RX queue per Ethernet port. */
	for (q = 0; q < rx_rings; q++) {
		retval = rte_eth_rx_queue_setup(port, q, nb_rxd,
				rte_eth_dev_socket_id(port), NULL, mbuf_pool);
		if (retval < 0)
			return retval;
	}

	txconf = dev_info.default_txconf;
	txconf.offloads = port_conf.txmode.offloads;
	/* Allocate and set up 1 TX queue per Ethernet port. */
	for (q = 0; q < tx_rings; q++) {
		retval = rte_eth_tx_queue_setup(port, q, nb_txd,
				rte_eth_dev_socket_id(port), &txconf);
		if (retval < 0)
			return retval;
	}

	/* Start the Ethernet port. */
	retval = rte_eth_dev_start(port);
	if (retval < 0)
		return retval;

	/* Display the port MAC address. */
	struct rte_ether_addr addr;
	retval = rte_eth_macaddr_get(port, &addr);
	if (retval != 0)
		return retval;

	printf("Port %u MAC: %02" PRIx8 " %02" PRIx8 " %02" PRIx8
			   " %02" PRIx8 " %02" PRIx8 " %02" PRIx8 "\n",
			port,
			addr.addr_bytes[0], addr.addr_bytes[1],
			addr.addr_bytes[2], addr.addr_bytes[3],
			addr.addr_bytes[4], addr.addr_bytes[5]);

	/* Enable RX in promiscuous mode for the Ethernet device. */
	retval = rte_eth_promiscuous_enable(port);
	if (retval != 0)
		return retval;

	return 0;
}

/*
 * The lcore main. This is the main thread that does the work
 */
static //__attribute__((noreturn)) void
int lcore_main(void)
{
	uint16_t port;
	port = 0;

	static FILE * outputFile;
	outputFile = fopen("rx.csv", "w");

	/*
	 * Check that the port is on the same NUMA node as the polling thread
	 * for best performance.
	 */
	// RTE_ETH_FOREACH_DEV(port)
	if (rte_eth_dev_socket_id(port) > 0 &&
			rte_eth_dev_socket_id(port) !=
					(int)rte_socket_id())
		printf("WARNING, port %u is on remote NUMA node to "
				"polling thread.\n\tPerformance will "
				"not be optimal.\n", port);
		printf("\nCore %u forwarding packets. [Ctrl+C to quit]\n",
		rte_lcore_id());
	
	/* Run until the application is quit or killed. */
	while (!force_quit) {
		/* Get burst of RX packets. */
		struct rte_mbuf *bufs[BURST_SIZE];
		const uint16_t nb_rx = rte_eth_rx_burst(port, 0, bufs, BURST_SIZE);
		
		/* If packets have been received, process them. */
		if (nb_rx != 0) 
		{
			for (int i = 0; i < nb_rx; i++)
			{
				const unsigned char *data = rte_pktmbuf_mtod(bufs[i], void *);
				
				// skip headers
				data = data + HEADER_OFFSET;
				// copy raw data into metadata struct
				rte_memcpy(&myPayload, data, sizeof(struct payload));
				// add entry to metadata struct
				metadata[counter] = myPayload;
				counter++;
				// in case the pre-allocated storage is full, reset counter and start over
				if (counter >= METADATA_QUEUE) {
					counter = 0;
					printf("Memory exhausted. Overwriting existing data.\n");
				}
				rte_pktmbuf_free(bufs[i]);
			}
		}
	}
	/* Calc inferred values for each metadata packet and save it.
	   This part runs only if the application has recieved a SIGINT or SIGTERM. */
	// CSV header line
	fprintf(outputFile, "hash_crc32, switch_id, hash_collision, ingress_global_timestamp, egress_global_timestamp, enq_qdepth, enq_congest_stat, enq_timestamp, deq_qdepth, deq_congest_stat, deq_timedelta, pkt_length, ipv4_src_ip, ipv4_dst_ip, tcp_src_port, tcp_dst_port, ipv4_protocol, pkt_ctr, byte_ctr, byte_minimum_ctr, byte_maximum_ctr, rx_window_minimum, rx_window_maximum, cwr_ctr, ece_ctr, urg_ctr, ack_ctr, psh_ctr, rst_ctr, syn_ctr, fin_ctr, actual_timestamp, first_timestamp, last_timestamp, iat, iat_min, iat_max, iat_sum, iat_sum_sq, byte_ctr_sq, flow_duration, byte_avg, byte_sd, iat_avg, iat_sd, bps, pps\n");
	for (int i = 0; i < counter; i++)
	{
		tmp_src_ip = (__bswap_32((&metadata[i])->ipv4_src_ip));
		if (tmp_src_ip != 0) // check validity of packet
		{ 
			// calc inferred values
			tmp_pkt_ctr = __bswap_32((&metadata[i])->pkt_ctr);
			tmp_byte_sum = __bswap_32((&metadata[i])->byte_ctr);
			tmp_byte_sqsum = __bswap_32((&metadata[i])->byte_ctr_sq);
			tmp_iat_sum = __bswap_32((&metadata[i])->iat_sum);
			tmp_iat_sqsum = __bswap_32((&metadata[i])->iat_sum_sq);
			tmp_flow_duration = __bswap_32((&metadata[i])->flow_duration);
			
			if (tmp_pkt_ctr > 1)
			{
			inf_byte_avg = (float) tmp_byte_sum / (float) tmp_pkt_ctr;
			inf_byte_sd = sqrt(tmp_byte_sqsum - ((1.0/(float) tmp_pkt_ctr) * pow(tmp_byte_sum, 2)));
			inf_iat_avg = (float) tmp_flow_duration / (float) tmp_pkt_ctr;
			inf_iat_sd = sqrt(tmp_iat_sqsum - ((1.0/(float) tmp_pkt_ctr) * pow(tmp_iat_sum, 2)));
			inf_bps = (float) tmp_byte_sum / ((float) tmp_flow_duration / 1000000.0);
			inf_pps = (float) tmp_pkt_ctr / ((float) tmp_flow_duration / 1000000.0);
			if (isnan(inf_byte_sd)) {inf_byte_sd = 0;}
			if (isnan(inf_iat_sd)) {inf_byte_sd = 0;}
			}
			else 
			{
			inf_byte_avg = 0;
			inf_byte_sd = 0;
			inf_iat_avg = 0;
			inf_iat_sd = 0;
			inf_bps = 0;
			inf_pps = 0;
			}


			
			fprintf(outputFile, "%u,%u,%u,%lu,%lu,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%u,%f,%f,%f,%f,%f,%f\n", __bswap_16((&metadata[i])->hash_crc32), (&metadata[i])->switch_id, (&metadata[i])->hash_collision, __bswap_64((&metadata[i])->ingress_global_timestamp), __bswap_64((&metadata[i])->egress_global_timestamp), __bswap_32((&metadata[i])->enq_qdepth), (&metadata[i])->enq_congest_stat, __bswap_32((&metadata[i])->enq_timestamp), __bswap_32((&metadata[i])->deq_qdepth), (&metadata[i])->deq_congest_stat, __bswap_32((&metadata[i])->deq_timedelta), __bswap_32((&metadata[i])->pkt_length), tmp_src_ip, __bswap_32((&metadata[i])->ipv4_dst_ip), __bswap_16((&metadata[i])->tcp_src_port), __bswap_16((&metadata[i])->tcp_dst_port), (&metadata[i])->ipv4_protocol, tmp_pkt_ctr, tmp_byte_sum, __bswap_16((&metadata[i])->byte_minimum_ctr), __bswap_16((&metadata[i])->byte_maximum_ctr), __bswap_16((&metadata[i])->rx_window_minimum), __bswap_16((&metadata[i])->rx_window_maximum), __bswap_16((&metadata[i])->cwr_ctr), __bswap_16((&metadata[i])->ece_ctr), __bswap_16((&metadata[i])->urg_ctr), __bswap_16((&metadata[i])->ack_ctr), __bswap_16((&metadata[i])->psh_ctr), __bswap_16((&metadata[i])->rst_ctr), __bswap_16((&metadata[i])->syn_ctr), __bswap_16((&metadata[i])->fin_ctr), __bswap_32((&metadata[i])->actual_timestamp), __bswap_32((&metadata[i])->first_timestamp), __bswap_32((&metadata[i])->last_timestamp), __bswap_32((&metadata[i])->iat), __bswap_32((&metadata[i])->iat_min), __bswap_32((&metadata[i])->iat_max), tmp_iat_sum, tmp_iat_sqsum, tmp_byte_sqsum, tmp_flow_duration, inf_byte_avg, inf_byte_sd, inf_iat_avg, inf_iat_sd, inf_bps, inf_pps);
		}
		else 
		{
			// fprintf(outputFile, "drop\n");  // DEBUG
		}
	}
	fflush(outputFile);
}

static void
signal_handler(int signum)
{
	if (signum == SIGINT || signum == SIGTERM) {
		printf("\n\nSignal %d received, preparing to exit...\n",
				signum);
		force_quit = true;
	}
}

/*
 * The main function, which does initialization and calls the per-lcore
 * functions.
 */
int
main(int argc, char *argv[])
{
	struct rte_mempool *mbuf_pool;
	unsigned nb_ports;
	uint16_t portid;

	portid = 0;

	/* Initialize the Environment Abstraction Layer (EAL). */
	int ret = rte_eal_init(argc, argv);
	if (ret < 0)
		rte_exit(EXIT_FAILURE, "Error with EAL initialization\n");

	argc -= ret;
	argv += ret;

	force_quit = false;
	signal(SIGINT, signal_handler);
	signal(SIGTERM, signal_handler);

	// not used since we only want to receive on a specific port. manually setting nb_ports to 1
    /* Check that there is an even number of ports to send/receive on. */
	nb_ports = rte_eth_dev_count_avail();
	if (nb_ports < 2 || (nb_ports & 1))
		rte_exit(EXIT_FAILURE, "Error: number of ports must be even\n");

	/* Creates a new mempool in memory to hold the mbufs. */
	// mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", NUM_MBUFS * nb_ports,
	// 	MBUF_CACHE_SIZE, 0, RTE_MBUF_DEFAULT_BUF_SIZE, rte_socket_id());

	mbuf_pool = rte_pktmbuf_pool_create("MBUF_POOL", NUM_MBUFS * nb_ports,
		MBUF_CACHE_SIZE, 0, RTE_ETHER_MAX_JUMBO_FRAME_LEN, rte_socket_id());


	if (mbuf_pool == NULL)
		rte_exit(EXIT_FAILURE, "Cannot create mbuf pool\n");

	/* Initialize all ports. */
	//RTE_ETH_FOREACH_DEV(portid)
		if (port_init(portid, mbuf_pool) != 0)
			rte_exit(EXIT_FAILURE, "Cannot init port %"PRIu16 "\n",
					portid);

	if (rte_lcore_count() > 1)
		printf("\nWARNING: Too many lcores enabled. Only 1 used.\n");

	rte_eth_dev_set_mtu(0, 16000);
	/* Call lcore_main on the master core only. */
	lcore_main();

	return 0;
}
