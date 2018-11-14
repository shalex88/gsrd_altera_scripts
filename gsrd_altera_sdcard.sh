#!/bi/bash
#
# Creating SD card for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_sdcard.sh

yellow='\E[1;33m'
NC='\033[0m'

echo -e "${yellow}Copying all needed files to sdcard directory:${NC}"
mkdir -p ../software/sdcard

# Partition 1 - FAT32
mkdir -p ../software/sdcard/fat32-sdX1
# U-boot
cp ../software/u-boot/u-boot.img ../software/sdcard/fat32-sdX1/
# U-boot script
cp ../software/u-boot_script/u-boot.scr ../software/sdcard/fat32-sdX1/
# RBF
cp ../output_files/gr_soc_rbf.rbf ../software/sdcard/fat32-sdX1/
mv ../software/sdcard/fat32-sdX1/gr_soc_rbf.rbf ../software/sdcard/fat32-sdX1/socfpga.rbf
# Device Tree
dtc -I dts -O dtb -o ../software/sdcard/fat32-sdX1/socfpga_cyclone5_gr_soc.dtb ../gr_soc.dts
# Linux Kernel
cp ../software/linux-socfpga/arch/arm/boot/zImage ../software/sdcard/fat32-sdX1/

# Partition 2 - ext3
mkdir -p ../software/sdcard/ext3-sdX2
# sudo tar -xzf ../ext3_rootfs.tag.gz

# Partition 3 - a2
mkdir -p ../software/sdcard/a2-sdX3
cp ../software/spl_bsp/preloader-mkpimage.bin ../software/sdcard/a2-sdX3

#
lsblk
echo -e "${yellow}Please provide an SD Card partition:${NC}"
read prt
umount /dev/${prt}1
umount /dev/${prt}2
umount /dev/${prt}3

mkdir -p ../software/sdcard/fat32_mount
mkdir -p ../software/sdcard/ext3_mount
sudo mount /dev/${prt}1 ../software/sdcard/fat32_mount
sudo mount /dev/${prt}2 ../software/sdcard/ext3_mount
sudo cp ../software/sdcard/fat32-sdX1/* ../software/sdcard/fat32_mount
# sudo cp ./sdcard/ext3-sdX2/* ./sdcard/ext3_mount
sudo dd if=../software/sdcard/a2-sdX3/preloader-mkpimage.bin of=/dev/${prt}3 bs=64K seek=0
sudo sync

sudo umount ../software/sdcard/fat32_mount
sudo umount ../software/sdcard/ext3_mount
sudo umount /dev/${prt}3

rm -rf ../software/sdcard/fat32_mount
rm -rf ../software/sdcard/ext3_mount
echo -e "${yellow}Done!${NC}"
