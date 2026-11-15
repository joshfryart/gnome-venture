# Tag icons, Opus pass (2701-opus), 8 PF_TAGS pieces

Fresh designs (Sonnet's `art-2701/tags` untouched). 64x64 native like `game/assets/img/ph`, hard pixels, 1 px ink
outline via `c:finish`, `HP.assertClean` passed on all (0 semi-transparent, 0 pure black/white). `_o.lua` is the
private helper (loads `lib/hp.lua` + `lib/hpx.lua` read-only: per-pixel lighting, tubes, local-frame masks, recentre,
save). Re-run: `AppRun -b --script-param out=<this dir>/ --script <name>.lua`. Not copied into `game/`.

| file | piece / tag | depicts | quirk | remaining weakness |
|---|---|---|---|---|
| jab | Jab / quick | red knitted mitten fist punching up-right, ribbed oatmeal cuff, 3 speed streaks, small gold pop star at the knuckles | worn hole at the knuckle, a fingertip peeks out | fingertip hole is small (reads as a beige dot under 32 px); could pass for a boxing glove |
| pierce | Pierce / pierce | one long arrow through a narrow, nearly edge-on plank buckler (iron rim and boss): fletching in front, cracked entry, shaft and steel head out the far side, splinters | a leaf skewered on the shaft past the shield | splinters are tiny; shield face grain a little busy |
| sting | Sting / poison | whole wasp in profile, abdomen curled under so the stinger points down-left, green venom drop hanging off it plus one falling | cross little eyebrow | brow/face tiny at 16 px; top/bottom margins 3-4 px (tall pose) |
| trip | Trip / trip | teal gnome boot pitching forward, heel kicked up, curled toe hooked under a gnarled root arching out of an earth clod, wobble arcs | small orange mushroom on the root | foot is half hidden by the root so the boot reads mostly as shaft + heel; smallest silhouette of the set |
| bash | Shield Bash / bash | round buckler quartered blue/cream, iron rim and boss, rim thickness showing, swung right into a jagged gold impact burst, swoosh arcs | sticking plaster over an old crack | boss flange is low-contrast; plaster reads only at 64 px |
| smash | Smash / heavy | big barrel-head beetle mallet (2 iron hoops, end-grain cap, ash handle) slammed onto a flagstone: star cracks, chips, dust, drop arcs | a pink daisy knocked flat on the slab | mallet head lighting is fairly flat (light runs along its axis); cracks thin |
| brace | Brace / hold | tall arched pavise (violet planks, gold spine, two iron bands, boss, studs) dug into turf and propped by a pole, wedge stone at its foot | a snail settled on top, staying put | without the prop pole it could read as a door; arch is gentle |
| roll | Roll / evade | woodlouse rolled into a ball of slate-blue overlapping plates, pink face and antennae at the front, spin arcs over the top, dust puffs behind, ground shadow | it winks | plate arcs can still hint at a ball of yarn at 16 px |

Every icon has a different main hue (red, wood+red, yellow/black, teal, blue/cream, wood/stone, violet, slate blue)
and a different silhouette, and none repeats the existing `ico-fist`, `ico-shield` or `ico-hammer` designs.
