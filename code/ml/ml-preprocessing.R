library(tidyverse)
library(iptools)

##### preparing CICIDS label dataset #####

# labels from CICIDS dataset
labels_monday = read.csv("Labels/Monday-WorkingHours.pcap_ISCX.csv")
labels_tuesday = read.csv("Labels/Tuesday-WorkingHours.pcap_ISCX.csv")
labels_wednesday = read.csv("Labels/Wednesday-workingHours.pcap_ISCX.csv")
labels_thursday_morning = read.csv("Labels/Thursday-WorkingHours-Morning-WebAttacks.pcap_ISCX.csv")
labels_thursday_afternoon = read.csv("Labels/Thursday-WorkingHours-Afternoon-Infilteration.pcap_ISCX.csv")
labels_friday_morning = read.csv("Labels/Friday-WorkingHours-Morning.pcap_ISCX.csv")
labels_friday_ddos = read.csv("Labels/Friday-WorkingHours-Afternoon-DDos.pcap_ISCX.csv")
labels_friday_portscan = read.csv("Labels/Friday-WorkingHours-Afternoon-PortScan.pcap_ISCX.csv")

# own aggregated metadata
ml_monday = read.csv("Metadata/monday.csv")
ml_tuesday = read.csv("Metadata/tuesday.csv")
ml_wednesday = read.csv("Metadata/wednesday.csv")
ml_thursday = read.csv("Metadata/thursday.csv")
ml_friday = read.csv("Metadata/friday.csv")

# combine labels into one df
labels_thursday = rbind(labels_thursday_morning, labels_thursday_afternoon)
rm(labels_thursday_morning)
rm(labels_thursday_afternoon)

labels_friday = rbind(labels_friday_ddos, labels_friday_morning, labels_friday_portscan)
rm(labels_friday_ddos)
rm(labels_friday_morning)
rm(labels_friday_portscan)

# remove unnecessary rows and columns
keep = c("Source.IP", "Source.Port", "Destination.IP", "Destination.Port", "Protocol", "Timestamp", "Label")
labels_monday = labels_monday[keep]
labels_tuesday = labels_tuesday[keep]
labels_wednesday = labels_wednesday[keep]
labels_thursday = labels_thursday[keep]
labels_friday = labels_friday[keep]

labels_monday$Source.IP.Numeric = ip_to_numeric(labels_monday$Source.IP)
labels_monday$Destination.IP.Numeric = ip_to_numeric(labels_monday$Destination.IP)
labels_tuesday$Source.IP.Numeric = ip_to_numeric(labels_tuesday$Source.IP)
labels_tuesday$Destination.IP.Numeric = ip_to_numeric(labels_tuesday$Destination.IP)
labels_wednesday$Source.IP.Numeric = ip_to_numeric(labels_wednesday$Source.IP)
labels_wednesday$Destination.IP.Numeric = ip_to_numeric(labels_wednesday$Destination.IP)
labels_thursday$Source.IP.Numeric = ip_to_numeric(labels_thursday$Source.IP)
labels_thursday$Destination.IP.Numeric = ip_to_numeric(labels_thursday$Destination.IP)
labels_friday$Source.IP.Numeric = ip_to_numeric(labels_friday$Source.IP)
labels_friday$Destination.IP.Numeric = ip_to_numeric(labels_friday$Destination.IP)

labels_wednesday$Label[labels_wednesday$Label == "DoS GoldenEye"] <- "DoS"
labels_wednesday$Label[labels_wednesday$Label == "DoS Hulk"] <- "DoS"
labels_wednesday$Label[labels_wednesday$Label == "DoS Slowhttptest"] <- "DoS"
labels_wednesday$Label[labels_wednesday$Label == "DoS slowloris"] <- "DoS"
labels_wednesday = labels_wednesday %>% filter(Label == "BENIGN" | Label == "DoS")

labels_thursday = labels_thursday %>% filter(Label == "BENIGN")

labels_friday = labels_friday %>% filter(Label == "BENIGN" | Label == "PortScan" | Label == "DDoS")


# generate flow IDs
labels_monday$Flow.ID.Forward =
  paste(labels_monday$Source.IP, labels_monday$Destination.IP,
        labels_monday$Source.Port, labels_monday$Destination.Port,
        labels_monday$Protocol, sep="-")

labels_monday$Flow.ID.Backward =
  paste(labels_monday$Destination.IP, labels_monday$Source.IP,
        labels_monday$Destination.Port, labels_monday$Source.Port,
        labels_monday$Protocol, sep="-")

labels_monday = labels_monday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
keep = c("Flow.ID", "Label")
labels_monday = labels_monday[keep]

#####

labels_tuesday$Flow.ID.Forward =
  paste(labels_tuesday$Source.IP, labels_tuesday$Destination.IP,
        labels_tuesday$Source.Port, labels_tuesday$Destination.Port,
        labels_tuesday$Protocol, sep="-")

labels_tuesday$Flow.ID.Backward =
  paste(labels_tuesday$Destination.IP, labels_tuesday$Source.IP,
        labels_tuesday$Destination.Port, labels_tuesday$Source.Port,
        labels_tuesday$Protocol, sep="-")

labels_tuesday = labels_tuesday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
keep = c("Flow.ID", "Label")
labels_tuesday = labels_tuesday[keep]

#####

labels_wednesday$Flow.ID.Forward =
  paste(labels_wednesday$Source.IP, labels_wednesday$Destination.IP,
        labels_wednesday$Source.Port, labels_wednesday$Destination.Port,
        labels_wednesday$Protocol, sep="-")

labels_wednesday$Flow.ID.Backward =
  paste(labels_wednesday$Destination.IP, labels_wednesday$Source.IP,
        labels_wednesday$Destination.Port, labels_wednesday$Source.Port,
        labels_wednesday$Protocol, sep="-")

labels_wednesday = labels_wednesday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
keep = c("Flow.ID", "Label")
labels_wednesday = labels_wednesday[keep]

#####

labels_thursday$Flow.ID.Forward =
  paste(labels_thursday$Source.IP, labels_thursday$Destination.IP,
        labels_thursday$Source.Port, labels_thursday$Destination.Port,
        labels_thursday$Protocol, sep="-")

labels_thursday$Flow.ID.Backward =
  paste(labels_thursday$Destination.IP, labels_thursday$Source.IP,
        labels_thursday$Destination.Port, labels_thursday$Source.Port,
        labels_thursday$Protocol, sep="-")

labels_thursday = labels_thursday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
keep = c("Flow.ID", "Label")
labels_thursday = labels_thursday[keep]

#####

labels_friday$Flow.ID.Forward =
  paste(labels_friday$Source.IP, labels_friday$Destination.IP,
        labels_friday$Source.Port, labels_friday$Destination.Port,
        labels_friday$Protocol, sep="-")

labels_friday$Flow.ID.Backward =
  paste(labels_friday$Destination.IP, labels_friday$Source.IP,
        labels_friday$Destination.Port, labels_friday$Source.Port,
        labels_friday$Protocol, sep="-")

labels_friday = labels_friday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
keep = c("Flow.ID", "Label")
labels_friday = labels_friday[keep]

# check if there are Flow.IDs that have multiple labels and remove

conflicts_monday = labels_monday %>%
        group_by(Flow.ID) %>%
        unique %>%
        filter(n()>1) %>%
        distinct(Flow.ID)
conflicts_monday = conflicts_monday %>% distinct(Flow.ID)
labels_monday = labels_monday[ ! labels_monday$Flow.ID %in% conflicts_monday$Flow.ID , ]
labels_monday = labels_monday %>% distinct(Flow.ID, .keep_all = TRUE)

conflicts_tuesday = labels_tuesday %>%
        group_by(Flow.ID) %>%
        unique %>%
        filter(n()>1) %>%
        distinct(Flow.ID)
labels_tuesday = labels_tuesday[ ! labels_tuesday$Flow.ID %in% conflicts_tuesday$Flow.ID , ]
labels_tuesday = labels_tuesday %>% distinct(Flow.ID, .keep_all = TRUE)

conflicts_wednesday = labels_wednesday %>%
        group_by(Flow.ID) %>%
        unique %>%
        filter(n()>1) %>%
        distinct(Flow.ID)
conflicts_wednesday = conflicts_wednesday %>% distinct(Flow.ID)
labels_wednesday = labels_wednesday[ ! labels_wednesday$Flow.ID %in% conflicts_wednesday$Flow.ID , ]
labels_wednesday = labels_wednesday %>% distinct(Flow.ID, .keep_all = TRUE)

conflicts_thursday = labels_thursday %>%
        group_by(Flow.ID) %>%
        unique %>%
        filter(n()>1) %>%
        distinct(Flow.ID)
conflicts_thursday = conflicts_thursday %>% distinct(Flow.ID)
labels_thursday = labels_thursday[ ! labels_thursday$Flow.ID %in% conflicts_thursday$Flow.ID , ]
labels_thursday = labels_thursday %>% distinct(Flow.ID, .keep_all = TRUE)

conflicts_friday = labels_friday %>%
        group_by(Flow.ID) %>%
        unique %>%
        filter(n()>1) %>%
        distinct(Flow.ID)
conflicts_friday = conflicts_friday %>% distinct(Flow.ID)
labels_friday = labels_friday[ ! labels_friday$Flow.ID %in% conflicts_friday$Flow.ID , ]
labels_friday = labels_friday %>% distinct(Flow.ID, .keep_all = TRUE)

##### preparing own metadata #####

# remove unnecessary columns
keep = c("hash_collision", "enq_qdepth", "enq_congest_stat", "deq_qdepth", "deq_congest_stat", "deq_timedelta", "pkt_length", 
         
         "ipv4_src_ip", "ipv4_dst_ip", "tcp_src_port", "tcp_dst_port", "ipv4_protocol", 
         
         "pkt_ctr", "byte_ctr", "ack_ctr", "rst_ctr", "syn_ctr", "fin_ctr", "byte_ctr_sq",
         "flow_duration", "byte_avg", "byte_sd", "iat_avg", "bps", "pps")

ml_monday = ml_monday[keep]
ml_monday = ml_monday %>% rename(Source.IP.Numeric = ipv4_src_ip, Destination.IP.Numeric = ipv4_dst_ip)

ml_tuesday = ml_tuesday[keep]
ml_tuesday = ml_tuesday %>% rename(Source.IP.Numeric = ipv4_src_ip, Destination.IP.Numeric = ipv4_dst_ip)

ml_wednesday = ml_wednesday[keep]
ml_wednesday = ml_wednesday %>% rename(Source.IP.Numeric = ipv4_src_ip, Destination.IP.Numeric = ipv4_dst_ip)

ml_thursday = ml_thursday[keep]
ml_thursday = ml_thursday %>% rename(Source.IP.Numeric = ipv4_src_ip, Destination.IP.Numeric = ipv4_dst_ip)

ml_friday = ml_friday[keep]
ml_friday = ml_friday %>% rename(Source.IP.Numeric = ipv4_src_ip, Destination.IP.Numeric = ipv4_dst_ip)


# remove invalid data (if any)
ml_monday = ml_monday %>% filter(Source.IP.Numeric != 0 & Destination.IP.Numeric != 0 &
                                     tcp_src_port != 0 & tcp_dst_port != 0 & ipv4_protocol != 0)
ml_tuesday = ml_tuesday %>% filter(Source.IP.Numeric != 0 & Destination.IP.Numeric != 0 &
                                   tcp_src_port != 0 & tcp_dst_port != 0 & ipv4_protocol != 0)
ml_wednesday = ml_wednesday %>% filter(Source.IP.Numeric != 0 & Destination.IP.Numeric != 0 &
                                   tcp_src_port != 0 & tcp_dst_port != 0 & ipv4_protocol != 0)
ml_thursday = ml_thursday %>% filter(Source.IP.Numeric != 0 & Destination.IP.Numeric != 0 &
                                   tcp_src_port != 0 & tcp_dst_port != 0 & ipv4_protocol != 0)
ml_friday = ml_friday %>% filter(Source.IP.Numeric != 0 & Destination.IP.Numeric != 0 &
                                  tcp_src_port != 0 & tcp_dst_port != 0 & ipv4_protocol != 0)

# add ip addresses in octet notation
ml_monday$Source.IP = numeric_to_ip(ml_monday$Source.IP.Numeric)
ml_monday$Destination.IP = numeric_to_ip(ml_monday$Destination.IP.Numeric)

ml_tuesday$Source.IP = numeric_to_ip(ml_tuesday$Source.IP.Numeric)
ml_tuesday$Destination.IP = numeric_to_ip(ml_tuesday$Destination.IP.Numeric)

ml_wednesday$Source.IP = numeric_to_ip(ml_wednesday$Source.IP.Numeric)
ml_wednesday$Destination.IP = numeric_to_ip(ml_wednesday$Destination.IP.Numeric)

ml_thursday$Source.IP = numeric_to_ip(ml_thursday$Source.IP.Numeric)
ml_thursday$Destination.IP = numeric_to_ip(ml_thursday$Destination.IP.Numeric)

ml_friday$Source.IP = numeric_to_ip(ml_friday$Source.IP.Numeric)
ml_friday$Destination.IP = numeric_to_ip(ml_friday$Destination.IP.Numeric)

# generate flow IDs and add direction
ml_monday$Flow.ID.Forward =
  paste(ml_monday$Source.IP, ml_monday$Destination.IP,
        ml_monday$tcp_src_port, ml_monday$tcp_dst_port,
        ml_monday$ipv4_protocol, sep="-")

ml_monday$Flow.ID.Backward =
  paste(ml_monday$Destination.IP, ml_monday$Source.IP,
        ml_monday$tcp_dst_port, ml_monday$tcp_src_port,
        ml_monday$ipv4_protocol, sep="-")

ml_monday = ml_monday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
ml_monday = ml_monday %>% mutate(Flow.Direction = ifelse(Source.IP.Numeric < Destination.IP.Numeric, "FWD", "BWD"))


ml_tuesday$Flow.ID.Forward =
  paste(ml_tuesday$Source.IP, ml_tuesday$Destination.IP,
        ml_tuesday$tcp_src_port, ml_tuesday$tcp_dst_port,
        ml_tuesday$ipv4_protocol, sep="-")

ml_tuesday$Flow.ID.Backward =
  paste(ml_tuesday$Destination.IP, ml_tuesday$Source.IP,
        ml_tuesday$tcp_dst_port, ml_tuesday$tcp_src_port,
        ml_tuesday$ipv4_protocol, sep="-")

ml_tuesday = ml_tuesday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
ml_tuesday = ml_tuesday %>% mutate(Flow.Direction = ifelse(Source.IP.Numeric < Destination.IP.Numeric, "FWD", "BWD"))


ml_wednesday$Flow.ID.Forward =
  paste(ml_wednesday$Source.IP, ml_wednesday$Destination.IP,
        ml_wednesday$tcp_src_port, ml_wednesday$tcp_dst_port,
        ml_wednesday$ipv4_protocol, sep="-")

ml_wednesday$Flow.ID.Backward =
  paste(ml_wednesday$Destination.IP, ml_wednesday$Source.IP,
        ml_wednesday$tcp_dst_port, ml_wednesday$tcp_src_port,
        ml_wednesday$ipv4_protocol, sep="-")

ml_wednesday = ml_wednesday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
ml_wednesday = ml_wednesday %>% mutate(Flow.Direction = ifelse(Source.IP.Numeric < Destination.IP.Numeric, "FWD", "BWD"))

ml_thursday$Flow.ID.Forward =
  paste(ml_thursday$Source.IP, ml_thursday$Destination.IP,
        ml_thursday$tcp_src_port, ml_thursday$tcp_dst_port,
        ml_thursday$ipv4_protocol, sep="-")

ml_thursday$Flow.ID.Backward =
  paste(ml_thursday$Destination.IP, ml_thursday$Source.IP,
        ml_thursday$tcp_dst_port, ml_thursday$tcp_src_port,
        ml_thursday$ipv4_protocol, sep="-")

ml_thursday = ml_thursday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
ml_thursday = ml_thursday %>% mutate(Flow.Direction = ifelse(Source.IP.Numeric < Destination.IP.Numeric, "FWD", "BWD"))

ml_friday$Flow.ID.Forward =
  paste(ml_friday$Source.IP, ml_friday$Destination.IP,
        ml_friday$tcp_src_port, ml_friday$tcp_dst_port,
        ml_friday$ipv4_protocol, sep="-")

ml_friday$Flow.ID.Backward =
  paste(ml_friday$Destination.IP, ml_friday$Source.IP,
        ml_friday$tcp_dst_port, ml_friday$tcp_src_port,
        ml_friday$ipv4_protocol, sep="-")

ml_friday = ml_friday %>% mutate(Flow.ID = ifelse(Source.IP.Numeric < Destination.IP.Numeric, Flow.ID.Forward, Flow.ID.Backward))
ml_friday = ml_friday %>% mutate(Flow.Direction = ifelse(Source.IP.Numeric < Destination.IP.Numeric, "FWD", "BWD"))

# remove unnecessary columns

keep = c("Flow.ID", 
          "hash_collision",
         "tcp_src_port", "tcp_dst_port", "ipv4_protocol", 
         "pkt_ctr", "byte_ctr", "ack_ctr", "rst_ctr", "syn_ctr", "fin_ctr", "byte_ctr_sq",
         "flow_duration", "byte_avg", "byte_sd", "iat_avg", "bps", "pps")

ml_monday = ml_monday[keep]
ml_tuesday = ml_tuesday[keep]
ml_wednesday = ml_wednesday[keep]
ml_thursday = ml_thursday[keep]
ml_friday = ml_friday[keep]

##### join datasets #####
sklearn_monday = merge(ml_monday, labels_monday, by = "Flow.ID")
sklearn_monday$Flow.ID = NULL
sklearn_tuesday = merge(ml_tuesday, labels_tuesday, by = "Flow.ID")
sklearn_tuesday$Flow.ID = NULL
sklearn_wednesday = merge(ml_wednesday, labels_wednesday, by = "Flow.ID")
sklearn_wednesday$Flow.ID = NULL
sklearn_thursday = merge(ml_thursday, labels_thursday, by = "Flow.ID")
sklearn_thursday$Flow.ID = NULL
sklearn_friday = merge(ml_friday, labels_friday, by = "Flow.ID")
sklearn_friday$Flow.ID = NULL

sklearn <- rbind(sklearn_monday, sklearn_tuesday, sklearn_wednesday, sklearn_thursday, sklearn_friday)

write.csv(sklearn, "sklearn-multi.csv", row.names = FALSE)
