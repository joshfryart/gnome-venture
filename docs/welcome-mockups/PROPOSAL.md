# Welcome flow redesign (proposal only, no game/ code changed)

Mockups: `index.html` (open `index.html#s1`, `#s2`, `#s3` for one 412px frame). Red 2px boxes = new art slots.
Real tokens from style.css; hat/beard swatch colours and emoji are stand-ins for the real HAT_COLORS / BEARD_COLORS / item icons.

## Shared
- Progress: 3 pixel icon tiles joined by bars (done = green check, now = ringed) replace the text tabs. Previous steps stay tappable. Label via aria-label.
- Wren: 96px portrait + bubble, max 1-2 sentences. The old long copy sits behind a 44px "More" toggle (details/summary, no JS needed).
- Sticky bottom bar (felt + gold stitch line) holds the one primary button and a 44px ghost "Back". Centred, full width.

## Step 1: Your gnome
Wren, then a big centred gnome on a stage (160px avatar), name input, then two rows of 44px colour tiles (hat, beard) with a tiny icon label. No visible text labels or help paragraphs; names via title/aria-label. The "calling hat colour takes over at level 5" note moves into "More".

## Step 2: Village
Two illustrated cards side by side (scene 160x100, name, 3 hero item icons + "+N"). Whole card is the radio. Error/gentle-road copy is a single hint line. Zone heading/landscape text is dropped (one zone per card group is implied by the scene art).
If a region ever has more than 2 villages: 2-column grid wraps.

## Step 3: First garden
Garden name input first, then 3 stat tiles (petals, plot, energy), then 3 "pack" cards (Maplewold seeds / Village basket / Everyday kit): icon-only slots with ×N badges, first 5 shown, "+N" opens the full list (details). Plant button is always visible in the sticky bar. Almanac line becomes one slot in the kit.

## New image assets
| Name | Purpose | Size |
|---|---|---|
| wren-portrait | Wren bubble speaker (all 3 steps) | 96x96 |
| stage-backdrop | Gnome preview stage, step 1 | 380x230 |
| village-poppyburrow | Village card art | 160x100 |
| village-honeybrook | Village card art | 160x100 |
| pack-seeds / pack-basket / pack-kit | Pack card header icons | 32x32 each |
| (optional) progress icons x3 | Replace emoji in progress tiles | 18x18 |
Future villages need one 160x100 scene each (fallback: landscape emoji on a flat colour).

## Code that would change
- welcome.php: replace `<ol class="wsteps">` markup; rewrite `.say` boxes as portrait + bubble with `<details>`; gnome step markup (drop labels/help, swatches get no `<span>` label); village step labels become cards; garden step: new `seed_chips` variant `pack_slots()` emitting icon + ×N badge; wrap button + back in a `.wcta` bar.
- style.css (~758-783): replace `.wsteps`, `.avatarcol`, `.swatches` (welcome only), `.zonecard`, `.villagepick`; add `.wprog`, `.wren`, `.stage`, `.vcard`, `.wpack`, `.wstat`, `.wcta`. All with `--px` stepped corners, no inline style.
- Village scene art needs a column or file naming convention (e.g. `img/villages/<slug>.png`).

## Risks
- Sticky bar vs the phone bottom menu / safe area: use `--sab`; check keyboard-open on the name inputs.
- Icon-only slots hurt clarity and colour-only swatches fail accessibility: keep titles, aria-labels, checkmark on selected, and tap-to-reveal names for slots.
- Hiding Wren's text behind "More" may drop the gentle-roads/level info; confirm with game-designer.
- Emoji vary by platform; real item icons (name_emoji) may differ in width.
- Mockup uses inline style for swatch colours; production must use classes/data attributes (CSP).

## Update: Wren bubble + welcome basket
- Wren portrait (72x72) now sits inside the speech-bubble box, tail pointing down-left. One shared component, all 3 steps.
- Step 2: village cards lose their item icons. A woven "welcome basket" sits below the cards; it holds the selected village's items as big slots with x-N badges and names. Tapping a card swaps the contents (items drop in with a short staggered pop, off under prefers-reduced-motion). `aria-live=polite` announces the change.
- Extra art: none required (basket is CSS weave; optional pixel basket rim later). Mockup states: `index.html#s2` (Poppyburrow), `#s2h` (Honeybrook); screenshots step2.png, step2-honeybrook.png.
