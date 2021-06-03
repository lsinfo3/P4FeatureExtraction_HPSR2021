/* -*- P4_14 -*- */

#ifdef __TARGET_TOFINO__
#include <tofino/constants.p4>
#include <tofino/intrinsic_metadata.p4>
#include <tofino/primitives.p4>
#include <tofino/stateful_alu_blackbox.p4>
#else
#error This program is intended to compile for Tofino P4 architecture only
#endif

#include "config.p4"
#include "header.p4"
#include "parser.p4"
#include "ingress.p4"
#include "egress.p4"
#include "functions/basicSwitching.p4"
#include "functions/clonePacket.p4"
#include "functions/collisionCheck.p4"
#include "functions/egressDrop.p4"
#include "functions/hash.p4"
#include "functions/iat.p4"
#include "functions/modifyPacket.p4"
#include "functions/prepareTcpFlags.p4"
#include "functions/registerHandling.p4"
#include "functions/time.p4"
#include "functions/updateByteCtr.p4"
#include "functions/updatePktCtr.p4"
#include "functions/updateRxWindow.p4"
#include "functions/updateTcpCwrFlgCtr.p4"
#include "functions/updateTcpEceFlgCtr.p4"
#include "functions/updateTcpUrgFlgCtr.p4"
#include "functions/updateTcpAckFlgCtr.p4"
#include "functions/updateTcpPshFlgCtr.p4"
#include "functions/updateTcpRstFlgCtr.p4"
#include "functions/updateTcpSynFlgCtr.p4"
#include "functions/updateTcpFinFlgCtr.p4"
#include "functions/square.p4"