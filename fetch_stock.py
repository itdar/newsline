#!/usr/bin/env python3
"""newsline · stock fetch (stdlib only).

Reads live KOSPI index + a small set of ticker quotes from Naver's public,
keyless polling API and prints ONE ready-to-render line (same OSC 8 hyperlink
style as fetch.py). refresh_stock.sh caches this separately from the news
line so a slow news fetch never delays a price update, or vice versa.

Usage: fetch_stock.py [codes]
  codes: comma-separated 6-digit tickers shown alongside KOSPI, OR
         "topN" (e.g. top5) to pull the top N KOSPI stocks by market cap
         live from Naver instead of a fixed list, OR
         "auto" — KOSPI top5 from 08:00-18:00 local time; outside that
         window, show US indices (Dow/Nasdaq/S&P) IF the US market is
         actually open, else exit 1 so the previous cached line (last
         close of whichever market was live) just stays on screen
         (default: 005930,000660 — Samsung Electronics, SK hynix)
Exits non-zero on failure so refresh_stock.sh keeps the previous cache.
Test override: NEWSLINE_STOCK_HOUR forces the "auto" local hour (0-23).
"""
import os
import re
import sys
import json
import time
import urllib.request

TIMEOUT = 5
HEADERS = {"User-Agent": "newsline/0.1"}
INDEX_URL = "https://polling.finance.naver.com/api/realtime/domestic/index/KOSPI"
STOCK_URL = "https://polling.finance.naver.com/api/realtime/domestic/stock/{codes}"
# same fields as STOCK_URL's payload (itemCode/stockName/closePrice/...), sorted
# by market cap — lets us pick "top N" without hardcoding which tickers those are
TOP_URL = "https://m.stock.naver.com/api/stocks/marketValue/KOSPI?page=1&pageSize={n}"
WORLD_INDEX_URL = "https://polling.finance.naver.com/api/realtime/worldstock/index/{codes}"
US_INDEX_CODES = [".DJI", ".IXIC", ".SPX"]   # Dow, Nasdaq, S&P 500
KOSPI_OPEN_HOUR, KOSPI_CLOSE_HOUR = 8, 18     # local wall-clock window for "auto"

# Naver's compareToPreviousPrice.code: 1/2 = 상한/상승 (up), 4/5 = 하한/하락 (down),
# 3 = 보합 (flat). Korean market convention is the OPPOSITE of US markets —
# red = up, blue = down — so we mirror that here, not the US red/green habit.
UP_CODES = {"1", "2"}
DOWN_CODES = {"4", "5"}


def fetch_json(url):
    req = urllib.request.Request(url, headers=HEADERS)
    return json.loads(urllib.request.urlopen(req, timeout=TIMEOUT).read())


def osc8(url, text):
    esc = "\x1b"
    return f"{esc}]8;;{url}{esc}\\{text}{esc}]8;;{esc}\\"


def fmt_item(d, link):
    name = d.get("stockName") or d.get("indexName") or d.get("itemCode") or "?"
    price = d.get("closePrice") or "?"
    ratio = (d.get("fluctuationsRatio") or "0").lstrip("+-")
    code = (d.get("compareToPreviousPrice") or {}).get("code", "")
    if code in UP_CODES:
        icon, sgr = "▲", "31"    # ▲ red
    elif code in DOWN_CODES:
        icon, sgr = "▼", "34"    # ▼ blue
    else:
        icon, sgr = "-", ""
    tail = f"{icon}{ratio}%"
    if sgr:
        tail = f"\x1b[{sgr}m{tail}\x1b[0m"
    # only the name sits inside the hyperlink — most terminals underline OSC 8
    # link text, and that underline visually swallows a "." sitting on the
    # baseline, so keep the price (and its decimal point) plain, outside the link
    return osc8(link, name) + f" {price} " + tail


def write_line(parts):
    icon = os.environ.get("NEWSLINE_STOCK_ICON", "\U0001F4CA")  # 📊
    prefix = "" if icon.strip().lower() in ("none", "off") else f"{icon} "
    sys.stdout.write(prefix + " · ".join(parts) + "\n")


def us_session_line():
    # only shown when the US market is genuinely open — Naver's own
    # marketStatus catches DST shifts + US holidays we'd otherwise have
    # to hardcode, so we trust it instead of guessing exact hours
    try:
        us = fetch_json(WORLD_INDEX_URL.format(codes=",".join(US_INDEX_CODES)))["datas"]
    except Exception:
        return None
    if not us or all(d.get("marketStatus") != "OPEN" for d in us):
        return None
    return [fmt_item(d, f"https://m.stock.naver.com/worldstock/index/{d.get('reutersCode', '')}") for d in us]


def main():
    codes = (sys.argv[1] if len(sys.argv) > 1 else "005930,000660").strip()
    auto = codes.lower() == "auto"
    top_n = None

    if auto:
        hour = int(os.environ.get("NEWSLINE_STOCK_HOUR", time.localtime().tm_hour))
        if KOSPI_OPEN_HOUR <= hour < KOSPI_CLOSE_HOUR:
            top_n = 5
        else:
            parts = us_session_line()
            if parts is None:
                return 1   # US market closed too — keep the previous cached line as-is
            write_line(parts)
            return 0
    else:
        m = re.match(r"^top(\d+)$", codes, re.IGNORECASE)
        if m:
            top_n = int(m.group(1))

    try:
        index = fetch_json(INDEX_URL)["datas"][0]
    except Exception:
        return 1
    parts = [fmt_item(index, "https://finance.naver.com/sise/sise_index.naver?code=KOSPI")]

    if top_n:
        try:
            stocks = fetch_json(TOP_URL.format(n=top_n))["stocks"]
        except Exception:
            stocks = []
        for s in stocks:
            code = s.get("itemCode")
            if code:
                parts.append(fmt_item(s, f"https://finance.naver.com/item/main.naver?code={code}"))
    else:
        code_list = [c for c in codes.split(",") if c]
        if code_list:
            try:
                stocks = fetch_json(STOCK_URL.format(codes=",".join(code_list)))["datas"]
            except Exception:
                stocks = []
            by_code = {s.get("itemCode"): s for s in stocks}
            for c in code_list:
                s = by_code.get(c)
                if s:
                    parts.append(fmt_item(s, f"https://finance.naver.com/item/main.naver?code={c}"))

    write_line(parts)
    return 0


if __name__ == "__main__":
    sys.exit(main())
