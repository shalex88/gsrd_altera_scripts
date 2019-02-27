#!/bi/bash

# script directory
script_dir_abs=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${script_dir_abs}"

uboot_src_dir="$(readlink -m "uboot-socfpga")"
cd "${uboot_src_dir}"

sdcard_a2_dir="$(readlink -m "sdcard/a2")"
sdcard_a2_preloader_bin_file="$(readlink -m "${sdcard_a2_dir}/$(basename "${preloader_bin_file}")")"

sdcard_a2_dir="$(readlink -m "spl_bsp")"
