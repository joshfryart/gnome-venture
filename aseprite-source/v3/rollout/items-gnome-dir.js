export const meta = {
  name: 'items-gnome-dir',
  description: 'Opus medium: directional (front/back/side) walk cycles for the recolourable player gnome rig',
  phases: [{ title: 'Draw' }],
}
const V3 = '/home/user/gnome-venture/aseprite-source/v3'
const SRC = V3 + '/hybrid-gnome-opus'
const OUT = V3 + '/gnome-dir'
const SP = '/tmp/claude-0/-home-user-gnome-venture/902950b7-6fde-51ce-869f-581deb60691a/scratchpad'
const p = `You are the pixel ARTIST for Gnome Venture (Aseprite 1.3.18 + Lua). Hard pixels, light upper-left, 1px ink outline #2b1c26, 4 tones per material. Read ONLY: ${V3}/lib/CHEATSHEET.md, ${SRC}/README.md, ${SRC}/gnome-opus.lua (the approved front-facing player gnome and its layer split / recolour contract: 64x80 cell, feet baseline y=70, x=32, 10 recolourable layers hat/tunic/scarf/skin/beard/boots/trim + fixed outline/face/shadow, marker-grey tint mapping, recolor.py). Do not read other files.
TASK: this gnome will walk around a tile map (tap a tile, it walks there), so it must TURN. Extend the SAME gnome (same hat, beard, tunic, scarf, boots, proportions, same colours/markers, same 10 layers) to 3 views: FRONT (existing facing-the-camera 3/4 view), BACK (we see the back of hat, back of the head with no face, the tunic back, the beard only as side wisps, the scarf from behind), SIDE (profile facing RIGHT; the left-facing view is made by code mirroring, so keep it symmetric-safe: nothing text-like). Each view: idle 2 frames + a smooth WALK cycle of 6 frames (contact, down, passing, contact, down, passing) with arm swing opposite to the legs, body bob 1px, hat tip and beard sway one frame late, boots visibly lifting, scarf tail trailing. Keep the foot baseline and x=32 stable so the sprite does not jitter between frames.
Outputs in ${OUT}/ (mkdir -p; never edit shared files): for each view V in front,back,side: layer strips ${OUT}/<V>-<layer>.png (8 frames x 64 px = 512x80; frames 1-2 idle, 3-8 walk) for all 10 layers and a composite ${OUT}/<V>.png, plus ${OUT}/gnome-dir.lua (the drawing script), a recolor copy that handles the 512-wide strips (recolor.py copy, args same as the old one) and a proof ${OUT}/proof.png: all 3 views, walk frames, default colours and one dark-skin recolour, x3. Layers must be disjoint and stack back to the composite exactly (verify, 0 px diff). HP.assertClean must pass. Run Aseprite with /tmp/aseq/squashfs-root/AppRun -b --script-param out=${OUT}/ --script f.lua. Keep tool calls few: write+run, build proof, Read it once, fix only outright failures (one more pass max). Reply under 60 words: weak spots.`
const r = await agent(p, { label: 'gnome-dir', phase: 'Draw', model: 'opus', effort: 'medium' })
return { note: String(r).slice(0, 400) }
