#!/bin/bash

. autobuild/lede-build-sanity.sh

branch_name=mt7987-mt7992-BE7200
branch_path=autobuild/mt7987-mt7992-BE7200
default_kernel_config=${BUILD_DIR}/target/linux/mediatek/mt7987/config-5.4
default_sdk_config=${branch_path}/.config
kasan=0
swpath=0
muldf=0
external_toolchain=0
# version=
debug=
rel_conf=${BUILD_DIR}/../tools/release_conf/${branch_name}/release.conf
package_conf=${BUILD_DIR}/../tools/release_conf/${branch_name}/package.conf
autobuild_tmp=${BUILD_DIR}/.tmp
mt7987=1
mt7987_fpga=0
mt7987_config=${branch_path}/files/mt7987.config
mt7987_kasan_config=${branch_path}/files/mt7987.kasan.config
mt7987_kasan_kernel_config=${branch_path}/files/mt7987.kasan.kernel.config
import_npu_path=${BUILD_DIR}/autobuild/mt7987-npu
import_fpga_path=${BUILD_DIR}/autobuild/mt7987-fpga


twopcie=0
mt7992=1
mt7992_mt7987_eeprom_config=${branch_path}/files/mt7992.mt7987.eeprom.config
mt7992_config=${branch_path}/files/mt7992.config
mt7992_map_config=${branch_path}/files/mt7992.map.config
mt7992_cfg80211_config=${branch_path}/files/mt7992.cfg80211.config
mt7992_mt7987_fpga_config=${branch_path}/files/mt7992.mt7987.fpga.config
mt7992_mt7987_warp_config=${branch_path}/files/mt7992.mt7987.warp.config
aspm=0
cfg80211_on=1
map=1
idx_log=1
add_wifi_detect_in_boot=1
default_hostapd_version=2.11-devel-2022-07-29
hostapd_version=$default_hostapd_version
default_backport_mac80211_version=5.15.81-1
backport_mac80211_version=$default_backport_mac80211_version
swpath=0

[ "$mt7987" = "1" -a "$mt7987_fpga" = "1" ] && {
	map=0
}


sku=BE7200
mt7988a=1
mt7988d=1
mt7988a_88d=0
ap_driver_version="8.2.1.2"
be7200_config=${branch_path}/files/be7200.config

extra_args=

parse_arg() {

	local _arg=$1
	local _ifs=$2
	local oIFS="$IFS"

	[ -n "${_ifs}" ] && IFS="${_ifs}" || IFS="="
	set -- ${_arg}
	[ "$1" != "sdk_path" -a "$1" != "branch" -a "$1" != "branch_path" -a "$1" != "cmd" ] && {
		extra_args="$1=$2 ${extra_args}"
	}
	eval "$1=$2"
	IFS="${oIFS}"

}

parse_args() {

	local arg=

	for arg in $@;
	do
		parse_arg ${arg}
	done

}

disable_config() {

	local config_path="$1"; shift
	local options="$1"; shift
	local option=
	local sed_cmd=

	for option in ${options};
	do
		sed_cmd="sed -i '/^${option}=/d' ${config_path}"
		eval $sed_cmd
		sed_cmd="sed -i '/# ${option} /d' ${config_path}"
		eval $sed_cmd
		echo "# ${option} is not set" >> ${config_path}
	done

	return 0

}

enable_config() {

	local config_path="$1"; shift
	local options="$1"; shift
	local value="$1"; shift
	local option=
	local sed_cmd=

	[ -z "$value" ] && value="y"

	for option in ${options};
	do
		sed_cmd="sed -i '/^${option}=/d' ${config_path}"
		eval $sed_cmd
		sed_cmd="sed -i '/# ${option} /d' ${config_path}"
		eval $sed_cmd
		echo "${option}=${value}" >> ${config_path}
	done
	return 0

}

enable_sdk_config() {

	local options="$1"; shift
	local value="$1"; shift

	enable_config ${default_sdk_config} "${options}" "${value}"

}

disable_sdk_config() {

	local options="$1"; shift

	disable_config ${default_sdk_config} "${options}"

}

enable_kernel_config() {

	local options="$1"; shift
	local value="$1"; shift

	enable_config ${default_kernel_config} "${options}" "${value}"

}

disable_kernel_config() {

	local options="$1"; shift

	disable_config ${default_kernel_config} "${options}"

}


do_patch_quilt() {
	quilt init
	# quilt import is a stack, we should reverse the order here
	files=`find $1 -name "*.patch" | sort | tac`
	for file in $files
	do
		quilt import "${file}"
	done
	echo "--- list openwrt patches ---"
	quilt series
	echo "quilt push -a"
	quilt push -a || exit 1
}

do_patch_normal() {
	files=`find $1 -name "*.patch" | sort`
	for file in $files
	do
	patch -f -p1 -i ${file} || exit 1
	done
}

do_path() {
	if command -v quilt &> /dev/null
	then
		do_patch_quilt $1
	else
		do_patch_normal $1
	fi
}

do_before_prepare(){

	rm -rf ${branch_path}/.config
	rm -rf ${branch_path}/tools
	rm -rf ${branch_path}/package
	rm -rf ${branch_path}/target

	[ "$mt7987_fpga" = "1" ] && {
		cp ${import_fpga_path}/.config $default_sdk_config
		[ -d "${import_fpga_path}/target" ] && cp -rn ${import_fpga_path}/target ${branch_path}
	} || {
		cp ${import_npu_path}/.config $default_sdk_config
		[ -d "${import_npu_path}/target" ] && cp -rn ${import_npu_path}/target ${branch_path}
		[ -d "${import_npu_path}/package" ] && cp -rn ${import_npu_path}/package ${branch_path}
		[ -d "${import_npu_path}/tools" ] && cp -rn ${import_npu_path}/tools ${branch_path}
	}

	[ -f "${mt7987_config}" ] && cat ${mt7987_config} >> ${default_sdk_config}

	[ -d "${branch_path}/files/tools" ] && cp -a ${branch_path}/files/tools ${branch_path}
	[ -d "${branch_path}/files/package" ] && cp -a ${branch_path}/files/package ${branch_path}
	[ -d "${branch_path}/files/target" ] && cp -a ${branch_path}/files/target ${branch_path}


	rm -rf ${BUILD_DIR}/package/libs/libnl-tiny

	rm -rf ${BUILD_DIR}/package/network/utils/iw

	rm -rf ${BUILD_DIR}/package/network/utils/iwinfo

	rm -rf ${BUILD_DIR}/package/network/services/hostapd

	rm -rf ${BUILD_DIR}/package/kernel/mac80211

	[ "$default_hostapd_version" != "$hostapd_version" ] && {
		rm -rf ${branch_path}/package/network/services/hostapd
		cp -a ${branch_path}/files/hostapd-${hostapd_version} ${branch_path}/package/network/services/hostapd
	}

	[ "$default_backport_mac80211_version" != "$backport_mac80211_version" ] && {
		rm -rf ${branch_path}/package/kernel/mac80211
		cp -a ${branch_path}/files/mac80211-${backport_mac80211_version} ${branch_path}/package/kernel/mac80211
	}

	[ "$hostapd_version" = "2.11-devel-2022-07-29" -a "$backport_mac80211_version" = "6.5" ] && {
		cp -a ${branch_path}/files/hostapd-2.11-devel-2022-07-29-for-6.5-patches/* ${branch_path}/package/network/services/hostapd/patches
	}

	[ "$add_wifi_detect_in_boot" = "1" ] && {
		sed -i '/^[\t ]*\[[ ]*![ ]*-f[ ]*\/etc\/config\/wireless[ ]*\]/a \\t\t\/sbin\/wifi detect' ${BUILD_DIR}/package/base-files/files/etc/init.d/boot
	}

	[ -n "${ap_driver_version}" ] && {
		sed -i "s/#define AP_DRIVER_VERSION.*/#define AP_DRIVER_VERSION	\"$ap_driver_version\"/g" ${BUILD_DIR}/../ko_module/wlan_driver/logan/wifi_driver/include/os/rt_linux.h
	}

	[ "$cfg80211_on" = "1" ] && {
		sed -i 's/$(LN) iwconfig $(1)\/usr\/sbin\/iwpriv/$(LN) mwctl $(1)\/usr\/sbin\/iwpriv/g' ${BUILD_DIR}/package/network/utils/wireless-tools/Makefile
	}


	[ -f ${branch_path}/files/openwrt_coverity_build_mt7988_mt7992_BE7200.sh ] && {
		cp ${branch_path}/files/openwrt_coverity_build_mt7988_mt7992_BE7200.sh ${branch_path}
	}
	[ -f ${branch_path}/files/openwrt_coverity_clean_mt7988_mt7992_BE7200.sh ] && {
		cp ${branch_path}/files/openwrt_coverity_clean_mt7988_mt7992_BE7200.sh ${branch_path}
	}
	return 0
}

do_after_prepare() {
	return 0
}

do_before_prepare_final() {

	[ "$kasan" = "1" ] && {
		echo "Enable KASAN"
		cat ${mt7987_kasan_config} >> ${default_sdk_config}
	}

#	[ -n "${version}" ] && {
#		echo "version: ${version}"
#		enable_sdk_config CONFIG_BUSYBOX_CUSTOM y
#		enable_sdk_config CONFIG_BUSYBOX_CONFIG_UNAME_OSNAME "\"\GNU/Linux ${version}\""
#	}

	[ "$external_toolchain" = "1" ] && {
		echo "Use external toolchain"
		external_toolchain_path=$(realpath ../external_toolchain)

		enable_sdk_config CONFIG_DEVEL y
		enable_sdk_config CONFIG_EXTRA_OPTIMIZATION "\"-fno-caller-saves -fno-plt -Wno-error=unused-but-set-variable -Wno-error=unused-result\""
		enable_sdk_config CONFIG_EXTERNAL_TOOLCHAIN y
		enable_sdk_config CONFIG_TARGET_NAME "\"aarch64-openwrt-linux-musl\""
		enable_sdk_config CONFIG_TOOLCHAIN_PREFIX "\"aarch64-openwrt-linux-musl-\""
		enable_sdk_config CONFIG_TOOLCHAIN_ROOT "\"${external_toolchain_path}\""
		enable_sdk_config CONFIG_EXTERNAL_TOOLCHAIN_LIBC_USE_MUSL y
		enable_sdk_config CONFIG_TOOLCHAIN_LIBC "\"musl\""
		enable_sdk_config CONFIG_TOOLCHAIN_BIN_PATH "\"./usr/bin ./bin\""
		enable_sdk_config CONFIG_TOOLCHAIN_INC_PATH "\"./usr/include ./include/fortify ./include\""
		enable_sdk_config CONFIG_TOOLCHAIN_LIB_PATH "\"./usr/lib ./lib\""
		enable_sdk_config CONFIG_USE_EXTERNAL_LIBC y
		enable_sdk_config CONFIG_LIBC_ROOT_DIR "\"${external_toolchain_path}\""
		enable_sdk_config CONFIG_LIBC_FILE_SPEC "\"./aarch64-openwrt-linux-musl/lib/ld-musl-aarch64.so.1 ./aarch64-openwrt-linux-musl/lib/libc.so\""
		enable_sdk_config CONFIG_LIBGCC_ROOT_DIR "\"${external_toolchain_path}\""
		enable_sdk_config CONFIG_LIBGCC_FILE_SPEC "\"./aarch64-openwrt-linux-musl/lib/libgcc_s.so ./aarch64-openwrt-linux-musl/lib/libgcc_s.so.1\""
		enable_sdk_config CONFIG_LIBPTHREAD_ROOT_DIR "\"${external_toolchain_path}\""
		enable_sdk_config CONFIG_LIBPTHREAD_FILE_SPEC "\"./lib/libpthread{-*.so,.so.*}\""
		enable_sdk_config CONFIG_LIBRT_ROOT_DIR "\"${external_toolchain_path}\""
		enable_sdk_config CONFIG_LIBRT_FILE_SPEC "\"./lib/librt{-*.so,.so.*}\""
		enable_sdk_config CONFIG_LIBSTDCPP_ROOT_DIR "\"${external_toolchain_path}\""
		enable_sdk_config CONFIG_LIBSTDCPP_FILE_SPEC "\"./aarch64-openwrt-linux-musl/lib/libstdc++.so ./aarch64-openwrt-linux-musl/lib/libstdc++.so.6 ./aarch64-openwrt-linux-musl/lib/libstdc++.so.6.0.25 ./aarch64-openwrt-linux-musl/lib/libstdc++.so.6.0.25-gdb.py\""
	}


	cat ${mt7992_config} >> ${default_sdk_config}

	enable_kernel_config CONFIG_AQUANTIA_PHY_FW_DOWNLOAD_SINGLE y
	disable_kernel_config CONFIG_AQUANTIA_PHY_FW_DOWNLOAD_GANG

	[ "$twopcie" = "0" ] && {
		echo "1pcie"
		enable_sdk_config CONFIG_MTK_HWIFI_MT799A n
		disable_sdk_config CONFIG_PACKAGE_kmod-mt799a
	}
	[ "$twopcie" = "1" ] && {
		echo "2pcie"
		enable_sdk_config CONFIG_MTK_HWIFI_MT7992_OPTION_TYPE 1
		enable_sdk_config CONFIG_MTK_HWIFI_MT7992_INTR_OPTION_SET 4
	}

	[ "$cfg80211_on" = "1" ] && {
		echo "Enable cfg80211"
		cat ${mt7992_cfg80211_config} >> ${default_sdk_config}
	}

	[ "$map" = "1" ] && {
		echo "Enable MAP"
		cat ${mt7992_map_config} >> ${default_sdk_config}
	}

	[ "$idx_log" = "1" ] && {
		echo "Enable FW idx log"
		enable_sdk_config CONFIG_MTK_WIFI7_FW_LOG_TYPE "\"idx_log\""
	}

	[ "$mt7987" = "1" -a "$mt7987_fpga" = "1" ] && {
		cat ${mt7992_mt7987_fpga_config} >> ${default_sdk_config}
	}

	[ "$mt7987" = "1" ] && {
		cat ${mt7992_mt7987_warp_config} >> ${default_sdk_config}
		enable_sdk_config CONFIG_MTK_HWIFI_MT7992_RRO_MODE 5
		enable_sdk_config CONFIG_MTK_HWIFI_MT7992_OPTION_TYPE 5
		enable_sdk_config CONFIG_MTK_HWIFI_MT7992_INTR_OPTION_SET 0
	}

	[ "$mt7987" = "1"  -a "$mt7992" = "1" ] && {
		cat ${mt7992_mt7987_eeprom_config} >> ${default_sdk_config}
	}

	[ "$swpath" = "1" ] && {
		echo "SW path"
		disable_sdk_config CONFIG_PACKAGE_kmod-mediatek_hnat
		disable_sdk_config CONFIG_MTK_HWIFI_WED_SUPPORT
		disable_sdk_config CONFIG_MTK_WIFI7_FAST_NAT_SUPPORT
		disable_sdk_config CONFIG_MTK_WIFI7_WHNAT_SUPPORT
		disable_sdk_config CONFIG_MTK_WIFI7_WARP_V2
		disable_sdk_config CONFIG_PACKAGE_kmod-mtk_wed
		disable_sdk_config CONFIG_PACKAGE_kmod-warp
		disable_sdk_config CONFIG_WARP_CONFIG_MODE
		disable_sdk_config CONFIG_WARP_CHIPSET
		disable_sdk_config CONFIG_WARP_VERSION
		disable_sdk_config CONFIG_WARP_DBG_SUPPORT
		disable_sdk_config CONFIG_PACKAGE_mtkhnat_util
		enable_sdk_config CONFIG_MTK_HWIFI_MT7992_RRO_MODE 0
		enable_sdk_config CONFIG_MTK_HWIFI_RX_PROCESS_WORKQUEUE y
		enable_sdk_config CONFIG_MTK_WIFI7_SPECIAL_RPS_SUPPORT y
		enable_sdk_config CONFIG_MTK_WIFI7_BA_REORDER_ARRAY_SUPPORT y
	}


	cat ${be7200_config} >> ${default_sdk_config}
	return 0
}

do_after_prepare_final() {

	[ "$kasan" = "1" ] && {
		cat ${mt7987_kasan_kernel_config} >> ${default_kernel_config}
	}
	[ "$swpath" = "1" ] && {
		echo "Enable SW path"
		enable_kernel_config CONFIG_BRIDGE_NETFILTER y
		enable_kernel_config CONFIG_NETFILTER_FAMILY_BRIDGE y
	}

	rm ${BUILD_DIR}/target/linux/mediatek/patches-5.4/999-2953-net-ethernet-mtk_eth_soc-enable-PKT-WDONE-for-MT7988.patch
	rm ${BUILD_DIR}/target/linux/mediatek/patches-5.4/999-2954-net-ethernet-mtk_eth_soc-disable-P1-NO-DROP.patch
	rm ${BUILD_DIR}/target/linux/mediatek/patches-5.4/999-2955-net-phy-aquantia-use-software-reset-for-MT7988.patch
	rm ${BUILD_DIR}/target/linux/mediatek/patches-5.4/999-2956-net-ethernet-mtk_eth_soc-disable-force-SER.patch
	[ "$mt7987_fpga" = "1" ] && {
		sed -i "s/ubus -t 20 wait_for network.interface./ubus -t 120 wait_for network.interface./g" ${BUILD_DIR}/package/mtk/drivers/wifi-profile/files/unified_script/mtwifi.lua
		cp -fpR ${import_fpga_path}/mtk-openwrt-feeds/feed/mtk_failsafe/files/mtk_failsafe.sh ${BUILD_DIR}/feeds/mtk_openwrt_feed/feed/app/mtk_failsafe/files/mtk_failsafe.sh
	}


	[ "$aspm" = "1" ] && {
		echo "Enable ASPM"
		enable_kernel_config CONFIG_PCIEASPM y
		disable_kernel_config CONFIG_PCIEASPM_DEBUG
		disable_kernel_config CONFIG_PCIEASPM_DEFAULT
		disable_kernel_config CONFIG_PCIEASPM_PERFORMANCE
		disable_kernel_config CONFIG_PCIEASPM_POWERSAVE
		enable_kernel_config CONFIG_PCIEASPM_POWER_SUPERSAVE y
		enable_kernel_config CONFIG_PCIEPORTBUS y
		enable_kernel_config CONFIG_PCIE_PME y
	}

	[ "$aspm" = "0" ] && {
		echo "Disable ASPM"
		disable_kernel_config CONFIG_PCIEASPM
		disable_kernel_config CONFIG_PCIEASPM_POWER_SUPERSAVE
		disable_kernel_config CONFIG_PCIEPORTBUS
		disable_kernel_config CONFIG_PCIE_PME
	}

	return 0
}

do_before_build() {

	[ ! -d ${autobuild_tmp} ] && mkdir -p ${autobuild_tmp}
	[ ! -f ${autobuild_tmp}/.autobuild_before_prepare_done ] && do_before_prepare && touch ${autobuild_tmp}/.autobuild_before_prepare_done
	[ ! -f ${autobuild_tmp}/.autobuild_prepare_done ] && prepare && touch ${autobuild_tmp}/.autobuild_prepare_done
	[ ! -f ${autobuild_tmp}/.autobuild_after_prepare_done ] && do_after_prepare && touch ${autobuild_tmp}/.autobuild_after_prepare_done
	[ ! -f ${autobuild_tmp}/.autobuild_prepare_mtwifi_done ] && prepare_mtwifi ${branch_name} && touch ${autobuild_tmp}/.autobuild_prepare_mtwifi_done
	[ ! -f ${autobuild_tmp}/.autobuild_before_prepare_final_done ] && do_before_prepare_final && touch ${autobuild_tmp}/.autobuild_before_prepare_final_done
	[ ! -f ${autobuild_tmp}/.autobuild_prepare_final_done ] && prepare_final ${branch_name} && touch ${autobuild_tmp}/.autobuild_prepare_final_done
	[ ! -f ${autobuild_tmp}/.autobuild_after_prepare_final_done ] && do_after_prepare_final && touch ${autobuild_tmp}/.autobuild_after_prepare_final_done

	return 0
}

do_start_build() {

	build ${branch_name} -pb || [ "$LOCAL" != "1" ]

	return 0
}

do_build() {

	do_before_build
	do_start_build

	return 0
}

do_release() {

	if [ ! -f ${rel_conf} ] || [ ! -f ${package_conf} ]; then
		echo "no release or pakcage config. release terminated"
	else
		. ${rel_conf}
		. ${package_conf}
		. ${BUILD_DIR}/../tools/release.sh release
	fi

	return 0
}

do_release_build() {

	if [ ! -f ${rel_conf} ] || [ ! -f ${package_conf} ]; then
		echo "no release or pakcage config. release terminated"
	else
		. ${rel_conf}
		. ${package_conf}
		. ${BUILD_DIR}/../tools/release.sh release_build $extra_args
	fi

	return 0
}

parse_args $@

[ "$map" = 1 ] && {
	package_conf=${BUILD_DIR}/../tools/release_conf/${branch_name}/package_map.conf
}


[ -n "${sku}" ] && {
	echo "sku: ${sku}"
	version="${sku} ${version}"
}


[ "$debug" = "1" ] && {
	set -x
}

[ -n "$cmd" ] || {
	cmd=build
}

case "$cmd" in
	before_build) do_before_build;;
	start_build) do_start_build;;
	build) do_build;;
	release) do_release;;
	release_build) do_release_build;;
	*) help;;
esac

exit 0


[ -n "${sku}" ] && {
	echo "sku: ${sku}"
	version="${sku} ${version}"
}
