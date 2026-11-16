# Puzzle Pals batch c05, Haiku first pass (art-2701-pals-all/c05/haiku)

Worklist index 5 of `../../worklist.json`. Eight pals, each with a yard sprite (64x64, `c:eyeLocked`) and a
hand-built perch sprite (36x36, `c:eyeSmall`). Built with `lib/hp.lua` directly (no Opus helper, nothing copied
from other pal folders). Every file passes `HP.assertClean` (0 semi-transparent, 0 pure black or white).
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua` (same for `-perch`).

| key | pal | rarity | calling | design / quirk |
|---|---|---|---|---|
| th-coffee-crumb | Coffee Crumb | common | brewroot | bean with an oversized dusk-purple hat; steam curl off the hat |
| th-flamingo-flick | Flamingo Flick | common | bloomcaller | one-legged petal flamingo in a sea waterhole; wing raised as a dare |
| th-termite-tower | Termite Tower | common | rootwarden | tapered ember tower with banded rings; grains drop off the base |
| th-acacia-antler | Acacia Antler | uncommon | rootwarden | moss body under antler twigs; gold weaver nest on each tip |
| th-kopje-keeper | Kopje Keeper | uncommon | thornblade | grey stone boulder with open locked eyes; moss tuft and sprout on top |
| th-tall-tiptoe | Tall Tiptoe | rare | wayfinder | gold giraffe with spots, petal muzzle, leaf on the head, sparkle |
| sp-saffron-snip | Saffron Snip | common | seedkeeper | gold round body with ember saffron threads and stone scissors; music notes |
| sp-yak-yonder | Yak Yonder | common | wayfinder | wood-brown yak with a dusk load on its back; pennant pointing ahead |

Weakest: flamingo wing reads as a fin at 36 px; kopje keeper has few tones (10 colours) and needs more
texture; tiptoe perch leaf is tight against the head. Not reviewed past a contact sheet.
