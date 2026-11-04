export const meta = {
  name: 'items-here',
  description: 'Lean Opus medium: real Here scenes (480x270) replacing the live placeholders, one agent per scene, layout JSON as contract',
  phases: [{ title: 'Draw' }],
}
const V3 = '/home/user/gnome-venture/aseprite-source/v3'
const REPO = '/home/user/gnome-venture'
const OUT = V3 + '/' + (args.out || 'here')
const SP = '/tmp/claude-0/-home-user-gnome-venture/902950b7-6fde-51ce-869f-581deb60691a/scratchpad'
const prompt = (s) => `You are the pixel ARTIST for Gnome Venture (Aseprite 1.3.18 + Lua), repo ${REPO}/aseprite-source. Style essentials: hard pixels only (no semi-transparency, dither, pure black/white); light from upper left, shade lower right; cool-violet shadows, warm-yellow lights; ONE small charming quirk/storyline; speckled leaf texture, tile courses on roofs, bark grain. Read ONLY: ${V3}/lib/CHEATSHEET.md (API; scene helpers c:bands, c:stripes, c:terrain, c:cloud, c:rim, c:edgeIn, c:groundShadow are in ${V3}/lib/README.md section on scenes: read just that part), the brief ${REPO}/claude/art-brief-here.md, ONE structure exemplar ${V3}/scenes/home-cottage.lua, and the layout JSON for your key (run: python3 -c "import json;print(json.dumps(json.load(open('${REPO}/game/includes/data/here_layouts.json'))['${s.key}'],indent=0))"). View the live placeholder ${REPO}/game/assets/img/scenes/here-${s.key}.png (upscaled) to see where every slot sits. Do not look at other scenes.
TASK: draw the real "Here" picture for key "${s.key}": ${s.desc}
Output exactly the layout w x h (480x270) to ${OUT}/here-${s.key}.lua/.png/.aseprite (mkdir -p; run with /tmp/aseq/squashfs-root/AppRun -b --script-param out=${OUT}/ --script f.lua). Rules: NO ink outline on landscape (c:finish{outline=false}); foreground and hero objects get a 1px dark edge in their own darker tone; 3-4 depth planes (sky in 4 flat bands with a sun and puff clouds, far hills low contrast, mid ground, big foreground); dense and alive, no empty ground (every ground area has a job: path, litter, moss, stones, flowers); 2-3 hero landmarks and 8+ small vignettes; NO people or animals painted in (villagers are sprites). LAYOUT CONTRACT: horizon at the layout's y; the 8 exit anchors each get a path stub that visibly leaves the picture there and ends in a clear patch (no detail inside r 30 of the anchor); every spot is drawn as its named object centred on its dot; every stand point has 28+ px of flat plain ground around it; keep all of this exactly where the JSON says. HP.assertClean must pass.
Also verify by compositing your PNG with the slot dots from the JSON (PIL, 2x) into ${SP}/h_${s.key}/check.png and Read it once; fix only outright failures (a slot hidden or an object far from its dot); one more bash call max. Never edit shared files. Reply under 40 words: weak spots.`
const scenes = args.scenes
const res = await parallel(scenes.map(s => () => agent(prompt(s), { label: `here:${s.key}`, phase: 'Draw', model: args.model || 'opus', effort: args.effort || 'medium' })))
return { notes: res.map(r => r && String(r).slice(0, 240)) }
