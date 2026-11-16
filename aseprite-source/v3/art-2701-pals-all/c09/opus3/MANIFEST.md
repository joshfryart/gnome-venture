# Puzzle Pals chunk c09, Opus richness pass (art-2701-pals-all/c09/opus3)

Richness pass on chunk 9 of `../../worklist.json`, built on `../opus2/`. 8 pals, each a yard sprite (64x64,
`c:eyeLocked`) and a perch sprite (36x36, hand-drawn at its size, `c:eyeSmall` pills): 16 sprites as `.lua` +
`.aseprite` + `.png`. Same keys, callings and concepts. Siblings of `c00/opus3` and `art-2701-batch3/pals/opus3`:
5-6 tone hue-shifted ramps, upper-left light with one lower-right shade, rim light and cool bounce, material
texture via `O.tex`, one quirk plus a smaller closer-look detail. `_opus.lua` is the unchanged opus2 helper (tools only).
`HP.assertClean` passes on all 16 (0 semi-transparent, 0 pure black/white, 1px ink `#2b1c26`). Not copied into game/.
Run: `AppRun -b --script-param out=<dir>/ --script <key>-yard.lua`.

| key | pal | richness added | opus2 weakness fixed | closer-look detail |
|---|---|---|---|---|
| pl-frt-3 | Thawdrop Pip | indigo-to-mint water ramp, frozen tip cap, ice shard in the core, trapped air bubbles, frost fleck | yawn read as "wow": now wide and lopsided with a dark throat and tongue, a yawn tear, a frosty breath curl and a sleepy Z (perch too) | a snowdrop sprouting by the puddle |
| pl-frt-4 | Frostwart Bumps | toad spots and goosebump grain, pimples and a pore on each wart, icicle points and glints on the frost caps, lit lip, nostrils | the jumping wart sat on a stalk and read as a little tree: now it floats clear of the back over the dimple it left, with bump and motion ticks | a snowflake on the left wart's cap |
| pl-frt-5 | Barrow Peephole | hue-shifted stone with specks, lichen and a crack, lit grain, a knot and a split, iron hinge straps, frost ferns, icicles, snow drift on the threshold | peephole eyes read as lights: now they have amber lower lids so they read as peeking | ring pull on its hook |
| pl-frt-6 | Barrow Icecrown | faceted points (shaded right face), hairline cracks and rime specks, freckled throat sac with a stretch crease | tiny gems: now cut diamonds with a glint, a dark lower facet and frost prongs (perch: 5x7 centre gem, 3x5 side gems) | a fly frozen in the tallest point |
| pl-cnd-1 | Crag Quill | lit barb ridges, darker condor margin toward the tip, two more barb splits, violet sheen glints, twine knot | afterfeather wisps read as legs: now it is planted like a spear in a cracked crag stone with one downy tuft at the base (perch too) | red war paint under the eyes |
| pl-cnd-2 | Ledge Feather | downy broken barbs at the vane base, lit barb edges, blue-teal sheen glints, broken strata, joints, a crack and lichen on the ledge | perch ledge was a few px tall: now a 12 px cliff block with a sand top, strata, a crack and a gold vein; the yard ledge is rougher and taller too | a scrap of cream fluff left on the ledge top |
| pl-cnd-3 | Updraft Fluff | warmer plum-peach-cream ramp, a dark crease between tufts, lit strand flecks, tongue in the "wow", lift streaks | (none listed) tufts now read one by one | a loose wisp blowing off behind; the caught seed has a green sprout |
| pl-cnd-4 | Talon Clutch | scaly shank with scute rims, lit ridges on the talons, lit scute rings on the toes, lichen and grit on the rock | pad read as a round creature on a rock: now a flatter pad with a scaly shank rising to a dark condor feather cuff, so it reads as a foot (perch: pad lightened so the face reads) | a down feather snagged between the middle toes; a chip breaking off the rock |

Weak spots left: Frostwart's empty dimple is only a few px; Thawdrop's ice shard and Icecrown's frozen fly are
faint, by design; Talon Clutch's feather cuff can read a little like a hat on the perch; Crag Quill's rachis is
low contrast on the lit side.
