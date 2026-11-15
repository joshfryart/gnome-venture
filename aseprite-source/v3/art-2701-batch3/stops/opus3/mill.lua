-- mill.lua : "Old mill" stop look, Maplewold (480x270 gate view). Opus second pass.
-- Read: a windmill at the road's end, an overshot water wheel on the plaster mill house, a stream and mill pond,
-- a granary with a sack hoist, millstones, sacks and wheat stooks. Quirk: a duck riding a wheel paddle.
-- opus3 richness pass: depth planes (haze on the back row, rim light on the near row), thatch / plank / water
-- texture, 28 px gnomes with tools, hens, ducklings, birds, chimney smoke; the duck now wears a gnome hat.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-2701-batch3/stops/opus3/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

---------------------------------------------------------------- far wheat field (right) with stooks
F.depth(1)
local field = poly{ { 268, 113 }, { 470, 113 }, { 470, 146 }, { 284, 146 } }
field:each(function(x, y)
  local r = (y - 113) % 4
  px(x, y, r == 0 and L.roof.shade or (r == 1 and L.roof.hi or L.roof.base))
  if hash(x, y, 3) < .05 then px(x, y, L.roof.deep) end
end)
hline(284, 470, 146, L.roof.deep)
local function stook(x, yb, h)
  local m = poly{ { x - h // 3, yb }, { x, yb - h }, { x + h // 3, yb } }
  rimOf(m, L.roof) part(m, L.roof)
  hline(x - h // 5, x + h // 5, yb - h // 2, L.timber.base)
  m:each(function(xx, y) if (xx + y) % 3 == 0 and y > yb - h + 2 then px(xx, y, L.roof.shade) end end)
end
for i, s in ipairs({ { 280, 124, 8 }, { 300, 120, 7 }, { 452, 122, 8 }, { 466, 128, 9 }, { 428, 118, 6 }, { 292, 136, 11 } }) do stook(s[1], s[2], s[3]) end

---------------------------------------------------------------- windmill at the road's end
F.depth(2)
local function windmill()
  local hx, hy = 240, 74
  local tower = poly{ { 224, 126 }, { 256, 126 }, { 251, 78 }, { 229, 78 } }
  local cap = poly{ { 225, 80 }, { 255, 80 }, { 252, 70 }, { 245, 64 }, { 235, 64 }, { 228, 70 } }
  F.shadow(226, 254, 126, 8, 3)
  rimOf(union(tower, cap), L.plaster)
  part(tower, L.plaster)
  tower:each(function(x, y) if y % 7 == 0 then px(x, y, L.plaster.shade) end end)
  F.door(236, 112, 244, 125, L.timber, true)
  F.window(237, 92, 242, 97, L.timber)
  -- gallery rail
  local gal = rect(222, 100, 258, 102)
  rimOf(gal, L.timber) part(gal, L.timber, { nopop = true, noshade = true })
  for x = 223, 257, 4 do vline(x, 103, 105, L.timber.base) end
  part(cap, L.roof, { sep = true })
  cap:each(function(x, y) if (y + (x // 4) % 2) % 3 == 0 then px(x, y, L.roof.shade) end end)
  line({ { 228, 71 }, { 236, 64 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  -- sails: four lattice arms
  local sails, frame = HP.mask(), HP.mask()
  for k = 0, 3 do
    local a = k * pi / 2 + .38
    local dx, dy, nx, ny = cos(a), sin(a), -sin(a), cos(a)
    local function P(t, s) return { hx + dx * t + nx * s, hy + dy * t + ny * s } end
    local q = poly{ P(7, 0), P(40, 0), P(40, 7), P(7, 7) }
    sails:add(q)
    frame:add(line({ P(0, 0), P(42, 0) }, 2))
    for t = 12, 40, 6 do frame:add(line({ P(t, 0), P(t, 7) })) end
    frame:add(line({ P(7, 7), P(40, 7) }))
  end
  local all = union(sails, frame)
  rimOf(all, L.timber)
  fill(sails, L.awnB.base)
  sails:each(function(x, y) local v = hash(x // 2, y // 2, 8) if v < .14 then px(x, y, L.awnB.shade) elseif v > .9 then px(x, y, L.awnB.hi) end end)
  part(frame, L.timber, { nopop = true, noshade = true })
  local hub = c:ellipse(hx, hy, 3, 3) rimOf(hub, L.timber) part(hub, L.iron)
end
windmill()

---------------------------------------------------------------- back-left: miller's cottage + tree
F.depth(1)
F.tree(84, 128, 40, 2)
F.building{ x0 = 20, x1 = 66, yb = 138, wh = 30, rh = 22, wall = L.wall2, roof = L.roof2, chimney = true }
F.window(26, 116, 31, 121, L.timber) F.door(46, 124, 53, 137, L.timber)
-- smoke from the chimney
F.smoke(57, 88, 6, .6, 2)
F.fenceP(70, 140, 196, 132, 9)

---------------------------------------------------------------- right: granary with the sack hoist
F.depth(2)
F.tree(468, 140, 44, 5)
local top, cx = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 28, wall = L.plaster, roof = L.roof, noAttic = true }
-- loft door + hoist beam
local loft = rect(368, 98, 382, 112)
fill(loft, L.timber.deep) fill(rect(369, 99, 381, 112), L.soil.deep)
for _, s in ipairs({ { 373, 112 }, { 379, 112 } }) do F.sack(s[1], s[2], L.awnB, 3) end
local beamH = rect(372, 92, 398, 95)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 92, L.timber.hi)
vline(394, 96, 136, L.board.deep)  -- rope
local hs = F.sack(394, 146, L.awnB, 5)
F.door(352, 140, 366, 169, L.timber)
F.window(396, 146, 404, 153, L.timber)
F.window(340, 128, 346, 134, L.timber)
-- loading dock with sack heap
local dock = rect(300, 158, 340, 172)
rimOf(dock, L.timber) part(dock, L.board)
F.planks(dock, L.board, 6, true, 11)
for _, s in ipairs({ { 306, 157 }, { 318, 158 }, { 330, 157 }, { 312, 149 }, { 325, 149 }, { 319, 141 } }) do F.sack(s[1], s[2], L.awnB, 5) end
F.depth(3)
local _, ghx, ghy = F.gnome(354, 182, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 150, ghy, L.board.deep) -- hauling the hoist rope
F.hen(380, 190, L.awnB) F.hen(398, 186, L.soil, true) F.hen(412, 192, L.awnB, true)
for _, g in ipairs({ { 388, 191 }, { 392, 189 }, { 404, 192 }, { 386, 188 } }) do px(g[1], g[2], L.roof.hi) end

---------------------------------------------------------------- left hero: mill house + overshot wheel
F.depth(3)
local mtop, mcx, wallM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 30, wall = L.plaster, roof = L.roof, chimney = true }
F.door(108, 158, 120, 185, L.timber)
F.window(134, 148, 142, 156, L.timber)
F.window(150, 148, 158, 156, L.timber)
F.window(100, 144, 104, 150, L.timber)
-- grain chute + sign of a wheat ear over the door
local plaque = c:ellipse(114, 150, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
vline(114, 147, 153, L.roof.shade) for y = 147, 152, 2 do px(113, y, L.roof.base) px(115, y + 1, L.roof.base) end

-- stone wheel pit behind the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.courses(pit, 176, 6, 10, L.stone)
-- flume on trestles, bringing water over the top of the wheel
local flume = poly{ { 186, 140 }, { 226, 130 }, { 226, 135 }, { 186, 145 } }
local legs = rect(218, 135, 220, 150):add(rect(206, 138, 208, 152))
rimOf(union(flume, legs), L.timber)
part(legs, L.timber, { nopop = true, noshade = true })
part(flume, L.board)
line({ { 187, 140 }, { 225, 130 } }):each(function(x, y) px(x, y, L.water.base) end)

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
  local p1 = { hx + cos(a) * (R - 3), hy + sin(a) * (R - 3) }
  local p2 = { hx + cos(a) * (R + 3), hy + sin(a) * (R + 3) }
  pads:add(line({ p1, p2 }, 2))
end
local wheel = union(ringO, ringI, spokes, pads)
rimOf(wheel, L.timber)
part(spokes, L.timber, { nopop = true, noshade = true })
part(ringI, L.timber, { nopop = true })
part(pads, L.board, { nopop = true, noshade = true })
part(ringO, L.timber, { nopop = true })
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .8 and ((x - hx) ^ 2 + (y - hy) ^ 2) > (R - 2) ^ 2 then px(x, y, L.timber.hi) end end)
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- water pouring over the far side of the wheel + splash
local pour = poly{ { 184, 142 }, { 190, 142 }, { 214, 160 }, { 220, 182 }, { 216, 198 }, { 212, 182 }, { 208, 162 } }
pour:cut(spokes):cut(ringI)
pour:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.water.hi or L.water.base) end)
for i = 0, 8 do local x, y = 200 + floor(hash(i, 1, 9) * 26), 192 + floor(hash(i, 2, 9) * 10) px(x, y, L.water.hi) px(x + 1, y, L.awnB.hi) end
-- quirk: a duck riding a paddle at the top of the wheel
F.sprite({
  "........Rr...",
  ".......RRr...",
  "......RRRr...",
  ".....RRRRr...",
  ".....hhhhhh..",
  ".....WWWWW...",
  "....WWWeWWOO.",
  "....WWWWWwOo.",
  "W...WWWWw....",
  "WW.WWWWWw....",
  "WWWWWWWWWW...",
  ".WWWWWwwWW...",
  "..WWwwwwW....",
  "...O....O....",
}, 168, 128, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, W = "#fff6e0", w = L.awnB.shade, e = L.timber.edge, O = L.roof.base, o = L.roof.shade })

---------------------------------------------------------------- tail race and mill pond (bottom-left)
local stream = poly{ { 170, 200 }, { 214, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.water)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 199 then px(x, y, hash(x, y, 51) < .5 and L.stone.base or L.stone.hi) end end)
F.water(water, L.water)
-- reflection of the wheel (dashes)
for y = 206, 214, 3 do hline(176, 196, y, L.water.shade) end
-- a mother duck and three ducklings in a line, each with a ripple
local function swim(x, y, big)
  local m = big and c:ellipse(x, y, 5, 3):add(c:ellipse(x + 5, y - 4, 2, 2)) or c:ellipse(x, y, 2, 1):add(rect(x + 1, y - 2, x + 2, y - 1))
  rimOf(m, L.timber) part(m, big and L.awnB or L.gold or L.roof, { nopop = true })
  if big then fill(rect(x + 7, y - 4, x + 8, y - 3), L.roof.base) px(x + 5, y - 5, L.timber.edge) hline(x - 6, x + 6, y + 3, L.water.hi)
  else px(x + 3, y - 2, L.roof.shade) hline(x - 3, x + 3, y + 2, L.water.hi) end
end
swim(96, 236, true) swim(84, 240) swim(74, 243) swim(64, 241)
-- reeds and lily pads
for i = 0, 7 do local x = 22 + i * 3 local h = 6 + floor(hash(i, 9, 52) * 8) vline(x, 246 - h, 246, i % 2 == 0 and L.leaf.shade or L.leaf.deep) if i % 2 == 0 then fill(rect(x, 246 - h - 1, x + 1, 246 - h + 2), L.timber.base) px(x, 246 - h - 1, L.timber.hi) end end
for _, p in ipairs({ { 60, 230 }, { 92, 244 }, { 48, 252 } }) do
  local pad = poly{ { p[1] - 4, p[2] }, { p[1], p[2] - 2 }, { p[1] + 4, p[2] }, { p[1], p[2] + 2 } }
  fill(pad, L.leaf.base) px(p[1] - 3, p[2], L.leaf.hi) px(p[1] + 1, p[2] + 1, L.leaf.deep)
end
-- plank footbridge over the race
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.timber) part(br, L.board)
F.planks(br, L.board, 5, true, 13)

---------------------------------------------------------------- millstones + sacks by the mill
local function millstone(x, y, r)
  local m = c:ellipse(x, y, r, r)
  rimOf(m, L.stone) part(m, L.stone)
  for k = 0, 5 do
    local a = k * pi / 3
    line({ { x + cos(a) * 3, y + sin(a) * 3 }, { x + cos(a + .5) * (r - 1), y + sin(a + .5) * (r - 1) } }):each(function(xx, yy) px(xx, yy, L.stone.shade) end)
  end
  fill(c:ellipse(x, y, 2, 2), L.stone.edge) px(x - 1, y - 1, L.stone.deep)
end
millstone(80, 176, 11)
local flat = c:ellipse(66, 196, 14, 5) rimOf(flat, L.stone) part(flat, L.stone) fill(c:ellipse(66, 195, 2, 1), L.stone.edge)
hline(54, 78, 199, L.stone.shade)
F.sack(40, 208, L.awnB, 6) F.sack(52, 212, L.roof, 5) F.sack(28, 214, L.awnB, 5)

---------------------------------------------------------------- right foreground: cart of sacks, sheaves
F.depth(3)
local function cart(x0, yb)
  local bed = poly{ { x0, yb - 14 }, { x0 + 40, yb - 14 }, { x0 + 38, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0 + 40, yb - 10 }, { x0 + 58, yb - 4 } }, 2)
  rimOf(union(bed, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) hline(x0 + 1, x0 + 39, yb - 10, L.board.deep)
  for _, s in ipairs({ { 6, -14 }, { 17, -15 }, { 28, -14 }, { 12, -22 }, { 23, -22 } }) do F.sack(x0 + s[1], yb + s[2], s[1] == 17 and L.roof or L.awnB, 5) end
  for _, wx in ipairs({ x0 + 8, x0 + 32 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.timber) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep)
    px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(302, 352, 226, 8, 3)
cart(300, 226)
local function sheaf(x, yb)
  local m = poly{ { x - 5, yb }, { x - 2, yb - 10 }, { x - 6, yb - 20 }, { x + 6, yb - 20 }, { x + 2, yb - 10 }, { x + 5, yb } }
  rimOf(m, L.roof) part(m, L.roof)
  m:each(function(xx, y) if y < yb - 15 and hash(xx, y, 2) < .4 then px(xx, y, L.roof.hi) elseif (xx + y) % 3 == 0 then px(xx, y, L.roof.shade) end end)
  hline(x - 2, x + 2, yb - 10, L.timber.base) hline(x - 2, x + 2, yb - 9, L.timber.deep)
end
for _, x in ipairs({ 312, 326, 340 }) do sheaf(x, 258) end
sheaf(436, 214) sheaf(450, 218)
F.sign(436, 168, 28, 14, L.board)
for y = 171, 179 do px(436, y, L.roof.shade) if y % 2 == 0 then px(435, y, L.roof.base) px(437, y + 1, L.roof.base) end end
-- millstone leaning on the sign post
millstone(456, 196, 9)

-- by the road, right: a goose and a sheaf
sheaf(282, 196)
F.sack(296, 200, L.roof, 5)
local goose = c:ellipse(276, 220, 5, 3):add(rect(279, 210, 280, 218)):add(c:ellipse(281, 210, 2, 2))
rimOf(goose, L.timber) part(goose, L.awnB, { nopop = true }) px(284, 210, L.roof.base) px(285, 210, L.roof.shade) px(281, 209, L.timber.edge)
hline(273, 279, 221, L.awnB.shade) vline(275, 224, 225, L.roof.shade) vline(278, 224, 225, L.roof.shade)
---------------------------------------------------------------- gnome on the road with a sack on his shoulder
F.gnome(258, 240, { hat = L.roof2, coat = L.leaf, arm = "up" })
F.sack(265, 222, L.awnB, 6)
-- flour trail from the split sack ... to a mouse with a floury nose
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.plaster.hi) px(253 - i * 4, 243 + i * 3, L.plaster.base) end
local mouse = c:ellipse(222, 263, 4, 2):add(c:ellipse(218, 260, 2, 2))
rimOf(mouse, L.stone) part(mouse, L.stone, { nopop = true }) px(217, 258, L.petal and L.petal.base or "#f5809f") px(216, 261, L.plaster.hi) px(218, 260, L.timber.edge)
line({ { 226, 263 }, { 230, 260 }, { 232, 262 } }):each(function(x, y) px(x, y, L.stone.shade) end)
F.depth(0)
F.birds({ { 300, 40, 2 }, { 310, 46, 1 }, { 292, 49, 1 }, { 140, 58, 2 } })

F.finish()
