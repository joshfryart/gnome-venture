-- camp.lua : "Camp" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition and story as the Maplewold camp (art-2701-batch3/stops/opus3/camp.lua), re-cast for a fen:
-- road's end: the striped two-peak mess marquee (cream and teal canvas) on a low deck between reed beds.
-- Back left: an upturned punt propped as a shelter, a reed-mat skirt; a washing line from an alder to a pollard
-- willow with a drying eel net, a gnome pegging. Right: a round reed hut with a conical reed thatch, glowing door,
-- on a plank deck on stilts over a pool (the bell tent's place). Back right: a hooped canvas houseboat-punt moored
-- in a dyke (the wagon's place). Hero: the camp stands on a raised clay platform with a woven wattle revetment;
-- a raised stone hearth with a tripod pot, reed-bundle seats, a lute player, a toasting gnome, a mug gnome, a dog
-- asleep; an eel-smoking rack with a smudge pot beside the fire. Left: stacked peat turfs between stakes and a
-- moorhen. Bottom left: the camp kitchen table with duck eggs and fish, an eel trap under it. Near right: a punt
-- moored in the pool, ducks. Quirk: an otter in a red gnome hat climbing out of the green pack with an eel.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "camp", out = DIR, farTrees = { 24, 52, 160, 196, 290, 318, 440 }, poolK = .8, treeLineGap = { 196, 284 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local G, IR = L.glow, L.iron
local sage = L.wall2
local EEL = F.rp("#d8b070 #b08048 #845c36 #5c3e2a #3a261c")   -- smoked eel, gold-brown
local EELF = F.rp("#a8a47a #7c7c5a #5c5e46 #404434 #282c22")  -- fresh eel, olive

-- local helpers ------------------------------------------------------------------------
-- the cut end of a reed bundle seen face-on
local function bundleEnd(x, y, r)
  local m = c:ellipse(x, y, r, r)
  c:rim(m, L.reed.edge)
  m:each(function(xx, yy)
    local d = (xx - x) + (yy - y)
    local col = d < -r * .6 and L.reed.hi or (d > r * .6 and L.reed.shade or L.reed.base)
    if (xx + yy * 2) % 3 == 0 then col = (d < 0) and L.reed.base or L.reed.deep end
    px(xx, yy, col)
  end)
  px(x, y, L.reed.deep)
  return m
end
-- a wicker eel trap (grig), a long cone lying or standing. horiz: mouth at x0, tip at x1
local function eelTrap(x0, y0, x1, y1, w)
  local m
  if y0 == y1 then m = poly{ { x0, y0 - w }, { x1, y0 - 1 }, { x1, y0 + 1 }, { x0, y0 + w } }
  else m = poly{ { x0 - w, y0 }, { x0 + w, y0 }, { x1 + 1, y1 }, { x1 - 1, y1 } } end
  rimOf(m, L.reed) part(m, L.reed, { nopop = true })
  m:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) elseif (x - y) % 3 == 0 then px(x, y, L.reed.hi) end end)
  if y0 == y1 then for x = x0 + 4, x1 - 2, 5 do m:each(function(xx, yy) if xx == x then px(xx, yy, L.timber.base) end end) end
    fill(c:ellipse(x0, y0, 1, w - 1), L.reed.deep)
  else for y = y0 + 3, y1 - 2, 4 do m:each(function(xx, yy) if yy == y then px(xx, yy, L.timber.base) end end) end end
  return m
end
-- a hanging eel: wavy 2-px body with a lit left edge, a dark head at the hook
local function eel(x, y, len, r, ph)
  for t = 0, len do
    local xx = x + floor(sin(t * .55 + ph) * 1.3 + .5)
    local col = t < 2 and r.deep or (t > len - 2 and r.shade or r.base)
    px(xx - 1, y + t, r.edge) px(xx + 2, y + t, r.edge)
    px(xx, y + t, t < 2 and r.deep or r.hi) px(xx + 1, y + t, col)
  end
  px(x, y + len + 1, r.edge) px(x + 1, y + len + 1, r.edge)
end

---------------------------------------------------------------- back trees (plane 1)
F.depth(1)
F.tree(10, 140, 46, 1)
F.tree(318, 138, 46, 0)
F.tree(384, 142, 58, 6)
F.tree(444, 136, 44, 5)
F.mist(100, 186, 116, 120, 401, .5) F.mist(296, 372, 115, 119, 402, .45)

---------------------------------------------------------------- road's end: the striped two-peak mess marquee on a low deck
F.depth(2)
F.tree(292, 128, 50, 1)
F.reeds(186, 206, 131, 13, 403, { cattails = 2 })
F.reeds(274, 290, 131, 12, 404, { green = true })
do
  local cx, yb = 240, 128
  local wall = rect(cx - 34, yb - 16, cx + 34, yb)
  local roofm = poly{ { cx - 42, yb - 15 }, { cx - 16, yb - 44 }, { cx, yb - 32 }, { cx + 16, yb - 44 }, { cx + 42, yb - 15 } }
  local poles = rect(cx - 17, yb - 54, cx - 16, yb - 44):add(rect(cx + 16, yb - 54, cx + 17, yb - 44))
  local deck = rect(cx - 40, yb + 1, cx + 40, yb + 3)
  F.boardwalk(deck, true, 405)
  hline(cx - 40, cx + 40, yb + 3, L.board.deep)
  for x = cx - 38, cx + 36, 12 do vline(x, yb + 4, yb + 5, L.timber.deep) end
  rimOf(union(wall, roofm, poles), L.timber)
  local tl = L.accent
  roofm:each(function(x, y)
    local pk = x < cx and cx - 16 or cx + 16
    local u = (x - pk) / (y - (yb - 46))
    local k = floor(u * 5 + 20)
    local h = (k % 2 == 0) and tl.base or L.awnB.hi
    if (u * 5 + 20) % 1 < .14 then h = (k % 2 == 0) and tl.shade or L.awnB.shade end
    if x > pk + 6 and (x - pk) / 26 + (y - (yb - 44)) / 30 > .9 then h = (k % 2 == 0) and tl.shade or L.awnB.base end
    if x < pk - 2 and (pk - x) / 10 + (y - (yb - 44)) / 12 < 1.1 then h = (k % 2 == 0) and tl.hi or L.awnB.hi end
    px(x, y, h)
  end)
  -- willow leaves on the canvas, a damp tide line along the foot
  roofm:each(function(x, y) if hash(x, y, 406) < .008 then px(x, y, L.willow.shade) end end)
  wall:each(function(x, y)
    local k = ((x - cx + 40) // 6) % 2
    local h = k == 0 and L.awnB.base or tl.hi
    if x > cx + 22 then h = k == 0 and L.awnB.shade or tl.base end
    if y >= yb - 2 and hash(x, y, 407) < .55 then h = L.peat.hi end
    px(x, y, h)
  end)
  for x = cx - 40, cx + 38, 6 do fill(poly{ { x, yb - 15 }, { x + 6, yb - 15 }, { x + 3, yb - 11 } }, L.awnA.base) px(x + 3, yb - 12, L.awnA.shade) px(x + 1, yb - 15, L.awnA.hi) end
  hline(cx - 42, cx + 42, yb - 15, L.awnA.deep)
  local door = poly{ { cx - 8, yb }, { cx - 5, yb - 12 }, { cx + 5, yb - 12 }, { cx + 8, yb } }
  fill(door, G.shade) fill(rect(cx - 3, yb - 9, cx + 3, yb), G.base) px(cx - 2, yb - 8, G.hi)
  part(poles, L.timber, { nopop = true, noshade = true })
  for _, p in ipairs({ { cx - 16, L.awnA }, { cx + 17, L.marigold } }) do fill(poly{ { p[1] + 1, yb - 54 }, { p[1] + 10, yb - 52 }, { p[1] + 1, yb - 49 } }, p[2].base) px(p[1] + 2, yb - 53, p[2].hi) end
  for _, g in ipairs({ { cx - 42, cx - 50 }, { cx + 42, cx + 50 } }) do line({ { g[1], yb - 15 }, { g[2], yb + 1 } }):each(function(x, y) px(x, y, L.board.deep) end) end
  fill(rect(cx + 25, yb - 34, cx + 27, yb - 28), IR.base) px(cx + 25, yb - 34, IR.hi) hline(cx + 24, cx + 28, yb - 35, IR.deep)
  F.smoke(cx + 26, yb - 38, 5, .6, 2)
  -- reed bundles stacked by the marquee, a water butt
  for k = 0, 2 do bundleEnd(cx + 38 + k * 4, yb - 2, 2) end
  for k = 0, 1 do bundleEnd(cx + 40 + k * 4, yb - 6, 2) end
  F.barrel(cx - 38, yb, L.timber, 8)
end

---------------------------------------------------------------- back left: an upturned punt propped up as a shelter
F.depth(1)
do
  local x0, x1 = 16, 72
  F.shadow(x0 + 2, x1, 147, 8, 3)
  -- the hull rests on its gunwale at the left and is propped high on two forked stakes at the right
  local under = poly{ { x0 + 6, 145 }, { x1 - 2, 133 }, { x1 - 2, 146 }, { x0 + 6, 146 } }
  fill(under, L.soil.deep)
  under:each(function(x, y) if y > 143 and hash(x, y, 408) < .5 then px(x, y, L.peat.shade) end end)
  -- a bedroll, a pair of boots and a glowing lamp tucked under
  local br = c:rrect(x0 + 26, 141, x0 + 42, 145, 2) rimOf(br, L.awnA) part(br, L.awnA, { nopop = true })
  fill(rect(x1 - 12, 139, x1 - 9, 143), G.base) px(x1 - 12, 139, G.hi) hline(x1 - 13, x1 - 8, 144, IR.shade)
  fill(rect(x0 + 18, 143, x0 + 20, 145), L.timber.base) fill(rect(x0 + 21, 143, x0 + 23, 145), L.timber.shade)
  -- the hull, bottom up: a flat tarred bottom (lit) with raked square ends over the sloping side
  local bottom = poly{ { x0 - 2, 140 }, { x0 + 4, 135 }, { x1 - 2, 121 }, { x1 + 5, 122 }, { x1 + 1, 126 }, { x0 + 2, 143 } }
  local side = poly{ { x0 + 2, 143 }, { x1 + 1, 126 }, { x1 + 1, 131 }, { x0 + 6, 146 } }
  local props = rect(x1 - 6, 128, x1 - 5, 147):add(rect(x1 - 1, 127, x1, 147))
  rimOf(union(bottom, side, props), L.timber)
  part(props, L.timber, { nopop = true, noshade = true })
  part(bottom, sage, { nopop = true }) F.planks(bottom, sage, 3, true, 409)
  part(side, L.timber, { nopop = true })
  side:each(function(x, y) if (x + y) % 6 == 0 then px(x, y, L.timber.shade) end end)
  line({ { x0 + 3, 136 }, { x1 - 2, 122 } }):each(function(x, y) px(x, y, sage.hi) end)
  line({ { x0 + 3, 143 }, { x1, 127 } }):each(function(x, y) px(x, y, L.timber.hi) end)
  -- a reed mat hung down the far end as a wall
  local mat = rect(x1 - 1, 129, x1 + 4, 146)
  rimOf(mat, L.reed) part(mat, L.reed, { nopop = true }) mat:each(function(x, y) if y % 2 == 0 then px(x, y, L.reed.hi) end end)
  hline(x1 - 1, x1 + 4, 136, L.timber.deep) hline(x1 - 1, x1 + 4, 142, L.timber.deep)
end
F.sedge(12, 150, 6) F.sedge(84, 150, 5, L.reed)

---------------------------------------------------------------- washing line from an alder to a pollard willow
F.tree(84, 140, 46, 9)
F.depth(2)
F.tree(186, 140, 50, 3)
local function sagY(x) local t = (x - 88) / (182 - 88) return floor(108 + 8 * sin(t * pi)) end
for x = 88, 182 do px(x, sagY(x), L.awnB.deep) end
for i, it in ipairs({ { 98, L.awnA, "sock" }, { 110, L.accent, "shirt" }, { 146, L.awnB, "shirt" }, { 166, L.lav, "sock" } }) do
  local x = it[1] local y = sagY(x) + 1 local r = it[2]
  local m
  if it[3] == "sock" then m = rect(x, y, x + 3, y + 8):add(rect(x, y + 6, x + 6, y + 9))
  else m = rect(x - 2, y, x + 10, y + 3):add(rect(x + 1, y, x + 7, y + 13)) end
  rimOf(m, r) part(m, r, { nopop = true })
  hline(x, x + 3, y, r.hi) px(x + 1, y - 1, L.timber.base)
  if it[3] == "sock" then hline(x, x + 3, y + 2, L.awnB.hi) end
end
-- a drying eel net, mesh with cork floats along its head
do
  local x0, x1 = 124, 140
  local net = HP.mask()
  for x = x0, x1 do local y0 = sagY(x) + 1 for y = y0, y0 + 14 - floor(math.abs(x - 132) * .3) do net:set(x, y) end end
  net:each(function(x, y) local a, b = (x + y) % 4, (x - y) % 4 if a == 0 or b == 0 then px(x, y, (x < 132) and L.awnB.base or L.awnB.shade) end end)
  for x = x0 + 1, x1, 4 do local y = sagY(x) + 1 fill(rect(x, y, x + 1, y + 1), L.needle.base) px(x, y, L.needle.hi) end
end

---------------------------------------------------------------- back right: a hooped canvas punt moored in a dyke
F.depth(2)
do
  local dyke = poly{ { 372, 142 }, { 476, 139 }, { 476, 160 }, { 384, 160 }, { 374, 152 } }
  rimOf(dyke, L.peat)
  dyke:grow(1):cut(dyke):each(function(x, y) px(x, y, hash(x, y, 410) < .5 and L.peat.base or L.peat.hi) end)
  F.water(dyke, L.water)
  F.tree(468, 150, 46, 2)
  local x0, yb = 398, 154
  local hull = poly{ { x0 - 4, yb - 6 }, { x0 + 64, yb - 6 }, { x0 + 60, yb }, { x0, yb } }
  local cover = HP.mask()
  for k = 0, 3 do cover:add(c:ellipse(x0 + 12 + k * 13, yb - 12, 8, 13):clip(rect(x0 + 4, yb - 30, x0 + 56, yb - 6))) end
  cover:add(rect(x0 + 6, yb - 16, x0 + 54, yb - 6))
  local pipe = rect(x0 + 46, yb - 34, x0 + 48, yb - 22)
  rimOf(union(hull, cover, pipe), L.timber)
  part(hull, sage, { nopop = true }) hline(x0 - 4, x0 + 64, yb - 6, sage.hi) hline(x0, x0 + 60, yb - 3, sage.deep)
  F.planks(hull:copy():clip(rect(x0 - 4, yb - 5, x0 + 64, yb)), sage, 3, false, 411)
  part(cover, L.awnB)
  for k = 1, 3 do vline(x0 + 5 + k * 13, yb - 26, yb - 7, L.awnB.shade) end
  cover:each(function(x, y) if y > yb - 9 and hash(x, y, 412) < .5 then px(x, y, L.awnB.shade) end end)
  -- open stern with lamp light, a reed-cutter's hook on the roof
  fill(rect(x0 + 6, yb - 14, x0 + 10, yb - 7), G.shade) fill(rect(x0 + 7, yb - 12, x0 + 9, yb - 7), G.base)
  part(pipe, IR, { nopop = true, noshade = true }) hline(x0 + 45, x0 + 49, yb - 35, IR.deep)
  F.smoke(x0 + 47, yb - 38, 5, .7, 2)
  for xx = x0, x0 + 60 do if hash(xx, 1, 413) < .6 then px(xx, yb + 1, xx % 3 == 0 and L.water.hi or L.water.deep) end end
  -- mooring post and rope
  local post = rect(384, 138, 386, 156) rimOf(post, L.timber) part(post, L.timber, { nopop = true, noshade = true }) px(384, 138, L.timber.hi)
  line({ { 386, 142 }, { x0 - 4, yb - 5 } }):each(function(x, y) px(x, y, L.board.deep) end)
  hline(376, 470, 157, L.water.shade)
end
F.depth(3)

---------------------------------------------------------------- right: round reed hut on a stilted deck over a pool
F.depth(3)
local pool = poly{ { 290, 201 }, { 410, 199 }, { 476, 204 }, { 476, 229 }, { 444, 229 }, { 412, 222 }, { 380, 214 }, { 330, 212 }, { 296, 210 } }
rimOf(pool, L.peat)
pool:grow(2):cut(pool):each(function(x, y) if y > 199 then local v = hash(x, y, 414) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
F.water(pool, L.water)
F.water(pool:copy():clip(rect(286, 199, 412, 210)), L.water, { dark = true })
local function reedHut(cx, yb)
  F.stilts({ cx - 54, cx - 38, cx - 20, cx + 18, cx + 36, cx + 52 }, yb + 4, yb + 15, yb + 11)
  local deck = rect(cx - 58, yb - 2, cx + 56, yb + 3)
  F.boardwalk(deck, true, 415)
  hline(cx - 58, cx + 56, yb + 3, L.board.deep) hline(cx - 58, cx + 56, yb + 2, L.board.shade)
  local wall = rect(cx - 42, yb - 24, cx + 42, yb - 3)
  local cone = poly{ { cx - 52, yb - 20 }, { cx - 34, yb - 42 }, { cx - 6, yb - 64 }, { cx + 6, yb - 64 }, { cx + 34, yb - 42 }, { cx + 52, yb - 20 } }
  local knob = poly{ { cx - 7, yb - 63 }, { cx - 4, yb - 72 }, { cx + 4, yb - 72 }, { cx + 7, yb - 63 } }
  local pole = rect(cx - 1, yb - 82, cx, yb - 73)
  F.shadow(cx - 40, cx + 44, yb - 2, 12, 4)
  rimOf(union(wall, cone, knob, pole), L.roof)
  -- woven reed-screen wall, lashed to two rails, lit left, shaded right
  wall:each(function(x, y)
    local k = (x - cx + 64) % 4
    local col = k == 0 and L.reed.deep or (k == 1 and L.reed.hi or L.reed.base)
    if (y + ((x - cx + 64) // 4) * 3) % 5 == 0 and k > 0 then col = L.reed.shade end
    if x > cx + 24 then col = (k == 0) and L.reed.edge or (k == 1 and L.reed.base or L.reed.shade) end
    if y >= yb - 5 and hash(x, y, 416) < .5 then col = L.peat.base end
    px(x, y, col)
  end)
  for _, ry in ipairs({ yb - 19, yb - 9 }) do
    hline(cx - 42, cx + 42, ry, L.timber.base) hline(cx - 42, cx + 42, ry + 1, L.timber.deep)
    for x = cx - 40, cx + 40, 8 do px(x, ry - 1, L.timber.deep) px(x, ry + 2, L.timber.deep) end
  end
  -- the cone: golden reed thatch, combed radially, lit upper left, the right flank in shade
  part(cone, L.roof, { nopop = true })
  cone:each(function(x, y)
    local u = (x - cx) / math.max(1, (y - (yb - 68)))
    local f = (u * 7 + 20) % 1
    local h = L.roof.base
    if x > cx + 14 and (x - cx) / 52 + (y - (yb - 64)) / 44 > .75 then h = L.roof.shade end
    if x < cx - 4 and (cx - x) / 30 + (y - (yb - 64)) / 30 < 1.15 then h = L.roof.hi end
    if f < .12 then h = (x > cx + 14) and L.roof.deep or L.roof.shade end
    px(x, y, h)
  end)
  F.thatch(cone, L.roof, yb - 64, cx + 10)
  -- ragged eave
  for x = cx - 52, cx + 52 do local d = floor(hash(x, 1, 417) * 3) for y = yb - 21, yb - 20 + d do px(x, y, (y == yb - 20 + d) and L.roof.edge or L.roof.deep) end end
  -- a sedge-bound top knot with a smoke hole, a pennant
  part(knob, L.roof2, { nopop = true })
  knob:each(function(x, y) if (y - (yb - 72)) % 3 == 0 then px(x, y, L.roof2.deep) elseif x < cx - 1 then px(x, y, L.roof2.hi) end end)
  hline(cx - 3, cx + 3, yb - 72, L.soil.deep)
  part(pole, L.timber, { nopop = true, noshade = true })
  local fl = poly{ { cx + 1, yb - 82 }, { cx + 12, yb - 79 }, { cx + 1, yb - 76 } } fill(fl, L.awnA.base) px(cx + 2, yb - 81, L.awnA.hi) px(cx + 9, yb - 79, L.awnA.shade)
  F.smoke(cx + 4, yb - 78, 5, .6, 2)
  -- the glowing doorway, a rolled reed blind over it, a rug, a lantern inside
  local door = c:rrect(cx - 9, yb - 26, cx + 9, yb - 3, 6):clip(rect(cx - 9, yb - 24, cx + 9, yb - 3))
  fill(door, G.deep)
  local inner = door:shrink(1)
  fill(inner, G.shade)
  fill(c:rrect(cx - 6, yb - 22, cx + 6, yb - 3, 4):clip(rect(cx - 6, yb - 21, cx + 6, yb - 3)), G.base)
  fill(rect(cx - 2, yb - 18, cx + 1, yb - 13), G.hi) vline(cx, yb - 22, yb - 19, L.timber.edge) px(cx - 1, yb - 17, L.awnB.hi)
  fill(rect(cx - 6, yb - 6, cx + 6, yb - 3), L.awnA.shade) hline(cx - 6, cx + 6, yb - 6, L.awnA.base)
  for x = cx - 5, cx + 5, 3 do px(x, yb - 4, L.marigold.base) end
  local blind = c:rrect(cx - 12, yb - 28, cx + 12, yb - 24, 2)
  rimOf(blind, L.reed) part(blind, L.reed, { nopop = true }) hline(cx - 10, cx + 10, yb - 27, L.reed.hi)
  for x = cx - 8, cx + 8, 8 do vline(x, yb - 28, yb - 24, L.timber.deep) end
  bundleEnd(cx + 12, yb - 26, 2)
  -- leaning sheaves left, a hanging net and a paddle right, eel traps by the door
  for k = 0, 3 do
    local sx = cx - 38 + k * 4
    local m = poly{ { sx, yb - 3 }, { sx + 3, yb - 3 }, { sx + 6, yb - 28 }, { sx + 4, yb - 30 } }
    rimOf(m, L.reed) part(m, L.reed, { nopop = true })
    m:each(function(x, y) if (x + k) % 2 == 0 then px(x, y, L.reed.hi) end end)
    hline(sx + 1, sx + 4, yb - 14, L.timber.deep)
    px(sx + 5, yb - 31, L.plume.base) px(sx + 4, yb - 32, L.plume.hi)
  end
  local net = poly{ { cx + 20, yb - 22 }, { cx + 36, yb - 22 }, { cx + 33, yb - 6 }, { cx + 23, yb - 6 } }
  net:each(function(x, y) if (x + y) % 3 == 0 or (x - y) % 3 == 0 then px(x, y, L.awnB.shade) end end)
  hline(cx + 20, cx + 36, yb - 22, L.timber.base)
  for x = cx + 22, cx + 35, 4 do px(x, yb - 22, L.needle.base) end
  local pad = line({ { cx + 40, yb - 34 }, { cx + 44, yb - 4 } }, 1):add(c:rrect(cx + 42, yb - 14, cx + 46, yb - 3, 2))
  rimOf(pad, L.timber) part(pad, L.board, { nopop = true, noshade = true })
  eelTrap(cx - 16, yb - 4, cx - 15, yb - 16, 3)
  eelTrap(cx + 14, yb - 4, cx + 15, yb - 13, 2)
end
reedHut(350, 196)
-- lilies and a frog in the pool, rushes at its ends
for _, p in ipairs({ { 300, 206, true, "white" }, { 322, 209, false }, { 376, 211, true }, { 428, 214, true, "yellow" }, { 446, 222, false }, { 468, 214, true } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.frog(378, 210, false)
F.reeds(284, 296, 210, 14, 418, { cattails = 2, green = true })

---------------------------------------------------------------- near right: a punt moored in the pool, ducks
F.punt(404, 462, 219, L.timber, { pole = { 416, 204, 448, 226 } })
F.sack(420, 215, L.plaster, 3)
eelTrap(430, 214, 446, 214, 3)
do -- a pair of mallards
  local function duck(x, y, drake)
    local rows = drake and { "..hh.....", ".hhkY....", "..hh.....", "..ww.....", ".BBBBBBBt", "BBbbbbBtt", ".BBBBBB.." }
      or { "..hh.....", ".hhkY....", "..hh.....", "..hh.....", ".BBBBBBBt", "BBbbbbBtt", ".BBBBBB.." }
    local map = drake and { h = L.accent.shade, k = L.timber.edge, Y = L.marigold.base, w = L.awnB.hi, B = L.goose.shade, b = L.goose.base, t = L.goose.deep }
      or { h = L.cattail.shade, k = L.timber.edge, Y = L.gold.shade, B = L.cattail.shade, b = L.cattail.hi, t = L.cattail.deep }
    F.sprite(rows, x, y, map)
    for xx = x - 2, x + 10 do if hash(xx, y, 419) < .7 then px(xx, y + 7, (xx < x + 4) and L.water.hi or F.SKYREF) end end
  end
  duck(452, 206, true) duck(440, 210, false)
end
F.reeds(466, 478, 228, 18, 420, { cattails = 2 })
F.dragonfly(398, 206, L.accent, true)

---------------------------------------------------------------- the raised camp platform: clay top, wattle revetment
F.depth(3)
F.reeds(150, 178, 176, 10, 421, { green = true })
F.reeds(20, 44, 180, 9, 422)
local platPts = { { 8, 184 }, { 28, 177 }, { 80, 173 }, { 150, 172 }, { 200, 176 }, { 214, 176 }, { 188, 262 }, { 120, 263 }, { 40, 262 }, { 8, 258 } }
local plat = poly(platPts)
plat:each(function(x, y) if x > F.xl(y) - 4 then end end)
local platC = HP.mask()
plat:each(function(x, y) if x <= F.xl(y) - 4 then platC:set(x, y) end end)
plat = platC
rimOf(plat, L.peat)
plat:each(function(x, y)
  local b = hash(x // 6, y // 2, 423)
  local h = b < .45 and L.peat.hi or (b < .8 and L.peat.base or L.soil.hi)
  local v = hash(x, y, 424)
  if v < .03 then h = L.reed.hi elseif v > .975 then h = L.peat.shade end
  if not plat:has(x, y - 1) then h = L.sedgeGround.hi elseif not plat:has(x, y - 2) then h = L.sedgeGround.base end
  px(x, y, h)
end)
-- strewn reed straw
for i = 0, 140 do
  local x, y = 12 + floor(hash(i, 1, 425) * 196), 176 + floor(hash(i, 2, 425) * 84)
  local n = 2 + floor(hash(i, 3, 425) * 3)
  local dir = hash(i, 4, 425) < .5 and 1 or -1
  for k = 0, n do local xx, yy = x + k, y + ((k == n) and dir * 0 or 0) if plat:has(xx, yy) then px(xx, yy, k == n and L.reed.shade or L.reed.hi) end end
end
-- the front revetment: woven wattle between stakes, below the platform's lower edge
do
  local bot = {}
  plat:each(function(x, y) if not bot[x] or y > bot[x] then bot[x] = y end end)
  for x, yb in pairs(bot) do
    for d = 1, 6 do
      local y = yb + d
      local k = ((x + (d % 2) * 2) // 2) % 2
      local col = k == 0 and L.willowBark.base or L.willowBark.shade
      if d == 1 then col = L.peat.deep end
      if (d % 2 == 0) and (x % 4 == 0) then col = L.willowBark.hi end
      if x % 9 == 0 then col = (d < 3) and L.timber.hi or L.timber.shade end
      if d == 6 then col = L.water.deep end
      px(x, y, col)
    end
  end
  -- the left flank (x 8..10) as a stake row
  for y = 186, 262, 4 do vline(8, y, y + 2, L.timber.shade) end
end
-- pile heads along the back lip (the platform is driven into the fen), and rush mats under the seats
do
  local top = {}
  plat:each(function(x, y) if not top[x] or y < top[x] then top[x] = y end end)
  for x = 14, 204, 15 do if top[x] then
    local m = rect(x, top[x] - 3, x + 2, top[x] + 1) rimOf(m, L.timber) part(m, L.timber, { nopop = true, noshade = true })
    hline(x, x + 2, top[x] - 3, L.board.hi) px(x + 1, top[x] - 3, L.board.shade)
  end end
  for _, mt in ipairs({ { 84, 196, 124, 203 }, { 150, 196, 176, 203 } }) do
    local m = rect(mt[1], mt[2], mt[3], mt[4])
    m:each(function(x, y) local k = ((x // 2) + y) % 2 px(x, y, k == 0 and L.reedGreen.shade or L.reed.shade) if y == mt[2] then px(x, y, L.reed.base) end end)
    hline(mt[1], mt[3], mt[4], L.reedGreen.deep)
  end
end
-- a boardwalk from the causeway in to the hearth
local walk = poly{ { 162, 226 }, { 212, 223 }, { 210, 233 }, { 160, 236 } }
local walkC = HP.mask() walk:each(function(x, y) if plat:has(x, y) or x <= F.xl(y) + 1 then walkC:set(x, y) end end)
F.boardwalk(walkC, true, 426)

---------------------------------------------------------------- left: stacked peat turfs between stakes, a moorhen
local function peatStack(x0, x1, yb)
  local stakes = rect(x0 - 2, yb - 22, x0, yb):add(rect(x1, yb - 22, x1 + 2, yb))
  local stack = rect(x0 + 1, yb - 18, x1 - 1, yb)
  F.shadow(x0, x1 + 2, yb, 8, 3)
  rimOf(union(stakes, stack), L.timber)
  part(stakes, L.timber, { nopop = true, noshade = true })
  px(x0 - 2, yb - 22, L.timber.hi) px(x1, yb - 22, L.timber.hi)
  fill(stack, L.peat.edge)
  for row = 0, 3 do
    local y = yb - 4 - row * 5
    for k = -1, (x1 - x0) // 8 do
      local tx = x0 + 1 + k * 8 + (row % 2) * 4
      local m = rect(tx, y, tx + 6, y + 3):clip(stack)
      m:each(function(x, yy)
        local col = (yy == y) and L.peat.hi or ((x == tx + 6 or yy == y + 3) and L.peat.shade or L.peat.base)
        if hash(x, yy, 427 + row) < .18 then col = L.peat.deep elseif hash(x, yy, 428) > .92 then col = L.reed.shade end
        px(x, yy, col)
      end)
    end
  end
  local lid = rect(x0 - 3, yb - 25, x1 + 3, yb - 21)
  rimOf(lid, L.roof) part(lid, L.roof, { nopop = true }) F.thatch(lid, L.roof, yb - 25) hline(x0 - 3, x1 + 3, yb - 21, L.roof.deep)
  hline(x0 - 3, x1 + 3, yb - 25, L.roof.hi)
end
peatStack(22, 72, 196)
F.sprite({
  "......kk...",
  ".....kkkRy.",
  ".....kekR..",
  ".....kkk...",
  "..wkkkkkk..",
  ".wwSkkkkkk.",
  "wwSSkkwkkk.",
  ".wSSSkkwwk.",
  "...SSSSSS..",
  "....g..g...",
  "...gg.gg...",
}, 76, 186, { k = IR.deep, S = IR.shade, w = L.awnB.hi, e = L.apple.base, R = L.apple.base, y = L.marigold.base, g = L.reedGreen.base })
-- a gnome pegging the net on the washing line
F.gnome(140, 134, { small = true, hat = L.produce, coat = L.leaf, arm = "up" })

---------------------------------------------------------------- eel-smoking rack beside the fire, a smudge pot under it
do
  local p1, p2, top, base = 182, 204, 162, 200
  local posts = rect(p1, top, p1 + 1, base):add(rect(p2, top, p2 + 1, base))
  local bar = rect(p1 - 2, top + 1, p2 + 3, top + 2)
  local bar2 = rect(p1, top + 16, p2 + 1, top + 16)
  F.shadow(p1, p2 + 2, base, 6, 2)
  rimOf(union(posts, bar), L.willowBark)
  part(posts, L.willowBark, { nopop = true, noshade = true }) vline(p1, top, base, L.willowBark.hi) vline(p2, top, base, L.willowBark.hi)
  part(bar, L.willowBark, { nopop = true, noshade = true }) hline(p1 - 2, p2 + 3, top + 1, L.willowBark.hi)
  hline(p1, p2 + 1, top + 16, L.willowBark.shade)
  -- smudge pot
  local pot = c:rrect(188, 192, 198, 199, 2) rimOf(pot, IR) part(pot, IR) hline(189, 197, 192, IR.deep)
  for x = 189, 197 do if hash(x, 1, 429) < .6 then px(x, 191, (x % 2 == 0) and G.shade or G.deep) end end
  px(192, 190, G.base) px(195, 191, G.base)
  F.smoke(193, 186, 6, .25, 2)
  -- the eels: a row from the top bar, a shorter row from the lower bar
  for k = 0, 6 do
    local x = p1 + 3 + k * 3
    px(x, top + 3, IR.hi)
    eel(x, top + 4, 9 + floor(hash(k, 1, 430) * 5), EEL, k * 1.3)
  end
  for k = 0, 3 do local x = p1 + 4 + k * 5 px(x, top + 17, IR.hi) eel(x, top + 18, 6 + k % 2 * 2, EEL, k) end
  -- a basket of fresh eels at the foot
  local bk = c:rrect(196, 199, 208, 206, 2) rimOf(bk, L.reed) part(bk, L.reed, { nopop = true })
  bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) end end)
  for k = 0, 3 do local x = 198 + k * 3 px(x, 198, EELF.base) px(x + 1, 197, EELF.hi) px(x + 1, 198, EELF.shade) end
end

---------------------------------------------------------------- the hearth (hero): raised stone hearth, tripod pot, reed-bundle seats
local function campfire(cx, cy)
  local function seat(x0, x1, y)
    local m = c:rrect(x0, y - 4, x1, y + 4, 4)
    F.shadow(x0, x1, y + 6, 4, 2)
    rimOf(m, L.reed) part(m, L.reed, { nopop = true })
    m:each(function(x, yy)
      if yy < y - 1 and (x + yy) % 3 ~= 0 then px(x, yy, L.reed.hi)
      elseif yy > y + 1 then px(x, yy, (x + yy) % 3 == 0 and L.reed.deep or L.reed.shade)
      elseif (x * 2 + yy) % 5 == 0 then px(x, yy, L.reed.shade) end
    end)
    for bx = x0 + 6, x1 - 8, 9 do vline(bx, y - 4, y + 4, L.timber.deep) vline(bx + 1, y - 4, y + 4, L.timber.base) px(bx + 1, y - 4, L.timber.hi) end
    bundleEnd(x1 - 3, y, 4)
    px(x0 + 1, y - 3, L.plume.base) px(x0, y - 2, L.plume.hi)
  end
  seat(cx - 34, cx + 38, cy - 24)
  -- the hearth: a raised drum of flat stones, slab top, coursed face
  local top = c:ellipse(cx, cy, 25, 9)
  local face = c:ellipse(cx, cy + 4, 25, 9):cut(top)
  F.shadow(cx - 22, cx + 24, cy + 13, 6, 2)
  rimOf(union(top, face), L.stone)
  part(face, L.stone, { nopop = true })
  F.courses(face, cy + 2, 3, 7, L.stone)
  face:each(function(x, y) if x > cx + 12 and hash(x, y, 431) < .6 then px(x, y, L.stone.shade) end end)
  top:each(function(x, y)
    local s = hash((x + (y // 3) * 4) // 7, y // 3, 432)
    local col = s < .35 and L.stone.hi or (s < .8 and L.stone.base or L.stone.shade)
    if y % 3 == 0 or (x + (y // 3) * 4) % 7 == 0 then col = L.stone.deep end
    px(x, y, col)
  end)
  local pit = c:ellipse(cx, cy, 17, 5)
  fill(pit, L.soil.deep)
  pit:each(function(x, y) if hash(x, y, 8) < .3 then px(x, y, L.road.shade) end end)
  -- logs + embers
  local logs = line({ { cx - 12, cy + 2 }, { cx + 10, cy - 4 } }, 3):add(line({ { cx - 10, cy - 4 }, { cx + 12, cy + 2 } }, 3))
  rimOf(logs, L.willowBark) part(logs, L.willowBark, { nopop = true })
  logs:each(function(x, y) if hash(x, y, 93) < .25 then px(x, y, G.deep) end end)
  pit:each(function(x, y) if hash(x, y, 9) < .25 and not logs:has(x, y) then px(x, y, G.deep) end end)
  -- a peat turf glowing at the edge
  fill(rect(cx + 12, cy - 2, cx + 16, cy + 1), L.peat.deep) hline(cx + 12, cx + 16, cy - 2, G.deep) px(cx + 13, cy, G.shade)
  local fl = poly{ { cx - 12, cy }, { cx - 9, cy - 16 }, { cx - 5, cy - 9 }, { cx - 2, cy - 28 }, { cx + 2, cy - 12 }, { cx + 6, cy - 22 }, { cx + 9, cy - 8 }, { cx + 12, cy } }
  fill(fl, G.deep)
  fill(fl:shrink(1), G.shade)
  fill(poly{ { cx - 8, cy }, { cx - 3, cy - 20 }, { cx + 1, cy - 9 }, { cx + 5, cy - 15 }, { cx + 8, cy } }, G.base)
  fill(poly{ { cx - 4, cy }, { cx - 1, cy - 12 }, { cx + 3, cy } }, G.hi)
  for i = 0, 14 do px(cx - 14 + floor(hash(i, 1, 31) * 30), cy - 32 - floor(hash(i, 2, 31) * 24), i % 3 == 0 and G.base or G.hi) end
  -- tripod of willow poles and the pot of eel stew
  local tri = line({ { cx - 18, cy + 4 }, { cx, cy - 40 } }, 2):add(line({ { cx + 18, cy + 4 }, { cx, cy - 40 } }, 2)):add(line({ { cx + 4, cy - 2 }, { cx, cy - 40 } }, 1))
  rimOf(tri, L.willowBark) part(tri, L.willowBark, { nopop = true, noshade = true })
  tri:each(function(x, y) if hash(x, y // 2, 94) < .2 then px(x, y, L.willowBark.hi) end end)
  hline(cx - 2, cx + 2, cy - 38, L.reed.base) hline(cx - 1, cx + 1, cy - 37, L.reed.shade)
  vline(cx, cy - 37, cy - 30, IR.deep)
  local pot = c:ellipse(cx, cy - 25, 7, 5):add(rect(cx - 7, cy - 28, cx + 7, cy - 26))
  rimOf(pot, IR) part(pot, IR) hline(cx - 7, cx + 7, cy - 28, IR.hi) fill(rect(cx - 5, cy - 29, cx + 5, cy - 29), L.reedGreen.hi)
  px(cx - 3, cy - 29, EEL.base) px(cx + 2, cy - 29, L.produce.base) px(cx, cy - 29, EEL.hi)
  fill(c:ellipse(cx, cy - 29, 7, 3):cut(c:ellipse(cx, cy - 29, 6, 2)):clip(rect(cx - 8, cy - 33, cx + 8, cy - 29)), IR.deep)
  F.smoke(cx + 1, cy - 38, 8, .5, 2)
  -- warm light on the clay
  local glowM = c:ellipse(cx, cy + 4, 42, 14):cut(c:ellipse(cx, cy + 3, 27, 12))
  glowM:each(function(x, y) if plat:has(x, y) and hash(x, y, 33) < .3 then px(x, y, hash(x, y, 34) < .5 and L.gold.hi or L.roof.hi) end end)
  seat(cx - 46, cx - 22, cy + 4)
  seat(cx + 24, cx + 50, cy + 2)
  seat(cx - 16, cx + 18, cy + 20)
end
campfire(132, 214)
local _, lx, ly = F.gnome(104, 191, { hat = L.leaf, coat = L.roof2, arm = "hold", noShadow = true })
local lute = c:ellipse(lx + 2, ly, 4, 3):add(line({ { lx + 5, ly - 1 }, { lx + 12, ly - 6 } }, 1))
rimOf(lute, L.timber) part(lute, L.board, { nopop = true }) fill(c:ellipse(lx + 2, ly, 1, 1), L.timber.edge) px(lx + 12, ly - 7, L.timber.base)
for _, n in ipairs({ { lx + 8, ly - 14 }, { lx + 13, ly - 18 } }) do vline(n[1] + 1, n[2] - 3, n[2], L.timber.edge) fill(rect(n[1], n[2], n[1] + 1, n[2] + 1), L.timber.edge) end
local _, mx, my = F.gnome(96, 210, { hat = L.awnA, coat = sage, arm = "out" })
-- a toasting stick: a marshmallow and a bit of smoked eel
fill(line({ { mx, my }, { mx + 10, my - 7 } }), L.board.base) fill(rect(mx + 10, my - 9, mx + 12, my - 7), L.awnB.hi) px(mx + 12, my - 7, L.gold.base) px(mx + 10, my - 9, L.plaster.hi)
px(mx + 6, my - 5, EEL.base) px(mx + 7, my - 5, EEL.shade) px(mx + 6, my - 6, EEL.hi)
local _, ux, uy = F.gnome(174, 208, { hat = L.marigold, coat = L.lav, arm = "out", flip = true })
fill(rect(ux - 3, uy - 3, ux, uy + 1), L.board.hi) px(ux, uy - 2, L.board.base) px(ux - 3, uy - 3, L.board.base) px(ux - 2, uy - 5, L.cloud.top) px(ux - 1, uy - 7, L.cloud.top)
-- a rough-coated water dog asleep by the fire
F.sprite({
  ".ee.............",
  "eDDe....DDDDD...",
  "DDeDDDDDDDDDDD..",
  "nwDDDDDDDDdDDDt.",
  "wwwDDDDDDDDDDDtt",
  ".wwdddddddddd...",
}, 154, 228, { e = L.soil.deep, D = L.soil.base, d = L.soil.shade, n = L.timber.edge, w = L.awnB.base, t = L.soil.hi })
hline(156, 157, 230, L.timber.edge)
for _, p in ipairs({ { 158, 229 }, { 162, 230 }, { 165, 229 } }) do px(p[1], p[2], L.soil.hi) end -- curls
-- a little reed-bundle stool by the lute player
do local st = c:rrect(60, 208, 72, 216, 3) rimOf(st, L.reed) part(st, L.reed, { nopop = true }) st:each(function(x, y) if x % 2 == 0 then px(x, y, L.reed.hi) end end) hline(60, 72, 212, L.timber.deep) end

---------------------------------------------------------------- camp kitchen table, bottom-left
local tbl = rect(24, 236, 76, 239):add(rect(27, 240, 30, 252)):add(rect(70, 240, 73, 252))
F.shadow(26, 76, 252, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
F.planks(rect(24, 236, 76, 239), L.board, 9, true, 31)
local ket = c:ellipse(36, 231, 5, 4):add(rect(41, 228, 44, 229)) rimOf(ket, L.accent) part(ket, L.accent) fill(rect(34, 226, 38, 227), L.accent.shade)
-- a pan with two little perch
local pan = c:ellipse(54, 234, 7, 2) rimOf(pan, IR) part(pan, IR, { nopop = true }) fill(rect(61, 233, 66, 234), L.timber.base)
for _, f in ipairs({ { 49, 233 }, { 54, 234 } }) do hline(f[1], f[1] + 4, f[2], L.heron.base) px(f[1], f[2], L.heron.hi) px(f[1] + 5, f[2], L.reedGreen.shade) px(f[1] + 2, f[2] - 1, L.produce.shade) end
-- a woven basket of duck eggs
local bask = c:rrect(64, 228, 75, 235, 2)
rimOf(bask, L.reed) part(bask, L.reed, { nopop = true })
bask:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.reed.shade) end end)
for k = 0, 3 do local x = 65 + k * 3 fill(rect(x, 226, x + 1, 227), L.accent.hi) px(x, 226, L.awnB.hi) end
line({ { 64, 228 }, { 69, 222 }, { 75, 228 } }):each(function(x, y) if y < 228 then px(x, y, L.reed.deep) end end)
-- under the table: a water bucket, an eel trap
local bucket = rect(40, 244, 48, 251) rimOf(bucket, L.timber) part(bucket, L.timber, { nopop = true }) hline(40, 48, 246, IR.shade) hline(41, 47, 244, L.water.base)
eelTrap(80, 250, 100, 250, 4)
F.sedge(14, 236, 5, L.reed)

---------------------------------------------------------------- bedrolls, packs and the otter (right of the road)
local function bedroll(x, y, r)
  local m = c:rrect(x - 14, y - 5, x + 14, y + 5, 5)
  rimOf(m, r) part(m, r)
  for k = -8, 8, 8 do vline(x + k, y - 5, y + 5, r.deep) end
  local e = c:ellipse(x + 12, y, 3, 5) fill(e, r.hi) c:ellipse(x + 12, y, 1, 3):edge():each(function(xx, yy) px(xx, yy, r.shade) end)
  hline(x - 6, x - 4, y - 5, L.timber.base)
  m:each(function(xx, yy) if (xx + yy * 2) % 7 == 0 and yy < y then px(xx, yy, r.hi) end end)
end
bedroll(300, 230, sage) bedroll(312, 240, L.roof2)
local function pack(x, yb, r)
  local m = c:rrect(x - 8, yb - 18, x + 8, yb, 4)
  local flap = c:rrect(x - 8, yb - 20, x + 8, yb - 12, 3)
  F.shadow(x - 6, x + 8, yb, 6, 2)
  rimOf(union(m, flap), r) part(m, r) part(flap, r, { sep = true })
  fill(rect(x - 1, yb - 13, x + 1, yb - 11), L.gold.base) px(x - 1, yb - 13, L.gold.hi)
  vline(x - 5, yb - 11, yb - 2, r.deep) vline(x + 5, yb - 11, yb - 2, r.deep)
  fill(c:ellipse(x + 10, yb - 8, 4, 4), IR.base) px(x + 9, yb - 10, IR.hi) px(x + 12, yb - 6, IR.deep)
end
pack(346, 258, L.leaf)
pack(330, 262, L.roof)
-- quirk: an otter in a red gnome hat climbing out of the green pack, an eel in its paws
F.sprite({
  ".......hR.......",
  "......hRRr......",
  ".....hRRRRr.....",
  "....hRRRRRRr....",
  "...ddddddddddd..",
  "..sOoOOOOOOOos..",
  "..oOOOOOOOOOOo..",
  ".oOOkKOOOOkKOoo.",
  ".oOOkkOOOOkkOoo.",
  ".oOOOmmmmmmOOoo.",
  "..oOmmmnnmmmOo..",
  "..ooOmmmmmmOoo..",
  "...oommmmmmoo...",
  "...oOmmmmmmoo...",
  "..oOOmmmmmmooo..",
  "kEEeeeeeEEEeeeEE",
  "EEpEEEEEEEEpEEEE",
  "..oommmmmmooo..E",
  "..ooommmmooooo.E",
  "...oooooooooo..k",
}, 336, 216, { h = L.awnA.hi, R = L.awnA.base, r = L.awnA.shade, d = L.awnA.deep, O = L.soil.base, o = L.soil.shade, s = L.soil.deep,
  k = L.timber.edge, K = L.awnB.hi, m = L.plaster.base, n = L.timber.edge, E = EELF.base, e = EELF.hi, p = L.soil.hi })
-- whiskers
px(339, 226, L.plaster.hi) px(338, 225, L.plaster.hi) px(349, 226, L.plaster.hi) px(350, 225, L.plaster.hi)
-- the thick tapering tail hanging over the pack's rim
F.sprite({ "oOo", "oOo", "oOo", ".oO", ".oO", ".oo", "..o" }, 353, 238, { o = L.soil.shade, O = L.soil.base })
F.sedge(294, 258, 6) F.sedge(364, 262, 6, L.reed) F.sedge(320, 268, 5)
F.depth(0)
F.birds({ { 330, 40, 2 }, { 344, 48, 1 }, { 120, 56, 2 }, { 352, 44, 1 } })
F.depth(3)

---------------------------------------------------------------- by the causeway: lantern pole, sign
local lp = rect(286, 176, 287, 212) rimOf(lp, L.timber) part(lp, L.timber, { nopop = true, noshade = true })
F.moss(rect(286, 204, 287, 212), .5, 25)
fill(rect(281, 176, 287, 177), L.timber.base) vline(281, 178, 180, L.timber.edge)
local lan = rect(278, 181, 284, 188) rimOf(lan, L.timber) fill(lan, G.base) px(279, 182, G.hi) vline(284, 182, 188, G.shade) hline(278, 284, 181, L.timber.base)
F.sign(212, 196, 20, 12, L.board)
-- pictogram: a little reed hut with a flag
fill(poly{ { 206, 205 }, { 212, 198 }, { 218, 205 } }, L.roof.base) px(210, 201, L.roof.hi) fill(rect(211, 203, 213, 205), L.timber.deep) px(212, 197, L.awnA.base)
-- willow leaves and reed straws scattered on the wet ground
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 55) * 440), 140 + floor(hash(i, 2, 55) * 120)
  if not (x > 378 and y > 228) and not plat:has(x, y) and not F.roadM:has(x, y) and not pool:has(x, y) then
    if i % 3 == 0 then px(x, y, L.reed.hi) px(x + 1, y, L.reed.hi) px(x + 2, y, L.reed.shade)
    else px(x, y, L.willow.base) px(x + 1, y, L.willow.shade) end
  end
end
F.dragonfly(232, 252, L.apple) F.dragonfly(100, 168, L.accent, true)
F.finish()
