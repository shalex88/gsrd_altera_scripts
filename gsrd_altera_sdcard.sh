#!/bi/bash
#
# Creating SD card for Altera Cyclone5 GSRD
# Usage: source sdcard_altera_gsrd

yellow='\E[1;33m'
NC='\033[0m'

echo -e "${yellow}Copying all needed files to sdcard directory:${NC}"
mkdir -p sdcard

# Partition 1 - FAT32
mkdir -p sdcard/fat32-sdX1
# U-boot
cp ./u-boot/u-boot.img sdcard/fat32-sdX1/
# U-boot script
cp ./u-boot_script/u-boot.scr sdcard/fat32-sdX1/
# RBF
cp ../output_files/gr_soc_rbf.rbf sdcard/fat32-sdX1/
mv ./sdcard/fat32-sdX1/gr_soc_rbf.rbf ./sdcard/fat32-sdX1/socfpga.rbf
# Device Tree
dtc -I dts -O dtb -o ./sdcard/fat32-sdX1/socfpga_cyclone5_gr_soc.dtb ../gr_soc.dts
# Linux Kernel
cp ./linux-socfpga/arch/arm/boot/zImage ./sdcard/fat32-sdX1/

# Partition 2 - ext3
mkdir -p sdcard/ext3-sdX2
# sudo tar -xzf ../ext3_rootfs.tag.gz

# Partition 3 - a2
mkdir -p ./sdcard/a2-sdX3
cp ./spl_bsp/preloader-mkpimage.bin ./sdcard/a2-sdX3

#
lsblk
echo -e "${yellow}Please provide an SD Card partition:${NC}"
read prt
umount /dev/${prt}1
umount /dev/${prt}2
umount /dev/${prt}3

mkdir -p ./sdcard/fat32_mount
mkdir -p ./sdcard/ext3_mount
sudo mount /dev/${prt}1 ./sdcard/fat32_mount
sudo mount /dev/${prt}2 ./sdcard/ext3_mount
sudo cp ./sdcard/fat32-sdX1/* ./sdcard/fat32_mount
# sudo cp ./sdcard/ext3-sdX2/* ./sdcard/ext3_mount
sudo dd if=./sdcard/a2-sdX3/preloader-mkpimage.bin of=/dev/${prt}3 bs=64K seek=0
sudo sync

sudo umount ./sdcard/fat32_mount
sudo umount ./sdcard/ext3_mount
sudo umount /dev/${prt}3

rm -rf ./sdcard/fat32_mount
rm -rf ./sdcard/ext3_mount
echo -e "${yellow}Done!${NC}"
