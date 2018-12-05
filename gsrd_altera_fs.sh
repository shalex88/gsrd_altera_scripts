#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh

yellow='\E[1;33m'
NC='\033[0m'
cd ../software
git clone http://git.buildroot.net/git/buildroot.git
cd buildroot
git checkout 2015.08.x
export ARCH=arm
cd ..
make -C buildroot ARCH=ARM BR2_TOOLCHAIN_EXTERNAL_PATH=/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux nconfig
# make -C buildroot busybox-menuconfig
make -C buildroot BR2_TOOLCHAIN_EXTERNAL_PATH=/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux all
echo -e "${yellow}Done!${NC}"
