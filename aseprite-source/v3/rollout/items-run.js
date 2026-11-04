export const meta = {
  name: 'items-rollout',
  description: 'Hearth Pop rework of 64x64 items: Sonnet drafts Lua per 24-item chunk, Opus finishes in groups of 4 (single pass, no fix round)',
  phases: [{ title: 'Draft' }, { title: 'Draw' }],
}
const items = args.items.map(x => { const [folder, name] = x.split('/'); return { folder, name } })
const tag = args.tag
const CH = 24, GR = 4
const chunks = []
for (let i = 0; i < items.length; i += CH) chunks.push(items.slice(i, i + CH))
const OUT = '/home/user/gnome-venture/aseprite-source/v3/items/final'
const label = (it) => `${it.folder}/${it.name}`
const draftPrompt = (chunk, ci) => `Write FIRST-DRAFT Lua scripts for Aseprite 1.3.18 using the v3 lib (an Opus artist redraws them after). Repo /home/user/gnome-venture/aseprite-source. Read art-style-guide-v3.md (sections 3, 5.1), v3/lib/README.md, and finished examples v3/items/batch1/*.lua + batch2/*.lua (shared helpers batch1/_h.lua, batch2/_b2.lua; reuse by dofile, never edit shared files). Old art for reference only: /home/user/gnome-venture/game/assets/img/<folder>/<name>.png (view upscaled to learn what the item is).
Draw these ${chunk.length} items, 64x64, slim, 1px ink outline, one small quirk each, each visually unique (no recolour templates): ${chunk.map(label).join(', ')}.
Rules: '-seed' items show the actual seed(s) on a small leaf scrap with a tiny sprout showing the plant's leaf (see batch2/*-seed.lua); 'ico-' items are bolder inline icons (3px min parts); 'broken-' items show the intact drawing plus a real gap/crack, chip, splinter; 'stage-' items are one growth step of a series.
Outputs: ${OUT}/<folder>/<name>.lua, .png, .aseprite (mkdir -p). Run each with: /tmp/aseq/squashfs-root/AppRun -b --script-param out=${OUT}/<folder>/ --script <file> (extract AppImage into /tmp/aseq if missing; if another agent is extracting, wait and retry). Put your helper in ${OUT}/_helpers/_d${tag}${ci}.lua. HP.assertClean must pass. Make ONE contact sheet of your chunk in scratchpad subfolder /tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad/d${tag}${ci}/ , view it, fix only obvious failures. Reply in under 40 words: counts pass/fail.`
const artPrompt = (g, ci, gi) => `You are the pixel ARTIST for Gnome Venture. Repo /home/user/gnome-venture/aseprite-source. Style guide art-style-guide-v3.md (read sections 3 and 5.1 fully). Target quality references: v3/items/batch1/turnip.lua, rambutan.lua, banana-seed.lua, v3/items/batch2/carrot.lua, carrot-seed.lua, pumpkin-seed.lua (+ .png) and libs v3/lib/hp.lua, hpx.lua (per-pixel lighting), README.md. Colour not capped; hard pixels only. Run: /tmp/aseq/squashfs-root/AppRun -b --script-param out=<dir>/ --script f.lua (extract AppImage in aseprite-source to /tmp/aseq if missing; wait and retry if another agent is extracting).
Your ${g.length} items (64x64, folder/name fixed): ${g.map(label).join(', ')}. Sonnet drafts exist at ${OUT}/<folder>/<name>.lua (+png). Old art: /home/user/gnome-venture/game/assets/img/<folder>/<name>.png (view upscaled to learn what the item is, then draw it NEW, do not trace).
Requirements: SLIM proportions (not fat), 5-6 tone ramps, material cues (grain, bevel, specular, waxy bloom, veins, weave, twist), ambient shading where parts meet, 1px ink outline, one small quirk each, centred with a >=5px margin, each of your items structurally different. '-seed' items: real seed(s) on a torn leaf scrap with a sprout showing the plant's leaf shape, polished as much as a crop. 'ico-' icons: bolder, 3px min parts, must read at 16px. 'broken-' = intact drawing + real damage + chip. Single pass, NO fix round (cost cut): render once, view one x6 contact image of your items (own scratchpad subfolder /tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad/a${tag}${ci}_${gi}/ , Read it) only to catch outright failures (unrecognisable, wrong size), fix those, and finish. Final files overwrite drafts: ${OUT}/<folder>/<name>.lua/.png/.aseprite. HP.assertClean must pass. Never edit shared files; your helper copy goes in ${OUT}/_helpers/_a${tag}${ci}_${gi}.lua. Reply under 60 words: any item you consider weak.`
const results = await parallel(chunks.map((chunk, ci) => async () => {
  if (!args.skipDraft) await agent(draftPrompt(chunk, ci), { label: `draft:${tag}${ci}`, phase: 'Draft', model: 'sonnet' })
  const groups = []
  for (let i = 0; i < chunk.length; i += GR) groups.push(chunk.slice(i, i + GR))
  return await parallel(groups.map((g, gi) => () => agent(artPrompt(g, ci, gi), { label: `art:${g[0].name}`, phase: 'Draw', model: 'opus' }).then(r => ({ g: g.map(x => x.name), r }))))
}))
return { chunks: results.length, notes: results.flat().map(x => x && x.r && String(x.r).slice(0, 200)) }
