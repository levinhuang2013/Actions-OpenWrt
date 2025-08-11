#!/bin/sh
# SPDX-License-Identifier: MediaTekProprietary

killall mt76-test

# Disable ids log to avoid the size of fwlog being too large.
echo 1 > /sys/kernel/debug/ieee80211/phy0/mt76/fw_debug_muru_disable

# record ICS log for 3 band
mwctl phy0 mac 820E705C=1FF0000
mwctl phy0 mac 820E7060=58000D0
mwctl phy0 mac 820E4120=1301

mwctl phy0 mac 820F705C=1FF0006
mwctl phy0 mac 820F7060=58000D0
mwctl phy0 mac 820F4120=1301

mwctl phy0 mac 830E705C=1FF000C
mwctl phy0 mac 830E7060=58000D0
mwctl phy0 mac 830E4120=1301

mkdir /tmp/mtk_log
mt76-test phy0 fwlog 0.0.0.0 15 /tmp/mtk_log/fw_log.bin &
