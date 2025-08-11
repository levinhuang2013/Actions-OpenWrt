#
# hua.shao@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=AFC
PKG_REVISION:=e20d70
PKG_SOURCE:=$(PKG_NAME)-$(PKG_REVISION).tar.bz2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

TARGET_CFLAGS += -DCONFIG_SUPPORT_OPENWRT
MAKE_FLAGS += CONFIG_SUPPORT_OPENWRT=y
MAKE_FLAGS += UAPD_INCLUDE_PATH=$(LINUX_DIR)/include/uapi/linux/wapp
MAKE_FLAGS += NL80211_INCLUDE_PATH=$(LINUX_DIR)/include/uapi/linux/mtk_nl80211_inc

define Package/AFC
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=AFC daemon
  SUBMENU:=Applications
  DEPENDS:= +USE_UCLIBC:libpthread +USE_UCLIBC:librt +libkvcutil +libopenssl +libnl-tiny +libcurl +libjson-c +WAPP_WPACTRL_SUPPORT:libwpactrl
endef

define Package/AFC/description
  AFC daemon
endef

define Package/AFC/config
	source "$(SOURCE)/Config.in"
endef


TARGET_CFLAGS += \
	-D_GNU_SOURCE \
	-I$(STAGING_DIR)/usr/include/libnl-tiny \
	-I$(PKG_BUILD_DIR) \


ifeq ($(CONFIG_WAPP_WPACTRL_SUPPORT), y)
MAKE_FLAGS += CONFIG_WPACTRL_SUPPORT=y
TARGET_CFLAGS += \
	-DWPACTRL_SUPPORT \
	-I$(STAGING_DIR)/usr/include/wpactrl
endif

define Package/AFC/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/AFC $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/afc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/location.cfg $(1)/etc/afc/location.cfg
endef

$(eval $(call BuildPackage,AFC))

