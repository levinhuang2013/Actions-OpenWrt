#!/bin/bash
#
# https://github.com/P3TERX/Actions-OpenWrt
# File name: diy-part2.sh
# Description: OpenWrt DIY script part 2 (After Update feeds)
#
# Copyright (c) 2019-2024 P3TERX <https://p3terx.com>
#
# This is free software, licensed under the MIT License.
# See /LICENSE for more information.
#

# Modify default IP
#sed -i 's/192.168.1.1/192.168.211.1/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Add packages
#git clone -b js https://github.com/gngpp/luci-theme-design package/luci-theme-design
#git clone https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome
#git clone https://github.com/messense/aliyundrive-webdav package/aliyundrive-webdav
#git clone https://github.com/sirpdboy/netspeedtest package/homebox
#git clone https://github.com/destan19/OpenAppFilter package/openappfilter
#rm -rf feeds/packages/net/open-app-filter
#git clone https://github.com/linkease/nas-packages-luci package/nas-packages-luci
#git clone https://github.com/linkease/nas-packages package/nas-packages

# Modify default WiFi SSID
#sed -i 's/ImmortalWrt-2.4G/SL-3000/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
#sed -i 's/ImmortalWrt-5G/SL-3000-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
#sed -i 's/MT7981_AX3000_2.4G/ImmortalWrt/g' package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b0.dat
#sed -i 's/MT7981_AX3000_5G/ImmortalWrt-5G/g' package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b1.dat

# Add OpenClash meta core
cd ./feeds/luci/applications/luci-app-openclash/root/etc/openclash/
mkdir ./core && cd ./core
curl -sfL -o ./meta.tar.gz https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz
tar -zxf ./meta.tar.gz && mv -f clash clash_meta
chmod +x ./clash* ; rm -rf ./*.gz
