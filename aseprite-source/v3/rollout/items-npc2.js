export const meta = {
  name: 'items-npc2',
  description: 'Creature villagers: matching 2.5D idle sprite (4 frames) + 80x100 portrait per NPC, Opus medium, lean, 2 NPCs per agent',
  phases: [{ title: 'Draw' }],
}
const V3 = '/home/user/gnome-venture/aseprite-source/v3'
const OUT = V3 + '/' + (args.out || 'npc')
const SP = '/tmp/claude-0/-home-user-gnome-venture/902950b7-6fde-51ce-869f-581deb60691a/scratchpad'
const GR = args.group || 2
const prompt = (g, gi) => `You are the pixel ARTIST for Gnome Venture (Aseprite 1.3.18 + Lua), repo /home/user/gnome-venture/aseprite-source. Read ONLY ${V3}/lib/CHEATSHEET.md and these two structure exemplars (do not copy their look): sprite ${V3}/hybrid-gnome-opus/gnome-opus.lua, portrait ${V3}/portraits/folk-bumblebee.lua.
For EACH villager of: ${g.join(', ')} draw ONE character TWICE, same design, same colours: a 2.5D SPRITE and a PORTRAIT. View the old art first (upscaled): /home/user/gnome-venture/game/assets/img/ph/npc-<name>.png to learn name, mood and role.
NO HUMANS. Every villager is a creature (animal, bird, insect, reptile, amphibian, fish, mushroom-folk...) or a gnome clearly different from the player gnome (the player is a white-bearded gnome in a red pointy hat and blue tunic: change hat shape, beard, build, palette). If the old art is human, redesign as a fitting creature that keeps the name and mood (e.g. Auntie Mossbead = elder turtle). If it is already a creature, keep that species. Each villager is structurally unique (silhouette, species, prop).
SPRITE spec: 64x96 cell, 3/4 top-down (you see the top of the head and part of the front), FEET baseline y=90 centred x=32, figure <=84 px tall, chunky head ~45% of height, tiny limbs, 4 tones per material, 1px ink outline #2b1c26, small two-tone stone ground shadow, ONE prop/quirk. IDLE ANIMATION, 4 frames in a 256x96 strip, small and calm: frame1 base, frame2 body 1px lower (breath) with hat/ears/tail/prop settling, frame3 base, frame4 a blink or tiny ear/tail/prop twitch. Feet and shadow never move. Files ${OUT}/sprites/npc-<name>.lua/.png/.aseprite (png = the 256x96 strip, aseprite has the 4 frames and an "idle" tag).
PORTRAIT spec: 80x100, bleeds off the bottom, head and shoulders, head 38-44 px wide; locked eyes (5x5 cream disc with cut corners, 3x3 ink pupil, 1px glint upper-left) adapted to the species; a designed nose/snout/beak; backdrop disc 62 px in the villager's colour with a 2px shade crescent lower-right and 1px outline in its own darker tone (never ink); outside the disc transparent; 1px ink outline #2b1c26 on the figure; the prop or companion in frame. Files ${OUT}/portraits/npc-<name>.lua/.png/.aseprite.
File names MUST start with "npc-". Each .lua self-contained, first line "-- npc-<name> <sprite|portrait> (npc2 ${args.tag}_${gi}) species: <species>". Hard pixels, light upper-left, cool-violet shadows, warm lights, no pure black/white; HP.assertClean must pass. Run with /tmp/aseq/squashfs-root/AppRun -b --script-param out=${OUT}/<sprites|portraits>/ --script f.lua. Use ONE bash call to write+run everything and build a 4x contact PNG (sprite frame 1 + portrait per villager) in ${SP}/n2${args.tag}_${gi}/ (PIL, nearest). Read it once, fix only outright failures (one more bash call max). Never edit shared files. Reply under 40 words: species chosen per villager and weak items.`
const groups = []
for (let i = 0; i < args.items.length; i += GR) groups.push(args.items.slice(i, i + GR))
const res = await parallel(groups.map((g, gi) => () => agent(prompt(g, gi), { label: `npc2:${g[0]}`, phase: 'Draw', model: args.model || 'opus', effort: args.effort || 'medium' })))
return { groups: res.length, notes: res.map(r => r && String(r).slice(0, 220)) }
