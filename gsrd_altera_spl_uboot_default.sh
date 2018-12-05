#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh

yellow='\E[1;33m'
NC='\033[0m'

# ToDo: Preloader Generation
# cd /media/alex/Develop/BSP_Project_by_PDF_Tutorial/gr-soc
cd ..
bsp-editor
cd ./software/spl_bsp/
make

# U-boot SOCFPGA
# export CROSS_COMPILE=/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
cd ./uboot-socfpga/
# Custom Board
# cp -r ../generated/* board/altera/socfpga
# Custom u-boot env
#Change EMAC1 to EMAC0
sed -i 's/CONFIG_EMAC1_BASE/CONFIG_EMAC0_BASE/g' include/configs/socfpga_cyclone5.h
sed -i 's/CONFIG_EPHY1_PHY_ADDR/CONFIG_EPHY0_PHY_ADDR/g' include/configs/socfpga_cyclone5.h
#Change U-boot promt
sed -i 's/SOCFPGA_CYCLONE5 #/GR_SOC #/g' include/configs/socfpga_cyclone5.h
sed -i 's/Altera SOCFPGA Cyclone V Board/GR SOC Board/g' board/altera/socfpga/socfpga_cyclone5.c

cd ../

# Build U-boot
make uboot

echo -e "${yellow}Done!${NC}"
