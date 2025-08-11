# MTK Property Software.
#

include $(TOPDIR)/rules.mk

PKG_NAME:=ControlAppC
PKG_REVISION:=65364c
PKG_SOURCE:=$(PKG_NAME)-$(PKG_REVISION).tar.bz2
PKG_RELEASE:=1.0

PKG_BUILD_DIR:=$(BUILD_DIR)/$(PKG_NAME)

include $(INCLUDE_DIR)/package.mk
include $(INCLUDE_DIR)/kernel.mk

define Package/ControlAppC
  SECTION:=MTK Properties
  CATEGORY:=MTK Properties
  TITLE:=ControlAppC
  SUBMENU:=Applications
  DEPENDS:=+libcurl +libjson-c
endef

define Package/ControlAppC/description
  ControlAppC Daemon
endef

define Package/ControlAppC/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_DIR) $(1)/etc
	$(INSTALL_DIR) $(1)/etc/controlappc
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/ControlAppC $(1)/usr/bin/ControlAppC
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/afc_ca.pem $(1)/etc/controlappc/afc_ca.pem
endef


$(eval $(call BuildPackage,ControlAppC))
