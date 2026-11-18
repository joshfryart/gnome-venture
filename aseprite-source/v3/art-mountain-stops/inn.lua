-- inn.lua : "Inn" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua), re-cast for the high mountains:
-- left hero: a pass hospice inn, chalet style. A whitewashed granite ground floor with sgraffito borders, dressed
-- quoins, glowing bay windows and a painted sundial; a log (Strickbau) upper storey with flame-painted shutters and a
-- long balcony of geraniums; a broad front gable of sun-scorched larch boards under a deep-eaved granite slab roof
-- with weighting stones, carved bargeboards and purlin ends, a little bell-cote on the ridge, two stone chimneys.
-- Firewood stacked to the eaves under the left overhang. A St-Bernard-style dog with a keg collar guards the door.
-- A gallows sign post by the road hangs the tankard board. Right: a beer garden under a big spruce and a larch,
-- lantern festoons, a long trestle table with three gnomes raising mugs, a cheese wheel, alpine choughs after the
-- crumbs, a waiter crossing the road. Road's end: a stone-and-larch stable barn; a mule eats from the hay cart.
-- A goat chews the tether at the hitching rail by a granite fountain trough fed by a larch spout.
-- Quirk: a big ginger tabby asleep on top of the inn sign, tail hanging down over the tankard, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 24, 150, 206, 300, 340, 380, 452 },
  clouds = { { 150, 40, 44 }, { 300, 28, 50 }, { 410, 62, 30 }, { 230, 70, 22 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix

-- local helpers ------------------------------------------------------------------------------------------
local function weightStone(x, y, rx, ry)
  local ws = c:ellipse(x, y, rx or 3, ry or 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(x - 1, y - 1, L.stone.hi)
  return ws
end
-- flame-painted shutter (red and cream chevrons), x0..x0+w, y0..y1
local function shutter(x0, y0, y1, w, flip)
  local m = rect(x0, y0, x0 + w, y1)
  c:rim(m, L.timber.edge)
  m:each(function(x, y)
    local u = flip and (x0 + w - x) or (x - x0)
    local k = (y - y0 + u) % 6
    px(x, y, k < 3 and L.awnA.base or L.awnB.base)
    if k == 2 then px(x, y, L.awnA.shade) end
    if k == 5 then px(x, y, L.awnB.shade) end
  end)
  vline(flip and x0 or x0 + w, y0, y1, L.timber.base)
  hline(x0, x0 + w, y0, L.awnA.hi)
  return m
end
-- a little alpine chough pecking: blue-black, yellow beak, red legs
local function chough(x, yb, flip)
  local rows = { "..kkk....", ".kKKKkk..", "yKeKKKKkk", ".kKKKKKk.", "..kKKk...", "...r.r..." }
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x - 4, yb - 5, { k = "#2c2c3c", K = "#424256", e = "#8a8aa4", y = L.gold.hi, r = L.apple.base })
end

---------------------------------------------------------------- back: the pass path zig-zagging up the near range
F.depth(0)
do
  local pts = { { 322, 100 }, { 350, 92 }, { 334, 86 }, { 360, 78 }, { 344, 72 }, { 366, 65 } }
  for i = 1, #pts - 1 do
    line({ pts[i], pts[i + 1] }):each(function(x, y)
      local v = c:get(x, y)
      if v and hash(x, y, 5) < .85 then px(x, y, mix(v, L.soil.shade, .32)) end
    end)
  end
  -- a cairn at the top bend
  px(366, 63, mix(L.soil.shade, L.peak.base, .3)) px(365, 64, mix(L.soil.deep, L.peak.base, .3)) px(366, 64, mix(L.soil.shade, L.peak.base, .3)) px(367, 64, mix(L.soil.deep, L.peak.base, .3))
end

---------------------------------------------------------------- back row: stone-and-larch stable barn at the road's end, far chalet
F.depth(1)
F.tree(300, 128, 34, 4)
F.tree(236, 126, 28, 2)
do
  local top, _, bwall, broof = F.building{ x0 = 246, x1 = 292, yb = 128, wh = 16, rh = 13, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, shingle = true }
  F.planks(bwall, L.timber, 3, true, 4)
  local base = rect(246, 121, 292, 128)
  part(base, L.plaster, { nopop = true }) F.courses(base, 121, 3, 6, L.plaster)
  F.lichen(broof, .25, 31)
  weightStone(256, top - 1, 2, 1) weightStone(282, top - 1, 2, 1)
  -- big arched barn door with a cart nose showing
  local d = c:rrect(260, 117, 276, 133, 5):clip(rect(260, 117, 276, 128))
  fill(d, L.soil.deep) c:edgeIn(d, L.timber.hi)
  fill(rect(264, 124, 272, 126), L.board.base) fill(c:ellipse(266, 127, 2, 1), L.timber.shade)
  px(268, 121, L.glow.shade) px(269, 121, L.glow.base) -- a lamp lit deep inside
end
do
  local top, _, cwall, croof = F.building{ x0 = 416, x1 = 456, yb = 126, wh = 13, rh = 10, wall = L.timber, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.planks(cwall, L.timber, 3, false, 6)
  local base = rect(416, 121, 456, 126)
  part(base, L.plaster, { nopop = true }) F.courses(base, 121, 3, 6, L.plaster)
  F.lichen(croof, .2, 32)
  F.window(424, 115, 428, 118, L.timber) F.window(446, 115, 450, 118, L.timber)
  hline(422, 452, 120, L.apple.base)
end
F.smoke(447, 98, 4, .5, 2)
F.fenceP(300, 132, 410, 129, 10)
F.goat(392, 127, { k = .4, graze = true, noShadow = true })
F.goat(404, 125, { k = .38, flip = true, r = L.chamois, noShadow = true })
-- the barn's washing line: aprons and tea towels (the inn's laundry), hazed with the back row
do local wp = rect(318, 112, 319, 130) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true }) end
F.washing(293, 114, 318, 113, { { "sheet", L.awnB }, { "shirt", L.awnA }, { "sock", L.accent } }, 3)

---------------------------------------------------------------- mid right: spruce + larch, hay cart, the mule
F.depth(2)
F.tree(352, 152, 50, 6)
F.larch(384, 158, 44, 17)
F.tree(322, 140, 34, 5)
F.boulder(372, 160, 6, 5, 21)
local function hayCart(x0, yb)
  local bed = poly{ { x0, yb - 12 }, { x0 + 46, yb - 12 }, { x0 + 44, yb - 6 }, { x0 + 2, yb - 6 } }
  local hay = c:ellipse(x0 + 23, yb - 16, 25, 8):clip(rect(x0 - 4, yb - 30, x0 + 50, yb - 11))
  local shaft = line({ { x0, yb - 9 }, { x0 - 16, yb - 3 } }, 2)
  rimOf(union(bed, hay, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) F.planks(bed, L.board, 4, true, 3)
  part(hay, L.needle)
  hay:each(function(x, y)
    if hash(x, y, 81) < .18 then px(x, y, L.needle.hi) elseif (x * 2 + y) % 5 == 0 then px(x, y, L.needle.shade) end
    if y > yb - 14 and hash(x, y, 82) < .3 then px(x, y, L.needle.deep) end
    if hash(x, y, 83) < .05 then px(x, y, L.fern.base) end -- green mountain hay
  end)
  for i = 0, 9 do local hx = x0 + 2 + i * 5 px(hx, yb - 25 + (i % 3), L.needle.hi) px(hx + 1, yb - 26 + (i % 3), L.needle.hi) end
  for _, wx in ipairs({ x0 + 9, x0 + 37 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep) px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(300, 350, 166, 8, 3)
hayCart(302, 166)
-- a mouse-grey pack mule with a pale muzzle and long ears, head down in the hay, a red pack saddle blanket
F.shadowM(c:ellipse(364, 167, 12, 1))
F.sprite({
  ".......mm...............",
  "......mmBBhhhhhhhhhh....",
  ".....mmBBrrrrrrrrrBBBh.t",
  "....mmBBBrRRRRRRRrBBBBtt",
  "...mmBBBBrrrrrrrrrBBBBtt",
  "..mBBB.BBBBBBBBBBBBBBBtt",
  ".mBeB..BBBBBBBBBBBBBBB.t",
  "BBkB...dBBBBBBBBBBBBBd.t",
  "BBBw....dBBdddddddBBBd.t",
  "BBww....BB.d.....BB.d...",
  "nBw.....Bd.d.....Bd.d...",
  "nn......Bd.dd....Bd.dd..",
  "........dd.dd....dd.dd..",
  "........ff.ff....ff.ff..",
}, 347, 153, { m = L.soil.deep, h = L.soil.hi, B = L.soil.base, d = L.soil.shade, k = L.timber.edge, w = L.goat.base,
  n = L.soil.deep, t = L.soil.deep, f = L.timber.deep, e = L.soil.deep, r = L.awnA.base, R = L.awnA.hi })
-- long ears
for _, p in ipairs({ { 349, 157 }, { 348, 156 }, { 347, 155 }, { 351, 158 }, { 351, 157 }, { 350, 156 } }) do px(p[1], p[2], L.soil.base) end
px(347, 155, L.soil.deep) px(350, 156, L.soil.deep) px(348, 156, L.soil.hi)
px(346, 162, L.needle.hi) px(345, 163, L.needle.base) px(346, 164, L.needle.hi) px(345, 161, L.needle.shade)

---------------------------------------------------------------- the hospice inn (left hero)
F.depth(3)
local AX, AY, SL = 107, 54, .6
local function yo(x) return AY + abs(x - AX) * SL end
local function inn()
  local X0, X1 = 30, 184
  local GTOP, YB = 142, 182          -- ground floor (whitewashed granite)
  local UX0, UX1, UTOP = 25, 189, 113 -- log storey
  -- deep-eaved front gable: roof band, the board gable and log storey below it
  local band, wall = HP.mask(), HP.mask()
  for x = 6, 208 do
    local y0 = floor(yo(x))
    for y = y0, math.min(y0 + 9, 116) do band:set(x, y) end
    if x >= UX0 and x <= UX1 then for y = y0 + 10, GTOP - 1 do wall:set(x, y) end end
  end
  local ground = rect(X0, GTOP, X1, YB)
  local ch1, ch2 = rect(46, 64, 55, 90), rect(158, 60, 167, 90)
  local cote = union(rect(102, 40, 103, 56), rect(111, 40, 112, 56), poly{ { 98, 42 }, { 107, 33 }, { 116, 42 } })
  local sil = union(band, wall, ground, ch1, ch2, cote)
  F.shadow(X0 + 4, X1 + 4, YB, 16, 6)
  rimOf(sil, L.timber)
  -- chimneys: granite, lichened, a slab cap on two stones
  for i, ch in ipairs({ ch1, ch2 }) do part(ch, L.stone) F.courses(ch, 60, 4, 6, L.stone) F.lichen(ch, .2, 33 + i) end
  for _, cx in ipairs({ 50, 162 }) do
    local cy = (cx == 50) and 64 or 60
    local cap = rect(cx - 6, cy - 4, cx + 6, cy - 3)
    rimOf(cap, L.stone) fill(cap, L.stone.base) hline(cx - 6, cx + 6, cy - 4, L.stone.hi)
    fill(rect(cx - 4, cy - 2, cx - 3, cy - 1), L.stone.shade) fill(rect(cx + 3, cy - 2, cx + 4, cy - 1), L.stone.shade)
    fill(rect(cx - 2, cy - 2, cx + 2, cy - 1), L.timber.edge)
  end
  -- the gable: vertical larch boards, sun-scorched near the top
  local gable = wall:copy():clip(rect(UX0, 0, UX1, UTOP - 2))
  part(gable, L.timber, { nopop = true })
  F.planks(gable, L.timber, 4, true, 11)
  gable:each(function(x, y) if y < 84 and hash(x, y, 18) < .35 then px(x, y, L.timber.deep) end end)
  -- the log storey: round larch logs with notched corner ends
  local logs = wall:copy():clip(rect(UX0, UTOP, UX1, GTOP - 1))
  F.logs(logs, L.timber, UTOP, 4)
  for y = UTOP + 2, GTOP - 3, 4 do F.logEnd(UX0 - 1, y, 1) F.logEnd(UX1 + 1, y, 1) end
  local sill = rect(UX0, UTOP - 2, UX1, UTOP - 1) part(sill, L.timber, { nopop = true, noshade = true }) hline(UX0, UX1, UTOP - 2, L.timber.hi)
  -- roof band: granite slab edges, carved bargeboard, dark soffit
  band:each(function(x, y)
    local d = y - floor(yo(x))
    local left = x < AX
    local h
    if d == 0 then h = left and L.roof.hi or L.roof.base
    elseif d <= 4 then
      local row = (d - 1) // 2
      local jx = (x + row * 4 + floor(hash(x // 7, row, 41) * 3)) % 7
      if jx == 0 then h = L.roof.deep
      elseif d % 2 == 1 then h = left and L.roof.base or L.roof.shade
      else h = left and L.roof.shade or L.roof.deep end
      if d == 4 and hash(x, 1, 42) < .5 then h = L.roof.edge end
    elseif d == 5 then h = L.timber.hi
    elseif d == 6 then h = (x % 5 == 0) and L.timber.shade or L.timber.base
    elseif d == 7 then h = (x % 5 == 2 or x % 5 == 3) and L.timber.deep or L.timber.base
    else h = (d == 8 and x % 5 >= 2 and x % 5 <= 3) and L.timber.deep or L.timber.edge end
    px(x, y, h)
  end)
  F.lichen(band, .12, 44)
  -- re-ink the bargeboard over any lichen that fell on it
  band:each(function(x, y) local d = y - floor(yo(x)) if d == 5 then px(x, y, L.timber.hi) elseif d >= 8 then px(x, y, L.timber.edge) end end)
  -- purlin ends poking out under the bargeboard
  for _, x in ipairs({ 30, 54, 78, 136, 160, 184 }) do F.logEnd(x, floor(yo(x)) + 10, 2) end
  F.logEnd(AX, AY + 11, 2)
  -- weighting stones along the slab edges
  for _, x in ipairs({ 22, 40, 66, 92, 124, 150, 176, 194 }) do weightStone(x, floor(yo(x)) - 1, 3, 2) end
  -- the bell-cote on the ridge: two posts, a slab cap, a bronze bell, an iron cross
  part(cote, L.timber, { nopop = true, noshade = true })
  local cap = poly{ { 98, 42 }, { 107, 33 }, { 116, 42 } }
  part(cap, L.roof, { nopop = true }) F.courses(cap, 33, 3, 5, L.roof)
  line({ { 98, 42 }, { 107, 33 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  fill(rect(104, 43, 110, 46), L.soil.deep)
  local bell = poly{ { 105, 46 }, { 109, 46 }, { 110, 52 }, { 104, 52 } }
  c:rim(bell, L.timber.edge) part(bell, L.gold, { nopop = true }) vline(105, 47, 51, L.gold.hi) vline(109, 47, 51, L.gold.deep)
  px(107, 53, L.gold.shade)
  vline(107, 27, 32, L.iron.base) hline(105, 109, 29, L.iron.base) px(106, 28, L.iron.hi)
  -- gable: a heart cut-out near the apex, two shuttered windows and a little balcony
  F.sprite({ "s.s", "sss", ".s." }, 106, 70, { s = L.soil.deep }, { rim = false })
  for _, wx in ipairs({ 92, 122 }) do
    F.window(wx - 3, 85, wx + 3, 95, L.timber)
    shutter(wx - 8, 84, 96, 3) shutter(wx + 5, 84, 96, 3, true)
  end
  -- carved braces (Bügen) from the gable to the purlins
  for _, b in ipairs({ { 64, 86, 72, 96 }, { 150, 86, 142, 96 } }) do
    local m = line({ { b[1], b[2] }, { b[3], b[4] } }, 2) rimOf(m, L.timber) part(m, L.timber, { nopop = true, noshade = true })
  end
  do -- the gable balcony: rail with cut-out balusters, geraniums
    local rail = rect(78, 100, 136, 101):add(rect(78, 108, 136, 109))
    for x = 79, 135, 3 do rail:add(rect(x, 102, x + 1, 107)) end
    rimOf(rail, L.timber) part(rail, L.board, { nopop = true, noshade = true })
    hline(78, 136, 100, L.board.hi) hline(78, 136, 109, L.timber.base)
    for x = 79, 135, 3 do px(x + 1, 104, L.timber.deep) end
    for x = 79, 135 do
      local h = hash(x, 99, 12)
      if h < .45 then px(x, 99, L.apple.base) px(x, 98, (h < .2) and L.apple.hi or L.leaf.base) elseif h < .8 then px(x, 99, L.leaf.base) end
    end
  end
  -- log storey: shuttered windows, a balcony door, and a long balcony across the front
  for _, wx in ipairs({ 46, 74, 140, 168 }) do
    F.window(wx - 4, UTOP + 4, wx + 4, UTOP + 13, L.timber)
    for y = UTOP + 5, UTOP + 12, 2 do px(wx - 3, y, L.glow.shade) end
    shutter(wx - 10, UTOP + 3, UTOP + 15, 4) shutter(wx + 6, UTOP + 3, UTOP + 15, 4, true)
  end
  local bd = rect(100, UTOP, 114, GTOP - 2)
  fill(bd:grow(1), L.timber.edge) fill(bd, L.soil.deep)
  fill(rect(101, UTOP + 3, 113, UTOP + 10), L.glow.shade) fill(rect(102, UTOP + 4, 106, UTOP + 9), L.glow.base) px(102, UTOP + 4, L.glow.hi)
  -- a gnome stepping out of the balcony door, beating a striped rug over the rail
  F.gnome(106, 132, { small = true, hat = L.leaf, coat = L.awnA, arm = "out" })
  local rail = rect(20, 126, 194, 127):add(rect(20, GTOP - 1, 194, GTOP + 1))
  for x = 21, 193, 4 do rail:add(rect(x, 128, x + 2, GTOP - 2)) end
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true })
  hline(20, 194, 126, L.timber.hi) hline(20, 194, GTOP - 1, L.timber.hi)
  for x = 21, 193, 4 do px(x + 1, 131, L.timber.edge) px(x + 1, 132, L.timber.edge) px(x, 134, L.timber.hi) end -- cut-out hearts
  for x = 22, 192, 6 do F.logEnd(x, GTOP + 1, 1) end
  -- geranium boxes on the rail
  for _, bx in ipairs({ { 24, 66 }, { 128, 190 } }) do
    hline(bx[1], bx[2], 125, L.board.base) hline(bx[1], bx[2], 126, L.board.deep)
    for x = bx[1], bx[2] do
      local h = hash(x, 124, 12)
      if h < .5 then px(x, 124, L.apple.base) px(x, 123, (h < .22) and L.apple.hi or L.apple.base) if h < .1 then px(x, 122, L.apple.hi) end
      elseif h < .85 then px(x, 124, L.leaf.base) px(x, 123, L.leaf.hi) end
    end
    for x = bx[1], bx[2], 5 do px(x, 127, L.leaf.shade) px(x + 1, 128, L.leaf.base) end -- trailing stems
  end
  local rug = rect(112, 125, 124, 150)
  c:rim(rug, L.timber.edge) fill(rug, L.awnA.base)
  rug:each(function(x, y) if ((y - 125) // 3) % 2 == 1 then px(x, y, L.awnB.base) end if x == 124 then px(x, y, L.awnA.deep) end if y == 125 then px(x, y, L.awnA.hi) end end)
  for x = 112, 124, 2 do px(x, 151, L.awnB.shade) end
  for _, p in ipairs({ { 127, 118 }, { 129, 115 }, { 128, 121 }, { 131, 119 }, { 132, 113 }, { 130, 123 } }) do px(p[1], p[2], "#dad8ce") px(p[1] + 1, p[2], "#c8cac2") end
  -- ground floor: whitewashed rubble granite with dressed quoins
  part(ground, L.plaster, { nopop = true })
  ground:each(function(x, y)
    local row = (y - GTOP) // 5
    local ry = (y - GTOP) % 5
    local bw = 7 + floor(hash(row, 1, 19) * 4)
    local rx = (x + row * 3) % bw
    if ry == 0 and hash(x // 3, row, 23) < .5 then px(x, y, L.plaster.shade)
    elseif rx == 0 and hash(row, x // bw, 24) < .6 then px(x, y, L.plaster.shade)
    elseif hash((x + row * 3) // bw, row, 20) < .12 then px(x, y, (ry == 1) and L.stone.hi or L.stone.base)
    elseif ry == 1 and rx == 1 then px(x, y, L.plaster.hi) end
    if y <= GTOP + 4 then px(x, y, (y == GTOP + 4) and L.plaster.shade or L.plaster.deep) end -- under the balcony
    if y > YB - 10 and hash(x, y, 21) < .3 then px(x, y, L.plaster.shade) end
  end)
  for _, qx in ipairs({ X0, X1 - 5 }) do
    for row = 0, 6 do
      local y0 = GTOP + 5 + row * 5
      local w = (row % 2 == 0) and 6 or 4
      local x0 = (qx == X0) and X0 or (X1 - w)
      local q = rect(x0, y0, x0 + w, y0 + 3)
      fill(q, L.stone.base) hline(x0, x0 + w, y0, L.stone.hi) vline(x0 + w, y0, y0 + 3, L.stone.shade) hline(x0, x0 + w, y0 + 4, L.stone.deep)
    end
  end
  local plinth = rect(X0, YB - 5, X1, YB)
  part(plinth, L.stone, { nopop = true }) F.courses(plinth, YB - 5, 3, 9, L.stone) F.lichen(plinth, .2, 35)
  -- door: arched larch door in a granite arch, a slab hood, ibex horns
  local arch = c:rrect(97, 151, 117, YB + 6, 6):clip(rect(97, 151, 117, YB))
  rimOf(arch, L.stone) fill(arch, L.stone.base) arch:each(function(x, y) if (x + y) % 5 == 0 then px(x, y, L.stone.deep) elseif x < 100 or y < 154 then px(x, y, L.stone.hi) end end)
  F.door(100, 154, 114, YB - 1, L.timber, true)
  for _, p in ipairs({ { 104, 165 }, { 110, 165 }, { 107, 162 }, { 107, 168 } }) do px(p[1], p[2], L.timber.hi) end -- diamond studs
  fill(rect(98, YB, 116, YB), L.stone.hi)
  local hood = poly{ { 92, 150 }, { 107, 141 }, { 122, 150 } }:add(rect(92, 149, 122, 151))
  rimOf(hood, L.roof) part(hood, L.roof, { nopop = true }) F.courses(hood, 141, 3, 5, L.roof)
  line({ { 92, 150 }, { 107, 141 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  -- ibex horns over the hood
  for _, s in ipairs({ -1, 1 }) do
    for i = 0, 7 do
      local x = 107 + s * (2 + floor(i * .7))
      local y = 140 - i
      px(x, y, (i % 2 == 0) and "#9c9078" or "#7a6e5c")
      if i > 4 then px(x + s, y, "#7a6e5c") end
    end
  end
  fill(rect(105, 139, 109, 141), L.board.base) px(105, 139, L.board.hi)
  -- bay windows in sgraffito borders, warm glow, geranium boxes
  local function bay(x0, x1, y0, y1)
    local m = rect(x0, y0, x1, y1)
    -- grey sgraffito border: a band with a running zig-zag
    local brd = rect(x0 - 5, y0 - 5, x1 + 5, y1 + 1):cut(rect(x0 - 3, y0 - 3, x1 + 3, y1 + 1))
    brd:each(function(x, y) px(x, y, L.plaster.deep) end)
    rect(x0 - 4, y0 - 4, x1 + 4, y0 - 4):each(function(x, y) if (x % 4 == 0) then px(x, y, L.plaster.hi) end end)
    for x = x0 - 4, x1 + 4 do px(x, y0 - 4 + ((x % 4 < 2) and 0 or 1), L.plaster.base) end
    fill(m:grow(2), L.stone.base) hline(x0 - 2, x1 + 2, y0 - 2, L.stone.hi) vline(x0 - 2, y0 - 2, y1 + 2, L.stone.hi)
    fill(m:grow(1), L.timber.edge)
    fill(m, L.glow.base)
    m:each(function(x, y)
      if (x - x0) % 6 == 0 or (y - y0) % 5 == 0 then px(x, y, L.timber.base)
      elseif (x - x0) % 6 == 1 and (y - y0) % 5 == 1 then px(x, y, L.glow.hi)
      elseif (x - x0) % 6 == 5 or (y - y0) % 5 == 4 then px(x, y, L.glow.shade) end
    end)
    local box = rect(x0 - 2, y1 + 2, x1 + 2, y1 + 5)
    rimOf(box, L.timber) part(box, L.board, { nopop = true }) F.planks(box, L.board, 4, true, 2)
    for x = x0 - 1, x1 + 1 do
      local h = hash(x, y1, 12)
      px(x, y1 + 1, L.leaf.shade)
      if h < .45 then px(x, y1, L.apple.base) px(x, y1 - 1, (h < .2) and L.apple.hi or L.apple.base) elseif h < .7 then px(x, y1, L.leaf.base) end
    end
  end
  bay(40, 76, 156, 168)
  bay(134, 170, 156, 168)
  -- inside the right bay: a gnome silhouette with a mug
  F.sprite({ "..ss..", ".ssss.", "ssssss", ".sss..", "sssss.", "sssss." }, 140, 160, { s = L.glow.deep }, { rim = false })
  -- a painted sundial between the bay and the door
  do
    local sd = c:ellipse(86, 151, 5, 5)
    c:rim(sd, L.plaster.deep) fill(sd, L.plaster.hi)
    for k = 0, 6 do local a = pi * k / 6 px(floor(86 - cos(a) * 4 + .5), floor(151 + sin(a) * 4 + .5), L.stone.shade) end
    fill(rect(85, 148, 87, 150), L.gold.base) px(85, 148, L.gold.hi) px(86, 151, L.iron.deep)
    line({ { 86, 151 }, { 89, 155 } }):each(function(x, y) px(x, y, L.iron.base) end)
  end
  -- a lantern on a bracket by the door
  fill(rect(122, 147, 128, 147), L.iron.shade) vline(127, 148, 149, L.iron.shade)
  local lam = rect(125, 150, 129, 156) rimOf(lam, L.timber) fill(lam, L.glow.base) px(126, 151, L.glow.hi) vline(129, 151, 156, L.glow.shade)
  for _, p in ipairs({ { 124, 158 }, { 130, 158 }, { 123, 153 }, { 131, 153 }, { 127, 159 } }) do px(p[1], p[2], L.glow.hi) end
  F.smoke(50, 56, 7, .5, 2) F.smoke(162, 52, 8, .8, 3)
end
inn()

-- firewood stacked to the eaves under the left overhang
do
  local X0, X1, Y0, Y1 = 12, 36, 117, 182
  local back = rect(X0, Y0, X1, Y1)
  F.shadow(X0, X1 + 2, Y1, 6, 3)
  rimOf(back, L.timber) fill(back, L.timber.deep)
  local row = 0
  for y = Y1 - 3, Y0 + 2, -5 do
    row = row + 1
    for x = X0 + 3 + (row % 2) * 2, X1 - 2, 5 do
      local v = hash(x, y, 6)
      F.logEnd(x, y, 2, v < .2 and L.redbark or (v > .85 and L.soil or L.timber))
      if hash(x, y, 7) < .25 then px(x - 1, y - 1, L.board.hi) px(x + 1, y + 1, L.board.shade) end
    end
  end
  for _, sx in ipairs({ X0, X1 }) do local s = rect(sx, Y0 - 1, sx + 1, Y1) part(s, L.timber, { nopop = true, noshade = true }) end
  -- a pair of old larch skis leaning on the woodpile, tips curled
  local ski = line({ { 40, 182 }, { 46, 150 }, { 44, 147 } }, 1):add(line({ { 43, 182 }, { 49, 151 }, { 47, 148 } }, 1))
  rimOf(ski, L.timber) part(ski, L.board, { nopop = true, noshade = true })
end

-- the innkeeper in her apron with a mug, on the step
F.depth(3)
local _, ihx, ihy = F.gnome(132, 194, { hat = L.awnA, coat = L.awnB, arm = "out" })
do local mug = rect(ihx, ihy - 5, ihx + 3, ihy) rimOf(mug, L.timber) part(mug, L.glow, { nopop = true }) hline(ihx, ihx + 3, ihy - 5, L.awnB.hi) px(ihx + 4, ihy - 3, L.glow.shade) end
-- the hospice dog: a big St-Bernard-style dog sitting at the door, keg on its collar
F.shadowM(c:ellipse(114, 199, 13, 1))
F.sprite({
  "......bbbbbbb...........",
  ".....bBBBBBBBb..........",
  "....bBBBBwBBBBb.........",
  "...ebBBBwwwBBBbe........",
  "..eebBkBwwwBkBbee.......",
  "..eeddbwwwwwwbddee......",
  "..eee.dwwwwwwwd.eee.....",
  "..eee.ewwnnnwwe.eee.....",
  "...ee.ewwwnwwwe..ee.....",
  "......sWwjjjwWs.........",
  ".....wwsWwwwWswwbbbb....",
  "....wwwwKKKKKwwbBBBBb...",
  "....wwwhKKKKKhwbBBBBBb..",
  "....wwwwKhhhKwwwbBBBBBd.",
  "...wwwwwwKKKwwwwwbBBBBd.",
  "...wwswwwwwwwwwwwwbBBdd.",
  "...wwswwwwwwwwwwwwwbddd.",
  "...wwswww.wwwwwwwwwbdd..",
  "...wwsww..wwwwwwwwwwdd.t",
  "...wwsww..wwwwwwwwwwwd.t",
  "...wwsww..wwwwwwwwwwwwtt",
  "..wwwsww.wwwwwwwwwwwww..",
  "..ppppp..ppppppp.pppp...",
}, 100, 176, { b = L.chamois.base, B = L.chamois.hi, d = L.chamois.shade, e = L.chamois.deep, w = L.goat.hi, W = L.goat.base,
  s = L.goat.shade, k = L.timber.edge, n = L.timber.edge, j = "#e88a8a", K = L.board.base, h = L.iron.shade, p = L.goat.base, t = L.chamois.shade })
px(106, 180, L.goat.hi) px(112, 180, L.goat.hi) -- eye glints
px(109, 187, L.board.hi) px(110, 187, L.board.hi) px(108, 186, L.awnA.base) px(114, 186, L.awnA.base) -- keg lit top, red collar
-- a slate board by the door: a chalk mug and a pie (the stamp board)
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.timber) part(leg, L.timber, { nopop = true, noshade = true })
  fill(bd, L.iron.deep) c:edgeIn(bd, L.timber.base)
  for _, p in ipairs({ { 83, 182 }, { 84, 182 }, { 85, 182 }, { 83, 183 }, { 83, 184 }, { 83, 185 }, { 84, 186 }, { 85, 186 }, { 86, 183 }, { 86, 184 }, { 87, 184 } }) do px(p[1], p[2], L.awnB.base) end
  for x = 90, 95 do px(x, 186, L.awnB.base) end for x = 91, 94 do px(x, 184, L.awnB.shade) end px(90, 185, L.awnB.base) px(95, 185, L.awnB.base)
  -- a chalk edelweiss at the bottom
  px(89, 189, L.awnB.base) px(88, 190, L.awnB.base) px(90, 190, L.awnB.base) px(89, 191, L.awnB.base)
end

---------------------------------------------------------------- the gallows sign post and its tankard board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = rect(189, 192, 202, 198)
  F.shadowM(c:ellipse(204, 199, 12, 2))
  rimOf(union(post, arm, brace, foot), L.timber)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.timber, { nopop = true, noshade = true })
  post:each(function(x, y) if hash(x, y // 3, 37) < .15 then px(x, y, L.timber.shade) end end)
  part(foot, L.stone, { nopop = true }) hline(189, 202, 192, L.stone.hi) F.lichen(foot, .3, 38)
  hline(194, 246, 96, L.timber.hi)
  -- a carved ibex-head finial
  F.sprite({ "h..h", ".hh.", "gGGg", "gGGg", ".gg." }, 244, 90, { h = "#9c9078", g = L.chamois.shade, G = L.chamois.base })
  -- chains
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.iron.shade) px(SX1 - 3, y, L.iron.shade) else px(SX0 + 3, y, L.iron.hi) px(SX1 - 3, y, L.iron.hi) end end
  -- the board: gentian frame, cream field, a big foaming tankard
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.plaster.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.plaster.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  -- little painted edelweiss in a board corner
  px(SX0 + 5, SY1 - 6, L.edel.base) px(SX0 + 4, SY1 - 5, L.edel.base) px(SX0 + 6, SY1 - 5, L.edel.base) px(SX0 + 5, SY1 - 4, L.edel.shade) px(SX0 + 5, SY1 - 5, L.gold.base)
  local tk = rect(213, 136, 227, 149)
  local hnd = c:ellipse(229, 142, 4, 4):cut(c:ellipse(229, 142, 2, 2)):cut(rect(222, 136, 227, 149))
  local foam = c:ellipse(220, 135, 9, 3):add(c:ellipse(216, 133, 3, 2)):add(c:ellipse(223, 132, 3, 2))
  c:rim(union(tk, hnd, foam), L.timber.edge)
  part(tk, L.glow) part(hnd, L.glow, { nopop = true })
  for x = 215, 225, 4 do vline(x, 139, 148, L.glow.shade) end
  hline(213, 227, 138, L.timber.base) hline(213, 227, 147, L.timber.base)
  part(foam, L.awnB, { nopop = true }) px(214, 132, L.awnB.hi) px(215, 131, L.awnB.hi) px(222, 131, L.awnB.hi)
  px(211, 137, L.awnB.base) px(210, 139, L.awnB.base) -- a drip of foam
  -- a lantern hung from the arm by the post
  vline(201, 100, 103, L.iron.shade)
  local lam = rect(199, 104, 203, 110) rimOf(lam, L.timber) fill(lam, L.glow.base) px(200, 105, L.glow.hi) vline(203, 105, 110, L.glow.shade)
  hline(198, 204, 103, L.iron.base)
end
-- QUIRK: a big ginger tabby asleep on top of the board, tail hanging down over the tankard
do
  local by = SY0 - 1
  local body = c:ellipse(226, by - 6, 13, 6):clip(rect(200, by - 14, 245, by))
  local head = c:ellipse(208, by - 7, 7, 6):clip(rect(196, by - 14, 220, by))
  local ears = poly{ { 202, by - 10 }, { 203, by - 17 }, { 207, by - 12 } }:add(poly{ { 209, by - 12 }, { 213, by - 17 }, { 215, by - 9 } })
  local tail = line({ { 238, by - 2 }, { 240, by + 4 }, { 237, by + 12 }, { 233, by + 15 } }, 3)
  local paws = c:ellipse(212, by - 1, 5, 1)
  local cat = union(body, head, ears, tail, paws)
  c:rim(cat, L.timber.edge)
  local O = L.produce
  part(union(body, tail), O, { nopop = true })
  body:each(function(x, y)
    if (x + floor((y - by) * .6)) % 5 == 0 and y < by - 2 then px(x, y, O.shade) end
    if y >= by - 2 then px(x, y, O.shade) end
    if y <= by - 10 and hash(x, y, 3) < .5 then px(x, y, O.hi) end
  end)
  tail:each(function(x, y) if (y - by) % 4 == 0 then px(x, y, O.deep) end end)
  part(head, O, { nopop = true }) part(ears, O, { nopop = true })
  head:each(function(x, y) if y <= by - 11 and (x % 3 == 0) then px(x, y, O.shade) end end)
  px(203, by - 14, "#f2a0a0") px(204, by - 13, "#f2a0a0") px(212, by - 14, "#f2a0a0") px(212, by - 13, "#f2a0a0")
  fill(c:ellipse(208, by - 3, 4, 2), L.awnB.hi) fill(paws, L.awnB.hi) px(209, by - 1, L.awnB.shade) px(213, by - 1, L.awnB.shade)
  px(203, by - 8, L.timber.edge) px(204, by - 7, L.timber.edge) px(205, by - 8, L.timber.edge)
  px(210, by - 8, L.timber.edge) px(211, by - 7, L.timber.edge) px(212, by - 8, L.timber.edge)
  fill(rect(207, by - 6, 208, by - 5), L.apple.base) px(207, by - 6, L.apple.hi)
  px(208, by - 4, L.timber.edge)
  hline(197, 200, by - 5, L.awnB.shade) hline(215, 218, by - 5, L.awnB.shade)
  -- a wisp of hay stuck in its fur
  px(230, by - 12, L.needle.hi) px(231, by - 13, L.needle.base)
  local function zed(x, y, s)
    for i = 0, s do px(x + i, y, L.awnB.hi) px(x + i, y + s, L.awnB.hi) px(x + s - i, y + i, L.awnB.hi) end
  end
  zed(214, by - 24, 3) zed(220, by - 32, 4) zed(228, by - 41, 5)
end

---------------------------------------------------------------- beer garden (right): a big spruce + a larch, festoons, table
F.depth(3)
do
  F.shadowM(c:ellipse(434, 194, 28, 3))
  F.larch(462, 190, 80, 51)
  F.conifer(428, 196, 104, L.foliage2, 52, { w = 30 })
  F.boulder(452, 196, 8, 6, 53)
end
-- festoon lantern strings: sign arm -> pole across the road, pole -> spruce
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.timber.deep) end
  local cols = { L.awnA, L.glow, L.accent, L.glow, L.roof2 }
  local i = startI or 0
  for x = x0 + 8, x1 - 6, step do
    i = i + 1
    local y = ly(x) + 1
    local r = cols[i % #cols + 1]
    local m = c:rrect(x - 2, y + 1, x + 2, y + 6, 1)
    c:rim(m, L.timber.edge) fill(m, r.base) px(x - 1, y + 2, r.hi) vline(x + 2, y + 2, y + 5, r.shade) px(x, y, L.timber.deep)
    px(x, y + 7, r.deep)
  end
end
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.timber) part(pole, L.timber, { nopop = true, noshade = true })
  F.sprite({ ".g.", "ggg" }, 287, 113, { g = L.foliage2.base }) -- a spruce sprig tied to the pole top
  festoon(289, 117, 412, 128, 3, 12, 0)
  festoon(246, 100, 288, 117, 4, 11, 2)
end
-- barrel stack against the pole
F.barrel(300, 206, L.timber, 12) F.barrel(312, 207, L.board, 12) F.barrel(306, 194, L.timber, 11)
-- long trestle table with three gnomes behind it, raising mugs
local function mugAt(x, y)
  local m = rect(x, y - 5, x + 3, y)
  c:rim(m, L.timber.edge) part(m, L.glow, { nopop = true }) hline(x, x + 3, y - 5, L.awnB.hi) hline(x - 1, x + 4, y - 6, L.awnB.base) px(x + 4, y - 3, L.glow.shade)
end
do
  local g1 = { 338, 210, L.roof2, L.leaf, "up" }
  local g2 = { 366, 209, L.lav, L.wall2, "up" }
  local g3 = { 394, 210, L.leaf, L.awnA, "out" }
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    mugAt(hx - 1, hy)
  end
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  -- the table: thick larch planks on X trestles
  local top = rect(322, 209, 414, 213)
  local legs = line({ { 326, 228 }, { 334, 214 } }, 2):add(line({ { 334, 228 }, { 326, 214 } }, 2))
    :add(line({ { 402, 228 }, { 410, 214 } }, 2)):add(line({ { 410, 228 }, { 402, 214 } }, 2))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 10, 3)
  rimOf(union(top, legs, bench), L.timber)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(bench, L.timber, { nopop = true }) F.planks(bench, L.timber, 9, false, 5) hline(318, 418, 224, L.timber.hi)
  part(top, L.board) F.planks(top, L.board, 9, false, 7) hline(322, 414, 209, L.board.hi) hline(322, 414, 213, L.timber.base)
  mugAt(348, 208) mugAt(380, 208)
  local loaf = c:ellipse(362, 206, 5, 3) rimOf(loaf, L.soil) part(loaf, L.produce) px(360, 205, L.produce.hi) hline(359, 365, 206, L.produce.shade) for k = 0, 2 do px(359 + k * 3, 204, L.produce.deep) end
  -- a mountain cheese, a wedge cut out
  local ch = c:rrect(386, 201, 400, 208, 2):cut(poly{ { 393, 201 }, { 401, 201 }, { 401, 205 } })
  c:rim(ch, L.cheese.edge) part(ch, L.cheese, { nopop = true }) hline(387, 393, 201, L.cheese.hi) hline(387, 399, 208, L.cheese.deep)
  px(395, 204, L.cheese.shade) px(397, 205, L.cheese.shade) px(389, 205, L.cheese.shade)
  -- a plate of dried meat and a candle in a jar
  local plate = c:ellipse(334, 208, 6, 1) fill(plate, L.awnB.base) fill(c:ellipse(334, 206, 4, 2), L.apple.deep) hline(331, 337, 205, L.apple.shade)
  px(332, 205, L.awnB.hi) px(336, 206, L.awnB.hi)
  fill(rect(371, 204, 373, 208), L.awnB.hi) px(372, 203, L.glow.hi) px(372, 202, L.glow.base)
end
-- the waiter crossing the road with a tray of mugs
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.accent, coat = L.awnA, arm = "up", flip = true })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.iron) part(tray, L.iron, { nopop = true, noshade = true })
  mugAt(hx - 8, hy - 2) mugAt(hx - 3, hy - 2) mugAt(hx + 2, hy - 2)
end

---------------------------------------------------------------- foreground left: granite fountain trough, hitching rail, firewood, barrel roller
F.depth(3)
do
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.timber) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 212, L.timber.hi)
  F.logEnd(22, 213, 1) F.logEnd(104, 213, 1)
  fill(rect(40, 214, 41, 218), L.board.shade) -- a tied rope
  -- the fountain post: a larch trunk with a spout, pouring into the trough
  local post = rect(58, 196, 63, 221)
  rimOf(post, L.timber) part(post, L.timber, { nopop = true })
  post:each(function(x, y) if (y % 4 == 0) and hash(x, y, 47) < .5 then px(x, y, L.timber.deep) end end)
  F.logEnd(60, 195, 3)
  local spout = rect(52, 202, 58, 203) rimOf(spout, L.timber) fill(spout, L.board.shade) px(52, 202, L.iron.base)
  -- the granite trough
  F.shadow(32, 96, 234, 8, 3)
  local t = rect(30, 220, 96, 232)
  rimOf(t, L.stone) part(t, L.stone) F.courses(t, 220, 6, 11, L.stone) F.lichen(t, .2, 46)
  fill(rect(30, 219, 96, 219), L.stone.hi)
  local w = rect(32, 221, 94, 223)
  fill(w, L.water.base) hline(32, 94, 221, L.water.hi) for x = 36, 92, 9 do px(x, 222, L.water.hi) px(x + 1, 222, "#eef6e6") end
  -- the stream from the spout and its splash rings
  for y = 204, 221 do px(51, y, (y % 3 == 0) and L.water.hi or L.water.base) if y > 206 then px(50, y, (y % 4 == 1) and "#eef6e6" or L.water.hi) end end
  hline(46, 55, 221, "#eef6e6") px(44, 222, L.water.hi) px(57, 222, L.water.hi)
  -- moss in the damp at the foot
  for x = 30, 96 do if hash(x, 1, 77) < .35 then px(x, 232, L.mossGround.base) px(x, 231, hash(x, 2, 77) < .5 and L.mossGround.hi or L.mossGround.shade) end end
end
do -- firewood stack under a little slab lean-to by the inn wall
  local stackM = rect(146, 196, 184, 212)
  F.shadow(146, 186, 213, 6, 3)
  rimOf(stackM, L.timber) fill(stackM, L.timber.shade)
  for row = 0, 2 do for k = 0, 6 do
    local cx, cy = 149 + k * 6 + (row % 2) * 3, 199 + row * 5
    if cx <= 182 then
      local tr = (hash(k, row, 8) < .3) and L.redbark or L.board
      local lg = c:ellipse(cx, cy, 2.5, 2.5)
      fill(lg, tr.hi) px(cx, cy, tr.shade) px(cx + 1, cy, tr.base)
      lg:edge():each(function(x, y) px(x, y, (x > cx or y > cy) and L.timber.base or tr.base) end)
    end
  end end
  local lean = poly{ { 142, 196 }, { 188, 192 }, { 188, 195 }, { 142, 199 } }
  rimOf(lean, L.roof) part(lean, L.roof, { nopop = true }) F.lichen(lean, .25, 42)
  weightStone(156, 194, 2, 1) weightStone(176, 192, 2, 1)
end
-- a chopping stump by the road with the axe bitten in, split billets and chips
do
  local x, yb, w = 194, 230, 6
  F.shadowM(c:ellipse(198, 231, 9, 1))
  local body = rect(x - w, yb - 7, x + w, yb)
  local top = c:ellipse(x, yb - 7, w, 2)
  rimOf(union(body, top), L.timber) part(body, L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, 44) < .6 then px(xx, yy, L.timber.shade) end end)
  fill(top, L.board.base) px(x, yb - 7, L.board.shade) hline(x - 3, x - 1, yb - 8, L.board.hi)
  line({ { x + 1, yb - 8 }, { x + 7, yb - 18 } }):each(function(xx, yy) px(xx, yy, L.board.base) px(xx + 1, yy, L.board.shade) end)
  fill(rect(x - 2, yb - 10, x + 2, yb - 8), L.iron.base) px(x - 2, yb - 10, L.iron.hi) px(x + 2, yb - 8, L.iron.deep)
  for _, s in ipairs({ { 178, 234 }, { 184, 238 }, { 200, 238 } }) do
    local m = poly{ { s[1], s[2] }, { s[1] + 5, s[2] - 2 }, { s[1] + 6, s[2] }, { s[1] + 1, s[2] + 2 } }
    rimOf(m, L.timber) fill(m, L.board.base) px(s[1] + 1, s[2], L.board.hi) px(s[1] + 5, s[2] - 1, L.timber.base)
  end
  for i = 0, 6 do px(184 + floor(hash(i, 1, 46) * 22), 229 + floor(hash(i, 2, 46) * 6), L.board.hi) end
end
-- a gnome rolling a barrel along toward the inn
do
  local _, hx, hy = F.gnome(176, 252, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.timber) part(b, L.timber)
  vline(155, 241, 253, L.iron.shade) vline(163, 241, 253, L.iron.shade) hline(153, 165, 246, L.timber.hi)
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 } }) do px(p[1], p[2], L.ground.hi) end
end
-- crate of green bottles, sacks, a boulder, edelweiss and junipers, bottom left
do
  F.crate(40, 256, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 238, bx + 2, 244):add(rect(bx + 1, 235, bx + 1, 237))
    c:rim(b, L.timber.edge) fill(b, L.leaf.shade) px(bx, 239, L.leaf.hi) px(bx + 1, 235, L.produce.base)
  end
  F.sack(86, 258, L.awnB, 7)
  F.sack(100, 262, L.board, 6)
  F.boulder(124, 262, 8, 6, 43)
  F.juniper(16, 244, 8, 6, 5) F.juniper(70, 266, 9, 5, 6)
  F.edelweiss(24, 252, true) F.edelweiss(30, 256, true) F.edelweiss(112, 250, true)
  F.gentian(136, 256, true) F.gentian(140, 260, true) F.gentian(20, 262, true)
end
-- a half-barrel tub of geraniums and alpine roses by the road
do
  local tub = c:rrect(210, 226, 228, 240, 3)
  F.shadowM(c:ellipse(222, 241, 10, 1))
  rimOf(tub, L.timber) part(tub, L.timber) hline(210, 228, 230, L.iron.shade) hline(210, 228, 237, L.iron.shade)
  local fl = c:ellipse(219, 222, 10, 5)
  rimOf(fl, L.leaf) part(fl, L.leaf, { nopop = true })
  for i = 0, 14 do local fx, fy = 211 + floor(hash(i, 1, 5) * 17), 218 + floor(hash(i, 2, 5) * 7) px(fx, fy, (i % 3 == 0) and L.petal.base or L.apple.base) px(fx + 1, fy, (i % 3 == 0) and L.petal.hi or L.apple.hi) end
end

-- alpine choughs after the crumbs dropped from the table
F.depth(3)
chough(318, 252) chough(342, 258, true) chough(360, 246, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 350, 255 }, { 329, 250 } }) do px(g[1], g[2], L.produce.hi) end
-- a spare cart wheel leaning on the barrels
do local w = c:ellipse(290, 214, 7, 8) rimOf(w, L.timber) part(w, L.timber, { nopop = true })
  fill(c:ellipse(290, 214, 4, 5), L.ground.shade) vline(290, 207, 221, L.timber.deep) hline(284, 296, 214, L.timber.deep) fill(rect(289, 213, 291, 215), L.iron.base) end
-- junipers, flowers and a young spruce around the garden (clear of the compass corner)
F.conifer(448, 226, 26, L.foliage2, 53)
F.juniper(304, 262, 9, 5, 7) F.juniper(374, 262, 6, 4, 8) F.juniper(466, 214, 8, 5, 9)
for _, f in ipairs({ { 290, 250 }, { 284, 236 }, { 432, 222 }, { 300, 240 }, { 368, 252 } }) do F.edelweiss(f[1], f[2], true) end
F.gentian(296, 244, true) F.gentian(426, 218, true) F.gentian(312, 262, true)
-- a goat tied to the hitching rail, chewing the rope
F.depth(3)
F.sprite({
  "...h.h..............",
  "..hWhW..............",
  ".WWWWWW.............",
  "WkWWWWWw............",
  "WWWWWWWWWWWWWWWw..t.",
  ".pWWw.WWWWWWWWWWWtt.",
  "..bb..WWWWWWWWWWWw..",
  "..b...WWwWWWWWWwWw..",
  "......sWwwwwwwwwws..",
  "......sWw.....wWs...",
  "......sw......ws....",
  "......ss......ss....",
  "......oo......oo....",
}, 106, 214, { W = L.goat.hi, w = L.goat.base, s = L.goat.shade, h = "#9c9078", k = L.timber.edge, p = "#f2a0a0", b = L.goat.shade, t = L.goat.shade, o = L.timber.deep })
for _, p in ipairs({ { 116, 219 }, { 117, 219 }, { 118, 220 }, { 122, 221 }, { 123, 221 } }) do px(p[1], p[2], L.goat.shade) end
for x = 100, 106 do px(x, 218 + (x - 100) // 3, L.board.deep) end
F.shadowM(c:ellipse(118, 228, 10, 1))
-- a St-Bernard pup asleep under the table between the legs
F.sprite({
  "....bb..........",
  "...bBBw.....bb..",
  "..bwkwWWWWbbWWb.",
  "dbWWWWWWWWBBWWWb",
  ".dddWWssWWWWssWt",
  "...ddd..ddddd.tt",
}, 364, 217, { b = L.chamois.base, B = L.chamois.hi, W = L.goat.hi, w = L.goat.base, s = L.goat.shade, d = L.chamois.shade, k = L.timber.edge, t = L.chamois.shade })

F.depth(0)
F.birds({ { 330, 52, 2 }, { 342, 46, 1 }, { 136, 30, 2 }, { 380, 78, 2 } })
F.finish()
