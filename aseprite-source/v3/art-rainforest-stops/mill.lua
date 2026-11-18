-- mill.lua : "Old mill" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua) and the forest mill, re-cast for a
-- jungle stream: road's end: a tall bamboo husking house on stilts with a steep palm-thatch roof (replaces the
-- windmill / saw-house), between a canopy tree (a monkey swinging from it) and a palm. Back left: a stilt hut with
-- hearth smoke. Far right: a sugarcane field. Right: the bamboo rice store with a hoist lifting a cane bundle, a
-- dock of rice sacks. Left hero: the bamboo-and-palm-thatch water mill on a wet stone footing, a bamboo flume and
-- an overshot wheel wrapped in vines, a banana plant beside it. Bottom left: a jade jungle pool with giant lily
-- pads, a lotus, a frog, a turtle and elephant-ear leaves. Bamboo pole stack, a coconut-splitting gnome, two
-- gnomes pounding rice in a big mortar, a red junglefowl, a cane cart, a scarlet macaw on a stump, blue morphos.
-- Quirk: a capuchin monkey in a red gnome hat riding the top paddle of the wheel, clutching a banana.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local cane = F.rp("#d898b4 #a85a84 #7a3e64 #542a48 #34182e") -- purple-red sugarcane
local burlap = F.rp("#ead6a4 #ccb27c #a68c5c #7a6644 #4c402e")  -- rice-sack hessian

local function bambooEnd(x, y, rr)
  local m = c:ellipse(x, y, rr, rr)
  c:rim(m, L.bamboo.edge) fill(m, L.bamboo.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y) < -rr * .5 then px(xx, yy, L.bamboo.hi) elseif (xx - x) + (yy - y) > rr * .6 then px(xx, yy, L.bamboo.shade) end end)
  if rr >= 2 then fill(c:ellipse(x, y, rr - 2 > 0 and rr - 2 or 1, rr - 2 > 0 and rr - 2 or 0), L.soil.deep) px(x, y - 1, L.soil.edge) end
  return m
end
local function sack(x, yb, w, r)
  r = r or burlap
  local m = F.sack(x, yb, r, w)
  -- a printed rice-sheaf mark and the weave
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 and hash(xx, yy, 5) < .4 then px(xx, yy, r.shade) end end)
  px(x, yb - w + 1, L.awnA.base) px(x - 1, yb - w + 2, L.awnA.shade) px(x + 1, yb - w + 2, L.awnA.shade)
  return m
end
local function caneBundle(x0, y0, w, rows)
  local m = HP.mask()
  for st = 0, rows do -- each stalk a slightly different length: ragged cut ends
    local a, b = floor(hash(st, 2, x0) * 3), floor(hash(st, 3, x0) * 3)
    m:add(rect(x0 + a, y0 + st * 2, x0 + w - b, y0 + st * 2 + 1))
  end
  m:cut(rect(x0, y0 + rows * 2 + 1, x0 + w, y0 + rows * 2 + 1))
  rimOf(m, cane)
  m:each(function(x, y)
    local k = (y - y0) % 2
    local st = (y - y0) // 2
    local h = k == 0 and cane.base or cane.shade
    if k == 0 and x < x0 + w * .4 then h = cane.hi end
    local nodeX = 4 + floor(hash(st, 0, 7) * 5)
    if (x - x0 + floor(hash(st, 1, 7) * 9)) % nodeX == 0 then h = k == 0 and cane.shade or cane.deep end -- nodes
    px(x, y, h)
  end)
  -- leafy tops on one end, cut ends on the other, two ties
  for y = y0, y0 + rows * 2, 2 do
    local a = floor(hash((y - y0) // 2, 2, x0) * 3)
    px(x0 + a - 1, y, L.leaf.base) px(x0 + a - 2, y - 1, L.leaf.hi) px(x0 + a - 3, y - 1, L.leaf.base) px(x0 + a - 3, y + 1, L.leaf.shade) px(x0 + a - 4, y, L.leaf.deep)
  end
  for _, tx in ipairs({ x0 + w // 3, x0 + w * 2 // 3 }) do vline(tx, y0, y0 + rows * 2, L.needle.base) end
  return m
end

---------------------------------------------------------------- far right: a sugarcane field
F.depth(1)
local field = poly{ { 268, 114 }, { 470, 114 }, { 470, 146 }, { 284, 146 } }
field:each(function(x, y)
  local h = L.mossGround.base
  if hash(x // 6, y // 2, 4) < .3 then h = L.mossGround.hi elseif hash(x // 5, y // 2, 5) < .2 then h = L.ground.base end
  if hash(x, y, 3) < .04 then h = L.mossGround.shade end
  px(x, y, h)
end)
-- cane rows across the view: stalks with nodes, leaf blades arching from the tops; taller and wider nearer
for row = 0, 6 do
  local y = 120 + row * 4 + (row > 3 and (row - 3) or 0)
  local hgt = 7 + row * 2
  for x = 290 + (row % 2) * 2, 466, 3 + (row > 3 and 1 or 0) do
    if hash(x, row, 7) < .85 then
      local top = y - hgt - floor(hash(x, row, 8) * 3)
      vline(x, top, y, (row + x) % 5 == 0 and cane.shade or ((row + x) % 2 == 0 and L.vine.base or L.vine.shade))
      for yy = top + 2, y, 4 do px(x, yy, L.vine.deep) end
      px(x - 1, top, L.leaf.hi) px(x - 2, top + 1, L.leaf.base) px(x + 1, top, L.leaf.base) px(x + 2, top + 1, L.leaf.shade)
      px(x, top - 1, L.leaf.hi)
      if row > 2 then px(x - 3, top + 2, L.leaf.shade) px(x + 3, top + 2, L.leaf.deep) px(x - 1, top + 4, L.leaf.base) px(x + 1, top + 5, L.leaf.shade) end
    end
  end
end
-- a far cane cutter and a cut bundle in a gap of the rows
F.gnome(330, 140, { small = true, hat = L.awnA, coat = L.accent, arm = "up" })
caneBundle(342, 136, 12, 2)
F.palm(460, 136, 34, 7, { ramp = L.foliage2 })

---------------------------------------------------------------- road's end: the husking house on stilts
F.depth(2)
F.tree(204, 128, 64, 1)
F.palm(278, 128, 60, 5, { lean = 6 })
local function huskHouse()
  local stilts = HP.mask()
  for _, sx in ipairs({ 227, 235, 244, 252 }) do stilts:add(rect(sx, 102, sx + 1, 126)) end
  local braces = line({ { 228, 124 }, { 236, 106 } }):add(line({ { 252, 124 }, { 245, 106 } }))
  local deck = rect(221, 100, 259, 103)
  local walls = rect(226, 76, 254, 99)
  local roofM = poly{ { 214, 82 }, { 240, 46 }, { 266, 82 } }
  roofM:add(poly{ { 212, 84 }, { 216, 78 }, { 220, 82 } }):add(poly{ { 268, 84 }, { 264, 78 }, { 260, 82 } }) -- upswept eave tips
  F.shadow(222, 258, 126, 8, 3)
  rimOf(union(stilts, braces, deck, walls, roofM), L.timber)
  part(stilts, L.bamboo, { nopop = true }) stilts:each(function(x, y) if y % 7 == 0 then px(x, y, L.bamboo.deep) end end)
  braces:each(function(x, y) px(x, y, L.bamboo.shade) end)
  part(walls, L.plaster)
  F.bambooWall(walls, L.bamboo, 3, false, 21)
  -- a woven mat panel either side of the door
  for _, pm in ipairs({ rect(228, 80, 233, 96), rect(247, 80, 252, 96) }) do
    pm:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
    F.c:edgeIn(pm, L.plaster.deep)
  end
  part(deck, L.timber, { nopop = true }) F.bambooWall(deck, L.bamboo, 2, true, 22)
  part(roofM, L.roof, { sep = true })
  F.palmThatch(roofM, L.roof, 46, 240, 63)
  line({ { 215, 81 }, { 239, 47 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  for x = 213, 267 do
    local len = 1 + floor(hash(x, 82, 64) * 3)
    for k = 1, len do px(x, 82 + k, k == len and L.roof.edge or (k == 1 and L.roof.deep or L.roof.shade)) end
  end
  -- the open husking floor: lamp light, a pestle beam and a winnowing basket
  local d = rect(235, 82, 245, 99)
  fill(d, L.timber.edge)
  fill(rect(236, 83, 244, 99), L.glow.shade) fill(rect(236, 83, 240, 90), L.glow.base) px(237, 84, L.glow.hi)
  vline(241, 84, 97, L.timber.deep) fill(rect(240, 95, 242, 97), L.timber.base)
  F.window(239, 62, 241, 67, L.timber)
  -- a toucan perched on the ridge pole
  vline(240, 44, 46, L.timber.edge)
  F.sprite({ "..KKK...", ".KWWKOO.", "KKWeKOOo", "KKKKK...", ".KKK....", "..K....." }, 236, 38,
    { K = "#2e2a30", W = L.gold.hi, e = L.timber.edge, O = L.produce.base, o = L.awnA.base })
  -- a ladder up to the deck
  local lad = line({ { 247, 126 }, { 250, 104 } }):add(line({ { 252, 126 }, { 255, 104 } }))
  for y = 107, 124, 4 do local t = (126 - y) / 22 lad:add(rect(floor(247 + 3 * t), y, floor(252 + 3 * t), y)) end
  rimOf(lad, L.timber) part(lad, L.bamboo, { nopop = true, noshade = true })
end
huskHouse()
F.smoke(246, 46, 5, .5, 2)
-- a bamboo pipe dripping water down to the road
local pipe = poly{ { 254, 110 }, { 266, 118 }, { 266, 120 }, { 254, 112 } }
rimOf(pipe, L.bamboo) part(pipe, L.bamboo, { nopop = true }) px(266, 121, L.water.hi) px(266, 123, L.water.base)
-- a spider monkey swinging by its tail from the canopy tree's limb
F.sprite({
  "..t.....",
  "..t.....",
  "...t....",
  "...MM...",
  "..MMMM..",
  ".MfefM..",
  ".MMMMMM.",
  "M.MMM.M.",
  "M.MmM..M",
  "..M.M...",
}, 222, 102, { t = L.timber.shade, M = L.timber.base, m = L.timber.shade, f = L.skin.base, e = L.timber.edge })

---------------------------------------------------------------- back-left: a stilt hut with hearth smoke
F.depth(1)
F.tree(86, 128, 46, 1)
F.palm(10, 136, 42, 3)
local hstilts = HP.mask()
for _, sx in ipairs({ 22, 36, 50, 64 }) do hstilts:add(rect(sx, 128, sx + 1, 140)) end
rimOf(hstilts, L.timber) part(hstilts, L.bamboo, { nopop = true })
local ctop, ccx, cwall = F.building{ x0 = 20, x1 = 66, yb = 128, wh = 22, rh = 22, wall = L.plaster, roof = L.roof, noShadow = true }
F.window(26, 112, 31, 117, L.timber) F.door(46, 114, 53, 127, L.timber)
F.shadow(20, 66, 141, 8, 3)
F.smoke(44, 80, 6, .6, 2)
F.fenceP(70, 140, 196, 132, 9)

---------------------------------------------------------------- right: the bamboo rice store with a hoist lifting a cane bundle
F.depth(2)
F.tree(300, 152, 56, 0)
F.palm(454, 142, 62, 9, { lean = -8 })
F.treeFern(436, 140, 36, 6)
local top, cx, swall, sroof = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 28, wall = L.bamboo, roof = L.roof, noAttic = true, noFrame = true }
F.bambooWall(swall, L.bamboo, 4, false, 9)
local gable = poly{ { 335, top }, { cx, top - 28 + 8 }, { 415, top } }
gable:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
swall:each(function(x, y) if y > 162 and hash(x, y // 2, 12) < .45 then px(x, y, L.moss.shade) end end) -- damp moss at the foot
-- dark hardwood corner posts and sill
local posts = union(rect(330, top, 332, 170), rect(418, top, 420, 170), rect(330, 168, 420, 170))
part(posts, L.timber, { nopop = true, noshade = true })
-- loft door + hoist beam
local loft = rect(368, 110, 382, 123)
fill(loft, L.timber.deep) fill(rect(369, 111, 381, 123), L.soil.deep)
sack(372, 122, 3) sack(379, 122, 3)
local beamH = rect(372, 104, 398, 107)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 104, L.timber.hi)
vline(394, 108, 132, L.needle.deep) -- rope
caneBundle(380, 134, 28, 4)
line({ { 394, 132 }, { 384, 134 } }):each(function(x, y) px(x, y, L.needle.deep) end)
line({ { 394, 132 }, { 404, 134 } }):each(function(x, y) px(x, y, L.needle.deep) end)
F.door(352, 140, 366, 169, L.timber)
F.window(396, 150, 404, 157, L.timber)
F.window(340, 130, 346, 136, L.timber)
F.vines(rect(330, top - 2, 420, top + 2), .05, 33, 10)
-- loading dock (bamboo poles) with stacked rice sacks and cane bundles
local dock = rect(300, 158, 340, 172)
rimOf(dock, L.timber) part(dock, L.bamboo)
F.bambooWall(dock, L.bamboo, 3, true, 11)
sack(306, 157, 5) sack(318, 157, 5) sack(312, 148, 5)
caneBundle(324, 150, 14, 3)
F.depth(3)
local _, ghx, ghy = F.gnome(354, 182, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 143, ghy, L.needle.deep) -- hauling the hoist rope
line({ { ghx, 143 }, { 394, 132 } }):each(function(x, y) px(x, y, L.needle.deep) end)

---------------------------------------------------------------- rice pounding: two gnomes, a big mortar, two pestles
local function mortar(x, yb)
  local body = poly{ { x - 9, yb - 14 }, { x + 9, yb - 14 }, { x + 7, yb - 4 }, { x + 8, yb }, { x - 8, yb }, { x - 7, yb - 4 } }
  local rimTop = c:ellipse(x, yb - 14, 9, 2)
  rimOf(union(body, rimTop), L.timber)
  part(body, L.timber)
  body:each(function(xx, yy) if xx < x - 4 then px(xx, yy, L.timber.hi) end if (yy - yb) % 5 == 0 then px(xx, yy, L.timber.shade) end end)
  fill(rimTop, L.timber.base) fill(c:ellipse(x, yb - 14, 7, 1), L.awnB.base) px(x - 3, yb - 15, L.awnB.hi) px(x + 2, yb - 14, L.awnB.shade)
  F.shine(body, .06, 9)
end
F.shadow(374, 410, 200, 6, 3)
mortar(392, 200)
local _, lhx, lhy = F.gnome(372, 204, { hat = L.awnA, coat = L.wall2, arm = "up" })
local _, rhx, rhy = F.gnome(410, 204, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
-- left pestle raised high, right pestle driven down into the mortar
local p1 = rect(lhx + 2, lhy - 18, lhx + 3, lhy + 6)
local p2 = rect(rhx - 1, rhy - 26, rhx, 187)
rimOf(union(p1, p2), L.timber) part(p1, L.board, { nopop = true }) part(p2, L.board, { nopop = true })
vline(lhx + 2, lhy - 18, lhy + 6, L.board.hi) vline(rhx - 1, rhy - 26, 187, L.board.hi)
fill(rect(lhx + 2, lhy - 18, lhx + 3, lhy - 16), L.timber.base) fill(rect(rhx - 1, rhy - 26, rhx, rhy - 24), L.timber.base)
fill(rect(rhx - 1, rhy - 1, rhx, rhy), L.skin.base)
-- flying rice grains
for i = 0, 6 do px(386 + floor(hash(i, 1, 41) * 14), 180 + floor(hash(i, 2, 41) * 5), L.awnB.hi) end
for i = 0, 10 do px(376 + floor(hash(i, 1, 42) * 32), 202 + floor(hash(i, 2, 42) * 6), L.awnB.base) end
F.hen(426, 214, L.produce, true) -- a red junglefowl pecking the spilt rice
px(420, 214, L.awnB.hi)

F.depth(2)
---------------------------------------------------------------- a banana plant beside the mill
local function banana(x, yb, h)
  local stem = poly{ { x - 2, yb }, { x + 2, yb }, { x + 1, yb - h * .55 }, { x - 1, yb - h * .55 } }
  rimOf(stem, L.vine) part(stem, L.vine, { nopop = true })
  stem:each(function(xx, yy) if xx < x then px(xx, yy, L.vine.hi) end if hash(xx, yy // 4, 3) < .15 then px(xx, yy, L.litter.shade) end end)
  local ty = floor(yb - h * .55)
  F.bigLeaf(x, ty, floor(h * .5), -pi * .8, L.leaf, 11, nil, { torn = true, droop = .35 })
  F.bigLeaf(x, ty, floor(h * .55), -pi * .2, L.foliage, 12, nil, { torn = true, droop = .4 })
  F.bigLeaf(x, ty, floor(h * .45), -pi * .55, L.leaf, 13, nil, { torn = true, droop = .15 })
  -- the fruit bunch and the purple bell
  for k = 0, 2 do local y = ty + 3 + k * 3 hline(x + 1, x + 4 - k, y, L.leaf.base) hline(x + 1, x + 4 - k, y + 1, L.leaf.shade) px(x + 5 - k, y, L.leaf.edge) end
  vline(x + 2, ty + 12, ty + 15, L.vine.shade)
  F.sprite({ ".l.", "lLl", "lLl", ".l." }, x + 1, ty + 15, { l = cane.shade, L = cane.base })
end
banana(78, 166, 52)
---------------------------------------------------------------- left hero: bamboo-and-palm-thatch mill house + overshot wheel
F.depth(3)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 30, wall = L.board, roof = L.roof, noFrame = true }
-- vertical seasoned (golden) bamboo culms above a wet stone footing
local boards = wallM:copy():clip(rect(92, mtop + 5, 172, 175))
F.bambooWall(boards, L.board, 4, false, 17)
local foot = rect(92, 176, 172, 186)
part(foot, L.stone, { nopop = true }) F.courses(foot, 176, 5, 9, L.stone) F.moss(foot, .2, 70) F.shine(foot, .08, 71)
hline(92, 172, 175, L.timber.edge)
local corners = union(rect(92, mtop + 4, 94, 175), rect(170, mtop + 4, 172, 175), rect(92, 160, 172, 161))
part(corners, L.timber, { nopop = true, noshade = true })
local mgable = poly{ { 97, mtop }, { mcx, mtop - 30 + 8 }, { 167, mtop } }
mgable:each(function(x, y) px(x, y, (((x + y) // 2) % 2 == ((x - y) // 2) % 2) and L.plaster.base or L.plaster.shade) end)
F.window(mcx - 3, mtop - 13, mcx + 2, mtop - 9, L.timber)
F.door(108, 158, 120, 185, L.timber)
F.window(134, 146, 142, 154, L.timber)
F.window(150, 146, 158, 154, L.timber)
F.window(100, 142, 104, 148, L.timber)
-- a round sign over the door: a rice sheaf
local plaque = c:ellipse(114, 150, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
F.sprite({ "g.g.g", ".ggg.", "..s..", "..s..", ".s.s." }, 112, 147, { g = L.gold.shade, s = L.needle.shade }, { rim = false })
-- window boxes with orchids
for _, wx in ipairs({ 138, 154 }) do
  hline(wx - 5, wx + 5, 157, L.timber.base) hline(wx - 5, wx + 5, 158, L.timber.deep)
  for k = -4, 4, 2 do px(wx + k, 156, L.fern.base) px(wx + k + 1, 155, L.fern.hi) end
  px(wx - 2, 154, L.orchid.hi) px(wx - 1, 154, L.orchid.base) px(wx + 2, 153, L.orchid.hi) px(wx + 3, 154, L.orchid.base) px(wx + 2, 154, L.orchid.deep)
end
-- a vine climbing the left corner and over the eave
for y = 140, 184 do local vx = 94 + floor(sin(y / 5) * 1.5 + .5) px(vx, y, L.vine.shade) if y % 4 == 0 then px(vx - 1, y, L.vine.hi) px(vx + 1, y + 1, L.vine.base) end end
F.vines(rect(92, mtop + 2, 132, mtop + 6), .08, 34, 9)

-- stone wheel pit behind the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.courses(pit, 176, 6, 10, L.stone) F.moss(pit, .24, 72) F.shine(pit, .08, 73)
-- split-bamboo flume on bamboo trestles, bringing the stream over the top of the wheel
local flume = poly{ { 186, 140 }, { 226, 130 }, { 226, 135 }, { 186, 145 } }
local legs = rect(218, 135, 220, 150):add(rect(206, 138, 208, 152))
rimOf(union(flume, legs), L.timber)
part(legs, L.bamboo, { nopop = true, noshade = true })
legs:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
part(flume, L.bamboo)
flume:each(function(x, y) if (x * 2 + y) % 13 == 0 then px(x, y, L.bamboo.deep) end end)
line({ { 187, 140 }, { 225, 130 } }):each(function(x, y) px(x, y, L.water.hi) end)
line({ { 187, 141 }, { 225, 131 } }):each(function(x, y) if hash(x, y, 3) < .5 then px(x, y, L.water.base) end end)

local hx, hy, R = 192, 170, 26
local outer = c:ellipse(hx, hy, R, R)
local ringO = outer:copy():cut(c:ellipse(hx, hy, R - 4, R - 4))
local ringI = c:ellipse(hx, hy, 9, 9):cut(c:ellipse(hx, hy, 6, 6))
local spokes, pads = HP.mask(), HP.mask()
for k = 0, 7 do
  local a = k * pi / 4 + .2
  spokes:add(line({ { hx + cos(a) * 6, hy + sin(a) * 6 }, { hx + cos(a) * (R - 3), hy + sin(a) * (R - 3) } }, 2))
end
for k = 0, 15 do
  local a = k * pi / 8 + .1
  pads:add(line({ { hx + cos(a) * (R - 3), hy + sin(a) * (R - 3) }, { hx + cos(a) * (R + 3), hy + sin(a) * (R + 3) } }, 2))
end
local wheel = union(ringO, ringI, spokes, pads)
rimOf(wheel, L.timber)
part(spokes, L.bamboo, { nopop = true, noshade = true })
spokes:each(function(x, y) if ((x - hx) ^ 2 + (y - hy) ^ 2) % 37 < 3 then px(x, y, L.bamboo.deep) end end)
part(ringI, L.timber, { nopop = true })
part(pads, L.board, { nopop = true, noshade = true })
part(ringO, L.timber, { nopop = true })
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .8 and ((x - hx) ^ 2 + (y - hy) ^ 2) > (R - 2) ^ 2 then px(x, y, L.timber.hi) end end)
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .6 and hash(x, y, 77) < .12 then px(x, y, L.wet) end end)
-- wet moss on the lower rim and vines wound round the wheel, trailing off the lower paddles
ringO:each(function(x, y) if y > hy + R * .5 and hash(x, y, 74) < .45 then px(x, y, hash(x, y, 75) < .5 and L.moss.base or L.moss.shade) end end)
for k = 0, 40 do
  local a = pi * .15 + k / 40 * pi * 1.1
  local rr = R - 2 + floor(sin(k * 1.3) * 1.5 + .5)
  local x, y = floor(hx + cos(a) * rr + .5), floor(hy + sin(a) * rr + .5)
  px(x, y, L.vine.shade)
  if k % 3 == 0 then px(x + 1, y - 1, L.vine.hi) px(x + 1, y, L.vine.base) end
  if k % 9 == 4 then px(x - 1, y + 1, L.orchid.base) px(x - 1, y, L.orchid.hi) end
end
for _, vv in ipairs({ { 176, 190, 8 }, { 186, 195, 6 }, { 204, 192, 7 } }) do F.vine(vv[1], vv[2], vv[3], vv[1]) end
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- water pouring over the far side of the wheel + splash
local pour = poly{ { 184, 142 }, { 190, 142 }, { 214, 160 }, { 220, 182 }, { 216, 198 }, { 212, 182 }, { 208, 162 } }
pour:cut(spokes):cut(ringI)
pour:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.water.hi or (hash(x, y, 5) < .1 and L.wet or L.water.base)) end)
for i = 0, 8 do local x, y = 200 + floor(hash(i, 1, 9) * 26), 192 + floor(hash(i, 2, 9) * 10) px(x, y, L.water.hi) px(x + 1, y, L.wet) end
-- quirk: a capuchin monkey in a red gnome hat riding the top paddle, clutching a banana
F.sprite({
  "...........R....",
  "..........RRr...",
  ".........RRRr...",
  "........RRRRr...",
  ".......hhhhhhh..",
  ".......MffffM...",
  "......MfefefM...",
  ".......ffnff....",
  "........MMMM.Yy.",
  ".......MMMMMMYY.",
  "......MMmMMMMy..",
  "......MMmMMMM...",
  ".t....MMMMMM....",
  "t.t...MM..MM....",
  "t..tttMM...MM...",
  ".t..............",
}, 178, 125, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, M = L.timber.base, m = L.timber.shade, f = L.skin.hi,
  e = L.timber.edge, n = L.skin.deep, Y = L.gold.hi, y = L.gold.shade, t = L.timber.shade })

---------------------------------------------------------------- tail race and jungle pool (bottom-left)
local stream = poly{ { 170, 200 }, { 214, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.water)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 199 then local v = hash(x, y, 51) px(x, y, v < .35 and L.stone.base or (v < .55 and L.stone.hi or (v < .62 and L.wet or L.moss.base))) end end)
F.water(water, L.water)
-- dark canopy reflections along the far edge, and the wheel's
for _, rx in ipairs({ 40, 58, 120, 140 }) do for k = 0, 5 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 222 + k * 2, L.water.shade) end end
for y = 206, 214, 3 do hline(176, 196, y, L.water.shade) end
-- giant lily pads (upturned rims, red undersides showing), a pink lotus, a tree frog, a jumping fish
local function lily(x, y, rx)
  local m = c:ellipse(x, y, rx, math.max(1, rx // 3))
  c:rim(m, L.apple.deep)
  fill(m, L.leaf.base)
  m:each(function(xx, yy)
    if not m:has(xx, yy - 1) then px(xx, yy, L.leaf.hi) elseif not m:has(xx, yy + 1) then px(xx, yy, L.apple.shade)
    elseif (xx - x) % 4 == 0 then px(xx, yy, L.leaf.shade) end
  end)
  px(x - rx // 2, y, L.wet)
  return m
end
lily(60, 230, 7) lily(98, 246, 9) lily(46, 252, 6) lily(140, 246, 7) lily(124, 234, 5)
F.sprite({ ".p.p.", "pPhPp", ".pPp.", "..g.." }, 96, 239, { p = L.petal.base, P = L.petal.hi, h = L.gold.hi, g = L.leaf.deep })
F.sprite({ "e.e.", "GGGG", "GgGG", "o..o" }, 138, 241, { e = L.apple.base, G = L.fern.hi, g = L.fern.shade, o = L.produce.base }) -- red-eyed tree frog
F.sprite({ ".ff.", "fFFf", "..f." }, 74, 236, { f = L.produce.shade, F = L.produce.base })
for k = -6, 6, 2 do px(74 + k, 241, L.water.hi) end
-- a turtle sunning on a wet rock
local tr = F.rock(166, 252, 9, 8) F.moss(tr, .2, 76) F.shine(tr, .12, 77)
F.sprite({ "..sSSs..", ".sSsSSs.", "hsSSsSSs", ".k....k." }, 161, 240, { s = L.fern.deep, S = L.fern.shade, h = L.fern.base, k = L.fern.deep })
F.moss(F.rock(16, 232, 7, 6), .3, 78)
-- papyrus heads and elephant-ear leaves on the left bank
for i = 0, 5 do
  local x = 20 + i * 4 local h = 9 + floor(hash(i, 9, 52) * 9)
  vline(x, 247 - h, 247, i % 2 == 0 and L.fern.shade or L.fern.deep)
  for d = -3, 3 do px(x + d, 247 - h - 1 + math.abs(d) // 2, math.abs(d) == 3 and L.fern.deep or L.fern.base) end
  px(x, 247 - h - 2, L.fern.hi)
end
F.bigLeaf(22, 226, 16, -pi * .75, L.foliage, 21, 7, { heart = true, stem = { 26, 240 } })
F.bigLeaf(32, 230, 14, -pi * .4, L.leaf, 22, 6, { heart = true, stem = { 28, 242 } })
-- a bamboo footbridge over the race
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.timber) part(br, L.bamboo)
F.bambooWall(br, L.bamboo, 3, false, 13)

---------------------------------------------------------------- left: a bamboo pole stack, rice sacks, the coconut-splitting gnome
F.depth(3)
F.shadow(34, 96, 202, 8, 4)
local function poleStack(x0, yb, n, rr)
  for row = 0, n - 1 do
    for k = 0, n - 1 - row do
      local lx, ly = x0 + k * (rr * 2 + 1) + row * (rr + 1), yb - rr - row * (rr * 2)
      local side = rect(lx, ly - rr, lx + 10, ly + rr)
      rimOf(side, L.bamboo) part(side, L.bamboo, { nopop = true })
      hline(lx, lx + 10, ly - rr, L.bamboo.hi) vline(lx + 6, ly - rr, ly + rr, L.bamboo.deep)
    end
  end
  for row = 0, n - 1 do
    for k = 0, n - 1 - row do bambooEnd(x0 + k * (rr * 2 + 1) + row * (rr + 1), yb - rr - row * (rr * 2), rr) end
  end
end
poleStack(40, 200, 5, 3)
sack(86, 202, 6) sack(92, 192, 5)
F.bamboo(24, 196, 44, 4, 31)
-- chopping block, coconut halves and the gnome with a raised machete
local blk = rect(114, 202, 126, 210)
local blkTop = c:ellipse(120, 202, 6, 2)
rimOf(union(blk, blkTop), L.timber) part(blk, L.timber, { nopop = true }) fill(blkTop, L.board.base) px(120, 202, L.board.shade) px(117, 201, L.board.hi)
local function coconut(x, y, half)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x - 1, y - 1, L.soil.hi)
  if half then fill(rect(x - 1, y - 1, x + 1, y), L.awnB.hi) px(x, y, L.awnB.shade) end
end
coconut(119, 199, true) coconut(130, 210, true) coconut(106, 213) coconut(28, 211) coconut(33, 214, true)
local _, wx, wy = F.gnome(104, 210, { hat = L.awnA, coat = L.leaf, arm = "up" })
line({ { wx, wy + 2 }, { wx - 1, wy - 1 } }):each(function(x, y) px(x, y, L.timber.base) end)
local blade = poly{ { wx - 2, wy - 1 }, { wx - 1, wy - 3 }, { wx - 7, wy - 10 }, { wx - 8, wy - 9 } }
c:rim(blade, L.iron.edge) fill(blade, L.iron.base)
blade:each(function(x, y) if not blade:has(x - 1, y) then px(x, y, L.iron.hi) end end)
for _, f in ipairs({ { 18, 205, 6 }, { 84, 212, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.heliconia(30, 212, 20, 41)

---------------------------------------------------------------- right foreground: a cane cart, heliconia, tree fern
F.depth(3)
local function cart(x0, yb)
  local bed = poly{ { x0, yb - 14 }, { x0 + 40, yb - 14 }, { x0 + 38, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0 + 40, yb - 10 }, { x0 + 58, yb - 4 } }, 2)
  rimOf(union(bed, shaft), L.timber)
  part(shaft, L.bamboo, { nopop = true, noshade = true })
  part(bed, L.timber) F.bambooWall(bed, L.bamboo, 3, false, 19)
  hline(x0 + 1, x0 + 39, yb - 14, L.timber.hi)
  caneBundle(x0 + 2, yb - 24, 34, 4)
  sack(x0 + 30, yb - 14, 5) sack(x0 + 10, yb - 24, 4)
  for _, wx_ in ipairs({ x0 + 8, x0 + 32 }) do
    local w = c:ellipse(wx_, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx_, yb - 4, 3, 3), L.timber.shade)
    vline(wx_, yb - 9, yb + 1, L.timber.deep) hline(wx_ - 5, wx_ + 5, yb - 4, L.timber.deep)
    px(wx_, yb - 4, L.iron.hi)
  end
end
F.shadow(302, 352, 226, 8, 3)
cart(300, 226)
for _, f in ipairs({ { 312, 258, 8 }, { 324, 262, 9 }, { 300, 250, 6 }, { 446, 220, 7 }, { 456, 224, 8 } }) do F.fern(f[1], f[2], f[3]) end
-- keep clear of the compass corner x>=380, y>=230: the frame repaints it
F.treeFern(364, 262, 30, 42)
F.heliconia(340, 262, 22, 43)
F.heliconia(420, 226, 18, 44)
F.orchid(372, 252, L.orchid, 3) F.orchid(330, 238, L.petal, 2, true)
F.mushroom(330, 246, L.produce, true) F.mushroom(326, 249, L.produce)
F.sign(436, 168, 28, 14, L.board)
F.sprite({ "g.g.g", ".ggg.", "..t..", "..t..", ".t.t." }, 434, 171, { g = L.gold.shade, t = L.timber.shade }, { rim = false })
-- a coconut heap against the sign post
coconut(452, 198) coconut(457, 199) coconut(462, 198) coconut(455, 194) coconut(460, 194, true)

-- by the road, right: a mossy stump with a scarlet macaw on it
local st = poly{ { 283, 216 }, { 293, 216 }, { 292, 209 }, { 284, 209 } }
local stTop = c:ellipse(288, 209, 4, 1)
rimOf(union(st, stTop), L.timber) part(st, L.timber, { nopop = true }) fill(stTop, L.board.base) px(288, 209, L.board.shade)
F.moss(st, .25, 79)
F.sprite({
  "..RRR.......",
  ".RWWRR......",
  "kkWeRR......",
  "kk.RRRR.....",
  "...RRRRR....",
  "...RRRYYR...",
  "...RRYYBB...",
  "....RYBBBB..",
  "....RRBBb...",
  ".....RRBb...",
  "......oRBR..",
  ".......RB...",
  ".......RB...",
  "........RB..",
  ".........R..",
}, 282, 193, { R = L.apple.base, W = L.awnB.hi, e = L.timber.edge, k = L.awnB.shade, Y = L.gold.base, B = "#4a8ad8", b = "#2c4c9c", o = L.iron.shade })

---------------------------------------------------------------- gnome on the road with a cane bundle on his shoulder
local _, phx, phy = F.gnome(258, 240, { hat = L.roof2, coat = L.wall2, arm = "up" })
for k = 0, 2 do
  local cl = line({ { phx - 18, phy + 8 + k - 1 }, { phx + 10, phy - 3 + k - 1 } }, 1)
  cl:each(function(x, y) px(x, y, (x + k) % 6 == 0 and cane.deep or (k == 0 and cane.hi or cane.base)) end)
end
px(phx - 19, phy + 8, L.leaf.base) px(phx - 20, phy + 9, L.leaf.shade) px(phx - 20, phy + 7, L.leaf.hi)
-- a rice trail ... to a mouse nibbling a grain
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.awnB.hi) px(253 - i * 4, 243 + i * 3, L.awnB.base) end
local mouse = c:ellipse(222, 263, 4, 2):add(c:ellipse(218, 260, 2, 2))
rimOf(mouse, L.soil) part(mouse, L.needle, { nopop = true }) px(217, 258, L.petal.base) px(219, 257, L.soil.shade) px(220, 257, L.soil.base) px(216, 261, L.awnB.hi) px(218, 260, L.timber.edge)
line({ { 226, 263 }, { 230, 260 }, { 232, 262 } }):each(function(x, y) px(x, y, L.needle.shade) end)
-- blue morpho butterflies
for _, b in ipairs({ { 182, 222 }, { 318, 196 }, { 64, 182 } }) do
  F.sprite({ "BB.BB", "bBkBb", ".b.b." }, b[1], b[2], { B = "#5aa8f0", b = "#2c62b4", k = L.timber.edge }, { rim = false })
end
F.depth(0)
-- a flock of parrots crossing the sky
F.birds({ { 300, 40, 2, "#2e7a46" }, { 310, 46, 1, "#2e7a46" }, { 292, 49, 1, "#b03a36" }, { 140, 58, 2, "#2e7a46" }, { 186, 74, 1, "#2e7a46" } })

F.finish()
