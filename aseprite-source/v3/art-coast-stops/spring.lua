-- spring.lua : "Spring" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua), re-cast for a chalk coast:
-- Right hero: a chalk cliff (bedding ledges, flint bands, a turf-and-thrift cap, kittiwakes on the ledges) with a
-- knapped-flint flushwork face set into it and a carved limestone gnome head; spring water arcs from its mouth into a
-- long granite trough, a second trickle runs from a seep in the chalk into a gnome's pail. The trough overflows into a
-- brook lined with watercress that runs down-left under a plank bridge on the road and spreads over the beach into
-- tide pools between barnacled rock ledges (bottom-left), on its way to the sea. Left: a flint well-head with a slate
-- roof, a gnome winding the bucket up, a herring gull on the ridge; a whitewashed cottage with a pantile roof and
-- ganseys on the line, wind-bent hawthorns. A gnome carries two pails on a yoke down the road, a stall sells flagons of
-- spring water and bunches of watercress, a gnome washes at the pools, another hauls a water cart.
-- Road's end: whitewashed fishermen's cottages and a little chapel against the sea. Yellow flag iris, thrift, campion.
-- Quirk: a grey seal pup in a red gnome hat sits in the trough, eyes shut, taking a shower under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 },
    clouds = { { 140, 44, 40 }, { 286, 32, 52 }, { 404, 60, 34 }, { 30, 84, 24 }, { 214, 78, 18 } },
    boats = { { 172, 97, 8 }, { 206, 95, 5 }, { 322, 99, 10 } }, stacks = { { 162, 101, 3, 8 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
local Wt = L.water
local GL = "#f2f8f0" -- water glint (not pure white)
local chalk = F.rp("#f6f2e2 #e2dfd0 #c6c4b6 #a0a09a #6c6e74")      -- warm cliff chalk
local flint = F.rp("#9aa2ae #6e7480 #50566a #3a3e50 #262a38")      -- knapped flint, blue-black
local lime = F.rp("#f4ecd4 #dccfae #bcac8a #94846a #5e5244")       -- dressed limestone
local brick = F.rp("#e48a68 #c0624a #9a4a3c #6e3430 #44222a")      -- voussoir brick
local seal = F.rp("#f4f0e2 #dcd8cc #b8b4ac #8a8486 #565058")       -- white-coat grey seal pup
local kale = F.rp("#d0dcd6 #a6bcbc #7e98a0 #5c7480 #3e5262")       -- glaucous sea-kale leaves
local cress = F.rp("#b8da7c #7cb04e #568c3c #3a6832 #244424")      -- watercress
local algae = F.rp("#a6c47a #7ea05a #5e7e48 #44603c #2e4430")      -- green seep stain
local gran = F.rp("#d2d2cc #aaaca8 #868a8a #626870 #40464e")       -- trough granite (warmer than L.stone)

---------------------------------------------------------------- far: the spring's own thread of water crossing the beach to the surf
F.depth(1)
do
  local pts = { { 184, 112 }, { 180, 110 }, { 184, 108 }, { 179, 106 } }
  for i = 1, #pts - 1 do line({ pts[i], pts[i + 1] }, 2):each(function(x, y) if y > F.SHORE_Y then px(x, y, (x + y) % 3 == 0 and L.sea.hi or "#a8d6dc") end end) end
end

---------------------------------------------------------------- back row: fishermen's cottages and a little chapel at the road's end
F.depth(1)
do
  local top, _, wall, roof = F.building{ x0 = 194, x1 = 228, yb = 126, wh = 13, rh = 10, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.window(201, 117, 205, 120, L.wall2) F.window(214, 117, 218, 120, L.wall2)
  hline(194, 228, 125, L.wall2.shade)
end
F.smoke(219, 97, 4, 1.1, 2)
do -- a whitewashed chapel with a slate roof and a bell-gable right of the road
  local wall = rect(254, 112, 278, 126)
  local roof = poly{ { 251, 113 }, { 266, 103 }, { 281, 113 } }
  local tower = rect(256, 96, 263, 112)
  local spire = poly{ { 255, 97 }, { 259, 84 }, { 264, 97 } }
  rimOf(union(wall, roof, tower, spire), L.tar)
  part(wall, L.plaster) part(tower, L.plaster, { nopop = true })
  part(roof, L.roof, { nopop = true }) F.courses(roof, 103, 2, 4, L.roof)
  part(spire, L.roof, { nopop = true }) F.courses(spire, 84, 2, 3, L.roof)
  fill(c:rrect(258, 99, 261, 104, 1), L.tar.deep) px(259, 101, L.gold.base) px(260, 101, L.gold.shade)
  px(259, 83, L.gold.base) px(259, 82, L.gold.hi)
  F.window(270, 116, 273, 120, L.wall2, true)
end
F.tree(300, 128, 22, 0)
F.fenceP(120, 132, 190, 127, 6)
F.depth(2)
F.tree(184, 150, 30, 2)
for i = 1, 16 do
  local x, y = 18 + floor(hash(i, 1, 36) * 200), 140 + floor(hash(i, 2, 36) * 22)
  if not F.roadM:has(x, y) and (x < 104 or x > 168) then F.marram(x, y, 3 + (y - 138) // 6) end
end

---------------------------------------------------------------- mid left: whitewashed cottage with a pantile roof, hawthorns, ganseys on the line
F.depth(2)
do
  local top, _, wall, roof = F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 16, wall = L.plaster, roof = L.roof2, chimney = true, noAttic = true, shingle = true, noFrame = true }
  F.pantile(roof, L.roof2, top - 16, 37)
  F.lichen(roof, .04, 38)
  F.window(30, 122, 35, 127, L.wall2) F.door(50, 124, 57, 135, L.wall2)
  hline(24, 70, 134, L.wall2.shade) hline(24, 70, 135, L.wall2.deep) -- a painted plinth
end
F.smoke(61, 88, 6, 1.4, 2)
F.tree(92, 150, 50, 0)
F.washing(70, 118, 91, 120, { { "shirt", L.accent }, { "sock", L.awnA }, { "shirt", L.wall2 } }, 3)
F.tree(160, 140, 40, 2)
F.tree(124, 146, 36, 1)

---------------------------------------------------------------- right hero: the chalk cliff
F.depth(2)
F.tree(452, 112, 40, 2) -- a hawthorn leaning over the cliff top
F.depth(3)
local mass = poly{ { 292, 212 }, { 294, 186 }, { 300, 166 }, { 306, 146 }, { 316, 132 }, { 328, 122 }, { 336, 112 },
  { 352, 106 }, { 370, 100 }, { 390, 95 }, { 410, 97 }, { 428, 93 }, { 446, 99 }, { 460, 104 }, { 474, 108 }, { 474, 212 } }
local face = rect(352, 132, 420, 192)
local blocks = { -- fallen chalk blocks at the foot (x, y, rx, ry, seed)
  { 300, 198, 14, 14, 46 }, { 330, 194, 18, 15, 48 }, { 446, 194, 22, 16, 47 }, { 466, 176, 10, 14, 45 } }
for _, b in ipairs(blocks) do
  local pts = {}
  for i = 0, 9 do
    local a = i / 10 * 2 * pi
    local k = .84 + .18 * hash(i, b[5], 3)
    pts[#pts + 1] = { b[1] + cos(a) * b[3] * k, b[2] + sin(a) * b[4] * k * (sin(a) < 0 and .8 or 1) }
  end
  b.m = poly(pts)
end
local rockM = mass:copy():add(face)
for _, b in ipairs(blocks) do rockM:add(b.m) end
F.shadowM(c:ellipse(382, 214, 94, 5))
rimOf(rockM, chalk)
-- top surface line of the cliff for each column
local topY = {}
mass:each(function(x, y) if not topY[x] or y < topY[x] then topY[x] = y end end)
local function wob(x) return floor(sin(x / 13) * 1.6 + sin(x / 5.3) * .7) end
local function vn(x, y, sd) -- smooth value noise
  local xi, yi = floor(x), floor(y)
  local xf, yf = x - xi, y - yi
  local u, v = xf * xf * (3 - 2 * xf), yf * yf * (3 - 2 * yf)
  local a, b, cc, d = hash(xi, yi, sd), hash(xi + 1, yi, sd), hash(xi, yi + 1, sd), hash(xi + 1, yi + 1, sd)
  return (a * (1 - u) + b * u) * (1 - v) + (cc * (1 - u) + d * u) * v
end
local function prof(x, y) return vn(x / 6, y / 46, 300) * .7 + vn(x / 2.5, y / 20, 303) * .3 end
mass:each(function(x, y)
  local d = y - topY[x]
  local g = prof(x, y)
  local slope = prof(x + 1, y) - prof(x - 1, y)
  local lt = (474 - x) / 180 * .4 - d / 90 * .3 + slope * 5 + (g - .5) * .35 - .06
  if d > 4 and d < 8 then lt = lt - .3 end -- the turf overhang's shadow
  local h = lt > .3 and chalk.hi or (lt > .0 and chalk.base or (lt > -.25 and chalk.shade or chalk.deep))
  local yy = y + wob(x)
  local band, bi = yy % 13, yy // 13
  local ledgeOn = vn(x / 9, bi, 301) > .5
  if ledgeOn and band == 0 then h = (lt > -.15) and chalk.hi or chalk.base
  elseif ledgeOn and band == 1 then h = (lt > .1) and chalk.shade or chalk.deep
  elseif ledgeOn and band == 2 and lt < .25 then h = chalk.shade end
  if band == 7 and hash(x // 7, bi, 302) < .6 then
    h = hash(x, y, 307) < .3 and flint.shade or flint.deep
  elseif band == 8 and hash(x // 7, bi, 302) < .6 and hash(x, y, 308) < .45 then
    h = flint.shade
  elseif band == 6 and hash(x // 7, bi, 302) < .6 and hash(x, y, 309) < .3 then
    h = chalk.deep
  end
  if ledgeOn == false and band > 2 and band < 6 and vn(x / 9, bi, 301) < .3 then h = (h == chalk.hi) and chalk.base or h end
  if hash(x, y, 304) < .015 then h = chalk.hi elseif hash(x, y, 305) < .015 then h = chalk.shade end
  if x >= 347 and x <= 425 and y >= 128 and h == chalk.hi then h = chalk.base end -- damp shade round the face
  if y > 202 then h = (hash(x, y, 306) < .5) and chalk.deep or chalk.shade end
  px(x, y, h)
end)
-- the spring line: green seep stains running down from wet bands in the chalk
for _, sp in ipairs({ { 316, 150, 30 }, { 338, 146, 20 }, { 428, 140, 44 }, { 444, 124, 30 }, { 460, 152, 34 }, { 304, 176, 22 } }) do
  local sx, sy, n = sp[1], sp[2], sp[3]
  px(sx, sy - 1, flint.edge) px(sx + 1, sy - 1, flint.deep)
  for t = 0, n do
    local x = sx + floor(sin(t / 6 + sx) * 1.2 + .5)
    local y = sy + t
    if mass:has(x, y) then
      local w = (t < n * .6) and 2 or 1
      px(x - 1, y, chalk.shade)
      px(x, y, t < 3 and algae.deep or (t % 4 == 0 and algae.hi or algae.base))
      if w == 2 then px(x + 1, y, algae.shade) end
    end
  end
end
-- fallen chalk blocks: faceted, lit upper left, flint nodules, orange lichen
for _, b in ipairs(blocks) do
  local off = hash(b[5], 1, 2) * 2 * pi
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local r = math.sqrt(nx * nx + ny * ny)
    local a = math.atan(ny, nx)
    local sec = floor(((a + off) % (2 * pi)) / (2 * pi) * 6)
    local ca = sec / 6 * 2 * pi + pi / 6 - off
    local lit
    if r < .4 then lit = .3 - (nx * .6 + ny * .8) * .4 else lit = -(cos(ca) * .6 + sin(ca) * .8) * math.min(1, r * 1.2) end
    lit = lit + (hash(x // 2, y // 2, b[5]) - .5) * .2
    local h = lit > .5 and chalk.hi or (lit > .05 and chalk.base or (lit > -.4 and chalk.shade or chalk.deep))
    if hash(x // 2, y // 2, b[5] + 4) < .02 then h = (lit > 0) and flint.base or flint.deep end
    px(x, y, h)
  end)
  c:edgeIn(b.m, chalk.edge)
  F.lichen(b.m, .025, b[5])
end
-- the turf cap: a ragged green lip with an overhang, thrift and campion on it, roots hanging down the face
for x, ty in pairs(topY) do
  local th = 3 + floor(hash(x // 2, 1, 310) * 3)
  for k = 0, th do
    local y = ty + k
    if mass:has(x, y) then
      local h = k == 0 and L.leaf.hi or (k < 2 and L.leaf.base or (k < th and L.leaf.shade or L.leaf.deep))
      if hash(x, y, 311) < .15 then h = L.marram.base end
      if k == 0 and (x - 400) < 0 and hash(x, 2, 311) < .3 then h = L.marram.hi end
      px(x, y, h)
    end
  end
  if hash(x, 3, 312) < .1 then for k = th + 1, th + 3 + floor(hash(x, 4, 312) * 4) do if mass:has(x, ty + k) then px(x, ty + k, k % 2 == 0 and L.soil.shade or L.leaf.deep) end end end
  if hash(x, 5, 313) < .25 then px(x, ty - 1, L.leaf.base) if hash(x, 6, 313) < .4 then px(x, ty - 2, L.marram.base) end end
end
for i = 0, 11 do
  local x = 322 + floor(hash(i, 1, 314) * 148)
  if topY[x] and (x < 380 or x > 410) then F.thrift(x, topY[x] + 2, i % 3 == 0) end
end
for i = 0, 6 do local x = 340 + floor(hash(i, 2, 314) * 120) if topY[x] then F.marram(x, topY[x] + 1, 5) end end
-- kittiwakes nesting on the ledges: white heads, grey backs, black wingtips, a dab of yellow bill
local function kitti(x, y, flip)
  local rows = { "..HHH....", ".HHeHHy..", "gGGGGHH..", "KgGGGGg..", ".KKggg..." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x - 4, y - 3, { H = L.gull.hi, G = L.gull.base, g = L.gull.shade, K = L.tar.deep, e = L.tar.deep, y = L.gold.base }, { rimCol = L.gull.edge })
  hline(x - 3, x + 3, y + 2, L.soil.shade) -- nest
end
for _, k in ipairs({ { 330, 141 }, { 342, 129, true }, { 436, 117 }, { 446, 129, true }, { 456, 141 }, { 318, 153, true }, { 432, 141 } }) do
  local yy = k[2] - (k[2] + wob(k[1])) % 12
  if mass:has(k[1], yy - 2) then kitti(k[1], yy - 2, k[3]) end
end
-- hart's-tongue ferns and sea-spleenwort in the damp crevices
for _, f in ipairs({ { 312, 176, 5 }, { 344, 164, 5 }, { 428, 160, 6 }, { 462, 150, 5 }, { 300, 186, 4 } }) do F.fern(f[1], f[2], f[3], L.fern) end

-- the flushwork face: a checker of knapped flint and limestone, limestone dressings
local panel = face:copy()
panel:each(function(x, y)
  local cx_, cy_ = (x - 352) // 6, (y - 132) // 5
  local kx, ky = (x - 352) % 6, (y - 132) % 5
  local h
  if (cx_ + cy_) % 2 == 0 then -- flint square: knapped nodules with glassy glints
    local v = hash(x // 2, y // 2, 320)
    h = v < .35 and flint.shade or (v < .7 and flint.deep or flint.base)
    if hash(x, y, 321) < .08 then h = flint.hi end
  else
    h = (kx == 0 or ky == 0) and lime.hi or ((kx == 5 or ky == 4) and lime.shade or lime.base)
    if hash(x, y, 322) < .06 then h = lime.shade end
  end
  if kx == 0 and (cx_ + cy_) % 2 == 0 then h = lime.deep end
  px(x, y, h)
end)
hline(352, 420, 132, lime.hi) hline(352, 420, 133, lime.base)
c:edgeIn(face, lime.edge)
local niche = c:rrect(362, 136, 410, 186, 20):clip(rect(362, 136, 410, 186))
fill(niche, flint.edge)
niche:each(function(x, y)
  if (x - 386) + (y - 160) < -14 then px(x, y, flint.deep) end
  if hash(x, y, 5) < .05 then px(x, y, flint.deep) end
  if y > 174 and hash(x // 2, y, 6) < .45 then px(x, y, algae.deep) end -- wet weed at the back of the niche
end)
c:edgeIn(niche, lime.edge)
-- voussoirs: alternating brick and limestone round the arch
do
  local ring = c:rrect(359, 133, 413, 189, 23):clip(rect(359, 133, 413, 186)):cut(c:rrect(362, 136, 410, 189, 20))
  ring:each(function(x, y)
    local a = math.atan(y - 160, x - 386)
    local seg = floor(a * 6) % 2
    local r = seg == 0 and brick or lime
    local outer = not ring:has(x - 1, y - 1)
    px(x, y, outer and r.hi or r.base)
    if not ring:has(x + 1, y + 1) then px(x, y, r.shade) end
  end)
end
-- algae streak and hanging turf over the face
for x = 352, 420 do if hash(x, 2, 8) < .5 then local n = 1 + floor(hash(x, 3, 8) * 3) for k = 0, n do px(x, 132 + k, k == 0 and L.leaf.hi or (k == n and L.leaf.deep or L.leaf.base)) end end end
-- the carved limestone gnome head spout
do
  local hx, hy = 386, 158
  local hat = poly{ { hx - 13, hy - 8 }, { hx + 13, hy - 8 }, { hx + 6, hy - 22 }, { hx + 11, hy - 26 }, { hx + 2, hy - 25 }, { hx - 6, hy - 18 } }
  local fc = c:rrect(hx - 11, hy - 9, hx + 11, hy + 3, 4)
  local beard = poly{ { hx - 12, hy - 1 }, { hx + 12, hy - 1 }, { hx + 9, hy + 12 }, { hx, hy + 18 }, { hx - 9, hy + 12 } }
  local head = union(hat, fc, beard)
  c:rim(head, lime.edge)
  part(fc, lime, { nopop = true }) part(beard, lime, { nopop = true }) part(hat, lime, { nopop = true })
  hline(hx - 13, hx + 13, hy - 8, lime.deep) hline(hx - 12, hx + 12, hy - 9, lime.hi)
  beard:each(function(x, y) if (x + 2 * y) % 5 == 0 and y > hy + 1 then px(x, y, lime.shade) end end)
  for _, ex in ipairs({ hx - 6, hx + 6 }) do px(ex - 2, hy - 4, lime.edge) px(ex - 1, hy - 3, lime.edge) px(ex, hy - 3, lime.edge) px(ex + 1, hy - 3, lime.edge) px(ex + 2, hy - 4, lime.edge) end
  local nose = c:ellipse(hx, hy - 1, 4, 3) c:rim(nose, lime.deep) part(nose, lime, { nopop = true }) px(hx - 2, hy - 3, lime.hi) px(hx - 1, hy - 3, lime.hi)
  px(hx - 9, hy - 1, lime.shade) px(hx + 9, hy - 1, lime.shade)
  -- a verdigris bronze pipe
  local pipe = rect(hx - 2, hy + 4, hx + 4, hy + 7) c:rim(pipe, L.tar.edge) fill(pipe, L.glass.shade) hline(hx - 2, hx + 4, hy + 4, L.glass.hi) fill(rect(hx + 3, hy + 5, hx + 4, hy + 6), Wt.deep)
  -- orange lichen on the hat, a green weed streak under the mouth, a limpet shell stuck on the beard (a gnome joke)
  F.lichen(hat, .05, 324)
  for y = hy + 8, hy + 15 do px(hx + 1, y, algae.shade) end
  px(hx - 5, hy + 6, L.awnB.shade) px(hx - 4, hy + 6, L.awnB.hi) px(hx - 5, hy + 5, L.awnB.hi)
end
-- the jet: an arc from the mouth down into the trough
local JX0, JY0 = 391, 164
local function jetY(x) local t = (x - JX0) / 18 return JY0 + floor(t * t * 22 + t * 2) end
for x = JX0, JX0 + 17 do
  local y0, y1 = jetY(x), jetY(x + 1)
  for y = y0, math.max(y0 + 3, y1 + 1) do px(x, y, Wt.base) px(x + 1, y, Wt.base) px(x + 2, y, Wt.shade) end
  px(x, y0, Wt.hi) px(x, y0 - 1, Wt.edge)
  if x % 3 == 0 then px(x + 1, y0 + 1, GL) end
end

---------------------------------------------------------------- the granite trough, its overflow and the seal pup
F.depth(3)
local TX0, TX1, TY = 350, 434, 190
do
  local topM = rect(TX0, TY, TX1, TY + 9)
  local front = rect(TX0, TY + 10, TX1, TY + 21)
  local inner = rect(TX0 + 4, TY + 2, TX1 - 4, TY + 7)
  rimOf(union(topM, front), gran)
  part(topM, gran, { nopop = true })
  topM:each(function(x, y) if y == TY then px(x, y, gran.hi) end end)
  part(front, gran) F.courses(front, TY + 10, 6, 21, gran)
  front:each(function(x, y) if x > 418 and y > TY + 11 then px(x, y, gran.shade) end if hash(x, y, 330) < .05 then px(x, y, gran.hi) end end)
  hline(TX0, TX1, TY + 10, gran.deep)
  F.water(inner, Wt, { step = 2 })
  -- the reflection of the flint face and the sky in the trough
  inner:each(function(x, y) if y <= TY + 3 and hash(x // 3, 0, 331) < .4 then px(x, y, Wt.shade) end end)
  -- green slime and cress at the foot of the trough, a carved date-stone (just a drop)
  for x = TX0, TX1 do if hash(x, 4, 12) < .45 then local n = floor(hash(x, 5, 12) * 4) for k = 0, n do px(x, TY + 21 - k, k == n and algae.hi or algae.base) end end end
  local ds = rect(386, TY + 12, 396, TY + 18) rimOf(ds, lime) fill(ds, lime.base) hline(386, 396, TY + 12, lime.hi)
  px(391, TY + 13, Wt.edge) hline(390, 392, TY + 14, Wt.base) hline(390, 392, TY + 15, Wt.shade) px(391, TY + 16, Wt.shade) px(390, TY + 14, Wt.hi)
end
-- the trickle from a seep in the chalk into a gnome's pail
do
  local cx, cy = 334, 168
  fill(line({ { cx - 3, cy - 5 }, { cx, cy } }, 2), chalk.edge)
  for y = cy - 6, cy + 4 do px(cx - 2 + floor((y - cy + 6) * .3), y + 1, algae.base) end
  for y = cy, 196 do px(cx + floor((y - cy) * .1), y, ((y // 2) % 2 == 0) and Wt.hi or Wt.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  local pail = poly{ { hx + 1, hy - 7 }, { hx + 10, hy - 7 }, { hx + 9, hy + 3 }, { hx + 2, hy + 3 } }
  c:rim(pail, L.tar.edge) part(pail, L.wall2) F.planks(pail, L.wall2, 3, true, 31)
  hline(hx + 1, hx + 10, hy - 5, L.iron.shade) hline(hx + 2, hx + 9, hy + 1, L.iron.shade)
  hline(hx + 2, hx + 9, hy - 7, Wt.hi) px(hx + 5, hy - 8, GL) px(hx + 8, hy - 9, Wt.hi)
  c:ellipse(hx + 5, hy - 12, 5, 4):edge():each(function(x, y) if y < hy - 11 then px(x, y, L.iron.base) end end)
end
-- QUIRK: a grey seal pup in a red gnome hat sitting in the trough, eyes shut, head up under the shower
do
  F.sprite({
    "............RR......",
    "...........RRr......",
    "..........HRRr......",
    ".........HRRRr......",
    "........HRRRRr......",
    ".......HRRRRRrr.....",
    "......HRRRRRRrr.....",
    ".....HRRRRRRRRrr....",
    "....bbbbbbbbbbbbb...",
    ".....lllSSSSSSSSs...",
    "....llSeeSSSSeeSSs..",
    "....lSSSSSSSSSSSSs..",
    "....lSSSSSwnnwSSSs..",
    ".....SSSSwSmmSwSs...",
    "......lSSSSSSSSs....",
    ".....lSSSSSSSSSSs...",
    "...FlSSSSSSSSSSSsF..",
    "..FFlSSSSSSSSSSSsFF.",
    "..F.lSSSSSSSSSSSs.F.",
  }, 394, 172, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.awnB.hi, S = seal.base, l = seal.hi, s = seal.shade,
    d = seal.deep, e = L.tar.deep, n = L.tar.deep, m = L.petal.shade, w = seal.shade, F = seal.shade }, { rimCol = seal.edge })
  -- a few darker dapples, the trough water lapping round it (the front lip is drawn over its belly)
  px(404, 192, seal.shade) px(410, 190, seal.shade) px(399, 189, seal.hi)
  for _, p in ipairs({ { 400, 183 }, { 408, 186 }, { 412, 183 }, { 403, 187 }, { 397, 185 }, { 409, 192 }, { 413, 188 } }) do px(p[1], p[2], seal.deep) end
  for _, p in ipairs({ { 402, 190 }, { 406, 189 }, { 411, 186 }, { 399, 186 } }) do px(p[1], p[2], seal.shade) end
  for y = 186, 190 do px(398, y, seal.deep) end
  hline(396, 415, TY + 5, Wt.hi) hline(398, 413, TY + 6, GL)
  for x = TX0, TX1 do px(x, TY + 8, gran.base) px(x, TY + 9, gran.shade) end
  hline(TX0 + 1, TX1 - 1, TY + 8, gran.hi)
  -- splash off the hat and nose
  for _, p in ipairs({ { 409, 172 }, { 405, 174 }, { 413, 173 }, { 401, 179 }, { 416, 180 }, { 411, 170 }, { 398, 184 }, { 419, 185 } }) do px(p[1], p[2], Wt.hi) end
  px(407, 171, GL) px(414, 171, GL)
end
-- the overflow spilling from a notch at the trough's left end
for y = TY + 6, TY + 20 do px(TX0 - 1 - (y - TY - 6) // 4, y, Wt.hi) px(TX0 - (y - TY - 6) // 4, y, Wt.base) px(TX0 + 1 - (y - TY - 6) // 4, y, GL) end

---------------------------------------------------------------- the brook winding down-left under the road, out onto the beach
local brook = HP.mask()
do
  local pts = { { 346, 210 }, { 334, 218 }, { 318, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 156, 248 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 10 + floor(i * 1.5)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  local bank = brook:grow(2):cut(brook):cut(F.roadM)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .35 and L.sand.base or (v < .55 and L.shingle.base or (v < .75 and L.shingle.hi or (v < .9 and cress.shade or L.sand.shade)))) end)
  brook:edge():each(function(x, y) if hash(x, y, 52) < .3 then px(x, y, L.sand.hi) end end)
  F.water(brook, Wt, { step = 3 })
  -- clear spring water: the sandy bed showing through in the shallows near each bank, current lines, glints
  brook:each(function(x, y)
    local edgeNear = not brook:has(x, y + 3) or not brook:has(x, y - 4)
    if edgeNear and brook:has(x, y - 1) and (x + y) % 2 == 0 then px(x, y, mix(Wt.base, L.sand.base, .45)) end
    if y % 3 == 1 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) then px(x, y, Wt.hi) end
    if hash(x, y, 55) < .012 and brook:has(x, y - 2) then px(x, y, GL) end
  end)
  -- pebbles in the stream with a foam lip
  for _, s in ipairs({ { 330, 220 }, { 306, 229 }, { 286, 236 }, { 190, 246 }, { 266, 241 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, L.shingle) part(m, L.shingle, { nopop = true }) px(s[1] - 1, s[2] - 1, L.shingle.hi)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, Wt.hi)
  end
end
-- watercress beds along the brook margins: rafts of round leaflets, tiny white flower heads
local function cressBed(cx, cy, rx, ry, seed)
  local m = c:ellipse(cx, cy, rx, ry)
  m:each(function(x, y)
    if hash(x // 2, y // 2, seed) < .78 then
      local v = hash(x, y, seed + 1)
      local h = ((x + y) % 3 == 0) and cress.shade or cress.base
      if v < .2 then h = cress.hi elseif v > .85 then h = cress.deep end
      if not m:has(x, y + 1) then h = cress.deep end
      px(x, y, h)
    end
  end)
  for k = 0, floor(rx * ry / 6) do
    local x, y = cx + floor((hash(k, 1, seed) - .5) * rx * 1.6), cy + floor((hash(k, 2, seed) - .5) * ry * 1.4)
    if m:has(x, y) then px(x, y - 1, L.awnB.hi) px(x + 1, y - 1, L.awnB.base) end
  end
end
for i, b in ipairs({ { 340, 210, 6, 3 }, { 318, 232, 8, 3 }, { 300, 226, 6, 2 }, { 284, 240, 7, 3 }, { 198, 239, 7, 2 }, { 178, 252, 9, 3 }, { 166, 243, 5, 2 } }) do cressBed(b[1], b[2], b[3], b[4], 340 + i * 3) end

---------------------------------------------------------------- the beach flat bottom-left: braided channels, rock ledges and tide pools
do
  local flat = c:ellipse(86, 254, 80, 20):clip(rect(16, 232, 200, 269))
  local fx0 = 16
  -- wet sand with wind ripples, glossy where the water just ran off
  flat:each(function(x, y)
    local rip = (x + floor(sin(y / 2.3 + x / 21) * 3)) % 6
    local h = rip == 0 and L.wetSand.base or (rip == 1 and L.sand.hi or L.sand.shade)
    if hash(x // 4, y // 2, 340) < .14 then h = mix(L.wetSand.hi, Wt.hi, .4) end
    local e = (x - 86) ^ 2 / 6400 + (y - 254) ^ 2 / 400 -- outer rim: dither into the dune turf
    if e > .8 and hash(x, y, 346) < (e - .8) * 4 then h = nil end
    if h then px(x, y, h) end
  end)
  -- braided channels fanning out from the brook mouth
  local ch = HP.mask()
  for _, p in ipairs({
    { { 160, 248 }, { 140, 250 }, { 118, 248 }, { 96, 252 }, { 70, 250 }, { 40, 254 }, { 18, 252 } },
    { { 150, 250 }, { 132, 256 }, { 110, 260 }, { 84, 262 }, { 60, 266 }, { 36, 266 } },
    { { 140, 250 }, { 128, 244 }, { 108, 240 }, { 86, 242 }, { 62, 238 }, { 40, 240 } } }) do
    for i = 1, #p - 1 do ch:add(line({ p[i], p[i + 1] }, 4 - floor(i / 3))) end
  end
  ch:clip(flat)
  -- tide pools held behind the rock ledges
  local pools = union(c:ellipse(46, 246, 16, 5), c:ellipse(120, 258, 14, 5), c:ellipse(78, 256, 9, 3))
  pools:clip(flat)
  local wet = union(ch, pools)
  F.water(wet, Wt, { step = 2 })
  wet:each(function(x, y) if hash(x, y, 341) < .3 and not pools:has(x, y) then px(x, y, mix(Wt.hi, L.sand.base, .35)) end end)
  -- rock ledges: dark bedded granite with barnacles, wrack and limpets
  local ledges = HP.mask()
  for _, r in ipairs({ { 22, 244, 12, 6 }, { 62, 240, 10, 4 }, { 102, 256, 9, 4 }, { 138, 262, 10, 4 }, { 34, 262, 8, 4 } }) do
    local m = poly{ { r[1] - r[3], r[2] + 1 }, { r[1] - r[3] + 2, r[2] - r[4] }, { r[1] + r[3] // 2, r[2] - r[4] - 1 }, { r[1] + r[3], r[2] - 1 }, { r[1] + r[3] - 1, r[2] + 1 } }
    ledges:add(m)
  end
  rimOf(ledges, L.stone)
  ledges:each(function(x, y)
    local top = not ledges:has(x, y - 1)
    local h = top and L.stone.hi or ((y % 3 == 0) and L.stone.deep or (hash(x, y, 342) < .5 and L.stone.base or L.stone.shade))
    px(x, y, h)
  end)
  F.barnacles(ledges, .18, 343, 0)
  ledges:each(function(x, y) if not ledges:has(x, y + 2) and hash(x, y, 344) < .55 then px(x, y, hash(x, y, 345) < .5 and L.kelp.base or L.kelp.shade) end end)
  for _, l in ipairs({ { 18, 241 }, { 64, 237 }, { 100, 253 } }) do px(l[1], l[2], L.cork.hi) px(l[1] + 1, l[2], L.cork.shade) end -- limpets
  -- anemones and a starfish in the pools, a shore crab on the sand
  for _, a in ipairs({ { 40, 247 }, { 52, 246 }, { 116, 259 }, { 126, 258 } }) do px(a[1], a[2], L.apple.base) px(a[1], a[2] - 1, L.apple.hi) px(a[1] + 1, a[2], L.apple.deep) end
  F.sprite({ "..o..", "ooOoo", ".oOo.", "o...o" }, 74, 254, { o = L.produce.base, O = L.produce.hi }, { rimCol = L.produce.edge })
  F.sprite({ "c.....c", "C.e.e.C", ".CCCCC.", "C.c.c.C" }, 92, 244, { C = L.kelp.base, c = L.kelp.shade, e = L.tar.edge }, { rimCol = L.kelp.edge })
  F.wrack(146, 262, 5, 3) F.wrack(56, 266, 6, 4)
  for _, s in ipairs({ { 132, 246, true }, { 86, 266, false }, { 150, 258, true } }) do F.shell(s[1], s[2], s[3]) end
end

---------------------------------------------------------------- left: flint well-head with a slate roof, a gnome winding the bucket
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local wall = c:rrect(x0, yb - 18, x1, yb, 3)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 }, { x1 + 6, yb - 48 } }:add(rect(x0 - 6, yb - 49, x1 + 6, yb - 46))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 12, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.tar)
  -- knapped flint drum with limestone quoins and a limestone coping
  wall:each(function(x, y)
    local v = hash(x // 2, y // 2, 360)
    local h = v < .3 and flint.base or (v < .65 and flint.shade or flint.deep)
    if hash(x, y, 361) < .07 then h = flint.hi end
    if (x - x0) < 6 or (x1 - x) < 6 then h = (((y - yb) // 4) % 2 == 0) and lime.base or lime.shade if (y - yb) % 4 == 0 then h = lime.deep end end
    px(x, y, h)
  end)
  wall:each(function(x, y) if y <= yb - 15 then px(x, y, y == yb - 18 and lime.hi or (y == yb - 15 and lime.deep or lime.base)) end end)
  F.lichen(wall, .02, 362)
  for x = x0, x1 do if hash(x, 7, 61) < .4 then px(x, yb, L.marram.base) px(x, yb - 1, L.marram.hi) end end
  part(postL, L.timber, { nopop = true }) part(postR, L.timber, { nopop = true })
  F.planks(postL, L.timber, 2, true, 363) F.planks(postR, L.timber, 2, true, 364)
  part(roof, L.roof, { sep = true }) F.courses(roof, yb - 66, 3, 5, L.roof) F.lichen(roof, .03, 365)
  line({ { x0 - 6, yb - 48 }, { (x0 + x1) // 2, yb - 66 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  hline(x0 - 6, x1 + 6, yb - 46, L.roof.deep)
  part(axle, L.timber, { nopop = true, noshade = true })
  fill(rect((x0 + x1) // 2 - 4, yb - 37, (x0 + x1) // 2 + 4, yb - 33), L.cork.base)
  for x = (x0 + x1) // 2 - 4, (x0 + x1) // 2 + 4, 2 do vline(x, yb - 37, yb - 33, L.cork.shade) end
  part(crank, L.iron, { nopop = true, noshade = true })
  local bx = (x0 + x1) // 2
  vline(bx, yb - 32, yb - 26, L.cork.deep)
  local bk = poly{ { bx - 5, yb - 25 }, { bx + 5, yb - 25 }, { bx + 4, yb - 17 }, { bx - 4, yb - 17 } }
  c:rim(bk, L.tar.edge) part(bk, L.wall2) hline(bx - 5, bx + 5, yb - 23, L.iron.shade) hline(bx - 4, bx + 4, yb - 25, Wt.hi)
  px(bx + 4, yb - 14, Wt.hi) px(bx - 3, yb - 12, Wt.base)
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
  -- a herring gull standing on the roof ridge, watching the bucket
  F.sprite({
    "...WWW....",
    "..WeWWW...",
    "YYWWWWW...",
    "r..WWWWW..",
    "...WWGGGGK",
    "....WGGGKK",
    ".....WWW..",
    "......pp..",
  }, (x0 + x1) // 2 - 4, yb - 74, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, Y = L.gold.base, r = L.apple.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
end
-- a pile of flagons waiting to be filled at the well's foot, thrift and campion
do
  for i, f in ipairs({ { 38, 206 }, { 46, 208 }, { 30, 210 } }) do
    local m = c:rrect(f[1] - 3, f[2] - 8, f[1] + 3, f[2], 2):add(rect(f[1] - 1, f[2] - 10, f[1] + 1, f[2] - 8))
    rimOf(m, L.soil) part(m, L.board, { nopop = true })
    m:each(function(x, y) if y < f[2] - 5 then px(x, y, (x < f[1]) and L.cork.base or L.cork.shade) end end)
    px(f[1] - 2, f[2] - 4, L.board.hi) px(f[1], f[2] - 10, L.cork.hi)
  end
end
F.thrift(42, 216, true) F.thrift(112, 214, false) F.marram(24, 204, 7) F.marram(118, 210, 6)
-- sea campion: white bladders and flowers
for _, s in ipairs({ { 26, 220 }, { 52, 218 } }) do for k = -2, 2, 2 do px(s[1] + k, s[2], L.leaf.shade) px(s[1] + k, s[2] - 1, L.awnB.hi) px(s[1] + k + 1, s[2] - 1, L.awnB.shade) end end

---------------------------------------------------------------- road: gnome with two pails on a yoke; the spring sign
F.depth(3)
do
  local x, yb = 262, 212
  F.gnome(x, yb, { hat = L.leaf, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 16, yb - 12 }, { x, yb - 14 }, { x + 16, yb - 12 } }, 2)
  c:rim(yoke, L.tar.edge) part(yoke, L.timber, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 6, L.cork.deep)
    local p = poly{ { x + sx - 5, yb - 6 }, { x + sx + 5, yb - 6 }, { x + sx + 4, yb + 2 }, { x + sx - 4, yb + 2 } }
    c:rim(p, L.tar.edge) part(p, L.wall2) hline(x + sx - 5, x + sx + 5, yb - 4, L.iron.shade) hline(x + sx - 4, x + sx + 4, yb - 6, Wt.hi)
    px(x + sx + 3, yb + 4, Wt.hi)
  end
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a blue drop on a sea-blue board, on a driftwood post
  local post = rect(206, 168, 207, 196)
  local bd = rect(194, 156, 220, 170)
  rimOf(union(post, bd), L.tar) part(post, L.timber, { nopop = true }) part(bd, L.wall2, { nopop = true }) c:edgeIn(bd, L.wall2.deep)
  F.planks(bd:shrink(1), L.wall2, 5, false, 33)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, Wt.edge) fill(drop, L.awnB.base) px(205, 164, L.awnB.hi) px(205, 165, GL) hline(206, 209, 168, L.awnB.shade)
  F.cork(196, 172) vline(196, 170, 171, L.cork.deep) -- a float hung off the corner
  F.lichen(post, .1, 34)
end

---------------------------------------------------------------- the stall: stoneware flagons of spring water, bunches of watercress
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 194)
  F.shadow(134, 182, 201, 8, 3)
  rimOf(union(top, legs, cloth), L.tar)
  part(legs, L.timber, { nopop = true, noshade = true }) part(top, L.board, { nopop = true }) hline(132, 182, 186, L.board.hi)
  fill(cloth, L.awnB.base) cloth:each(function(x, y) if ((x - 132) // 4) % 2 == 0 then px(x, y, L.wall2.base) end if y == 194 then px(x, y, L.wall2.deep) end end)
  for i, jx in ipairs({ 137, 147, 174 }) do -- salt-glazed flagons, brown-dipped shoulders
    local big = i % 2 == 1
    local jh = big and 10 or 8
    local jug = c:rrect(jx - 3, 185 - jh, jx + 3, 185, 2):add(rect(jx - 1, 183 - jh, jx + 1, 185 - jh))
    local hnd = c:ellipse(jx + 4, 180 - jh // 2, 2, 2):cut(c:ellipse(jx + 4, 180 - jh // 2, 1, 1))
    c:rim(union(jug, hnd), L.soil.edge) part(jug, L.board) fill(hnd, L.cork.shade)
    jug:each(function(x, y) if y < 185 - jh + 4 then px(x, y, x < jx and L.cork.base or L.cork.shade) end end)
    px(jx - 2, 184 - jh + 5, L.board.hi) px(jx, 183 - jh, L.cork.hi)
  end
  -- bunches of watercress tied with twine, and a basket of them
  for _, bx in ipairs({ 160, 165 }) do
    local m = c:ellipse(bx, 182, 3, 3) m:each(function(x, y) px(x, y, hash(x, y, 370) < .3 and cress.hi or ((x + y) % 2 == 0 and cress.base or cress.shade)) end)
    vline(bx, 185, 186, cress.deep) px(bx, 184, L.cork.base) px(bx - 1, 180, L.awnB.hi)
  end
  local bsk = c:rrect(184, 190, 196, 200, 3) rimOf(bsk, L.soil) part(bsk, L.cork)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.cork.shade) end end)
  c:ellipse(190, 189, 6, 2):each(function(x, y) px(x, y, hash(x, y, 371) < .3 and cress.hi or cress.base) end) px(188, 188, L.awnB.hi) px(193, 188, L.awnB.hi)
end

---------------------------------------------------------------- mid: a driftwood bench under the hawthorns, a far gnome on the road, path stones
F.depth(2)
do
  F.driftwood(112, 160, 146, 160, 4)
  F.driftwood(110, 157, 117, 161, 2) -- a root stub
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.wall2, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.gorse, arm = "out" })
  px(248, 139, L.wall2.base) px(248, 140, L.wall2.shade)
end
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, chalk) part(m, chalk, { nopop = true }) px(s[1] - 2, s[2] - 1, chalk.hi) px(s[1] + 2, s[2], flint.base)
end

---------------------------------------------------------------- right of the road: a small gnome with a jug, sea-buckthorn with orange berries
F.depth(2)
do
  local bm = F.bush(280, 152, 13, 11, L.foliage, 61)
  bm:each(function(x, y) if hash(x, y, 62) < .07 then px(x, y, L.produce.base) if bm:has(x, y - 1) then px(x, y - 1, L.produce.hi) end end end)
  F.tree(300, 150, 26, 0)
end
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  local jug = c:rrect(hx - 2, hy - 6, hx + 3, hy + 1, 2) c:rim(jug, L.soil.edge) part(jug, L.board, { nopop = true })
  hline(hx - 2, hx + 3, hy - 6, L.cork.base) hline(hx - 2, hx + 3, hy - 5, L.cork.shade) px(hx - 1, hy - 3, L.board.hi)
end

---------------------------------------------------------------- the washer gnome on a flat rock by the channels; yellow flag iris
F.depth(3)
do
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, L.stone) part(st, L.stone, { nopop = true }) F.barnacles(st, .15, 64, 236)
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.leaf, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.tar.edge) part(wb, L.board, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.board.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, Wt.hi) end
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.soil) part(bsk, L.cork)
  bsk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.cork.shade) elseif (x - y) % 4 == 0 then px(x, y, L.cork.hi) end end)
  -- a navy gansey and a red-and-white striped jersey waiting their turn
  fill(c:ellipse(189, 221, 4, 2), L.accent.base) px(187, 220, L.accent.hi)
  c:ellipse(196, 220, 4, 2):each(function(x, y) px(x, y, (x % 2 == 0) and L.awnA.base or L.awnB.hi) end)
end
local function iris(x, yb, n, hmax, seed)
  -- yellow flag: thin sword leaves fanning from a clump, taller flower stalks with three-petal yellow heads
  local m = HP.mask()
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.2)
    local h = floor(hmax * (.5 + .4 * hash(i, 2, seed)))
    local lean = (i - (n + 1) / 2) * 1.3 + (hash(i, 3, seed) - .5) * 2
    m:add(line({ { bx, yb }, { bx + lean * .25, yb - h * .55 }, { bx + lean, yb - h } }))
    m:add(line({ { bx + 1, yb }, { bx + 1 + lean * .2, yb - h * .4 } }))
  end
  c:rim(m, L.fern.edge)
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local col = t > .55 and L.fern.hi or (t > .2 and L.fern.base or L.fern.shade)
    if not m:has(xx - 1, yy) and t > .2 then col = L.fern.hi end
    if yy >= yb - 1 then col = L.fern.deep end
    px(xx, yy, col)
  end)
  for i = 1, 3 do
    local hx = x + floor((hash(i, 5, seed) - .5) * n * 1.1)
    local hy = yb - hmax - 1 - floor(hash(i, 6, seed) * 4)
    if i == 3 and hash(i, 7, seed) < .5 then break end
    vline(hx, hy + 2, yb - floor(hmax * .5), L.fern.shade)
    -- standard upright, two falls drooping left/right, an orange-veined throat
    px(hx, hy - 2, L.gorse.hi) px(hx, hy - 1, L.gorse.base)
    px(hx - 1, hy, L.gorse.hi) px(hx, hy, L.produce.base) px(hx + 1, hy, L.gorse.base)
    px(hx - 2, hy + 1, L.gorse.base) px(hx + 2, hy + 1, L.gorse.shade) px(hx, hy + 1, L.gorse.deep)
    px(hx - 2, hy + 2, L.gorse.shade) px(hx + 2, hy + 2, L.gorse.deep)
  end
end
iris(26, 248, 9, 18, 3) iris(352, 236, 8, 16, 21) iris(368, 264, 7, 16, 22) iris(158, 268, 8, 14, 23)

F.depth(3)
---------------------------------------------------------------- the plank bridge where the road crosses the brook
do
  local ys, ye = 999, -1
  onRoad:each(function(x, y) if y < ys then ys = y end if y > ye then ye = y end end)
  ys, ye = ys + 3, ye - 5
  local deck = HP.mask()
  for y = ys, ye do deck:add(rect(floor(F.xl(y)) - 4, y, floor(F.xr(y) + .99) + 4, y)) end
  -- piles and the shadow of the deck on the water each side
  for _, side in ipairs({ -1, 1 }) do
    for _, y in ipairs({ ys + 3, (ys + ye) // 2, ye - 1 }) do
      local x = side < 0 and floor(F.xl(y)) - 6 or floor(F.xr(y)) + 6
      if brook:has(x, y + 2) or brook:has(x, y) then
        local pl = rect(x - 1, y - 2, x, y + 4) rimOf(pl, L.tar) part(pl, L.timber, { nopop = true, noshade = true })
        hline(x - 3, x + 2, y + 5, GL) F.barnacles(pl, .2, x, y + 2)
      end
    end
  end
  brook:each(function(x, y) if deck:grow(2):has(x, y) and not deck:has(x, y) then px(x, y, Wt.deep) end end)
  rimOf(deck, L.tar)
  deck:each(function(x, y)
    -- planks run along the road: 4 px wide boards, dark gaps, short butt joints
    local xl = floor(F.xl(y)) - 4
    local col = (x - xl) // 4
    local k = (x - xl) % 4
    local h = k == 0 and L.board.deep or (k == 1 and L.board.hi or (k == 2 and L.board.base or L.board.shade))
    local jy = (y - ys + col * 5) % 17
    if jy == 0 then h = L.board.deep end
    local v = hash(col, (y - ys + col * 5) // 17, 350)
    if v < .2 and k > 0 then h = (k == 1) and L.timber.hi or L.timber.base end -- a grey replacement plank
    if k == 2 and hash(x, y, 351) < .1 then h = L.board.shade end
    px(x, y, h)
  end)
  -- nail heads near each end of every plank, ends ragged
  for y = ys + 2, ye, 3 do
    local xa, xb = floor(F.xl(y)) - 1, floor(F.xr(y) + .99) + 2
    px(xa, y, L.iron.deep) px(xb, y, L.iron.deep)
    if hash(y, 1, 352) < .5 then px(xa - 2, y - 1, L.tar.edge) end
  end
  -- kerb beams framing both edges of the deck, and a worn threshold at each end
  for y = ys, ye do
    local xa, xb = floor(F.xl(y)) - 4, floor(F.xr(y) + .99) + 4
    px(xa, y, L.tar.base) px(xa + 1, y, L.timber.shade) px(xa + 2, y, L.timber.base)
    px(xb, y, L.tar.base) px(xb - 1, y, L.timber.deep) px(xb - 2, y, L.timber.shade)
  end
  hline(floor(F.xl(ys)) - 3, floor(F.xr(ys) + .99) + 3, ys, L.timber.hi)
  hline(floor(F.xl(ye)) - 3, floor(F.xr(ye) + .99) + 3, ye, L.tar.base)
  -- driftwood post-and-rail handrails along both edges
  local rails = HP.mask()
  local postsM = HP.mask()
  for _, side in ipairs({ -1, 1 }) do
    local tops = {}
    local n = 3
    for i = 0, n do
      local y = ys + 1 + floor((ye - ys - 1) * i / n)
      local x = side < 0 and floor(F.xl(y)) - 5 or floor(F.xr(y) + .99) + 3
      local hh = 13 + floor((y - ys) * .12)
      postsM:add(rect(x, y - hh, x + 2, y))
      tops[#tops + 1] = { x + 1, y - hh + 1 }
    end
    for i = 1, #tops - 1 do
      rails:add(line({ tops[i], tops[i + 1] }, 1))
      rails:add(line({ { tops[i][1], tops[i][2] + 6 }, { tops[i + 1][1], tops[i + 1][2] + 6 } }))
    end
  end
  local allR = union(rails, postsM)
  rimOf(postsM, L.tar)
  part(postsM, L.timber, { nopop = true })
  postsM:each(function(x, y) if not postsM:has(x, y - 1) then px(x, y, L.timber.hi) end end)
  rails:each(function(x, y) if not postsM:has(x, y) then px(x, y, (x + y) % 2 == 0 and L.cork.base or L.cork.shade) end end)
  F.barnacles(postsM, .06, 354, 0)
  -- a coil of rope hung on the right rail, a cork float tied on
  local rx, ry = floor(F.xr(ye)) + 5, ye - 8
  c:ellipse(rx, ry, 3, 3):cut(c:ellipse(rx, ry, 1, 1)):each(function(x, y) px(x, y, (x + y) % 2 == 0 and L.cork.base or L.cork.shade) end)
  F.cork(rx, ry + 5)
end

---------------------------------------------------------------- flora round the cliff foot: thrift, campion, marram, shells
F.depth(3)
for _, f in ipairs({ { 292, 214, 7 }, { 306, 222, 6 }, { 452, 216, 8 }, { 466, 222, 7 }, { 120, 206, 6 }, { 230, 214, 5 } }) do F.marram(f[1], f[2], f[3]) end
for i = 0, 9 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 218 + floor(hash(i, 2, 71) * 10)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) then
    if i % 3 == 0 then F.thrift(x, y, true)
    else for k = -3, 3 do px(x + k, y + 1, L.leaf.shade) if k % 2 == 0 then px(x + k, y, L.leaf.base) px(x + k, y - 1, L.awnB.hi) px(x + k + 1, y - 1, L.petal.hi) end end end
  end
end
for i, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, chalk) part(m, chalk, { nopop = true }) px(s[1] - 2, s[2] - 1, chalk.hi) px(s[1] + 1, s[2], flint.shade)
end
F.shell(440, 224, true) F.shell(446, 226, false) F.shell(300, 228, true)
F.pebbles(436, 222, 3, 71) F.pebbles(294, 226, 2, 72)
F.driftwood(420, 226, 446, 220, 2)
-- sea kale on the shingle: big waxy blue-grey leaves, a dome of white flowers
local function seaKale(x, yb, r, seed)
  local m = HP.mask()
  for k = 0, 5 do
    local a = pi + k * pi / 5 + (hash(k, 1, seed) - .5) * .3
    m:add(c:ellipse(x + floor(cos(a) * r * .8), yb - 2 + floor(sin(a) * r * .45), 3 + floor(hash(k, 2, seed) * 2), 2))
  end
  rimOf(m, kale)
  m:each(function(xx, yy)
    local lt = (xx - x) / r + (yy - yb) / r * .5
    local h = lt < -.4 and kale.hi or (lt < .2 and kale.base or kale.shade)
    if (xx * 3 + yy) % 5 == 0 then h = kale.deep end -- crinkled margins
    px(xx, yy, h)
  end)
  local fl = c:ellipse(x, yb - r * .5 - 2, floor(r * .5), 2)
  fl:each(function(xx, yy) px(xx, yy, hash(xx, yy, seed) < .3 and L.awnB.shade or ((xx + yy) % 2 == 0 and L.awnB.hi or L.board.hi)) end)
  px(x - 1, yb - floor(r * .5) - 4, L.gorse.hi)
end
seaKale(452, 226, 9, 380) seaKale(426, 214, 6, 381)
F.pebbles(466, 224, 4, 382) F.thrift(470, 216, true)

---------------------------------------------------------------- foreground: a gnome hauling a water cart; an oystercatcher; butterflies
F.depth(3)
do
  local x, yb = 322, 266
  local bar = c:rrect(330, 242, 354, 260, 5)
  local shaft = line({ { 332, 256 }, { 326, 258 } }, 2)
  local wh = c:ellipse(342, 262, 6, 6)
  F.shadowM(c:ellipse(346, 268, 16, 1))
  rimOf(union(bar, shaft, wh), L.tar)
  part(bar, L.wall2) F.planks(bar, L.wall2, 4, true, 12)
  for _, hy in ipairs({ 245, 256 }) do hline(330, 354, hy, L.iron.shade) hline(331, 353, hy - 1, L.iron.hi) end
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(wh, L.timber, { nopop = true }) fill(c:ellipse(342, 262, 3, 3), L.timber.shade)
  vline(342, 257, 267, L.timber.deep) hline(337, 347, 262, L.timber.deep) px(342, 262, L.iron.hi)
  fill(rect(339, 240, 345, 241), Wt.base) px(340, 240, Wt.hi)
  for _, p in ipairs({ { 348, 239 }, { 351, 238 }, { 355, 241 }, { 357, 245 }, { 336, 239 } }) do px(p[1], p[2], Wt.hi) end
  F.gnome(x, yb, { hat = L.roof2, coat = L.awnB, arm = "out" })
end
F.marram(306, 262, 8) F.marram(296, 266, 7) F.thrift(362, 268, true)
-- an oystercatcher (black back, white belly, orange bill, pink legs) on the bridge's right rail post
do
  local bx, by = floor(F.xr(230)) + 2, 211
  F.sprite({ ".KK....", "KeKK...", "OKKKKK.", "..KWWKK", "..WWWW.", "...p.p." }, bx - 2, by - 8,
    { K = L.tar.deep, e = L.apple.base, O = L.produce.base, W = L.gull.hi, p = L.petal.base }, { rimCol = L.tar.edge })
end
-- small blue butterflies over the thrift, a cabbage white by the cress
for i, d in ipairs({ { 296, 216 }, { 176, 236 }, { 64, 228 }, { 360, 220 } }) do
  local x, y = d[1], d[2]
  local w = i == 2 and L.awnB or L.accent
  px(x - 1, y, w.hi) px(x + 1, y, w.base) px(x - 1, y + 1, w.base) px(x + 1, y + 1, w.shade) px(x, y, L.tar.edge) px(x, y + 1, L.tar.edge)
end

F.depth(0)
F.gull(330, 44, 3) F.gull(342, 52, 2) F.gull(168, 60, 2) F.gull(186, 52, 2) F.gull(236, 70, 1) F.gull(410, 50, 2)
F.gull(350, 88, 1) F.gull(196, 92, 1)
F.finish()
