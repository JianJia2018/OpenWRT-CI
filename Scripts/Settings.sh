#!/bin/bash

#删除冲突插件
#rm -rf $(find ./feeds/luci/ -type d -regex ".*\(argon\|bootstrap\|openclash\).*")
#修改默认主题
sed -i "s/luci-theme-design/luci-theme-$openWRT_THEME/g" $(find ./feeds/luci/collections/ -type f -name "Makefile")
#修改默认IP地址
sed -i "s/192\.168\.[0-9]*\.[0-9]*/$openWRT_IP/g" ./package/base-files/files/bin/config_generate
#修改默认主机名
sed -i "s/hostname='.*'/hostname='$openWRT_NAME'/g" ./package/base-files/files/bin/config_generate
#修改默认时区
sed -i "s/timezone='.*'/timezone='CST-8'/g" ./package/base-files/files/bin/config_generate
sed -i "/timezone='.*'/a\\\t\t\set system.@system[-1].zonename='Asia/Shanghai'" ./package/base-files/files/bin/config_generate

#修改默认WIFI名
sed -i "s/\.ssid=.*/\.ssid=$WRT_WIFI/g" $(find ./package/kernel/mac80211/ ./package/network/config/ -type f -name "mac80211.*")


#修默认bash
sed -i 's/\/bin\/ash/\/bin\/bash/g' ./package/base-files/files/etc/passwd

#根据源码来修改
if [[ $WRT_URL == *"lede"* ]]; then
	LEDE_FILE=$(find ./package/lean/autocore/ -type f -name "index.htm")
	#修改默认时间格式
  sed -i 's/os.date()/os.date("%Y-%m-%d %H:%M 星期%w")/g' $LEDE_FILE
fi

sed -i 's:/bin/ash:/bin/bash:g' /etc/passwd

sed -i "/helloworld/d" "feeds.conf.default"
echo "src-git helloworld https://github.com/fw876/helloworld.git" >> "feeds.conf.default"
./scripts/feeds update -a && ./scripts/feeds install -a

# 注释原行（精确匹配原URL和版本）
sed -i '/src-git luci https:\/\/github.com\/coolsnowwolf\/luci\.git;openwrt-23.05/s/^/#/' "feeds.conf.default"

# 添加新行到文件末尾
echo "src-git luci https://github.com/coolsnowwolf/luci.git" >> "feeds.conf.default"