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

# Enviroment ###################################################################
toolchain_path="/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux"
export CROSS_COMPILE=${toolchain_path}/bin/arm-linux-gnueabihf-
export PATH=$PATH:/home/alex/intelFPGA/18.1/quartus/sopc_builder/bin

# Parameters ###################################################################
# SD Card
quartus_proj_abs=$(pwd)

sdcard_partition_number_fat32="1"
sdcard_partition_number_ext3="2"
sdcard_partition_number_a2="3"
sdcard_partition_size_fat32="256M"
sdcard_partition_size_linux="254M"
# Files
fpga_file="socfpga.rbf"
device_tree="socfpga.dtb"
root_fs="rootfs.tar"
preloader_file="preloader-mkpimage.bin"
script_dir_abs="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

### Functions #############################################################
function create_directories
{
  echo -e "${yellow}Copying all needed files to SD Card directory:${NC}"
  mkdir -p software/sdcard/fat32-sdX1
  mkdir -p software/sdcard/ext3-sdX2
  mkdir -p software/sdcard/a2-sdX3
  # mkdir -p ../software/userspace
}

function fat_prt   # Partition 1 - FAT32
{
  # U-boot
  # cp ../software/u-boot/u-boot.img ../software/sdcard/fat32-sdX1/
  cp -rf software/spl_bsp/uboot-socfpga/u-boot.img software/sdcard/fat32-sdX1/
  # U-boot script
  mkimage -A arm -O linux -T script -C none -a 0 -e 0 -n SOCFPGA -d ${script_dir_abs}/u-boot_rocket.script software/sdcard/fat32-sdX1/u-boot.scr
  # RBF
  cp -rf output_files/gr_soc_rbf.rbf software/sdcard/fat32-sdX1/${fpga_file}
  # Device Tree
  dtc -I dts -O dtb -o software/sdcard/fat32-sdX1/${device_tree} gr-soc.dts
  # cp ../software/linux-socfpga/arch/arm/boot/dts/socfpga_cyclone5_de0_sockit.dtb ../software/sdcard/fat32-sdX1/${device_tree}
  # Linux Kernel
  cp -rf software/linux-socfpga/arch/arm/boot/zImage software/sdcard/fat32-sdX1/
}

function rootfs_prt   # Partition 2 - ext3
{
  cp -rf software/buildroot/output/images/${root_fs} software/sdcard/ext3-sdX2
}

function preloader_prt   # Partition 3 - a2
{
  cp software/spl_bsp/${preloader_file} software/sdcard/a2-sdX3
}

function userspace   # Userspace header files
{
  sopc-create-header-files gr_soc.sopcinfo --single software/userspace/hps_0.h --module hps_0
}


function sdcard_format # SD Card formatting
{
  umount /dev/${prt}${sdcard_partition_number_fat32}
  umount /dev/${prt}${sdcard_partition_number_ext3}
  # umount /dev/${prt}3
  echo -e "${yellow}Formatting SD Card:${NC}"
  sudo dd if="/dev/zero" of=/dev/${prt} bs=512 count=1
  echo -e "n\np\n3\n\n4095\nt\na2\nn\np\n1\n\n+${sdcard_partition_size_fat32}\nt\n1\nb\nn\np\n2\n\n+${sdcard_partition_size_linux}\nt\n2\n83\nw\nq\n" | sudo fdisk /dev/${prt}
  # create filesystems
  sudo mkfs.vfat /dev/${prt}${sdcard_partition_number_fat32}
  sudo mkfs.ext3 -F /dev/${prt}${sdcard_partition_number_ext3}
}

function partition
{
  lsblk
  echo -e "${yellow}Please provide an SD Card partition:${NC}"
  read prt
}
function sdcard_flash_fat
{
  echo -e "${yellow}Flashing FAT32 partition:${NC}"
  mkdir -p software/sdcard/fat32_mount
  sudo mount /dev/${prt}${sdcard_partition_number_fat32} software/sdcard/fat32_mount
  sudo cp -rf software/sdcard/fat32-sdX1/* software/sdcard/fat32_mount
  sudo sync
}

function sdcard_flash_ext3
{
  echo -e "${yellow}Flashing ext3 partition:${NC}"
  mkdir -p software/sdcard/ext3_mount
  sudo mount /dev/${prt}${sdcard_partition_number_ext3} software/sdcard/ext3_mount
  sudo tar -xvf software/sdcard/ext3-sdX2/${root_fs} -C software/sdcard/ext3_mount
}

function sdcard_flash_a2
{
  echo -e "${yellow}Flashing preloader:${NC}"
  sudo dd if=software/sdcard/a2-sdX3/${preloader_file} of=/dev/${prt}${sdcard_partition_number_a2} bs=64K seek=0
  sudo sync
}

function sdcard_unmount
{
  sudo umount software/sdcard/fat32_mount
  sudo umount software/sdcard/ext3_mount
  rm -rf software/sdcard/fat32_mount
  rm -rf software/sdcard/ext3_mount
  sudo umount /dev/${prt}${sdcard_partition_number_ext3}
  sudo umount /dev/${prt}${sdcard_partition_number_fat32}
  sudo umount /dev/${prt}${sdcard_partition_number_a2}

}

### Main #############################################################

echo -e "${yellow}1. Create directories? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  create_directories
fi

echo -e "${yellow}2. Make FAT partition? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  fat_prt
fi

echo -e "${yellow}3. Make Rootfs partition? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  rootfs_prt
fi

echo -e "${yellow}4. Make Preloader partition? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  preloader_prt
fi

echo -e "${yellow}5. Format SD Card? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  sdcard_format
fi

partition

echo -e "${yellow}6. Flash SD Card preloader? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  sdcard_flash_a2
fi

echo -e "${yellow}6. Flash SD Card FAT32? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  sdcard_flash_fat
fi

echo -e "${yellow}6. Flash RootFS? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  sdcard_flash_ext3
fi

echo -e "${yellow}7. Unmount? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  sdcard_unmount
fi

echo -e "${yellow}Done!${NC}"
