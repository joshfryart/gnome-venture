-- mill.lua : "Old mill" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua), re-cast for a chalk-and-dune coast:
-- road's end: a white-washed tower windmill with a tarred boat cap and white sails, on a marram dune top, the sea
-- and luggers behind it. Back left: a fisherman's cottage (slate roof, blue door), smoke blown out to sea, an
-- upturned boat and nets on poles. Right: the tarred salt store with a red pantile roof and a hoist lifting a salt
-- sack; salt pans with white heaps beyond; a dock of salt sacks, barrels and fish boxes. Left hero: the white
-- weatherboard tide mill on a barnacled granite footing, an undershot wheel fed through a timber sluice.
-- Bottom left: the tide pool (anemones, a starfish, wrack) with an eider duck family. Millstones, flour sacks and
-- lobster pots; a shrimping gnome; two gnomes carrying a salt handbarrow past a kelp rack; a handcart of sacks; a
-- herring gull on a driftwood bollard; a sack-carrying gnome whose flour trail leads to a crab.
-- Quirk: a puffin in a red gnome hat riding the top paddle of the wheel, with a beakful of sand eels.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 160, 330, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

---------------------------------------------------------------- the right headland: a little lighthouse; sea life
local lhx, lhy = 452, floor(F.fFar(452))
local lt = rect(lhx - 2, lhy - 13, lhx + 1, lhy)
fill(lt, F.mix(L.chalk.hi, "#d4e2e8", .15))
lt:each(function(x, y) if (y - lhy) % 6 < 3 and y < lhy - 1 then px(x, y, F.mix(L.awnA.base, "#d4e2e8", .25)) end if x == lhx + 1 then px(x, y, F.mix(L.chalk.shade, "#d4e2e8", .2)) end end)
hline(lhx - 2, lhx + 1, lhy - 14, L.glow.base) hline(lhx - 3, lhx + 2, lhy - 15, L.tar.base) px(lhx - 1, lhy - 16, L.tar.base) px(lhx, lhy - 16, L.tar.base)
F.boat(186, 99, 10, { far = true, sail = L.awnB })
F.boat(292, 103, 12, { far = true })
F.gull(170, 88, 1) F.gull(352, 84, 1)

---------------------------------------------------------------- far right: salt pans with white heaps, a kelp rack
F.depth(1)
local field = poly{ { 268, 114 }, { 470, 114 }, { 470, 146 }, { 284, 146 } }
local rows = { 114, 118, 123, 129, 136, 146 }
field:each(function(x, y)
  local ri = 1
  for i = 1, #rows - 1 do if y >= rows[i] then ri = i end end
  local d = y - F.HZ + 6
  local u = (x - F.VX) / d * 9
  local h
  local onBank = y == rows[ri] or y == rows[ri] + 1 and ri > 2 or math.abs(u - floor(u + .5)) < .5 / d * 9 * .35
  if onBank then h = (y == rows[ri]) and L.wetSand.deep or L.wetSand.shade
  else
    local pan = hash(floor(u + .5), ri, 7)
    if pan < .35 then h = hash(x, y, 8) < .7 and L.awnB.hi or L.chalk.base               -- salt crust
    elseif pan < .7 then h = (y - rows[ri] < 2) and L.sky[3] or L.sky[4]                -- brine mirroring the sky
    else h = (y - rows[ri] < 2) and L.wetSand.shade or L.wetSand.base end               -- drained pan
    if hash(x, y, 9) < .05 then h = L.foam end
  end
  px(x, y, h)
end)
hline(284, 470, 146, L.wetSand.deep)
local function saltHeap(x, yb, h)
  local m = poly{ { x - h, yb }, { x - 1, yb - h }, { x, yb - h }, { x + h, yb } }
  rimOf(m, L.chalk) fill(m, L.chalk.base)
  m:each(function(xx, yy) if xx > x then px(xx, yy, L.chalk.shade) elseif xx < x - 1 and yy < yb - 1 then px(xx, yy, L.awnB.hi) end end)
end
for _, s in ipairs({ { 290, 124, 3 }, { 300, 122, 3 }, { 344, 131, 4 }, { 356, 132, 4 }, { 430, 128, 4 }, { 296, 142, 5 }, { 458, 140, 5 } }) do saltHeap(s[1], s[2], s[3]) end
F.gnome(320, 140, { small = true, hat = L.awnA, coat = L.wall2, arm = "up" })
line({ { 326, 126 }, { 330, 141 } }):each(function(x, y) px(x, y, L.timber.base) end) hline(327, 333, 141, L.timber.deep) -- salt rake
-- a kelp drying rack: poles with brown ribbons hanging
local rk = union(rect(400, 118, 400, 136), rect(452, 118, 452, 136), rect(400, 119, 452, 119))
rimOf(rk, L.timber) part(rk, L.timber, { nopop = true, noshade = true })
for x = 402, 450, 2 do
  local len = 6 + floor(hash(x, 1, 11) * 9)
  for y = 120, 120 + len do px(x + (y > 126 and 1 or 0), y, y == 120 + len and L.kelp.deep or (x % 4 == 0 and L.kelp.base or L.kelp.shade)) end
end

---------------------------------------------------------------- road's end: the tower windmill on a dune top
F.depth(2)
local mound = c:ellipse(240, 130, 40, 11):clip(rect(196, 112, 284, 128))
mound:each(function(x, y)
  local lt_ = (x - 240) / 40 + (y - 130) / 11 * .7
  local h = lt_ < -.5 and L.marram.hi or (lt_ < .25 and L.marram.base or L.marram.shade)
  if F.hash(x // 4, y // 2, 12) < .25 then h = L.sand.hi end
  px(x, y, h)
end)
for i = 1, 26 do F.marram(204 + floor(hash(i, 1, 13) * 72), 120 + floor(hash(i, 2, 13) * 8), 3 + floor(hash(i, 3, 13) * 3)) end
local function windmill()
  local hx, hy = 240, 66
  local tower = poly{ { 225, 126 }, { 255, 126 }, { 250, 74 }, { 230, 74 } }
  local cap = poly{ { 227, 76 }, { 253, 76 }, { 252, 69 }, { 246, 61 }, { 234, 61 }, { 228, 69 } }
  local fan = c:ellipse(258, 64, 4, 4)
  local fanArm = line({ { 250, 70 }, { 258, 64 } }, 1)
  F.shadow(226, 254, 126, 8, 3)
  rimOf(union(tower, cap, fanArm), L.tar)
  part(tower, L.plaster)
  tower:each(function(x, y)
    if y % 6 == 0 and hash(x // 3, y, 14) < .6 then px(x, y, L.plaster.shade) end
    if x > 247 - (y - 74) * .1 + (126 - y) * .0 and hash(x, y, 15) < .5 then px(x, y, L.plaster.shade) end
    if y > 120 and hash(x, y // 2, 16) < .35 then px(x, y, L.sand.shade) end -- sand splash at the foot
  end)
  F.door(236, 112, 244, 125, L.wall2, true)
  F.window(237, 90, 242, 95, L.wall2)
  F.window(238, 79, 241, 83, L.wall2)
  -- the stage (gallery) around the tower
  local gal = rect(220, 101, 260, 103)
  rimOf(gal, L.tar) part(gal, L.timber, { nopop = true, noshade = true }) hline(220, 260, 101, L.timber.hi)
  for x = 222, 258, 4 do vline(x, 104, 107, L.timber.base) end
  -- tarred boat cap with a finial
  part(cap, L.tar, { sep = true })
  cap:each(function(x, y) if (x + y) % 4 == 0 and y < 74 then px(x, y, L.tar.base) end end)
  line({ { 229, 69 }, { 235, 62 } }):each(function(x, y) px(x, y, L.tar.hi) end)
  vline(240, 55, 60, L.tar.edge) px(240, 54, L.gold.base) px(239, 55, L.gold.hi)
  -- fantail: little vanes behind the cap
  part(fanArm, L.timber, { nopop = true, noshade = true })
  fill(fan, L.sky[3])
  for k = 0, 5 do
    local a = k * pi / 3 + .3
    line({ { 258, 64 }, { 258 + cos(a) * 4, 64 + sin(a) * 4 } }):each(function(x, y) px(x, y, k % 2 == 0 and L.awnB.hi or L.awnB.shade) end)
  end
  px(258, 64, L.tar.deep)
  -- sails: four lattice arms with white canvas, the lower-right ones in shade
  local sails, frame = HP.mask(), HP.mask()
  local sk = {}
  for k = 0, 3 do
    local a = k * pi / 2 + .38
    local dx, dy, nx, ny = cos(a), sin(a), -sin(a), cos(a)
    local function P(t, s) return { hx + dx * t + nx * s, hy + dy * t + ny * s } end
    local q = poly{ P(7, 0), P(42, 0), P(42, 8), P(7, 8) }
    sails:add(q) sk[k] = q
    frame:add(line({ P(0, 0), P(44, 0) }, 2))
    for t = 12, 42, 5 do frame:add(line({ P(t, 0), P(t, 8) })) end
    frame:add(line({ P(7, 8), P(42, 8) }))
  end
  local all = union(sails, frame)
  rimOf(all, L.tar)
  for k = 0, 3 do
    local q = sk[k]
    local lit = (k == 2 or k == 3)
    fill(q, lit and L.awnB.hi or L.awnB.base)
    q:each(function(x, y)
      local v = hash(x // 2, y // 2, 8 + k)
      if v < .16 then px(x, y, lit and L.awnB.base or L.awnB.shade) elseif v > .92 then px(x, y, L.awnB.hi) end
    end)
  end
  part(frame, L.timber, { nopop = true, noshade = true })
  frame:each(function(x, y) if hash(x, y, 17) < .2 then px(x, y, L.timber.shade) end end)
  local hub = c:ellipse(hx, hy, 3, 3) rimOf(hub, L.tar) part(hub, L.iron)
end
windmill()

---------------------------------------------------------------- back-left: fisherman's cottage, upturned boat, nets on poles
F.depth(1)
F.tree(10, 134, 30, 0)
local ctop, ccx, cwall, croof = F.building{ x0 = 20, x1 = 66, yb = 138, wh = 26, rh = 20, wall = L.plaster, roof = L.roof, chimney = true, shingle = true, noFrame = true, noAttic = true }
F.lichen(croof, .05, 21)
F.window(26, 120, 31, 125, L.wall2) F.window(56, 120, 61, 125, L.wall2)
F.door(42, 124, 50, 137, L.wall2)
F.smoke(56, 92, 6, 1.2, 2)
-- upturned boat on trestles
local ub = c:ellipse(84, 138, 14, 6):clip(rect(70, 130, 98, 138))
rimOf(ub, L.tar) part(ub, L.tar)
ub:each(function(x, y) if y == 134 or y == 136 then px(x, y, L.tar.deep) end if y <= 133 and x < 84 then px(x, y, L.tar.hi) end end)
hline(70, 98, 138, L.wall2.base)
vline(74, 139, 141, L.timber.deep) vline(94, 139, 141, L.timber.deep)
-- nets drying on two poles
local poles = union(rect(102, 116, 103, 142), rect(132, 114, 133, 142))
rimOf(poles, L.timber) part(poles, L.timber, { nopop = true, noshade = true })
F.netSwag(104, 131, 118, 14, { floatStep = 6 })
F.fenceP(70, 146, 196, 134, 9)

---------------------------------------------------------------- right: the tarred salt store with a hoist lifting a salt sack
F.depth(2)
F.tree(300, 152, 40, 1)
F.tree(452, 142, 44, 2)
local top, cx, swall, sroof = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 28, wall = L.tar, roof = L.roof2, noAttic = true, shingle = true, noFrame = true }
F.planks(swall, L.tar, 5, true, 9)
F.pantile(sroof, L.roof2, top - 28, 22)
F.lichen(sroof, .04, 23)
swall:each(function(x, y) if y > 163 and hash(x, y // 2, 12) < .4 then px(x, y, L.sand.shade) end end) -- blown sand at the foot
local posts = union(rect(330, top, 332, 170), rect(418, top, 420, 170), rect(330, 168, 420, 170))
part(posts, L.timber, { nopop = true, noshade = true })
-- loft door + hoist beam
local loft = rect(368, 98, 382, 112)
fill(loft, L.tar.edge) fill(rect(369, 99, 381, 112), L.soil.deep)
F.sack(375, 112, L.awnB, 4)
local beamH = rect(372, 92, 398, 95)
rimOf(beamH, L.tar) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 92, L.timber.hi)
vline(394, 96, 128, L.cork.deep) -- rope
-- the hoisted salt sack
F.sack(394, 142, L.awnB, 7)
px(394, 129, L.iron.base) px(393, 130, L.iron.shade)
F.door(352, 140, 366, 169, L.wall2)
F.window(396, 150, 404, 157, L.wall2)
F.window(340, 128, 346, 134, L.wall2)
-- a painted name board under the eaves (no lettering: a row of white fish)
local nb = rect(344, 117, 404, 122) rimOf(nb, L.tar) fill(nb, L.wall2.base) hline(344, 404, 117, L.wall2.hi)
for x = 348, 400, 8 do hline(x, x + 3, 119, L.awnB.hi) px(x + 4, 118, L.awnB.base) px(x + 4, 120, L.awnB.base) px(x, 120, L.awnB.shade) end
-- loading dock with salt sacks, fish barrels and a stack of fish boxes
local dock = rect(300, 158, 340, 172)
rimOf(dock, L.tar) part(dock, L.board)
F.planks(dock, L.board, 6, true, 11)
F.sack(306, 157, L.awnB, 5) F.sack(318, 157, L.awnB, 5) F.sack(312, 147, L.awnB, 5)
F.barrel(332, 157, L.timber, 11)
F.crate(322, 145, 12, 7, L.gull)
F.depth(3)
local _, ghx, ghy = F.gnome(354, 182, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 143, ghy, L.cork.deep) -- hauling the hoist rope
line({ { ghx, 143 }, { 394, 128 } }):each(function(x, y) px(x, y, L.cork.deep) end)

---------------------------------------------------------------- kelp rack + two gnomes carrying a salt handbarrow
local kr = union(rect(380, 166, 381, 196), rect(412, 166, 413, 196), rect(378, 168, 415, 169), rect(378, 178, 415, 179))
rimOf(kr, L.timber) part(kr, L.timber, { nopop = true, noshade = true }) hline(378, 415, 168, L.timber.hi)
for x = 383, 410, 3 do
  for _, y0 in ipairs({ 170, 180 }) do
    local len = 5 + floor(hash(x, y0, 18) * 7)
    for y = y0, y0 + len do px(x + floor(sin(y * .7 + x) * .8), y, y == y0 + len and L.kelp.deep or (x % 2 == 0 and L.kelp.hi or L.kelp.base)) end
  end
end
F.shadow(372, 414, 206, 6, 3)
local _, lhx2, lhy2 = F.gnome(370, 206, { hat = L.awnA, coat = L.wall2, arm = "out" })
local _, rhx2, rhy2 = F.gnome(420, 208, { hat = L.roof2, coat = L.accent, arm = "out", flip = true })
-- the handbarrow: two poles between their hands, a slatted tray heaped with salt
local polesM = line({ { lhx2 - 2, lhy2 }, { rhx2 + 2, rhy2 } }, 1)
rimOf(polesM, L.timber) part(polesM, L.timber, { nopop = true, noshade = true })
local tray = rect(lhx2 + 3, lhy2 - 3, rhx2 - 3, lhy2)
rimOf(tray, L.timber) part(tray, L.board, { nopop = true })
local heap = poly{ { lhx2 + 4, lhy2 - 4 }, { (lhx2 + rhx2) // 2 - 3, lhy2 - 13 }, { (lhx2 + rhx2) // 2 + 2, lhy2 - 13 }, { rhx2 - 4, lhy2 - 4 } }
rimOf(heap, L.chalk) fill(heap, L.chalk.base)
heap:each(function(x, y) if x < (lhx2 + rhx2) // 2 - 3 and y < lhy2 - 5 then px(x, y, L.awnB.hi) elseif x > (lhx2 + rhx2) // 2 + 2 then px(x, y, L.chalk.shade) end end)
for k = 0, 2 do F.shell(428 + k * 4, 214 + k, k == 1) end
F.thrift(432, 220, true)

---------------------------------------------------------------- left hero: white weatherboard tide mill on a granite footing
F.depth(2)
F.tree(78, 162, 34, 1)
F.depth(3)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 30, wall = L.plaster, roof = L.roof, chimney = true, shingle = true, noFrame = true }
local boards = wallM:copy():clip(rect(92, mtop + 2, 172, 175))
F.planks(boards, L.plaster, 4, false, 17)
local foot = rect(92, 176, 172, 186)
part(foot, L.stone, { nopop = true }) F.courses(foot, 176, 5, 9, L.stone)
F.barnacles(foot, .12, 24, 181)
foot:each(function(x, y) if y >= 183 and hash(x // 2, y, 25) < .55 then px(x, y, hash(x, y, 26) < .5 and L.kelp.base or L.kelp.shade) end end) -- weed at the tide line
hline(92, 172, 175, L.tar.edge)
local corners = union(rect(92, mtop, 94, 175), rect(170, mtop, 172, 175), rect(92, mtop, 172, mtop + 1))
part(corners, L.tar, { nopop = true, noshade = true })
F.lichen(roofM, .06, 27)
F.door(108, 158, 120, 185, L.wall2)
F.window(134, 148, 142, 156, L.wall2)
F.window(150, 148, 158, 156, L.wall2)
F.window(100, 144, 104, 150, L.wall2)
-- a round sign over the door: a fish
local plaque = c:ellipse(114, 150, 5, 4) rimOf(plaque, L.tar) part(plaque, L.wall2)
F.sprite({ "f..ff.", "fffffe", "f..ff." }, 111, 149, { f = L.awnB.hi, e = L.tar.edge }, { rim = false })
-- window boxes with sea thrift
for _, wx in ipairs({ 138, 154 }) do
  hline(wx - 5, wx + 5, 159, L.wall2.base) hline(wx - 5, wx + 5, 160, L.wall2.deep)
  for k = -4, 4, 2 do px(wx + k, 158, L.leaf.shade) px(wx + k + 1, 157, L.petal.base) px(wx + k, 156, L.petal.hi) end
end

-- granite wheel pit with a timber sluice: the tide pond's water rushes out under the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.courses(pit, 176, 6, 10, L.stone)
F.barnacles(pit, .1, 28, 186)
pit:each(function(x, y) if y >= 192 and hash(x // 2, y, 29) < .5 then px(x, y, L.kelp.base) end end)
local sl = union(rect(208, 140, 211, 200), rect(224, 136, 227, 196), rect(206, 140, 229, 143))
local gateP = rect(212, 152, 223, 170)
local rack = rect(217, 128, 218, 151)
rimOf(union(sl, gateP, rack), L.tar)
part(sl, L.timber, { nopop = true, noshade = true }) hline(206, 229, 140, L.timber.hi)
part(gateP, L.board) F.planks(gateP, L.board, 3, true, 19)
part(rack, L.iron, { nopop = true, noshade = true }) for y = 129, 150, 2 do px(219, y, L.iron.shade) end
local wheelSpot = c:ellipse(222, 134, 2, 2) fill(wheelSpot, L.iron.base) px(221, 133, L.iron.hi)
-- water spilling from under the raised gate
local spill = poly{ { 212, 171 }, { 224, 171 }, { 226, 190 }, { 218, 200 }, { 206, 200 }, { 210, 186 } }
spill:each(function(x, y) px(x, y, hash(x, y, 4) < .35 and L.water.hi or (hash(x, y // 2, 5) < .5 and L.water.base or L.foam)) end)
F.barnacles(sl, .08, 30, 180)

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
rimOf(wheel, L.tar)
part(spokes, L.timber, { nopop = true, noshade = true })
part(ringI, L.timber, { nopop = true })
part(pads, L.board, { nopop = true, noshade = true })
part(ringO, L.timber, { nopop = true })
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .8 and ((x - hx) ^ 2 + (y - hy) ^ 2) > (R - 2) ^ 2 then px(x, y, L.timber.hi) end end)
-- wrack and barnacles on the lower rim
ringO:each(function(x, y) if y > hy + R * .5 and hash(x, y, 74) < .45 then px(x, y, hash(x, y, 75) < .5 and L.kelp.base or L.kelp.shade) end end)
F.barnacles(ringO, .1, 31, hy + 4)
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- the undershot race: water churning under the wheel's bottom paddles, spray thrown up
local race = poly{ { 168, 190 }, { 214, 190 }, { 218, 200 }, { 166, 200 } }
race:cut(spokes):cut(ringI):cut(pads)
race:each(function(x, y) px(x, y, hash(x, y, 6) < .3 and L.foam or (hash(x // 2, y, 7) < .5 and L.water.hi or L.water.base)) end)
for i = 0, 14 do local x, y = 168 + floor(hash(i, 1, 9) * 50), 184 + floor(hash(i, 2, 9) * 16) px(x, y, L.foam) px(x + 1, y, L.water.hi) end
-- quirk: a puffin in a red gnome hat riding the top paddle, sand eels dangling from its bill
F.sprite({
  "......R.........",
  ".....RRr........",
  "....RRRRr.......",
  "...RRRRRRr......",
  "..hhhhhhhhh.....",
  "..KKWWWWWKK.....",
  ".KKWWWWeWWWOO...",
  ".KWWWWWWWWOOYo..",
  ".KKWWWWWWWOoooS.",
  "KKKKWWWWWKKSsSs.",
  "KKKKWWWWWWK.S.s.",
  "KKKKWWWWWWK.....",
  ".KKKWWWWWWK.....",
  "..KKKWWWWK......",
  "...ff...ff......",
}, 178, 126, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, K = L.tar.deep, W = L.gull.hi, e = L.tar.edge,
  O = L.produce.base, o = L.awnA.base, Y = L.gold.hi, S = L.iron.hi, s = L.iron.shade, f = L.produce.base }, { rimCol = L.tar.edge })
px(185, 131, L.gull.shade) px(184, 132, L.gull.shade) -- face grey under the eye

---------------------------------------------------------------- tide race and tide pool (bottom-left)
local stream = poly{ { 166, 200 }, { 218, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.water)
local bank = water:grow(3):cut(water)
bank:each(function(x, y) if y > 199 then local v = hash(x // 2, y // 2, 51) px(x, y, v < .3 and L.stone.base or (v < .5 and L.stone.hi or (v < .7 and L.kelp.base or (v < .85 and L.kelp.shade or L.stone.shade)))) end end)
F.water(water, L.water)
-- submerged rocks with anemones and a starfish
for _, r in ipairs({ { 54, 244, 9, 4 }, { 124, 252, 8, 3 }, { 150, 238, 6, 3 } }) do
  local m = c:ellipse(r[1], r[2], r[3], r[4]):clip(water)
  fill(m, L.water.shade) m:each(function(x, y) if y < r[2] - r[4] + 2 then px(x, y, L.water.base) end end)
end
for _, a in ipairs({ { 50, 242 }, { 58, 243 }, { 122, 251 }, { 152, 237 } }) do px(a[1], a[2], L.apple.base) px(a[1], a[2] - 1, L.apple.hi) px(a[1] + 1, a[2], L.apple.deep) end
F.sprite({ "..o..", "ooOoo", ".oOo.", "o...o" }, 120, 245, { o = L.produce.base, O = L.produce.hi }, { rimCol = L.produce.edge })
-- dark reflections of the mill along the far edge
for y = 206, 214, 3 do hline(176, 196, y, L.water.shade) end
-- an eider family: the drake (cream back, dark flanks, green nape), the brown duck and three ducklings
local function swim(x, y, kind)
  if kind == "drake" or kind == "duck" then
    local m = c:ellipse(x, y, 5, 3):add(c:ellipse(x + 5, y - 4, 2, 2))
    rimOf(m, L.tar)
    part(m, kind == "drake" and L.awnB or L.needle, { nopop = true })
    if kind == "drake" then
      m:each(function(xx, yy) if yy >= y and yy <= y + 3 and xx <= x + 3 then px(xx, yy, L.tar.deep) end end)
      hline(x - 2, x + 2, y - 2, L.awnB.hi) px(x + 4, y - 3, L.petal.hi)
      px(x + 6, y - 4, L.foliage2.hi) px(x + 5, y - 3, L.foliage2.hi) px(x + 4, y - 6, L.tar.deep) px(x + 5, y - 6, L.tar.deep)
    else
      for k = -3, 3, 2 do px(x + k, y - 1, L.needle.shade) px(x + k + 1, y + 1, L.needle.deep) end
    end
    fill(rect(x + 7, y - 4, x + 8, y - 3), L.wetSand.shade) px(x + 6, y - 5, L.tar.edge) hline(x - 6, x + 6, y + 3, L.water.hi)
  else
    local m = c:ellipse(x, y, 2, 1):add(rect(x + 1, y - 2, x + 2, y - 1))
    rimOf(m, L.tar) part(m, L.soil, { nopop = true })
    px(x + 3, y - 2, L.soil.shade) hline(x - 3, x + 3, y + 2, L.water.hi)
  end
end
swim(110, 238, "drake") swim(96, 236, "duck") swim(84, 240) swim(74, 243) swim(64, 241)
-- floating wrack and a bladder-wrack fringe on the near bank
for x = 30, 150, 4 do F.wrack(x, 262 + floor(sin(x / 9) * 2), 3, x) end
-- barnacled boulders on the bank
F.barnacles(F.rock(166, 252, 9, 8), .14, 76, 0)
F.barnacles(F.rock(16, 232, 7, 6), .14, 77, 0)
F.thrift(176, 256, true) F.thrift(24, 224, false)
-- driftwood plank footbridge over the race
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.tar) part(br, L.timber)
F.planks(br, L.timber, 5, true, 13)

---------------------------------------------------------------- left: millstones, flour sacks, lobster pots, a shrimping gnome
F.depth(3)
F.shadow(30, 96, 202, 8, 4)
local function millstone(x, y, r)
  local m = c:ellipse(x, y, r, r)
  rimOf(m, L.stone) part(m, L.stone)
  -- dressing: furrows radiating from the eye
  for k = 0, 9 do
    local a = k * pi / 5
    line({ { x + cos(a) * 3, y + sin(a) * 3 }, { x + cos(a) * (r - 2), y + sin(a) * (r - 2) } }):each(function(xx, yy) px(xx, yy, L.stone.shade) end)
  end
  m:each(function(xx, yy) if (xx - x) + (yy - y) < -r * .9 then px(xx, yy, L.stone.hi) end end)
  local eye = c:ellipse(x, y, 2, 2) fill(eye, L.stone.deep) px(x + 1, y + 1, L.tar.deep)
  return m
end
millstone(76, 186, 13)
millstone(52, 190, 11)
F.sack(34, 202, L.awnB, 6) F.sack(48, 205, L.awnB, 6) F.sack(40, 194, L.awnB, 5)
F.lobsterPot(80, 208, 8)
F.lobsterPot(26, 216, 7)
-- a coil of rope
local coil = c:ellipse(98, 212, 5, 2)
rimOf(coil, L.cork) fill(coil, L.cork.base) hline(95, 101, 212, L.cork.shade) fill(c:ellipse(98, 212, 2, 1), L.cork.deep) px(95, 211, L.cork.hi)
-- the shrimping gnome with a push-net over his shoulder, and a creel of silver fish
local _, wx, wy = F.gnome(116, 210, { hat = L.awnA, coat = L.wall2, arm = "out", flip = true })
local pole = line({ { wx + 2, wy - 2 }, { wx - 18, wy + 18 } }, 1)
rimOf(pole, L.tar) part(pole, L.timber, { nopop = true, noshade = true })
-- the D-shaped push-net frame dipping into the pool, mesh showing above the water
local hoop = c:ellipse(wx - 22, wy + 20, 6, 3)
local hoopIn = c:ellipse(wx - 22, wy + 20, 5, 2)
local hr = hoop:copy():cut(hoopIn)
fill(hr, L.timber.base) hr:each(function(x, y) if y > wy + 20 then px(x, y, L.timber.deep) end end)
hoopIn:each(function(x, y) if y <= wy + 20 and (x + y) % 2 == 0 then px(x, y, L.cork.shade) end end)
hline(wx - 29, wx - 15, wy + 24, L.water.hi)
local creel = rect(126, 203, 136, 210)
rimOf(creel, L.cork) part(creel, L.cork, { nopop = true })
creel:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.cork.deep) end end)
for x = 127, 135, 2 do px(x, 202, L.iron.hi) px(x + 1, 202, L.iron.base) px(x, 201, L.iron.shade) end
for _, f in ipairs({ { 24, 196, 6 }, { 86, 222, 5 }, { 18, 205, 7 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(64, 212, true) F.thrift(102, 224, false)

---------------------------------------------------------------- right foreground: a handcart of sacks, marram, buckthorn, the sign
F.depth(3)
local function cart(x0, yb)
  local bed = poly{ { x0, yb - 14 }, { x0 + 40, yb - 14 }, { x0 + 38, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0 + 40, yb - 10 }, { x0 + 58, yb - 4 } }, 2)
  rimOf(union(bed, shaft), L.tar)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.wall2) hline(x0 + 1, x0 + 39, yb - 10, L.wall2.deep) hline(x0 + 1, x0 + 39, yb - 13, L.wall2.hi)
  F.sack(x0 + 8, yb - 14, L.awnB, 6) F.sack(x0 + 22, yb - 14, L.awnB, 6) F.sack(x0 + 15, yb - 24, L.awnB, 5)
  F.crate(x0 + 29, yb - 14, 10, 6, L.gull)
  for _, wx in ipairs({ x0 + 8, x0 + 32 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.tar) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep)
    px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(302, 352, 226, 8, 3)
cart(300, 226)
for _, f in ipairs({ { 312, 258, 8 }, { 324, 262, 9 }, { 338, 256, 7 }, { 446, 220, 7 }, { 456, 224, 8 }, { 300, 250, 6 } }) do F.marram(f[1], f[2], f[3]) end
-- (keep clear of the compass corner x>=380, y>=230: the frame repaints it)
F.tree(348, 262, 26, 1)
local gorse = F.bush(424, 228, 10, 10, L.foliage2, 42)
gorse:each(function(x, y) if hash(x, y, 43) < .14 then px(x, y, hash(x, y, 44) < .5 and L.gorse.base or L.gorse.hi) end end)
F.thrift(352, 266, true) F.thrift(374, 262, false)
F.shell(330, 246, true) F.shell(336, 249, false) F.shell(326, 250, true)
F.sign(436, 168, 28, 14, L.wall2)
F.sprite({ "..t..", "t.t.t", ".ttt.", "t.t.t", ".TTT." }, 434, 170, { t = L.awnB.hi, T = L.tar.base }, { rim = false }) -- a little windmill
-- lobster pots stacked against the sign post
F.lobsterPot(452, 200, 6) F.lobsterPot(466, 200, 6) F.lobsterPot(459, 190, 6)

-- by the road, right: a driftwood bollard with a herring gull on it, a rope round its neck
local bol = rect(283, 204, 293, 218)
local bolTop = c:ellipse(288, 204, 5, 2)
rimOf(union(bol, bolTop), L.tar) part(bol, L.timber, { nopop = true })
F.planks(bol, L.timber, 3, true, 32)
fill(bolTop, L.timber.hi) px(288, 204, L.timber.shade)
hline(283, 293, 210, L.cork.deep) hline(283, 293, 211, L.cork.base)
F.sprite({
  "....WWW.......",
  "...WWWWW......",
  "..YWeWWW......",
  ".rYYWWWWW.....",
  "....WWWWWW....",
  "....WWWWWWW...",
  "...WWGGGGGGG..",
  "...WWGGGGGGGG.",
  "....WWGGGGwKK.",
  ".....WWWGKwKKK",
  "......WWW..KK.",
  ".......p.p....",
}, 282, 191, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, w = L.gull.hi, Y = L.gold.base, r = L.apple.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
px(286, 196, L.gull.base) px(285, 197, L.gull.base) -- breast shading

---------------------------------------------------------------- gnome on the road with a flour sack on his shoulder
local _, phx, phy = F.gnome(258, 240, { hat = L.roof2, coat = L.accent, arm = "out" })
F.sack(phx + 3, phy + 9, L.awnB, 5)
-- flour trail ... to a crab with a floury claw
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.awnB.hi) px(253 - i * 4, 243 + i * 3, L.awnB.base) end
F.sprite({
  "WW.......cc",
  "Wc.e...e.cC",
  ".C.C...C.C.",
  "..CCCCCCC..",
  ".CcCCCCCCC.",
  "C.c.c.c.c.C",
}, 216, 258, { C = L.roof2.base, c = L.roof2.shade, W = L.awnB.hi, e = L.tar.edge }, { rimCol = L.roof2.edge })
F.depth(0)
F.gull(300, 40, 3) F.gull(318, 50, 2) F.gull(160, 30, 2) F.gull(144, 62, 2) F.gull(420, 98, 1)
F.birds({ { 292, 49, 1 }, { 186, 74, 1 } })

F.finish()
