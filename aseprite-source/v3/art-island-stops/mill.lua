-- mill.lua : "Old mill" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold mill (art-2701-batch3/stops/opus3/mill.lua), re-cast for a coral island:
-- road's end: a coral-stone sugar windmill with a palm-thatch cap, woven pandanus-mat sails and a tail pole,
-- between two coconut palms. Back left: a bamboo boiling house with a coral chimney and smoke. Far right: a
-- sugar-cane patch with cut bundles. Right: the whitewashed cane store with a hoist lifting a net of coconuts,
-- a drying fishing net on its wall, a bamboo dock of sugar sacks and molasses barrels. Left hero: the plastered
-- tide mill on a black lava footing, an overshot wheel fed by a bamboo flume. Bottom left: a turquoise reef
-- channel / tide pool with an outrigger canoe, a sea turtle, reef fish, mangrove roots and floating hibiscus.
-- A coconut pyramid and a husking gnome, a three-roller cane press swept by two gnomes, a cane cart,
-- parrots, crabs, shells. Quirk: a red crab in a red gnome hat riding the top paddle, waving a hibiscus.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "mill", out = DIR, farTrees = { 24, 52, 150, 330, 352, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi

---------------------------------------------------------------- far right: a sugar-cane patch with cut bundles
F.depth(1)
local field = poly{ { 268, 114 }, { 470, 114 }, { 470, 146 }, { 284, 146 } }
field:each(function(x, y)
  local h = L.mossGround.base
  if hash(x // 6, y // 2, 4) < .3 then h = L.mossGround.hi elseif hash(x // 5, y // 2, 5) < .2 then h = L.soil.hi end
  if hash(x, y, 3) < .04 then h = L.mossGround.shade end
  px(x, y, h)
end)
-- cane rows: tall stalks with node rings and arching leaf tops, rows step forward and grow taller
for row = 0, 4 do
  local yb = 120 + row * 6
  local hgt = 8 + row * 2
  for x = 290 + row * 3, 466, 3 do
    if hash(x, row, 7) < .8 then
      local hh = hgt + floor(hash(x, row, 8) * 4)
      vline(x, yb - hh, yb, (x + row) % 2 == 0 and L.board.base or L.board.shade)
      for y = yb - hh + 3, yb, 3 do px(x, y, L.board.deep) end
      px(x - 1, yb - hh, L.leaf.hi) px(x + 1, yb - hh, L.leaf.base) px(x - 2, yb - hh + 1, L.leaf.base) px(x + 2, yb - hh + 1, L.leaf.shade)
      px(x, yb - hh - 1, L.leaf.hi) px(x + 2, yb - hh + 2, L.leaf.deep)
    end
  end
end
-- cut cane bundles and a field hut
local function caneBundle(x, yb)
  local m = poly{ { x - 6, yb }, { x + 6, yb }, { x + 2, yb - 9 }, { x - 2, yb - 9 } }
  rimOf(m, L.board) part(m, L.board, { nopop = true })
  m:each(function(xx, yy) if xx % 2 == 0 then px(xx, yy, L.board.shade) end end)
  hline(x - 3, x + 3, yb - 4, L.rope.deep)
  px(x - 1, yb - 10, L.leaf.hi) px(x + 1, yb - 11, L.leaf.base) px(x, yb - 10, L.leaf.shade)
end
caneBundle(300, 142) caneBundle(318, 144) caneBundle(452, 144)

---------------------------------------------------------------- road's end: the coral-stone sugar windmill between two palms
F.depth(2)
F.tree(206, 128, 62, 2)
F.tree(278, 128, 56, 0)
local function windmill()
  local tower = poly{ { 226, 126 }, { 254, 126 }, { 250, 80 }, { 230, 80 } }
  local cap = poly{ { 225, 82 }, { 232, 70 }, { 240, 64 }, { 248, 70 }, { 255, 82 } }
  local tail = line({ { 252, 80 }, { 272, 124 } }, 2)
  F.shadow(226, 254, 126, 8, 3)
  rimOf(union(tower, cap, tail), L.timber)
  part(tail, L.timber, { nopop = true, noshade = true })
  F.fill(c:ellipse(272, 123, 3, 3), L.timber.base) px(272, 123, L.timber.deep) px(271, 122, L.timber.hi) -- tail-pole wheel
  -- coral stone, rounded: lit left, shaded right, course lines and lava patches
  part(tower, L.stone)
  F.courses(tower, 80, 5, 7, L.stone)
  tower:each(function(x, y)
    local u = (x - 240) / 12
    if u < -.7 then px(x, y, L.stone.hi) elseif u > .55 and (y % 5) ~= 0 then px(x, y, L.stone.shade) end
    if hash(x // 3, y // 5, 61) < .06 and (y % 5) ~= 0 then px(x, y, L.lava.base) end
  end)
  -- the thatch cap with a woven ridge knot
  part(cap, L.roof, { sep = true })
  F.thatch(cap, L.roof, 64, 240)
  line({ { 226, 81 }, { 239, 65 } }):each(function(x, y) if cap:has(x, y) then px(x, y, L.roof.hi) end end)
  hline(225, 255, 82, L.roof.deep)
  fill(rect(239, 61, 241, 64), L.rope.base) px(239, 61, L.rope.hi) px(240, 59, L.rope.shade) px(240, 60, L.rope.base)
  -- a door with lamp light, a little arched window
  local d = rect(235, 108, 245, 125)
  fill(d, L.timber.edge)
  fill(rect(236, 109, 244, 125), L.glow.shade) fill(rect(236, 109, 240, 115), L.glow.base)
  hline(233, 247, 107, L.stone.hi) hline(233, 247, 106, L.stone.shade)
  F.window(238, 90, 242, 95, L.timber, true)
  -- the sails: four stocks with lattice frames carrying woven pandanus mats, lit on their upper-left faces
  local hx, hy = 240, 76
  local sails = HP.mask()
  local frame, mats = HP.mask(), HP.mask()
  for k = 0, 3 do
    local a = k * pi / 2 + .42
    local ca, sa = cos(a), sin(a)
    local nx, ny = -sa, ca
    local stock = line({ { hx, hy }, { hx + ca * 36, hy + sa * 36 } }, 2)
    frame:add(stock)
    for d = 9, 35, .5 do
      for w = 1, 7, .5 do
        local x, y = floor(hx + ca * d + nx * w + .5), floor(hy + sa * d + ny * w + .5)
        local onFrame = (floor(d) % 6 == 3) or w >= 6.5
        if onFrame then frame:set(x, y) else mats:set(x, y) end
      end
    end
  end
  mats:cut(frame)
  sails:add(frame):add(mats)
  rimOf(sails, L.timber)
  -- woven pandanus mats: a two-tone basket weave, sunlit on the upper-left sails
  mats:each(function(x, y)
    local lit = (x < hx and y < hy + 6) or (y < hy - 4)
    local wv = ((x // 2 + y // 2) % 2 == 0)
    local hcol = lit and (wv and L.rope.hi or L.rope.base) or (wv and L.needle.hi or L.needle.base)
    px(x, y, hcol)
  end)
  frame:each(function(x, y) px(x, y, (x < hx or y < hy) and L.timber.shade or L.timber.deep) end)
  local hub = c:ellipse(hx, hy, 3, 3)
  c:rim(hub, L.timber.edge) fill(hub, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
end
windmill()

---------------------------------------------------------------- back-left: bamboo boiling house with a coral chimney
F.depth(1)
F.tree(84, 128, 44, 0)
F.tree(10, 134, 40, 3)
local ctop, ccx, cwall = F.building{ x0 = 20, x1 = 66, yb = 138, wh = 30, rh = 22, wall = L.board, roof = L.roof, chimney = true, noFrame = true }
F.bamboo(cwall:copy():clip(rect(20, ctop + 4, 66, 138)), L.board, 3)
hline(20, 66, ctop + 4, L.timber.base) hline(20, 66, 137, L.timber.deep)
F.window(26, 116, 31, 121, L.timber) F.door(46, 124, 53, 137, L.timber)
F.smoke(57, 88, 6, .6, 2)
F.fenceP(70, 140, 196, 132, 9)

---------------------------------------------------------------- right: the whitewashed cane store, hoist lifting a net of coconuts
F.depth(2)
F.tree(300, 152, 58, 1)
F.tree(452, 142, 58, 4)
F.tree(436, 136, 40, 7)
local top, cx, swall, sroof = F.building{ x0 = 330, x1 = 420, yb = 170, wh = 46, rh = 28, wall = L.plaster, roof = L.roof, noAttic = true, noFrame = true }
-- coral-stone quoins on the corners, a damp sandy foot, limewash patches
local quoins = HP.mask()
for y = top + 2, 168, 4 do
  local w = ((y - top) // 4) % 2 == 0 and 5 or 3
  quoins:add(rect(330, y, 330 + w, y + 2)):add(rect(420 - w, y, 420, y + 2))
end
part(quoins, L.stone, { nopop = true })
swall:each(function(x, y) if y > 164 and hash(x, y // 2, 12) < .4 then px(x, y, L.ground.shade) end end)
-- loft door + hoist beam
local loft = rect(368, 98, 382, 112)
fill(loft, L.timber.deep) fill(rect(369, 99, 381, 112), L.soil.deep)
F.planks(rect(369, 99, 374, 112), L.wall2, 3, true, 3) fill(rect(369, 99, 374, 112), L.wall2.base) vline(374, 99, 112, L.wall2.deep) vline(369, 99, 112, L.wall2.hi) -- open shutter
local beamH = rect(372, 92, 398, 95)
rimOf(beamH, L.timber) part(beamH, L.timber, { nopop = true, noshade = true }) hline(372, 398, 92, L.timber.hi)
vline(394, 96, 126, L.rope.shade) -- rope
-- the hoisted net bag of coconuts
local bag = c:ellipse(394, 134, 9, 7)
c:rim(bag, L.rope.deep)
fill(bag, L.coconut.shade)
for _, n in ipairs({ { 389, 131, false }, { 395, 129, true }, { 399, 134, false }, { 391, 137, true }, { 396, 138, false }, { 387, 135, false } }) do
  fill(c:ellipse(n[1], n[2], 2, 2), n[3] and L.foliage.base or L.coconut.base)
  px(n[1] - 1, n[2] - 1, n[3] and L.foliage.hi or L.coconut.hi) px(n[1] + 1, n[2] + 1, n[3] and L.foliage.shade or L.coconut.deep)
end
F.net(bag, L.rope)
line({ { 394, 126 }, { 386, 129 } }):each(function(x, y) px(x, y, L.rope.base) end)
line({ { 394, 126 }, { 402, 129 } }):each(function(x, y) px(x, y, L.rope.base) end)
F.door(352, 140, 366, 169, L.timber)
-- windows with turquoise shutters
local function shuttered(x0, y0, x1, y1)
  F.window(x0, y0, x1, y1, L.timber)
  local w = (x1 - x0) // 2 + 1
  local sl, sr = rect(x0 - w - 2, y0 - 1, x0 - 2, y1 + 1), rect(x1 + 2, y0 - 1, x1 + w + 2, y1 + 1)
  rimOf(union(sl, sr), L.wall2) part(sl, L.wall2, { nopop = true }) part(sr, L.wall2, { nopop = true })
  union(sl, sr):each(function(x, y) if y % 2 == 0 then px(x, y, L.wall2.shade) end end)
end
shuttered(396, 148, 404, 156)
shuttered(400, 124, 405, 130)
-- a fishing net drying on the store wall, cork floats along its top
local netM = poly{ { 334, 124 }, { 350, 124 }, { 348, 162 }, { 336, 158 } }
F.net(netM, L.rope, { floats = true })
-- bamboo loading dock with sugar sacks and molasses barrels
local dock = rect(300, 158, 340, 172)
rimOf(dock, L.timber) part(dock, L.board)
F.bamboo(dock, L.board, 3, { horizontal = true })
F.sack(306, 157, L.awnB, 5) F.sack(318, 157, L.awnB, 5) F.sack(312, 147, L.awnB, 5)
F.barrel(330, 157, L.timber, 11)
F.sprite({ "SSS", "S.S", "SSS" }, 304, 151, { S = L.awnA.base }, { rim = false }) -- a red sugar mark on a sack
F.depth(3)
local _, ghx, ghy = F.gnome(354, 182, { hat = L.awnA, coat = L.accent, arm = "up", flip = true })
vline(ghx, 143, ghy, L.rope.shade) -- hauling the hoist rope
line({ { ghx, 143 }, { 394, 126 } }):each(function(x, y) px(x, y, L.rope.shade) end)
-- a lory on the hoist beam
F.parrot(378, 81, "lory", true)

---------------------------------------------------------------- the three-roller cane press, swept round by two gnomes
local function press(x0, x1, yb)
  -- crushed cane (bagasse) heap behind on the right
  local heap = poly{ { x1 - 2, yb }, { x1 + 16, yb }, { x1 + 10, yb - 7 }, { x1 + 2, yb - 8 } }
  rimOf(heap, L.needle) part(heap, L.needle)
  heap:each(function(x, y) if hash(x, y, 15) < .3 then px(x, y, L.needle.hi) end end)
  -- the frame: two posts and a cap beam, three upright rollers between them
  local postL, postR = rect(x0, yb - 15, x0 + 2, yb), rect(x1 - 2, yb - 15, x1, yb)
  local capB = rect(x0 - 2, yb - 17, x1 + 2, yb - 15)
  local rollers = HP.mask()
  local rw = (x1 - x0 - 4) // 3
  for k = 0, 2 do rollers:add(rect(x0 + 3 + k * rw, yb - 14, x0 + 2 + (k + 1) * rw, yb - 4)) end
  local trough = rect(x0 - 3, yb - 3, x1 + 3, yb)
  rimOf(union(postL, postR, capB, rollers, trough), L.timber)
  part(union(postL, postR), L.timber, { nopop = true }) part(capB, L.timber, { nopop = true, noshade = true }) hline(x0 - 2, x1 + 2, yb - 17, L.timber.hi)
  for k = 0, 2 do
    local rx0, rx1 = x0 + 3 + k * rw, x0 + 2 + (k + 1) * rw
    local r = rect(rx0, yb - 14, rx1, yb - 4)
    part(r, k == 1 and L.timber or L.iron, { nopop = true })
    local rr = k == 1 and L.timber or L.iron
    vline(rx0, yb - 14, yb - 4, rr.hi) vline(rx1, yb - 14, yb - 4, rr.deep)
    hline(rx0, rx1, yb - 12, L.iron.deep) hline(rx0, rx1, yb - 6, L.iron.deep)
  end
  -- the trough of cane juice and a copper pot catching the spout
  part(trough, L.timber, { nopop = true }) hline(x0 - 2, x1 + 2, yb - 2, L.glow.base) hline(x0, x1, yb - 3, L.glow.hi)
  local pot = c:rrect(x0 - 12, yb - 5, x0 - 4, yb + 1, 2)
  rimOf(pot, L.soil) part(pot, L.produce, { nopop = true }) hline(x0 - 11, x0 - 5, yb - 5, L.glow.base) px(x0 - 10, yb - 3, L.produce.hi)
  vline(x0 - 3, yb - 3, yb - 1, L.glow.shade)
  -- canes being fed in from the left
  for k = 0, 2 do
    local m = line({ { x0 - 14, yb - 12 + k * 2 }, { x0 + 4, yb - 14 + k * 3 } }, 1)
    m:each(function(x, y) px(x, y, (x % 3 == 0) and L.board.deep or L.board.base) end)
    px(x0 - 15, yb - 13 + k * 2, L.leaf.hi) px(x0 - 16, yb - 13 + k * 2, L.leaf.base)
  end
end
F.shadow(370, 414, 198, 6, 3)
press(380, 404, 198)
local _, lhx, lhy = F.gnome(368, 202, { hat = L.awnA, coat = L.hibiscus, arm = "up" })
local _, rhx, rhy = F.gnome(418, 204, { hat = L.roof2, coat = L.accent, arm = "up", flip = true })
-- the sweep beam across the cap on a spindle, pushed round from both ends
vline(392, 176, 181, L.iron.base) px(392, 175, L.iron.hi) px(393, 178, L.iron.deep)
local sweep = line({ { lhx - 2, lhy + 1 }, { rhx + 2, rhy + 1 } }, 2)
rimOf(sweep, L.timber) part(sweep, L.timber, { nopop = true, noshade = true })
line({ { lhx - 2, lhy + 1 }, { rhx + 2, rhy + 1 } }):each(function(x, y) px(x, y, L.timber.hi) end)
fill(rect(lhx - 1, lhy, lhx, lhy + 1), L.skin.base) fill(rect(rhx, rhy, rhx + 1, rhy + 1), L.skin.base) -- hands on the beam
F.shell(430, 212, "conch", true) F.shell(436, 214, "scallop") F.crab(428, 220, L.awnA)

F.depth(2)
F.tree(76, 162, 48, 3)
---------------------------------------------------------------- left hero: the plastered tide mill on a lava footing + overshot wheel
F.depth(3)
local mtop, mcx, wallM, roofM = F.building{ x0 = 92, x1 = 172, yb = 186, wh = 52, rh = 30, wall = L.pinkwash, roof = L.roof, chimney = true, noFrame = true }
-- black lava-block footing
local foot = rect(92, 175, 172, 186)
part(foot, L.lava, { nopop = true }) F.courses(foot, 175, 5, 9, L.lava)
foot:each(function(x, y) if hash(x, y, 70) < .1 then px(x, y, L.lava.deep) end end)
hline(92, 172, 174, L.pinkwash.deep)
-- coral-stone quoins and a driftwood lintel band
local mq = HP.mask()
for y = mtop + 2, 172, 4 do
  local w = ((y - mtop) // 4) % 2 == 0 and 5 or 3
  mq:add(rect(92, y, 92 + w, y + 2)):add(rect(172 - w, y, 172, y + 2))
end
part(mq, L.stone, { nopop = true })
local lint = rect(92, mtop + 18, 172, mtop + 19)
part(lint, L.timber, { nopop = true, noshade = true }) hline(92, 172, mtop + 18, L.timber.hi)
F.door(108, 158, 120, 185, L.timber, true)
local function mwin(x0, y0, x1, y1)
  F.window(x0, y0, x1, y1, L.timber)
  local w = (x1 - x0) // 2 + 1
  local sl, sr = rect(x0 - w - 2, y0 - 1, x0 - 2, y1 + 1), rect(x1 + 2, y0 - 1, x1 + w + 2, y1 + 1)
  rimOf(union(sl, sr), L.wall2) part(sl, L.wall2, { nopop = true }) part(sr, L.wall2, { nopop = true })
  union(sl, sr):each(function(x, y) if y % 2 == 0 then px(x, y, L.wall2.shade) end end)
end
mwin(136, 148, 142, 156)
mwin(154, 148, 160, 156)
F.window(100, 144, 104, 150, L.timber)
-- a round sign over the door: a coconut palm
local plaque = c:ellipse(114, 150, 5, 4) rimOf(plaque, L.timber) part(plaque, L.board)
F.sprite({ "g.g.g", ".ggg.", "..t..", "..t..", ".tt.." }, 112, 147, { g = L.foliage.shade, t = L.coconut.base }, { rim = false })
-- window boxes with hibiscus
for _, wx in ipairs({ 139, 157 }) do
  hline(wx - 6, wx + 6, 159, L.timber.base) hline(wx - 6, wx + 6, 160, L.timber.deep)
  for k = -5, 5, 2 do px(wx + k, 158, L.foliage2.base) px(wx + k + 1, 157, L.foliage2.hi) end
  px(wx - 3, 157, L.awnA.base) px(wx - 3, 156, L.awnA.hi) px(wx + 2, 157, L.hibiscus.base) px(wx + 2, 156, L.hibiscus.hi) px(wx + 5, 157, L.awnA.shade)
end

-- coral-stone wheel pit behind the wheel
local pit = rect(170, 176, 214, 200)
rimOf(pit, L.stone) part(pit, L.stone) F.courses(pit, 176, 6, 10, L.stone)
pit:each(function(x, y) if y > 192 and hash(x // 2, y, 72) < .35 then px(x, y, L.seagrass.shade) end end)
-- bamboo flume on driftwood trestles, bringing the tide-race water over the top of the wheel
local flume = poly{ { 186, 140 }, { 226, 130 }, { 226, 135 }, { 186, 145 } }
local legs = rect(218, 135, 220, 150):add(rect(206, 138, 208, 152))
rimOf(union(flume, legs), L.timber)
part(legs, L.timber, { nopop = true, noshade = true })
part(flume, L.board)
flume:each(function(x, y) local k = (y - 130 + (x - 186) // 4) px(x, y, (y - floor(140 - (x - 186) * .25)) % 2 == 0 and L.board.hi or L.board.base) if (x - 186) % 9 == 0 then px(x, y, L.board.deep) end end)
line({ { 187, 140 }, { 225, 130 } }):each(function(x, y) px(x, y, L.lagoon.base) end)
for _, lx in ipairs({ 207, 219 }) do hline(lx - 2, lx + 3, 140 + (219 - lx) // 4, L.rope.base) end -- lashings

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
pads:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.board.deep) end end) -- bamboo nodes on the paddles
part(ringO, L.timber, { nopop = true })
ringO:each(function(x, y) if (x - hx) + (y - hy) < -R * .8 and ((x - hx) ^ 2 + (y - hy) ^ 2) > (R - 2) ^ 2 then px(x, y, L.timber.hi) end end)
-- green weed and barnacles on the lower rim where the tide reaches
ringO:each(function(x, y)
  if y > hy + R * .55 then local v = hash(x, y, 74)
    if v < .4 then px(x, y, hash(x, y, 75) < .5 and L.seagrass.base or L.seagrass.shade) elseif v > .9 then px(x, y, L.shell.hi) end end
end)
local hubm = c:ellipse(hx, hy, 3, 3) fill(hubm, L.iron.base) px(hx - 1, hy - 1, L.iron.hi) px(hx + 1, hy + 1, L.iron.deep)
-- water pouring over the far side of the wheel + splash
local pour = poly{ { 184, 142 }, { 190, 142 }, { 214, 160 }, { 220, 182 }, { 216, 198 }, { 212, 182 }, { 208, 162 } }
pour:cut(spokes):cut(ringI)
pour:each(function(x, y) px(x, y, hash(x, y, 4) < .3 and L.lagoon.hi or L.lagoon.base) end)
for i = 0, 8 do local x, y = 200 + floor(hash(i, 1, 9) * 26), 192 + floor(hash(i, 2, 9) * 10) px(x, y, L.lagoon.hi) px(x + 1, y, L.surf) end
-- quirk: a red crab in a red gnome hat riding the top paddle, waving a hibiscus in one claw
F.sprite({
  "......R.......",
  ".....RRr......",
  "....RRRr......",
  "...RRRRRr.....",
  "..hhhhhhhh....",
  "F..e....e..c..",
  "FfCe....eCcc..",
  "fcC.CCCC.Cc...",
  ".cCCChCCCCC...",
  "..CChhCCCCCc..",
  ".CCCCCCCCCCC..",
  "l.lCCCCCCCl.l.",
  ".l.l.l..l.l.l.",
}, 184, 128, { R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep, C = L.hibiscus.shade, c = L.hibiscus.deep,
  e = L.timber.edge, l = L.hibiscus.deep, F = L.awnA.hi, f = L.gold.base })
for _, p in ipairs({ { 189, 136 }, { 192, 137 }, { 186, 137 } }) do px(p[1], p[2], L.hibiscus.base) end
px(188, 136, L.hibiscus.hi) px(187, 137, L.hibiscus.hi)

---------------------------------------------------------------- tide race and reef pool (bottom-left)
local stream = poly{ { 170, 200 }, { 214, 200 }, { 206, 214 }, { 176, 226 }, { 150, 230 }, { 138, 222 }, { 160, 212 } }
local pond = poly{ { 18, 232 }, { 40, 220 }, { 96, 216 }, { 150, 220 }, { 180, 230 }, { 176, 250 }, { 140, 262 }, { 80, 266 }, { 30, 262 }, { 16, 250 } }
local water = union(stream, pond)
rimOf(water, L.lagoon)
local bank = water:grow(2):cut(water)
bank:each(function(x, y) if y > 199 then local v = hash(x, y, 51) px(x, y, v < .3 and L.lava.base or (v < .55 and L.stone.hi or (v < .7 and L.lava.hi or L.ground.hi))) end end)
F.water(water, L.lagoon)
-- coral heads and sand patches under the clear water
for _, ch in ipairs({ { 50, 250, 6 }, { 130, 252, 5 }, { 74, 258, 4 }, { 160, 238, 4 } }) do
  local m = c:ellipse(ch[1], ch[2], ch[3], math.max(2, ch[3] // 2))
  m:each(function(x, y) if water:has(x, y) then px(x, y, hash(x, y, 53) < .5 and L.coral.shade or L.coral.base) end end)
  m:edge():each(function(x, y) if water:has(x, y) and y > ch[2] then px(x, y, L.lagoon.deep) end end)
  px(ch[1] - 1, ch[2] - 1, L.coral.hi)
end
-- dark reflections of the palms along the far edge, and the wheel
for _, rx in ipairs({ 40, 58, 120, 140 }) do for k = 0, 5 do hline(rx - 3 + k // 2, rx + 3 - k // 2, 222 + k * 2, L.lagoon.shade) end end
for y = 206, 214, 3 do hline(176, 196, y, L.lagoon.shade) end
-- reef fish: little stripes of colour under the surface
for _, f in ipairs({ { 110, 246, L.gold }, { 116, 249, L.gold }, { 66, 236, L.accent }, { 150, 244, L.hibiscus }, { 96, 260, L.accent } }) do
  px(f[1], f[2], f[3].base) px(f[1] + 1, f[2], f[3].hi) px(f[1] - 1, f[2], f[3].shade) px(f[1] - 2, f[2] - 1, f[3].shade) px(f[1] - 2, f[2] + 1, f[3].shade)
end
-- a green sea turtle paddling, with its ripple
local function turtle(x, y)
  local shellM = c:ellipse(x, y, 6, 4)
  local flips = poly{ { x - 4, y - 3 }, { x - 9, y - 6 }, { x - 6, y - 1 } }:add(poly{ { x + 3, y - 3 }, { x + 7, y - 7 }, { x + 5, y - 1 } })
    :add(poly{ { x - 5, y + 3 }, { x - 8, y + 5 }, { x - 3, y + 4 } }):add(poly{ { x + 4, y + 3 }, { x + 7, y + 5 }, { x + 2, y + 4 } })
  local head = c:ellipse(x + 8, y - 1, 2, 2)
  local all = union(shellM, flips, head)
  rimOf(all, L.foliage2)
  part(union(flips, head), L.seagrass, { nopop = true })
  part(shellM, L.coconut, { nopop = true })
  shellM:each(function(xx, yy) if (xx + yy) % 4 == 0 or (xx - yy) % 4 == 0 then px(xx, yy, L.coconut.deep) end if xx < x - 2 and yy < y then px(xx, yy, L.coconut.hi) end end)
  px(x + 9, y - 2, L.timber.edge)
  hline(x - 8, x + 10, y + 6, L.lagoon.hi)
end
turtle(100, 240)
-- an outrigger canoe moored at the channel mouth, a painted paddle across it
F.outrigger(44, 90, 228, { side = -1, stripe = L.awnA })
line({ { 56, 220 }, { 76, 222 } }):each(function(x, y) px(x, y, L.board.base) end) fill(rect(76, 221, 79, 223), L.awnA.base)
-- floating hibiscus and a coconut
F.flower(140, 248, "hibiscus", true) F.flower(126, 256, "orange", true) F.flower(60, 254, "plumeria", true)
F.coconut(150, 232, 2)
-- mangrove saplings on stilt roots at the left edge of the pool
for i, mx in ipairs({ 24, 34 }) do
  local yb = 244 + i * 2
  local roots = HP.mask()
  for k = -2, 2 do roots:add(line({ { mx, yb - 10 }, { mx + k * 3, yb - 4 }, { mx + k * 4, yb } }, 1)) end
  rimOf(roots, L.timber) roots:each(function(x, y) px(x, y, x < mx and L.timber.hi or L.timber.base) end)
  F.crown(mx, yb - 16, 7, 5, L.foliage2, 60 + i)
end
-- lava boulders on the bank
F.lavaRock(166, 252, 9, 8, 76)
F.lavaRock(16, 232, 7, 6, 77)
F.crab(170, 244, L.hibiscus, true)
-- bamboo footbridge over the race
local br = poly{ { 136, 212 }, { 168, 206 }, { 172, 212 }, { 140, 218 } }
rimOf(br, L.timber) part(br, L.board)
F.bamboo(br, L.board, 3)

---------------------------------------------------------------- left: coconut pyramid, husking stake, husking gnome
F.depth(3)
F.shadow(34, 96, 202, 8, 4)
-- a heap of brown husks behind
local husks = poly{ { 30, 202 }, { 50, 202 }, { 46, 194 }, { 36, 192 } }
rimOf(husks, L.needle) part(husks, L.needle)
husks:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) elseif hash(x, y, 18) < .2 then px(x, y, L.needle.hi) end end)
-- the coconut pyramid
for row = 0, 3 do
  for k = 0, 3 - row do
    local nx, ny = 52 + k * 9 + row * 4 + row % 2, 196 - row * 7
    F.coconut(nx, ny, 4, hash(k, row, 19) < .3)
  end
end
-- husking stake, split coconuts with white flesh
local stake = rect(118, 196, 119, 208)
local stakeBase = c:ellipse(118, 208, 5, 2)
rimOf(union(stake, stakeBase), L.timber) part(stakeBase, L.timber, { nopop = true }) fill(stake, L.iron.base) px(118, 196, L.iron.hi)
for _, s in ipairs({ { 128, 210 }, { 106, 213 }, { 26, 210 }, { 132, 214 } }) do
  local m = c:ellipse(s[1], s[2], 3, 2)
  c:rim(m, L.coconut.edge) fill(m, L.coconut.base) fill(c:ellipse(s[1], s[2] - 1, 2, 1), L.shell.hi) px(s[1] + 1, s[2] - 1, L.shell.base)
end
local _, wx, wy = F.gnome(104, 210, { hat = L.awnA, coat = L.wall2, arm = "up" })
-- the husker's machete raised, mid-swing
line({ { wx, wy + 2 }, { wx - 2, wy - 2 } }):each(function(x, y) px(x, y, L.timber.deep) end)
local blade = poly{ { wx - 2, wy - 2 }, { wx - 4, wy - 10 }, { wx - 2, wy - 11 }, { wx, wy - 3 } }
c:rim(blade, L.iron.edge) fill(blade, L.iron.base) blade:each(function(x, y) if x <= wx - 3 then px(x, y, L.iron.hi) end end)
-- ferns and beach grass along the left edge
for _, f in ipairs({ { 24, 196, 6 }, { 30, 194, 5 }, { 84, 210, 5 }, { 18, 205, 6 } }) do F.fern(f[1], f[2], f[3]) end

---------------------------------------------------------------- right foreground: a cane cart, banana and hibiscus, shells
F.depth(3)
local function cart(x0, yb)
  local bed = poly{ { x0, yb - 14 }, { x0 + 40, yb - 14 }, { x0 + 38, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0 + 40, yb - 10 }, { x0 + 58, yb - 4 } }, 2)
  rimOf(union(bed, shaft), L.timber)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.board) F.bamboo(bed, L.board, 3, { horizontal = true })
  -- a load of sugar cane: long gold stalks with node rings, leafy tops spilling off the back
  local load = HP.mask()
  for k = 0, 4 do load:add(rect(x0 - 4 + k, yb - 16 - k * 3, x0 + 44 - k * 2, yb - 15 - k * 3 + 1)) end
  rimOf(load, L.board)
  load:each(function(x, y)
    local hcol = (y % 3 == 0) and L.board.hi or ((y % 3 == 1) and L.board.base or L.board.shade)
    if (x + y * 3) % 9 == 0 then hcol = L.board.deep end
    px(x, y, hcol)
  end)
  for k = 0, 4 do
    local ty = yb - 15 - k * 3
    F.frond(x0 - 4 + k, ty, 3.0 - k * .08, 9, .4, L.leaf, 400 + k, { wide = .25 })
  end
  hline(x0 + 18, x0 + 20, yb - 30, L.rope.base) vline(x0 + 19, yb - 30, yb - 15, L.rope.shade)
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
for _, f in ipairs({ { 312, 258, 8 }, { 324, 262, 9 }, { 338, 256, 7 }, { 446, 220, 7 }, { 456, 224, 8 }, { 300, 250, 6 } }) do F.fern(f[1], f[2], f[3]) end
-- a banana plant and a hibiscus bush in the near right (keep clear of the compass corner x>=380, y>=230)
F.banana(364, 262, 34, 41)
F.hibiscus(420, 226, 9, 12, 42)
F.fern(352, 266, 7) F.fern(374, 262, 6)
F.shell(330, 246, "conch", true) F.shell(338, 249, "scallop", true) F.crab(326, 252, L.awnA, true)
F.sign(436, 168, 28, 14, L.board)
F.sprite({ "g.g.g", ".ggg.", "..t..", "..t..", ".ttt." }, 434, 171, { g = L.foliage.shade, t = L.coconut.shade }, { rim = false })
-- green coconuts stacked against the sign post
for k = 0, 2 do F.coconut(452 + k * 6, 200, 3, true) end
for k = 0, 1 do F.coconut(455 + k * 6, 194, 3, k == 0) end
F.coconut(458, 188, 3)

-- by the road, right: a driftwood stump with a scarlet macaw on it
local function stump(x, yb, w)
  local body = rect(x - w, yb - w, x + w, yb)
  local topE = c:ellipse(x, yb - w, w, math.max(1, w // 2))
  rimOf(union(body, topE), L.timber) part(body, L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 then px(xx, yy, L.timber.shade) end end)
  fill(topE, L.timber.hi) px(x, yb - w, L.timber.shade) px(x - 1, yb - w - 1, L.board.hi)
  return body
end
stump(288, 216, 5)
F.parrot(287, 199, "macaw")
-- macaw tail hanging down the stump
vline(286, 210, 214, L.awnA.shade) vline(287, 210, 213, "#3c78c8")

---------------------------------------------------------------- gnome on the road with a bundle of cane on his shoulder
local _, phx, phy = F.gnome(258, 240, { hat = L.roof2, coat = L.leaf, arm = "up" })
local cane = HP.mask()
for k = 0, 2 do cane:add(line({ { phx - 18, phy + 8 + k }, { phx + 10, phy - 3 + k } }, 1)) end
rimOf(cane, L.board)
cane:each(function(x, y) px(x, y, (x % 4 == 0) and L.board.deep or (y % 2 == 0 and L.board.hi or L.board.base)) end)
F.frond(phx + 10, phy - 3, -.5, 8, .5, L.leaf, 420, { wide = .25 })
-- a trail of cane trash ... to a hermit crab in a pink conch, nose in the sugar
for i = 0, 6 do px(252 - i * 4, 243 + i * 3, L.needle.hi) px(253 - i * 4, 243 + i * 3, L.board.base) end
local conch = c:ellipse(222, 261, 4, 3)
rimOf(conch, L.shell) part(conch, L.shell, { nopop = true })
px(221, 259, L.shell.hi) px(223, 260, L.petal.base) px(224, 261, L.petal.shade) px(220, 262, L.shell.shade)
F.sprite({ "l.e.e", ".lCCC", "l.lCl" }, 214, 260, { l = L.hibiscus.deep, C = L.hibiscus.base, e = L.timber.edge })
F.depth(0)
F.birds({ { 300, 40, 3 }, { 312, 48, 2 }, { 292, 52, 1 }, { 150, 62, 2 }, { 186, 72, 1 } })

F.finish()
