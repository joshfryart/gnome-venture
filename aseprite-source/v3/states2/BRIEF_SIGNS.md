# Opus pass on the BUILD signs (empty-plot state) of the garden buildings

CONTEXT: In a cosy gnome garden game, each of 16 buildings has a not-yet-bought state: a cleared plot with a small sign that says BUILD. A first pass exists (4-frame animated strips). Your job is a craft pass on JUST the empty-plot state of the buildings assigned to you: better, more legible, more charming, more distinct signs, and a plot that reads as cleared ground.

READ FIRST
- The finished first-pass art: /home/user/gnome-venture/aseprite-source/v3/states2/<b>/<b>-sheet.png (view with the Read tool) and the script /home/user/gnome-venture/aseprite-source/v3/states2/<b>.lua (read the empty-state code and how the file is organised). Also view /tmp/ase/out/garden-patch6.png to see the scene they live in, and the shared brief /tmp/ase/states2/BRIEF.md (canvas sizes, anchor (W/2, H-10), style rules; the empty state is 4 frames, a horizontal strip 4W x H).
- Art guide: /home/user/gnome-venture/aseprite-source/v3/art-style-guide-v3.md (hard pixels only; no dither, gradients, semi-transparency; 1 px warm ink outline #2b1c26; light from the upper left; hue-shifted ramps; no pure black or white; stitch is a spice) and lib docs /home/user/gnome-venture/aseprite-source/v3/lib/README.md.
- The shared lettering module /tmp/ase/states2/signfont.lua: the word BUILD in a 3x5 font, 19 px wide. ALL signs must use it (so the game has one hand-lettering style). Choose letter colour and an optional 1 px drop shadow per sign for strong contrast on the plate (letters light on dark plate, or dark ink on a pale plate; contrast must be obvious at 1x zoom).

WHAT TO IMPROVE (per building)
1. LEGIBILITY: BUILD must be readable at 1x (native pixels) and at 3x, never crossed by outlines, shadows, stakes, flowers or the sign's own mount. Give the lettering a clean plate with at least a 2 px margin around the word.
2. DISTINCT SIGNS: each building keeps its own sign design from the table below, but make each a real small piece of craft: a plate with material texture (wood grain, chalk smudges, leaf veins, rope fibres, enamel rim), depth (a visible thickness or shadow edge), a believable mount (post, rope loop, chain, peg, stake, boulder strap), hardware (nails, screws, ties), and an icon of the building that is clear at a glance (3 to 5 colours, no mush). No two signs may share a silhouette or mount. Sign size: about 26 to 34 px wide and 14 to 24 px tall plate, with its mount; it should be the focal point of the empty state without hiding the plot.
3. THE PLOT: it must read as cleared ground, flush with the surroundings: packed earth in 3 tones with a darker rim where it was cut, four corner stakes joined by a string line (string in a light colour, at least 1 px wide, visible), a few tufts or pebbles and one or two flowers suited to the building's world. NOT a raised box, trough, log or planter (the first pass looked like that for some). Footprint roughly the size of the level-1 building's footprint so the player sees where it will go.
4. ANIMATION: 4 frames, looping, tasteful: the sign sways or flutters by 1 px (or the hanging parts swing), and one small life detail (leaf blow-by, bird hop, dust puff, flag flutter) per the table. The plate and lettering must NOT jitter so much that BUILD is hard to read: letters move at most 1 px between frames.
5. Keep the same canvas size, anchor point (W/2, H-10) and file names as the first pass, with the cool lower-right cast shadow where it applies. No "!" badge on this state.

SIGN DESIGNS (keep each building's concept; refine freely)
kitchen: chalkboard on a small A-frame easel, a tiny red pot icon, chalk dust
beehive: hexagonal honeycomb plaque hanging from a bent iron bracket, a bee icon
greenhouse: big leaf-shaped board on a stake, a seedling icon, leaf veins
tailor: wooden tag board dangling by a thread from a crossbar post, a spool and needle icon, a little cloth flag
tool_shed: plank sign nailed on a post with crossed hammer and saw, a few nails
compost_bin: cardboard crate-lid sign propped on a stake, a leaf and an apple-core icon
rain_barrel: board hung from a rope loop on a gallows-style post, a water-drop icon, a drip
root_cellar: arrow-shaped sign stuck in the soil pointing down, a carrot icon
worm_farm: tiny sign held up by a smiling pink worm that pokes out of the ground
ladybird_lodge: leaf-shaped sign with a ladybird perched on its edge
snail_jar: sign carried on a snail's shell next to the plot (the snail is the mount), a jar icon
frog_pond: lily-pad-shaped sign floating on a puddle-shaped patch of muddy ground (the plot is a dry cracked mud flat with a puddle outline), a frog icon
quail_coop: egg-shaped sign on a short stick, speckles, a tiny nest icon
silk_shelf: spool-shaped sign wound with white silk thread, a mulberry leaf icon
tortoise_run: sign strapped to a boulder with leather straps, a tortoise-shell icon
butterfly_bush: pennant banner strung between two bare twigs, a butterfly icon

OUTPUT: edit ONLY the empty-state code in /tmp/ase/states2/<b>.lua (copy it there first from the repo path if it has been overwritten; your own working copies live in /tmp/ase/states2/<b>_signs.lua so nothing collides: write your new script as /tmp/ase/states2/<b>_signs.lua that draws ONLY the empty state strip), and run
`/tmp/ase/squashfs-root/AppRun -b --script-param out=/tmp/ase/states2/<b>/ --script /tmp/ase/states2/<b>_signs.lua`
It must write /tmp/ase/states2/<b>/<b>-empty.png (strip 4W x H, scale 1) and <b>-empty.aseprite (tag "empty"), plus a review image /tmp/ase/states2/<b>/<b>-signs-sheet.png: the 4 frames at scale 4 on a light-green background in one row, with a second row showing frame 1 at scale 1 and scale 2 (build with Python PIL, Image.NEAREST). Do not overwrite the other states' PNGs. Check: view the sheet with the Read tool, confirm BUILD reads at 1x, signs differ from each other across your buildings, alpha only 0 or 255. Loop up to 5 rounds per building, then a final look at everything. Do NOT touch any file under /home/user/gnome-venture. Do NOT touch other agents' buildings. Finish with ONE short line per building: done or what is weak.
