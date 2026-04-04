# AGENTS.md — OpenWRT-CI 项目指南

> 本文件供 AI 编码代理（如 Cursor、Copilot、OpenCode）参考，帮助理解项目结构、约定和操作方式。

## 项目概述

这是一个 **OpenWRT 云编译** 项目，通过 GitHub Actions 自动编译适用于 Xiaomi WR30U (MediaTek Filogic) 路由器的 OpenWRT 固件。基于 LEDE 源码（coolsnowwolf/lede），使用 `workflow_dispatch` 手动触发构建。

## 项目结构

```
.github/workflows/   # GitHub Actions CI 配置
├── openWRT-CORE.yml      # 公用编译核心（workflow_call），所有构建共用
├── Mediatek-lede.yml     # Mediatek/LEDE 构建入口（手动触发）
└── OWRT-TEST.yml         # 清理旧 workflow 运行记录

Config/              # OpenWRT .config 配置片段
├── General.txt      # 通用组件/插件配置（所有平台共用）
└── Mediatek.txt     # Mediatek 平台特定配置（目标设备、分区大小）

Scripts/             # 自定义构建脚本
├── Extras.sh        # 追加主题和 LuCI 界面配置
├── Plugins.sh       # 克隆/更新第三方插件（Design 主题、MosDNS、Tailscale 等）
├── Renames.sh       # 编译产出物重命名（源码_型号_日期格式）
└── Settings.sh      # 修改默认设置（IP、主机名、时区、主题、WiFi 名、bash）

Depends.txt          # Ubuntu 构建环境依赖包列表
pi_zero_update.sh    # 旧版 PI Zero 设备配置脚本（参考用）
```

## 构建流程

1. **手动触发** `Mediatek-lede.yml` workflow
2. 调用 `openWRT-CORE.yml`（reusable workflow），传入平台参数
3. CI 流程：环境初始化 → 克隆 LEDE 源码 → 缓存检查 → feeds 更新 → 执行自定义脚本 → 编译 → 打包 → 发布 Release
4. 产出固件发布到 GitHub Releases，保留最近 5 个版本

### 构建命令（CI 内部，本地无需执行）

```bash
# 在 openwrt 源码目录内执行
make defconfig          # 生成完整 .config
make download -j$(nproc) # 下载源码包
make -j$(nproc) || make -j1 V=s  # 编译（失败时单线程详细输出）
```

**本地无 build/lint/test 命令**——这是一个纯 CI 配置仓库，所有编译在 GitHub Actions 上完成。

## 代码风格指南

### Shell 脚本（Scripts/ 目录）

- **Shebang**: 所有 `.sh` 文件使用 `#!/bin/bash`
- **编码**: 确保使用 Unix 换行符（LF），CI 中通过 `dos2unix` 转换
- **权限**: 所有 `.sh` 文件需可执行（`chmod +x`）
- **变量引用**: 环境变量使用大写蛇形命名（`$openWRT_TARGET`, `$WRT_WIFI`），使用 `$VAR` 而非 `${VAR}`
- **字符串比较**: 使用 `[[ $var == *"pattern"* ]]`（bash 风格）
- **命令替换**: 混用 `$(command)` 和反引号，新代码统一使用 `$(command)`
- **echo 追加**: 向 `.config` 追加配置使用 `echo "CONFIG_*=y" >> .config`
- **sed 替换**: 使用 `sed -i` 直接修改文件，`grep -P` 使用 Perl 正则
- **错误处理**: 无 `set -e`，依赖 CI 的 `|| make -j1 V=s` 回退机制
- **函数定义**: 使用 `UPPER_CASE()` 命名（如 `UPDATE_PACKAGE`, `UPDATE_VERSION`）
- **注释**: 中文注释，用 `#` 单行注释，注释掉的代码保留供参考

### YAML（.github/workflows/ 目录）

- **缩进**: 2 空格
- **注释**: 中文注释，`#` 开头
- **命名**: workflow 和 job 名使用驼峰或短横线（`openWRT-CORE`, `Mediatek-lede`）
- **环境变量**: 顶级 `env` 块定义，通过 `${{inputs.xxx}}` 传入
- **复用**: 核心流程抽取为 reusable workflow（`workflow_call`），入口 workflow 仅传参
- **权限**: `permissions: write-all`（需要创建 Release 和删除旧版本）

### Config 文件（Config/ 目录）

- **格式**: OpenWRT `.config` 片段，每行一个 `CONFIG_*=[y/n]`
- **分类注释**: 用 `#增加参数`、`#删除参数`、`#增加组件`、`#增加插件`、`#删除插件` 分区
- **首行约定**: `Config/$PLATFORM.txt` 首行以 `#` 开头注明设备型号名（被 CI 脚本解析）
- **值约定**: `=y` 启用，`=n` 禁用，数值类型直接赋值（如 `=64`）

## 关键环境变量

| 变量 | 说明 | 来源 |
|------|------|------|
| `openWRT_TARGET` | 编译平台（如 `Mediatek`） | workflow input |
| `openWRT_THEME` | 默认主题（如 `design`） | workflow input |
| `openWRT_URL` | 源码仓库 URL | workflow input |
| `openWRT_BRANCH` | 源码分支 | workflow input |
| `openWRT_IP` | 路由器默认 IP | workflow input |
| `openWRT_PW` | 默认密码 | workflow input |
| `openWRT_NAME` | 默认主机名 | workflow input |
| `WRT_WIFI` | 默认 WiFi 名称 | workflow input |
| `openWRT_DATE` | 构建日期时间 | CI 自动生成 |
| `openWRT_SOURCE` | 源码名称（从 URL 提取） | CI 自动生成 |
| `openWRT_TYPE` | 设备型号（从 Config 首行提取） | CI 自动生成 |

## 注意事项

- **不要在本地运行构建**——完整的 OpenWRT 编译需要 Linux 环境 + 大量依赖，仅在 CI 中执行
- **修改插件列表**: 编辑 `Config/General.txt`（通用插件）或 `Config/$PLATFORM.txt`（平台特定）
- **添加新插件**: 在 `Scripts/Plugins.sh` 中 `git clone` 插件仓库，在 `Config/General.txt` 中添加 `CONFIG_PACKAGE_luci-app-*=y`
- **修改默认设置**: 编辑 `Scripts/Settings.sh`（IP、主机名、时区等）
- **添加新设备**: 创建新的 workflow YAML（参考 `Mediatek-lede.yml`）和 `Config/$PLATFORM.txt`
- **缓存策略**: 使用 `actions/cache`，key 格式为 `$TARGET-$TYPE-$HASH`，toolchain 命中缓存时跳过编译
- **发布管理**: 保留最近 5 个 Release，自动删除旧的 workflow 运行记录
- **Git 用户**: 本地配置为 `简的mac <1538304461@qq.com>`，remote 为 `JianJia2018/OpenWRT-CI`
