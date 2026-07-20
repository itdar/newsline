<div align="center">

[English](../README.md) · [한국어](ko.md) · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · **中文**

</div>

# newsline

**等待 Claude Code 完成任务时，直接在状态栏里读一行最新新闻。**
一条轮播的区域头条位于会话底部——漫长的等待就变成了快速浏览新闻的时间。它显示在你现有状态栏的
*下方*（你的 HUD 保持不变）。

## 安装并运行 — 一行搞定

```sh
# curl (macOS / Linux / WSL) — 安装并立即完成设置
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

新闻行会在你的 **下一条消息** 时出现——无需重启。设置会询问语言、主题和文字颜色，并保留你现有的状态栏。

## 它做什么

- **抓取和显示新闻都在你的电脑上完成**——绝不触碰你的代码、提示词、文件或与 Claude 的对话。
- 一个小型 **边缘服务** 挑选最合适的区域新闻源并路由头条点击，因此无需重装即可保持新闻源常新。
  若无法连接，newsline 会 **回退到内置源**。
- 状态栏即时显示（来自缓存）；刷新在后台进行。

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
| `color` | `white` | 新闻文字颜色：`default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

也可以运行 `newsline color` — 每次执行切换到下一种颜色（default(gray) → white → cyan →
yellow → green → blue → magenta → red，下次状态栏刷新即生效）。

## 卸载

```sh
newsline uninstall      # 恢复你之前的状态栏
```

需要 `bash` + `python3`（macOS / Linux；Windows 通过 WSL）。
