#!/bin/bash

#Design Theme
git clone --depth=1 --single-branch --branch $(echo $openWRT_URL | grep -iq "lede" && echo "main" || echo "js") https://github.com/gngpp/luci-theme-design.git
git clone --depth=1 --single-branch https://github.com/gngpp/luci-app-design-config.git

#Argon Theme
#git clone --depth=1 --single-branch --branch $(echo $openWRT_URL | grep -iq "lede" && echo "18.06" || echo "master") https://github.com/jerrykuku/luci-theme-argon.git
#git clone --depth=1 --single-branch https://github.com/jerrykuku/luci-app-argon-config.git

#Linkease
#git clone --depth=1 --single-branch https://github.com/linkease/istore.git
#git clone --depth=1 --single-branch https://github.com/linkease/nas-packages.git
#git clone --depth=1 --single-branch https://github.com/linkease/nas-packages-luci.git

#Open Clash
#git clone --depth=1 --single-branch --branch "dev" https://github.com/vernesong/OpenClash.git

#Pass Wall
#git clone --depth=1 --single-branch --branch "luci" https://github.com/xiaorouji/openwrt-passwall.git ./pw_luci
#git clone --depth=1 --single-branch --branch "packages" https://github.com/xiaorouji/openwrt-passwall.git ./pw_packages

#unblockneteasemusic
#rm -rf ../../customfeeds/luci/applications/luci-app-unblockmusic
#git clone --depth=1 --single-branch --branch "master" https://github.com/UnblockNeteaseMusic/luci-app-unblockneteasemusic.git

#xlnetacc
#git clone --depth=1 --single-branch --branch "master" https://github.com/a7909a/luci-app-xlnetacc.git

#adguardhome
git clone --depth=1 --single-branch --branch "master" https://github.com/rufengsuixing/luci-app-adguardhome.git

#vssr
git clone --depth=1 --single-branch --branch "master" https://github.com/jerrykuku/lua-maxminddb.git
git clone --depth=1 --single-branch --branch "master" https://github.com/jerrykuku/luci-app-vssr.git