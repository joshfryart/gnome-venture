#!/usr/bin/env python3
"""
AI playtest: 50 Haiku agents play Gnome Venture for one simulated week, one hour per step
(168 steps). One Sonnet agent oversees: reads each hour's digest, dedupes findings, steers
agents toward gaps, and writes the final report. Everything goes through the Claude API.

SETUP (Linux/WSL; needs php 8.1+ with sqlite):
    pip install anthropic libfaketime
    export ANTHROPIC_API_KEY=sk-ant-...
    python3 tools/playtest_ai.py --dry-run          # no API calls: boots game, registers 50 players, 2 ticks of fake play
    python3 tools/playtest_ai.py                    # the real run
    python3 tools/playtest_ai.py --resume           # continue after a crash / Ctrl-C (same --out)

HOW TIME WORKS: the game reads the real PHP clock. The server runs under libfaketime with
FAKETIME_TIMESTAMP_FILE, so the harness sets the game's clock by writing one file per hour step.
All agents in a step see the same frozen time. Start = a Wednesday 00:00 Hollow time (America/Halifax),
so the Monday week rollover happens mid-run.

COST: hard budget guard (--budget, default 80 USD). Haiku turns stop when spend reaches
budget minus a reserve kept for the overseer's final report. Prices in PRICES below.
Output: <out>/report.md (overseer's final report), findings.jsonl, events.jsonl, agent_bugs.jsonl,
state.json, server.log. The game copy lives in <out>/game (your repo is never touched).
"""
from __future__ import annotations

import argparse
import concurrent.futures as cf
import datetime as dt
import html
import http.cookiejar
import json
import os
import random
import re
import shutil
import signal
import sqlite3
import subprocess
import sys
import threading
import time
import urllib.error
import urllib.parse
import urllib.request
from html.parser import HTMLParser
from pathlib import Path
from zoneinfo import ZoneInfo

try:
    import anthropic
except ImportError:
    anthropic = None

HAIKU = "claude-haiku-5-5"
SONNET = "claude-sonnet-5-5"
# USD per million tokens (input, output). Haiku 5.5 doubles+ above 100K prompt; our prompts are far below.
PRICES = {HAIKU: (0.10, 0.50), SONNET: (2.00, 10.00)}
HOLLOW_TZ = ZoneInfo("America/Halifax")
REPO = Path(__file__).resolve().parent.parent
N_AGENTS = 50
TICKS = 168

# --------------------------------------------------------------------------------------
# 50 focus areas: every page and system in the README is owned by at least one agent.
# --------------------------------------------------------------------------------------
AREAS = [
    ("garden-basics", "Garden core loop: till, plant, water, tend, harvest (garden.php, tend.php). Growth timers across hours."),
    ("soil-npk", "Soil care, compost, fertility, NPK feeding pools, soil items."),
    ("breeding", "Plant breeding and the 22 hybrids; seeds; unusual crosses."),
    ("garden-animals", "Garden animals: worm farm, ladybird lodge, frog pond, butterfly bush, snail jar, quail coop, silkworm shelf, tortoise run, goat, pigeon (yard.php)."),
    ("kitchen-cooking", "Kitchen, pantry, recipes, cooking, Gourmand (kitchen.php, gourmand.php)."),
    ("pals-cooking", "Pals: adopting, pal pots, passive cooking checks every 10 min, recalling pals home early (pals.php)."),
    ("crafting", "Crafting, shelves, craft map, arranging (crafting.php, arrange.php)."),
    ("inventory-items", "Inventory, chest, satchel, item squares, using/selling/dropping items (inventory.php)."),
    ("shop-trading", "Shop and Trading Post: buying, selling, prices, stock limits, petals (shop.php, market.php)."),
    ("market-day", "Market day and townsfolk orders (marketday.php, town.php, folk.php)."),
    ("job-boards", "Job Board, player jobs, pal jobs (jobs.php, paljobs.php)."),
    ("quests-callings", "Quests and callings (tiers at L5, L15, L28), levels, mentors (journey.php, mentor.php)."),
    ("world-roads", "World map, 14 regions, road walks, travel time and costs (world.php, hollow.php)."),
    ("exploring", "Exploring regions, region maps, 81 landmarks: havens, wonders (landmark.php, explore)."),
    ("delves-lairs", "Delves and lairs, combat, floors, loot, delve_v2 (adventure.php)."),
    ("villagers-rest", "Rest stops, villagers, stop folk, conversations (villagers.php, stopfolk.php)."),
    ("gathering", "Gathering and gathering practice (gather.php)."),
    ("hired-help", "Hiring help: costs, wages, what they do over hours."),
    ("treks", "Treks party campaign (trek.php): Wilting Rows, Weeping Clay. Needs L15."),
    ("catfish", "Cat Fish: adopt a cat, toy rod, Nap for Yarn, weekly Cat Show (catfish.php)."),
    ("jigsaw", "Jigsaw: library, Easy/Advanced/Expert, save and resume, personal bests (jigsaw.php)."),
    ("gifsaw", "GIFsaw animated jigsaws and tournaments (gifsaw.php)."),
    ("rain-barrel-beds", "Rain Barrel and Gnome Beds daily puzzles (rainbarrel.php, gnomebeds.php)."),
    ("puzzle-hub", "Puzzles hub, tournaments, cups, trophies, puzzle pals (puzzles.php, puzzlepals.php, puzzles_api.php)."),
    ("worms-memory", "Worm Hunting and Seed Memory (worms.php, memory.php)."),
    ("race-spit", "Snail Race and Seed Spitting (race.php, spit.php)."),
    ("weight-mushroom", "Guess the Weight (marrow.php) and Mushroom Sweeper (mushroom.php)."),
    ("letters-pest", "Lost Letters and Pest Patrol (letters.php, pest.php)."),
    ("fair-show", "Harvest Fair and Village Show (fair.php, show.php)."),
    ("carve-festival", "Pumpkin carving, festivals, events (carve.php, festival.php, event.php)."),
    ("social-visits", "Friends, visiting other gardens, watering for friends, gifts, guestbook stamps (visit.php, community.php). Other agents are real players in this world."),
    ("stats-levels", "Gnome stats, stat points on level-up, XP curve, level gates on regions and features (gnome.php, profile pages)."),
    ("goals-almanac", "Hollow Goals, Almanac encyclopedia, passport, guide, book (passport.php, book.php, guide.php)."),
    ("profile-account", "Profile, account settings, customise, theme (profile.php, account.php, customise.php, theme.php)."),
    ("daily-firstweek", "Daily rewards, first-week guide, tour, onboarding follow-ups (daily.php, firstweek.php, tour.php)."),
    ("weather-seasons", "Seasons and weather chip; how they change hour to hour and day to day; effects on the garden."),
    ("auth-guest", "Login, logout, register, forgot/reset password, guest play (login.php, guest.php, forgot.php). Test as many auth edge cases as you can with your own account."),
    ("feedback-report", "Feedback and report pages, moderation tools, contests and Game-of-the-Month (feedback.php, report.php, gotm.php, modtools.php)."),
    ("edge-inputs", "Edge-case input hunter: empty, negative, huge, decimal, unicode, HTML in every form field you can find."),
    ("economy-exploits", "Economy exploit hunter: duplication, infinite petals/XP, negative prices, double-submit, buy-sell loops."),
    ("access-control", "Access-control hunter: other players' ids in URLs, skipping steps, admin paths, level gates, closed features. This is a private test copy; probe freely, report precisely."),
    ("trader-a", "Trading partner A: gift and trade with other players' gardens; coordinate via notes with trader-b (agent 43)."),
    ("trader-b", "Trading partner B: gift and trade with other players' gardens; coordinate via notes with trader-a (agent 42)."),
    ("speedrunner", "Speedrunner: gain XP and levels as fast as possible. Judge pacing, gating, dead ends."),
    ("completionist", "Completionist: visit every page reachable from navigation, tick off every feature. Report dead links and empty pages."),
    ("newbie", "Confused newcomer: follow only what the UI tells you. Report unclear steps, missing guidance, dead ends."),
    ("copy-reader", "Copy and UX reader: typos, tone, unclear labels, inconsistent names, contradictory numbers."),
    ("timers-cooldowns", "Time-dependent systems: start things, then check back after hours. Report timers or cooldowns that are wrong, stuck or unexplained."),
    ("weekly-loop", "Weekly loop: weekly quests, show ribbons, weekly resets and rollovers at Hollow midnight (the week turns mid-run)."),
    ("chaos-monkey", "Chaos monkey: click random links and press random buttons everywhere; back-to-back; unusual orders. Look for errors and broken states."),
]
assert len(AREAS) == N_AGENTS

# Agents that need late-game access get a head start: (level, petals).
BOOSTS = {
    "delves-lairs": (12, 800), "treks": (16, 1500), "quests-callings": (6, 500), "hired-help": (6, 2000),
    "exploring": (8, 600), "world-roads": (8, 600), "speedrunner": (3, 100), "economy-exploits": (4, 500),
    "catfish": (4, 400), "puzzle-hub": (4, 300), "fair-show": (6, 400), "pals-cooking": (6, 500),
    "breeding": (7, 400), "crafting": (6, 400), "kitchen-cooking": (5, 300), "completionist": (10, 1000),
    "trader-a": (5, 800), "trader-b": (5, 800), "access-control": (5, 300), "weekly-loop": (5, 400),
}
FEATURE_SETTINGS = {
    "puzzles_open": "1", "puzzles_tournaments": "1", "jigsaw_open": "1", "jigsaw_tournaments": "1",
    "ppal_open": "1", "ppal_boons": "1", "gourmand_open": "1", "trek_open": "1", "trek_chapters_open": "3",
    "catfish_open": "1", "guest_open": "1", "pj_open": "1", "delve_v2": "1",
}
SCHEDULES = {  # active hours of the Hollow day, so players behave like people (and tokens last)
    "early-bird": list(range(5, 11)) + [12, 18],
    "commuter": [7, 8, 12, 13, 17, 18, 19, 21],
    "evening": list(range(18, 24)) + [12],
    "night-owl": [21, 22, 23, 0, 1, 2, 3, 13],
    "binger": list(range(9, 21)),
    "dipper": [8, 12, 16, 20],
}
SEVERITIES = ["crash", "broken", "exploit", "ux", "balance", "typo", "idea"]

# --------------------------------------------------------------------------------------
# cost tracking
# --------------------------------------------------------------------------------------
class Cost:
    def __init__(self, spent: float = 0.0):
        self.lock = threading.Lock()
        self.spent = spent
        self.by_model: dict[str, list[int]] = {}

    def add(self, model: str, usage) -> None:
        pin, pout = PRICES[model]
        i = (usage.input_tokens or 0) + (getattr(usage, "cache_creation_input_tokens", 0) or 0)
        c = getattr(usage, "cache_read_input_tokens", 0) or 0
        o = usage.output_tokens or 0
        usd = (i * pin + c * pin * 0.1 + o * pout) / 1e6
        with self.lock:
            self.spent += usd
            m = self.by_model.setdefault(model, [0, 0, 0])
            m[0] += i + c
            m[1] += o
            m[2] += 1


# --------------------------------------------------------------------------------------
# HTML -> compact text for the agents
# --------------------------------------------------------------------------------------
class PageParser(HTMLParser):
    SKIP = {"script", "style", "svg", "noscript", "head", "template"}
    BLOCK = {"p", "div", "li", "tr", "h1", "h2", "h3", "h4", "br", "section", "article", "ul", "table", "form", "header", "footer", "nav"}

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.title = ""
        self.in_title = False
        self.skip = 0
        self.text: list[str] = []
        self.links: list[tuple[str, str]] = []
        self.forms: list[dict] = []
        self.cur_form: dict | None = None
        self.cur_link: list | None = None
        self.cur_select: dict | None = None
        self.cur_button: dict | None = None
        self.flash: list[str] = []
        self.flash_depth = 0
        self.cur_textarea: dict | None = None
        self.nav_depth = 0

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "title":
            self.in_title = True
            return
        if tag in self.SKIP:
            self.skip += 1
            return
        if self.skip:
            return
        if tag in ("nav", "footer"):
            self.nav_depth += 1  # nav text is noise; its links are still collected
        cls = a.get("class") or ""
        if "flash" in cls.split():
            self.flash_depth = 1
            self.flash.append("[" + ("ERR" if "err" in cls else "ok") + "] ")
        elif self.flash_depth and tag in ("div", "p", "span", "b", "i", "a", "strong", "em"):
            self.flash_depth += 1
        if tag in self.BLOCK:
            self.text.append("\n")
        if tag == "a" and a.get("href"):
            self.cur_link = [a["href"], ""]
        elif tag == "form":
            self.cur_form = {"i": len(self.forms), "method": (a.get("method") or "get").lower(), "action": a.get("action") or "",
                             "fields": [], "buttons": [], "hidden": {}}
            self.forms.append(self.cur_form)
        elif tag == "input" and self.cur_form is not None:
            t = (a.get("type") or "text").lower()
            n = a.get("name")
            if t == "hidden" and n:
                self.cur_form["hidden"][n] = a.get("value", "")
            elif t in ("submit", "image"):
                self.cur_form["buttons"].append({"name": n, "value": a.get("value", ""), "label": a.get("value") or n or "submit"})
            elif n and t not in ("button", "reset", "file"):
                f = {"name": n, "type": t, "value": a.get("value", "")}
                if t in ("checkbox", "radio"):
                    f["checked"] = "checked" in a
                for k in ("min", "max", "maxlength", "required"):
                    if k in a:
                        f[k] = a[k] if a[k] is not None else True
                self.cur_form["fields"].append(f)
        elif tag == "textarea" and self.cur_form is not None and a.get("name"):
            self.cur_textarea = {"name": a["name"], "type": "textarea", "value": ""}
            self.cur_form["fields"].append(self.cur_textarea)
        elif tag == "select" and self.cur_form is not None and a.get("name"):
            self.cur_select = {"name": a["name"], "type": "select", "options": [], "value": ""}
            self.cur_form["fields"].append(self.cur_select)
        elif tag == "option" and self.cur_select is not None:
            self.cur_select["options"].append([a.get("value", ""), ""])
            if "selected" in a:
                self.cur_select["value"] = a.get("value", "")
        elif tag == "button" and self.cur_form is not None:
            t = (a.get("type") or "submit").lower()
            if t == "submit":
                self.cur_button = {"name": a.get("name"), "value": a.get("value", ""), "label": ""}
                self.cur_form["buttons"].append(self.cur_button)

    def handle_endtag(self, tag):
        if tag == "title":
            self.in_title = False
            return
        if tag in self.SKIP:
            self.skip = max(0, self.skip - 1)
            return
        if self.skip:
            return
        if tag in ("nav", "footer"):
            self.nav_depth = max(0, self.nav_depth - 1)
        if tag in ("a", "span", "button", "label", "b", "td", "th", "option"):
            self.text.append(" ")
        if self.flash_depth and tag in ("div", "p", "span", "b", "i", "a", "strong", "em"):
            self.flash_depth -= 1
        if tag == "a" and self.cur_link:
            href, label = self.cur_link
            self.links.append((re.sub(r"\s+", " ", label).strip(), href))
            self.cur_link = None
        elif tag == "form":
            self.cur_form = None
        elif tag == "select":
            self.cur_select = None
        elif tag == "textarea":
            self.cur_textarea = None
        elif tag == "button":
            self.cur_button = None
        if tag in self.BLOCK:
            self.text.append("\n")

    def handle_data(self, data):
        if self.in_title:
            self.title += data
            return
        if self.skip:
            return
        if self.cur_select is not None and self.cur_select["options"]:
            self.cur_select["options"][-1][1] += data
            return
        if self.cur_textarea is not None:
            self.cur_textarea["value"] += data
            return
        if self.cur_button is not None:
            self.cur_button["label"] += data
        if self.cur_link is not None:
            self.cur_link[1] += data
        if self.flash_depth and self.flash:
            self.flash[-1] += data
        if not self.nav_depth:
            self.text.append(data)


def _sp(t: str) -> str:
    return re.sub(r"\s+", " ", t).strip()


def render_page(raw: str, final_url: str, status: int, max_chars: int) -> tuple[str, dict]:
    """Return (text for the agent, page state {forms, links})."""
    p = PageParser()
    try:
        p.feed(raw)
        p.close()
    except Exception:
        pass
    body = re.sub(r"[ \t\r\f\v]+", " ", "".join(p.text))
    body = re.sub(r"\n\s*\n+", "\n", body).strip()
    out = [f"URL: {final_url}   HTTP {status}   Title: {p.title.strip()}"]
    for f in p.flash:
        out.append("FLASH " + re.sub(r"\s+", " ", f).strip())
    out.append("--- text ---")
    out.append(body[:max_chars])
    if len(body) > max_chars:
        out.append(f"...(page text cut, {len(body) - max_chars} more chars)")
    seen, ls = set(), []
    for label, href in p.links:
        if href.startswith(("#", "javascript:", "mailto:")) or re.match(r"https?://", href):
            continue
        key = (label, href)
        if key in seen:
            continue
        seen.add(key)
        ls.append(f"[{label[:40] or '·'}]({href})")
        if len(ls) >= 45:
            break
    if ls:
        out.append("--- links ---")
        out.append(" ".join(ls))
    for f in p.forms:
        if f["method"] != "post" and not f["fields"]:
            continue
        fields, groups = [], {}
        for fl in f["fields"]:
            if fl["type"] == "radio":
                g = groups.setdefault(fl["name"], [])
                g.append(fl["value"] + ("*" if fl.get("checked") else ""))
                continue
            if fl["type"] == "select":
                opts = ",".join(f"{v}={_sp(t)[:24]}" for v, t in fl["options"][:14])
                fields.append(f"{fl['name']}=<select {opts}>")
            else:
                extra = "".join(f" {k}={fl[k]}" for k in ("min", "max", "maxlength") if k in fl)
                chk = " (checked)" if fl.get("checked") else ""
                fields.append(f"{fl['name']}=<{fl['type']} default={fl['value']!r}{extra}{chk}>")
        fields += [f"{n}=<radio one of {','.join(v[:20])} (* = default)>" for n, v in groups.items()]
        btns = [f"{b['name'] or ''}={_sp(b['label'])[:30]!r}" for b in f["buttons"]]
        hid = {k: v for k, v in f["hidden"].items() if k != "csrf"}
        out.append(f"FORM #{f['i']} {f['method'].upper()} {f['action'] or '(same page)'} hidden={json.dumps(hid)[:160]} fields: {'; '.join(fields) or '-'} buttons: {btns or '-'}")
    return "\n".join(out), {"forms": p.forms, "url": final_url}


# --------------------------------------------------------------------------------------
# a player's browser
# --------------------------------------------------------------------------------------
PHP_ERR = re.compile(r"(Fatal error|Parse error|Warning|Notice|Deprecated|Uncaught|Stack trace|SQLSTATE)\b[^\n<]{0,160}")


class Browser:
    def __init__(self, base: str, cookie_file: Path | None = None):
        self.base = base.rstrip("/")
        self.jar = http.cookiejar.MozillaCookieJar(str(cookie_file)) if cookie_file else http.cookiejar.CookieJar()
        if cookie_file and cookie_file.exists():
            try:
                self.jar.load(ignore_discard=True, ignore_expires=True)
            except Exception:
                pass
        self.cookie_file = cookie_file
        self.opener = urllib.request.build_opener(urllib.request.HTTPCookieProcessor(self.jar))
        self.last_state: dict = {"forms": [], "url": ""}
        self.last_html = ""

    def save(self):
        if self.cookie_file:
            self.jar.save(ignore_discard=True, ignore_expires=True)

    def _open(self, req) -> tuple[int, str, str]:
        for attempt in range(3):
            try:
                with self.opener.open(req, timeout=60) as r:
                    return r.status, r.read().decode("utf-8", "replace"), r.geturl()
            except urllib.error.HTTPError as e:
                body = e.read().decode("utf-8", "replace")
                if e.code >= 500 and attempt < 2:
                    time.sleep(0.4 * (attempt + 1))
                    continue
                return e.code, body, e.geturl()
            except Exception as e:  # connection reset etc.
                if attempt == 2:
                    return 0, f"CONNECTION ERROR {e}", req.full_url
                time.sleep(0.5)
        return 0, "", req.full_url

    def _norm(self, path: str) -> str:
        path = path.strip()
        if re.match(r"https?://", path):
            u = urllib.parse.urlparse(path)
            if f"{u.scheme}://{u.netloc}" != self.base:
                raise ValueError("only this game's own pages can be opened")
            path = (u.path or "/") + (("?" + u.query) if u.query else "")
        return self.base + "/" + path.lstrip("/")

    def get(self, path: str) -> tuple[int, str, str]:
        status, raw, final = self._open(urllib.request.Request(self._norm(path)))
        self.last_html = raw
        return status, raw, final

    def post(self, url: str, fields: list[tuple[str, str]]) -> tuple[int, str, str]:
        data = urllib.parse.urlencode(fields).encode()
        status, raw, final = self._open(urllib.request.Request(self._norm(url), data=data, method="POST"))
        self.last_html = raw
        return status, raw, final

    def csrf(self) -> str:
        m = re.search(r'name="csrf"\s+value="([^"]*)"', self.last_html)
        return m.group(1) if m else ""


def html_errors(raw: str) -> list[str]:
    return [m.group(0)[:200] for m in PHP_ERR.finditer(raw)][:3]


# --------------------------------------------------------------------------------------
# game server
# --------------------------------------------------------------------------------------
def find_faketime(explicit: str | None) -> str:
    cands = [explicit, os.environ.get("FAKETIME_LIB")]
    try:
        import libfaketime  # type: ignore
        root = Path(libfaketime.__file__).parent
        cands += [str(p) for p in root.rglob("libfaketime.so.1")]
    except ImportError:
        pass
    cands += ["/usr/lib/x86_64-linux-gnu/faketime/libfaketime.so.1", "/usr/lib/faketime/libfaketime.so.1",
              "/usr/lib/aarch64-linux-gnu/faketime/libfaketime.so.1", "/usr/local/lib/faketime/libfaketime.so.1"]
    for c in cands:
        if c and Path(c).exists():
            return str(Path(c).resolve())
    sys.exit("libfaketime not found. Run: pip install libfaketime   (or set FAKETIME_LIB / --faketime-lib)")


class GameServer:
    def __init__(self, out: Path, port: int, faketime: str, workers: int):
        self.out, self.port, self.faketime, self.workers = out, port, faketime, workers
        self.game = out / "game"
        self.clock_file = out / "clock.txt"
        self.proc: subprocess.Popen | None = None
        self.base = f"http://127.0.0.1:{port}"
        self.log_pos = 0

    def prepare(self):
        if self.game.exists():
            return
        src = REPO / "game"

        def skip(d, names):  # drop only the top-level runtime data/ and config.php, keep includes/data/
            return [n for n in names if n == "config.php" or (n == "data" and Path(d) == src)]
        shutil.copytree(src, self.game, ignore=skip)
        (self.game / "data").mkdir()
        (self.out / "sessions").mkdir(exist_ok=True)

    def set_clock(self, when: dt.datetime):
        # libfaketime reads the file in the process's local zone; the server runs with TZ=UTC
        self.clock_file.write_text(when.astimezone(dt.timezone.utc).strftime("%Y-%m-%d %H:%M:%S"))

    def start(self):
        env = dict(os.environ, LD_PRELOAD=self.faketime, FAKETIME_TIMESTAMP_FILE=str(self.clock_file), FAKETIME_NO_CACHE="1",
                   TZ="UTC", PHP_CLI_SERVER_WORKERS=str(self.workers), DONT_FAKE_MONOTONIC="1")
        router = REPO / "tests" / "router.php"
        self.logf = open(self.out / "server.log", "ab")
        self.proc = subprocess.Popen(
            ["php", "-d", f"session.save_path={self.out / 'sessions'}", "-d", "display_errors=1", "-d", "error_reporting=E_ALL",
             "-d", "log_errors=1", "-S", f"127.0.0.1:{self.port}", "-t", str(self.game), str(router)],
            env=env, stdout=self.logf, stderr=subprocess.STDOUT)
        for _ in range(60):
            try:
                urllib.request.urlopen(self.base + "/install.php", timeout=3).read()
                return
            except urllib.error.HTTPError:
                return  # any HTTP answer (the game 503s until installed) means the server is up
            except Exception:
                time.sleep(0.5)
        sys.exit("game server did not start; see " + str(self.out / "server.log"))

    def stop(self):
        if self.proc and self.proc.poll() is None:
            self.proc.terminate()
            try:
                self.proc.wait(10)
            except Exception:
                self.proc.kill()

    def db(self, sql: str, args=()):
        con = sqlite3.connect(str(self.game / "data" / "game.sqlite"), timeout=30)
        try:
            cur = con.execute(sql, args)
            rows = cur.fetchall()
            con.commit()
            return rows
        finally:
            con.close()

    def new_log_errors(self) -> list[str]:
        p = self.out / "server.log"
        with open(p, "rb") as f:
            f.seek(self.log_pos)
            chunk = f.read().decode("utf-8", "replace")
            self.log_pos = f.tell()
        lines = [l for l in chunk.splitlines() if re.search(r"PHP (Fatal|Parse|Warning|Notice|Deprecated)|Uncaught|SQLSTATE|Stack trace", l)]
        return lines


def install_and_enable(srv: GameServer, admin_pass: str):
    b = Browser(srv.base)
    b.get("install.php")
    status, raw, _ = b.post("install.php", [
        ("csrf", b.csrf()), ("driver", "sqlite"), ("site_name", "Gnome Venture"), ("base_url", ""),
        ("admin_user", "admin"), ("admin_email", "a@b.local"), ("admin_pass", admin_pass), ("admin_pass2", admin_pass)])
    if "All planted" not in raw:
        sys.exit("install failed: " + re.sub(r"\s+", " ", raw)[:400])
    for k, v in FEATURE_SETTINGS.items():
        if srv.db("SELECT 1 FROM settings WHERE name=?", (k,)):
            srv.db("UPDATE settings SET value=? WHERE name=?", (v, k))
        else:
            srv.db("INSERT INTO settings (name, value) VALUES (?, ?)", (k, v))


_FIRST = ["Bramble", "Pip", "Moss", "Thistle", "Fennel", "Juniper", "Clover", "Nettle", "Hazel", "Sorrel"]
_LAST = ["Puddlefoot", "Underbough", "Mossback", "Tanglewick", "Dewdrop"]
GNOME_NAMES = [f"{a} {b}" for b in _LAST for a in _FIRST]  # 50 letters-only names


def register_player(srv: GameServer, idx: int, name: str, cookie: Path, rng: random.Random):
    b = Browser(srv.base, cookie)
    user = f"{name}{idx:02d}"
    pw = "TestPass123!"
    b.get("register.php")
    b.post("register.php", [("csrf", b.csrf()), ("username", user), ("email", f"{user}@b.local"), ("password", pw),
                            ("password2", pw), ("rules", "1"), ("age", "1")])
    b.get("welcome.php")
    b.post("welcome.php", [("csrf", b.csrf()), ("do", "gnome"), ("gnome_name", GNOME_NAMES[(idx - 1) % len(GNOME_NAMES)]),
                           ("hat", rng.choice(["#2e7d4f", "#c0392b", "#2f5d9e", "#e0a526"])), ("beard", "#b5651d")])
    rid = srv.db("SELECT id FROM regions WHERE code='NA'")[0][0]
    villages = srv.db("SELECT l.id FROM locations l WHERE l.region_id=? AND l.kind='village' AND EXISTS "
                      "(SELECT 1 FROM routes r WHERE r.kind='road' AND (r.a_id=l.id OR r.b_id=l.id)) ORDER BY l.sort_order", (rid,))
    vid = rng.choice(villages)[0]
    b.get("welcome.php?step=place")
    b.post("welcome.php", [("csrf", b.csrf()), ("do", "place"), ("village_id", str(vid))])
    b.get("welcome.php?step=garden")
    b.post("welcome.php", [("csrf", b.csrf()), ("do", "finish"), ("garden_name", f"Patch {idx:02d}")])
    b.save()
    return user, pw


# --------------------------------------------------------------------------------------
# Haiku player agent
# --------------------------------------------------------------------------------------
AGENT_SYSTEM = """You are a playtester in a live test of Gnome Venture, a cosy garden browser game (PHP site, plain HTML pages): grow plants, tend beds, cook, trade, explore roads and regions, hire help, play small puzzle games. Currency is petals. You play one simulated week; each message is one hour of game time. The clock is frozen during your hour and jumps one hour when you finish.

YOU ARE: agent {idx} of 50, a playtester called "{user}", already signed in with a finished gnome and garden. Other agents are other players in the same world.
YOUR FOCUS: {area_name}: {area_desc}
YOUR PLAY STYLE: {schedule_name} player.

TOOLS: get_page(path) opens a page (path like "garden.php" or "world.php?tab=map"). submit_form(form, fields, button) submits a FORM # from the page you last opened (csrf and hidden fields are added for you; "fields" overrides or adds values; "button" is the label or name=value of the submit button to press). note(text) saves a private note that you will see again next hour (use it for plans, timers like "tomato ready ~Thu 14:00", IDs, what you tried). report_bug(...) files a finding.

HOW TO PLAY: use only the game's own pages. Act like a real player who is interested in your focus, but your real job is to find problems. Do real things (plant, buy, cook, walk, play), then come back in later hours to see what changed. Prefer doing over reading. You have at most {calls} tool calls per hour, so make each one count; end your hour with one short sentence saying what you did and what you will do next (no tool call).

WHAT TO REPORT (report_bug): errors, blank or broken pages, PHP warnings, dead links, actions that do nothing or do the wrong thing, wrong numbers (costs, timers, rewards that disagree with what the page says), things that do not change when time passes, features you cannot reach, exploits, confusing steps, typos, balance problems. Be exact: say the page, what you did (form fields and button), what happened, and what you expected. One report per problem; do not repeat one you already filed (check your notes). Do not report a thing as broken until you have tried it once more or read the page properly. A closed or locked feature that clearly says so is not a bug unless the message is wrong. severity: crash (error page, PHP error, 5xx), broken (does not work), exploit (cheat/duplication/access), ux (confusing), balance (numbers feel wrong), typo, idea."""

TOOLS = [
    {"name": "get_page", "description": "Open a game page with GET. path is relative, e.g. garden.php?sel=0-0. Returns text, links and forms.",
     "input_schema": {"type": "object", "properties": {"path": {"type": "string"}}, "required": ["path"], "additionalProperties": False}},
    {"name": "submit_form", "description": "Submit FORM #n from the page you last opened. csrf and hidden fields are added automatically.",
     "input_schema": {"type": "object", "properties": {
         "form": {"type": "integer", "description": "form number shown as FORM #n"},
         "fields": {"type": "object", "additionalProperties": {"type": "string"}, "description": "field name -> value (overrides defaults)"},
         "button": {"type": "string", "description": "label or name=value of the submit button to press (optional)"}},
         "required": ["form"], "additionalProperties": False}},
    {"name": "note", "description": "Save a private note for yourself for the next hours.",
     "input_schema": {"type": "object", "properties": {"text": {"type": "string"}}, "required": ["text"], "additionalProperties": False}},
    {"name": "report_bug", "description": "File a finding for the overseer.",
     "input_schema": {"type": "object", "properties": {
         "severity": {"type": "string", "enum": SEVERITIES}, "title": {"type": "string"},
         "page": {"type": "string"}, "steps": {"type": "string", "description": "what you did"},
         "actual": {"type": "string"}, "expected": {"type": "string"}},
         "required": ["severity", "title", "page", "steps", "actual", "expected"], "additionalProperties": False}},
]


class Agent:
    def __init__(self, idx: int, area: tuple[str, str], schedule: str, user: str, pw: str, browser: Browser):
        self.idx, self.area_name, self.area_desc = idx, area[0], area[1]
        self.schedule = schedule
        self.hours = set(SCHEDULES[schedule])
        self.user, self.pw, self.browser = user, pw, browser
        self.notes = ""
        self.last_summary = ""
        self.directives: list[str] = []
        self.force_wake = False
        self.turns = 0
        self.calls = 0
        self.errors = 0

    def system(self, calls: int) -> str:
        return AGENT_SYSTEM.format(idx=self.idx, user=self.user, area_name=self.area_name, area_desc=self.area_desc,
                                   schedule_name=self.schedule, calls=calls)

    def to_state(self):
        return {"notes": self.notes, "last_summary": self.last_summary, "directives": self.directives,
                "turns": self.turns, "calls": self.calls, "errors": self.errors}

    def load_state(self, s):
        self.notes, self.last_summary, self.directives = s.get("notes", ""), s.get("last_summary", ""), s.get("directives", [])
        self.turns, self.calls, self.errors = s.get("turns", 0), s.get("calls", 0), s.get("errors", 0)


class TickLog:
    """what one agent did in one hour; goes to the overseer digest and events.jsonl"""
    def __init__(self, idx):
        self.idx = idx
        self.paths: list[str] = []
        self.errors: list[str] = []
        self.bugs: list[dict] = []
        self.summary = ""
        self.calls = 0
        self.api_error = ""


def run_agent_hour(agent: Agent, client, cost: Cost, tick: int, when: dt.datetime, args, lock: threading.Lock, bugs_file: Path) -> TickLog:
    log = TickLog(agent.idx)
    hollow = when.astimezone(HOLLOW_TZ)
    stamp = hollow.strftime("%a %Y-%m-%d %H:%M")
    directive = " | ".join(agent.directives)
    agent.directives = []
    user_msg = (
        f"Hollow time now: {stamp} (hour {tick + 1} of {TICKS}).\n"
        f"Your notes:\n{agent.notes or '(none yet)'}\n"
        f"Last hour you: {agent.last_summary or '(this is your first hour)'}\n"
        + (f"OVERSEER SAYS: {directive}\n" if directive else "")
        + f"Play your hour now (max {args.calls_per_hour} tool calls)."
    )
    messages = [{"role": "user", "content": user_msg}]
    system = [{"type": "text", "text": agent.system(args.calls_per_hour), "cache_control": {"type": "ephemeral"}}]
    b = agent.browser
    calls = 0
    while True:
        if cost.spent >= args.budget - args.reserve:
            log.api_error = "budget"
            break
        try:
            resp = client.messages.create(model=HAIKU, max_tokens=4000, system=system, tools=TOOLS, messages=messages,
                                          output_config={"effort": "low"})
        except Exception as e:  # SDK already retried 429/5xx
            log.api_error = f"{type(e).__name__}: {str(e)[:160]}"
            break
        cost.add(HAIKU, resp.usage)
        if resp.stop_reason == "refusal":
            log.api_error = "refusal"
            break
        # append the assistant turn unchanged (thinking blocks must be preserved within the hour)
        messages.append({"role": "assistant", "content": resp.content})
        uses = [x for x in resp.content if x.type == "tool_use"]
        if resp.stop_reason == "max_tokens" and not uses:
            break
        if not uses:
            log.summary = " ".join(x.text for x in resp.content if x.type == "text").strip()[:300]
            break
        results = []
        for u in uses:
            calls += 1
            inp = u.input if isinstance(u.input, dict) else {}
            if calls > args.calls_per_hour:
                results.append({"type": "tool_result", "tool_use_id": u.id, "is_error": True,
                                "content": "Out of tool calls for this hour. Reply with one sentence now."})
                continue
            results.append({"type": "tool_result", "tool_use_id": u.id, **do_tool(agent, u.name, inp, log, args, when, lock, bugs_file)})
        messages.append({"role": "user", "content": results})
        if calls > args.calls_per_hour + 1:  # model ignored the limit
            break
    log.calls = min(calls, args.calls_per_hour)
    agent.turns += 1
    agent.calls += log.calls
    agent.errors += len(log.errors)
    if log.summary:
        agent.last_summary = log.summary
    b.save()
    return log


def do_tool(agent: Agent, name: str, inp: dict, log: TickLog, args, when, lock, bugs_file: Path) -> dict:
    b = agent.browser
    try:
        if name == "get_page":
            path = str(inp.get("path", ""))
            log.paths.append(path)
            status, raw, final = b.get(path)
            text, b.last_state = render_page(raw, final, status, args.page_chars)
            note_page_issues(log, path, status, raw)
            return {"content": text}
        if name == "submit_form":
            forms = b.last_state.get("forms", [])
            n = int(inp.get("form", -1))
            if not (0 <= n < len(forms)):
                return {"is_error": True, "content": f"No FORM #{n} on the last page you opened. Open the page again with get_page."}
            f = forms[n]
            fields: dict[str, str] = {}
            for fl in f["fields"]:
                if fl["type"] in ("checkbox", "radio"):
                    if fl.get("checked"):
                        fields[fl["name"]] = fl["value"] or "on"
                else:
                    fields[fl["name"]] = fl["value"]
            fields.update({k: v for k, v in f["hidden"].items()})
            for k, v in (inp.get("fields") or {}).items():
                fields[str(k)] = str(v)
            btn = str(inp.get("button") or "")
            chosen = None
            for bt in f["buttons"]:
                if btn and (btn.lower() in (bt["label"] or "").strip().lower() or btn == f"{bt['name']}={bt['value']}" or btn == bt["name"]):
                    chosen = bt
                    break
            if chosen is None and f["buttons"] and not btn:
                chosen = f["buttons"][0]
            if chosen and chosen["name"]:
                fields[chosen["name"]] = chosen["value"]
            fields["csrf"] = b.csrf() or fields.get("csrf", "")
            target = f["action"] or b.last_state.get("url", "")
            if target.startswith("?"):
                target = urllib.parse.urlparse(b.last_state.get("url", "")).path + target
            log.paths.append(f"POST {target} {json.dumps({k: v for k, v in fields.items() if k != 'csrf'})[:100]}")
            if f["method"] == "get":
                q = urllib.parse.urlencode(list(fields.items()))
                status, raw, final = b.get(target.split("?")[0] + "?" + q)
            else:
                status, raw, final = b.post(target, list(fields.items()))
            text, b.last_state = render_page(raw, final, status, args.page_chars)
            note_page_issues(log, f"POST {target}", status, raw)
            return {"content": text}
        if name == "note":
            agent.notes = (agent.notes + "\n" + f"[{when.astimezone(HOLLOW_TZ):%a %H:%M}] " + str(inp.get("text", ""))[:400]).strip()[-2200:]
            return {"content": "saved"}
        if name == "report_bug":
            rec = {k: str(inp.get(k, ""))[:700] for k in ("severity", "title", "page", "steps", "actual", "expected")}
            rec.update(agent=agent.idx, area=agent.area_name, at=when.astimezone(HOLLOW_TZ).strftime("%a %H:%M"))
            log.bugs.append(rec)
            with lock, open(bugs_file, "a") as fh:
                fh.write(json.dumps(rec) + "\n")
            return {"content": "filed"}
        return {"is_error": True, "content": f"unknown tool {name}"}
    except ValueError as e:
        return {"is_error": True, "content": str(e)}
    except Exception as e:
        return {"is_error": True, "content": f"harness error: {type(e).__name__}: {e}"}


def note_page_issues(log: TickLog, where: str, status: int, raw: str):
    if status >= 500 or status == 0:
        log.errors.append(f"HTTP {status} on {where}")
    for m in html_errors(raw):
        log.errors.append(f"PHP text on {where}: {m}")


# --------------------------------------------------------------------------------------
# Sonnet overseer
# --------------------------------------------------------------------------------------
OVERSEER_SYSTEM = """You are the OVERSEER of an AI playtest of Gnome Venture, a cosy garden browser game. Fifty Haiku agents (each owns a focus area) play one simulated week, one hour per step, 168 steps, as separate players in one shared world. Each step you get a digest of what every agent did, the findings they filed, HTTP/PHP errors the harness saw automatically, and new lines from the PHP server log.

Your jobs each step:
1. FINDINGS: turn new agent reports and automatic errors into deduplicated findings. Only emit a finding if it is new (compare with KNOWN FINDINGS titles). Merge duplicates. Judge whether an agent's claim is believable from its evidence; mark confidence low if it looks like agent misunderstanding. Severity: crash, broken, exploit, ux, balance, typo, idea.
2. DIRECTIVES: steer agents. Tell an agent to verify a suspicious claim, to retry something at a later hour, to test an area nobody covered, or to stop wasting calls. At most 8 directives per step. Instruction is one or two sentences.
3. COVERAGE: note areas or pages not yet touched and push idle agents toward them.
4. MEMORY: keep a short running memory (max 1800 chars) of what matters for later steps: time-based things to re-check, suspicious patterns, who is stuck.
Be exact and brief. Do not invent evidence."""

OVERSEER_SCHEMA = {
    "type": "object",
    "properties": {
        "findings": {"type": "array", "items": {"type": "object", "properties": {
            "severity": {"type": "string", "enum": SEVERITIES},
            "area": {"type": "string"}, "title": {"type": "string"}, "details": {"type": "string"},
            "evidence": {"type": "string"}, "confidence": {"type": "string", "enum": ["high", "medium", "low"]},
            "agents": {"type": "array", "items": {"type": "integer"}}},
            "required": ["severity", "area", "title", "details", "evidence", "confidence", "agents"], "additionalProperties": False}},
        "directives": {"type": "array", "items": {"type": "object", "properties": {
            "agent": {"type": "integer"}, "instruction": {"type": "string"}, "wake": {"type": "boolean"}},
            "required": ["agent", "instruction", "wake"], "additionalProperties": False}},
        "coverage_gaps": {"type": "array", "items": {"type": "string"}},
        "memory": {"type": "string"},
    },
    "required": ["findings", "directives", "coverage_gaps", "memory"],
    "additionalProperties": False,
}


class Overseer:
    def __init__(self, client, cost: Cost, out: Path):
        self.client, self.cost, self.out = client, cost, out
        self.memory = ""
        self.findings: list[dict] = []
        self.coverage_gaps: list[str] = []
        self.page_hits: dict[str, int] = {}

    def digest(self, tick, when, logs: list[TickLog], agents: list[Agent], server_errs: list[str]) -> str:
        lines = [f"STEP {tick + 1}/{TICKS}  Hollow time {when.astimezone(HOLLOW_TZ):%a %Y-%m-%d %H:%M}",
                 f"MEMORY: {self.memory or '(empty)'}",
                 "KNOWN FINDINGS (titles): " + ("; ".join(f"#{i} [{f['severity']}] {f['title'][:70]}" for i, f in enumerate(self.findings[-80:])) or "none"),
                 f"ACTIVE AGENTS THIS STEP: {len(logs)} of {len(agents)}"]
        for lg in logs:
            a = agents[lg.idx - 1]
            seen = ", ".join(p[:40] for p in lg.paths[:6])
            for p in lg.paths:
                key = re.sub(r"[?&].*", "", p.replace("POST ", "").split(" ")[0]).lstrip("/")
                self.page_hits[key] = self.page_hits.get(key, 0) + 1
            lines.append(f"- agent {lg.idx} [{a.area_name}] calls={lg.calls} pages: {seen or '-'} | said: {lg.summary[:140] or '-'}"
                         + (f" | API:{lg.api_error}" if lg.api_error else ""))
            for e in lg.errors[:3]:
                lines.append(f"    AUTO-ERROR: {e[:200]}")
            for bg in lg.bugs:
                lines.append(f"    REPORT [{bg['severity']}] {bg['title'][:90]} @ {bg['page'][:50]} | did: {bg['steps'][:160]} | got: {bg['actual'][:160]} | wanted: {bg['expected'][:100]}")
        if server_errs:
            lines.append("PHP SERVER LOG (new lines):")
            lines += ["    " + l[:240] for l in server_errs[:12]]
        quiet = [a.idx for a in agents if a.turns == 0 or a.idx not in {l.idx for l in logs}]
        lines.append(f"INACTIVE THIS STEP: {quiet[:50]}")
        return "\n".join(lines)

    def step(self, tick, when, logs, agents, server_errs, budget_left: bool) -> list[dict]:
        text = self.digest(tick, when, logs, agents, server_errs)
        has_news = any(l.bugs or l.errors for l in logs) or server_errs
        if not budget_left:
            return []
        # quiet hours with nothing to judge: only call at every 6th step to keep steering cheap
        if not has_news and tick % 6 != 0:
            return []
        try:
            resp = self.client.messages.create(
                model=SONNET, max_tokens=6000, system=OVERSEER_SYSTEM, messages=[{"role": "user", "content": text}],
                output_config={"effort": "low", "format": {"type": "json_schema", "schema": OVERSEER_SCHEMA}})
        except Exception as e:
            print(f"  overseer error: {type(e).__name__}: {str(e)[:160]}")
            return []
        self.cost.add(SONNET, resp.usage)
        if resp.stop_reason == "refusal":
            return []
        try:
            data = json.loads(next(b.text for b in resp.content if b.type == "text"))
        except Exception:
            return []
        self.memory = data.get("memory", "")[:1900]
        self.coverage_gaps = data.get("coverage_gaps", [])[:12]
        for f in data.get("findings", []):
            f["found_at"] = f"{when.astimezone(HOLLOW_TZ):%a %H:%M}"
            self.findings.append(f)
            with open(self.out / "findings.jsonl", "a") as fh:
                fh.write(json.dumps(f) + "\n")
        for d in data.get("directives", [])[:8]:
            if 1 <= d.get("agent", 0) <= len(agents):
                a = agents[d["agent"] - 1]
                a.directives.append(d["instruction"][:400])
                a.force_wake = a.force_wake or bool(d.get("wake"))
        return data.get("findings", [])

    def final_report(self, agents: list[Agent], totals: dict, elapsed: str) -> str:
        agent_lines = [f"{a.idx} {a.area_name}: turns={a.turns} calls={a.calls} auto-errors={a.errors} last: {a.last_summary[:110]}" for a in agents]
        hits = sorted(self.page_hits.items(), key=lambda kv: -kv[1])
        findings = json.dumps(self.findings, indent=0)[:70000]
        prompt = (
            "The week is over. Write the final playtest report in Markdown for the developer (solo dev of a PHP game). Sections: "
            "1) Verdict in 5 lines. 2) Findings grouped by severity (crash, exploit, broken, balance, ux, typo, idea), each with title, area, "
            "exact repro (page, fields, button), evidence, confidence, agents; merge duplicates; drop low-confidence ones into a separate 'unverified' list. "
            "3) Coverage: which areas/pages were exercised, which were not (use the page hit counts and agent lines). "
            "4) Time-based observations (things that changed or failed to change across hours, day and week rollover). "
            "5) Suggested fix order. Be exact and concise; do not invent evidence beyond what is below.\n\n"
            f"RUN: {json.dumps(totals)} elapsed {elapsed}\nOVERSEER MEMORY: {self.memory}\nCOVERAGE GAPS NOTED: {self.coverage_gaps}\n"
            f"PAGE HITS: {hits[:120]}\nAGENTS:\n" + "\n".join(agent_lines) + f"\n\nALL FINDINGS (JSON):\n{findings}")
        resp = self.client.messages.create(model=SONNET, max_tokens=16000, messages=[{"role": "user", "content": prompt}],
                                           output_config={"effort": "medium"})
        self.cost.add(SONNET, resp.usage)
        return "\n".join(b.text for b in resp.content if b.type == "text")


# --------------------------------------------------------------------------------------
# dry-run stand-in (no API): proves the harness, server, clock and parsing work
# --------------------------------------------------------------------------------------
def dry_hour(agent: Agent, tick: int, when, args, lock, bugs_file) -> TickLog:
    log = TickLog(agent.idx)
    for path in ("garden.php", "world.php", "index.php"):
        log.paths.append(path)
        st, raw, fin = agent.browser.get(path)
        text, agent.browser.last_state = render_page(raw, fin, st, args.page_chars)
        note_page_issues(log, path, st, raw)
        if tick == 0 and agent.idx == 1:
            print("---- sample rendered page ----\n" + text[:1800] + "\n------------------------------")
    log.calls = 3
    log.summary = "dry run"
    agent.turns += 1
    return log


# --------------------------------------------------------------------------------------
def next_wednesday_midnight_hollow(now: dt.datetime) -> dt.datetime:
    d = now.astimezone(HOLLOW_TZ).date()
    d += dt.timedelta(days=(2 - d.weekday()) % 7 or 7)
    return dt.datetime(d.year, d.month, d.day, tzinfo=HOLLOW_TZ)


def main():
    ap = argparse.ArgumentParser(description=__doc__, formatter_class=argparse.RawDescriptionHelpFormatter)
    ap.add_argument("--out", default=str(REPO / "playtest-out"), help="work and output folder (default ./playtest-out, git-ignored)")
    ap.add_argument("--port", type=int, default=8765)
    ap.add_argument("--budget", type=float, default=80.0, help="hard USD cap for the whole run (default 80)")
    ap.add_argument("--reserve", type=float, default=6.0, help="USD kept back for the overseer's last steps and report")
    ap.add_argument("--concurrency", type=int, default=8, help="agents played at once (game server workers = same)")
    ap.add_argument("--calls-per-hour", type=int, default=6, help="max tool calls per agent per simulated hour")
    ap.add_argument("--page-chars", type=int, default=3500, help="max page text characters shown to an agent")
    ap.add_argument("--ticks", type=int, default=TICKS, help="hour steps to run (168 = one week)")
    ap.add_argument("--agents", type=int, default=N_AGENTS)
    ap.add_argument("--always-on", action="store_true", help="every agent plays every hour (about 2x the cost)")
    ap.add_argument("--start", help="Hollow start time 'YYYY-MM-DD' (midnight Halifax); default next Wednesday")
    ap.add_argument("--faketime-lib", help="path to libfaketime.so.1")
    ap.add_argument("--seed", type=int, default=7)
    ap.add_argument("--resume", action="store_true")
    ap.add_argument("--dry-run", action="store_true", help="no API calls: boot, register players, 2 steps of scripted browsing")
    args = ap.parse_args()

    if not args.dry_run:
        if anthropic is None:
            sys.exit("pip install anthropic")
        if not os.environ.get("ANTHROPIC_API_KEY"):
            sys.exit("Set ANTHROPIC_API_KEY (the key that has your credit).")
    if shutil.which("php") is None:
        sys.exit("php not found")
    if sys.platform != "linux":
        print("note: libfaketime via LD_PRELOAD works on Linux/WSL; on other systems run this in a Linux container.")

    out = Path(args.out)
    out.mkdir(parents=True, exist_ok=True)
    rng = random.Random(args.seed)
    n_agents = min(args.agents, N_AGENTS)
    ticks = 2 if args.dry_run else args.ticks
    state_path = out / "state.json"
    state = json.loads(state_path.read_text()) if args.resume and state_path.exists() else {}

    srv = GameServer(out, args.port, find_faketime(args.faketime_lib), args.concurrency)
    srv.prepare()
    start = (dt.datetime.strptime(args.start, "%Y-%m-%d").replace(tzinfo=HOLLOW_TZ) if args.start
             else (dt.datetime.fromisoformat(state["start"]) if state.get("start") else next_wednesday_midnight_hollow(dt.datetime.now(dt.timezone.utc))))
    srv.set_clock(start)
    srv.start()
    t0 = time.time()
    stop = threading.Event()
    signal.signal(signal.SIGINT, lambda *_: stop.set())

    print(f"game server on {srv.base}, clock starts {start:%a %Y-%m-%d %H:%M} Halifax")
    if not state.get("installed"):
        print("installing game, enabling features...")
        install_and_enable(srv, "TestPassword123")
        state["installed"] = True
    users = state.get("users") or {}
    agents: list[Agent] = []
    sched_names = list(SCHEDULES)
    print(f"registering {n_agents} players...")
    for i in range(1, n_agents + 1):
        area = AREAS[i - 1]
        cookie = out / f"cookies-{i:02d}.txt"
        if str(i) not in users:
            u, pw = register_player(srv, i, "gnome", cookie, rng)
            users[str(i)] = [u, pw]
            lvl = BOOSTS.get(area[0])
            if lvl:
                srv.db("UPDATE users SET level=?, xp=?, coins=? WHERE username=?", (lvl[0], 50 * lvl[0] * (lvl[0] - 1), lvl[1], u))
        u, pw = users[str(i)]
        ag = Agent(i, area, sched_names[(i * 7 + rng.randrange(6)) % len(sched_names)], u, pw, Browser(srv.base, cookie))
        if args.resume and str(i) in state.get("agents", {}):
            ag.load_state(state["agents"][str(i)])
        agents.append(ag)
    state["users"] = users
    state["start"] = start.isoformat()
    state_path.write_text(json.dumps(state))
    srv.new_log_errors()  # skip install noise
    srv.log_pos = (out / "server.log").stat().st_size

    cost = Cost(state.get("cost", 0.0))
    client = None if args.dry_run else anthropic.Anthropic(max_retries=4, timeout=120.0)
    overseer = Overseer(client, cost, out)
    overseer.memory = state.get("overseer_memory", "")
    overseer.findings = state.get("findings", [])
    overseer.page_hits = state.get("page_hits", {})
    lock = threading.Lock()
    bugs_file = out / "agent_bugs.jsonl"
    first = state.get("tick", -1) + 1 if args.resume else 0
    pool = cf.ThreadPoolExecutor(max_workers=args.concurrency)
    stopped_early = ""

    for tick in range(first, ticks):
        if stop.is_set():
            stopped_early = "interrupted"
            break
        when = start + dt.timedelta(hours=tick)
        srv.set_clock(when)
        hod = when.astimezone(HOLLOW_TZ).hour
        active = [a for a in agents if args.always_on or args.dry_run or hod in a.hours or a.force_wake]
        for a in active:
            a.force_wake = False
        budget_left = cost.spent < args.budget - args.reserve
        if not budget_left and not args.dry_run:
            stopped_early = f"budget reached at step {tick + 1} (${cost.spent:.2f})"
            break
        if args.dry_run:
            futs = [pool.submit(dry_hour, a, tick, when, args, lock, bugs_file) for a in active[:6]]
        else:
            futs = [pool.submit(run_agent_hour, a, client, cost, tick, when, args, lock, bugs_file) for a in active]
        logs = []
        for f in futs:
            try:
                logs.append(f.result())
            except Exception as e:
                print(f"  agent crashed: {type(e).__name__}: {e}")
        logs.sort(key=lambda l: l.idx)
        server_errs = srv.new_log_errors()
        with open(out / "events.jsonl", "a") as fh:
            for lg in logs:
                fh.write(json.dumps({"tick": tick, "time": f"{when.astimezone(HOLLOW_TZ):%a %H:%M}", "agent": lg.idx, "calls": lg.calls,
                                     "paths": lg.paths, "errors": lg.errors, "bugs": len(lg.bugs), "summary": lg.summary, "api_error": lg.api_error}) + "\n")
            if server_errs:
                fh.write(json.dumps({"tick": tick, "server_log": server_errs[:30]}) + "\n")
        new = [] if args.dry_run else overseer.step(tick, when, logs, agents, server_errs, budget_left)
        n_bug = sum(len(l.bugs) for l in logs)
        n_err = sum(len(l.errors) for l in logs)
        print(f"step {tick + 1:3d}/{ticks} {when.astimezone(HOLLOW_TZ):%a %H:%M}  active={len(logs):2d} reports={n_bug} auto-errors={n_err} "
              f"server-log={len(server_errs)} new-findings={len(new)} total-findings={len(overseer.findings)}  spent=${cost.spent:.2f}  {time.time() - t0:.0f}s", flush=True)
        state.update(tick=tick, cost=cost.spent, overseer_memory=overseer.memory, findings=overseer.findings, page_hits=overseer.page_hits,
                     agents={str(a.idx): a.to_state() for a in agents})
        state_path.write_text(json.dumps(state))

    pool.shutdown(wait=True)
    elapsed = f"{(time.time() - t0) / 60:.1f} min"
    totals = {"steps_run": state.get("tick", -1) + 1, "stopped_early": stopped_early or None, "spent_usd": round(cost.spent, 2),
              "tokens_by_model[in,out,calls]": cost.by_model, "findings": len(overseer.findings)}
    if args.dry_run:
        print("dry run OK:", json.dumps(totals))
    else:
        print("writing final report with the overseer...")
        try:
            report = overseer.final_report(agents, totals, elapsed)
        except Exception as e:
            report = f"# Final report failed: {type(e).__name__}: {e}\nSee findings.jsonl.\n"
        (out / "report.md").write_text(report)
        totals["spent_usd"] = round(cost.spent, 2)
        print(json.dumps(totals, indent=1))
        print(f"report: {out / 'report.md'}")
    srv.stop()


if __name__ == "__main__":
    main()
