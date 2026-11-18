-- mill.lua : "Old mill" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua) and the forest mill, re-cast for
-- an arctic tundra: road's end: a round stone wind-pump tower with a many-bladed fan wheel and a sod cap, between
-- two snowy spruces. Back left: a sod-roofed stone longhouse with peat smoke. Right: a falu-red granary on a stone
-- footing with a hoist lifting a net of grain sacks, a sack dock under snow, ptarmigans, a gnome shovelling snow.
-- Left hero: the stone-and-driftwood watermill under a snow-capped sod roof; overshot wheel fringed with icicles,
-- an icy flume, a steaming millrace. Bottom left: the mill pond, iced over except a steaming open lead with eiders.
-- Millstones, a gnome hauling a sack sledge, a reindeer pulling a loaded sledge, a snowy owl on the sign, a cairn
-- with a snow bunting, hare tracks, a sack-carrying gnome on the road with a flour trail to a lemming.
-- Quirk: an arctic hare in a red gnome hat riding the top paddle of the wheel, clutching an ear of barley.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 160, 330, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local S = L.snow
local SACK = F.rp("#ecd6aa #ccae80 #a68660 #7a604a #4a3a34") -- burlap: reads against the snow (awnB cream did not)

---------------------------------------------------------------- far right: open tundra, a cairn, a reindeer herd grazing
F.depth(1)
for _, w in ipairs({ { 292, 124, 5, 4 }, { 330, 130, 6, 4 }, { 462, 128, 5, 4 }, { 376, 140, 7, 5 }, { 300, 142, 6, 5 } }) do F.willow(w[1], w[2], w[3], w[4], w[1]) end
F.drift(420, 146, 22, 5, 7)
F.cairn(352, 136, 14, 3)
-- the herd: small reindeer silhouettes heads-down in the lichen, antlers up
local function smallDeer(x, yb, flip, grazing)
  local s = flip and -1 or 1
  local body = rect(x - 3, yb - 5, x + 3, yb - 3)
  local legs = rect(x - 3, yb - 2, x - 3, yb):add(rect(x + 2, yb - 2, x + 2, yb))
  local head = grazing and rect(x + 4 * s, yb - 3, x + 5 * s, yb - 1) or rect(x + 4 * s, yb - 7, x + 5 * s, yb - 5)
  if s < 0 then head = grazing and rect(x - 5, yb - 3, x - 4, yb - 1) or rect(x - 5, yb - 7, x - 4, yb - 5) end
  local m = union(body, legs, head)
  c:rim(m, L.deer.edge)
  fill(m, L.deer.base) hline(x - 3, x + 3, yb - 5, L.deer.hi) px(x + 3 * s, yb - 3, L.fur.base) fill(legs, L.deer.deep)
  local ax = x + 4 * s + (s > 0 and 0 or 1)
  local ay = grazing and yb - 4 or yb - 8
  px(ax, ay, L.board.shade) px(ax - s, ay - 1, L.board.shade) px(ax + s, ay - 1, L.board.shade) px(ax, ay - 2, L.board.deep)
end
for _, d in ipairs({ { 394, 128, false, true }, { 406, 126, false, false }, { 418, 131, true, true }, { 440, 127, false, true }, { 452, 133, true, false }, { 312, 134, true, true } }) do smallDeer(d[1], d[2], d[3], d[4]) end
F.tracks({ { 380, 142 }, { 400, 134 }, { 430, 132 } }, "deer", 5)

---------------------------------------------------------------- road's end: the stone wind-pump between two spruces
F.depth(2)
F.tree(206, 128, 62, 2)
F.tree(276, 128, 56, 4)
local function windpump()
  local body = poly{ { 227, 126 }, { 253, 126 }, { 250, 86 }, { 230, 86 } }
  local capM = poly{ { 225, 89 }, { 240, 70 }, { 255, 89 } }
  F.shadow(227, 253, 126, 8, 3)
  rimOf(union(body, capM), L.timber)
  part(body, L.stone)
  F.rubble(body, L.stone, 86, 5, 81)
  body:each(function(x, y) if x > 246 and hash(x, y, 82) < .5 then px(x, y, L.stone.shade) end end)
  part(capM, L.roof, { sep = true })
  F.sod(capM, L.roof, 70, 240)
  F.snowCap(capM, 3, 83, { cx = 241, lip = true })
  F.icicles(226, 254, 90, 4, 84)
  -- door with warm lamp light, a little window
  local d = rect(235, 109, 245, 125)
  fill(d, L.timber.edge)
  fill(rect(236, 110, 244, 125), L.glow.shade) fill(rect(236, 110, 239, 116), L.glow.base) px(236, 110, L.glow.hi)
  vline(240, 110, 125, L.timber.deep)
  hline(233, 247, 108, L.timber.hi)
  F.window(238, 94, 242, 99, L.timber)
  -- tail vane on a rod behind the wheel (to the right)
  local rod = rect(244, 69, 266, 70)
  local vane = poly{ { 258, 62 }, { 270, 64 }, { 270, 76 }, { 258, 74 } }
  rimOf(union(rod, vane), L.timber)
  part(rod, L.iron, { nopop = true, noshade = true })
  part(vane, L.wall2, { nopop = true })
  F.planks(vane, L.wall2, 3, true, 85)
  hline(258, 270, 62, S.hi)
  -- the fan wheel: 14 blades between an inner and an outer ring, lit upper-left blades paler
  local hx, hy, R = 240, 68, 15
  local blades, ring = HP.mask(), c:ellipse(hx, hy, R, R):cut(c:ellipse(hx, hy, R - 1, R - 1))
  local bl = {}
  for k = 0, 11 do
    local a0, a1 = k * 2 * pi / 12, k * 2 * pi / 12 + .27
    local b = poly{ { hx + cos(a0) * 4, hy + sin(a0) * 4 }, { hx + cos(a0) * (R - 1), hy + sin(a0) * (R - 1) },
      { hx + cos(a1) * (R - 1), hy + sin(a1) * (R - 1) }, { hx + cos(a1) * 4, hy + sin(a1) * 4 } }
    blades:add(b) bl[#bl + 1] = { b, a0 }
  end
  local hub = c:ellipse(hx, hy, 3, 3)
  local ring2 = c:ellipse(hx, hy, 7, 7):cut(c:ellipse(hx, hy, 6, 6))
  F.obj()
  -- blades are not ink-rimmed (the rim would fill the sky gaps); each gets a deep lower/right edge instead
  for _, b in ipairs(bl) do
    local lit = cos(b[2] + .15) * -.7 + sin(b[2] + .15) * -.7
    local br = (#bl % 2 == 0) and L.board or L.wall2
    br = (floor(b[2] / (2 * pi / 12) + .5) % 2 == 0) and L.board or L.wall2 -- alternate cream and falu-red blades
    fill(b[1], lit > .3 and br.hi or (lit > -.3 and br.base or br.shade))
    b[1]:each(function(x, y) if not b[1]:has(x + 1, y) or not b[1]:has(x, y + 1) then px(x, y, L.timber.deep) end end)
  end
  rimOf(union(ring, hub), L.timber)
  fill(ring2, L.timber.shade)
  -- rime frost on the upper blades
  blades:each(function(x, y) if y < hy - 6 and not blades:has(x, y - 1) and hash(x, y, 86) < .5 then px(x, y, S.hi) end end)
  -- weathervane: a little fish on top of the vane rod
  F.sprite({ ".FFF.", "FFFFf", ".fff." }, 264, 57, { F = L.gold.base, f = L.gold.shade })
  -- pump pipe down the tower into an iced trough
  vline(254, 96, 120, L.iron.shade) vline(255, 96, 120, L.iron.deep)
  local trough = rect(254, 120, 266, 125)
  rimOf(trough, L.timber) part(trough, L.timber, { nopop = true })
  hline(255, 265, 120, L.ice.hi) hline(255, 265, 121, L.ice.base)
  F.icicles(255, 265, 126, 2, 87, .5)
end
windpump()
F.steam(260, 118, 4, .3, 9) -- breath of the trough

---------------------------------------------------------------- back-left: sod-roofed stone longhouse
F.depth(1)
F.tree(84, 128, 44, 2)
F.tree(10, 134, 40, 1)
local ltop, lcx, lwall = F.building{ x0 = 20, x1 = 66, yb = 138, wh = 26, rh = 22, wall = L.stone, roof = L.roof, chimney = true, noFrame = true, snow = 4 }
F.rubble(lwall, L.stone, ltop + 4, 4, 88)
F.window(27, 120, 32, 125, L.timber) F.window(56, 120, 61, 125, L.timber) F.door(40, 124, 47, 137, L.timber)
F.smoke(57, 90, 6, .6, 2)
F.fenceP(70, 140, 196, 132, 9)
-- a drift banked against the fence
F.drift(150, 138, 26, 3, 9)

---------------------------------------------------------------- right: the falu-red granary with a hoist lifting grain sacks
F.depth(2)
F.tree(300, 152, 54, 1)
F.tree(452, 142, 58, 6)
F.tree(436, 136, 40, 7)
local top, cx, gwall, groof = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 28, wall = L.wall2, roof = L.roof, noAttic = true, noFrame = true, snow = 4 }
F.planks(gwall, L.wall2, 5, true, 9)
-- stone footing, white-painted corner boards and sill (Nordic trim)
local gfoot = rect(330, 162, 420, 170)
part(gfoot, L.stone, { nopop = true }) F.rubble(gfoot, L.stone, 162, 4, 89)
local trim = union(rect(330, top, 332, 161), rect(418, top, 420, 161), rect(330, 160, 420, 161))
part(trim, L.plaster, { nopop = true, noshade = true })
-- loft door + hoist beam
local loft = rect(368, 98, 382, 112)
fill(loft, L.plaster.deep) fill(rect(369, 99, 381, 112), L.soil.deep)
F.sack(372, 112, SACK, 3) F.sack(379, 112, SACK, 3)
local beamH = rect(372, 92, 398, 95)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 92, S.hi) hline(374, 396, 91, S.base)
vline(394, 96, 126, L.board.deep) -- rope
-- the hoisted net of three grain sacks
F.sack(388, 140, SACK, 5) F.sack(400, 140, SACK, 5) F.sack(394, 133, SACK, 5)
for _, ln in ipairs({ { 394, 126, 384, 134 }, { 394, 126, 404, 134 }, { 386, 136, 402, 136 } }) do
  line({ { ln[1], ln[2] }, { ln[3], ln[4] } }):each(function(x, y) px(x, y, L.board.deep) end)
end
F.door(352, 136, 366, 159, L.timber)
F.window(396, 146, 404, 153, L.plaster)
F.window(340, 128, 346, 134, L.plaster)
-- loading dock: frosted planks, sacks under a snow crust
local dock = rect(300, 158, 340, 172)
rimOf(dock, L.timber) part(dock, L.timber)
F.planks(dock, L.timber, 6, true, 11)
hline(300, 340, 158, S.hi) hline(301, 339, 159, S.base)
local sacks = {}
for _, sk in ipairs({ { 306, 157 }, { 316, 157 }, { 326, 157 }, { 311, 148 }, { 321, 148 }, { 316, 139 } }) do
  sacks[#sacks + 1] = F.sack(sk[1], sk[2], SACK, 4)
end
for _, m in ipairs(sacks) do F.snowCap(m, 2, 90) end
F.depth(3)
local _, ghx, ghy = F.gnome(354, 182, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 143, ghy, L.board.deep) -- hauling the hoist rope
line({ { ghx, 143 }, { 394, 126 } }):each(function(x, y) px(x, y, L.board.deep) end)

---------------------------------------------------------------- right middle: ptarmigans, a quern, a gnome clearing snow
local function ptarmigan(x, yb, flip, pose)
  F.sprite(flip and {
    ".WW......",
    "bKWW.....",
    ".WWWWWWWW",
    ".wWWWWWWk",
    "..wWWWWw.",
    "...o..o..",
  } or {
    "......WW.",
    ".....WWKb",
    "WWWWWWWW.",
    "kWWWWWWw.",
    ".wWWWWw..",
    "..o..o...",
  }, x - 4, yb - 5, { W = L.fur.base, w = L.fur.shade, K = L.timber.edge, b = L.timber.edge, k = L.timber.edge, o = L.soil.shade })
  px(flip and x - 3 or x + 3, yb - 5, L.apple.base) -- red eye-comb
end
F.shadow(372, 412, 198, 6, 3)
-- a snow heap the gnome is building, with the shovel's last load on top
local heap = poly{ { 376, 200 }, { 384, 190 }, { 392, 188 }, { 400, 192 }, { 406, 200 } }
c:rim(heap, S.deep)
fill(heap, S.base)
heap:each(function(x, y) if x < 388 and hash(x, y, 91) < .6 then px(x, y, S.hi) elseif x > 396 then px(x, y, S.shade) end end)
hline(386, 394, 189, S.hi)
local _, shx, shy = F.gnome(414, 204, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
-- the wooden snow shovel, a scoop of snow on its blade
line({ { shx, shy }, { shx - 7, shy + 6 } }):each(function(x, y) px(x, y, L.board.base) end)
local blade = rect(shx - 11, shy + 6, shx - 6, shy + 8)
c:rim(blade, L.timber.edge) fill(blade, L.board.base) hline(shx - 11, shx - 6, shy + 5, S.hi)
ptarmigan(372, 210) ptarmigan(390, 214, true) ptarmigan(430, 214)
-- a leaning quern stone
local q = c:ellipse(434, 198, 6, 6)
c:rim(q, L.stone.edge) part(q, L.stone, { nopop = true })
fill(c:ellipse(434, 198, 1, 1), L.stone.deep) px(431, 195, L.stone.hi) px(432, 194, L.stone.hi)
hline(430, 437, 192, S.hi)

F.depth(2)
F.birch(76, 162, 48, 43)
---------------------------------------------------------------- left hero: stone-and-driftwood mill house + overshot wheel
F.depth(3)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 30, wall = L.timber, roof = L.roof, chimney = true, noFrame = true, snow = 4, icicles = 6 }
-- silver driftwood weatherboards above, a rubble-stone lower storey
local boards = wallM:copy():clip(rect(92, mtop + 2, 172, 161))
F.planks(boards, L.timber, 4, false, 17)
boards:each(function(x, y) if hash(x // 6, y // 4, 18) < .08 then px(x, y, L.board.base) end end) -- a few newer planks
local foot = rect(92, 162, 172, 186)
part(foot, L.stone, { nopop = true }) F.rubble(foot, L.stone, 162, 5, 70)
hline(92, 172, 161, L.timber.edge) hline(92, 172, 162, S.base)
local corners = union(rect(92, mtop, 94, 161), rect(170, mtop, 172, 161))
part(corners, L.timber, { nopop = true, noshade = true })
F.door(108, 164, 120, 185, L.timber)
F.window(134, 146, 142, 154, L.timber)
F.window(150, 146, 158, 154, L.timber)
F.window(100, 142, 104, 148, L.timber)
F.window(150, 170, 156, 176, L.stone)
-- a round sign over the door: a barley sheaf
local plaque = c:ellipse(114, 156, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
F.sprite({ "g.g.g", ".ggg.", "..g..", ".bbb.", "..g.." }, 112, 153, { g = L.gold.shade, b = L.soil.base }, { rim = false })
-- snow on the window sills
for _, wx in ipairs({ 138, 154 }) do hline(wx - 5, wx + 5, 157, S.hi) hline(wx - 4, wx + 4, 156, S.base) end

-- stone wheel pit behind the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.rubble(pit, L.stone, 176, 6, 72)
F.icicles(170, 214, 176, 3, 73, .3)
-- flume on trestles bringing the water over the top of the wheel, icicles along its belly, snow on the lip
local flume = poly{ { 186, 140 }, { 226, 130 }, { 226, 135 }, { 186, 145 } }
local legs = rect(218, 135, 220, 150):add(rect(206, 138, 208, 152))
rimOf(union(flume, legs), L.timber)
part(legs, L.timber, { nopop = true, noshade = true })
part(flume, L.board)
line({ { 187, 140 }, { 225, 130 } }):each(function(x, y) px(x, y, L.water.base) px(x, y - 1, S.hi) end)
for x = 187, 225 do
  local yb = floor(145 - (x - 186) * .25 + .5) + 1
  if hash(x, 1, 74) < .5 then for k = 0, floor(hash(x, 2, 74) * 5) do px(x, yb + k, k == 0 and L.ice.hi or L.ice.base) end end
end

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
-- ice fringe: a glaze of ice on the lower rim and paddles, icicles hanging off them, rime on the upper rim
wheel:each(function(x, y)
  if y > hy + R * .45 and hash(x, y, 75) < .4 then px(x, y, hash(x, y, 76) < .5 and L.ice.base or L.ice.shade) end
  if y < hy - R * .3 and not wheel:has(x, y - 1) and hash(x, y, 77) < .6 then px(x, y, S.hi) end
end)
wheel:each(function(x, y)
  if y > hy + 2 and not wheel:has(x, y + 1) and hash(x, y, 78) < .45 then
    local len = 1 + floor(hash(x, y, 79) ^ 1.5 * 6)
    for k = 1, len do if not wheel:has(x, y + k) then px(x, y + k, k == len and L.ice.deep or (k == 1 and L.ice.hi or L.ice.base)) end end
  end
end)
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- water pouring over the far side of the wheel, splash, steam
local pour = poly{ { 184, 142 }, { 190, 142 }, { 214, 160 }, { 220, 182 }, { 216, 198 }, { 212, 182 }, { 208, 162 } }
pour:cut(spokes):cut(ringI)
pour:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.water.hi or L.water.base) end)
for i = 0, 8 do local x, y = 200 + floor(hash(i, 1, 9) * 26), 192 + floor(hash(i, 2, 9) * 10) px(x, y, L.water.hi) px(x + 1, y, L.ice.hi) end
-- quirk: an arctic hare in a red gnome hat riding the top paddle, ears poking through, clutching an ear of barley
F.sprite({
  "...........kk.......",
  "..........kFp.......",
  ".........kFFp..R....",
  ".........FFp..RRr...",
  "........FFp..RRRr...",
  "........FFfhRRRRRr..",
  ".......hhhhhhhhhhh..",
  ".......FFFFFFFFFFf..",
  "..fFFFfFFFFFeFFFFFn.",
  ".FFFFFFFFFFFFFFFFf..",
  "FFFFFFFFFFFFFFFFf...",
  "FFFFFFFFFFFFFGGf....",
  "FFFFFFFFFFFfGGg.....",
  "fFFFFFFFFFf..g......",
  ".ffFFf.fFFf.........",
  "..ff....ff..........",
}, 174, 125, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, F = L.fur.hi, f = L.fur.shade, K = L.timber.edge,
  k = L.timber.edge, p = L.petal.hi, e = L.timber.edge, n = L.petal.base, G = L.gold.base, g = L.gold.shade })

---------------------------------------------------------------- tail race and mill pond (bottom-left): ice with a steaming open lead
local stream = poly{ { 170, 200 }, { 214, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.ice)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 199 then local v = hash(x, y, 51) px(x, y, v < .3 and L.stone.base or (v < .75 and S.hi or S.shade)) end end)
-- the open lead: the race and the water it keeps open
local lead = union(stream, c:ellipse(146, 234, 30, 8), c:ellipse(112, 230, 18, 5)):clip(water)
local iceM = water:copy():cut(lead)
F.water(lead, L.water)
-- the ice sheet: pale, lit far edge, long cracks, snow skiffs, a dark rim along the lead
iceM:each(function(x, y)
  local v = F.vnoise(x / 14, y / 4, 61)
  local h = v < .35 and L.ice.base or (v < .7 and L.ice.hi or S.base)
  if hash(x, y, 62) < .04 then h = L.ice.shade end
  px(x, y, h)
end)
for _, ck in ipairs({ { { 30, 246 }, { 52, 242 }, { 70, 250 }, { 96, 248 } }, { { 60, 258 }, { 84, 254 }, { 110, 260 } }, { { 120, 246 }, { 136, 252 }, { 150, 250 } } }) do
  line(ck):each(function(x, y) if iceM:has(x, y) then px(x, y, L.ice.deep) if iceM:has(x, y + 1) then px(x, y + 1, L.ice.hi) end end end)
end
iceM:each(function(x, y) if lead:has(x, y - 1) or lead:has(x + 1, y) or lead:has(x - 1, y) or lead:has(x, y + 1) then px(x, y, L.ice.hi) if lead:has(x, y - 1) then px(x, y, L.ice.shade) end end end)
-- reflections of the wheel in the lead
for y = 206, 214, 3 do hline(176, 196, y, L.water.shade) end
-- steam curling off the warm race
F.steam(184, 214, 7, .6, 3) F.steam(150, 230, 6, .8, 5) F.steam(206, 200, 6, .4, 7) F.steam(120, 228, 4, .7, 8)
-- common eiders in the lead: a drake (white back, black flanks, mint nape) and a brown duck
local function eider(x, y, drake)
  local m = c:ellipse(x, y, 5, 3):add(c:ellipse(x + 5, y - 4, 2, 2))
  rimOf(m, L.timber)
  part(m, drake and L.fur or L.deer, { nopop = true })
  if drake then
    hline(x - 4, x + 3, y + 1, L.timber.edge) hline(x - 3, x + 2, y + 2, L.timber.deep)
    px(x + 4, y - 5, "#a8d8c0") px(x + 5, y - 5, "#a8d8c0") px(x + 6, y - 3, L.timber.edge) px(x - 5, y, L.timber.edge)
  else
    for k = -3, 3, 2 do px(x + k, y - 1, L.deer.shade) end
  end
  fill(rect(x + 7, y - 4, x + 8, y - 3), drake and L.gold.shade or L.deer.deep) px(x + 5, y - 5, L.timber.edge) hline(x - 6, x + 6, y + 3, L.water.hi)
end
eider(146, 234, true) eider(132, 238) eider(162, 236, true)
-- dry sedge and cotton grass poking through the bank snow
for i = 0, 8 do
  local x = 20 + i * 3 local h = 6 + floor(hash(i, 9, 52) * 8)
  vline(x, 247 - h, 247, i % 2 == 0 and L.fern.shade or L.fern.base)
  if i % 3 == 0 then px(x, 247 - h - 1, L.awnB.hi) px(x + 1, 247 - h - 1, L.awnB.base) px(x, 247 - h - 2, L.awnB.hi) end
end
-- snow-capped boulders on the bank
F.snowCap(F.rock(166, 252, 9, 8), 3, 76)
F.snowCap(F.rock(16, 232, 7, 6), 2, 77)
-- plank footbridge over the race, snow on the deck
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.timber) part(br, L.timber)
F.planks(br, L.timber, 5, true, 13)
F.snowCap(br, 2, 14)
-- hare tracks crossing the ice to the wheel
F.tracks({ { 40, 258 }, { 70, 246 }, { 100, 244 } }, "hare", 7)

---------------------------------------------------------------- left: millstones, sacks under snow, a gnome hauling a sack sledge
F.depth(3)
F.shadow(30, 92, 202, 8, 4)
-- two millstones leaning on each other
for _, ms in ipairs({ { 40, 190, 11 }, { 60, 194, 9 } }) do
  local m = c:ellipse(ms[1], ms[2], ms[3], ms[3])
  c:rim(m, L.stone.edge) part(m, L.stone, { nopop = true })
  m:each(function(x, y)
    local d = math.sqrt((x - ms[1]) ^ 2 + (y - ms[2]) ^ 2)
    if floor(d) == ms[3] - 3 and (x - ms[1]) + (y - ms[2]) > 0 then px(x, y, L.stone.deep) end
    if (x - ms[1]) * .6 + (y - ms[2]) > 0 and math.abs((x - ms[1]) * .6 - (y - ms[2]) * .3) < .6 then px(x, y, L.stone.shade) end -- dress furrows
  end)
  fill(c:ellipse(ms[1], ms[2], 2, 2), L.stone.edge) px(ms[1] - 1, ms[2] - 1, L.stone.deep)
  F.snowCap(m, 2, ms[1])
end
-- a stack of grain sacks against the mill under a crust of snow
for _, sk in ipairs({ { 76, 198 }, { 86, 198 }, { 81, 189 } }) do F.snowCap(F.sack(sk[1], sk[2], SACK, 4), 2, sk[1]) end
-- the sack sledge (pulk): curled runners, a slatted bed, three sacks
local function pulk(x0, yb, w)
  local runner = line({ { x0, yb }, { x0 + w, yb } }):add(line({ { x0 + w, yb }, { x0 + w + 3, yb - 3 }, { x0 + w + 2, yb - 5 } }))
  local bed = rect(x0 + 1, yb - 5, x0 + w - 1, yb - 2)
  rimOf(union(runner, bed), L.timber)
  part(runner, L.iron, { nopop = true, noshade = true }) hline(x0, x0 + w, yb, L.iron.hi)
  part(bed, L.board) F.planks(bed, L.board, 4, true, 19)
  for k = 0, 2 do F.sack(x0 + 6 + k * 9, yb - 5, k == 1 and L.produce or SACK, 4) end
  hline(x0 + 3, x0 + w - 3, yb - 9, L.soil.base)
end
F.shadow(58, 92, 214, 6, 3)
pulk(60, 214, 30)
local _, phx0, phy0 = F.gnome(104, 214, { hat = L.awnA, coat = L.leaf, arm = "out", flip = true })
line({ { phx0, phy0 }, { 94, 210 } }):each(function(x, y) px(x, y, L.soil.base) end)
F.tracks({ { 126, 216 }, { 112, 216 } }, "boot", 5)
-- willow scrub along the left edge
F.willow(24, 200, 7, 8, 11) F.willow(28, 214, 5, 6, 12)

---------------------------------------------------------------- right foreground: a reindeer pulling a loaded sledge, the owl on the sign
F.depth(3)
local function sledge(x0, yb)
  local runner = line({ { x0, yb }, { x0 + 40, yb } }):add(line({ { x0 + 40, yb }, { x0 + 45, yb - 4 }, { x0 + 44, yb - 8 } }))
  local bed = rect(x0 + 2, yb - 7, x0 + 38, yb - 3)
  local stan = rect(x0 + 6, yb - 3, x0 + 7, yb - 1):add(rect(x0 + 32, yb - 3, x0 + 33, yb - 1))
  rimOf(union(runner, bed, stan), L.timber)
  part(runner, L.timber, { nopop = true, noshade = true }) hline(x0, x0 + 40, yb, S.hi)
  part(stan, L.timber, { nopop = true, noshade = true })
  part(bed, L.wall2) F.planks(bed, L.wall2, 4, true, 23)
  local loads = {}
  for _, sk in ipairs({ { 8, -7 }, { 19, -7 }, { 30, -7 }, { 13, -15 }, { 25, -15 } }) do loads[#loads + 1] = F.sack(x0 + sk[1], yb + sk[2], SACK, 5) end
  F.snowCap(loads[4], 2, 24) F.snowCap(loads[5], 2, 25)
end
local function reindeer(x, yb)
  local body = c:ellipse(x, yb - 15, 12, 6)
  local neck = poly{ { x + 6, yb - 18 }, { x + 12, yb - 26 }, { x + 17, yb - 25 }, { x + 13, yb - 14 } }
  local head = c:ellipse(x + 16, yb - 26, 4, 3):add(poly{ { x + 16, yb - 28 }, { x + 23, yb - 25 }, { x + 23, yb - 22 }, { x + 17, yb - 23 } })
  local legs = HP.mask()
  for _, lx in ipairs({ -9, -5, 6, 10 }) do legs:add(line({ { x + lx, yb - 11 }, { x + lx + (lx > 0 and 1 or -1), yb } }, 2)) end
  local tail = rect(x - 13, yb - 19, x - 12, yb - 16)
  local antl = HP.mask()
  for _, a in ipairs({ { { x + 14, yb - 29 }, { x + 11, yb - 35 }, { x + 9, yb - 42 }, { x + 12, yb - 47 } }, { { x + 17, yb - 29 }, { x + 19, yb - 36 }, { x + 18, yb - 43 }, { x + 22, yb - 47 } },
    { { x + 11, yb - 35 }, { x + 7, yb - 37 } }, { { x + 10, yb - 40 }, { x + 5, yb - 42 } }, { { x + 19, yb - 36 }, { x + 23, yb - 39 } }, { { x + 18, yb - 41 }, { x + 23, yb - 44 } }, { { x + 15, yb - 30 }, { x + 18, yb - 33 } } }) do
    antl:add(line(a, 1))
  end
  local m = union(body, neck, head, legs, tail, antl)
  F.shadowM(c:ellipse(x - 4, yb + 1, 16, 2))
  rimOf(m, L.deer)
  part(legs, L.deer, { nopop = true, noshade = true })
  legs:each(function(xx, yy) if yy > yb - 3 then px(xx, yy, L.deer.edge) elseif yy > yb - 6 then px(xx, yy, L.fur.base) end end) -- white socks, dark hooves
  part(body, L.deer)
  body:each(function(xx, yy) if yy > yb - 12 then px(xx, yy, L.fur.shade) end end) -- pale belly
  part(neck, L.fur, { nopop = true })
  neck:each(function(xx, yy) if hash(xx, yy, 92) < .25 then px(xx, yy, L.fur.shade) end end)
  part(head, L.deer, { nopop = true })
  px(x + 17, yb - 27, L.timber.edge) px(x + 23, yb - 24, L.timber.edge) px(x + 13, yb - 28, L.deer.deep) -- eye, nose, ear
  part(antl, L.board, { nopop = true, noshade = true })
  antl:each(function(xx, yy) if hash(xx, yy, 93) < .35 then px(xx, yy, L.board.shade) end end)
  part(tail, L.fur, { nopop = true, noshade = true })
  -- harness: a red collar with a brass bell, a trace line back to the sledge
  local collar = line({ { x + 9, yb - 20 }, { x + 13, yb - 15 } }, 2)
  fill(collar, L.awnA.base) px(x + 9, yb - 20, L.awnA.hi)
  fill(rect(x + 13, yb - 14, x + 14, yb - 13), L.gold.base) px(x + 13, yb - 14, L.gold.hi)
  line({ { x + 10, yb - 16 }, { x - 14, yb - 12 } }):each(function(xx, yy) if not body:has(xx, yy) then px(xx, yy, L.soil.shade) end end)
  return m
end
F.shadow(296, 344, 226, 8, 3)
sledge(298, 226)
reindeer(356, 226)
F.tracks({ { 296, 236 }, { 270, 250 } }, "deer", 6)
-- a snowy spruce and willow scrub in the near right (clear of the compass corner x>=380, y>=230)
F.conifer(364, 266, 30, L.foliage2, 41)
F.willow(312, 260, 8, 9, 31) F.willow(338, 256, 6, 7, 32) F.willow(450, 224, 7, 8, 33)
F.conifer(424, 226, 22, L.foliage, 42)
F.sign(436, 168, 28, 14, L.board)
F.sprite({ "g.g.g", ".ggg.", "..g..", ".bbb.", "..g.." }, 434, 171, { g = L.gold.shade, b = L.soil.base }, { rim = false })
hline(422, 450, 167, S.hi)
-- a snowy owl perched on the sign, yellow eyes, dark barring
F.sprite({
  "..WWWWW...",
  ".WWWWWWWw.",
  ".WyKWyKWw.",
  ".WWWbWWWw.",
  "WWWWWWWWWw",
  "WWsWWWsWWw",
  "WWWWsWWWsw",
  "WsWWWWsWWw",
  ".WWsWWWWw.",
  "..wwwww...",
  "..g...g...",
}, 426, 156, { W = L.fur.hi, w = L.fur.shade, y = L.gold.hi, K = L.timber.edge, b = L.timber.edge, s = L.fur.deep, g = L.timber.edge })
-- driftwood stacked against the sign post: bleached silver ends
for k = 0, 2 do F.logEnd(452 + k * 6, 200, 3) end
for k = 0, 1 do F.logEnd(455 + k * 6, 194, 3) end
F.logEnd(458, 188, 3)
hline(449, 467, 196, S.base) hline(453, 462, 190, S.hi) hline(455, 461, 184, S.hi)

-- by the road, right: a cairn with a snow bunting on top, bird tracks
F.cairn(288, 216, 14, 5)
F.sprite({ -- snow bunting: white body, black wing and tail, buff cap
  "...cc..",
  "..cWWk.",
  "WWWWWb.",
  "KWWKWW.",
  ".KKWW..",
  "..o.o..",
}, 284, 199, { W = L.fur.hi, c = L.board.hi, k = L.timber.edge, b = L.gold.shade, K = L.timber.edge, o = L.timber.deep })
F.tracks({ { 296, 220 }, { 306, 214 }, { 312, 216 } }, "bird", 4)

---------------------------------------------------------------- gnome on the road with a grain sack on his shoulder
local _, rhx, rhy = F.gnome(258, 240, { hat = L.roof2, coat = L.accent, arm = "up" })
F.sack(rhx - 2, rhy + 4, SACK, 4)
-- flour trail ... to a lemming with a floury nose
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.awnB.hi) px(253 - i * 4, 243 + i * 3, L.awnB.base) end
F.sprite({ -- a Norway lemming facing the trail: dark cap and back, golden flanks, flour on its nose
  "...kk.kkk.....",
  "..KKKKKKKKk...",
  ".KeKKKKKKKDd..",
  "WDDDDKDDDDDDd.",
  "WWDDDDDDDDDdd.",
  ".pDDdDDDDDdd..",
  "..o.o...o.o...",
}, 212, 258, { k = L.soil.shade, K = L.soil.deep, e = L.timber.edge, D = L.gold.shade, d = L.deer.shade, W = L.awnB.hi,
  p = L.petal.base, o = L.soil.deep })
F.tracks({ { 214, 266 }, { 200, 262 } }, "bird", 3)
F.depth(0)
F.birds({ { 300, 40, 2 }, { 310, 46, 1 }, { 292, 49, 1 }, { 140, 58, 2 }, { 186, 74, 1 } })

F.finish()
