# Here: labels + popover rules (brainstorm, 2026-11-05, for Josh to pick)

Problem (phone shot, Maizehollow Market): picture tags are ~7px, overlap (Town Library / Piñata Tree), run under the compass, and the big text list below repeats every name. NPC tap goes to a plain page.

## A. Text in the picture: options
1. **Numbered pins (RECOMMENDED).** No words on the picture. Each thing gets a round-edge gold badge 1..N (18px min on phone) at its `pin` point (layout field, default top-centre of box). The list below is the legend: same number + name + one-word verb. Tap pin or list row = same popover. Picture stays clean, nothing overlaps, always readable. People: small portrait-dot pin, no number.
2. **Pills.** Dark pill with white text, fixed 11px+ in screen space (not scaled with the SVG), per-spot `tag` anchor in the layout, collision pass pushes pills apart; long names cut to 2 lines. Busier picture, still can clip on 360px.
3. **Names on tap only.** Picture shows brackets; name appears in a bubble on tap/hover. Cleanest, but "tell what to click" is lost until you tap.
Pick 1 as default; a setting "Names on picture" (pills) for those who want words. Both read one list so no drift.

## B. The list below the picture
- One compact list, not big buttons: row = number badge, small icon, name, verb chip (Shop, Talk, Read, Rest, Explore), state dot (new / locked / closed / goal).
- Grouped: **Places** (tap = popover), **People** (portrait row), **Ways out** (compass Routes, kept as its own sheet).
- Wander off the Trail / Shops stay as rows (they are real actions, not places).
- Rows are the accessible fallback: keyboard order = number order. Row height 44px, 2 per line only if both names fit.
- Long press / hover on a row lights its bracket in the picture.

## C. Rules for what a tap does (standard, applies to every Here picture)
1. **Tap never spends anything and never navigates by itself, except a Set off (travel) button inside a card.** Everything opens a popover first.
2. **Four kinds, one popover shell:**
   - *Person* -> person card.
   - *Place with things to do* (Green, Café, Plaza, Piñata Tree) -> place card: flavour line, what is here now, 1-3 actions.
   - *Service page* (Shops, Notice Board, Library) -> card with a live preview (3 top items / 2 newest notices) + **Open** button to the full page.
   - *Way to another town/stop* -> Routes card (name by destination, cost, **Set off**). Only this leaves the node.
3. **Popover anatomy:** header (icon, name, one-line mood) / body (state, who is here) / actions (max 3 big buttons, same order every time: primary, secondary, "More" fold) / footer (Full page link, Close). Close = ✕, Esc, outside tap, phone Back. Reload keeps it open (`?open=key`, already exists).
4. **Costs and locks shown before the tap**: energy chip on the button, lock reason as text (closed till 8 am, needs level), never a dead button.
5. **Verbs fixed:** Talk, Give, Trade, Shop, Read, Enter, Rest, Explore, Set off, Open. No synonyms.
6. **Same key opens same card** from picture pin, list row or link elsewhere (`here.php?open=<key>`).
7. **Full pages are the second step**, linked "Open full page", so deep links and old bookmarks keep working.

## D. Person popover (new)
- Header: portrait, name, species/job, mood + where they are from (home, work).
- Line of the day (1 sentence, changes by time/season/friendship).
- Buttons: **Talk** (chat opens inside the card: their line, 2-3 reply choices, back arrow; ends with a friendship tick shown), **Give** (inline satchel strip filtered to what they could take; likes/loves hint shown after a first gift; confirm tap), **Trade / Shop** if they sell, **Task** if they have one (badge), **Knock** only at a home door.
- More fold: Profile (full page), Gift history, Birthday.
- Friendship: hearts bar under the header; gift/chat results update it in place.
- Tap area on the picture: whole sprite, 44px min; name shown on tap only.
- Several people on one slot cluster -> a "Who is here (4)" card listing portraits.

## E. Build order (code, no new art needed except pin sprite optional)
1. Pin renderer + `pin` field default in `hub_hotspot_box` (replace `.tag`), setting for pills. CSS only for the badge; emoji/no art.
2. New list component `here_list_html()` (number, verb chip, state) replacing the button grid; lint it against the pins (same numbers).
3. Popover shell standard (`here_card()`): one function, used by places, services, people; lint that every spot has a card.
4. Person card + chat/gift endpoints (reuse `npc_gift`, villager chat; no spend on open).
5. Service previews (Shops, Notice Board, Library).
6. Tests: pin/list numbers match, every spot has a card, tap spends nothing, Back closes.

## F. Questions for Josh
- Numbered pins as default? (yes/no/pills)
- Chat inside popover (choices) or open the villager page?
- Gift: pick from satchel inside the card, or keep today's gift page?
