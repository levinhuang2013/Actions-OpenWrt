#
# MTK Property Software.
#
include $(TOPDIR)/rules.mk

PKG_NAME:=libwpactrl
PKG_REVISION:=74f317
PKG_SOURCE:=$(PKG_NAME)-$(PKG_REVISION).tar.bz2
PKG_RELEASE:=1

PKG_BUILD_PARALLEL:=0

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/cmake.mk

# set to 1 to enable debugging
DEBUG=

define Package/libwpactrl
  SECTION:=libs
  CATEGORY:=Libraries
  TITLE:=C library for the wpa ctrl interface
  DEPENDS:=+hostapd +hostapd-common
  ABI_VERSION:=20130104
endef

HOSTAPD_DIR=$(shell find ${BUILD_DIR}/hostapd* -name hs20 | xargs dirname)
CMAKE_OPTIONS += -DHOSTAPD_DIR=$(HOSTAPD_DIR)

TARGET_CFLAGS += -I$(STAGING_DIR)/usr/include -DWPACTRL_SUPPORT_MTK_EXTENSION
TARGET_LDFLAGS += -L$(STAGING_DIR)/usr/lib

define Package/libwpactrl/install
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwpactrl.so* $(1)/usr/lib/
endef

define Build/InstallDev
	$(INSTALL_DIR) $(1)/usr/include/wpactrl
	$(CP) $(PKG_BUILD_DIR)/include/libwpactrl.h $(1)/usr/include/wpactrl
	$(INSTALL_DIR) $(1)/usr/lib
	$(CP) $(PKG_BUILD_DIR)/libwpactrl.so* $(1)/usr/lib
endef

$(eval $(call BuildPackage,libwpactrl))
