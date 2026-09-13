# fur602-chinadns-test

用 fork 自动构建的 ChinaDNS-NG 编译 23.05 Honor FUR-602 测试固件。

## 组成

- [`chinadns-ng-override/Makefile`](chinadns-ng-override/Makefile)：顶替 ImmortalWrt
  packages feed 里的 chinadns-ng（下载源指向 `HyperionHXH/chinadns-ng` 的 release，
  `PKG_VERSION` 在构建时自动改成 fork 的最新 release tag）。安装路径与原包一致：
  `/usr/bin/chinadns-ng`，passwall 无感知。
- [`build_firmware.sh`](build_firmware.sh)：复用
  [immortalwrt-mt798x-2305](https://github.com/HyperionHXH/immortalwrt-mt798x-2305)
  wrapper 的 `01_prepare.sh`（含 passwall 上游最新、dnsmasq 默认关闭重绑定保护、
  23.05 设备适配），源码固定在 padavanonly `openwrt-23.05` 的
  `8fd3008be125e590664b311e3aaedee344adc354`，只编 `honor_fur-602` 一个 profile。
- [`.github/workflows/build.yml`](.github/workflows/build.yml)：每天北京时间 06:30
  自动跟随 fork 最新 chinadns-ng 构建一次，也可手动触发。

## 与上游的关系

- 源仓库 [zfl9/chinadns-ng](https://github.com/zfl9/chinadns-ng) 自 2025.08.09 后
  未再发布新版本。
- [HyperionHXH/chinadns-ng](https://github.com/HyperionHXH/chinadns-ng) fork
  每天同步上游 master，用 zig 0.10.1 交叉构建静态二进制并发版，版本号使用构建
  日期（保证新于上游最后一版，passwall 的"检查更新"不会往回刷）。

## 刷机

Release 里的 7z 解压后得到 `immortalwrt-...-honor_fur-602-squashfs-*.bin`：

- 从原厂/其他固件首次刷入用 factory 包；
- 从本仓库旧版 23.05 固件升级用 sysupgrade 包（保留配置）。

验证 chinadns-ng 版本：

```sh
chinadns-ng --version
opkg list-installed | grep chinadns
```
