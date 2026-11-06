# Product

> Draft written from README.md, claude/art-style-guide.md and the code during the polish audit (claude/plan-polish.md, Phase 0). Items marked **(confirm)** are inferred, not stated by Joshua. Run impeccable `init` to confirm them.

## Platform
web (responsive, phone first; also installable via `game/manifest.json`).

## Stack
Plain PHP 8.1+ with PDO, no framework, no build step. MySQL on the live host (CanSpace shared cPanel), SQLite for local tests. Vanilla JS in `game/assets/*.js`. One main stylesheet `game/assets/style.css` plus `puzzles.css`, `catfish.css`, `landing.css`, `admin.css`. CSP is `style-src 'self'`, so no inline styles.

## Users
Players of a cosy browser game, mostly on phones **(confirm)**. A gnome may also be a throwaway guest account (no email). Admins (Joshua) run the content, settings and updates from `game/admin/`.

## Product Purpose
Gnome Venture is a cosy garden game: grow plants, tend beds, cook, trade, explore roads and regions, hire help, play small puzzle games. Live at gnomeventure.ca. No monetization.

## Positioning
A gentle, no-pressure daily game with a lot of small systems (garden, world, pals, puzzles, crafting, Cat Fish, Treks). The risk is breadth: many pages and tabs for one small player base **(confirm)**. Polish should make the game feel smaller and calmer, not add surface.

## Operating Context
Solo-developed. Releases are slim zips uploaded by Joshua through Admin > Update. Many features ship OFF behind settings (`trek_open`, `catfish_open`, `ppal_open`, `gourmand_open`, `delve_v2`, `ppal_boons`) and admins see them first. Hollow time is America/Halifax; days turn at local midnight.

## Capabilities and Constraints
- Shared hosting: no cron, no build step, weather and time computed on view.
- No framework; changes must keep working on PHP 8.1 and MySQL as well as SQLite.
- Old URLs must keep working (redirect stubs exist: `kitchen.php`, `passport.php`, `seasons.php`, `arrange.php`, and old `jobs.php?t=orders|errands|quests` links; `crafting.php` is a live page that also serves the Satchel Crafting tab).
- Core and Player & Progression function signatures are shared by every section (see graphify-out/SECTIONS.md).

## Brand Commitments
- Art style "Stitched Toy": felt and stitch chrome, hard pixel corners, 1 px umber outline on pixel art, warm palette, no pure black.
- Characters: Jeff hosts, his twin Ffej makes mischief, the Old Wizard gives hints; pal and villager names are part of the voice.
- Cosy, short, friendly copy. Few words.

## Evidence on Hand
README screenshots (`docs/screens/`), landing shots, the style guide (`claude/art-style-guide.md`, PDF in `game/assets/guides/`), the 2026-10-31 polish audit (`claude/polish-audit.md`). No player analytics or usage data in the repo **(confirm whether any exists)**.

## Product Principles
1. One place for each thing. Do not add a new page when a tab or fold on an existing one will do (see consolidation list in `claude/plan-polish.md` section 7).
2. Phone first, about 412 px, dark theme; desktop is the same design with more room.
3. Calm over busy: fold explanations, few words, one solid button per card.
4. Nothing breaks old links or saves.
5. Features stay OFF until Joshua checks them on a phone.

## Accessibility & Inclusion
Tap targets at least 44 px (`--tap`), visible focus (`--focus`), dark and light themes with equal contrast, `prefers-reduced-motion` honoured, no sideways scrolling, every icon-only control has a name. Status is never colour-only **(confirm)**. Screen reader and 200% zoom have never been tested.
