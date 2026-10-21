# Art to-do: icons still missing (2026-10-21)

Each needs a plain SVG in `tests/ico_src/ico-<slug>.svg` (viewBox 64, no halo), then the recipe in `claude/todo.md` (ico_build restyle, row in `tests/ico_map_source.json`, `ico_map_build.py`, `build_guide.py`). Until a file exists the emoji shows.

## Trek (fight, events, HUD)
| Emoji | Slug to draw | Where |
|---|---|---|
| 🪃 | ico-boomerang | Wayfinder shot breaks Old Pinch's hold (trek_fight.php, fight log) |
| 🩹 | ico-bandage | trail event "Patch it up" (trek_events.php) |
| 🤲 | ico-cupped-hands | trail event "Catch it" |
| 👂 | ico-ear | trail event "Count the beats" |
| 🤫 | ico-shush | Sneak button (trek.php) |
| 😮‍💨 | ico-tired | Tired / Worn out chip (two-part emoji; map needs the ZWJ form) |
| ⚪ | ico-dot-empty | unearned milestone bullet |

## Withheld on purpose (see WITHHOLD in tests/ico_build.py)
🙏 prayer (Blessed chip), 🤝 handshake (Help button): need a non-religious / neutral redraw first.

## Not art: how trek combat shows icons
Fight log lines, replay rows and foe cards are JSON, so the page-wide emoji swap never saw them. Fixed in 2.0.31 (`trek_ico_html()`): they now use our icons wherever a file exists.
