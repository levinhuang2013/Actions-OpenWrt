/* Copyright (C) 2025 Mediatek Inc. */
#define _GNU_SOURCE

#include "mtk_vendor_nl80211.h"
#include "mt76-vendor.h"
#include "mwctl.h"

DECLARE_SECTION(set);

int handle_set_dso_glb_en(struct nl_msg *msg, int argc,
	char **argv, void *ctx)
{
	unsigned int i = 0;
	char *token;
	void *data;
	char *data_str;
	u32 dso_param[3];

	if (argc != 1)
		return -EINVAL;

	data = nla_nest_start(msg, NL80211_ATTR_VENDOR_DATA);
	if (!data)
		return -ENOMEM;

	data_str = argv[0];

	for (token = strtok(data_str, ","), i = 0;
			i < 3 && token != NULL;
			i++, token = strtok(NULL, ",")) {
		dso_param[i] = strtol(token, NULL, 10);
	}

	if (i != 3)
		return -EINVAL;

	if (nla_put(msg, MTK_NL80211_VENDOR_ATTR_DSO_GLB_EN, sizeof(dso_param), &dso_param))
			return -EMSGSIZE;

	nla_nest_end(msg, data);

	return 0;
}


COMMAND(set, dso_glb_en,
		"<dso_en:0/1>,<dso_snd_en:0/1>,<dso_5g_bw325_en:0/1>",
		MTK_NL80211_VENDOR_SUBCMD_SET_DSO,
		0, CIB_NETDEV, handle_set_dso_glb_en,
		"Set DSO GLB EN.\n");

int handle_set_dso_sta_cap(struct nl_msg *msg, int argc,
	char **argv, void *ctx)
{
	unsigned int i = 0;
	char *token;
	void *data;
	char *data_str;
	u32 dso_param[4];

	if (argc != 1)
		return -EINVAL;

	data = nla_nest_start(msg, NL80211_ATTR_VENDOR_DATA);
	if (!data)
		return -ENOMEM;

	data_str = argv[0];

	for (token = strtok(data_str, ","), i = 0;
			i < 4 && token != NULL;
			i++, token = strtok(NULL, ",")) {
		if (i == 2)
			dso_param[i] = strtol(token, NULL, 16);
		else
			dso_param[i] = strtol(token, NULL, 10);
	}

	if (i != 4)
		return -EINVAL;

	if (nla_put(msg, MTK_NL80211_VENDOR_ATTR_DSO_STA_CAP, sizeof(dso_param), &dso_param))
			return -EMSGSIZE;

	nla_nest_end(msg, data);

	return 0;
}

COMMAND(set, dso_sta_cap,
		"<wlan_id:Wlan Idx>,<dso_cap:0/1>,<support_bn_bmap:0x0-0xffff>,<switch_latency:0-65535>",
		MTK_NL80211_VENDOR_SUBCMD_SET_DSO,
		0, CIB_NETDEV, handle_set_dso_sta_cap,
		"Set DSO STA CAP.\n");


