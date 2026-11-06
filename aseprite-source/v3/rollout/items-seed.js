export const meta = {
  name: 'items-seed',
  description: 'Hybrid seed run: agent writes only a param file per seed for items/seedgen/seedgen.lua, one bash call per group',
  phases: [{ title: 'Draw' }],
}
const items = args.items.map(x => { const [folder, name] = x.split('/'); return { folder, name } })
const tag = args.tag
const GR = args.group || 6
const ROOT = '/home/user/gnome-venture/aseprite-source/v3/items'
const OUT = args.outDir || ROOT + '/final'
const SP = '/tmp/claude-0/-home-user-gnome-venture/24dbc14e-ae34-540a-ac1a-cc6317049307/scratchpad'
const label = (it) => `${it.folder}/${it.name}`
const prompt = (g, gi) => `You are the pixel artist for Gnome Venture. Make ${g.length} seed icons (64x64) by writing ONE tiny Lua PARAM file per item for the generator ${ROOT}/seedgen/seedgen.lua. Do NOT read any other file. Items: ${g.map(label).join(', ')}.
Each seed shows 2-4 REAL seeds of that plant (true size, shape, colour, markings) on a torn leaf scrap in that plant's leaf colour/shape, one seed split with a sprout showing the plant's true first leaves. Use your own knowledge of the plant; make every item look clearly different from the others (colours, seed shape/size, leaf scrap shape, sprout type, markings, quirk).
Param file format (write to ${OUT}/<folder>/<name>.lua, first line a comment "-- <name> (seed ${tag}_${gi})"):
dofile([[${ROOT}/seedgen/seedgen.lua]])({
  name="<name>", dir=[[${ROOT}]],
  seed={6 hex dark->light}, leaf={6 hex}, sleaf={6 hex fresher young-leaf}, stem={5 hex: 3 stem tones then 2 greener}, root={3 hex cream tones} (last two optional),
  vein="#hex", gloss="#hex", cool="#hex", red="#hex margin tint",
  sl=<seed length mult 0.5-1.4>, sw=<seed width mult 0.6-1.3>, taper=<0 round .. 0.4 teardrop>, drop={4} or {4,1} (remove seeds; never 3; descending),
  marks="pits"|"spots"|"stripes"|"none", markc="#hex",
  scrap={ax,ay,cx,cy,bx,by} (leaf scrap bezier; default {7,55,28,52,57,40}), scrapW=<6.3 default half-width>, scrapExp=<0.72; higher = blunter>,
  sprout="pair"|"blades"|"trio"|"single", leafw=<3.6>,
  quirk="hat" (empty seed coat on a leaf tip) or "none",
  extra=function(ctx) ... end  -- OPTIONAL custom unique quirk: ctx.c canvas, ctx.G, ctx.X, ctx.K; paint a few pixels with ctx.c:put(x,y,"#hex",{r={name="q"}}); sprout leaves are around y 3-22, scrap y 40-58.
})
Ramps are 6 tones dark->light (e.g. seed {"#3a1a1e","#62262a","#8c3c32","#b45c3c","#d68650","#f0b878"}). Colours saturated, cool-violet shadows, warm lights; no pure black/white.
Do it in ONE bash call: write all ${g.length} files with heredocs (mkdir -p), run each with /tmp/aseq/squashfs-root/AppRun -b --script-param out=${OUT}/<folder>/ --script <file> (it writes .png/.aseprite there), and build one 3x contact PNG of the results in ${SP}/s${tag}_${gi}/ with PIL. Then Read that PNG once and fix only outright failures (an item must be recognisable; assertClean must pass), at most one more bash call. Never edit shared files. Reply under 40 words: weak items.`
const groups = []
for (let i = 0; i < items.length; i += GR) groups.push(items.slice(i, i + GR))
const res = await parallel(groups.map((g, gi) => () => agent(prompt(g, gi), { label: `seed:${g[0].name}`, phase: 'Draw', model: args.artModel || 'sonnet', effort: args.artEffort || 'medium' })))
return { groups: res.length, notes: res.map(r => r && String(r).slice(0, 200)) }
