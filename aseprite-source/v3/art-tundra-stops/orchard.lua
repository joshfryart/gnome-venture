-- orchard.lua : "Orchard" stop look, TUNDRA (tundra_frost), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua) and the forest orchard,
-- re-cast as a hardy berry orchard on the tundra: rows of sea-buckthorn bushes heavy with orange berries, low
-- creeping dwarf apples trained flat under the snow, lingonberry beds under glass bell cloches, and young trees
-- in burlap wraps behind slatted windbreaks, all running to a snow fence at the horizon.
-- Road's end: an ancient gnarled crab tree, snow on every limb, frozen red apples, waxwings, a rope swing (little gnome).
-- Back right: a lamp-lit glasshouse on a stone knee wall with a smoking stove pipe.
-- Left hero: a driftwood berry press under a snowy sod hood, sea-buckthorn juice into a bucket, a turning gnome,
-- berry heaps and crates, jars of jam and a steaming kettle on a plank table, barrels, a bed of cloches.
-- Right hero: a picker on a ladder at a big front sea-buckthorn, a canvas sheet catching berries, crates by the road,
-- a kick-sled with a basket of apples, a gnome with a lingonberry basket. An arctic fox at the windfalls.
-- Quirk (kept): a porcupine in a red gnome hat trundling off with a dwarf apple and lingonberries stuck on its quills.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-tundra-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, max, min = math.floor, math.sin, math.cos, math.pi, math.max, math.min
local S, AP, IR = L.snow, L.apple, L.iron
local BUCK = F.rp("#ffd27a #f8a030 #d8761e #a4521c #6a3418")   -- sea-buckthorn berry
local SILV = F.rp("#dfe6d8 #b2c0ac #8a9a8c #66746c #42504c")   -- sea-buckthorn silver leaf
local LING = F.rp("#ff9a8c #d8343e #a81e34 #6e1428 #440c1c")   -- lingonberry
local LINGLF = F.rp("#a4c4a0 #5e8a6c #3e6652 #2a4840 #1a2e2e") -- lingonberry glossy leaf
local GOLD = F.rp("#fff0a0 #f2cc5a #c89a34 #8c6628 #5a401c")   -- golden dwarf apple
local RUSS = F.rp("#ecc48c #c48e58 #986a42 #6a4a34 #422e26")   -- frost-russet apple leaf
local RUSS2 = F.rp("#d8c49a #ae9a6c #84744e #5e543c #3a3428") -- olive-bronze leaf
local BARK = F.rp("#b8aaa0 #8c7e78 #685c5c #4a4044 #2e2830")  -- old tree bark
local SACK = F.rp("#ecd6aa #ccae80 #a68660 #7a604a #4a3a34")  -- burlap / canvas
local CROW = F.rp("#9a8aac #5e4e78 #42365a #2c2442 #1a1428")  -- crowberry
local COPPER = F.rp("#f6c098 #d88a5a #ac6040 #7a4232 #4a2822")
local GLASS = "#e4eef6"

local function fruitDot(ax, ay, s, fr)
  if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
  else px(ax, ay, fr.base) if s > .7 then px(ax + 1, ay, fr.shade) end end
end
local function berryCluster(ax, ay, s, fr)
  -- sea-buckthorn: berries packed along a twig
  if s > 1.1 then
    for k = 0, 2 do px(ax + k, ay + (k % 2), fr.base) end
    px(ax, ay - 1, fr.hi) px(ax + 1, ay + 1, fr.shade) px(ax + 2, ay - 1, fr.hi) px(ax + 3, ay, fr.shade)
  elseif s > .7 then px(ax, ay, fr.base) px(ax + 1, ay, fr.hi)
  else px(ax, ay, fr.base) end
end

-- slatted snow fence / windbreak: thin boards with 1 px gaps (no rim, it would fill the gaps), snow on top
local function windbreak(x0, x1, yb, h, seed)
  F.obj()
  for x = x0, x1 do
    if (x - x0) % 3 ~= 2 then
      local hh = h + (hash(x, 1, seed) < .3 and 1 or 0)
      for y = yb - hh, yb do
        local v = (x - x0) % 3 == 0 and L.board.base or L.timber.hi
        if y == yb - hh then v = S.hi elseif y == yb then v = L.timber.deep elseif (x - x0) % 3 == 1 then v = (x < (x0 + x1) / 2) and L.board.shade or L.timber.base end
        px(x, y, v)
      end
    end
  end
  if h > 5 then hline(x0, x1, yb - h + 2, L.timber.shade) hline(x0, x1, yb - 2, L.timber.shade) end
  for x = x0, x1, 9 do vline(x, yb - h - 1, yb, L.timber.deep) end
end

-- a glass bell cloche over a lingonberry plant (glass = the inside colours mixed with a cool tint)
local function cloche(x, yb, r, seed, tilt)
  local rh = floor(r * 1.25 + .5)
  local dome = c:ellipse(x, yb, r, rh):clip(rect(x - r - 1, yb - rh - 1, x + r + 1, yb))
  -- the plant inside
  local plant = c:ellipse(x, yb - 1, max(1, r - 1), max(1, floor(r * .7)))
  plant:each(function(xx, yy) local v = hash(xx, yy, seed) px(xx, yy, v < .25 and LINGLF.hi or (v < .7 and LINGLF.base or LINGLF.shade)) end)
  for i = 1, max(2, r) do px(x + floor((hash(i, seed, 2) - .5) * 2 * (r - 1)), yb - 1 - floor(hash(i, seed, 3) * r * .7), LING.base) end
  c:rim(dome, L.ice.edge)
  dome:each(function(xx, yy)
    local v = c:get(xx, yy) or S.base
    if plant:has(xx, yy) then px(xx, yy, F.mix(v, GLASS, .32)) else px(xx, yy, F.mix(S.shade, GLASS, .55)) end
  end)
  dome:each(function(xx, yy)
    if not dome:has(xx - 1, yy) or not dome:has(xx, yy - 1) then
      if xx < x and yy < yb - 1 then px(xx, yy, L.ice.hi) else px(xx, yy, L.ice.shade) end
    elseif not dome:has(xx + 1, yy) then px(xx, yy, L.ice.deep) end
  end)
  if r > 2 then px(x - floor(r * .5), yb - floor(rh * .6), "#f6fafc") px(x - floor(r * .5), yb - floor(rh * .6) + 1, L.ice.hi) end
  px(x, yb - rh - 1, L.ice.shade) if r > 3 then px(x, yb - rh - 2, L.ice.deep) end -- knob
  -- snow banked at the foot, a frost cap
  hline(x - r - 1, x + r + 1, yb, S.hi) px(x + r + 1, yb, S.shade) px(x + r + 2, yb, S.deep)
  if r > 3 then hline(x - 1, x + 1, yb - rh, S.hi) end
  return dome
end

-- orchard plants in four kinds so the rows never repeat one shape:
--   1 sea-buckthorn bush (twiggy stems, silver crown, packed orange berries), 2 creeping dwarf apple trained flat
--   (low limbs, flat russet crown under a heavy snow load, red / gold apples hanging under it), 3 lingonberry bed
--   under glass cloches in a driftwood frame, 4 young tree in a burlap wrap behind a slatted windbreak.
local function orchardTree(x, yb, s, seed, kind)
  kind = kind or (seed % 4) + 1
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  if kind == 1 then
    local st = HP.mask()
    for k = -2, 2 do st:add(line({ { x + k * s * .6, yb }, { x + k * 4 * s + lean * .5, yb - 16 * s } }, max(1, floor(s * .8)))) end
    F.shadow(floor(x - 6 * s), floor(x + 6 * s), yb + 1, floor(5 * s), floor(1 + s))
    st:each(function(xx, yy) px(xx, yy, st:has(xx - 1, yy) and BARK.shade or (hash(xx, yy // 2, seed) < .4 and BARK.deep or BARK.base)) end)
    local cr = union(
      F.crown(x - 7 * s, yb - 19 * s, 7 * s, 8 * s, SILV, seed),
      F.crown(x + 7 * s, yb - 20 * s, 7 * s, 8 * s, SILV, seed + 1),
      F.crown(x + lean, yb - 27 * s, 8 * s, 8 * s, SILV, seed + 2))
    -- twigs poking out of the crown top
    if s > .6 then for i = 1, floor(5 * s) do local tx = floor(x + (hash(i, seed, 7) - .5) * 22 * s) local ty = yb - floor(28 * s) - 2
      for k = 0, floor(3 * s) do if not cr:has(tx, ty - k + floor(4 * s)) then px(tx + (k > 1 and 1 or 0), ty - k + floor(4 * s), BARK.shade) end end end end
    for i = 1, floor(16 * s * s) + 5 do
      local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2)) * .95
      berryCluster(floor(x + cos(a) * rr * 13 * s), floor(yb - 22 * s + sin(a) * rr * 10 * s), s, BUCK)
    end
    F.snowCap(cr, max(1, floor(1.6 * s)), seed + 3)
  elseif kind == 2 then
    local tr = poly{ { x - 2 * s, yb }, { x - 1 * s, yb - 6 * s }, { x + 1 * s, yb - 6 * s }, { x + 2 * s, yb } }
    local w2 = max(1, floor(1.5 * s))
    local brs = line({ { x, yb - 5 * s }, { x - 9 * s, yb - 8 * s }, { x - 17 * s, yb - 7 * s } }, w2)
      :add(line({ { x, yb - 5 * s }, { x + 9 * s, yb - 9 * s }, { x + 17 * s, yb - 7 * s } }, w2))
    F.shadow(floor(x - 16 * s), floor(x + 16 * s), yb + 1, floor(4 * s), floor(1 + s * .6))
    rimOf(union(tr, brs), BARK) part(tr, BARK, { nopop = true }) part(brs, BARK, { nopop = true, noshade = true })
    -- forked props under the long limbs
    if s > .8 then for _, d in ipairs({ -13, 13 }) do vline(floor(x + d * s), floor(yb - 7 * s), yb, L.timber.base) px(floor(x + d * s) - 1, floor(yb - 8 * s), L.timber.base) px(floor(x + d * s) + 1, floor(yb - 8 * s), L.timber.base) end end
    local lr = (seed % 2 == 0) and RUSS or RUSS2
    -- separate flat clumps along the limbs, so the limbs show between them (not one cap)
    local cr = union(
      F.crown(x - 13 * s, yb - 10 * s, 6 * s, 3.5 * s, lr, seed),
      F.crown(x - 4 * s, yb - 12 * s, 6 * s, 4 * s, lr, seed + 1),
      F.crown(x + 6 * s, yb - 13 * s, 6 * s, 4 * s, lr, seed + 2),
      F.crown(x + 14 * s, yb - 10 * s, 5 * s, 3.5 * s, lr, seed + 3))
    for i = 1, floor(8 * s * s) + 3 do
      local fr = (hash(i, seed, 4) < .35) and GOLD or AP
      local ax = floor(x + (hash(i, seed, 1) - .5) * 34 * s)
      local ay = floor(yb - 8 * s - hash(i, seed, 2) * 4 * s)
      fruitDot(ax, ay, s, fr)
    end
    F.snowCap(cr, max(2, floor(3 * s)), seed + 5, { lip = s > .9 })
    if s > 1 then F.icicles(floor(x - 18 * s), floor(x + 18 * s), floor(yb - 7 * s), 3, seed, .12) end
  elseif kind == 3 then
    local bw = floor(15 * s)
    local frame = rect(x - bw, yb - max(1, floor(2 * s)), x + bw, yb)
    F.shadow(x - bw, x + bw, yb + 1, floor(3 * s), 1)
    rimOf(frame, L.timber) part(frame, L.timber, { nopop = true, noshade = true }) hline(x - bw, x + bw, frame:bbox() and yb - max(1, floor(2 * s)) or yb, S.hi)
    local r = max(2, floor(4 * s))
    local n = s > .8 and 3 or 2
    for k = 0, n - 1 do
      local cx = floor(x - bw + (k + .5) * (2 * bw) / n)
      cloche(cx, yb - max(1, floor(2 * s)) - 1, r, seed + k)
    end
  else
    local tr = rect(floor(x), floor(yb - 14 * s), floor(x + max(1, s * .8)), yb)
    local stake = rect(floor(x + 3 * s), floor(yb - 12 * s), floor(x + 3 * s), yb)
    windbreak(floor(x - 9 * s), floor(x - 4 * s), yb - 1, floor(9 * s) + 1, seed)
    F.shadow(floor(x - 2 * s), floor(x + 3 * s), yb + 1, floor(3 * s), 1)
    rimOf(union(tr, stake), L.timber) part(tr, BARK, { nopop = true, noshade = true }) part(stake, L.board, { nopop = true, noshade = true })
    local cr = F.crown(x, yb - 18 * s, 6 * s, 5 * s, (seed % 2 == 0) and SILV or RUSS, seed)
    if s > .7 then
      local wrap = rect(floor(x - 1 * s), floor(yb - 8 * s), floor(x + 1 * s + 1), yb)
      rimOf(wrap, SACK) fill(wrap, SACK.base)
      wrap:each(function(xx, yy) if (yy + xx) % 3 == 0 then px(xx, yy, SACK.shade) elseif (yy - xx) % 4 == 0 then px(xx, yy, SACK.hi) end end)
      hline(floor(x - 1 * s), floor(x + 1 * s + 1), floor(yb - 6 * s), L.awnA.shade) -- twine
    end
    for i = 1, 3 do fruitDot(floor(x + (hash(i, seed, 1) - .5) * 8 * s), floor(yb - 18 * s + (hash(i, seed, 2) - .2) * 5 * s), s, (seed % 2 == 0) and BUCK or AP) end
    F.snowCap(cr, max(1, floor(1.5 * s)), seed + 7)
  end
end

---------------------------------------------------------------- packed paths, snow fence at the far end
local rows = {}
for k = 0, 5 do
  local t = k / 5
  local y = floor(122 + t * t * 70)
  local s = .45 + t * t * .75
  rows[#rows + 1] = { F.xl(y) - 18 - 60 * t, y, s }
  rows[#rows + 1] = { F.xr(y) + 18 + 60 * t, y, s }
  rows[#rows + 1] = { F.xl(y) - 70 - 110 * t, y + 2, s }
  rows[#rows + 1] = { F.xr(y) + 70 + 110 * t, y + 2, s }
end
-- trodden picking paths (wind-packed, bright, a little lichen showing) between the rows
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do
      if not F.roadM:has(x, y) then
        local v = hash(x // 3, y, 91)
        if v < .5 then px(x, y, S.hi) elseif v < .56 then px(x, y, L.tLichen[min(4, 1 + d // 30)]) elseif v < .6 then px(x, y, L.tMoss[min(4, 1 + d // 30)]) end
      end
    end
  end
end
-- under each row: a lilac trough and a scatter of bare lichen / bearberry
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 18, 461 do
    if not F.roadM:has(x, y + 1) then
      local v = hash(x, y, 92)
      if v < .45 then px(x, y + 1, L.ground.shade) px(x, y + 2, F.mix(L.ground.shade, L.ground.base, .5))
      elseif v < .52 then px(x, y + 1, L.tRust[min(4, 1 + (y - 108) // 30)]) end
    end
  end
end
F.depth(1)
windbreak(20, 196, 119, 4, 11)
windbreak(284, 400, 119, 4, 12)
F.drift(150, 122, 30, 3, 21) F.drift(330, 122, 26, 3, 22)

F.depth(2)
---------------------------------------------------------------- ancient crab tree at the road's end (farthest, drawn first)
local function oldTree()
  local tr = poly{ { 226, 126 }, { 232, 110 }, { 236, 98 }, { 230, 84 }, { 250, 84 }, { 246, 98 }, { 249, 110 }, { 254, 126 } }
  local roots = poly{ { 218, 127 }, { 230, 119 }, { 232, 127 } }:add(poly{ { 248, 127 }, { 252, 118 }, { 262, 127 } })
  local limbs = {
    { { 236, 90 }, { 222, 78 }, { 206, 72 }, { 194, 64 } }, { { 246, 88 }, { 260, 76 }, { 276, 70 }, { 288, 60 } },
    { { 240, 86 }, { 236, 70 }, { 240, 52 } }, { { 222, 78 }, { 216, 62 }, { 218, 50 } }, { { 260, 76 }, { 264, 60 }, { 260, 46 } },
    { { 206, 72 }, { 196, 76 } }, { { 276, 70 }, { 286, 74 } },
  }
  local brs = HP.mask()
  for i, l in ipairs(limbs) do brs:add(line(l, i <= 2 and 3 or 2)) end
  F.shadow(222, 262, 128, 10, 3)
  local all = union(tr, roots, brs)
  rimOf(all, BARK) part(tr, BARK) part(roots, BARK, { nopop = true }) part(brs, BARK, { nopop = true })
  -- deep fissured bark, grey lichen crust, a gnarl
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 or ((x + y // 3) % 6 == 0 and y > 100) then px(x, y, BARK.deep) end end)
  tr:each(function(x, y) if x > 245 and hash(x // 2, y // 2, 61) < .45 then px(x, y, hash(x, y, 62) < .5 and L.greyMoss.base or L.lichen.shade) end end)
  local knot = c:ellipse(240, 104, 3, 2) fill(knot, BARK.edge) px(239, 103, BARK.deep)
  -- the crown: snow-loaded clumps of russet leaf along the limbs, with fine twigs out past them
  local crowns = {
    { 200, 64, 15, 9, RUSS, 51 }, { 282, 62, 15, 9, RUSS2, 52 }, { 240, 46, 22, 12, RUSS, 53 }, { 216, 48, 14, 9, RUSS2, 54 },
    { 264, 44, 14, 9, RUSS, 55 }, { 226, 70, 13, 7, RUSS2, 56 }, { 256, 70, 14, 7, RUSS, 57 }, { 240, 62, 12, 7, RUSS2, 58 },
  }
  local twigs = HP.mask()
  for i = 1, 26 do
    local a = -pi * (.05 + .9 * hash(i, 1, 58))
    local bx, by = 240 + floor(cos(a) * 44), 66 + floor(sin(a) * 24)
    twigs:add(line({ { bx, by }, { bx + floor(cos(a) * 6), by + floor(sin(a) * 5) }, { bx + floor(cos(a + .5) * 9), by + floor(sin(a + .5) * 7) } }))
  end
  twigs:each(function(x, y) px(x, y, hash(x, y, 59) < .5 and BARK.shade or BARK.deep) end)
  local cm = HP.mask()
  for _, k in ipairs(crowns) do cm:add(F.crown(k[1], k[2], k[3], k[4], k[5], k[6])) end
  F.snowCap(cm, 3, 60, { cx = 236, lip = true })
  brs:each(function(x, y) if not brs:has(x, y - 1) and not cm:has(x, y) and hash(x, y, 63) < .7 then px(x, y - 1, S.hi) end end)
  F.icicles(198, 290, 74, 4, 64, .12)
  -- frozen red apples and a few gold ones still hanging
  for i = 1, 52 do
    local ax, ay = 188 + floor(hash(i, 3, 1) * 104), 36 + floor(hash(i, 4, 1) * 44)
    if (ax - 240) ^ 2 / 2600 + (ay - 60) ^ 2 / 520 < 1 then
      local fr = (i % 6 == 0) and GOLD or AP
      fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
      if hash(i, 5, 1) < .4 then px(ax, ay - 1, BARK.deep) end
    end
  end
  -- waxwings feeding in the crown
  for _, w in ipairs({ { 206, 56 }, { 268, 54 }, { 248, 38 } }) do
    F.sprite({ "..c...", ".cWWk.", "WWWWWW", ".wWrWy", "..ww.y" }, w[1], w[2], { c = "#c4a088", W = "#d8b8a4", w = "#a48a84", k = L.timber.edge, r = AP.base, y = L.gold.base })
  end
  -- rope swing
  vline(216, 74, 112, SACK.deep) vline(228, 76, 112, SACK.deep)
  for y = 78, 110, 4 do px(216, y, SACK.base) px(228, y + 2, SACK.base) end
  local seat = rect(214, 112, 230, 114) rimOf(seat, L.timber) part(seat, L.board, { nopop = true }) hline(214, 230, 112, S.hi)
  F.gnome(222, 112, { small = true, hat = L.awnA, coat = L.accent, noShadow = true }) -- a little one swinging
end
oldTree()
table.sort(rows, function(a, b) return a[2] < b[2] end)
for i, r in ipairs(rows) do
  F.depth(r[2] < 140 and 1 or (r[2] < 170 and 2 or 3))
  local x = floor(r[1])
  if x > 0 and x < 480 and not (x > 370 and r[2] > 175) then
    orchardTree(x, r[2], r[3], i * 7 + 1, (i * 3 + x // 50) % 4 + 1)
  end
end
-- two dark spruces as a shelter belt behind the far rows
F.depth(1)
F.tree(150, 124, 40, 1) F.tree(338, 122, 42, 5)

---------------------------------------------------------------- back-right: the lamp-lit glasshouse
local function glasshouse()
  local x0, x1, yb = 404, 462, 140
  local knee = rect(x0, 128, x1, yb)
  local walls = rect(x0, 108, x1, 127)
  local roofM = poly{ { x0 - 2, 108 }, { 433, 90 }, { x1 + 2, 108 } }
  local pipe = rect(452, 80, 454, 100)
  F.shadow(x0, x1, yb + 1, 8, 3)
  rimOf(union(knee, walls, roofM, pipe), L.timber)
  part(knee, L.stone, { nopop = true }) F.rubble(knee, L.stone, 128, 4, 31)
  -- warm inside: lamp glow, potted dwarf trees and berry bushes
  local glassM = union(walls, roofM)
  glassM:each(function(x, y)
    local g = y > 116 and L.glow.base or (y > 104 and L.glow.hi or "#f4e8cc")
    px(x, y, F.mix(g, GLASS, .35))
  end)
  for _, p in ipairs({ { 412, 127, 5 }, { 426, 127, 6 }, { 442, 127, 5 }, { 455, 127, 4 } }) do
    local m = c:ellipse(p[1], p[2] - p[3] - 3, p[3], p[3] - 1)
    m:each(function(x, y) local v = hash(x, y, 33) px(x, y, F.mix(v < .3 and LINGLF.base or LINGLF.shade, GLASS, .3)) end)
    fill(rect(p[1] - 2, p[2] - 3, p[1] + 2, p[2]), F.mix(L.wall2.base, GLASS, .3))
    for k = 1, 3 do px(p[1] + floor((hash(k, p[1], 34) - .5) * 2 * p[3]), p[2] - p[3] - 3 + floor((hash(k, p[1], 35) - .5) * p[3]), (p[1] % 2 == 0) and BUCK.base or AP.base) end
  end
  -- mullions and glazing bars
  for x = x0, x1, 6 do vline(x, 108, 127, L.timber.base) end
  hline(x0, x1, 117, L.timber.base) hline(x0, x1, 108, L.timber.shade) hline(x0, x1, 127, L.timber.deep)
  roofM:each(function(x, y) if (x - x0) % 6 == 0 then px(x, y, L.timber.base) end end)
  line({ { x0 - 2, 108 }, { 433, 90 } }):each(function(x, y) px(x, y, L.timber.hi) end)
  -- pane glints
  for x = x0 + 2, x1 - 4, 6 do px(x, 110, "#fbf6ea") px(x + 1, 111, "#fbf6ea") px(x, 119, L.glow.hi) end
  -- snow sits on the roof bars and the ridge, slides off the glass, piles at the foot
  roofM:each(function(x, y) if not roofM:has(x, y - 1) and (x < 425 or hash(x, y, 36) < .6) then px(x, y, S.hi) px(x, y + 1, x < 433 and S.base or S.shade) end end)
  F.icicles(x0, x1, 109, 3, 37, .3)
  part(pipe, IR, { nopop = true }) hline(451, 455, 80, IR.deep) hline(451, 455, 79, S.hi)
  F.smoke(453, 76, 6, .7, false)
  F.drift(412, 141, 10, 3, 38) F.drift(452, 141, 12, 4, 39)
  -- door on the left end
  local d = rect(406, 120, 412, 139) fill(d, L.timber.edge) fill(rect(407, 121, 411, 139), F.mix(L.glow.shade, GLASS, .25)) px(410, 130, L.gold.hi)
end
glasshouse()

---------------------------------------------------------------- left hero: driftwood berry press under a sod hood
F.depth(2)
F.birch(198, 182, 40, 45)
F.depth(3)
local function press(x0, yb)
  local posts = rect(x0, yb - 52, x0 + 4, yb):add(rect(x0 + 46, yb - 52, x0 + 50, yb))
  local beam = rect(x0 - 4, yb - 56, x0 + 54, yb - 50)
  local screw = rect(x0 + 23, yb - 50, x0 + 27, yb - 28)
  local bar = rect(x0 + 6, yb - 42, x0 + 44, yb - 40)
  local plate = rect(x0 + 10, yb - 28, x0 + 40, yb - 24)
  local tub = poly{ { x0 + 6, yb - 24 }, { x0 + 44, yb - 24 }, { x0 + 42, yb - 6 }, { x0 + 8, yb - 6 } }
  local base = rect(x0 - 4, yb - 6, x0 + 54, yb)
  local spout = rect(x0 + 52, yb - 10, x0 + 60, yb - 8)
  local roofM = poly{ { x0 - 10, yb - 56 }, { x0 + 25, yb - 72 }, { x0 + 60, yb - 56 } }
  F.shadow(x0, x0 + 56, yb, 10, 4)
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout, roofM), L.timber)
  part(roofM, L.roof, { sep = true }) F.sod(roofM, L.roof, yb - 72, x0 + 25)
  F.snowCap(roofM, 4, 81, { cx = x0 + 25, lip = true })
  F.icicles(x0 - 8, x0 + 58, yb - 55, 5, 82, .4)
  part(posts, L.timber) F.planks(posts, L.timber, 5, true, 83)
  part(beam, L.timber) F.planks(beam, L.timber, 3, false, 84)
  part(screw, IR, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, IR.deep) px(x0 + 23, y + 1, IR.hi) end
  part(bar, L.board, { nopop = true }) part(plate, L.board)
  part(tub, L.board) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 7, L.board.deep) end
  hline(x0 + 7, x0 + 43, yb - 20, IR.shade) hline(x0 + 8, x0 + 42, yb - 10, IR.shade)
  -- orange pulp squeezing out under the plate
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, BUCK.shade) if x % 4 == 1 then px(x, yb - 22, BUCK.base) end end
  part(base, L.timber, { nopop = true }) F.planks(base, L.timber, 3, false, 85) hline(x0 - 4, x0 + 54, yb - 6, S.hi)
  part(spout, L.timber, { nopop = true })
  -- sea-buckthorn juice pouring into a bucket
  vline(x0 + 60, yb - 7, yb + 4, BUCK.base) vline(x0 + 61, yb - 7, yb + 4, BUCK.hi)
  local bk = poly{ { x0 + 54, yb + 4 }, { x0 + 68, yb + 4 }, { x0 + 66, yb + 14 }, { x0 + 56, yb + 14 } }
  rimOf(bk, L.timber) part(bk, L.board) hline(x0 + 55, x0 + 67, yb + 5, BUCK.base) hline(x0 + 56, x0 + 66, yb + 6, BUCK.shade) hline(x0 + 55, x0 + 67, yb + 8, IR.shade)
  -- a little drip of amber icicle off the spout
  px(x0 + 59, yb - 7, BUCK.hi) px(x0 + 58, yb - 7, BUCK.shade)
end
press(92, 206)
local _, tx, ty = F.gnome(80, 210, { hat = L.lav, coat = L.wall2, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.board.base)
-- heaps of frozen berries beside the press, rimed with frost
local function heap(x0, x1, yb, fr)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  m:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, fr.hi) elseif k == 3 then px(x, y, fr.shade) end
    if hash(x, y, 87) < .08 then px(x, y, S.hi) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), SILV.base) px(x + 1, yb - 9 + (x % 3), SILV.hi) end
  F.snowCap(m, 1, x0)
end
heap(30, 84, 214, BUCK)
heap(18, 44, 206, LING)
F.crate(24, 232, 22, 12, BUCK) F.crate(50, 234, 22, 12, LING) F.crate(36, 220, 22, 10, GOLD)
-- plank table: jars of jam and juice, a copper kettle steaming on a little stove
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 6, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true }) hline(118, 182, 226, S.hi)
for k = 0, 3 do
  local x = 126 + k * 11
  local jr = ({ BUCK, LING, CROW, GOLD })[k + 1]
  local jar = c:rrect(x - 4, 214, x + 4, 225, 2)
  rimOf(jar, L.ice) fill(jar, jr.base)
  jar:each(function(xx, yy) if yy < 217 then px(xx, yy, F.mix(jr.hi, GLASS, .5)) elseif xx > x + 2 then px(xx, yy, jr.shade) end end)
  vline(x - 3, 218, 223, F.mix(jr.hi, GLASS, .6)) px(x - 2, 219, "#f6fafc")
  -- cloth lid with twine
  fill(rect(x - 4, 211, x + 4, 213), (k % 2 == 0) and L.awnA.base or SACK.base) hline(x - 4, x + 4, 211, (k % 2 == 0) and L.awnA.hi or SACK.hi) hline(x - 3, x + 3, 213, L.timber.deep)
end
local stove = rect(166, 216, 178, 225)
rimOf(stove, IR) part(stove, IR, { nopop = true }) fill(rect(169, 220, 175, 223), L.glow.shade) hline(170, 174, 221, L.glow.base)
local kettle = c:ellipse(172, 210, 5, 4):add(rect(176, 207, 180, 208))
rimOf(kettle, COPPER) part(kettle, COPPER) hline(170, 174, 205, COPPER.deep) px(169, 208, COPPER.hi) px(170, 207, "#fbe6d4")
F.steam(181, 204, 6, .5, 41)
F.barrel(196, 250, L.timber, 14) F.barrel(186, 262, L.board, 12)
hline(191, 201, 236, S.hi) hline(181, 191, 250, S.hi)
-- a bed of lingonberry cloches in the near left, one lifted off and lying on its side
local bed = rect(20, 252, 112, 255)
rimOf(bed, L.timber) part(bed, L.timber, { nopop = true, noshade = true }) F.planks(bed, L.timber, 7, true, 42) hline(20, 112, 252, S.hi)
for k, cx in ipairs({ 30, 50, 70, 98 }) do cloche(cx, 251, 7, 40 + k) end
-- the uncovered plant between them, berries showing, and the lifted cloche on the snow
local up = c:ellipse(84, 250, 6, 3) up:each(function(x, y) local v = hash(x, y, 47) px(x, y, v < .3 and LINGLF.hi or (v < .7 and LINGLF.base or LINGLF.shade)) end)
for i = 1, 7 do fill(rect(79 + floor(hash(i, 1, 48) * 10), 248 + floor(hash(i, 2, 48) * 3), 79 + floor(hash(i, 1, 48) * 10), 248 + floor(hash(i, 2, 48) * 3)), LING.base) end
px(82, 248, LING.hi) px(86, 247, LING.hi)
F.willow(14, 234, 6, 8, 43)

---------------------------------------------------------------- right hero: picker on a ladder at a big front sea-buckthorn
orchardTree(408, 226, 2.3, 77, 1)
-- canvas sheet spread under the bush to catch beaten berries
local sheet = poly{ { 382, 222 }, { 446, 220 }, { 450, 229 }, { 378, 229 } }:cut(rect(398, 200, 418, 227))
rimOf(sheet, SACK) fill(sheet, SACK.hi)
sheet:each(function(x, y) if (x + y * 3) % 11 == 0 then px(x, y, SACK.base) end if y == 228 then px(x, y, SACK.shade) end
  if hash(x, y, 49) < .12 then px(x, y, BUCK.base) elseif hash(x, y, 50) < .03 then px(x, y, BUCK.hi) end end)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
for k = 0, 8 do local t = k / 8 lad:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(lad, L.timber) part(lad, L.board, { nopop = true, noshade = true })
for k = 0, 8 do local t = k / 8 px(floor(353 + 18 * t), floor(235 - 68 * t), S.hi) end
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.accent, arm = "up", noShadow = true })
berryCluster(phx - 1, phy - 2, 1.2, BUCK)
local bas = poly{ { 368, 186 }, { 380, 186 }, { 378, 194 }, { 370, 194 } } rimOf(bas, SACK) part(bas, SACK)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, SACK.shade) end end)
for k = 0, 4 do fill(rect(369 + k * 2, 184, 370 + k * 2, 185), BUCK.base) px(369 + k * 2, 184, BUCK.hi) end
-- crates by the road (right), snow on the lids' rims
F.crate(290, 226, 22, 12, BUCK) F.crate(314, 228, 22, 12, AP) F.crate(300, 213, 22, 11, LING)
-- a gnome carrying a basket of lingonberries
local _, ghx, ghy = F.gnome(336, 256, { hat = L.roof2, coat = L.wall2, arm = "out", flip = true })
local lb = poly{ { ghx - 6, ghy - 1 }, { ghx + 2, ghy - 1 }, { ghx + 1, ghy + 4 }, { ghx - 5, ghy + 4 } }
rimOf(lb, SACK) part(lb, SACK, { nopop = true })
for xx = ghx - 5, ghx + 1, 2 do px(xx, ghy - 2, LING.base) px(xx + 1, ghy - 2, LING.shade) px(xx, ghy - 3, LING.hi) end
-- a kick-sled with a basket of dwarf apples on its seat
local function kicksled(x0, yb)
  local run = line({ { x0, yb }, { x0 + 44, yb } }):add(line({ { x0 + 44, yb }, { x0 + 48, yb - 3 }, { x0 + 47, yb - 6 } }))
  local run2 = line({ { x0 + 3, yb - 2 }, { x0 + 40, yb - 2 } })
  local up = line({ { x0 + 4, yb - 2 }, { x0 + 6, yb - 24 } }, 2):add(line({ { x0 + 3, yb - 24 }, { x0 + 9, yb - 24 } }, 2))
  local seat = rect(x0 + 20, yb - 12, x0 + 34, yb - 10)
  local legs = rect(x0 + 21, yb - 9, x0 + 22, yb - 2):add(rect(x0 + 32, yb - 9, x0 + 33, yb - 2))
  local back = line({ { x0 + 20, yb - 11 }, { x0 + 18, yb - 20 } }, 2)
  F.shadow(x0, x0 + 46, yb + 1, 6, 2)
  rimOf(union(run, up, seat, legs, back), L.timber)
  part(run, IR, { nopop = true, noshade = true }) hline(x0, x0 + 44, yb, IR.hi)
  run2:each(function(x, y) px(x, y, IR.shade) end)
  part(up, L.wall2, { nopop = true, noshade = true }) part(back, L.wall2, { nopop = true, noshade = true })
  part(seat, L.wall2, { nopop = true }) part(legs, L.wall2, { nopop = true, noshade = true })
  local bk = poly{ { x0 + 21, yb - 21 }, { x0 + 35, yb - 21 }, { x0 + 33, yb - 13 }, { x0 + 23, yb - 13 } }
  rimOf(bk, SACK) part(bk, SACK)
  bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, SACK.shade) elseif (x - y) % 5 == 0 then px(x, y, SACK.hi) end end)
  for x = x0 + 22, x0 + 33, 3 do local fr = (x % 2 == 0) and AP or GOLD fill(rect(x, yb - 24, x + 1, yb - 22), fr.base) px(x, yb - 24, fr.hi) px(x + 1, yb - 22, fr.shade) end
end
kicksled(268, 260)
F.tracks({ { 256, 262 }, { 230, 268 } }, "boot", 5)

---------------------------------------------------------------- frozen windfalls, tracks, an arctic fox
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 3 == 0) and BUCK or ((i % 3 == 1) and LING or AP)
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, S.hi) end
end
F.tracks({ { 40, 196 }, { 70, 186 }, { 100, 184 } }, "hare", 7)
F.tracks({ { 140, 196 }, { 176, 192 } }, "bird", 4)
for _, w in ipairs({ { 116, 190, 5, 6 }, { 270, 196, 5, 6 }, { 458, 206, 6, 7 } }) do F.willow(w[1], w[2], w[3], w[4], w[1]) end
-- an arctic fox nosing at the windfalls under the far-left bushes
F.sprite({
  "..k.k.........",
  ".kFFFk......ww",
  "kFeFFFFFFFFwWW",
  "nFFFFFFFFFFFWW",
  ".kFfFFFFFFFf..",
  "..F.F...F.F...",
}, 38, 159, { F = L.fur.hi, f = L.fur.shade, w = L.fur.shade, W = L.fur.base, k = L.fur.deep, e = L.timber.edge, n = L.timber.edge })
for _, a in ipairs({ { 30, 165 }, { 34, 167 }, { 56, 166 } }) do px(a[1], a[2], LING.base) px(a[1] + 1, a[2], LING.shade) px(a[1], a[2] - 1, S.hi) end
-- waxwings pecking frozen berries by the road
F.sprite({ "..c...", ".cWWk.", "WWWWWW", ".wWrWy", "..ww.y" }, 180, 188, { c = "#c4a088", W = "#d8b8a4", w = "#a48a84", k = L.timber.edge, r = AP.base, y = L.gold.base })
F.sprite({ "...c..", ".kWWc.", "WWWWWW", "yWrWw.", "y.ww.." }, 160, 194, { c = "#c4a088", W = "#d8b8a4", w = "#a48a84", k = L.timber.edge, r = AP.base, y = L.gold.base })
px(178, 194, BUCK.base) px(177, 194, BUCK.shade) px(168, 199, LING.base)

---------------------------------------------------------------- quirk: a porcupine in a red gnome hat, apple and lingonberries on its quills
F.shadowM(c:ellipse(222, 263, 13, 1))
F.sprite({
  "...................R....",
  "..........aaa.....RRr...",
  ".....t.t.aAaaa...RRRr...",
  "...t.QtQtaaaaat.RRRRRr..",
  "..tQtQqQqaaaaQtqhhhhhhh.",
  ".tQqQlQqQqQqQqQqffffff..",
  "tQqQqQqQqlQqQqQqffefff..",
  "QqQqlqQqQqQqQqQqfffffnn.",
  "qqQqQqQqQqQqQqQqqffff...",
  ".qqqqqqqqqqqqqqqqqf.....",
  "...dd........dd..dd.....",
}, 200, 252, { a = AP.base, A = AP.hi, q = L.soil.deep, Q = L.soil.shade, t = L.fur.hi, l = LING.base, R = L.awnA.base, r = L.awnA.shade, h = L.awnA.deep,
  f = L.deer.shade, e = L.timber.edge, n = L.timber.edge, d = L.timber.edge })
F.depth(0)
F.birds({ { 330, 40, 2 }, { 120, 48, 2 }, { 132, 42, 1 } })
F.finish()
