include $(TOPDIR)/rules.mk

PKG_NAME:=chinadns-ng
PKG_VERSION:=2026.09.13
PKG_RELEASE:=1

ifeq ($(ARCH),aarch64)
  PKG_ARCH:=chinadns-ng+wolfssl_noasm@aarch64-linux-musl@generic+v8a@fast+lto
else ifeq ($(ARCH),x86_64)
  PKG_ARCH:=chinadns-ng+wolfssl@x86_64-linux-musl@x86_64@fast+lto
else
  PKG_ARCH:=unsupported-arch
endif

PKG_SOURCE:=$(PKG_NAME)-$(PKG_VERSION)-$(ARCH_PACKAGES)
PKG_SOURCE_URL:=https://github.com/HyperionHXH/chinadns-ng/releases/download/$(PKG_VERSION)/$(PKG_ARCH)?
UNPACK_CMD=$(CP) $(DL_DIR)/$(PKG_SOURCE) $(PKG_BUILD_DIR)/$(PKG_NAME)
PKG_HASH:=skip

PKG_LICENSE:=AGPL-3.0-only
PKG_LICENSE_FILES:=LICENSE
PKG_MAINTAINER:=HyperionHXH

include $(INCLUDE_DIR)/package.mk

define Package/chinadns-ng
  SECTION:=net
  CATEGORY:=Network
  SUBMENU:=IP Addresses and Names
  TITLE:=ChinaDNS next generation (HyperionHXH fork build)
  URL:=https://github.com/HyperionHXH/chinadns-ng
  DEPENDS:=@(aarch64||x86_64)
endef

define Package/chinadns-ng/description
  ChinaDNS NG，构建自 HyperionHXH/chinadns-ng fork 的每日自动构建。
  与上游 zfl9/chinadns-ng 相比：上游长期未发版时，这里保持可用的
  自动构建通道，版本号使用构建日期。
endef

define Build/Compile
endef

define Package/chinadns-ng/install
	$(INSTALL_DIR) $(1)/usr/bin
	$(INSTALL_BIN) $(PKG_BUILD_DIR)/chinadns-ng $(1)/usr/bin
endef

$(eval $(call BuildPackage,chinadns-ng))
