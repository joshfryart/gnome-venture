export const meta = {
  name: 'items-npc',
  description: 'Lean 2.5D villager sprite run: Opus medium, no draft, cheat sheet + one exemplar, one agent per group',
  phases: [{ title: 'Draw' }],
}
const V3 = '/home/user/gnome-venture/aseprite-source/v3'
const OUT = V3 + '/' + (args.out || 'sprites-test')
const SP = '/tmp/claude-0/-home-user-gnome-venture/902950b7-6fde-51ce-869f-581deb60691a/scratchpad'
const GR = args.group || 2
const prompt = (g, gi) => `You are the pixel ARTIST for Gnome Venture (Aseprite 1.3.18 + Lua), repo /home/user/gnome-venture/aseprite-source. Read ONLY ${V3}/lib/CHEATSHEET.md and ONE exemplar for structure/part helpers: ${V3}/hybrid-gnome-opus/gnome-opus.lua (do not copy its look). No other files.
Draw ${g.length} villager SPRITES (2.5D, 3/4 top-down: you see the top of the head and part of the front): ${g.join(', ')}. Learn who each is from the old art (view upscaled, then draw NEW, do not trace): /home/user/gnome-venture/game/assets/img/ph/npc-<name>.png
Spec each: canvas 64x96 transparent, FEET baseline y=90 centred x=32, figure <=84 px tall, chunky head ~45% of height, tiny limbs, 4 tones per material, hard pixels, light upper-left, cool-violet shadows, 1px ink outline #2b1c26, small two-tone stone ground shadow under the feet, one species/trait-true silhouette feature and ONE prop/quirk. Species must read from the silhouette alone; every villager structurally unique. ${args.note || ""} Single standing pose. HP.assertClean must pass.
Outputs: ${OUT}/<name>.lua/.png/.aseprite named npc-<name> (mkdir -p; run with /tmp/aseq/squashfs-root/AppRun -b --script-param out=${OUT}/ --script f.lua). Each .lua self-contained, first line "-- npc-<name> (sprite ${args.tag}_${gi})". ONE bash call writes+runs all and builds a 4x contact PNG in ${SP}/n${args.tag}_${gi}/ (PIL, nearest). Read it once, fix only outright failures (one more bash call max). Never edit shared files. Reply under 40 words: weak items.`
const groups = []
for (let i = 0; i < args.items.length; i += GR) groups.push(args.items.slice(i, i + GR))
const res = await parallel(groups.map((g, gi) => () => agent(prompt(g, gi), { label: `npc:${g[0]}`, phase: 'Draw', model: args.model || 'opus', effort: args.effort || 'medium' })))
return { groups: res.length, notes: res.map(r => r && String(r).slice(0, 200)) }
