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

# Parameters ##################################
# SD Card
sdcard_partition_number_fat32="1"
sdcard_partition_number_ext3="2"
sdcard_partition_number_a2="3"
sdcard_partition_size_fat32="256M"
sdcard_partition_size_linux="254M"
# Files
fpga_file="socfpga"
device_tree="socfpga"
root_fs="rootfs.tar"
preloader_file="preloader-mkpimage.bin"
# toolchain=""

# Script execution #############################################################

echo -e "${yellow}Copying all needed files to SD Card directory:${NC}"
mkdir -p ../software/sdcard

# Partition 1 - FAT32
mkdir -p ../software/sdcard/fat32-sdX1
# U-boot
# cp ../software/u-boot/u-boot.img ../software/sdcard/fat32-sdX1/
cp ../software/spl_bsp/uboot-socfpga/u-boot.img ../software/sdcard/fat32-sdX1/
# U-boot script
mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n SOCFPGA -d u-boot_rocket.script ../software/sdcard/fat32-sdX1/u-boot.scr
# RBF
cp ../output_files/gr_soc_rbf.rbf ../software/sdcard/fat32-sdX1/${fpga_file}.rbf
# Device Tree
# dtc -I dts -O dtb -o ../software/sdcard/fat32-sdX1/socfpga.dtb ../gr-soc.dts
cp ../software/linux-socfpga/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb ../software/sdcard/fat32-sdX1/${device_tree}.dtb
# Linux Kernel
cp ../software/linux-socfpga/arch/arm/boot/zImage ../software/sdcard/fat32-sdX1/

# Partition 2 - ext3
mkdir -p ../software/sdcard/ext3-sdX2
cp ../software/buildroot/output/images/${root_fs} ../software/sdcard/ext3-sdX2

# Partition 3 - a2
mkdir -p ../software/sdcard/a2-sdX3
cp ../software/spl_bsp/${preloader_file}${preloader_file} ../software/sdcard/a2-sdX3

# SD Card formatting
lsblk
echo -e "${yellow}Please provide an SD Card partition:${NC}"
read prt
umount /dev/${prt}${sdcard_partition_number_fat32}
umount /dev/${prt}${sdcard_partition_number_ext3}
# umount /dev/${prt}3

echo -e "${yellow}Formatting SD Card:${NC}"
sudo dd if="/dev/zero" of=/dev/${prt} bs=512 count=1
echo -e "n\np\n3\n\n4095\nt\na2\nn\np\n1\n\n+${sdcard_partition_size_fat32}\nt\n1\nb\nn\np\n2\n\n+${sdcard_partition_size_linux}\nt\n2\n83\nw\nq\n" | sudo fdisk /dev/${prt}
# create filesystems
sudo mkfs.vfat /dev/${prt}${sdcard_partition_number_fat32}
sudo mkfs.ext3 -F /dev/${prt}${sdcard_partition_number_ext3}


echo -e "${yellow}Flashing SD Card:${NC}"
mkdir -p ../software/sdcard/fat32_mount
mkdir -p ../software/sdcard/ext3_mount
sudo mount /dev/${prt}${sdcard_partition_number_fat32} ../software/sdcard/fat32_mount
sudo mount /dev/${prt}${sdcard_partition_number_ext3} ../software/sdcard/ext3_mount
sudo cp ../software/sdcard/fat32-sdX1/* ../software/sdcard/fat32_mount
sudo tar -xvf ../software/sdcard/ext3-sdX2/${root_fs} -C ../software/sdcard/ext3_mount
sudo dd if=../software/sdcard/a2-sdX3/${preloader_file} of=/dev/${prt}${sdcard_partition_number_a2} bs=64K seek=0
sudo sync
sudo umount ../software/sdcard/fat32_mount
sudo umount ../software/sdcard/ext3_mount
# sudo umount /dev/${prt}3

rm -rf ../software/sdcard/fat32_mount
rm -rf ../software/sdcard/ext3_mount
echo -e "${yellow}Done!${NC}"
