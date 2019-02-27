#!/bi/bash
#
# Creating SD card for Altera Cyclone5 GSRD
# ===================================================================================
# usage: create_linux_system.sh [sdcard_device]
#
# positional arguments:
#     sdcard_device    path to sdcard device file    [ex: "/dev/sdb", "/dev/mmcblk0"]
# ===================================================================================

yellow='\E[1;33m'
NC='\033[0m'
# Device Tree
cd ..
sopc2dts -v --input gr_soc.sopcinfo --output gr-soc.dts --type dts --board soc_system_board_info.xml --board hps_common_board_info.xml --bridge-removal all --clocks
# dtc -I dts -O dtb -o ../software/sdcard/fat32-sdX1/socfpga_cyclone5_gr_soc.dtb ../gr_soc.dts
dtc -I dts -O dtb -o socfpga.dtb gr-soc.dts #dts to dtb
# dtc -I dtb -O dts -o soc_system.dts soc_system.dtb #dtb to dts


cd gsrd_altera_scripts
echo -e "${yellow}Done!${NC}"
