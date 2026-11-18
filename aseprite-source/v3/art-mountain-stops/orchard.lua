-- orchard.lua : "Orchard" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold orchard (art-2701-batch3/stops/opus3/orchard.lua), re-cast as a high-valley
-- terraced orchard: rows of hardy fruit and nut trees on dry-stone terraces running up to the snow peaks
-- (round red / gold apples, tall pears, broad grey-barked walnuts with green husks, silvery sea-buckthorn bushes
-- crusted with orange berries, slim rowans with scarlet umbels, young staked trees in little stone rings), a larch
-- or an arolla pine standing in among the rows. Grass rides between the rows, a lichened wall under every terrace.
-- Road's end: a great old lichened apple tree in a round dry-stone bed, a pygmy owl in its hollow and a rope swing
-- (a little gnome). Back right: a stone press-house (whitewashed granite, larch gable, weighted slab roof, smoking
-- chimney, drying pear rings), a ladder and baskets. Left hero: a screw press on a granite press-bed under a slab hood,
-- juice running into a bucket, a turning gnome, heaps and crates, a basket of walnuts, stoneware jugs and a glass of
-- sea-buckthorn juice on a plank table, barrels. Right hero: a picker on a ladder at a big front apple tree, a basket,
-- crates by the road, a gnome bringing a basket of sea-buckthorn, a barrow of apples. A goat and kid at the windfalls,
-- an alpine chough, a nutcracker with a walnut on the crates, a marmot on a terrace wall.
-- Quirk (kept): a hedgehog trundling off with an apple, a leaf and a sprig of rowan berries stuck on its spines.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "orchard", out = DIR, farTrees = { 24, 52, 100, 380, 410, 440 } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local AP, IR = L.apple, L.iron
-- high-valley ramps: cool greens, a yellowing pear, a turning rowan, a silvery buckthorn
local LF = F.rp("#c0d488 #90b260 #66904c #46703f #2a4632")    -- apple green (cool)
local LF2 = F.rp("#e0dc86 #b8b85a #8e9446 #626e3a #3c482a")   -- yellowing (pear)
local LF3 = F.rp("#f0b07a #d27c4a #a85a3a #763e30 #4a2626")   -- turning rowan
local LF4 = F.rp("#acc890 #7ca46c #5a8058 #3e604a #273f36")   -- deep walnut green
local SBL = F.rp("#d2dcc4 #a8b8a4 #829888 #607670 #3e5054")   -- sea-buckthorn silver
local PEAR = F.rp("#eef09a #c8d062 #9ca64c #6c763a #424a28")
local GOLD = F.rp("#f6e08a #e2b44a #b8862e #865c24 #563a1a")
local NUTG = F.rp("#d4e08e #a8bc62 #7e9a4a #5a743c #3a4c2c")  -- walnut green husk
local WAL = F.rp("#e0c494 #b8946a #8c6c4c #624a36 #3e2e24")   -- walnut shell
local BERRY = L.produce                                         -- sea-buckthorn orange
local ROW = F.rp("#ff9a6a #e8502e #b83a2a #842a26 #521c1e")   -- rowan scarlet
local WBARK = F.rp("#c6c0b4 #9e978c #7a746c #5a5652 #3a3836") -- grey walnut / old-apple bark
local WICK = F.rp("#d8b47c #b48a52 #8c683c #644a30 #3e2e22")
local CIDER = F.rp("#f6e49a #e6c058 #c0963a #8c6a2c #5a4422")

local function fruitDot(ax, ay, s, fr)
  if s > 1.1 then fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
  else px(ax, ay, fr.base) if s > .7 then px(ax + 1, ay, fr.shade) end end
end
local function berryCluster(ax, ay, s, r)
  -- a rowan umbel: a little dome of berries
  if s > .8 then
    px(ax, ay, r.hi) px(ax + 1, ay, r.base) px(ax - 1, ay + 1, r.base) px(ax, ay + 1, r.base) px(ax + 1, ay + 1, r.shade) px(ax + 2, ay + 1, r.shade)
    if s > 1.1 then px(ax, ay + 2, r.shade) px(ax + 1, ay + 2, r.deep) end
  else px(ax, ay, r.base) if s > .6 then px(ax + 1, ay, r.shade) end end
end
local function lichenTrunk(m, seed, k)
  m:each(function(x, y) if hash(x // 2, y // 2, seed) < (k or .14) then
    local v = hash(x, y, seed + 1)
    px(x, y, v < .45 and L.moss.hi or (v < .85 and L.moss.base or L.lichenOrange)) end end)
end

-- fruit and nut trees, six kinds so the rows never repeat one shape:
--   1 round apple (red or gold), 2 tall pear, 3 broad walnut (grey bark, green husks), 4 young staked tree in a
--   stone ring, 5 sea-buckthorn bush (silver, orange berries), 6 slim rowan (scarlet umbels)
local function fruitTree(x, yb, s, seed, kind)
  kind = kind or (seed % 6) + 1
  local lr = ({ LF, LF4, LF, LF2 })[(seed // 4) % 4 + 1]
  local w2 = math.max(1, floor(2 * s))
  local lean = (hash(seed, 1, 9) - .5) * 4 * s
  if kind == 1 then
    local fr = (seed % 3 == 0) and GOLD or AP
    local tr = poly{ { x - 3 * s, yb }, { x - 2 * s + lean, yb - 12 * s }, { x + 2 * s + lean, yb - 12 * s }, { x + 3 * s, yb } }
    local brs = line({ { x + lean, yb - 10 * s }, { x - 8 * s, yb - 18 * s } }, w2):add(line({ { x + lean, yb - 10 * s }, { x + 8 * s, yb - 19 * s } }, w2))
    F.shadowM(c:ellipse(x + 4 * s, yb, 13 * s, 2 * s))
    rimOf(union(tr, brs), L.timber) part(tr, L.timber, { nopop = true }) part(brs, L.timber, { nopop = true, noshade = true })
    if s > .8 then lichenTrunk(tr, seed) end
    F.crown(x - 6 * s, yb - 22 * s, 9 * s, 7 * s, lr, seed) F.crown(x + 6 * s, yb - 23 * s, 9 * s, 7 * s, lr, seed + 1) F.crown(x + lean, yb - 29 * s, 10 * s, 7 * s, lr, seed + 2)
    for i = 1, floor(9 * s * s) + 3 do local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2)) * .95 fruitDot(floor(x + cos(a) * rr * 13 * s), floor(yb - 25 * s + sin(a) * rr * 9 * s), s, fr) end
  elseif kind == 2 then
    lr = (seed % 2 == 0) and LF2 or LF
    local tr = poly{ { x - 2 * s, yb }, { x - 1 * s, yb - 14 * s }, { x + 1 * s, yb - 14 * s }, { x + 2 * s, yb } }
    F.shadowM(c:ellipse(x + 3 * s, yb, 8 * s, 2 * s))
    rimOf(tr, L.timber) part(tr, L.timber, { nopop = true })
    F.crown(x + lean * .5, yb - 24 * s, 7 * s, 10 * s, lr, seed) F.crown(x + lean, yb - 37 * s, 5 * s, 7 * s, lr, seed + 1)
    for i = 1, floor(7 * s * s) + 2 do
      local ax, ay = floor(x + (hash(i, seed, 1) - .5) * 12 * s), floor(yb - 18 * s - hash(i, seed, 2) * 22 * s)
      fruitDot(ax, ay, s, PEAR) if s > .9 then px(ax, ay - 1, PEAR.shade) end
    end
  elseif kind == 3 then
    -- walnut: a broad, high crown on a stout grey trunk with lifted limbs
    local tr = poly{ { x - 4 * s, yb }, { x - 3 * s, yb - 11 * s }, { x + 3 * s, yb - 11 * s }, { x + 4 * s, yb } }
    local brs = line({ { x, yb - 10 * s }, { x - 12 * s, yb - 18 * s } }, w2 + 1):add(line({ { x, yb - 10 * s }, { x + 12 * s, yb - 17 * s } }, w2 + 1))
    F.shadowM(c:ellipse(x + 4 * s, yb, 17 * s, 2 * s))
    rimOf(union(tr, brs), WBARK) part(tr, WBARK, { nopop = true }) part(brs, WBARK, { nopop = true, noshade = true })
    tr:each(function(xx, yy) if (xx * 3 + yy) % 7 == 0 then px(xx, yy, WBARK.shade) end end)
    if s > .6 then lichenTrunk(union(tr, brs), seed, .18) end
    F.crown(x - 12 * s, yb - 22 * s, 9 * s, 7 * s, LF4, seed) F.crown(x + 12 * s, yb - 22 * s, 9 * s, 7 * s, LF4, seed + 1) F.crown(x, yb - 29 * s, 13 * s, 9 * s, LF4, seed + 2)
    for i = 1, floor(9 * s * s) + 3 do
      local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2)
      local ax, ay = floor(x + cos(a) * rr * 19 * s), floor(yb - 25 * s + sin(a) * rr * 8 * s)
      fruitDot(ax, ay, s, NUTG)
      if s > 1 and i % 4 == 0 then px(ax + 1, ay, WAL.shade) end -- a split husk
    end
  elseif kind == 4 then
    local tr = rect(floor(x), floor(yb - 14 * s), floor(x + math.max(1, s)), yb)
    local stake = rect(floor(x + 3 * s), floor(yb - 12 * s), floor(x + 3 * s), yb)
    F.shadowM(c:ellipse(x + 3 * s, yb, 7 * s, 1 + s))
    rimOf(union(tr, stake), L.timber) part(tr, L.timber, { nopop = true, noshade = true }) part(stake, L.board, { nopop = true, noshade = true })
    F.crown(x, yb - 18 * s, 6 * s, 6 * s, (seed % 2 == 0) and LF or LF4, seed)
    if s > .7 then -- a ring of field stones round the young tree
      for k = -2, 2 do
        local sx = floor(x + k * 2 * s)
        local sy = yb + ((k == -2 or k == 2) and -1 or 0)
        px(sx, sy, L.stone.hi) px(sx + 1, sy, L.stone.base) px(sx, sy + 1, L.stone.shade) px(sx + 1, sy + 1, L.stone.deep)
      end
    end
    for i = 1, 3 do fruitDot(floor(x + (hash(i, seed, 1) - .5) * 8 * s), floor(yb - 18 * s + (hash(i, seed, 2) - .5) * 6 * s), s, (seed % 2 == 0) and AP or GOLD) end
  elseif kind == 5 then
    -- sea-buckthorn: a thorny multi-stem bush, silver leaves, crusted with orange berries
    F.shadowM(c:ellipse(x + 3 * s, yb, 11 * s, 1 + s))
    F.crown(x - 7 * s, yb - 9 * s, 7 * s, 6 * s, SBL, seed) F.crown(x + 7 * s, yb - 10 * s, 7 * s, 6 * s, SBL, seed + 1) F.crown(x + lean * .5, yb - 15 * s, 9 * s, 7 * s, SBL, seed + 2)
    for k = -1, 1 do line({ { x + k * s, yb }, { x + k * 5 * s, yb - 6 * s } }):each(function(xx, yy) px(xx, yy, (k < 0) and L.timber.base or L.timber.deep) end) end
    for i = 1, floor(22 * s * s) + 5 do
      local a, rr = hash(i, seed, 1) * 2 * pi, math.sqrt(hash(i, seed, 2))
      local ax, ay = floor(x + cos(a) * rr * 14 * s), floor(yb - 12 * s + sin(a) * rr * 7 * s)
      px(ax, ay, BERRY.base) if s > .7 then px(ax, ay - 1, BERRY.hi) px(ax + 1, ay, BERRY.shade) end
    end
  else
    -- rowan: a slim grey trunk, a light feathery crown, scarlet umbels
    local tr = poly{ { x - 1.5 * s, yb }, { x - 1 * s, yb - 16 * s }, { x + 1 * s, yb - 16 * s }, { x + 1.5 * s, yb } }
    local brs = line({ { x, yb - 14 * s }, { x - 6 * s, yb - 22 * s } }, w2 > 1 and 2 or 1):add(line({ { x, yb - 13 * s }, { x + 6 * s, yb - 21 * s } }))
    F.shadowM(c:ellipse(x + 3 * s, yb, 9 * s, 1 + s))
    rimOf(union(tr, brs), WBARK) part(tr, WBARK, { nopop = true }) part(brs, WBARK, { nopop = true, noshade = true })
    local rl = (seed % 3 == 0) and LF3 or LF
    F.crown(x - 6 * s, yb - 25 * s, 7 * s, 6 * s, rl, seed) F.crown(x + 6 * s, yb - 26 * s, 7 * s, 6 * s, rl, seed + 1) F.crown(x + lean * .4, yb - 32 * s, 7 * s, 6 * s, rl, seed + 2)
    for i = 1, floor(6 * s * s) + 3 do
      local a, rr = hash(i, seed, 1) * 2 * pi, hash(i, seed, 2)
      berryCluster(floor(x + cos(a) * rr * 11 * s), floor(yb - 27 * s + sin(a) * rr * 7 * s), s, ROW)
    end
  end
end

---------------------------------------------------------------- the rows and their terraces (back to front)
local rows, levels = {}, {}
for k = 0, 5 do
  local t = k / 5
  local y = floor(122 + t * t * 70)
  local s = .45 + t * t * .75
  levels[#levels + 1] = { y, s }
  rows[#rows + 1] = { F.xl(y) - 18 - 60 * t, y, s }
  rows[#rows + 1] = { F.xr(y) + 18 + 60 * t, y, s }
  rows[#rows + 1] = { F.xl(y) - 70 - 110 * t, y + 2, s }
  rows[#rows + 1] = { F.xr(y) + 70 + 110 * t, y + 2, s }
end
-- grass rides between the rows (short lush turf) and a darker trodden band under each row
for y = 116, 229 do
  local d = y - 108
  local band = floor(60 / d * 6)
  if band % 2 == 0 then
    for x = 18, 461 do
      if not F.roadM:has(x, y) then
        local v = hash(x // 3, y, 91)
        if v < .5 then px(x, y, L.mossGround.base) elseif v < .62 then px(x, y, L.mossGround.hi) end
      end
    end
  end
end
for _, r in ipairs(rows) do
  local y = floor(r[2])
  for x = 18, 461 do if not F.roadM:has(x, y + 1) and hash(x, y, 92) < .5 then px(x, y + 1, L.mossGround.shade) px(x, y + 2, F.mix(L.mossGround.shade, L.ground.base, .5)) end end
end
-- dry-stone terrace walls: a lit capping course with turf lipping over it, coursed stones, lichen, a shadow foot
local function terraceWall(y0, h, s, seed, x0, x1)
  local m = HP.mask()
  for x = x0, x1 do for y = y0, y0 + h do if not F.roadM:has(x, y) and not F.roadM:has(x - 1, y) and not F.roadM:has(x + 1, y) then m:set(x, y) end end end
  local bw = 3 + floor(s * 3)
  m:each(function(x, y)
    local ry = y - y0
    local row = (ry - 1) // 2
    local h2
    if ry == 0 then h2 = (hash(x // 2, y, seed) < .2) and L.moss.base or L.stone.hi
    else
      local rx = (x + row * 3 + floor(hash(row, 1, seed) * 4)) % bw
      local v = hash((x + row * 3) // bw, row, seed + 1)
      h2 = v < .3 and L.stone.hi or (v < .7 and L.stone.base or L.stone.shade)
      if rx == 0 or (s > .8 and (ry - 1) % 2 == 1 and hash(x, y, seed + 2) < .5) then h2 = L.stone.deep end
      if ry == h then h2 = (rx == 0) and L.stone.edge or L.stone.shade end
    end
    -- the wall ends against the road: a lit end stone
    if not m:has(x - 1, y) and x > x0 then h2 = L.stone.hi elseif not m:has(x + 1, y) and x < x1 then h2 = L.stone.deep end
    px(x, y, h2)
  end)
  F.lichen(m, .22, seed + 3)
  -- turf lipping over the capping course, shadow along the foot
  m:each(function(x, y)
    if y == y0 then
      if hash(x, 1, seed + 4) < .35 then px(x, y - 1, hash(x, 2, seed) < .5 and L.fern.base or L.fern.hi) end
      if s > .8 and hash(x, 3, seed + 4) < .12 then px(x, y, L.fern.shade) end
    end
    if y == y0 + h and not m:has(x, y + 1) then px(x, y + 1, L.shadow) end
  end)
  return m
end
for k = 2, #levels do
  local y, s = levels[k][1], levels[k][2]
  F.depth(y < 140 and 1 or (y < 170 and 2 or 3))
  terraceWall(y + 4, 1 + floor(s * 2.6), s, 500 + k * 7, 16, 463)
end

F.depth(2)
---------------------------------------------------------------- great old apple tree at the road's end, in a round dry-stone bed
local function oldTree()
  -- the raised round bed
  local bed = c:ellipse(240, 127, 22, 4)
  local face = rect(218, 127, 262, 131):cut(c:ellipse(240, 125, 22, 4)):clip(c:ellipse(240, 129, 23, 5))
  F.shadow(222, 266, 131, 8, 2)
  rimOf(union(bed, face), L.stone)
  fill(bed, L.mossGround.base) bed:each(function(x, y) local v = hash(x, y, 64) if v < .25 then px(x, y, L.mossGround.hi) elseif v > .8 then px(x, y, L.mossGround.shade) end end)
  face:each(function(x, y) local v = hash((x + (y % 2) * 2) // 4, y, 65)
    px(x, y, ((x + (y % 2) * 2) % 4 == 0) and L.stone.deep or (v < .35 and L.stone.hi or (v < .75 and L.stone.base or L.stone.shade))) end)
  F.lichen(face, .25, 66)
  local tr = poly{ { 226, 126 }, { 233, 104 }, { 234, 96 }, { 230, 84 }, { 250, 84 }, { 246, 96 }, { 247, 104 }, { 254, 126 } }
  local roots = poly{ { 220, 127 }, { 230, 120 }, { 232, 127 } }:add(poly{ { 248, 127 }, { 251, 119 }, { 260, 127 } })
  local brs = line({ { 236, 90 }, { 212, 70 } }, 3):add(line({ { 246, 88 }, { 270, 68 } }, 3)):add(line({ { 240, 86 }, { 238, 66 } }, 2))
  local all = union(tr, roots, brs)
  rimOf(all, WBARK) part(tr, WBARK) part(roots, WBARK, { nopop = true }) part(brs, WBARK, { nopop = true })
  -- deep fissured bark, grey-green and orange lichen on the shaded side and in the crotch
  tr:each(function(x, y) if (x * 2 + y) % 9 == 0 or ((x + y // 3) % 6 == 0 and y > 100) then px(x, y, WBARK.deep) end end)
  tr:each(function(x, y) if x > 245 and hash(x // 2, y // 2, 61) < .5 then px(x, y, hash(x, y, 62) < .6 and L.moss.base or L.moss.shade) end end)
  lichenTrunk(union(roots, brs), 63, .25)
  for _, o in ipairs({ { 232, 112 }, { 230, 117 }, { 251, 116 }, { 237, 120 } }) do px(o[1], o[2], L.lichenOrange) px(o[1] + 1, o[2], L.gold.shade) px(o[1], o[2] + 1, L.lichenOrange) end
  -- the hollow with a pygmy owl looking out
  local hol = c:ellipse(240, 101, 4, 5)
  fill(hol, L.timber.edge)
  F.sprite({ "o...o", "OoOoO", "yEoEy", "oOvOo", "owOwo", ".ooo." }, 238, 97, { o = L.chamois.base, O = L.chamois.hi, y = L.gold.hi, E = L.timber.edge, v = L.gold.base, w = L.edel.base }, { rim = false })
  F.crown(210, 62, 24, 16, LF, 51) F.crown(270, 60, 24, 16, LF4, 52) F.crown(240, 48, 30, 18, LF, 53) F.crown(240, 72, 20, 10, LF2, 54)
  for i = 1, 50 do
    local ax, ay = 188 + floor(hash(i, 3, 1) * 104), 34 + floor(hash(i, 4, 1) * 48)
    if (ax - 240) ^ 2 / 2400 + (ay - 58) ^ 2 / 500 < 1 then
      local fr = (i % 5 == 0) and GOLD or AP
      fill(rect(ax, ay, ax + 1, ay + 1), fr.base) px(ax, ay, fr.hi) px(ax + 1, ay + 1, fr.shade)
    end
  end
  -- rope swing
  vline(216, 72, 112, WICK.deep) vline(228, 74, 112, WICK.deep)
  for y = 76, 110, 4 do px(216, y, WICK.base) px(228, y + 2, WICK.base) end
  local seat = rect(214, 112, 230, 114) rimOf(seat, L.timber) part(seat, L.board, { nopop = true })
  F.gnome(222, 112, { small = true, hat = L.awnA, coat = L.accent, noShadow = true }) -- a little one swinging
end
oldTree()
table.sort(rows, function(a, b) return a[2] < b[2] end)
for i, r in ipairs(rows) do
  F.depth(r[2] < 140 and 1 or (r[2] < 170 and 2 or 3))
  local x = floor(r[1])
  if x > 0 and x < 480 and not (x > 370 and r[2] > 175) then
    if i == 13 and x > 20 and x < 460 then
      -- a larch or an arolla pine standing in the row
      F.larch(x, r[2], floor(54 * r[3]), 1 + 4 * i)
    else
      fruitTree(x, r[2], r[3], i * 7 + 1, (i * 5 + x // 50) % 6 + 1)
    end
  end
end
-- a larch and an arolla framing the far left and right rows
F.depth(1)
F.larch(150, 124, 46, 9) F.tree(338, 122, 40, 6)

---------------------------------------------------------------- back-right: the stone press-house (between the rows)
local function pressHouse()
  local top, cx, wallM, roofM = F.building{ x0 = 404, x1 = 462, yb = 140, wh = 30, rh = 22, wall = L.timber, roof = L.roof, shingle = true, chimney = true, noFrame = true, noAttic = true }
  F.planks(wallM, L.timber, 3, true, 24)
  local base = rect(404, 122, 462, 140)
  part(base, L.plaster, { nopop = true }) F.courses(base, 122, 4, 7, L.plaster)
  base:each(function(x, y) if hash(x // 3, y // 3, 26) < .1 then px(x, y, L.stone.base) end if y > 136 and hash(x, y, 27) < .3 then px(x, y, L.plaster.shade) end end)
  hline(404, 462, 121, L.timber.edge)
  F.lichen(roofM, .2, 81)
  for _, w in ipairs({ { 412, 112 }, { 426, 101 }, { 440, 101 }, { 454, 112 } }) do
    local ws = c:ellipse(w[1], w[2], 2, 1) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(w[1] - 1, w[2] - 1, L.stone.hi)
  end
  -- wide arched door standing open: the big press-tub and a barrel in the dark
  local dm = rect(420, 124, 442, 139)
  fill(rect(419, 123, 443, 139), L.timber.edge) fill(dm, L.soil.edge)
  F.barrel(426, 139, L.timber, 9)
  fill(rect(432, 132, 441, 139), L.timber.deep) hline(432, 441, 132, L.board.shade) hline(432, 441, 135, IR.deep)
  local leaf = rect(442, 124, 446, 139) rimOf(leaf, L.timber) part(leaf, L.timber, { nopop = true }) F.planks(leaf, L.timber, 2, true, 25)
  F.window(410, 127, 415, 132, L.timber)
  F.window(450, 127, 455, 132, L.timber)
  -- loft hatch with strings of drying pear rings under the eaves
  fill(rect(429, 106, 437, 113), L.timber.edge) fill(rect(430, 107, 436, 113), L.soil.deep)
  for _, sx in ipairs({ 412, 418, 448, 454 }) do
    vline(sx, 113, 119, L.timber.deep)
    for y = 114, 119, 2 do px(sx, y, PEAR.hi) px(sx + 1, y, PEAR.shade) end
  end
  F.smoke(452, 84, 5, .5, 2)
  -- a ladder leaning on the house and a stack of empty baskets
  local lad = line({ { 400, 140 }, { 408, 112 } }):add(line({ { 404, 140 }, { 412, 112 } }))
  for k = 1, 6 do local t = k / 7 lad:add(line({ { 400 + 8 * t, 140 - 28 * t }, { 404 + 8 * t, 140 - 28 * t } })) end
  c:rim(lad, L.timber.edge) fill(lad, L.board.base)
  for k = 0, 2 do
    local b = poly{ { 464 - 1, 140 - k * 3 - 4 }, { 472, 140 - k * 3 - 4 }, { 471, 140 - k * 3 }, { 464, 140 - k * 3 } }
    rimOf(b, WICK) part(b, WICK, { nopop = true })
  end
end
pressHouse()

---------------------------------------------------------------- left hero: the screw press on a granite press-bed
F.depth(2)
F.larch(198, 182, 40, 45)
F.depth(3)
local function press(x0, yb)
  local posts = rect(x0, yb - 52, x0 + 4, yb):add(rect(x0 + 46, yb - 52, x0 + 50, yb))
  local beam = rect(x0 - 4, yb - 56, x0 + 54, yb - 50)
  local screw = rect(x0 + 23, yb - 50, x0 + 27, yb - 28)
  local bar = rect(x0 + 6, yb - 42, x0 + 44, yb - 40)
  local plate = rect(x0 + 10, yb - 28, x0 + 40, yb - 24)
  local tub = poly{ { x0 + 6, yb - 24 }, { x0 + 44, yb - 24 }, { x0 + 42, yb - 7 }, { x0 + 8, yb - 7 } }
  local base = rect(x0 - 4, yb - 7, x0 + 54, yb)
  local spout = rect(x0 + 52, yb - 10, x0 + 60, yb - 8)
  local roofM = poly{ { x0 - 10, yb - 56 }, { x0 + 25, yb - 70 }, { x0 + 60, yb - 56 } }
  F.shadow(x0, x0 + 56, yb, 12, 4)
  rimOf(union(posts, beam, screw, bar, plate, tub, base, spout, roofM), L.timber)
  -- a little slab hood keeps the snow off the screw, a weighting stone on the ridge
  part(roofM, L.roof, { sep = true }) F.courses(roofM, yb - 70, 3, 5, L.roof) F.lichen(roofM, .25, 82)
  line({ { x0 - 9, yb - 57 }, { x0 + 24, yb - 70 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, L.roof.hi) end end)
  local ws = c:ellipse(x0 + 25, yb - 70, 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(x0 + 24, yb - 71, L.stone.hi)
  part(posts, L.timber) posts:each(function(x, y) if hash(x, y // 3, 83) < .2 then px(x, y, L.timber.shade) end if x == x0 or x == x0 + 46 then px(x, y, L.timber.hi) end end)
  part(beam, L.timber) F.logs(beam, L.timber, yb - 56, 7) F.logEnd(x0 - 4, yb - 53, 3) F.lichen(beam, .12, 84)
  part(screw, IR, { nopop = true }) for y = yb - 49, yb - 29, 2 do hline(x0 + 23, x0 + 27, y, IR.deep) px(x0 + 23, y + 1, IR.hi) end
  part(bar, L.board, { nopop = true }) part(plate, L.board)
  part(tub, L.board) for x = x0 + 10, x0 + 40, 6 do vline(x, yb - 23, yb - 8, L.board.deep) end
  hline(x0 + 7, x0 + 43, yb - 20, IR.shade) hline(x0 + 8, x0 + 42, yb - 11, IR.shade)
  for x = x0 + 9, x0 + 41, 2 do px(x, yb - 23, CIDER.shade) if x % 4 == 1 then px(x, yb - 22, CIDER.base) end end
  -- the granite press-bed: one dressed slab with a juice groove
  part(base, L.stone) F.courses(base, yb - 7, 7, 14, L.stone) F.lichen(base, .2, 85)
  hline(x0 - 3, x0 + 53, yb - 7, L.stone.hi) hline(x0 + 6, x0 + 52, yb - 6, CIDER.shade)
  part(spout, L.stone, { nopop = true }) hline(x0 + 53, x0 + 60, yb - 10, L.stone.hi)
  -- juice pouring into a bucket
  vline(x0 + 60, yb - 7, yb + 4, CIDER.base) vline(x0 + 61, yb - 7, yb + 4, CIDER.hi)
  local bk = poly{ { x0 + 54, yb + 4 }, { x0 + 68, yb + 4 }, { x0 + 66, yb + 14 }, { x0 + 56, yb + 14 } }
  rimOf(bk, L.timber) part(bk, L.board) hline(x0 + 55, x0 + 67, yb + 5, CIDER.base) hline(x0 + 56, x0 + 66, yb + 6, CIDER.shade) hline(x0 + 55, x0 + 67, yb + 8, IR.shade)
  -- a wasp at the sweet spout
  px(x0 + 64, yb - 12, L.gold.base) px(x0 + 65, yb - 12, L.timber.edge) px(x0 + 64, yb - 13, L.mist2)
end
press(92, 206)
local _, tx, ty = F.gnome(80, 210, { hat = L.awnA, coat = L.accent, arm = "up" })
fill(line({ { tx, ty }, { 98, 166 } }), L.board.base)
-- heaps beside the press
local function heap(x0, x1, yb, fr)
  local m = poly{ { x0, yb }, { x0 + 4, yb - 7 }, { (x0 + x1) // 2, yb - 11 }, { x1 - 4, yb - 7 }, { x1, yb } }
  rimOf(m, fr) fill(m, fr.base)
  m:each(function(x, y) local k = (x + (y % 2) * 2) % 4 if k == 0 then px(x, y, fr.hi) elseif k == 3 then px(x, y, fr.shade) end end)
  for x = x0 + 4, x1 - 4, 7 do px(x, yb - 8 + (x % 3), LF.base) px(x + 1, yb - 9 + (x % 3), LF.hi) end
end
heap(30, 84, 214, AP)
heap(18, 44, 206, PEAR)
F.crate(24, 232, 22, 12, AP) F.crate(50, 234, 22, 12, GOLD) F.crate(36, 220, 22, 10, PEAR)
local function basket(x, yb, w, h, fr, nuts)
  local m = poly{ { x - w, yb - h }, { x + w, yb - h }, { x + w - 2, yb }, { x - w + 2, yb } }
  local handle = c:ellipse(x, yb - h, w - 2, h - 1):cut(c:ellipse(x, yb - h, w - 4, h - 3)):clip(rect(x - w, yb - 2 * h, x + w, yb - h - 1))
  rimOf(union(m, handle), WICK) part(handle, WICK, { nopop = true, noshade = true })
  part(m, WICK, { nopop = true })
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, WICK.shade) elseif (xx - yy) % 5 == 0 then px(xx, yy, WICK.hi) end end)
  for xx = x - w + 1, x + w - 1, 2 do
    if nuts then px(xx, yb - h - 1, WAL.base) px(xx + 1, yb - h - 1, WAL.shade) px(xx, yb - h - 2, WAL.hi)
    else px(xx, yb - h - 1, fr.base) px(xx + 1, yb - h - 1, fr.shade) px(xx, yb - h - 2, fr.hi) end
  end
end
basket(80, 226, 7, 6, nil, true)
-- stoneware jugs and a glass of sea-buckthorn juice on a plank table
local tbl = rect(118, 226, 182, 229):add(rect(121, 230, 123, 242)):add(rect(177, 230, 179, 242))
F.shadow(120, 182, 242, 8, 3)
rimOf(tbl, L.timber) part(tbl, L.board, { nopop = true })
for k = 0, 3 do
  local x = 126 + k * 14
  local jr = ({ L.awnB, L.wall2, L.awnB, L.stone })[k + 1]
  local jug = c:rrect(x - 4, 214, x + 4, 225, 3):add(rect(x - 2, 210, x + 2, 214))
  rimOf(jug, L.timber) part(jug, jr)
  hline(x - 3, x + 3, 216, (k % 2 == 0) and L.gentian.shade or L.accent.shade)
  if k % 2 == 0 then px(x - 1, 220, L.gentian.base) px(x, 219, L.gentian.base) px(x + 1, 220, L.gentian.base) end -- a painted gentian
  fill(rect(x + 4, 216, x + 6, 221), L.timber.edge) fill(rect(x + 4, 217, x + 5, 220), jr.shade)
  fill(rect(x - 2, 209, x + 2, 210), L.board.shade) px(x - 2, 209, L.board.hi)
end
-- the glass of orange juice and a dish of walnuts
fill(rect(175, 220, 178, 225), BERRY.base) hline(175, 178, 220, BERRY.hi) vline(178, 221, 225, BERRY.shade) px(175, 219, L.edel.base) px(178, 219, L.edel.shade)
F.barrel(196, 250, L.timber, 14) F.barrel(186, 262, L.board, 12)
F.lichen(rect(184, 236, 208, 240), .12, 86)
F.edelweiss(206, 252, true) F.gentian(210, 255, true)

---------------------------------------------------------------- right hero: picker on a ladder at a big front apple tree
fruitTree(408, 226, 2.3, 80, 1)
local lad = line({ { 352, 236 }, { 370, 168 } }, 2):add(line({ { 364, 238 }, { 382, 170 } }, 2))
for k = 0, 8 do local t = k / 8 lad:add(line({ { 352 + 18 * t, 236 - 68 * t }, { 364 + 18 * t, 238 - 68 * t } })) end
rimOf(lad, L.timber) part(lad, L.board, { nopop = true, noshade = true })
local _, phx, phy = F.gnome(375, 190, { hat = L.awnA, coat = L.wall2, arm = "up", noShadow = true })
fill(rect(phx, phy - 2, phx + 1, phy - 1), AP.base) px(phx, phy - 2, AP.hi)
local bas = poly{ { 368, 186 }, { 380, 186 }, { 378, 194 }, { 370, 194 } } rimOf(bas, WICK) part(bas, WICK)
bas:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, WICK.shade) end end)
for k = 0, 4 do fill(rect(369 + k * 2, 184, 370 + k * 2, 185), AP.base) px(369 + k * 2, 184, AP.hi) end
-- crates by the road (right)
F.crate(290, 226, 22, 12, AP) F.crate(314, 228, 22, 12, GOLD) F.crate(300, 213, 22, 11, PEAR)
basket(330, 214, 6, 5, nil, true)
-- a gnome bringing in a basket of sea-buckthorn
local _, ghx, ghy = F.gnome(336, 256, { hat = L.roof2, coat = L.leaf, arm = "out", flip = true })
local mb = poly{ { ghx - 6, ghy - 1 }, { ghx + 2, ghy - 1 }, { ghx + 1, ghy + 4 }, { ghx - 5, ghy + 4 } }
rimOf(mb, WICK) part(mb, WICK, { nopop = true })
for xx = ghx - 5, ghx + 1 do px(xx, ghy - 2, (xx % 2 == 0) and BERRY.base or BERRY.hi) if xx % 2 == 1 then px(xx, ghy - 3, BERRY.base) end end
px(ghx - 3, ghy - 4, SBL.base) px(ghx - 2, ghy - 5, SBL.hi) px(ghx, ghy - 4, SBL.shade)
-- wheelbarrow of apples
local wb = poly{ { 282, 246 }, { 312, 246 }, { 306, 256 }, { 288, 256 } }
local wbh = line({ { 282, 250 }, { 270, 256 } }, 2):add(rect(296, 256, 297, 262))
local wbw = c:ellipse(310, 260, 4, 4)
F.shadow(276, 314, 264, 6, 2)
rimOf(union(wb, wbh, wbw), L.timber) part(wbh, L.timber, { nopop = true, noshade = true }) part(wb, L.accent) part(wbw, L.timber, { nopop = true })
F.planks(wb, L.accent, 3, false, 23)
fill(c:ellipse(310, 260, 1, 1), L.iron.base)
for x = 285, 309, 3 do local fr = (x % 2 == 0) and AP or GOLD fill(rect(x, 243, x + 1, 245), fr.base) px(x, 243, fr.hi) px(x + 1, 245, fr.shade) end
px(292, 242, LF.base) px(293, 241, LF.hi)

---------------------------------------------------------------- alpine life in the orchard
-- junipers and boulders at the row ends, edelweiss and gentian in the rides
F.juniper(22, 198, 7, 4, 3) F.juniper(458, 210, 6, 4, 5) F.juniper(30, 252, 8, 5, 7) F.edelweiss(190, 232, true)
F.boulder(110, 198, 5, 4, 12) F.boulder(268, 204, 6, 5, 13) F.boulder(450, 216, 5, 4, 14) F.boulder(66, 256, 6, 5, 15)
for _, f in ipairs({ { 120, 252 }, { 236, 222 }, { 274, 232 }, { 96, 248 }, { 446, 202 }, { 150, 184 }, { 160, 186 } }) do F.edelweiss(f[1], f[2], true) end
for _, f in ipairs({ { 142, 182 }, { 156, 188 }, { 126, 254 }, { 352, 210 }, { 280, 236 } }) do F.gentian(f[1], f[2], true) end
F.conifer(22, 268, 30, L.foliage2, 44)
-- a marmot sitting up on the right-hand terrace wall
F.marmot(276, 195)
px(282, 186, L.edel.hi) px(284, 185, L.edel.base) px(285, 184, L.edel.hi) -- its whistle

---------------------------------------------------------------- windfalls + quirk hedgehog
for i = 0, 40 do
  local x, y = 20 + floor(hash(i, 5, 7) * 440), 150 + floor(hash(i, 6, 7) * 110)
  local fr = (i % 4 == 0) and PEAR or ((i % 4 == 1) and GOLD or AP)
  if i % 7 == 3 then fr = WAL end
  if not F.roadM:has(x, y) and not (x > 378 and y > 228) then px(x, y, fr.base) px(x + 1, y, fr.shade) px(x, y - 1, fr.hi) end
end
-- quirk: a hedgehog trundling off with an apple, a leaf and a sprig of rowan berries stuck on its spines
F.shadowM(c:ellipse(222, 263, 13, 1))
F.sprite({
  "......llaaa...mm......",
  ".....lLaAAaa.mMmm.....",
  "......aAaaaaa..w......",
  "...sssaaaaaaasssS.....",
  "..sSsSaaaaaSsSsss.....",
  ".sSsSssaaasSsSsSss....",
  "sSsSsSsSsSsSsSsSsfff..",
  "sssSsSsSsSsSsSssffeff.",
  "ssssssssssssssssfffffn",
  ".sssssssssssssssfffff.",
  "...ff.......ff..ff....",
}, 206, 252, { l = LF.base, L = LF.hi, a = AP.base, A = AP.hi, s = L.soil.shade, S = L.soil.hi, f = L.board.hi, e = L.timber.edge, n = L.timber.edge,
  m = ROW.base, M = ROW.hi, w = L.fern.shade })
-- a goat and her kid at the windfalls under the far-left trees
F.goat(64, 168, { k = .5, graze = true })
F.goat(46, 166, { k = .36, flip = true, r = L.chamois })
for _, a in ipairs({ { 52, 169 }, { 55, 171 }, { 76, 170 } }) do px(a[1], a[2], AP.base) px(a[1] + 1, a[2], AP.shade) px(a[1], a[2] - 1, AP.hi) end
-- an alpine chough (yellow bill, red legs) pecking a windfall by the road
F.sprite({ ".kk....", "kkkkk..", "kkkkkky", ".kkkk..", "..r.r.." }, 182, 191, { k = "#3c3640", y = L.gold.hi, r = AP.base })
px(180, 195, AP.base) px(179, 195, AP.shade)
-- a nutcracker on the crate stack with a walnut in its bill
F.sprite({
  "...CC.....",
  "..CCCC....",
  "NkCECBB...",
  "NkBwBwBB..",
  "..BBwBwBbb",
  "...BwBBbbt",
  "....BBWWbt",
  "....o.o..t",
}, 303, 194, { C = "#3a2e2a", E = L.timber.edge, k = "#2e2a2c", N = WAL.base, B = "#6a5244", w = L.edel.base, W = L.edel.hi, b = "#46383a", t = "#2e2a2c", o = L.timber.edge })
F.depth(0)
F.birds({ { 330, 40, 2 }, { 120, 48, 2 }, { 132, 42, 1 } })
F.finish()
