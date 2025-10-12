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
sed -i 's/192.168.6.1/192.168.0.1/g' package/base-files/files/bin/config_generate

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
git clone https://github.com/nikkinikki-org/OpenWrt-nikki package/nikki
git clone https://github.com/eamonxg/luci-theme-aurora package/aurora

# Modify default WiFi SSID
sed -i 's/ImmortalWrt-2.4G/COMFAST-2.4G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh
sed -i 's/ImmortalWrt-5G/COMFAST-5G/g' package/mtk/applications/mtwifi-cfg/files/mtwifi.sh

# Add OpenClash DEV/TUN core
cd ./feeds/luci/applications/luci-app-openclash/root/etc/openclash/
mkdir ./core && cd ./core
#curl -sfL -o ./dev.tar.gz https://github.com/vernesong/OpenClash/raw/core/dev/dev/clash-linux-arm64.tar.gz
#tar -zxf ./dev.tar.gz
#curl -sfL -o ./clash_tun.gz https://github.com/vernesong/OpenClash/raw/core/dev/premium/clash-linux-arm64-2023.08.17-13-gdcc8d87.gz
#gzip -d clash_tun.gz
curl -sfL -o ./meta.tar.gz https://github.com/vernesong/OpenClash/raw/core/dev/meta/clash-linux-arm64.tar.gz
tar -zxf ./meta.tar.gz && mv -f clash clash_meta
chmod +x ./clash* ; rm -rf ./*.gz
