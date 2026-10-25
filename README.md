<p align="center"><b>简体中文</b> · <a href="README.en.md">English</a></p>

<h1 align="center">长征机 · dsh-theme-longmarch</h1>

> **作者**：[@Soviet-Dreadnaught](https://github.com/Soviet-Dreadnaught)
> **仓库**：https://github.com/Soviet-Dreadnaught/dsh-theme-longmarch
>
> 转载、搬运、做视频请保留上面这两行 —— 项目名很容易和别的长征主题插件混在一起。

<img src="icon@2x.png" width="96" alt="长征终端">

![动效预览：四套部门预设轮播](docs/demo.gif)

<sub>动效预览（四套部门预设轮播）：红色数据雨、CRT 扫描线 + 过扫光带、军委的雷达扫描扇、徽记水印。</sub>


> 把 DeepSeek Harness 的 Web GUI 换成《烈焰升腾》（The Fire Rises）新左派「长征 / Loji」AI 路线的终端：
> 纯黑底 + 磷光红字符、红色数据雨、CRT 扫描线，四套部门预设各自带徽记、配色与背景纹样。

纯视觉插件。不注册工具、不发网络请求、不写宿主 DOM，只做三件事：重映射 `--dsw-*` 令牌、注入一层全部挂在 `body[data-dsh-longmarch]` 下的 CSS、在官方插槽里渲染装饰层与设置页。

## 目录

- [它做什么](#它做什么)
- [安装](#安装)
- [四套部门预设](#四套部门预设)
- [设置项](#设置项)
- [兼容性](#兼容性)
- [实现笔记](#实现笔记)
- [故障档案](#故障档案)
- [徽记取材](#徽记取材)
- [已知限制](#已知限制)
- [许可](#许可)

## 它做什么

- **配色**：整套 `--dsw-*` 令牌重映射为长征路线色板（纯黑底 + 磷光红 + 信号绿 / 琥珀 / 品红）
- **四套部门预设**：党务管理 / 国家政务 / 中央军委 / 国家安全 —— 各自带徽记、配色与背景纹样，一键切换
- **动效**：红色二进制雨（`shell.overlay` 层）、CRT 扫描线 + 过扫光带、暗角、柔和噪点、左下角 CHANGZHENG / CPUPF 读数
- **设置页**：设置 → 左侧「长征终端」：切预设、开关各特效、辉光强度、扫描线亮度、背景徽记强度、字符亮度（60–200%）、重置（存在浏览器 localStorage）
- **品牌位接管**：左上角官方 DeepSeek 字样换成 `CHANGZHENG / CPUPF · 状态 + 光标`（`sidebar.brand.name` / `sidebar.brand.mark`，priority -1 覆盖官方）
- **新会话标题接管**：新会话页的鲸鱼与「探索未至之境」换成党徽 + `长征计划 · LONG MARCH` / `走向数字世界 · CPUPF`（可关）
- **TUI 直角**：半径令牌全部归零；输入卡（`[data-composer-card]`）改为 1px 亮红硬边 + 焦点发光
- **锁定暗色**：注册 `colorScheme: dark` 的真主题并钉住，宿主才会写 `color-scheme: dark` / `data-ds-dark-theme`，其它插件据此切到暗色面板
- **浅色令牌兜底**：覆盖 `--dsw-static-neutral-50/-100` 与 `--dsw-alias-file-diff-*`，消除交付卡 / 改动卡的白块

## 安装

### 方式一：放进 profile 的 node_modules（推荐，桌面版可用）

```powershell
# 1. 包放进 profile 的 node_modules
Copy-Item -Recurse -Force '.\dsh-theme-longmarch' "$env:DSH_PROFILE_DIR\node_modules\dsh-theme-longmarch"

# 2. 在 profile 的 cordis.patch.yml 末尾保留挂载行
#    - insert:
#        - id: dsh-theme-longmarch
#          name: 'dsh-theme-longmarch'

# 3. Ctrl+F5 刷新页面（宿主图变化通常会自动热更）
```

Windows 桌面版的 profile 默认在 `%USERPROFILE%\.dsh\profiles\desktop`。

卸载：删掉 `node_modules\dsh-theme-longmarch` 与那三行挂载即可。

### 方式二：CLI

```bash
dsh plugin --profile desktop add ./dsh-theme-longmarch
```

> 桌面版对 CLI 安装可能会拒绝（需要先确认宿主版本允许本地包装载）；被拒就走方式一。

## 四套部门预设

![四套部门预设配色对照](docs/presets.jpg)

<sub>四套预设的静态对照（党务 / 政务 / 军委 / 国安）。徽记、配色与背景纹样会整体切换。</sub>

| 预设 | id | 徽记 | 形式 | 配色 | 背景纹样 |
|---|---|---|---|---|---|
| 党务管理 | `party` | 党徽（镰刀锤头） | 矢量 24×24 | 红磷光 | 终端网格 + 红色数据雨 + 党徽水印 |
| 国家政务 | `state` | 国徽 | 单色线稿 384×384 | 金 / 暖白 | 金色公文网格 + 缓速数据流 + 国徽水印 |
| 中央军委 | `cmc` | 军徽（红底金星 + 金八一） | 位图 256×256 | 橙红 / 金 | 战术网格 + 雷达扫描扇 + 军徽水印 |
| 国家安全 | `mss` | 国安徽（盾 + 长城 + 叶环） | 单色线稿 384×384 | 钢蓝 / 青 | 环形网格 + 十字准线 + 国安徽水印 |

中性层（底色 / 面板 / 边框）由预设的 `label` 色按比例派生，所以换预设时整套皮肤会跟着换色调。
徽记装配在 `MARKS` 表里，品牌位、新会话 hero、背景水印三处共用同一份定义。

## 设置项

| 项 | 说明 | 默认 |
|---|---|---|
| 部门预设 | 四选一，切换徽记 / 配色 / 背景纹样 | 党务管理 |
| 数据雨 | 红色二进制雨背景层 | 开 |
| 扫描线 | CRT 扫描线 + 缓慢过扫光带 | 开 |
| 暗角 | 屏幕四周压暗 | 开 |
| 角标读数 | 接管左上角品牌位（CHANGZHENG / CPUPF / 光标） | 开 |
| 背景徽记 | 背景里的部门徽记强度（预设基准 × 倍率，0 = 关闭） | 150% |
| 辉光强度 | 文字辉光、扫描线与噪点强度 | 65 |
| 扫描线亮度 | CRT 扫描线与过扫光带的强度 | 50 |
| 字符亮度 | 文字与边线亮度（60–200%），偏暗就往上拉 | 100 |
| 共存模式 | 自动让位 / 强制接管（见下） | 自动让位 |
| 接管品牌位 | 关掉即把左上角官方字样原样交还 | 开 |
| 锁定暗色 | 注册并钉住 `colorScheme: dark` 主题 | 开 |
| 页面高度兜底 | 封掉页面级滚动，排障用（默认关） | 关 |
| 布局诊断 | 右下角显示 innerH / rootH / frameH 与 body 直系子节点 | 关 |
| 弹窗转当前窗口 | 把同源带 hash 的 `window.open` 改成当前窗口改 hash + reload | 关 |

所有设置存在浏览器 localStorage（键 `dsh.longmarch.v1`），换机器不带过去。

## 兼容性

### 生态约定

DSH 的皮肤 / 主题类插件靠 **body 上的通用属性**互相识别（`dsh-mpkg-wallpaper` 的 `detectConflicts()` 里写死了这份名单：
`data-dsh-aurora` / `data-dsh-whale-song` / `data-dsh-skin` / `data-dsh-ui-skin` / `data-dsh-theme` / `data-skin`）。
本插件同时做两件事：

- **自报家门**：在 `<body>` 打 `data-dsh-skin` / `data-dsh-ui-skin` / `data-dsh-theme` = `longmarch`，壁纸 / 主题切换器据此让位（另有自有属性 `data-dsh-longmarch`）。
- **检测别人**：扫上面那份签名 + `[data-plugin]` 里的已知主题 / 皮肤 / 壁纸 id + `ctx.theme` 已注册的第三方主题。

### 共存模式

| 档位 | 行为 |
|---|---|
| 自动让位（默认） | 检测到其它皮肤 / 主题时**不注册主题、不抢外观偏好**，只保留自己的 CSS 层 |
| 强制接管 | 无视冲突，始终钉住本主题 |

### 传送门表面

`dialog` / `[role=dialog]` / `[role=menu]` / `[data-menu-material]` / `[data-radix-popper-content-wrapper]>*`
这些被 React 挂到 `body` 上的根会**自带一份令牌**，光靠 body 继承盖不住 —— 本主题对它们再声明一遍关键令牌。
（选择器抄自月下载量最高的皮肤 `@smalltailqwq/dsh-client-ui-skin-maid-atelier`。）

## 实现笔记

### 徽记为什么画在覆盖层，而不是背景层

本插件的整屏装饰（数据雨、扫描线、徽记）都画在 `shell.overlay` 插槽里，而不是 `body::before` 的背景图层。原因见[故障档案](#故障档案)第 4、5 条：
**宿主的结构性整屏面（AppFrame → 侧栏 → 会话根 → 卡片）是逐层叠上来的**，画在内容之下的装饰每穿一层就衰减一次，
12% 的徽记穿到第 2~3 层已经归零。覆盖层是宿主自己给皮肤提供的装饰位，稳定可见。

代价是装饰会浮在内容之上，所以：

- 徽记默认 12~14% 基准 × 1.5 倍率（设置里可调，0 = 关）
- 数据雨、扫描线都是稀疏 / 低对比度的图案
- 底图那层只留网格与底色渐变，不承担"看得见"的职责

### 覆盖层内部分层表

`.lm-fx` 的子元素全是 `position:absolute`，所以 `z-index` 直接生效：

| z-index | 内容 |
|---|---|
| 1 | 背景纹样：军委的旋转光束 `.lm-radar`、国安的同心圆 `.lm-rings` + 十字准线 `.lm-cross` |
| 2 | 徽记 `.lm-wm` |
| 3 | 数据雨 `.lm-rain` |
| 4 | 扫描线 `.lm-scan` / 过扫光带 `.lm-sweep` |
| 5 | 暗角 `.lm-vig` |
| 6 / 7 | 角标读数 `.lm-hud` / 布局诊断 `.lm-diag` |

徽记压在光束与同心圆之上是刻意的：光束、同心圆是「背景扫描」，徽记是「前景徽记」。JSX 的 `kids.push` 顺序也按这张表排，CSS 只是把规则钉死。

### 主题注册

只叠 token 层不足以让其它插件识别出"宿主是暗色"。本插件注册一个 `colorScheme: dark` 的真主题并 `setTheme`，
宿主才会写 `color-scheme` 与 `body[data-ds-dark-theme]`；`theme/change` 事件上挂了守卫，主题被别的插件抢走时会重新钉回来。

## 故障档案

| 症状 | 根因 | 处理 |
|---|---|---|
| 交付卡 / 改动卡一片白 | `dsh-client-ui-deliverables` 的 `--changes-fill / --deliverable-fill` 指向 `--dsw-static-neutral-50`，diff 区用浅色 `--dsw-alias-file-diff-*-bg` | 覆盖两个静态中性色根 + 6 个 file-diff 令牌（同时写进 `!important` 兜底块） |
| 第三方面板在深色皮肤里仍是浅灰 | 对方按 `data-ds-dark-theme` / `color-scheme` 判断宿主主题，默认回落 white | 注册 `colorScheme: dark` 的真主题并钉住（设置页「锁定暗色」） |
| 主界面往下滚出现一整截空白 | 第三方浮动面板的位置来自它自己持久化的几何，与主题无关 | 主题侧提供高度链兜底（设置页「页面高度兜底」）+「布局诊断」定位 |
| 背景底图整层不显示 | ① 宿主给 `html` 铺底后，`body` 的 `background-color` 不再传播到画布，而是作为普通盒子背景画在 `body::before`（`z-index:-2`）之上；② 结构面用不透明的 `--dsw-alias-bg-base` 铺底 | `body` 改 `background-color: transparent`（底色交给 `::before` 最底那层渐变，另给 `html` 补一份防闪白）；`--dsw-alias-bg-base` 改 `transparent`、侧栏填充改 86% 半透明，并把 `#root` / `*_frame` / `*_centerCol` / `*_sidebarCol` / `*_rightbarCol` / `*_root[data-phase]` 显式放空 |
| 只有部分预设能看见背景徽记 | 整屏面逐层叠加，`::before` 里 12% 的徽记每穿一层衰减一次，到第 2~3 层归零 | 徽记改由覆盖层（`shell.overlay` → `.lm-fx` → `.lm-wm`）绘制，和数据雨同级同性质 |
| 徽记被旋转光束 / 同心圆压在下面 | 覆盖层内部没有定 `z-index`，只看 DOM 顺序 | 定死分层表（见上），JSX 顺序与 CSS 同步 |

> 定位方法：装上 Edge（`msedge.exe --headless=new --screenshot`）跑一张**用宿主真实类名与令牌 1:1 复刻的壳页**，
> 同一份 CSS 改前改后各截一张，差异当场可见，不用猜。层级这类问题还可以把光束临时换成纯色方块 + 把徽记拉满不透明度，
> 直接量中心像素 —— 比看截图靠谱。

## 徽记取材

| 徽记 | 形式 | 来源与处理 |
|---|---|---|
| 党徽 | 矢量 24×24（145 点） | 官方标准图案描摹（人民网受权发布 4096px PNG）：alpha 0.5 等值线 marching squares → Douglas-Peucker 简化 → 归一化到 24×24 viewBox → 单条闭合填充路径 |
| 国徽 | 单色线稿 384×384 | 线稿取墨（`R - max(G,B)`）→ 裁边归一 → 12 级 alpha 遮罩 |
| 军徽 | 双色位图 256×256 | 官方图样线稿 → 星体填红、墨线与八一填金 |
| 国安徽 | 单色线稿 384×384 | 同上，取墨后压成单通道遮罩 |

三种形态各有各的道理：

- **矢量**（党徽）：线条少，任意缩放都不糊，填充直接取预设的 `main` 色。
- **单色线稿遮罩**（国徽 / 国安徽）：把线稿的墨迹抽成一张只有 alpha 的 PNG，CSS 里用 `mask-image` 挖形、`currentColor` 上色 ——
  所以颜色完全跟着预设走（政务=金、国安=钢蓝），改色不用重出图。
  徽记外再套一层 `.lm-glow` 做轮廓辉光：一个 1px 的紧光圈叠一个 3.5px 的弱光圈，两层都很淡（水印那档换成 `vmin` 单位，跟着尺寸放大）。
  > 辉光必须挂在外层 —— `filter` 比 `mask` 先生效，挂在同一层会被遮罩裁掉。
- **双色位图**（军徽）：红底金星 + 金八一自带配色，保持不动。

所有资源都是 data URI 内嵌，插件始终是**单文件、零依赖**（只 `require('react')`，走平台模块表）。

`main` / `deep` 两个色位作用于矢量与单色遮罩徽记；军徽那份双色位图自带配色 —— 换色需要重新生成 PNG。

> 注：党徽、国徽、军徽均为官方标准图案；国安徽是线稿抠图版，国家安全机关未公开发布过标准徽。

### 生态参考（2026-10 抓取）

| 插件 | npm 近 30 天下载 | GitHub stars |
|---|---|---|
| dshmarket | 596,609 | – |
| dsh-better-sidebar | 241,407 | – |
| dsh-whale-widget | 186,009 | 4,853 |
| @smalltailqwq/dsh-client-ui-skin-maid-atelier | 39,269 | – |
| dsh-mpkg-wallpaper | 8,946 | – |
| dsh-theme-whalegirl | 2,805 | 1 |
| dsh-joi-channel-theme | 2,548 | – |

主题类里装机量最高的是 skin-maid（下载）与 whale-widget（stars）。本插件保留自己的实现，但把它们的**共存机制**
（通用属性签名、传送门令牌再声明、冲突让位）搬了过来。

## 图标

插件图标取自《烈焰升腾》本体的长征机图样：
`gfx/interface/ideas/PRC/PRC_the_long_march_idea.png`（机柜 + 红星 + 镰刀锤头 + 二进制串，正是长征机那条国策线的图标）。

- `icon.png` —— 原图裁边后的 68×68 真彩 PNG 调色板版（2.4 KB）
- `icon@2x.png` —— 136×136，给需要更大尺寸的场合
- `icon.svg` —— 同一张图的自包含 SVG 包装（内部内嵌 PNG，单文件可缩放）

DSH 插件管理页读的是 **`package.json` 的 `meta.icon`**，它被直接当作 `<img src>` 使用，所以那里填的是这张 PNG 的 data URI（3.2 KB）——
本地安装的插件没有市场图床，只能内嵌。

## 已知限制

- **主题是全局的**：开启后所有面板都会变成红黑配色，这是皮肤的本意，不是 bug。
- **与其它皮肤插件同时启用**时默认让位（只保留 CSS 层，不抢主题偏好）；想强推就切「强制接管」。
- **安装需要写 profile 目录**：CLI 安装被拒时只能手动放包（见安装方式一）。
- **纯 CSS 层不做像素级布局改动**：主题不移动、不隐藏宿主控件，只改外观。

## 作者与来源

- **作者**：[@Soviet-Dreadnaught](https://github.com/Soviet-Dreadnaught)
- **仓库**：https://github.com/Soviet-Dreadnaught/dsh-theme-longmarch
- 同人创作，与《烈焰升腾》模组作者、与 DeepSeek 官方均无隶属关系
- 与其它 DSH 的「长征 / Loji」相关插件（例如开机动画那类）不是同一个项目，请勿混淆
- 转载 / 搬运 / 视频二创请保留作者名与仓库地址

## 许可

MIT，见 [LICENSE](./LICENSE)。版本历史见 [CHANGELOG.md](./CHANGELOG.md)。

《烈焰升腾》是 HOI4 的第三方模组，本插件与模组作者、与 DeepSeek 官方均无隶属关系，仅取配色与意象作为同人创作。
