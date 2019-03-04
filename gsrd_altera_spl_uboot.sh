#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: . gsrd_altera_setup.sh
# Run in quartus project directory

yellow='\E[1;33m'
NC='\033[0m'

### Parameters ###
toolchain_path="/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux" #ToDo: find the directory instead of path
uboot_url="git://git.denx.de/u-boot.git"
uboot_dir="uboot-socfpga"
output_dir="output"
preloader_file="preloader-mkpimage.bin"
uboot_img="u-boot.img"
uboot_branch="u-boot-2016.09.y"
quartus_proj_abs=$(pwd)
spl_dir_abs=${quartus_proj_abs}/software/spl_bsp
script_dir_abs="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
export CROSS_COMPILE=${toolchain_path}/bin/arm-linux-gnueabihf-
export PATH=$PATH:${toolchain_tools_path}
board_vendor="gr"
board_name="gr-soc"

### Functions ###
function download
{
  cd ${spl_dir_abs}
  echo -e "${yellow}Default branch:${NC} ${uboot_branch}"
  echo -e "${yellow}Choose another branch? [y/n]${NC}"
  read yn
  if [ ${yn} == "y" ]
  then
    git ls-remote --heads ${uboot_url}
    echo -e "${yellow}Type branch name...${NC}"
    read uboot_branch
  fi
  echo -e "${yellow}Downloading...${NC}"
  git clone -b ${uboot_branch} ${uboot_url} ${uboot_dir}
}

function start_eds_shell
{
  eds=$(sudo find ~ -name embedded_command_shell.sh) #ToDo: edit the the shell script file, comment bash command
  cd $(dirname ${eds})
  . ${eds}
  # sleep 1
}

function preloader
{
  start_eds_shell
  cd ${quartus_proj_abs}
  # pwd
  bsp-editor #File->New HPS BSP, choose hps_isw_handoff. Add FAT support. Generate
  cd ${spl_dir_abs}
  # pwd
  # exit
  make -j4 #generates preloader-mkpimage.bin and uboot-socfpga directory already with needed files!
}

function qts_filter
{
  rm -rf ${spl_dir_abs}/qts
  mkdir ${spl_dir_abs}/qts
  soc_type="cyclone5"
  input_qts_dir=${quartus_proj_abs}
  input_bsp_dir=${spl_dir_abs}
  output_dir_qts="${spl_dir_abs}/qts/"
  . ${spl_dir_abs}/uboot/arch/arm/mach-socfpga/qts-filter.sh ${soc_type} ${input_qts_dir} ${input_bsp_dir} ${output_dir_qts}
}

function uboot_compilation
{
  cd ${spl_dir_abs}/${uboot_dir}
  make mrproper #remove old files
  if [ ${uboot_dir} == "uboot" ]
  then
    make socfpga_de0_nano_soc_defconfig #ToDo: add custom board defconfig
  else
    make socfpga_cyclone5_config
  fi
  make -j4
}

function uboot_mainline_conf
{
  cd ${spl_dir_abs}/${uboot_dir}
  qts_filter
  # Custom Board
  mkdir -p board/${board_vendor}/${board_name}
  cp -r board/altera/cyclone5-socdk/* board/${board_vendor}/${board_name} #copy altera board files to custom board
  cp -r ../qts/* board/${board_vendor}/${board_name}/qts #copy preloader generated files to custom board
  #ToDo: add uboot configuration
}

function uboot_ghrd_conf
{
  cd ${spl_dir_abs}/${uboot_dir}

  #Change default soc configuration to generated one
  cp -r ../generated/* board/altera/socfpga
  #Custom uboot environment
  #Change EMAC1 to EMAC0
  sed -i "s/CONFIG_EMAC1_BASE/CONFIG_EMAC0_BASE/g" include/configs/socfpga_cyclone5.h
  sed -i "s/CONFIG_EPHY1_PHY_ADDR/CONFIG_EPHY0_PHY_ADDR/g" include/configs/socfpga_cyclone5.h
  #Change U-boot promt
  sed -i "s/SOCFPGA_CYCLONE5 #/GR_SOC #/g" include/configs/socfpga_cyclone5.h
  sed -i "s/Altera SOCFPGA Cyclone V Board/GR SOC Board/g" board/altera/socfpga/socfpga_cyclone5.c
}

function uboot_ghrd_custom_conf
{
  cd ${spl_dir_abs}/${uboot_dir}

  #Create custom board directory based on the default altera board
  mkdir -p board/${board_vendor}/${board_name}
  cp -r board/altera/socfpga/* board/${board_vendor}/${board_name}/ #copy altera board files to custom board
  cp -r ../generated/* board/${board_vendor}/${board_name} #copy preloader generated files to custom board

  #Custom uboot environment
  cp include/configs/socfpga_cyclone5.h include/configs/socfpga_${board_vendor}_soc.h
  cp include/configs/socfpga_common.h include/configs/socfpga_${board_vendor}_soc_common.h
  sed -i 's/#define CONFIG_SOCFPGA_CYCLONE5/&\n#define CONFIG_GR_SOC/g' include/configs/socfpga_${board_vendor}_soc.h
  sed -i 's/socfpga_common.h/socfpga_"${board_vendor}"_soc_common.h/g' include/configs/socfpga_${board_vendor}_soc.h
  sed -i 's/board\/altera\/socfpga/board\/"${board_vendor}"\/"${board_name}"/g' include/configs/socfpga_${board_vendor}_soc.h
  #Change EMAC1 to EMAC0
  sed -i "s/CONFIG_EMAC1_BASE/CONFIG_EMAC0_BASE/g" include/configs/socfpga_${board_vendor}_soc.h
  sed -i "s/CONFIG_EPHY1_PHY_ADDR/CONFIG_EPHY0_PHY_ADDR/g" include/configs/socfpga_${board_vendor}_soc.h
  #Change U-boot promt
  sed -i 's/SOCFPGA_CYCLONE5 #/GR_SOC #/g' include/configs/socfpga_${board_vendor}_soc.h
  sed -i 's/board\/altera\/socfpga/board\/"${board_vendor}"\/"${board_name}"/g' include/configs/socfpga_${board_vendor}_soc_common.h
  sed -i 's/Altera SOCFPGA Cyclone V Board/GR SOC Board/g' board/${board_vendor}/${board_name}/socfpga_cyclone5.c
  sed -i 's/socfpga_cyclone5/socfpga_"${board_vendor}"_soc                arm         armv7       "${board_name}"            "${board_vendor}           socfpga\n&/' boards.cfg

  #Update uboot make file with custom board
  cd ${spl_dir_abs} #???????????????????????????
  sed -i 's/board\/altera\/socfpga/board\/"${board_vendor}"\/"${board_name}"/g' Makefile
  sed -i 's/socfpga_$(DEVICE_FAMILY)_config/"${board_vendor}"_soc_config/g' Makefile
}

### Main ###
# start_eds_shell
echo -e "${yellow}1. Generate preloader? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  echo -e "${yellow}Compiling..${NC}"
  if preloader
  then
    echo -e "${yellow}Success!!${NC}"
  else
    echo -e "${yellow}Error!!${NC}"
    return
  fi
fi

echo -e "${yellow}2. Use mainline u-boot instead of the default GHRD uboot-socfpga? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  echo -e "${yellow}Using mainline uboot..${NC}"
  uboot_dir="uboot"
  echo -e "${yellow}Download the source? [y/n]${NC}"
  read yn
  if [ ${yn} == "y" ]
  then
    if download
    then
    echo -e "${yellow}Success!!${NC}"
    else
    echo -e "${yellow}Error!!${NC}"
    return
    fi
  fi
  # cd ${uboot_dir} #uboot dir
else
  echo -e "${yellow}Using GHRD uboot-socfpga..${NC}"
  # cd ${uboot_dir} #uboot-socfpga dir
fi

echo -e "${yellow}4. Configure? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  if [ ${uboot_dir} == "uboot-socfpga" ]
  then
    echo -e "${yellow}Create new board instead of default one? [y/n]${NC}"
    read yn
    if [ ${yn} == "y" ]
    then
      uboot_ghrd_custom_conf
    else
      uboot_ghrd_conf
    fi
  else
    uboot_mainline_conf
  fi
fi

echo -e "${yellow}5. Compile? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  echo -e "${yellow}Compiling..${NC}"
  if uboot_compilation
  then
    echo -e "${yellow}Success!!${NC}"
  else
    echo -e "${yellow}Error!!${NC}"
    return
  fi
fi


echo -e "${yellow}6. Copy output file to ${output_dir} directory? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  cd ${quartus_proj_abs}/software
  mkdir -p ${output_dir}
  cp ${spl_dir_abs}/${uboot_dir}/${uboot_img} ${quartus_proj_abs}/software/${output_dir}/${uboot_img}
  cp ${spl_dir_abs}/${preloader_file} ${quartus_proj_abs}/software/${output_dir}/${preloader_file}
fi

cd ${quartus_proj_abs} #go to initial dir
echo -e "${yellow}U-boot is ready!${NC}"
