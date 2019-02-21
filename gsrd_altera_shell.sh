#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh

yellow='\E[1;33m'
NC='\033[0m'

### Parameters ###
toolchain_path="/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux"

### Functions ###

### Main ###
echo -e "${yellow}Running EDS shell...${NC}"
find ~ -name "embedded_command_shell.sh" -exec chmod +x {} \; -exec {} \;
export CROSS_COMPILE=${toolchain_path}/bin/arm-linux-gnueabihf-
export PATH=$PATH:/home/alex/intelFPGA/18.1/quartus/sopc_builder/bin
