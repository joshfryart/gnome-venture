export const meta = {
  name: 'items-gnome',
  description: 'Sonnet medium test: redraw the 2.5D player gnome as a recolourable layered rig, compare to Opus rig',
  phases: [{ title: 'Draw' }],
}
const V3 = '/home/user/gnome-venture/aseprite-source/v3'
const OUT = V3 + '/' + (args.out || 'hybrid-gnome')
const SP = '/tmp/claude-0/-home-user-gnome-venture/902950b7-6fde-51ce-869f-581deb60691a/scratchpad'
const p = `You are the pixel artist for Gnome Venture (Aseprite 1.3.18 + Lua), repo /home/user/gnome-venture/aseprite-source. Hard pixels only, light upper-left, cool-violet shadows, warm lights, 1px ink outline #2b1c26, 4 tones per material. Lib API: ${V3}/lib/CHEATSHEET.md.
TASK: make a NEW player gnome 2.5D model (your own design, do NOT trace) that works as the existing recolourable rig: read ${V3}/models/rig/README.md and rig.json, and the structure of ${V3}/models/gnome-player.lua and ${V3}/models/rig/gnome-rig.lua (read those three only, plus the CHEATSHEET). Same contract: 64x80 cell, 3/4 top-down, feet baseline y=70 centred x=32, 6 frames (idle 2 + walk 4) as a 384x80 strip, chunky head about 45% of height, tiny limbs. Tint layers (hat, tunic, scarf, skin, beard, boots, trim) must be recolourable through the marker-grey mapping so the same recolor.py presets and hex colours work; eyes must keep contrast on DARK skin (cream disc + ink pupil + glint, not skin-toned). Make it clearly different from the old gnome in silhouette details (e.g. different hat shape, beard shape, a quirk) but the same rig layers and order.
Work in ${OUT}/ (mkdir -p; copy rig files there, never edit shared files). Produce the 10 layer PNGs, the .aseprite, and a recolour proof sheet at ${OUT}/proof.png (4 colour variants incl. one dark skin, frame 1 at x4, via a copy of recolor.py) plus a side-by-side of the OLD gnome vs NEW at x4 in ${SP}/${args.out || 'pgnome'}/. Run Aseprite with /tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script f.lua. HP.assertClean must pass; layers must be disjoint and stack back exactly (use the verify idea). Keep tool calls minimal; Read the proof once and also view one walk frame; fix only outright failures; stop. Reply under 60 words: weak spots.`
const r = await agent(p, { label: 'gnome-rig', phase: 'Draw', model: args.model || 'sonnet', effort: args.effort || 'medium' })
return { note: String(r).slice(0, 400) }
