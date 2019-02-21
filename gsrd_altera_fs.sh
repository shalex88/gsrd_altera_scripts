#!/bi/bash
#
# Creating BSP for Altera Cyclone5 GSRD
# Usage: source gsrd_altera_setup.sh
# Info: https://rocketboards.org/foswiki/Documentation/EmbeddedLinuxBeginnerSGuide

yellow='\E[1;33m'
NC='\033[0m'

### Parameters ###
toolchain_path="/media/alex/Develop/BSP/gcc-linaro-arm-linux-gnueabihf-4.9-2014.09_linux"
url="http://git.buildroot.net/git/buildroot.git"
branch="2015.08.x"
repo_dir="buildroot"
output_dir="output"
root_fs="rootfs.tar"

### Functions ###
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
  # configure buildroot
  make ARCH=ARM BR2_TOOLCHAIN_EXTERNAL_PATH=${toolchain_path} nconfig
  # configure BusyBox
  make busybox-menuconfig
  # build BusyBox
  make BR2_TOOLCHAIN_EXTERNAL_PATH=${toolchain_path} all
}

### Main ###
echo -e "${yellow}1. Download buildroot source? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  download
  cd ${repo_dir}
fi

echo -e "${yellow}2. Compile? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  echo -e "${yellow}Compiling..${NC}"
  compilation
fi

echo -e "${yellow}3. Copy output file to ../${output_dir} directory? [y/n]${NC}"
read yn
if [ ${yn} == "y" ]
then
  mkdir -p ../${output_dir}
  cp ./output/images/${root_fs} ./../${output_dir}/${root_fs}
fi

echo -e "${yellow}Linux BusyBox file system is ready!${NC}"
