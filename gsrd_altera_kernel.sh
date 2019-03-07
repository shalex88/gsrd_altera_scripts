#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: call from linux source directory or from where you want to place it

yellow='\E[1;33m'
NC='\033[0m'

### Parameters #############################################################
toolchain_path="/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux"
url="https://github.com/altera-opensource/linux-socfpga.git"
branch="socfpga-4.9.76-ltsi-rt"
repo_dir="linux-socfpga"
output_dir="output"
dts="socfpga_cyclone5_de0_sockit.dtb"

### Functions #############################################################
function download
{
  echo -e "${yellow}Default branch:${NC} ${branch}"
  echo -e "${yellow}Choose another branch? [y/n]${NC}"
  read yn
  if [ ${yn} == "y" ]
  then
    git ls-remote --heads ${url}
    echo -e "${yellow}Type branch name...${NC}"
    read branch
  fi
  echo -e "${yellow}Downloading...${NC}"
  git clone -b ${branch} ${url} ${repo_dir}
}

function compilation
{
  export CROSS_COMPILE=${toolchain_path}/bin/arm-linux-gnueabihf-
  export ARCH=arm
  echo -e "${yellow}Clean previous builds? [y/n]${NC}"
  read yn
  if [ ${yn} == "y" ]
  then
    make mrproper
  fi
  make socfpga_defconfig
  make menuconfig
  make ${dts} #?
  # make -j4 LOCALVERSION= zImage
  if make zImage
  then
    echo -e "${yellow}Success!!${NC}"
  else
    echo -e "${yellow}Error!!${NC}"
    cd ${quartus_proj_abs}
    return 1
  fi
}

### Main #############################################################
mkdir -p software
cd software

echo -e "${yellow}1. Download linux source for Altera Socfpga? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  if download
  then
    echo -e "${yellow}Success!!${NC}"
  else
    echo -e "${yellow}Error!!${NC}"
    cd ${quartus_proj_abs}
    return 1
  fi
fi


cd ${repo_dir}

echo -e "${yellow}2. Compile? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  echo -e "${yellow}Compiling..${NC}"
  compilation
fi

echo -e "${yellow}3. Copy output files to ../${output_dir} directory? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  mkdir -p ../${output_dir}
  cp ./arch/arm/boot/zImage ./../${output_dir}/zImage
  cp ./arch/arm/boot/dts/${dts} ./../${output_dir}/${dts}
fi

cd ${quartus_proj_abs}
echo -e "${yellow}Linux kernel is ready!${NC}"
