#!/bin/sh
# SPDX-License-Identifier: MediaTekProprietary

mt76-test phy0 fwlog 0.0.0.0 0 &
sleep 1

killall mt76-test

# Stop In-Chip sniffer for IP0_Band 0
mwctl phy0 mac 820E705C=0FF0000
sleep 1
# Stop In-Chip sniffer for IP0_Band 1
mwctl phy0 mac 820F705C=0FF0000
sleep 1
# Stop In-Chip sniffer for IP1_Band 0(=Band 2)
mwctl phy0 mac 830E705C=0FF0000

# Restore the ids log default setting
echo 0 > /sys/kernel/debug/ieee80211/phy0/mt76/fw_debug_muru_disable

sleep 1
echo -e "**** Stop recording fw parser log & ics log ****\n"
chmod 777 /tmp/mtk_log/fw_log.bin
