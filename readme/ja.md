<div align="center">

[English](../README.md) · [한국어](ko.md) · **日本語** · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**Claude Code の処理が終わるのを待っていますか？最新のひとことニュースをステータスラインで読みましょう。**
地域のヘッドラインがセッション下部で切り替わり表示され、長い待ち時間がサッとニュースをチェックする
時間に変わります。既存のステータスライン（HUD）の **下の行に** 表示されるので、HUD はそのまま残ります。

<p align="center"><img src="../docs/demo.gif" alt="newsline — Claude Code のステータスラインで切り替わる地域ヘッドライン" width="720"></p>

## インストールと実行 — 一行で

```sh
# curl (macOS / Linux / WSL) — インストールとセットアップを一気に
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init

# Claude Code プラグイン — Claude Code 内で実行し、その後 /newsline:setup
/plugin marketplace add itdar/newsline
/plugin install newsline@itdar
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

## プライバシー

あなたのマシンで動くコードはすべてこのリポジトリで公開されており、外部に送られる情報は以下が
すべてです:

- **フィードのキュレーション**（最大 1 時間に 1 回）: 地域に合った最新ソースを選ぶため、`lang`、
  おおまかな国、現地時刻、曜日、タイムゾーン、`topic`、プラグインのバージョンをエッジサービスに
  送ります。トラッキング ID や個人情報はありません。
- **ヘッドラインのクリック時**: 停止したソースをサーバー側で差し替え、クリックを集計カウント
  できるよう、小さなリダイレクトを経由します（記事 URL + `lang`/`topic`/バージョンのみ)。
  ユーザーごとの識別子はありません。
- **決して送信・閲覧しないもの**: コード、プロンプト、ファイル、Claude との会話。ステータス
  ラインはネットワークを待たず、ローカルキャッシュから描画されます。

**完全ローカルモード**: `~/.config/newsline/config.json` に `"api": "off"` と
`"endpoint": "off"` を設定すると、フィードは同梱の `feeds.json` のみを使い、ヘッドラインは記事に
直接リンクします。ニュースフィード以外にはどこにも接続しません。

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
| `color` | `magenta` | 見出しの文字色：`default` `gray` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

`newsline color <名前>` で色を直接指定でき（例：`newsline color gray`）、名前なしで
`newsline color` を実行すると次の色へ進みます（default → gray → white → cyan → yellow →
green → blue → magenta → red）。`newsline colorlist` で全色をプレビュー付きで一覧でき、
変更は次のステータスライン更新で反映されます。

## アップデート

インストールした方法と同じ手順で更新できます — 言語・トピック・色の設定は保持されます:

```sh
# curl — インストーラを再実行（セットアップはスキップし、CLI のみ更新）
curl -fsSL https://raw.githubusercontent.com/itdar/newsline/master/install.sh | NEWSLINE_NO_INIT=1 sh

# Homebrew
brew update && brew upgrade newsline

# npm
npm i -g newsline-cli@latest
```

Claude Code プラグイン: `/plugin marketplace update itdar` を実行後、`/reload-plugins`
（または再起動）。`/plugin` → **Marketplaces** でバックグラウンド自動更新も有効にできます。

## アンインストール

```sh
newsline uninstall      # 以前のステータスラインを復元します
```

`bash` と `python3` が必要です（macOS / Linux、Windows は WSL 経由）。
