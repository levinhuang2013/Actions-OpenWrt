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
#sed -i 's/192.168.1.1/192.168.50.5/g' package/base-files/files/bin/config_generate

# Modify default theme
#sed -i 's/luci-theme-bootstrap/luci-theme-argon/g' feeds/luci/collections/luci/Makefile

# Modify hostname
#sed -i 's/OpenWrt/P3TERX-Router/g' package/base-files/files/bin/config_generate

# Add packages
#git clone -b js https://github.com/gngpp/luci-theme-design package/luci-theme-design
#git clone https://github.com/rufengsuixing/luci-app-adguardhome package/luci-app-adguardhome
#git clone https://github.com/messense/aliyundrive-webdav package/aliyundrive-webdav

# Modify default WiFi SSID
#sed -i 's/ImmortalWrt-2.4G/Xiaomi_203/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
#sed -i 's/ImmortalWrt-5G/Xiaomi_203-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
#sed -i 's/MT7981_AX3000_2.4G/Xiaomi_203/g' package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b0.dat
#sed -i 's/MT7981_AX3000_5G/Xiaomi_203-5G/g' package/mtk/drivers/wifi-profile/files/mt7981/mt7981.dbdc.b1.dat

# Use WACPU/WOCPU NEW FW
sed -i 's/mt7981-fw-20230306/mt7981-fw-20230411/g' package/mtk/drivers/mt_wifi/Makefile
#sed -i 's/mt7981-fw-20230411/mt7981-fw-20230330/g' package/mtk/drivers/warp/Makefile

# Add OpenClash DEV/TUN core
#cd ./feeds/luci/applications/luci-app-openclash/root/etc/openclash/
#mkdir ./core && cd ./core
#curl -sfL -o ./dev.tar.gz https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-arm64.tar.gz
#tar -zxf ./dev.tar.gz
#curl -sfL -o ./clash_tun.gz https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz
#gzip -d clash_tun.gz
#chmod +x ./clash* ; rm -rf ./*.gz
