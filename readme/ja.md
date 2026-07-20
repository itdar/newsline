<div align="center">

[English](../README.md) · [한국어](ko.md) · **日本語** · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**Claude Code の処理が終わるのを待っていますか？最新のひとことニュースをステータスラインで読みましょう。**
地域のヘッドラインがセッション下部で切り替わり表示され、長い待ち時間がサッとニュースをチェックする
時間に変わります。既存のステータスライン（HUD）の **下の行に** 表示されるので、HUD はそのまま残ります。

## インストールと実行 — 一行で

```sh
# curl (macOS / Linux / WSL) — インストールとセットアップを一気に
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

ニュース行は **次のメッセージ** で表示されます — 再起動は不要です。セットアップで言語・トピック・文字色を
尋ね、既存のステータスラインはそのまま保持します。

## 何をするか

- **ニュースの取得と表示はあなたのマシン上で** 行われます — コード・プロンプト・ファイル・Claude との
  会話には一切触れません。
- 小さな **エッジサービス** が地域に最適なソースを選び、ヘッドラインのクリックをルーティングします。
  おかげで再インストールなしでソースが最新に保たれ、エッジに接続できない場合は **内蔵フィードに自動
  フォールバック** します。
- ステータスラインはキャッシュから **即座に** 表示され、更新はバックグラウンドで実行されます。

## 設定

`newsline init` を再実行するか、`~/.config/newsline/config.json` を編集します:

| キー | 既定値 | 意味 |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh`、または `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | ヘッドラインごとの表示秒数 |
| `count` | `15` | 切り替えるヘッドライン数 |
| `maxlen` | `120` | 最大文字数（`max` = 無制限） |
| `icon` | `📰` | 先頭アイコン（`none` で非表示） |
| `color` | `white` | 見出しの文字色：`default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

`newsline color` を実行するたびに次の色へ進みます（default(gray) → white → cyan → yellow →
green → blue → magenta → red の順で循環、次のステータスライン更新で反映）。

## アンインストール

```sh
newsline uninstall      # 以前のステータスラインを復元します
```

`bash` と `python3` が必要です（macOS / Linux、Windows は WSL 経由）。
