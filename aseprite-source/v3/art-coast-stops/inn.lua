-- inn.lua : "Inn" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold inn (art-2701-batch4/stops/opus3/inn.lua), re-cast for a chalk-and-dune harbour:
-- left hero: a big two-storey whitewashed harbour pub, granite quoins and plinth, a navy fascia with a white rope
-- twist between the floors, a blue-grey slate roof with orange lichen, a red clay ridge, slate-hooded dormers, two
-- whitewashed stacks with clay pots, glowing bow windows with lead hoods, a slate porch hood and a lifebuoy over the
-- blue door. Herring gulls stand on the ridge. Lobster pots stacked to the eaves at the gable end. A gallows sign post
-- by the road hangs the tankard board, a ship's wheel on the arm's end against the sea. Right: a beer garden under a
-- leaning maritime pine and a wind-bent hawthorn, three fisherfolk in oilskins and guernseys raising tankards at a
-- driftwood trestle table, lantern festoons strung across the road, a barrel stack, an anchor, a waiter with a tray.
-- Road's end: a tarred boathouse with a red pantile roof, a boat's bow in its door. Back right: a whitewashed cottage.
-- A grey donkey at the cart of lobster pots; a goat chewing its tether at the driftwood rail by a granite trough;
-- a collie asleep under the table; gulls begging for crumbs.
-- Quirk: a big ginger tabby asleep on top of the inn sign, tail hanging down over the tankard, "z z" rising.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "inn", out = DIR, farTrees = { 150, 206, 300, 340, 452 },
  sunX = 104, sunY = 34, clouds = { { 300, 34, 54 }, { 412, 62, 32 }, { 186, 74, 20 }, { 22, 30, 26 } },
  boats = { { 172, 97, 8 }, { 324, 95, 6 }, { 346, 101, 9 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix = F.mix

-- a herring gull standing, facing left (flip = facing right), feet at (x, yb)
local function standGull(x, yb, flip, big)
  local rows = big and {
    "..WWW......",
    ".WWeWW.....",
    "YrWWWW.....",
    "...WWWW....",
    "...WWGGGG..",
    "...WWGGGGG.",
    "....WWGGKKK",
    ".....WWW.KK",
    "......p.p..",
  } or {
    "..WW.....",
    ".WeWW....",
    "YYWWW....",
    "..WWGGG..",
    "...WGGGKK",
    "....WWW.K",
    ".....p.p.",
  }
  local w = #rows[1]
  if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
  F.sprite(rows, x - w // 2, yb - #rows + 1, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, Y = L.gold.base, r = L.apple.base,
    e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
end

---------------------------------------------------------------- back row: tarred boathouse at the road's end, far cottage
F.depth(1)
F.tree(300, 128, 30, 4)
F.tree(232, 126, 22, 2)
do
  local top, _, bwall, broof = F.building{ x0 = 246, x1 = 292, yb = 128, wh = 16, rh = 13, wall = L.tar, roof = L.roof2, noFrame = true, noAttic = true, shingle = true }
  F.planks(bwall, L.tar, 4, true, 31)
  F.pantile(broof, L.roof2, top - 13, 31)
  F.lichen(broof, .05, 31)
  -- big arched boathouse door with a boat's bow showing in the dark
  local d = c:rrect(260, 115, 278, 133, 5):clip(rect(260, 115, 278, 128))
  fill(d, L.tar.deep) c:edgeIn(d, L.timber.base)
  local bow = poly{ { 264, 128 }, { 274, 128 }, { 272, 122 }, { 269, 120 }, { 266, 122 } }
  fill(bow, L.wall2.shade) hline(265, 273, 122, L.wall2.hi) vline(269, 120, 127, L.tar.edge) px(268, 121, L.wall2.hi)
  px(262, 118, L.glow.shade) px(263, 118, L.glow.base) -- a lamp lit deep inside
  -- an oar and a lifebuoy hung on the boards
  vline(252, 112, 127, L.board.base) fill(rect(251, 124, 253, 127), L.board.hi)
  local lb = c:ellipse(286, 118, 3, 3):cut(c:ellipse(286, 118, 1, 1))
  lb:each(function(x, y) px(x, y, ((x < 286) == (y < 118)) and L.awnA.base or L.awnB.hi) end)
  -- slipway of sand running down from the door
  for y = 129, 132 do hline(262 - (y - 129), 276 + (y - 129), y, y % 2 == 0 and L.wetSand.base or L.sand.shade) end
end
do
  local top, _, cwall, croof = F.building{ x0 = 416, x1 = 456, yb = 126, wh = 13, rh = 10, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.lichen(croof, .06, 32)
  F.window(424, 117, 428, 120, L.wall2) F.window(446, 117, 450, 120, L.wall2)
  F.door(435, 116, 440, 125, L.wall2)
end
F.smoke(447, 98, 4, .5, 2)
F.fenceP(300, 132, 410, 129, 10)
-- the boathouse washing line: aprons, a guernsey and tea towels (the inn's laundry), hazed with the back row
do local wp = rect(318, 112, 319, 130) rimOf(wp, L.timber) part(wp, L.timber, { nopop = true, noshade = true }) end
F.washing(293, 114, 318, 113, { { "sheet", L.awnB }, { "shirt", L.accent }, { "sock", L.awnA } }, 3)

local function lp(x, yb, w)
  local m = F.lobsterPot(x, yb, w)
  -- lath cage: pale slats round the dome, a dark funnel eye on the face, a red cork float on a rope
  for _, yy in ipairs({ yb - 3, yb - 3 - w // 2 }) do hline(x - w + 1, x + w - 1, yy, L.timber.hi) hline(x - w + 2, x + w - 2, yy + 1, L.timber.deep) end
  local fn = c:ellipse(x - w // 3, yb - w // 2 - 1, math.max(1, w // 3), math.max(1, w // 3))
  rimOf(fn, L.timber) fill(fn, L.soil.deep)
  px(x + w - 1, yb - w - 4, L.awnA.base) px(x + w, yb - w - 4, L.awnA.shade) px(x + w - 1, yb - w - 3, L.awnA.hi) px(x + w - 2, yb - w - 2, L.tar.base)
  return m
end
---------------------------------------------------------------- mid right: wind-bent trees, the cart of lobster pots, the donkey
F.depth(2)
F.tree(352, 152, 46, 6)
F.tree(386, 158, 40, 1)
F.tree(322, 140, 30, 5)
local function potCart(x0, yb)
  local bed = poly{ { x0, yb - 12 }, { x0 + 46, yb - 12 }, { x0 + 44, yb - 6 }, { x0 + 2, yb - 6 } }
  local shaft = line({ { x0, yb - 9 }, { x0 - 16, yb - 3 } }, 2)
  rimOf(union(bed, shaft), L.tar)
  part(shaft, L.timber, { nopop = true, noshade = true })
  part(bed, L.wall2) hline(x0 + 1, x0 + 45, yb - 9, L.wall2.deep) hline(x0 + 1, x0 + 45, yb - 12, L.wall2.hi)
  -- the load: lobster pots, a coil of rope, a net heap with cork floats
  lp(x0 + 10, yb - 12, 7) lp(x0 + 26, yb - 12, 7) lp(x0 + 18, yb - 21, 6)
  local net = c:ellipse(x0 + 39, yb - 15, 6, 4):clip(rect(x0 + 30, yb - 22, x0 + 47, yb - 12))
  rimOf(net, L.tar) fill(net, L.tar.base)
  net:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.tar.hi) elseif (x - y) % 4 == 0 then px(x, y, L.tar.deep) end end)
  for _, k in ipairs({ { x0 + 36, yb - 17 }, { x0 + 41, yb - 14 }, { x0 + 44, yb - 18 } }) do F.cork(k[1], k[2]) end
  for _, wx in ipairs({ x0 + 9, x0 + 37 }) do
    local w = c:ellipse(wx, yb - 4, 6, 6)
    rimOf(w, L.tar) part(w, L.timber, { nopop = true })
    fill(c:ellipse(wx, yb - 4, 3, 3), L.timber.shade)
    vline(wx, yb - 9, yb + 1, L.timber.deep) hline(wx - 5, wx + 5, yb - 4, L.timber.deep) px(wx, yb - 4, L.iron.hi)
  end
end
F.shadow(300, 350, 166, 8, 3)
potCart(302, 166)
-- a grey donkey with a pale muzzle and long ears, head down at a hay net
F.shadowM(c:ellipse(370, 167, 12, 1))
F.sprite({
  "..aa....................",
  "..aA..mm................",
  "...aAmmBBhhhhhhhhhh.....",
  ".....mBBBBBBBBBBBBBBh.t.",
  "....mBBBBBBBBBBBBBBBBtt.",
  "...mBBBBBBBBBBBBBBBBBtt.",
  "..mBBB.BBBBBBBBBBBBBBBt.",
  ".mBeB..BBBBBBBBBBBBBBB.t",
  "BBBB...dBBBBBBBBBBBBBd.t",
  "BBBw....dBBdddddddBBBd.t",
  "BBww....BB.d.....BB.d...",
  "nww.....Bd.d.....Bd.d...",
  "nn......Bd.dd....Bd.dd..",
  "........dd.dd....dd.dd..",
  "........ff.ff....ff.ff..",
}, 352, 152, { m = L.tar.base, h = L.timber.hi, B = L.timber.base, d = L.timber.shade, a = L.timber.shade, A = L.awnB.base,
  w = L.awnB.base, n = L.tar.shade, t = L.tar.base, f = L.tar.deep, e = L.tar.edge }, { rimCol = L.tar.edge })
vline(364, 157, 160, L.tar.shade) -- the dark cross on its back
-- tall ears, inner ear pale
do
  local ears = poly{ { 354, 153 }, { 353, 145 }, { 357, 146 }, { 357, 153 } }:add(poly{ { 358, 154 }, { 359, 146 }, { 363, 147 }, { 361, 155 } })
  rimOf(ears, L.tar) fill(ears, L.timber.shade)
  vline(355, 148, 152, L.cloud.mid) vline(360, 149, 153, L.cloud.mid)
  px(354, 146, L.timber.hi) px(359, 147, L.timber.hi)
end
-- the hay net hanging off the cart tail
local hn = c:ellipse(350, 161, 3, 3) rimOf(hn, L.cork) fill(hn, L.gold.base)
hn:each(function(x, y) if (x + y) % 2 == 0 then px(x, y, L.cork.shade) elseif hash(x, y, 5) < .4 then px(x, y, L.gold.hi) end end)

---------------------------------------------------------------- the inn (left hero)
F.depth(3)
local function inn()
  local X0, X1 = 30, 184
  local GTOP, YB = 142, 182          -- ground floor
  local UX0, UX1, UTOP = 25, 189, 106 -- upper floor, a little proud of the ground floor
  local ground = rect(X0, GTOP, X1, YB)
  local upper = rect(UX0, UTOP, UX1, GTOP - 1)
  local roof = poly{ { 16, UTOP + 1 }, { 198, UTOP + 1 }, { 178, 62 }, { 36, 62 } }
  local ch1, ch2 = rect(52, 46, 61, 70), rect(152, 42, 161, 70)
  local pots = union(rect(54, 40, 56, 45), rect(58, 42, 60, 45), rect(154, 36, 156, 41), rect(158, 38, 160, 41))
  local dorm = {}
  for _, dx in ipairs({ 74, 140 }) do
    dorm[#dorm + 1] = { x = dx, m = poly{ { dx - 11, 96 }, { dx, 77 }, { dx + 11, 96 } }:add(rect(dx - 8, 89, dx + 8, 99)) }
  end
  local sil = union(ground, upper, roof, ch1, ch2, pots)
  F.shadow(X0 + 4, X1 + 4, YB, 16, 6)
  rimOf(sil, L.tar)
  -- chimneys: whitewashed stacks, a tarred band and a slate oversail course, red clay pots
  for _, ch in ipairs({ ch1, ch2 }) do
    part(ch, L.plaster)
    local b = { ch:bbox() }
    ch:each(function(x, y)
      if x >= b[3] - 2 then px(x, y, L.plaster.shade) end
      if hash(x, y // 3, 33) < .08 then px(x, y, L.plaster.shade) end
      if y >= b[4] - 6 and hash(x, y, 34) < .3 then px(x, y, L.lichen.shade) end -- soot-and-lichen stain at the roof line
    end)
    hline(b[1], b[3], b[2] + 4, L.tar.base) hline(b[1], b[3], b[2] + 5, L.tar.deep)
  end
  fill(rect(51, 45, 62, 47), L.roof.deep) hline(51, 62, 45, L.roof.hi)
  fill(rect(151, 41, 162, 43), L.roof.deep) hline(151, 162, 41, L.roof.hi)
  part(pots, L.roof2, { nopop = true })
  for _, p in ipairs({ { 54, 40 }, { 58, 42 }, { 154, 36 }, { 158, 38 } }) do hline(p[1], p[1] + 2, p[2], L.roof2.hi) px(p[1] + 2, p[2] + 2, L.roof2.deep) end
  -- roof: blue-grey slate courses, a red clay ridge, darker hipped right end, lit left end
  part(roof, L.roof, { band = 3 })
  F.courses(roof, 62, 3, 5, L.roof)
  roof:each(function(x, y)
    if y <= 65 then px(x, y, (x % 6 < 3) and L.roof2.base or L.roof2.shade) if y == 62 and x % 6 == 0 then px(x, y, L.roof2.hi) end end -- clay ridge tiles
    local lx = 36 - (y - 62) * 20 / 45
    local rx = 178 + (y - 62) * 20 / 45
    if x > rx - 12 and hash(x, y, 9) < .75 then px(x, y, ((y - 62) % 3 == 0) and L.roof.edge or L.roof.deep) end
    if x < lx + 6 and (y - 62) % 3 ~= 0 and hash(x, y, 10) < .5 then px(x, y, L.roof.hi) end
    -- odd slates: a paler new one, a rusty-stained one
    if y > 66 and (y - 62) % 3 ~= 0 then
      local v = hash((x + ((y - 62) // 3) * 2) // 5, (y - 62) // 3, 11)
      if v < .07 then px(x, y, L.roof.hi) elseif v > .96 then px(x, y, mix(L.roof.base, L.cork.shade, .35)) end
    end
  end)
  hline(36, 178, 62, L.roof2.hi)
  -- orange and grey lichen crusts spreading over the shady lower slates
  for i, b in ipairs({ { 52, 98, 9 }, { 100, 92, 6 }, { 126, 100, 10 }, { 168, 94, 7 }, { 150, 78, 5 }, { 64, 80, 4 }, { 30, 104, 6 }, { 110, 72, 4 } }) do
    roof:each(function(x, y)
      local d = ((x - b[1]) / b[3]) ^ 2 + ((y - b[2]) / (b[3] * .6)) ^ 2
      if d < 1 and hash(x, y, 30 + i) < .6 then
        local h = d < .3 and L.lichen.shade or (hash(x, y, 50 + i) < .5 and L.moss.base or L.moss.shade)
        if (y - 62) % 3 == 0 then h = d < .5 and L.lichen.deep or L.roof.deep end
        if d < .15 and (y - b[2]) < 0 then h = L.lichen.base end
        px(x, y, h)
      end
    end)
  end
  F.lichen(roof, .025, 36)
  -- herring gulls on the ridge, one calling with its beak open
  standGull(98, 61, false, true) standGull(116, 61, true) standGull(170, 61, false)
  px(94, 52, L.apple.base) px(93, 52, L.gold.base)
  hline(16, 198, UTOP + 1, L.roof.edge) hline(17, 197, UTOP, L.roof.deep)
  for x = 18, 196, 3 do px(x, UTOP + 2, L.roof.deep) if x % 2 == 0 then px(x, UTOP + 3, L.roof.edge) end end
  -- a cast-iron gutter along the eaves with a downpipe at the right corner
  hline(17, 197, UTOP + 1, L.iron.shade) for x = 20, 196, 9 do px(x, UTOP + 2, L.iron.deep) end
  -- dormers: slate hoods, whitewashed cheeks, white bargeboards, blue sash windows
  for _, d in ipairs(dorm) do
    rimOf(d.m, L.tar)
    local wall = rect(d.x - 7, 89, d.x + 7, 99)
    part(d.m, L.roof, { nopop = true }) F.courses(d.m, 77, 3, 5, L.roof) F.lichen(d.m, .06, 34 + d.x)
    part(wall, L.plaster, { nopop = true })
    wall:each(function(x, y) if x >= d.x + 5 then px(x, y, L.plaster.shade) end end)
    F.window(d.x - 4, 90, d.x + 3, 97, L.wall2, true)
    line({ { d.x - 11, 96 }, { d.x, 77 } }):each(function(x, y) px(x, y, L.awnB.hi) end)
    line({ { d.x + 11, 96 }, { d.x, 77 } }):each(function(x, y) px(x, y, L.plaster.shade) end)
    px(d.x, 75, L.tar.edge) px(d.x, 76, L.roof2.base) -- finial
  end
  -- upper floor: whitewash, salt-streaked, an eave shadow
  part(upper, L.plaster, { nopop = true })
  upper:each(function(x, y)
    local v = hash(x, y // 3, 46)
    if v < .05 then px(x, y, L.plaster.shade) elseif hash(x // 3, y, 47) < .05 then px(x, y, L.plaster.hi) end
    if hash(x, 1, 48) < .05 and y > UTOP + 6 and y < UTOP + 6 + floor(hash(x, 2, 48) * 14) then px(x, y, L.plaster.shade) end -- rain streaks
    if y <= UTOP + 3 then px(x, y, y <= UTOP + 1 and L.plaster.deep or L.plaster.shade) end -- eave shadow
    if x >= UX1 - 3 then px(x, y, L.plaster.shade) end
  end)
  -- granite quoins up both corners
  for _, qx in ipairs({ UX0, UX1 - 5 }) do
    for y = UTOP + 4, GTOP - 4, 5 do
      local w = ((y - UTOP) // 5) % 2 == 0 and 5 or 3
      local x0q = qx == UX0 and qx or qx + 5 - w
      local q = rect(x0q, y, x0q + w, y + 3)
      part(q, L.stone, { nopop = true, noshade = true }) hline(x0q, x0q + w, y, L.stone.hi) hline(x0q, x0q + w, y + 3, L.stone.deep)
    end
  end
  -- the fascia between the floors: navy board with a white rope twist
  local fas = rect(UX0 - 1, GTOP - 4, UX1 + 1, GTOP + 1)
  part(fas, L.accent, { nopop = true, noshade = true }) hline(UX0 - 1, UX1 + 1, GTOP - 4, L.accent.hi) hline(UX0 - 1, UX1 + 1, GTOP + 1, L.accent.deep)
  for x = UX0 + 1, UX1 - 1 do
    local k = x % 4
    px(x, GTOP - 2 + (k < 2 and 0 or 1), k == 0 and L.awnB.hi or L.awnB.base)
    if k == 1 then px(x, GTOP - 1, L.awnB.shade) end
  end
  -- upper windows: blue sashes with blue shutters, anchor cut-outs, a glow behind
  for _, wx in ipairs({ 62, 106, 148, 178 }) do
    F.window(wx - 3, UTOP + 17, wx + 3, UTOP + 27, L.wall2)
    hline(wx - 3, wx + 3, UTOP + 22, L.wall2.base)
    for y = UTOP + 18, UTOP + 26, 2 do px(wx - 2, y, L.glow.shade) px(wx + 2, y + 1, L.glow.shade) end
    hline(wx - 4, wx + 4, UTOP + 28, L.stone.hi) hline(wx - 4, wx + 4, UTOP + 29, L.stone.shade) -- slate sill
    for _, sx in ipairs({ wx - 8, wx + 5 }) do
      if not (wx == 178 and sx > wx) then
        local sh = rect(sx, UTOP + 16, sx + 3, UTOP + 28)
        c:rim(sh, L.wall2.edge) part(sh, L.wall2, { nopop = true })
        vline(sx + 3, UTOP + 17, UTOP + 27, L.wall2.shade) hline(sx, sx + 3, UTOP + 22, L.wall2.deep)
        px(sx + 1, UTOP + 18, L.wall2.deep) px(sx + 2, UTOP + 18, L.wall2.deep) vline(sx + 1, UTOP + 18, UTOP + 20, L.wall2.deep) -- anchor
        px(sx, UTOP + 20, L.wall2.deep) px(sx + 2, UTOP + 20, L.wall2.deep)
      end
    end
  end
  -- ground floor: whitewash, damp lower course, granite plinth with lichen
  part(ground, L.plaster)
  ground:each(function(x, y)
    if y <= GTOP + 4 then px(x, y, L.plaster.shade) end -- under the fascia
    if hash(x, y // 3, 49) < .05 then px(x, y, L.plaster.shade) end
    if y >= YB - 10 and hash(x // 2, y, 52) < .25 then px(x, y, L.plaster.shade) end
    if x >= X1 - 3 then px(x, y, L.plaster.shade) end
  end)
  for _, qx in ipairs({ X0, X1 - 5 }) do
    for y = GTOP + 4, YB - 10, 5 do
      local w = ((y - GTOP) // 5) % 2 == 0 and 5 or 3
      local x0q = qx == X0 and qx or qx + 5 - w
      local q = rect(x0q, y, x0q + w, y + 3)
      part(q, L.stone, { nopop = true, noshade = true }) hline(x0q, x0q + w, y, L.stone.hi) hline(x0q, x0q + w, y + 3, L.stone.deep)
    end
  end
  local plinth = rect(X0, YB - 6, X1, YB)
  part(plinth, L.stone, { nopop = true }) F.courses(plinth, YB - 6, 3, 8, L.stone) F.lichen(plinth, .14, 35)
  hline(X0, X1, YB - 7, L.tar.base)
  -- the door: sea-blue, arched, a slate porch hood on driftwood posts, a lifebuoy over the door
  F.door(99, 154, 115, YB - 1, L.wall2, true)
  fill(rect(98, YB, 116, YB), L.stone.hi)
  local hood = poly{ { 92, 152 }, { 107, 143 }, { 122, 152 } }:add(rect(92, 151, 122, 153))
  rimOf(hood, L.tar) part(hood, L.roof, { nopop = true }) F.courses(hood, 143, 3, 4, L.roof)
  line({ { 92, 152 }, { 107, 143 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  F.lichen(hood, .1, 37)
  for _, px0 in ipairs({ 94, 119 }) do local p = rect(px0, 154, px0 + 1, YB) rimOf(p, L.tar) part(p, L.timber, { nopop = true, noshade = true }) end
  do
    local ring = c:ellipse(107, 160, 5, 5):cut(c:ellipse(107, 160, 2, 2))
    c:rim(ring, L.tar.edge)
    ring:each(function(x, y)
      local a = math.atan(y - 160, x - 107)
      local q = floor((a + pi) / (pi / 2) + .5) % 2
      px(x, y, q == 0 and L.awnA.base or L.awnB.hi)
      if x + y > 107 + 160 + 4 then px(x, y, q == 0 and L.awnA.shade or L.awnB.shade) end
    end)
    for _, p in ipairs({ { 102, 156 }, { 112, 156 }, { 102, 164 }, { 112, 164 } }) do px(p[1], p[2], L.cork.deep) end
  end
  -- bow windows: bowed panes with a lead hood above and a panelled stall-board below
  local function bay(x0, x1, y0, y1)
    local cx, hw = (x0 + x1) // 2, (x1 - x0) // 2
    local m = rect(x0, y0, x1, y1)
    local hoodM = c:ellipse(cx, y0 - 1, hw + 3, 4):clip(rect(x0 - 4, y0 - 6, x1 + 4, y0 - 2))
    local stall = rect(x0 - 1, y1 + 2, x1 + 1, y1 + 6)
    rimOf(union(m:grow(1), hoodM, stall), L.tar)
    fill(m:grow(1), L.wall2.base)
    fill(m, L.glow.base)
    m:each(function(x, y)
      local f = (x - x0) / (x1 - x0)
      if (x - x0) % 6 == 0 or (y - y0) % 5 == 0 then px(x, y, f > .8 and L.wall2.shade or L.wall2.hi)
      elseif f < .18 and (x - x0) % 6 == 1 then px(x, y, L.glow.hi)
      elseif f > .82 then px(x, y, L.glow.shade)
      elseif (x - x0) % 6 == 1 and (y - y0) % 5 == 1 then px(x, y, L.glow.hi)
      elseif (x - x0) % 6 == 5 or (y - y0) % 5 == 4 then px(x, y, L.glow.shade) end
    end)
    part(hoodM, L.iron, { nopop = true })
    hoodM:each(function(x, y) if (x - x0) % 6 == 3 then px(x, y, L.iron.shade) end if x < cx - hw // 2 and not hoodM:has(x, y - 1) then px(x, y, L.iron.hi) end end)
    hline(x0 - 1, x1 + 1, y0 - 1, L.wall2.deep)
    hline(x0 - 1, x1 + 1, y1 + 1, L.stone.hi)
    part(stall, L.wall2, { nopop = true })
    for k = 0, 3 do
      local p = rect(x0 + 1 + k * floor((x1 - x0) / 4), y1 + 3, x0 + (k + 1) * floor((x1 - x0) / 4) - 1, y1 + 5)
      c:edgeIn(p, L.wall2.shade) px(p:bbox(), y1 + 3, L.wall2.hi)
    end
    -- thrift and geraniums in pots along the sill
    for x = x0 + 2, x1 - 2, 7 do
      fill(rect(x, y1 - 2, x + 2, y1), L.roof2.base) px(x, y1 - 2, L.roof2.hi)
      px(x, y1 - 3, L.leaf.base) px(x + 2, y1 - 3, L.leaf.shade) px(x + 1, y1 - 4, L.apple.base) px(x, y1 - 4, L.apple.hi)
    end
  end
  bay(40, 76, 155, 168)
  bay(134, 170, 155, 168)
  -- inside the bows: drinkers' silhouettes with tankards
  F.sprite({ "..ss..", ".ssss.", "ssssss", ".sss..", "sssss.", "sssss." }, 140, 159, { s = L.glow.deep }, { rim = false })
  F.sprite({ "..ss...", ".ssss..", "ssssss.", "..sssss", ".ssssss", ".ssssss" }, 60, 159, { s = L.glow.deep }, { rim = false })
  px(66, 160, L.glow.deep) px(67, 160, L.glow.deep) px(67, 161, L.glow.deep)
  -- a ship's lantern on a bracket by the door
  fill(rect(122, 146, 128, 146), L.iron.shade) vline(127, 147, 148, L.iron.shade)
  local lam = rect(125, 149, 129, 155) rimOf(lam, L.tar) fill(lam, L.glow.base) px(126, 150, L.glow.hi) vline(129, 150, 155, L.glow.shade)
  hline(125, 129, 148, L.cork.shade) px(127, 156, L.tar.base)
  for _, p in ipairs({ { 124, 157 }, { 130, 157 }, { 123, 152 }, { 131, 152 }, { 127, 158 } }) do px(p[1], p[2], L.glow.hi) end
  -- a climbing rose up the right corner, pink against the whitewash
  for i = 0, 34 do
    local y = YB - 8 - i
    local x = X1 - 7 + floor(2 * sin(i * .5))
    px(x, y, L.leaf.shade)
    if i % 4 == 0 then px(x - 1, y, L.leaf.base) px(x + 1, y - 1, L.leaf.hi) end
    if i % 5 == 2 then px(x - 1, y, L.petal.base) px(x - 1, y - 1, L.petal.hi) px(x, y + 1, L.petal.shade) end
  end
  -- downpipe at the right corner
  vline(X1 + 2, UTOP + 2, YB, L.iron.shade) vline(X1 + 3, UTOP + 2, YB, L.iron.deep) px(X1 + 2, YB, L.iron.hi)
  F.smoke(56, 34, 7, .9, 2) F.smoke(157, 30, 8, 1.1, 3)
  -- a gnome leaning out of the upstairs window, shaking a Breton-striped rug, dust flying
  F.gnome(106, 139, { small = true, hat = L.awnA, coat = L.accent, arm = "out" })
  local rug = rect(112, 135, 124, 151)
  c:rim(rug, L.tar.edge) fill(rug, L.awnB.hi)
  rug:each(function(x, y) if ((y - 135) // 3) % 2 == 1 then px(x, y, L.accent.base) end if x == 124 then px(x, y, ((y - 135) // 3) % 2 == 1 and L.accent.deep or L.awnB.shade) end if y == 135 then px(x, y, L.awnB.hi) end end)
  for x = 112, 124, 2 do px(x, 152, L.awnA.base) end
  for _, p in ipairs({ { 127, 140 }, { 129, 137 }, { 128, 144 }, { 131, 141 }, { 132, 146 }, { 130, 135 } }) do px(p[1], p[2], "#d6d4c2") px(p[1] + 1, p[2], "#c4c4b0") end
end
inn()

-- lobster pots stacked to the eaves against the left gable end, glass floats and a coil of rope on top
do
  local X0, X1, Y0, Y1 = 15, 40, 108, 182
  F.shadow(X0, X1 + 2, Y1, 6, 3)
  local back = rect(X0 + 1, Y0 + 4, X1 - 1, Y1)
  fill(back, L.plaster.deep)
  local row = 0
  for yb = Y1, Y0 + 14, -9 do
    row = row + 1
    for _, x in ipairs(row % 2 == 0 and { 22, 34 } or { 21, 33 }) do lp(x, yb, 5) end
  end
  -- a buoy and two glass floats in rope cages on the top tier
  local fl = c:ellipse(22, Y0 + 9, 3, 3) rimOf(fl, L.glass) part(fl, L.glass) px(21, Y0 + 8, "#eef6f0")
  local fl2 = c:ellipse(30, Y0 + 10, 2, 2) rimOf(fl2, L.glass) part(fl2, L.glass, { nopop = true })
  fl:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.cork.shade) end end)
  local buoy = c:ellipse(36, Y0 + 9, 3, 4) rimOf(buoy, L.awnA) part(buoy, L.awnA) hline(33, 39, Y0 + 9, L.awnB.hi)
  -- a blue fish box at the foot with a few silver fish
  F.crate(38, 186, 14, 6, L.gull)
  -- an oar leaning on the stack
  local oar = line({ { 44, 172 }, { 51, 144 } }, 1)
  local blade = poly{ { 41, 182 }, { 42, 170 }, { 45, 170 }, { 45, 182 } }
  rimOf(union(oar, blade), L.tar) part(oar, L.board, { nopop = true, noshade = true }) part(blade, L.wall2, { nopop = true })
  vline(42, 172, 181, L.wall2.hi) fill(rect(50, 144, 51, 147), L.cork.base)
end

-- the landlady in her apron with a tankard, on the step
F.depth(3)
local _, ihx, ihy = F.gnome(132, 194, { hat = L.awnA, coat = L.awnB, arm = "out" })
do local mug = rect(ihx, ihy - 5, ihx + 3, ihy) rimOf(mug, L.tar) part(mug, L.iron, { nopop = true }) hline(ihx, ihx + 3, ihy - 5, L.awnB.hi) px(ihx + 4, ihy - 3, L.iron.shade) end
-- a slate board by the door: a chalk tankard and a fish
do
  local leg = line({ { 82, 198 }, { 86, 180 } }, 1):add(line({ { 96, 198 }, { 92, 180 } }, 1))
  local bd = rect(80, 178, 98, 192)
  rimOf(union(bd, leg), L.tar) part(leg, L.timber, { nopop = true, noshade = true })
  fill(bd, L.iron.deep) c:edgeIn(bd, L.timber.base)
  for _, p in ipairs({ { 83, 182 }, { 84, 182 }, { 85, 182 }, { 83, 183 }, { 83, 184 }, { 83, 185 }, { 84, 186 }, { 85, 186 }, { 86, 183 }, { 86, 184 }, { 87, 184 } }) do px(p[1], p[2], L.awnB.base) end
  for x = 90, 94 do px(x, 185, L.awnB.base) end px(91, 184, L.awnB.base) px(92, 184, L.awnB.base) px(91, 186, L.awnB.base) px(92, 186, L.awnB.base)
  px(95, 184, L.awnB.base) px(95, 186, L.awnB.base) px(89, 185, L.awnB.shade)
end

---------------------------------------------------------------- the gallows sign post, the ship's wheel and the tankard board
F.depth(3)
local SX0, SX1, SY0, SY1 = 202, 240, 128, 152
do
  local post = rect(194, 96, 197, 196)
  local arm = rect(194, 96, 246, 99)
  local brace = line({ { 198, 118 }, { 218, 100 } }, 2)
  local foot = rect(189, 192, 202, 198)
  F.shadowM(c:ellipse(204, 199, 12, 2))
  rimOf(union(post, arm, brace, foot), L.tar)
  part(post, L.timber, { nopop = true }) part(arm, L.timber, { nopop = true, noshade = true }) part(brace, L.timber, { nopop = true, noshade = true })
  post:each(function(x, y) if hash(x, y // 3, 37) < .15 then px(x, y, L.timber.shade) end end)
  part(foot, L.stone, { nopop = true }) hline(189, 202, 192, L.stone.hi) F.lichen(foot, .25, 38)
  hline(194, 246, 96, L.timber.hi)
  -- a rope whipping round the post
  for y = 160, 166 do hline(194, 197, y, y % 2 == 0 and L.cork.base or L.cork.shade) end
  -- the ship's wheel bolted on the arm's end, standing against the sea
  local wx, wy = 248, 85
  local ringW = c:ellipse(wx, wy, 7, 7):cut(c:ellipse(wx, wy, 5, 5))
  local hub = c:ellipse(wx, wy, 2, 2)
  local spokes = HP.mask()
  for k = 0, 7 do
    local a = k * pi / 4 + .2
    spokes:add(line({ { wx + cos(a) * 2, wy + sin(a) * 2 }, { wx + cos(a) * 10, wy + sin(a) * 10 } }, 1))
  end
  local brk = rect(247, 93, 248, 96)
  local wheel = union(ringW, hub, spokes, brk)
  rimOf(wheel, L.tar)
  part(spokes, L.cork, { nopop = true, noshade = true })
  for k = 0, 7 do
    local a = k * pi / 4 + .2
    local hx_, hy_ = floor(wx + cos(a) * 9 + .5), floor(wy + sin(a) * 9 + .5)
    px(hx_, hy_, (cos(a) + sin(a) < 0) and L.cork.hi or L.cork.shade)
  end
  part(ringW, L.cork, { nopop = true })
  ringW:each(function(x, y) if (x - wx) + (y - wy) < -6 then px(x, y, L.cork.hi) elseif (x - wx) + (y - wy) > 6 then px(x, y, L.cork.deep) end end)
  fill(hub, L.gold.base) px(wx - 1, wy - 1, L.gold.hi) px(wx + 1, wy + 1, L.gold.deep)
  part(brk, L.iron, { nopop = true, noshade = true })
  -- chains
  for y = 100, SY0 - 1 do if y % 2 == 0 then px(SX0 + 3, y, L.iron.shade) px(SX1 - 3, y, L.iron.shade) else px(SX0 + 3, y, L.iron.hi) px(SX1 - 3, y, L.iron.hi) end end
  -- the board: navy frame, cream field, a big foaming tankard
  local board = rect(SX0, SY0, SX1, SY1)
  rimOf(board, L.accent) part(board, L.accent, { nopop = true })
  local field = rect(SX0 + 3, SY0 + 3, SX1 - 3, SY1 - 3)
  fill(field, L.awnB.hi) field:each(function(x, y) if hash(x, y, 6) < .06 then px(x, y, L.awnB.base) end end)
  hline(SX0, SX1, SY0, L.accent.hi) vline(SX0, SY0, SY1, L.accent.hi)
  -- rope-knot corners and a little painted fish
  for _, p in ipairs({ { SX0 + 1, SY0 + 1 }, { SX1 - 1, SY0 + 1 }, { SX0 + 1, SY1 - 1 }, { SX1 - 1, SY1 - 1 } }) do px(p[1], p[2], L.cork.hi) end
  F.sprite({ "f..ff.", "fffffe", "f..ff." }, SX0 + 4, SY1 - 7, { f = L.wall2.base, e = L.tar.edge }, { rim = false })
  local tk = rect(213, 136, 227, 149)
  local hnd = c:ellipse(229, 142, 4, 4):cut(c:ellipse(229, 142, 2, 2)):cut(rect(222, 136, 227, 149))
  local foam = c:ellipse(220, 135, 9, 3):add(c:ellipse(216, 133, 3, 2)):add(c:ellipse(223, 132, 3, 2))
  c:rim(union(tk, hnd, foam), L.tar.edge)
  part(tk, L.glow) part(hnd, L.iron, { nopop = true })
  for x = 215, 225, 4 do vline(x, 139, 148, L.glow.shade) end
  hline(213, 227, 138, L.iron.base) hline(213, 227, 147, L.iron.base) px(213, 138, L.iron.hi) px(213, 147, L.iron.hi)
  part(foam, L.awnB, { nopop = true }) px(214, 132, L.awnB.hi) px(215, 131, L.awnB.hi) px(222, 131, L.awnB.hi)
  px(211, 137, L.awnB.base) px(210, 139, L.awnB.base) -- a drip of foam
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
  c:rim(cat, L.tar.edge)
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
  px(203, by - 14, L.petal.base) px(204, by - 13, L.petal.base) px(212, by - 14, L.petal.base) px(212, by - 13, L.petal.base)
  fill(c:ellipse(208, by - 3, 4, 2), L.awnB.hi) fill(paws, L.awnB.hi) px(209, by - 1, L.awnB.shade) px(213, by - 1, L.awnB.shade)
  px(203, by - 8, L.tar.edge) px(204, by - 7, L.tar.edge) px(205, by - 8, L.tar.edge)
  px(210, by - 8, L.tar.edge) px(211, by - 7, L.tar.edge) px(212, by - 8, L.tar.edge)
  fill(rect(207, by - 6, 208, by - 5), L.petal.shade) px(207, by - 6, L.petal.hi)
  px(208, by - 4, L.tar.edge)
  hline(197, 200, by - 5, L.awnB.shade) hline(215, 218, by - 5, L.awnB.shade)
  -- a herring bone it has finished with, on the board edge by its paws
  hline(198, 202, by, L.awnB.hi) px(197, by - 1, L.awnB.base) px(197, by + 1, L.awnB.base) for x = 199, 201, 2 do px(x, by - 1, L.awnB.base) end px(203, by, L.gull.shade)
  local function zed(x, y, s)
    for i = 0, s do px(x + i, y, L.accent.deep) px(x + i, y + s, L.accent.deep) px(x + s - i, y + i, L.accent.deep) end
  end
  zed(214, by - 24, 3) zed(220, by - 32, 4) zed(228, by - 41, 5)
end

---------------------------------------------------------------- beer garden (right): maritime pine + hawthorn, festoons, table
F.depth(3)
do
  F.shadowM(c:ellipse(434, 194, 28, 3))
  F.windTree(452, 192, 72, L.foliage2, 51)
  F.tree(428, 196, 104, 3)
  F.tree(404, 194, 92, 2)
end
-- festoon lantern strings: sign arm -> pole across the road, pole -> pine
local function festoon(x0, y0, x1, y1, sag, step, startI)
  local function ly(x) local t = (x - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for x = x0, x1 do px(x, ly(x), L.tar.deep) end
  local cols = { L.awnA, L.glow, L.wall2, L.glow, L.roof2 }
  local i = startI or 0
  for x = x0 + 8, x1 - 6, step do
    i = i + 1
    local y = ly(x) + 1
    local r = cols[i % #cols + 1]
    local m = c:rrect(x - 2, y + 1, x + 2, y + 6, 1)
    c:rim(m, L.tar.edge) fill(m, r.base) px(x - 1, y + 2, r.hi) vline(x + 2, y + 2, y + 5, r.shade) px(x, y, L.tar.deep)
    px(x, y + 7, r.deep)
  end
end
do
  local pole = rect(288, 116, 289, 196)
  rimOf(pole, L.tar) part(pole, L.timber, { nopop = true, noshade = true })
  F.sprite({ "rr..", "rrrr", "rr.." }, 290, 112, { r = L.awnA.base }) vline(289, 112, 116, L.tar.base) -- a red pennant on the pole top
  festoon(289, 117, 412, 128, 3, 12, 0)
  festoon(246, 100, 288, 117, 4, 11, 2)
end
-- barrel stack against the pole, lobster pots and a coil of rope
F.barrel(300, 206, L.timber, 12) F.barrel(312, 207, L.cork, 12) F.barrel(306, 194, L.timber, 11)
F.barnacles(rect(295, 202, 317, 207), .06, 39)
-- long driftwood trestle table with three fisherfolk behind it, raising tankards
local function mugAt(x, y)
  local m = rect(x, y - 5, x + 3, y)
  c:rim(m, L.tar.edge) part(m, L.iron, { nopop = true }) hline(x, x + 3, y - 5, L.awnB.hi) hline(x - 1, x + 4, y - 6, L.awnB.base) px(x + 4, y - 3, L.iron.shade)
  px(x + 1, y - 3, L.glow.base)
end
do
  local g1 = { 338, 210, L.gorse, L.gorse, "up" }       -- yellow oilskins and a sou'wester
  local g2 = { 366, 209, L.awnA, L.accent, "up" }       -- navy guernsey, red cap
  local g3 = { 394, 210, L.accent, L.wall2, "out" }     -- blue smock
  for i, g in ipairs({ g1, g2, g3 }) do
    local _, hx, hy = F.gnome(g[1], g[2], { hat = g[3], coat = g[4], arm = g[5], flip = (i == 3), noShadow = true })
    mugAt(hx - 1, hy)
  end
  -- the sou'wester brim
  hline(331, 345, 197, L.gorse.shade) px(331, 198, L.gorse.deep) px(345, 198, L.gorse.deep)
  for _, p in ipairs({ { 356, 186 }, { 352, 184 }, { 358, 182 } }) do px(p[1], p[2], L.awnB.hi) end
  -- the table: driftwood top on trestles
  local top = rect(322, 209, 414, 213)
  local legs = rect(328, 214, 330, 228):add(rect(406, 214, 408, 228)):add(line({ { 329, 222 }, { 407, 222 } }))
  local bench = rect(318, 224, 418, 226):add(rect(322, 227, 323, 231)):add(rect(413, 227, 414, 231))
  F.shadow(324, 414, 231, 10, 3)
  rimOf(union(top, legs, bench), L.tar)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(bench, L.timber, { nopop = true }) hline(318, 418, 224, L.timber.hi)
  part(top, L.board) F.planks(top, L.board, 9, false, 7) hline(322, 414, 209, L.board.hi) hline(322, 414, 213, L.timber.base)
  mugAt(348, 208) mugAt(380, 208)
  local loaf = c:ellipse(362, 206, 5, 3) rimOf(loaf, L.soil) part(loaf, L.produce) px(360, 205, L.produce.hi) hline(359, 365, 206, L.produce.shade) for k = 0, 2 do px(359 + k * 3, 204, L.produce.deep) end
  -- a boiled crab on a plate
  fill(c:ellipse(394, 208, 6, 1), L.awnB.base)
  F.sprite({ "c.....c", ".c.e.c.", "..CCC..", ".CCCCC." }, 391, 203, { C = L.roof2.base, c = L.roof2.shade, e = L.tar.edge }, { rimCol = L.roof2.edge })
  -- a bowl of mussels
  local plate = c:ellipse(334, 208, 6, 1) fill(plate, L.awnB.base) fill(c:ellipse(334, 206, 4, 2), L.accent.deep) hline(331, 337, 205, L.accent.base)
  px(332, 204, L.accent.hi) px(335, 204, L.cork.hi) px(336, 205, L.accent.hi) px(333, 206, L.cork.base)
  -- a candle in a jar
  fill(rect(371, 204, 373, 208), L.glass.hi) px(372, 203, L.glow.hi) px(372, 202, L.glow.base)
end
-- the waiter crossing the road with a tray of tankards
F.depth(3)
do
  local _, hx, hy = F.gnome(268, 232, { hat = L.wall2, coat = L.awnB, arm = "up", flip = true })
  local tray = rect(hx - 9, hy - 1, hx + 5, hy)
  rimOf(tray, L.tar) part(tray, L.iron, { nopop = true, noshade = true })
  mugAt(hx - 8, hy - 2) mugAt(hx - 3, hy - 2) mugAt(hx + 2, hy - 2)
end

---------------------------------------------------------------- foreground left: granite trough, driftwood rail, lean-to, barrel roller
F.depth(3)
do
  local rail = rect(22, 212, 104, 214):add(rect(26, 212, 28, 228)):add(rect(98, 212, 100, 228))
  rimOf(rail, L.tar) part(rail, L.timber, { nopop = true, noshade = true }) hline(22, 104, 212, L.timber.hi)
  rail:each(function(x, y) if hash(x // 3, y, 54) < .12 then px(x, y, L.timber.shade) end end)
  fill(rect(40, 214, 41, 218), L.cork.shade) -- a tied rope
  -- a granite trough full of water
  F.shadow(32, 96, 234, 8, 3)
  local t = rect(32, 219, 96, 231)
  rimOf(t, L.stone) part(t, L.stone)
  F.courses(t, 223, 4, 16, L.stone)
  local w = rect(35, 220, 93, 222)
  fill(rect(33, 219, 95, 219), L.stone.hi)
  fill(w, L.water.base) hline(35, 93, 220, L.water.hi) for x = 38, 92, 9 do px(x, 221, L.water.hi) px(x + 1, 221, L.foam) end
  hline(34, 94, 223, L.stone.shade)
  F.lichen(t, .05, 41)
  for x = 32, 96 do if hash(x, 1, 77) < .35 then px(x, 231, L.leaf.base) end end
end
do -- driftwood logs stacked under a slate lean-to by the inn wall
  local stackM = rect(146, 196, 184, 212)
  F.shadow(146, 186, 213, 6, 3)
  rimOf(stackM, L.tar) fill(stackM, L.timber.deep)
  for row = 0, 2 do for k = 0, 6 do
    local cx, cy = 149 + k * 6 + (row % 2) * 3, 199 + row * 5
    if cx <= 182 then
      local tr = (hash(k, row, 8) < .3) and L.cork or L.board
      local lg = c:ellipse(cx, cy, 2.5, 2.5)
      fill(lg, tr.hi) px(cx, cy, tr.shade) px(cx + 1, cy, tr.base)
      lg:edge():each(function(x, y) px(x, y, (x > cx or y > cy) and L.timber.base or tr.base) end)
    end
  end end
  local lean = poly{ { 142, 196 }, { 188, 192 }, { 188, 195 }, { 142, 199 } }
  rimOf(lean, L.tar) part(lean, L.roof, { nopop = true }) F.lichen(lean, .2, 42)
  local axe = line({ { 186, 212 }, { 180, 202 } }) fill(axe, L.board.base) fill(rect(178, 200, 181, 203), L.iron.base) px(178, 200, L.iron.hi)
end
-- a driftwood chopping block by the road with the axe bitten in, split billets and chips
do
  local x, yb, w = 194, 230, 6
  F.shadowM(c:ellipse(198, 231, 9, 1))
  local body = rect(x - w, yb - 7, x + w, yb)
  local top = c:ellipse(x, yb - 7, w, 2)
  rimOf(union(body, top), L.tar) part(body, L.timber, { nopop = true })
  body:each(function(xx, yy) if (xx - x) % 3 == 0 and hash(xx, yy // 2, 44) < .6 then px(xx, yy, L.timber.shade) end end)
  fill(top, L.board.base) px(x, yb - 7, L.board.shade) hline(x - 3, x - 1, yb - 8, L.board.hi)
  F.barnacles(body, .08, 45, yb - 3)
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
  local _, hx, hy = F.gnome(176, 252, { hat = L.awnA, coat = L.accent, arm = "out", flip = true })
  local b = c:rrect(152, 240, 166, 254, 4)
  F.shadowM(c:ellipse(160, 255, 9, 1))
  rimOf(b, L.tar) part(b, L.cork)
  vline(155, 241, 253, L.iron.shade) vline(163, 241, 253, L.iron.shade) hline(153, 165, 246, L.cork.hi)
  for _, p in ipairs({ { 146, 250 }, { 144, 246 }, { 143, 253 } }) do px(p[1], p[2], L.sand.hi) end
end
-- crate of green bottles, a fish box, a barnacled rock, shore plants, bottom left
do
  F.crate(40, 256, 26, 12)
  for k = 0, 5 do
    local bx = 43 + k * 4
    local b = rect(bx, 238, bx + 2, 244):add(rect(bx + 1, 235, bx + 1, 237))
    c:rim(b, L.tar.edge) fill(b, L.glass.shade) px(bx, 239, L.glass.hi) px(bx + 1, 235, L.cork.base)
  end
  F.crate(80, 262, 18, 7, L.gull)
  hline(80, 98, 262, L.wall2.base)
  F.sack(108, 262, L.board, 6)
  F.barnacles(F.rock(126, 262, 8, 6), .18, 43, 0)
  F.marram(16, 238, 7) F.marram(24, 250, 8) F.marram(116, 250, 6) F.marram(70, 266, 6) F.marram(8, 260, 7)
  F.thrift(134, 256, true) F.thrift(140, 260) F.thrift(30, 262, true)
  F.shell(60, 264, true) F.shell(66, 266) F.pebbles(102, 268, 3, 6)
  F.driftwood(4, 246, 22, 242, 2)
end
-- a half-barrel tub of thrift and white sea campion by the road
do
  local tub = c:rrect(210, 226, 228, 240, 3)
  F.shadowM(c:ellipse(222, 241, 10, 1))
  rimOf(tub, L.tar) part(tub, L.wall2) hline(210, 228, 230, L.iron.shade) hline(210, 228, 237, L.iron.shade)
  tub:each(function(x, y) if (x - 210) % 4 == 0 and y > 230 and y < 237 then px(x, y, L.wall2.shade) end end)
  fill(c:ellipse(219, 226, 8, 2), L.leaf.shade)
  F.thrift(214, 226, true) F.thrift(220, 225, true) F.thrift(225, 226, false)
  for i = 0, 7 do local fx, fy = 211 + floor(hash(i, 1, 5) * 16), 222 + floor(hash(i, 2, 5) * 4) px(fx, fy, L.awnB.hi) px(fx + 1, fy + 1, L.leaf.base) end
end

-- gulls begging for crumbs dropped from the table, and one hen
F.depth(3)
standGull(320, 252, false, true) standGull(344, 258, true) F.hen(362, 246, L.awnB, true)
for _, g in ipairs({ { 326, 254 }, { 332, 256 }, { 336, 251 }, { 352, 255 }, { 329, 250 } }) do px(g[1], g[2], L.produce.hi) end
-- a small anchor leaning on the barrels
do
  local an = union(rect(289, 204, 290, 222), rect(285, 207, 294, 208), c:ellipse(290, 202, 2, 2):cut(c:ellipse(290, 202, 1, 1)))
  an:add(line({ { 283, 217 }, { 285, 222 }, { 290, 224 }, { 295, 222 }, { 297, 217 } }, 1))
  rimOf(an, L.tar) part(an, L.iron, { nopop = true, noshade = true })
  px(283, 216, L.iron.hi) px(297, 216, L.iron.hi) vline(289, 209, 221, L.iron.hi)
  -- rust and a twist of wrack on the crown
  px(288, 223, L.produce.deep) px(292, 224, L.produce.shade) F.wrack(286, 225, 7, 3)
end
-- lobster pots and shore plants on the right, around the garden (clear of the compass corner)
lp(440, 224, 6) lp(456, 224, 6) lp(448, 214, 6)
for _, f in ipairs({ { 304, 262, 8 }, { 290, 250, 6 }, { 374, 262, 7 }, { 430, 222, 6 }, { 470, 216, 7 }, { 282, 238, 5 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(300, 240, true) F.thrift(306, 244) F.thrift(366, 254, true)
F.shell(312, 248, true) F.shell(370, 266) F.shell(286, 262, true)
-- a goat tied to the driftwood rail, chewing the rope
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
}, 106, 214, { W = L.awnB.hi, w = L.awnB.base, s = L.awnB.shade, h = L.timber.hi, k = L.tar.edge, p = L.petal.base, b = L.awnB.shade, t = L.awnB.shade, o = L.tar.deep })
for _, p in ipairs({ { 116, 219 }, { 117, 219 }, { 118, 220 }, { 122, 221 }, { 123, 221 } }) do px(p[1], p[2], L.timber.base) end
for x = 100, 106 do px(x, 218 + (x - 100) // 3, L.cork.shade) end
F.shadowM(c:ellipse(118, 228, 10, 1))
-- a black-and-white collie asleep under the table between the legs
F.sprite({
  "....bb..............",
  "...bBBb.......bb....",
  "..bWkBBBBBBBBBBBBBb.",
  ".dWWWWBBBBBBBBBBBBBb",
  "..dWWBBbbBBBBbbBBBWW",
  "...ddd...WWdWW..WWWW",
  "..........dd..dd....",
}, 362, 216, { b = L.tar.base, B = L.tar.shade, d = L.tar.deep, W = L.awnB.hi, k = L.tar.edge }, { rimCol = L.tar.edge })

F.depth(0)
F.gull(330, 52, 3) F.gull(346, 44, 2) F.gull(372, 62, 2) F.gull(200, 52, 2) F.gull(420, 84, 1) F.gull(160, 84, 1)
F.finish()
