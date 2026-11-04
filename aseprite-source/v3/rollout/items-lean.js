export const meta = {
  name: 'items-lean',
  description: 'Lean Hearth Pop item run: no draft step, one art agent per group, cheat sheet only',
  phases: [{ title: 'Draw' }],
}
const items = args.items.map(x => { const [folder, name] = x.split('/'); return { folder, name } })
const tag = args.tag
const GR = args.group || 3
const OUT = args.outDir || '/home/user/gnome-venture/aseprite-source/v3/items/final'
const SP = '/tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad'
const label = (it) => `${it.folder}/${it.name}`
const prompt = (g, gi) => `You are the pixel ARTIST for Gnome Venture (Aseprite 1.3.18 + Lua). Repo /home/user/gnome-venture/aseprite-source. Read ONLY: v3/lib/CHEATSHEET.md and the one exemplar ${args.exemplar ? args.exemplar + ' (use this instead of the one the cheat sheet names)' : 'it names'}. Do not read the style guide, README or other items.
Draw these ${g.length} items, 64x64, ink-outlined, each structurally unique: ${g.map(label).join(', ')}. Old art for reference only (view upscaled to learn what the item is, then draw NEW): /home/user/gnome-venture/game/assets/img/<folder>/<name>.png
Outputs: ${OUT}/<folder>/<name>.lua/.png/.aseprite (mkdir -p; run with --script-param out=${OUT}/<folder>/). Each .lua must be self-contained and start with a comment line "-- <name> (lean ${tag}_${gi})". Contact sheet only in ${SP}/l${tag}_${gi}/. Never edit or delete shared files. Single pass. Reply under 50 words: weak items.`
const groups = []
for (let i = 0; i < items.length; i += GR) groups.push(items.slice(i, i + GR))
const res = await parallel(groups.map((g, gi) => () => agent(prompt(g, gi), { label: `lean:${g[0].name}`, phase: 'Draw', model: args.artModel || 'sonnet', effort: args.artEffort || 'high' })))
return { groups: res.length, notes: res.map(r => r && String(r).slice(0, 200)) }
