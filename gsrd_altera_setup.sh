#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh

yellow='\E[1;33m'
NC='\033[0m'

# ToDo: Preloader Generation
# ToDo: U-boot
# ToDo: Create U-boot script
# ToDo: Linux Kernel

# create Device Tree
sopc2dts --input gr_soc.sopcinfo --output gr_soc.dts --type dts --board soc_system_board_info.xml --board hps_common_board_info.xml --bridge-removal all --clocks

echo -e "${yellow}Done!${NC}"
