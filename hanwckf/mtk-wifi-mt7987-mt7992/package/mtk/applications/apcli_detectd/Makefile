#
# Bing-Ruei.Hsieh@mediatek.com
#
# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=apcli_detectd
PKG_REVISION:=527a38
PKG_SOURCE:=$(PKG_NAME)-$(PKG_REVISION).tar.bz2
PKG_RELEASE:=1

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/apcli_detectd
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=an program to detect the connection of apclients.
  SUBMENU:=Applications
  DEPENDS:=+@KERNEL_DEVMEM
endef

define Package/apcli_detectd/description
  an program to detect the connection of apclients.
endef

define Package/apcli_detectd/install
	$(INSTALL_DIR) $(1)/etc/init.d
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/apcli_detectd $(1)/usr/bin
	$(INSTALL_BIN) ./files/apcli_detectd.init $(1)/etc/init.d/apcli_detectd
endef


$(eval $(call BuildPackage,apcli_detectd))
