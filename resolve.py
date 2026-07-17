#!/usr/bin/env python3
"""newsline · resolve which feeds to use — server-first, local fallback, topic-aware.

Tries the operator's curation API (NEWSLINE_API) with a short timeout, sending only
COARSE CONTEXT (lang, country, localtime, dow, tz, topic) — never personal data.
The server's list is used AS-IS (it handles topic: vertical partners first, then
Google's topic feed). Only when the server is unreachable does the local fallback
kick in: bundled feeds.json, with a keyless Google News topic feed prepended if a
topic preference is set (NEWSLINE_TOPIC) so the topic still leads offline.

Prints a feeds.json-shaped object fetch.py consumes:  {"<lang>": [...], "default": [...]}

Usage: resolve.py <lang> <local_feeds.json> [api_base]
Context from env: NEWSLINE_COUNTRY, NEWSLINE_LOCALTIME, NEWSLINE_DOW, NEWSLINE_TZ, NEWSLINE_TOPIC
"""
import os
import sys
import json
import urllib.request
import urllib.parse

TIMEOUT = float(os.environ.get("NEWSLINE_API_TIMEOUT") or 2)

# user-friendly topic -> Google News section topic
GN_TOPICS = {
    "tech": "TECHNOLOGY", "technology": "TECHNOLOGY",
    "business": "BUSINESS", "biz": "BUSINESS",
    "sports": "SPORTS", "sport": "SPORTS",
    "world": "WORLD", "international": "WORLD",
    "science": "SCIENCE", "sci": "SCIENCE",
    "health": "HEALTH",
    "entertainment": "ENTERTAINMENT", "ent": "ENTERTAINMENT",
    "nation": "NATION", "national": "NATION",
}
LANG_COUNTRY = {"ko": "KR", "ja": "JP", "en": "US", "de": "DE",
                "fr": "FR", "es": "ES", "pt": "BR", "zh": "CN"}
# Google News wants regioned codes for some languages (bare "pt"/"zh" 404s or
# serves the wrong edition).
GN_HL = {"pt": "pt-BR", "zh": "zh-CN", "en": "en-US"}
GN_CEID_LANG = {"pt": "pt-419", "zh": "zh-Hans"}


def topic_feed(lang, country, topic):
    topic = (topic or "").strip().lower()
    if topic in ("", "general", "all", "none"):
        return None
    t = GN_TOPICS.get(topic)
    if not t:
        return None
    gl = country or LANG_COUNTRY.get(lang, lang.upper())
    hl = GN_HL.get(lang, lang)
    cl = GN_CEID_LANG.get(lang, lang)
    return (f"https://news.google.com/rss/headlines/section/topic/{t}"
            f"?hl={hl}&gl={gl}&ceid={gl}:{cl}")


def local_feeds(lang, path):
    try:
        feeds = json.load(open(path, encoding="utf-8"))
    except Exception:
        feeds = {}
    default = feeds.get("default") or []
    return (feeds.get(lang) or default or []), default


def server_feeds(lang, api_base):
    """Return (feeds_or_None, update_or_None) from the curation API."""
    params = {
        "lang": lang,
        "country": os.environ.get("NEWSLINE_COUNTRY", ""),
        "localtime": os.environ.get("NEWSLINE_LOCALTIME", ""),
        "dow": os.environ.get("NEWSLINE_DOW", ""),
        "tz": os.environ.get("NEWSLINE_TZ", ""),
        "topic": os.environ.get("NEWSLINE_TOPIC", ""),
        "v": os.environ.get("NEWSLINE_VERSION", ""),
    }
    url = api_base.rstrip("/") + "/feed?" + urllib.parse.urlencode(params)
    req = urllib.request.Request(url, headers={"User-Agent": "newsline/0.1"})
    obj = json.loads(urllib.request.urlopen(req, timeout=TIMEOUT).read())
    update = obj.get("update")
    if not isinstance(update, dict):
        update = None
    feeds = obj.get("feeds")
    if isinstance(feeds, list):
        # fetch.py urlopens these — accept only http(s) URLs
        feeds = [x for x in feeds
                 if isinstance(x, str) and x.startswith(("http://", "https://"))]
    else:
        feeds = None
    return (feeds or None), update


def main():
    if len(sys.argv) < 3:
        return 2
    lang, local_path = sys.argv[1], sys.argv[2]
    api_base = sys.argv[3] if len(sys.argv) > 3 else os.environ.get("NEWSLINE_API", "")

    local_urls, default = local_feeds(lang, local_path)

    feeds = update = None
    if api_base:
        try:
            feeds, update = server_feeds(lang, api_base)   # server-first, used AS-IS
        except Exception:
            feeds, update = None, None              # any issue -> local fallback
    if not feeds:
        # server unreachable: bundled feeds, topic preference prepended locally
        feeds = local_urls or default
        tfeed = topic_feed(lang, os.environ.get("NEWSLINE_COUNTRY", ""),
                           os.environ.get("NEWSLINE_TOPIC", ""))
        if tfeed:
            feeds = [tfeed] + [f for f in feeds if f != tfeed]

    if not feeds:
        return 1
    out = {lang: feeds, "default": default or feeds}
    if update:
        out["_update"] = update   # refresh.sh turns this into the notice line
    sys.stdout.write(json.dumps(out, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())
