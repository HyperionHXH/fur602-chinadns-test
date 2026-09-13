#!/bin/bash
set -e -o pipefail

# fur602 23.05 测试固件构建脚本：
# 复用 immortalwrt-mt798x-2305 wrapper 的全套准备逻辑（passwall 上游最新、
# dnsmasq 补丁、23.05 设备适配），只编 honor_fur-602 一台设备，
# 并把 chinadns-ng 替换为 HyperionHXH/chinadns-ng fork 的自动构建版本。

OPENWRT_REPO="https://github.com/padavanonly/immortalwrt-mt798x-6.6"
OPENWRT_COMMIT="8fd3008be125e590664b311e3aaedee344adc354"
WRAPPER_REPO="${WRAPPER_REPO:-https://github.com/HyperionHXH/immortalwrt-mt798x-2305}"
DEVICE="honor_fur-602"
FORK_REPO="${FORK_REPO:-HyperionHXH/chinadns-ng}"

# 1. fork 的最新 release tag
cdn_version="$(curl -fsSL "https://api.github.com/repos/${FORK_REPO}/releases/latest" \
  | sed -n 's/.*"tag_name": *"\([^"]*\)".*/\1/p')"
[ -n "$cdn_version" ] || { echo "无法获取 ${FORK_REPO} 的最新 release" >&2; exit 1; }
echo ">> fork chinadns-ng 最新 release：$cdn_version"

# 2. wrapper 与源码
rm -rf wrapper openwrt
git clone --depth=1 "$WRAPPER_REPO" wrapper
git init openwrt
git -C openwrt remote add origin "$OPENWRT_REPO"
git -C openwrt fetch --depth=1 origin "$OPENWRT_COMMIT"
git -C openwrt checkout --detach FETCH_HEAD
test "$(git -C openwrt rev-parse HEAD)" = "$OPENWRT_COMMIT"

cd openwrt
export GOPROXY="${GOPROXY:-https://goproxy.cn,direct}"

# 3. 2305 全套准备（与主线 CI 完全一致）
bash ../wrapper/01_prepare.sh
bash ../wrapper/scripts/validate_2305_adaptations.sh .

# 4. 用 fork 构建的 chinadns-ng 顶替（01_prepare.sh 已删除 feed 里的旧版）
rm -rf package/chinadns-ng
cp -a ../chinadns-ng-override package/chinadns-ng
sed -i "s/^PKG_VERSION:=.*/PKG_VERSION:=${cdn_version}/" package/chinadns-ng/Makefile
grep -E "PKG_VERSION|PKG_SOURCE_URL" package/chinadns-ng/Makefile

# 5. 配置：mt7981-ax3000 的完整包组合，只编 fur602 一台设备
# （defconfig 在源码树里，01_prepare.sh 的设备适配脚本已写入全部候选设备）
cfg=defconfig/mt7981-ax3000.config
grep -vE "^CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_" "$cfg" > .config
printf 'CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_%s=y\n' "$DEVICE" >> .config
printf 'CONFIG_TARGET_DEVICE_PACKAGES_mediatek_mt7981_DEVICE_%s=""\n' "$DEVICE" >> .config
echo "CONFIG_TARGET_SQUASHFS_XZ=y" >> .config
# package.conf 在 wrapper 仓库里，而 02_add_package.sh 默认读 ../package.conf
PACKAGE_CONF=../wrapper/package.conf bash ../wrapper/02_add_package.sh
make defconfig

# 6. 校验关键项
grep -Fq "CONFIG_TARGET_DEVICE_mediatek_mt7981_DEVICE_${DEVICE}=y" .config \
  || { echo "设备 profile ${DEVICE} 未启用" >&2; exit 1; }
grep -Fq "CONFIG_PACKAGE_chinadns-ng=y" .config \
  || { echo "chinadns-ng 未被选中" >&2; exit 1; }
grep -Fq "CONFIG_PACKAGE_luci-app-passwall=y" .config \
  || { echo "luci-app-passwall 未被选中" >&2; exit 1; }
bash ../wrapper/scripts/validate_2305_packages.sh .config

# 7. 下载并编译
make download -j8 || make download -j1 V=s
make -j"$(nproc)" || make -j1 V=s
