<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · **中文**

</div>

# newsline

**等待 Claude Code 完成任务时，直接在状态栏里读一行最新新闻。**
一条轮播的区域头条位于会话底部——漫长的等待就变成了快速浏览新闻的时间。它显示在你现有状态栏的
*下方*（你的 HUD 保持不变）。

<p align="center"><img src="../docs/demo.gif" alt="newsline — 在 Claude Code 状态栏中轮播的区域头条" width="720"></p>

## 安装并运行 — 一行搞定

```sh
# curl (macOS / Linux / WSL) — 安装并立即完成设置
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init

# Claude Code 插件 — 在 Claude Code 内执行，然后运行 /newsline:setup
/plugin marketplace add itdar/newsline
/plugin install newsline@itdar
```

新闻行会在你的 **下一条消息** 时出现——无需重启。设置会询问语言、主题和文字颜色，并保留你现有的状态栏。

## 它做什么

- **抓取和显示新闻都在你的电脑上完成**——绝不触碰你的代码、提示词、文件或与 Claude 的对话。
- 一个小型 **边缘服务** 挑选最合适的区域新闻源并路由头条点击，因此无需重装即可保持新闻源常新。
  若无法连接，newsline 会 **回退到内置源**。
- 状态栏即时显示（来自缓存）；刷新在后台进行。

## 隐私

在你电脑上运行的所有代码都在这个仓库里——以下就是会离开你机器的全部信息：

- **新闻源筛选**（每小时最多一次）：`lang`、粗略的国家、当地时间、星期、时区、`topic` 和插件
  版本会发送到边缘服务，以便挑选最新的区域新闻源。没有跟踪 ID，没有个人数据。
- **点击头条时**：链接经由一个小型重定向打开（它只看到文章 URL 加 `lang`/`topic`/版本），以便在
  服务器端替换失效的新闻源并做聚合点击统计。没有任何按用户区分的标识符。
- **绝不发送、绝不读取**：你的代码、提示词、文件或与 Claude 的对话。状态栏从本地缓存渲染，
  从不等待网络。

**完全本地模式**：在 `~/.config/newsline/config.json` 中设置 `"api": "off"` 和
`"endpoint": "off"` —— 新闻源只使用内置的 `feeds.json`，头条直接链接到文章。除了新闻源本身，
不会联系任何服务。

## 配置

重新运行 `newsline init`，或编辑 `~/.config/newsline/config.json`：

| 键 | 默认值 | 含义 |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`，或 `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | 每条头条显示秒数 |
| `count` | `15` | 轮播头条数量 |
| `maxlen` | `120` | 最大字符数（`max` = 不截断） |
| `icon` | `📰` | 前置图标（`none` 为隐藏） |
| `color` | `magenta` | 新闻文字颜色：`default` `gray` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

用 `newsline color <名称>` 直接设置颜色（如 `newsline color gray`），或不带名称运行
`newsline color` 切换到下一种颜色（default → gray → white → cyan → yellow → green → blue →
magenta → red）。`newsline colorlist` 会列出所有颜色并附带预览，更改在下次状态栏刷新时生效。

## 更新

按你安装的方式更新即可 — 语言/主题/颜色设置会保留：

```sh
# curl — 重新运行安装脚本（跳过设置，仅更新 CLI）
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | NEWSLINE_NO_INIT=1 sh

# Homebrew
brew update && brew upgrade newsline

# npm
npm i -g newsline-cli@latest
```

Claude Code 插件：运行 `/plugin marketplace update itdar`，然后 `/reload-plugins`
（或重启）。也可在 `/plugin` → **Marketplaces** 中启用后台自动更新。

## 卸载

```sh
newsline uninstall      # 恢复你之前的状态栏
```

需要 `bash` + `python3`（macOS / Linux；Windows 通过 WSL）。
