/* if more than 16 bits are defined,
   check if header field sizes are large enough! */
#define REGISTER_BITS 16
#define REGISTER_SIZE 65536
/* definition in bytes,
   IPv4 header size is 20 bytes,
   add inserted metadata size */
#define METADATA_PACKET_LENGTH 145
#define SWITCH_ID 1