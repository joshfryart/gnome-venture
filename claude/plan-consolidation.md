# Gnome Venture: consolidation plan (2026-10-17)

From the overlap review (Sonnet, 2026-10-17).
Rule: one job = one place. Never remove access to a page without a link from its hub.

## Done
- 1.7.0: stamps+reactions merge, "Guestbook" rename, one visitor notice/day, duplicate menu links, Getting started link, garden "Need help?" panel.
- 1.7.1 (Phase A): Today Home one jar/Pulse row; admin settings labels prefixed + grouped; unlinked pages audit (no orphans).
- 1.7.2 (Phase B, done early because few players yet = little disruption):
  - jobs.php = "📋 Tasks", tabs ?t=jobs|quests|orders|errands (sub-tab ?p=daily|weekly|monthly|post). Helpers in includes/quests_view.php (tasks_counts/quests/orders/errands/order_post). town.php?view=quests → jobs.php?t=orders (POST too); jobs.php?s=quests → t=quests. Order + favour POSTs handled in jobs.php. journey.php `back` now also accepts jobs.php?… (Journey hand-in buttons on Quests tab not built yet).
  - community.php = "🌻 Together", tabs ?t=garden|jar|about; hollow.php redirects to ?t=jar. Jar tier settle runs on jar tab + Today.
  - Names: "Gnome friends" (players), "Villagers" (NPC folk; rest-stop tab, world map, gnome page, Almanac heading). Almanac chapter key "Folk" unchanged. mentor.php = "Calling mentor", pals.php?tab=mentor = "Gnome mentor" (two different features, both kept).
  - games.php?tab=contests = hub cards (Show, Fair, GotM, Pumpkin Carving) with status + entered + one button (contests_hub_html in includes/contests.php); entry pages have "← Contests".
  - Menu: Together / Tasks / Gnome friends / Villagers; Hollow tile gone; bottom bar "Tasks".
  - Tests updated: social100.sh, mentors120.sh (Together URLs, tab label), games2.sh (counts `box ccard`).

## Phase C (code tidy, no player change)
- `gate_can_interact()` for every visitor action (started 1.7.0).
- Fold social169 into the social module; small dispatch table in visit.php.
- One shared roll-up notice helper for repeat notices (friend requests, gifts, visitors).
- One event hook for "did X today" (daily card, First Week, Hollow Goals, callings).
- Tasks menu badge: use tasks_counts() total (cache per session; it queries DB).
- Journey hand-in buttons directly on Tasks → Quests.
- Remaining "Folk"/"Hollow page" wording in includes/almanac_notes.php (148, 183, 184).
