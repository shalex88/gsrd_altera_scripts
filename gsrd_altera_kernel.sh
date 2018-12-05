#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh

yellow='\E[1;33m'
NC='\033[0m'
cd ../software
git clone https://github.com/altera-opensource/linux-socfpga.git
cd linux-socfpga
export CROSS_COMPILE=/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux/bin/arm-linux-gnueabihf-
export ARCH=arm
make socfpga_defconfig
make socfpga_cyclone5_de0_sockit.dtb
echo -e "${yellow}Done!${NC}"
