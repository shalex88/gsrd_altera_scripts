#!/bi/bash

# script directory
script_dir_abs=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
cd "${script_dir_abs}"

uboot_src_dir="$(readlink -m "uboot-socfpga")"
cd "${uboot_src_dir}"
