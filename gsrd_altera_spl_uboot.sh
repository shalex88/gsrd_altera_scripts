#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh

yellow='\E[1;33m'
NC='\033[0m'

# ToDo: Preloader Generation
cd /media/alex/Develop/BSP_Project_by_PDF_Tutorial/gr-soc_2
bsp-editor
cd ./software/spl_bsp/
make

# U-boot SOCFPGA
export CROSS_COMPILE=/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
cd ./uboot-socfpga/
# Custom Board
mkdir -p board/gr/gr-soc
cp -r board/altera/socfpga/* board/gr/gr-soc
cp -r ../generated/* board/gr/gr-soc
# Custom u-boot env
cp include/configs/socfpga_cyclone5.h include/configs/socfpga_gr_soc.h
cp include/configs/socfpga_common.h include/configs/socfpga_gr_soc_common.h
sed -i 's/#define CONFIG_SOCFPGA_CYCLONE5/&\n#define CONFIG_GR_SOC/g' include/configs/socfpga_gr_soc.h
sed -i 's/socfpga_common.h/socfpga_gr_soc_common.h/g' include/configs/socfpga_gr_soc.h
sed -i 's/board\/altera\/socfpga/board\/gr\/gr-soc/g' include/configs/socfpga_gr_soc.h
#Change EMAC1 to EMAC0
sed -i 's/CONFIG_EMAC1_BASE/CONFIG_EMAC0_BASE/g' include/configs/socfpga_gr_soc.h
sed -i 's/CONFIG_EPHY1_PHY_ADDR/CONFIG_EPHY0_PHY_ADDR/g' include/configs/socfpga_gr_soc.h
#Change U-boot promt
sed -i 's/SOCFPGA_CYCLONE5 #/GR_SOC #/g' include/configs/socfpga_gr_soc.h
sed -i 's/board\/altera\/socfpga/board\/gr\/gr-soc/g' include/configs/socfpga_gr_soc_common.h
sed -i 's/Altera SOCFPGA Cyclone V Board/GR SOC Board/g' board/gr/gr-soc/socfpga_cyclone5.c
sed -i 's/socfpga_cyclone5/socfpga_gr_soc                arm         armv7       gr-soc            gr           socfpga\n&/' boards.cfg

cd ../
sed -i 's/board\/altera\/socfpga/board\/gr\/gr-soc/g' Makefile
sed -i 's/socfpga_$(DEVICE_FAMILY)_config/gr_soc_config/g' Makefile

make
make uboot
# ToDo: U-boot
# ToDo: Create U-boot script
# ToDo: Linux Kernel

# create Device Tree
# sopc2dts --input gr_soc.sopcinfo --output gr_soc.dts --type dts --board soc_system_board_info.xml --board hps_common_board_info.xml --bridge-removal all --clocks

echo -e "${yellow}Done!${NC}"
