# New-Player Welcome Flow: Mobile Redesign (design document)

Status: proposal + static mockup. No game code changed. Target: `game/welcome.php`, `game/assets/style.css` (~758-783).
Viewport: 412px phone first. Tokens from DESIGN.md (pixel corners, `--px 2px`, `--tap 44px`, no inline style, no sideways scroll, dark+light check).

## Problem
Steps are text walls: long Wren paragraphs, label-heavy swatches, chip walls (20+ items), primary button below the fold on step 3.

## Principles
1. One picture or icon before any sentence. 2. Max 1-2 sentences per Wren line; rest behind "More". 3. Items are icons with a x-N badge; names on tap/under. 4. One primary action, always visible (sticky bar). 5. Centred layout.

## Shared components
- **Progress**: 3 pixel icon tiles joined by bars (done = check, now = ringed). Done tiles link back. aria-label "Step N of 3: ...".
- **Wren bubble**: one box. Wren portrait (72x72) inside at left, text right, tail at bottom-left pointing down. "More" is `<details>`/44px toggle holding long copy (gentle roads, level info, hat-at-level-5 note).
- **Sticky CTA bar**: felt bar, gold dashed top thread, full-width primary button, 44px ghost Back below. Respect `--sab` safe area; check with keyboard open.

## Step 1: Your gnome
Wren bubble > stage (backdrop art + 160px `gnome_avatar()` live preview) > name input > hat row > beard row.
Swatches: 44px colour tiles, checkmark on selected, `title`/`aria-label` carry the colour name (colour never the only signal). Row emoji marks hat/beard. Help text removed.

## Step 2: Village
Wren bubble > two village cards side by side (scene art, name; whole card is a radio) > **welcome basket** > one hint line.
- **Basket, top-down view**: round woven rim around an empty floor; the selected village's items rest on the floor as 46px slots, x-N badge, short name under. Title "<Village>'s welcome basket".
- **Switching villages** empties the basket; new items drop in with a 60ms staggered pop (0.25s). `prefers-reduced-motion`: no animation. `aria-live=polite` on the basket.
- Poppyburrow: Four-leaf Clover 1, Wild Honeycomb 1, Wild Strawberries 1, Meadowsweet 1, Wild Rice Seeds 2, Raspberry 2.
- Honeybrook: same first four, Apple Seedling 2, Apple 2. (Data comes from `village_welcome_pack()`; max ~6 slots in a 3x2 grid; more would shrink or scroll inside the basket, never sideways.)
- More than 2 villages: cards wrap to a 2-col grid.

## Step 3: First garden
Wren bubble > garden name input > 3 stat tiles (500 petals, 4x4 plot, 20 energy) > 3 pack cards (Maplewold seeds, <Village> basket, Everyday kit): header icon + title + count, first 5 items as icon slots with x-N badge; header tap expands full list (`<details>`). Contents mirror what step 2 showed. Plant button lives in the sticky bar; Back = "Change village".

## New art (all shown as red-outline placeholders in the mockup)
| Asset | Purpose | Size |
|---|---|---|
| wren-portrait | Speaker in every Wren bubble | 72x72 |
| stage-backdrop | Meadow + mushroom-ring stage behind gnome, step 1 | 380x230 |
| village-poppyburrow | Village card scene, step 2 | 160x100 |
| village-honeybrook | Village card scene, step 2 | 160x100 |
| welcome-basket-topdown | Round woven rim + empty floor, items overlay; step 2 | 380x330 |
| pack-seeds / pack-basket / pack-kit | Pack card header icons, step 3 | 32x32 each |
| progress icons x3 (optional) | Gnome / house / sprout tiles replacing emoji | 18x18 each |
Rule: each future village needs one 160x100 scene (fallback: landscape emoji on flat colour). Basket art must keep its centre floor clear for items. CSS in the mockup (conic weave + ellipse) is a stand-in.

## Code impact
- `welcome.php`: replace `<ol class="wsteps">`; `.say` boxes become portrait+bubble with `<details>`; gnome step drops labels/help; village step renders radio cards + a basket container filled from `village_welcome_pack()` for every village (all baskets in DOM, toggled with a small JS handler on `change`, so it works as a normal form without JS: server-rendered selected basket); garden step: `seed_chips()` variant `pack_slots()` (icon + badge); `.wcta` bar.
- `style.css`: replace `.wsteps .avatarcol .swatches(welcome) .zonecard .villagepick`; add `.wprog .wren .stage .vcard .wbasket .wpack .wstat .wcta`.
- Village art path convention e.g. `img/villages/<slug>.png`.
- Mockup uses inline style for swatch colours and item animation delay; production uses classes / CSS custom properties set via data attributes (CSP `style-src 'self'`).

## Risks / open questions
- Hiding Wren copy behind "More" may drop the gentle-roads / recommended-level guidance. Confirm with game design.
- Icon-only slots: keep names visible in basket; titles on swatches; test with screen reader.
- Basket capacity: villages with >6 items need a layout rule.
- Emoji differ by platform; real item art (`name_emoji` / item icons) may vary in width.
- Sticky bar vs bottom menu / keyboard.

## Files
`index.html` (open `#s1` `#s2` `#s2h` `#s3`), `step1.png`, `step2.png`, `step2-honeybrook.png`, `step3.png`.
