#!/bi/sh - run in shell
#
# Building Yocto for Altera Cyclone5 Soc
# Usage: source yocto_altera_install

yellow='\E[1;33m'
NC='\033[0m'

echo -e "${yellow}Comiling QTS files for new U-boot version (>2015)...${NC}"
rm -rf ../software/qts
mkdir ../software/qts
../software/u-boot/arch/arm/mach-socfpga/qts-filter.sh cyclone5 ../ ../software/spl_bsp/ ../software/qts/
echo -e "${yellow}Done!${NC}"
