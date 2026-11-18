-- mill.lua : "Old mill" stop look, WETLAND (wetland_reed), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua), re-cast for a reed fen:
-- road's end: a tarred smock drainage windpump with a boat-shaped reed cap, lattice sails and a tail pole,
-- between two weeping willows. Far right: a reed-cutting ground with sheaf stooks. Back left: a reed-thatched
-- daub cottage with peat smoke. Right: the reed store on stilts over a pool, a hoist lifting a reed sheaf, a
-- boardwalk deck with bundle stacks. Left hero: a tarred weatherboard tide mill with a reed-thatched roof, standing
-- on stilts over the mill channel, an undershot wheel on an A-frame dipping into the stream.
-- Bottom left: the mill pool with a gnome poling a punt, greylag geese and goslings, lilies, bulrushes, a frog.
-- Bottom right: a pool with a punt loaded with flour sacks, a grey heron fishing. Geese on the bank, a scythe gnome,
-- a reed-sheaf stack and a binding gnome, a gnome on the causeway with a reed bundle, a flour trail to a water vole.
-- Quirk: a big green frog in a red gnome hat riding the top paddle of the wheel, holding a bulrush.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-wetland-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 }, poolK = .77 }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local TAR = F.rp("#8a8c80 #64685e #4a4e48 #363a36 #24282a") -- tarred weatherboard

-- a tied reed sheaf standing (side view): tapering bundle, stalk stripes, a band, a plume tuft on top
local function sheaf(x, yb, h, r)
  r = r or L.reed
  local w = math.max(2, h // 4)
  local m = poly{ { x - w, yb }, { x + w, yb }, { x + w - 1, yb - h + 2 }, { x, yb - h }, { x - w + 1, yb - h + 2 } }
  rimOf(m, r)
  part(m, r, { nopop = true })
  m:each(function(xx, yy) if (xx - x) % 2 == 0 and yy > yb - h + 2 then px(xx, yy, xx < x and r.hi or r.shade) end end)
  local by = yb - floor(h * .45)
  hline(x - w, x + w, by, L.timber.deep) hline(x - w + 1, x + w - 1, by - 1, L.timber.base)
  px(x, yb - h - 1, L.plume.base) px(x - 1, yb - h, L.plume.hi)
  return m
end
-- a stook: three or four sheaves leaning into a cone
local function stook(x, yb, h)
  sheaf(x - h // 4, yb, h - 2) sheaf(x + h // 4, yb, h - 2) sheaf(x, yb + 1, h)
end
-- the cut end of a reed bundle seen face-on: a disc of stalk ends, lit upper left, a binding ring
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

---------------------------------------------------------------- far right: reed-cutting ground with sheaf stooks
F.depth(1)
local field = poly{ { 268, 115 }, { 470, 115 }, { 470, 146 }, { 284, 146 } }
field:each(function(x, y)
  local r = (y - 115) % 4
  local h = r == 0 and L.reed.shade or (r == 1 and L.reed.hi or L.reed.base) -- cut stubble rows
  if hash(x // 5, y // 3, 4) < .18 then h = L.sedgeGround.base end
  if hash(x, y, 3) < .05 then h = L.reed.deep end
  px(x, y, h)
end)
-- a strip of standing reed still to cut along the back, and a far dyke of water catching the sky
F.reeds(300, 468, 118, 8, 61)
for x = 284, 470 do if hash(x // 9, 1, 62) < .7 then px(x, 132, F.SKYREF) px(x, 133, L.water.base) end end
hline(284, 470, 146, L.reed.deep)
for _, s in ipairs({ { 280, 126, 9 }, { 298, 122, 8 }, { 452, 124, 9 }, { 466, 130, 10 }, { 428, 121, 7 }, { 292, 140, 12 }, { 410, 138, 10 } }) do stook(s[1], s[2], s[3]) end
F.gnome(352, 140, { small = true, hat = L.awnA, coat = L.leaf, arm = "out" })
line({ { 362, 133 }, { 366, 140 } }):each(function(x, y) px(x, y, L.iron.hi) end) -- the reed hook

---------------------------------------------------------------- road's end: smock drainage windpump between two willows
F.depth(2)
F.tree(204, 128, 54, 2)
F.tree(278, 130, 50, 4)
local function windpump()
  local hx, hy = 240, 70
  local tower = poly{ { 228, 126 }, { 252, 126 }, { 248, 76 }, { 232, 76 } }
  local plinth = rect(226, 119, 254, 126)
  local cap = poly{ { 228, 78 }, { 252, 78 }, { 251, 71 }, { 246, 65 }, { 234, 65 }, { 229, 71 } }
  local tail = line({ { 250, 75 }, { 268, 124 } }, 1)
  F.shadow(226, 254, 126, 8, 3)
  rimOf(union(tower, plinth, cap, tail), TAR)
  part(tower, TAR)
  tower:each(function(x, y)
    if (x - 228) % 3 == 0 then px(x, y, TAR.shade) end
    if x <= 232 + floor((126 - y) * .08) then px(x, y, TAR.hi) end
  end)
  part(plinth, L.stone, { sep = true }) F.courses(plinth, 119, 3, 6, L.stone)
  part(tail, L.timber, { nopop = true, noshade = true })
  F.door(236, 108, 244, 125, L.board, true)
  F.window(238, 88, 242, 93, L.board)
  -- the boat-shaped cap, reed thatched, white finial
  part(cap, L.roof, { sep = true })
  F.thatch(cap, L.roof, 65, 240)
  line({ { 229, 72 }, { 235, 65 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  px(240, 63, L.awnB.hi) px(240, 64, L.awnB.base)
  -- a gallery / staging
  local gal = rect(222, 98, 258, 100)
  rimOf(gal, L.timber) part(gal, L.timber, { nopop = true, noshade = true })
  for x = 223, 257, 4 do vline(x, 101, 103, L.timber.base) end
  -- sails: four lattice arms, canvas on two of them, bare frames on the other two (it's a working pump)
  local sails, frame = HP.mask(), HP.mask()
  for k = 0, 3 do
    local a = k * pi / 2 + .5
    local dx, dy, nx, ny = cos(a), sin(a), -sin(a), cos(a)
    local function P(t, s) return { hx + dx * t + nx * s, hy + dy * t + ny * s } end
    if k % 2 == 0 then sails:add(poly{ P(7, 0), P(36, 0), P(36, 6), P(7, 6) }) end
    frame:add(line({ P(0, 0), P(38, 0) }, 2))
    for t = 12, 36, 6 do frame:add(line({ P(t, 0), P(t, 6) })) end
    frame:add(line({ P(7, 6), P(36, 6) }))
  end
  local all = union(sails, frame)
  rimOf(all, L.timber)
  fill(sails, L.awnB.base)
  sails:each(function(x, y) local v = hash(x // 2, y // 2, 8) if v < .14 then px(x, y, L.awnB.shade) elseif v > .9 then px(x, y, L.awnB.hi) end end)
  part(frame, L.timber, { nopop = true, noshade = true })
  local hub = c:ellipse(hx, hy, 3, 3) rimOf(hub, L.timber) part(hub, L.iron)
  -- the scoop-wheel house on the left, thatched, with the water it lifts spilling into the dyke
  local sw = rect(212, 112, 226, 126)
  local swr = poly{ { 210, 113 }, { 228, 104 }, { 228, 113 } }
  rimOf(union(sw, swr), L.timber)
  part(sw, L.board) F.planks(sw, L.board, 3, true, 4)
  part(swr, L.roof) F.thatch(swr, L.roof, 104)
  hline(212, 226, 120, L.water.hi) fill(rect(214, 121, 224, 126), L.water.base)
end
windpump()
F.depth(1)
F.mist(150, 222, 117, 121, 64, .5) F.mist(260, 330, 117, 121, 65, .5)

---------------------------------------------------------------- back-left: the miller's daub cottage, reed thatch
F.depth(1)
F.tree(86, 128, 44, 1)
F.tree(10, 134, 40, 2)
local ctop, ccx, cwall = F.building{ x0 = 20, x1 = 66, yb = 138, wh = 26, rh = 22, wall = L.plaster, roof = L.roof, chimney = true }
F.window(26, 120, 31, 125, L.timber) F.door(46, 126, 53, 137, L.timber)
F.smoke(57, 92, 6, .6, 2)
F.fenceP(70, 140, 196, 132, 9)

---------------------------------------------------------------- right: the reed store on stilts over a pool, hoist and deck
F.depth(2)
F.tree(300, 156, 50, 1)
F.tree(452, 146, 56, 0)
F.tree(436, 140, 36, 3)
local spool = poly{ { 292, 168 }, { 436, 166 }, { 440, 184 }, { 400, 190 }, { 330, 190 }, { 296, 186 } }
rimOf(spool, L.peat)
F.water(spool, L.water, { dark = true })
F.stilts({ 304, 318, 334, 350, 366, 382, 398, 414, 422 }, 166, 188, 182)
local deck = rect(298, 161, 426, 166)
F.boardwalk(deck, true, 21)
hline(298, 426, 166, L.board.deep)
local top, cx, swall, sroof = F.building{ x0 = 330, x1 = 420, yb = 160, wh = 40, rh = 28, wall = L.board, roof = L.roof2, noAttic = true, noFrame = true, noShadow = true, ridge = L.timber }
F.planks(swall, L.board, 5, true, 9)
swall:each(function(x, y) if y > 154 and hash(x, y // 2, 12) < .45 then px(x, y, L.moss.shade) end end) -- damp at the foot
F.moss(sroof, .06, 69)
local posts = union(rect(330, top, 332, 160), rect(418, top, 420, 160))
part(posts, L.timber, { nopop = true, noshade = true })
-- loft door + hoist beam
local loft = rect(368, 124, 382, 138)
fill(loft, L.timber.deep) fill(rect(369, 125, 381, 138), L.soil.deep)
for y = 129, 137, 3 do bundleEnd(372, y, 1) bundleEnd(378, y, 1) end
local beamH = rect(372, 118, 400, 121)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 400, 118, L.timber.hi)
vline(396, 122, 132, L.board.deep) -- rope
-- the hoisted reed sheaf, slung in a rope sling
local hb = poly{ { 386, 134 }, { 408, 132 }, { 410, 140 }, { 388, 142 } }
rimOf(hb, L.reed) part(hb, L.reed, { nopop = true })
hb:each(function(x, y) if y % 2 == 0 then px(x, y, L.reed.hi) end if x > 405 then px(x, y, L.plume.base) end end)
bundleEnd(386, 138, 3)
hline(396, 397, 133, L.timber.deep) vline(396, 133, 141, L.timber.deep)
F.door(352, 136, 366, 159, L.timber)
F.window(396, 146, 404, 153, L.timber)
F.window(340, 128, 346, 134, L.timber)
-- bundle stacks on the deck (end-on) and a couple of flour sacks
for row = 0, 2 do for k = 0, 3 - row do bundleEnd(304 + k * 7 + row * 3, 157 - row * 6, 3) end end
F.sack(326, 160, L.plaster, 4)
F.depth(3)
local _, ghx, ghy = F.gnome(346, 166, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
line({ { ghx, ghy }, { 396, 122 } }):each(function(x, y) px(x, y, L.board.deep) end)

---------------------------------------------------------------- right middle: geese on the bank, a scythe gnome, stooks
F.depth(3)
F.goose(386, 202, true) F.goose(400, 206, false) F.goose(372, 208, true)
F.shadow(412, 432, 200, 5, 2)
stook(416, 200, 16)
stook(434, 196, 13)
local _, sx, sy = F.gnome(452, 216, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
-- the scythe: a long snath and a curved blade low in the sedge
line({ { sx + 2, sy - 4 }, { sx - 4, sy + 12 } }):each(function(x, y) px(x, y, L.board.base) end)
c:rim(line({ { sx - 4, sy + 12 }, { sx - 16, sy + 10 } }, 2), L.iron.edge)
line({ { sx - 4, sy + 12 }, { sx - 16, sy + 10 } }):each(function(x, y) px(x, y, L.iron.hi) end)
line({ { sx - 5, sy + 13 }, { sx - 15, sy + 11 } }):each(function(x, y) px(x, y, L.iron.shade) end)
for k = 0, 5 do F.sedge(430 + k * 3, 222 + (k % 2), 4, L.reed) end

F.depth(2)
F.tree(78, 166, 46, 3)
---------------------------------------------------------------- left hero: stilted tide mill over the channel, undershot wheel
F.depth(2)
-- the mill channel runs under the house and out to the pool at the bottom left
local chan = poly{ { 86, 184 }, { 214, 184 }, { 212, 200 }, { 182, 208 }, { 140, 208 }, { 124, 214 }, { 110, 222 }, { 84, 222 }, { 90, 206 }, { 84, 196 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(chan, pond)
rimOf(water, L.peat)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 183 then local v = hash(x, y, 51) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end end)
F.water(water, L.water)
-- in the shade under the mill deck the water is dark, with the stilts' reflections
local under = water:copy():clip(rect(84, 184, 216, 212))
F.water(under, L.water, { dark = true })
for _, sx in ipairs({ 92, 106, 122, 138, 154, 168 }) do for y = 205, 213, 2 do if water:has(sx, y) then px(sx, y, L.water.deep) px(sx + 1, y, L.water.shade) end end end
F.depth(3)
F.stilts({ 92, 106, 122, 138, 154, 168 }, 182, 204, 196)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 178, wh = 44, rh = 32, wall = TAR, roof = L.roof, chimney = true, noFrame = true, noShadow = true }
F.planks(wallM:copy():clip(rect(92, mtop + 2, 172, 178)), TAR, 4, false, 17)
wallM:each(function(x, y) if x <= 95 and y > mtop + 2 then px(x, y, TAR.hi) end end)
local corners = union(rect(92, mtop, 94, 178), rect(170, mtop, 172, 178), rect(92, mtop, 172, mtop + 1))
part(corners, L.board, { nopop = true, noshade = true })
-- the deck the mill stands on, silvered planks, mossy edge
local mdeck = rect(84, 179, 180, 183)
F.boardwalk(mdeck, true, 31)
F.door(108, 150, 120, 178, L.board)
F.window(134, 146, 142, 154, L.board)
F.window(150, 146, 158, 154, L.board)
F.window(100, 142, 104, 148, L.board)
-- a round sign over the door: an ear of wheat
local plaque = c:ellipse(114, 144, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
F.sprite({ ".g.", "gGg", "GgG", "gGg", ".t." }, 113, 142, { g = L.gold.shade, G = L.gold.base, t = L.timber.shade }, { rim = false })
-- window boxes with marsh marigolds
for _, wx in ipairs({ 138, 154 }) do
  hline(wx - 5, wx + 5, 157, L.timber.base) hline(wx - 5, wx + 5, 158, L.timber.deep)
  for k = -4, 4, 2 do px(wx + k, 156, L.reedGreen.base) px(wx + k + 1, 155, L.marigold.base) end
end
-- a gangway from the deck down to the left bank
local gang = poly{ { 70, 192 }, { 86, 180 }, { 90, 183 }, { 74, 195 } }
rimOf(gang, L.timber) part(gang, L.board, { nopop = true })
F.planks(gang, L.board, 3, true, 19)
-- eel traps (wicker cones) hanging on the stilts
for _, ex in ipairs({ 128, 146 }) do
  local t = poly{ { ex, 186 }, { ex + 4, 186 }, { ex + 3, 196 }, { ex + 1, 196 } }
  rimOf(t, L.reed) part(t, L.reed, { nopop = true }) t:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.reed.shade) end end)
end

-- the undershot wheel on an A-frame, dipping into the stream
local hx, hy, R = 194, 172, 24
local aframe = line({ { hx - 12, 206 }, { hx, hy } }, 2):add(line({ { hx + 12, 206 }, { hx, hy } }, 2))
rimOf(aframe, L.timber) part(aframe, L.timber, { nopop = true, noshade = true })
local outer = c:ellipse(hx, hy, R, R)
local ringO = outer:copy():cut(c:ellipse(hx, hy, R - 4, R - 4))
local ringI = c:ellipse(hx, hy, 8, 8):cut(c:ellipse(hx, hy, 5, 5))
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
part(spokes, L.timber, { nopop = true, noshade = true })
part(ringI, L.timber, { nopop = true })
part(pads, L.board, { nopop = true, noshade = true })
part(ringO, L.timber, { nopop = true })
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .8 and ((x - hx) ^ 2 + (y - hy) ^ 2) > (R - 2) ^ 2 then px(x, y, L.timber.hi) end end)
ringO:each(function(x, y) if y > hy + R * .45 and hash(x, y, 74) < .5 then px(x, y, hash(x, y, 75) < .5 and L.moss.base or L.moss.shade) end end)
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- the stream covers the bottom of the wheel; churned white water on the downstream (left) side, drips off the paddles
local wl = 194
wheel:grow(1):each(function(x, y) if y > wl and chan:has(x, y) then
  local s = hash((x + y * 3) // 6, y, 79)
  px(x, y, s < .3 and F.SKYREF or (y == wl + 1 and L.water.deep or L.water.base))
end end)
for x = hx - R - 6, hx + R + 2 do
  local v = hash(x, 1, 80)
  if v < .6 then px(x, wl, (x < hx) and L.awnB.hi or L.water.hi) end
  if x < hx - 4 and v < .35 then px(x, wl - 1, L.awnB.base) px(x - 1, wl + 1, L.water.hi) end
end
for k = 0, 7 do local a = pi * (.62 + k * .05) local x, y = floor(hx + cos(a) * (R + 2)), floor(hy + sin(a) * (R + 2)) px(x - 1, y + 2, L.water.hi) px(x - 1, y + 4, L.water.hi) end
-- quirk: a big green frog in a red gnome hat riding the top paddle, holding a bulrush
F.sprite({
  "......RR.......",
  ".....RRRr......",
  "....RRRRr......",
  ".EE.RRRRRr.EE..",
  "EpeEhhhhhhEpeE.",
  "GEEGGGGGGGGEEGg",
  "GHGGGGGGGGGGGGg",
  "gmmmmmmmmmmmmgg",
  ".GGGGGGGGGGGGg.",
  "..GyyyyyyyyGg..",
  ".GGyyyyyyyyGGg.",
  "GGg.Gyyyyyy.GGg",
  "Gg..GG....GG.gg",
}, hx - 7, hy - R - 15, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, E = L.leaf.hi, e = L.gold.hi, p = L.timber.edge,
  G = L.leaf.base, H = L.leaf.hi, g = L.leaf.shade, m = L.leaf.deep, y = L.marigold.hi })
do -- the frog's bulrush, held up beside its hat
  local bx, by = hx + 6, hy - R - 2
  local head = rect(bx, by - 21, bx + 1, by - 15)
  local stem = rect(bx, by - 14, bx, by):add(rect(bx, by - 24, bx, by - 22))
  c:rim(union(head, stem), L.timber.edge)
  vline(bx, by - 14, by, L.reedGreen.base) vline(bx, by - 24, by - 22, L.reedGreen.shade)
  fill(head, L.cattail.base) vline(bx, by - 21, by - 16, L.cattail.hi) px(bx + 1, by - 15, L.cattail.deep)
end

---------------------------------------------------------------- the mill pool (bottom-left): punt, geese, lilies, bulrushes
F.depth(3)
-- dark reflections of the willows and the mill along the far edge
for _, rx in ipairs({ 40, 58, 120, 140 }) do for k = 0, 5 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 222 + k * 2, L.water.shade) end end
for y = 200, 206, 2 do hline(100, 170, y, L.water.shade) end
-- a gnome poling a punt
F.punt(52, 104, 240, L.timber)
local _, phx, phy = F.gnome(70, 236, { hat = L.awnA, coat = L.leaf, arm = "up" })
line({ { phx + 4, phy - 10 }, { phx - 8, 252 } }):each(function(x, y) px(x, y, L.board.base) end)
line({ { phx + 5, phy - 10 }, { phx - 7, 252 } }):each(function(x, y) if y > phy then px(x, y, L.board.shade) end end)
for xx = phx - 12, phx - 4 do if hash(xx, 3, 81) < .6 then px(xx, 253, L.water.hi) end end
F.sack(92, 236, L.plaster, 4)
-- a greylag goose with three goslings in a line
F.goose(132, 246, false, true)
for k, gx in ipairs({ 146, 154, 162 }) do
  local gy = 249 + (k % 2)
  local m = c:ellipse(gx, gy, 2, 1):add(rect(gx - 2, gy - 3, gx - 1, gy - 1))
  rimOf(m, L.timber) part(m, L.gold, { nopop = true })
  px(gx - 3, gy - 2, L.produce.base) hline(gx - 3, gx + 3, gy + 2, L.water.hi)
end
-- lilies (one with a frog), bulrushes and reeds along the pool's left edge
for _, p in ipairs({ { 60, 226, true, "white" }, { 112, 256, true }, { 44, 252, false, "yellow" }, { 150, 238, true, "white" }, { 30, 240 }, { 100, 226 } }) do F.lily(p[1], p[2], p[3], p[4]) end
F.frog(114, 254, true)
F.reeds(14, 34, 248, 18, 82, { cattails = 4, green = true })
F.reeds(160, 184, 236, 14, 83, { cattails = 2 })
F.dragonfly(88, 214, L.accent) F.dragonfly(130, 228, L.apple, true)
-- mossy stones on the bank
F.moss(F.rock(176, 254, 8, 7), .3, 76)

---------------------------------------------------------------- left: reed-bundle stack, binding gnome, millstone
F.depth(3)
F.shadow(20, 72, 202, 8, 4)
-- the stack: bark... reed sides first, then the cut ends row by row
for row = 0, 3 do
  for k = 0, 3 - row do
    local lx, ly = 22 + k * 11 + row * 5, 196 - row * 10
    local side = rect(lx, ly - 5, lx + 10, ly + 5)
    rimOf(side, L.reed) part(side, L.reed, { nopop = true })
    side:each(function(x, y) if y % 2 == 0 then px(x, y, L.reed.hi) end end)
    vline(lx + 6, ly - 5, ly + 5, L.timber.deep)
  end
end
for row = 0, 3 do for k = 0, 3 - row do bundleEnd(22 + k * 11 + row * 5, 196 - row * 10, 5) end end
-- a millstone leaning on the stack
local ms = c:ellipse(76, 196, 8, 8)
rimOf(ms, L.stone) part(ms, L.stone)
fill(c:ellipse(76, 196, 2, 2), L.stone.deep) px(72, 191, L.stone.hi) px(73, 191, L.stone.hi)
for k = 0, 3 do local a = k * pi / 2 + .4 line({ { 76 + cos(a) * 3, 196 + sin(a) * 3 }, { 76 + cos(a) * 7, 196 + sin(a) * 7 } }):each(function(x, y) px(x, y, L.stone.shade) end) end
local _, bx, by = F.gnome(56, 214, { hat = L.roof2, coat = L.accent, arm = "hold" })
sheaf(bx + 4, by + 6, 14)
F.sedge(14, 214, 6) F.sedge(84, 212, 5) F.sedge(30, 218, 5)

---------------------------------------------------------------- right foreground: a pool, a punt of flour sacks, a heron
F.depth(3)
local rpool = poly{ { 290, 226 }, { 336, 220 }, { 370, 226 }, { 376, 244 }, { 362, 262 }, { 312, 264 }, { 290, 252 } }
rimOf(rpool, L.peat)
local rb = rpool:grow(2):cut(rpool)
rb:each(function(x, y) local v = hash(x, y, 52) px(x, y, v < .4 and L.peat.base or (v < .65 and L.peat.hi or L.sedgeGround.base)) end)
F.water(rpool, L.water)
for k = 0, 4 do hline(306 + k, 330 - k, 228 + k * 2, L.water.shade) end -- reflection of the store
F.punt(298, 346, 246, L.timber)
F.sack(312, 243, L.plaster, 3) F.sack(322, 243, L.plaster, 3) F.sack(332, 243, L.plaster, 3) F.sack(317, 238, L.plaster, 3)
F.heron(364, 250)
for xx = 356, 372 do if hash(xx, 2, 84) < .6 then px(xx, 251, L.water.hi) end end
F.lily(296, 258, true, "white") F.lily(352, 230, false)
F.reeds(372, 378, 226, 16, 85, { green = true })
F.reeds(284, 296, 262, 16, 86, { cattails = 2 })
F.dragonfly(342, 216, L.accent, true)
F.sign(436, 168, 28, 14, L.board)
F.sprite({ "..ww...", ".wwwk..", "wwww.o.", ".ww....", ".k.k..." }, 432, 171, { w = L.heron.shade, k = L.timber.edge, o = L.produce.base }, { rim = false })
-- marsh marigolds and sedge in the near right
for _, f in ipairs({ { 300, 214 }, { 352, 214 }, { 446, 228 }, { 458, 226 } }) do F.sedge(f[1], f[2], 7) px(f[1] - 1, f[2] - 5, L.marigold.base) px(f[1] + 2, f[2] - 4, L.marigold.hi) end
F.reeds(456, 470, 226, 20, 87, { cattails = 2, green = true })

---------------------------------------------------------------- gnome on the causeway with a reed bundle on his shoulder
local _, rhx, rhy = F.gnome(258, 240, { hat = L.roof2, coat = L.wall2, arm = "up" })
local rbund = poly{ { rhx - 18, rhy + 6 }, { rhx + 8, rhy - 4 }, { rhx + 10, rhy - 1 }, { rhx - 16, rhy + 9 } }
rimOf(rbund, L.reed) part(rbund, L.reed, { nopop = true })
rbund:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.reed.hi) end end)
px(rhx + 10, rhy - 3, L.plume.base) px(rhx + 11, rhy - 2, L.plume.hi) px(rhx + 9, rhy - 5, L.plume.base)
-- flour trail ... to a water vole with a floury nose
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.awnB.hi) px(253 - i * 4, 243 + i * 3, L.awnB.base) end
local vole = c:ellipse(222, 263, 4, 2):add(c:ellipse(218, 261, 2, 2))
rimOf(vole, L.soil) part(vole, L.soil, { nopop = true }) px(216, 261, L.awnB.hi) px(217, 259, L.soil.hi) px(218, 260, L.timber.edge)
line({ { 226, 263 }, { 229, 262 } }):each(function(x, y) px(x, y, L.soil.shade) end)
F.depth(0)
-- a skein of geese and a heron flying far off
F.birds({ { 300, 40, 2 }, { 306, 43, 2 }, { 312, 46, 2 }, { 294, 43, 2 }, { 288, 46, 2 }, { 140, 58, 1 }, { 186, 74, 1 } })
F.sprite({ "......ww....", "wwwwwwwww...", "..wwwwwwwkYY", ".wwwww......", "..www......." }, 380, 58, { w = L.heron.base, k = L.heron.deep, Y = L.marigold.shade }, { rim = false })

F.finish()
