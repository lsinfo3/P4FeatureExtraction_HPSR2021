This folder contains four applications.

# 01-switch-app

This is a P4-based switch app performing the metadata extraction and aggregation tasks.
It is supposed to run on a Barefoot Tofino switch.

**Build:**
Use the vendor-supplied **p4_build.sh** script (in the Barefoot SDE).

**Run:**
Use the vendor-supplied **run_switchd.sh** script with "-p main" parameter.

# 02-controller-app

This is a Python-pased app accessing the switch's registers and checking for expired flows.
It is supposed to run on a Barefoot Tofino switch.

**Run:**
Use the vendor-supplied **run_switchd.sh** script with "-p main" parameter and supply the **controller.py** file as argument.

# 03-receiver-app

This is a DPDK-based app that listens on a specific interfaces and receives metadata packets emitted by the switch or controller.

**Build:**
A Makefile is supplied.

**Run:**
No special requirements. The application starts the write process of the metadata file on a SIGINT signal (e.g. CTRL+C).

# 04-metadata-analyzer

This folder contains the JupyterLab notebook used for the Machine Learning tasks.
It is expected that the imported libraries are already installed (e.g. through **pip**)
