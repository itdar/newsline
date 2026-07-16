# newsline

Claude Code 상태줄에 지역·언어에 맞는 뉴스 한 줄 — **완전 로컬**, 그리고 기존 상태줄(예: HUD)을
**덮지 않고 그 아래에 붙입니다(compose)**.

[English](../README.md) · **한국어**

## 무엇인가

세션 하단에 지역 언어 뉴스 헤드라인을 **회전 표시**하는 Claude Code 상태줄 유틸리티입니다.
로케일 감지·피드 수집·파싱·캐시·렌더링 전부 **로컬에서** 돌아갑니다. 코드·프롬프트·파일·Claude
대화는 절대 읽지 않습니다.

## 설치

**curl | sh** (macOS / Linux / WSL):
```sh
curl -fsSL https://raw.githubusercontent.com/itdar/cc-plugin/master/install.sh | sh
```

**Homebrew:**
```sh
brew install itdar/tap/newsline
```

**소스에서:**
```sh
git clone https://github.com/itdar/cc-plugin && cd cc-plugin && ./install.sh
```

**curl | sh** 설치는 셋업까지 **자동**입니다 — 언어·분야를 물어본 뒤 상태줄을 연결해요.
**Homebrew**나 **소스** 설치는 직접 실행:
```sh
newsline init
```
`init`이 언어·분야를 물어보고(메뉴에서 번호 선택), 상태줄을 등록합니다. **기존 상태줄은 그대로
두고**(HUD 유지) 그 아래 줄에 뉴스를 보여줍니다. Claude Code가 설정을 핫리로드하므로 **재시작
없이 다음 메시지 때 바로** 나타납니다.

_(설치 중 자동 셋업을 끄려면 `NEWSLINE_NO_INIT=1`.)_

## 설정

`newsline init`에서 고르거나, `~/.config/newsline/config.json`을 편집(또는 환경변수 설정):

| 키 / 환경변수 | 기본값 | 의미 |
|---|---|---|
| `lang` / `NEWSLINE_LANG` | `auto` | `ko` `ja` `en` `es` `fr` `de` `pt` `zh` 또는 `auto` |
| `topic` / `NEWSLINE_TOPIC` | `general` | `general` `tech` `business` `world` `sports` `science` `health` `entertainment` |
| `rotate` / `NEWSLINE_ROTATE` | `6` | 헤드라인당 노출 초 |
| `count` / `NEWSLINE_COUNT` | `15` | 회전용으로 캐시할 헤드라인 수 |
| `maxlen` / `NEWSLINE_MAXLEN` | `120` | 최대 글자수; `max`=무제한; `NN%`≈터미널 폭 비율 |
| `icon` / `NEWSLINE_ICON` | `📰` | 앞 아이콘; `none`이면 제거 |
| `linkhint` / `NEWSLINE_LINKHINT` | off | 끝에 `↗`(외부 열기) 힌트 추가 |
| `api` / `NEWSLINE_API` | — | 선택: 큐레이션 API (서버 우선, 실패 시 로컬 폴백) |
| `endpoint` / `NEWSLINE_ENDPOINT` | — | 클릭 리다이렉트 래퍼 |

## 동작 방식

- **`newsline render`** (상태줄이 호출) — 캐시에서 **즉시** 출력하고 절대 막지 않으며, 캐시가
  낡았으면 백그라운드 refresh를 트리거합니다.
- **`newsline refresh`** — keyless 지역 RSS/Atom 피드를 로컬에서 받아 상위 헤드라인을 파싱·중복
  제거·캐시합니다.
- 헤드라인은 클릭 가능한 [OSC 8] 링크입니다. 그냥 클릭 vs `Cmd`/`Ctrl`+클릭으로 열리는지는
  newsline이 아니라 **터미널 설정**이 결정합니다.

## 제거

```sh
newsline uninstall      # 연결을 제거하고 이전 상태줄로 복구
```

## 프라이버시

로컬에서 실행되며, 로케일은 시스템 설정에서 감지(IP 지오로케이션 없음), 공개 피드를 직접
받아옵니다. 코드·프롬프트·파일·Claude 대화는 접근하지 않습니다. 클릭은 리다이렉트를 거치는데,
이는 참여도 측정과 향후 제휴 링크(운영 자금)를 위한 것이며 여기에 명시합니다.

## 요구사항

`bash`, `python3`. macOS·Linux는 기본 지원, Windows는 WSL 또는 Git Bash.

[OSC 8]: https://gist.github.com/egmontkob/eb114294efbcd5adb1944c9f3cb5feda
