<div align="center">

[English](../README.md) · **한국어** · [日本語](ja.md) · [Español](es.md) · [Français](fr.md) · [Deutsch](de.md) · [Português](pt.md) · [中文](zh.md)

</div>

# newsline

**Claude Code 작업 끝나길 기다리는 동안, 상태줄에서 최신 한줄 뉴스를 확인하세요.**
긴 작업을 기다리는 시간이 뉴스 한 번 훑는 시간이 됩니다 — 세션 하단에 지역 맞춤 헤드라인이
회전 표시됩니다. 기존 상태줄(HUD) **아래 줄에** 붙어서, HUD는 그대로 보입니다.

## 설치 & 실행 — 한 줄

```sh
# curl (macOS / Linux / WSL) — 설치 + 셋업까지 바로
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh

# Homebrew
brew install itdar/tap/newsline && newsline init

# npm
npm i -g newsline-cli && newsline init
```

뉴스 줄은 **다음 메시지 때** 나타납니다 — 재시작 불필요. 셋업은 언어·분야·글자 색을 물어보고, 기존
상태줄은 유지합니다.

## 무엇을 하나

- **뉴스 수집·표시는 내 컴퓨터에서** 이뤄집니다 — 코드·프롬프트·파일·Claude 대화는 건드리지 않아요.
- 작은 **엣지 서비스**가 지역에 맞는 최적 소스를 골라주고 헤드라인 클릭을 라우팅합니다. 덕분에
  재설치 없이 소스가 최신으로 유지되고, 엣지가 불통이면 **내장 피드로 자동 폴백**합니다.
- 상태줄은 캐시에서 **즉시** 표시되고, 갱신은 백그라운드에서 돕니다.

## 설정

`newsline init` 재실행 또는 `~/.config/newsline/config.json` 편집:

| 키 | 기본값 | 의미 |
|---|---|---|
| `lang` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh` 또는 `auto` |
| `topic` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` | `6` | 헤드라인당 노출 초 |
| `count` | `15` | 회전 헤드라인 수 |
| `maxlen` | `120` | 최대 글자수 (`max`=무제한) |
| `icon` | `📰` | 앞 아이콘 (`none`이면 제거) |
| `color` | `white` | 뉴스 글자 색: `default` `white` `cyan` `yellow` `green` `blue` `magenta` `red` |

`newsline color`를 실행할 때마다 다음 색으로 넘어갑니다 (default(gray) → white → cyan →
yellow → green → blue → magenta → red 순환, 다음 상태줄 갱신 때 반영).

## 제거

```sh
newsline uninstall      # 이전 상태줄로 복구
```

`bash` + `python3` 필요 (macOS / Linux; Windows는 WSL).
