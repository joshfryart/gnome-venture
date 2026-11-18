-- spring.lua : "Spring" stop look, ISLAND (island_palm), 480x270 gate view.
-- Same composition as the Maplewold spring (art-2701-batch4/stops/opus3/spring.lua), re-cast for a volcanic island:
-- Right hero: a black lava outcrop of columnar basalt under coconut palms, the far volcano behind it. A freshwater
-- spring pours as a two-step waterfall through a cleft in the basalt into a lava-rimmed pool, with spray and a little
-- rainbow; a bamboo spout pipes a second jet out of the rock, and a bamboo trickle-pipe fills a gnome's calabash.
-- The pool overflows into a brook that winds down-left over the sand, under a coral bridge with bamboo rails, into a
-- lotus pool bottom-left. Left: a lava-stone well with a palm-thatch roof and a gnome winding the bucket up, a woven
-- pandanus cottage on lava stilts, palms, a plumeria and a banana. A gnome carries bamboo water tubes on a yoke,
-- another sells calabashes of spring water at a tapa-cloth stall, another does the washing at the lotus pool,
-- another hauls a water cart. Road's end: a thatched hut and a coral chapel with a bell gable.
-- Tree ferns, heliconia, torch ginger, taro leaves, a kingfisher on the bridge rail, a lory on the rocks, terns.
-- Quirk: a green day gecko in a red gnome hat sits on a lotus pad in the pool, eyes shut, showering under the spout.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-island-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "spring", out = DIR, farTrees = { 22, 60, 104, 150, 330, 372, 452 }, treeLineGap = { 186, 292 },
    clouds = { { 150, 40, 40 }, { 290, 30, 46 }, { 420, 52, 30 }, { 30, 82, 22 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local rp = F.rp
local Wt = rp("#d6f8f0 #86e2da #48c2c8 #2c96ae #1e6888") -- clear spring water
local GL = "#f2faf2"                                     -- water glint / foam
local SPR = "#e2f2f0"                                    -- spray
local bas = rp("#9a96a2 #726e7a #56525e #3e3a48 #221e2a") -- basalt
local basLit = "#a8a2a8"                                 -- sun-struck basalt lip
local basWet = "#3e4e5c"                                 -- wet basalt
local moss = L.moss
local gk = rp("#c4f48a #74d24e #42a648 #2c7a40 #1a4e32")  -- day gecko green
local tfern = rp("#c6ec84 #86ca54 #529e44 #36783a #22502e")
local fernTrunk = rp("#a88866 #7c5e46 #5a4234 #3e2e26 #281e1a")

---------------------------------------------------------------- back row: a thatched hut and a coral chapel at the road's end
F.depth(1)
do
  local top, _, wall = F.building{ x0 = 196, x1 = 228, yb = 126, wh = 13, rh = 11, wall = L.rope, roof = L.roof, noFrame = true, noAttic = true, chimney = true }
  wall:each(function(x, y) if y > top + 1 and ((x // 2 + y // 2) % 2 == 0) then px(x, y, L.rope.shade) end end)
  hline(196, 228, 125, L.lava.base) hline(196, 228, 126, L.lava.shade)
  F.window(204, 117, 208, 120, L.timber)
  fill(rect(201, 116, 202, 121), L.wall2.base) fill(rect(210, 116, 211, 121), L.wall2.base)
end
F.smoke(219, 97, 4, .5, 2)
do -- a little coral chapel: whitewashed nave, thatch, and a stepped bell gable with a bronze bell
  local wall = rect(254, 112, 278, 126)
  local roof = poly{ { 251, 113 }, { 266, 103 }, { 281, 113 } }
  local gable = poly{ { 254, 112 }, { 254, 96 }, { 257, 96 }, { 257, 92 }, { 259, 88 }, { 261, 88 }, { 263, 92 }, { 263, 96 }, { 266, 96 }, { 266, 112 } }
  rimOf(union(wall, roof, gable), L.stone)
  part(wall, L.plaster) F.courses(wall, 112, 3, 6, L.plaster)
  part(roof, L.roof, { nopop = true }) F.thatch(roof, L.roof, 103, 266)
  part(gable, L.plaster, { nopop = true })
  vline(254, 96, 112, L.plaster.hi) hline(254, 266, 96, L.stone.shade)
  local arch = c:rrect(257, 97, 263, 104, 2) fill(arch, L.lava.deep)
  fill(c:ellipse(260, 101, 2, 2), L.gold.base) px(259, 100, L.gold.hi) px(261, 102, L.gold.deep) px(260, 103, L.gold.shade)
  px(260, 87, L.timber.deep) px(260, 86, L.timber.deep) px(259, 86, L.timber.deep) px(261, 86, L.timber.deep) -- a little cross
  fill(rect(270, 117, 274, 125), L.wall2.base) vline(270, 117, 125, L.wall2.hi) vline(274, 117, 125, L.wall2.deep) hline(270, 274, 117, L.wall2.deep)
  hline(254, 278, 126, L.lava.base)
end
F.tree(300, 128, 28, 3)
F.palm(186, 128, 34, L.foliage2, 2, { lean = -7 })
F.fenceP(120, 132, 190, 127, 6)

---------------------------------------------------------------- mid left: woven pandanus cottage on lava stilts, palms
F.depth(2)
F.palm(8, 156, 40, L.foliage, 1, { lean = 8 })
do
  local top, _, wall = F.building{ x0 = 24, x1 = 70, yb = 136, wh = 20, rh = 16, wall = L.rope, roof = L.roof, chimney = false, noAttic = true, noFrame = true }
  -- woven pandanus mat walls: a two-tone basket weave between driftwood posts
  wall:each(function(x, y)
    if y > top + 1 and y < 131 then
      local wv = ((x // 3 + y // 2) % 2 == 0)
      px(x, y, wv and L.rope.base or L.rope.shade)
      if (x // 3 + y // 2) % 2 == 0 and x % 3 == 0 then px(x, y, L.rope.hi) end
    end
  end)
  for _, vx in ipairs({ 24, 25, 46, 47, 69, 70 }) do vline(vx, top + 1, 131, (vx % 2 == 0) and L.timber.base or L.timber.shade) end
  hline(24, 70, top + 1, L.timber.hi)
  -- lava-block stilts with sand-shadow gaps
  fill(rect(24, 131, 70, 136), L.ground.deep)
  for _, sx in ipairs({ 25, 39, 54, 66 }) do
    local st = rect(sx, 131, sx + 4, 136) part(st, L.lava, { nopop = true }) px(sx, 131, L.lava.hi) px(sx + 1, 131, L.lava.hi)
  end
  hline(23, 71, 130, L.timber.base) hline(23, 71, 131, L.timber.deep)
  F.window(30, 120, 35, 125, L.timber)
  fill(rect(26, 119, 28, 126), L.wall2.base) vline(26, 119, 126, L.wall2.hi) fill(rect(37, 119, 39, 126), L.wall2.base) vline(39, 119, 126, L.wall2.deep)
  F.door(50, 118, 57, 130, L.timber)
  fill(rect(51, 119, 56, 130), L.wall2.base) vline(51, 119, 130, L.wall2.hi) vline(54, 119, 130, L.wall2.shade) px(55, 124, L.gold.hi)
  -- a bamboo step up to the door
  hline(48, 59, 132, L.board.hi) hline(48, 59, 133, L.board.shade)
  -- plumeria lei hung by the door
  for k = 0, 4 do F.flower(60 + (k % 2), 120 + k * 2, k % 2 == 0 and "plumeria" or "white", true) end
end
F.smoke(36, 92, 5, .5, 2)
local _, p1x, p1y = F.palm(92, 150, 56, L.foliage, 31, { lean = 12 })
-- washing strung from the cottage gable to the palm trunk
F.washing(70, 118, 96, 122, { { "shirt", L.awnA }, { "sock", L.accent }, { "trousers", L.hibiscus } }, 3)
F.plumeria(160, 140, 36, 34)
F.banana(124, 146, 30, 6)

---------------------------------------------------------------- right hero: the basalt outcrop under palms, waterfall
F.depth(2)
F.palm(446, 128, 70, L.foliage, 8, { lean = -14 })
F.palm(336, 132, 44, L.foliage2, 9, { lean = -10 })
F.depth(3)
local boulders = {
  { 312, 158, 22, 22, 41 }, { 340, 128, 26, 24, 42 }, { 384, 114, 30, 22, 43 }, { 430, 120, 26, 24, 44 },
  { 452, 160, 20, 30, 45 }, { 300, 196, 16, 16, 46 }, { 436, 196, 26, 18, 47 },
  { 330, 190, 22, 18, 48 }, { 352, 166, 14, 16, 50 }, { 418, 150, 12, 16, 51 },
}
local rockM = HP.mask()
for _, b in ipairs(boulders) do
  local pts = {}
  for i = 0, 13 do
    local a = i / 14 * 2 * pi
    local k = .82 + .2 * hash(i, b[5], 3)
    pts[#pts + 1] = { b[1] + cos(a) * b[3] * k, b[2] + sin(a) * b[4] * k }
  end
  b.m = poly(pts)
  rockM:add(b.m)
end
local face = rect(352, 126, 420, 196) -- columnar basalt face
local mass = poly{ { 294, 212 }, { 298, 172 }, { 312, 132 }, { 346, 106 }, { 388, 96 }, { 432, 98 }, { 466, 110 }, { 470, 212 } }
rockM:add(face):add(mass)
F.shadowM(c:ellipse(380, 214, 92, 5))
rimOf(rockM, bas)
-- the mass behind: dark porous lava with ropy pahoehoe ripples
mass:each(function(x, y)
  local v = hash(x, y, 77)
  local h = (hash(x // 5, y // 4, 78) < .5) and bas.shade or bas.deep
  if (floor(x * .6 + sin(y * .5) * 2) + y) % 7 == 0 then h = bas.base end
  if v < .05 then h = bas.edge elseif v > .97 then h = bas.hi end
  px(x, y, h)
end)
for _, b in ipairs(boulders) do
  -- faceted lava boulder: flat facets round a lit crown, porous pits, a hot sunlit lip on the upper left
  local off = hash(b[5], 1, 2) * 2 * pi
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local r = math.sqrt(nx * nx + ny * ny)
    local a = math.atan(ny, nx)
    local sec = floor(((a + off) % (2 * pi)) / (2 * pi) * 7)
    local ca = sec / 7 * 2 * pi + pi / 7 - off
    local lit
    if r < .38 then lit = .25 - (nx * .6 + ny * .8) * .4
    else lit = -(cos(ca) * .6 + sin(ca) * .8) * math.min(1, r * 1.2) end
    lit = lit + (hash(x // 2, y // 2, b[5]) - .5) * .25
    local h
    if lit > .62 then h = basLit elseif lit > .3 then h = bas.hi elseif lit > -.05 then h = bas.base elseif lit > -.45 then h = bas.shade else h = bas.deep end
    local v = hash(x, y, b[5])
    if v > .93 then h = bas.edge elseif v > .89 and lit > 0 then h = bas.deep end -- vesicles
    px(x, y, h)
  end)
  c:edgeIn(b.m, bas.edge)
  -- cracks with a lit lower-left lip
  for k = 1, 2 do
    local x, y = floor(b[1] + (hash(k, b[5], 81) - .5) * b[3]), floor(b[2] - b[4] * .1 + (hash(k, b[5], 82) - .2) * b[4] * .6)
    for t = 0, floor(b[4] * .5) do
      if b.m:has(x, y) and b.m:has(x, y + 1) then px(x, y, bas.edge) if b.m:has(x - 1, y) then px(x - 1, y, bas.hi) end end
      y = y + 1 x = x + ((hash(t, k, b[5]) < .5) and 1 or -1) * ((t % 2) == 0 and 1 or 0)
    end
  end
  -- pale lichen and little orange rock-lichen spots
  for k = 1, 3 do
    local x, y = floor(b[1] + (hash(k, b[5], 83) - .5) * b[3] * 1.2), floor(b[2] + (hash(k, b[5], 84) - .3) * b[4] * .8)
    if b.m:has(x, y) then px(x, y, "#c8d4b4") px(x + 1, y, "#9cae94") px(x, y + 1, "#9cae94") px(x - 1, y + 1, k == 2 and L.produce.base or "#c8d4b4") end
  end
  -- a jungle-green moss and fern cushion on the top, ragged hanging edge
  b.m:each(function(x, y)
    local nx, ny = (x - b[1]) / b[3], (y - b[2]) / b[4]
    local cap = -.55 + .25 * sin(x * .9 + b[5]) + .15 * hash(x, 3, b[5])
    if ny < cap and nx < .6 then
      local v = hash(x, y, 9)
      local edge = not b.m:has(x, y - 1)
      local lt = -(nx * .6 + ny * .8)
      local h = lt > .75 and moss.hi or (lt > .35 and moss.base or moss.shade)
      if v < .12 then h = moss.hi elseif v > .9 then h = L.fern.shade end
      if edge then h = moss.edge end
      px(x, y, h)
      if not (ny + 0.06 < cap) then px(x, y + 1, moss.deep) end
    end
  end)
end

-- the columnar basalt face: hexagonal columns 7 px wide, lit left facet, shaded right facet, joint cracks,
-- column tops stepping down toward the cleft where the water comes through
local CW = 7
local colTop = {}
for i = 0, 9 do
  local cx0 = 352 + i * CW
  local d = abs((cx0 + 3) - 384)
  colTop[i] = 126 + floor(hash(i, 1, 140) * 6) + (d < 14 and (14 - d) // 2 or 0)
end
local faceM = HP.mask()
for i = 0, 9 do
  local x0 = 352 + i * CW
  local x1 = math.min(420, x0 + CW - 1)
  local t = colTop[i]
  local colM = rect(x0, t + 2, x1, 196):add(rect(x0 + 1, t + 1, x1 - 1, t + 1)):add(rect(x0 + 2, t, x1 - 2, t))
  faceM:add(colM)
  colM:each(function(x, y)
    local u = x - x0
    local h
    if u <= 1 then h = bas.hi elseif u <= 3 then h = bas.base elseif u <= 5 then h = bas.shade else h = bas.deep end
    if y <= t + 2 then h = (u <= 3) and basLit or bas.hi end -- sunlit hexagonal top
    -- joints: a horizontal crack every 11-16 px, offset per column
    local jy = (y - t + floor(hash(i, 2, 141) * 12)) % (11 + i % 5)
    if jy == 0 and y > t + 3 then h = bas.edge elseif jy == 1 and y > t + 3 and u <= 3 then h = bas.hi end
    if hash(x, y, 142) < .05 then h = bas.edge end
    px(x, y, h)
  end)
  vline(x1, t + 2, 196, bas.edge)
  -- top hexagon edges
  px(x0 + 1, t, bas.edge) px(x1 - 1, t, bas.edge) px(x0, t + 1, bas.edge) px(x1, t + 1, bas.edge)
end
rimOf(faceM:copy():cut(rockM:copy():cut(face)), bas)
-- ferns and hanging moss draping over the column tops, a lory on the tallest column
for i = 0, 9 do
  local x0, t = 352 + i * CW, colTop[i]
  if i ~= 4 and i ~= 5 then
    for x = x0, x0 + CW - 1 do if hash(x, 2, 8) < .65 then local n = 1 + floor(hash(x, 3, 8) * 5) for k = 0, n do px(x, t + 1 + k, k == 0 and moss.hi or (k == n and moss.shade or moss.base)) end end end
  end
end

-- hanging vines with heart leaves trailing down some columns, and little ferns sprouting from the joints
for _, v in ipairs({ { 0, 3, 34 }, { 2, 5, 22 }, { 3, 1, 14 }, { 7, 2, 30 }, { 8, 5, 18 }, { 9, 1, 26 } }) do
  local x, t = 352 + v[1] * CW + v[2], colTop[v[1]] + 2
  for k = 0, v[3] do
    local xx = x + floor(sin(k * .35 + v[1]) * 1.5 + .5)
    px(xx, t + k, L.foliage2.deep)
    if k % 4 == 1 then
      local s = (k // 4) % 2 == 0 and -1 or 1
      px(xx + s, t + k, L.foliage2.base) px(xx + s * 2, t + k, s < 0 and L.foliage2.hi or L.foliage2.shade)
      px(xx + s, t + k + 1, L.foliage2.shade) px(xx + s * 2, t + k - 1, L.foliage2.hi)
    end
  end
end
for i = 1, 14 do
  local col = floor(hash(i, 1, 145) * 10)
  if col ~= 4 and col ~= 5 then
    local x = 352 + col * CW + 2 + floor(hash(i, 2, 145) * 3)
    local y = colTop[col] + 14 + floor(hash(i, 3, 145) * 50)
    if y < 192 then
      px(x, y, tfern.shade) px(x - 1, y - 1, tfern.hi) px(x + 1, y - 1, tfern.base) px(x - 2, y - 1, tfern.base) px(x + 2, y, tfern.shade) px(x, y - 2, tfern.hi)
    end
  end
end

-- the waterfall: water slides over the cleft lip (cols 4,5), falls to a ledge, then drops into the pool
local fall = HP.mask()
local LIP, LEDGE, POOL = colTop[4] + 1, 160, 198
local function fallX(y) -- left / right edge of the falling sheet
  if y < LEDGE then return 380 + floor((y - LIP) * .05), 389 + floor((y - LIP) * .08) end
  return 377 + floor((y - LEDGE) * .04), 393 + floor((y - LEDGE) * .1)
end
for y = LIP, POOL do local a, b = fallX(y) for x = a, b do fall:set(x, y) end end
-- the ledge: a broken column stump the upper fall hits
local ledge = rect(372, LEDGE - 2, 396, LEDGE + 2)
fill(ledge, bas.base) hline(372, 396, LEDGE - 2, basLit) hline(372, 396, LEDGE + 2, bas.edge)
-- dark wet rock behind and around the fall
fall:grow(2):cut(fall):each(function(x, y) if face:has(x, y) then px(x, y, (y % 3 == 0) and basWet or bas.edge) end end)
fall:each(function(x, y)
  local a, b = fallX(y)
  local u = (x - a) / math.max(1, b - a)
  local strand = hash(x, 0, 150)
  local flow = (y + floor(strand * 9)) % 9
  local h = (u < .3) and Wt.hi or (u < .7 and Wt.base or Wt.shade)
  if flow < 2 and strand < .55 then h = GL elseif flow > 6 then h = (u < .5) and Wt.base or Wt.deep end
  if x == a then h = Wt.hi end
  if x == b then h = Wt.deep end
  px(x, y, h)
end)
-- white water at the lip, on the ledge and at the foot
for x = 378, 391 do px(x, LIP, GL) if hash(x, 1, 151) < .6 then px(x, LIP - 1, Wt.hi) end end
for x = 372, 397 do if hash(x, 2, 151) < .7 then px(x, LEDGE - 1, GL) end if hash(x, 3, 151) < .5 then px(x, LEDGE - 3, SPR) end end
for i = 0, 40 do
  local x, y = 368 + floor(hash(i, 1, 152) * 34), POOL - 6 + floor(hash(i, 2, 152) * 9)
  px(x, y, hash(i, 3, 152) < .5 and GL or SPR)
end
-- a small rainbow in the spray, left of the fall
for a = 0, 30 do
  local t = a / 30
  local ang = pi + t * pi * .55
  for k, col in ipairs({ L.awnA.hi, L.gold.hi, L.leaf.hi, Wt.base }) do
    local r = 18 - k
    local x, y = floor(366 + cos(ang) * r + .5), floor(198 + sin(ang) * r * .8 + .5)
    if hash(x, y, 153) < .7 and not fall:has(x, y) then px(x, y, col) end
  end
end

-- the bamboo spout: a split cane jutting from the rock right of the fall, its jet arcs onto the gecko
do
  local sp = line({ { 436, 162 }, { 418, 168 } }, 3)
  rimOf(sp, L.board) part(sp, L.board, { nopop = true, noshade = true })
  line({ { 436, 161 }, { 418, 167 } }):each(function(x, y) px(x, y, L.board.hi) end)
  line({ { 436, 163 }, { 418, 169 } }):each(function(x, y) px(x, y, L.board.shade) end)
  for _, nx in ipairs({ 430, 424 }) do vline(nx, 162, 167, L.board.deep) end
  fill(rect(436, 158, 440, 168), bas.deep) -- the hole in the rock
  -- lashed to a driftwood stake
  vline(428, 166, 178, L.timber.base) vline(429, 166, 178, L.timber.deep) px(428, 165, L.rope.hi) hline(427, 430, 166, L.rope.base)
  local JX0, JY0 = 418, 168 -- lands on the hat tip
  for k = 0, 10 do
    local x = JX0 - k
    local y = JY0 + floor(k * k * .1 + k * .2)
    local y2 = JY0 + floor((k + 1) * (k + 1) * .1 + (k + 1) * .2)
    for yy = y, math.max(y + 2, y2) do px(x, yy, Wt.base) px(x - 1, yy, Wt.shade) end
    px(x, y, Wt.hi) px(x, y - 1, GL)
  end
end

---------------------------------------------------------------- the pool, its overflow and the gecko
F.depth(3)
local BX, BY = 392, 202
do
  local outer = c:ellipse(BX, BY, 40, 10)
  local wall = rect(BX - 40, BY, BX + 40, BY + 8)
  local inner = c:ellipse(BX, BY - 1, 35, 7)
  rimOf(union(outer, wall), bas)
  -- a dry-laid rim of rounded lava stones, each one lit upper left
  union(outer, wall):cut(inner):each(function(x, y)
    local cx, cy = (x + (y // 4) * 3) // 6, y // 4
    local u, v = (x + (y // 4) * 3) % 6, y % 4
    local h = bas.base
    if u == 0 or v == 0 then h = bas.edge elseif u == 1 and v == 1 then h = bas.hi elseif u >= 4 or v == 3 then h = bas.shade end
    if hash(cx, cy, 160) < .18 and h ~= bas.edge then h = (u + v < 4) and L.stone.hi or L.stone.base end -- the odd coral block
    px(x, y, h)
  end)
  wall:each(function(x, y) if (x - BX) > 22 and y > BY + 3 and hash(x, y, 161) < .5 then px(x, y, bas.deep) end end)
  F.water(inner, Wt)
  -- light shafts / pebbles seen through the clear water, and rings where the falls hit
  inner:each(function(x, y) if y > BY + 1 and hash(x // 2, y, 162) < .08 then px(x, y, Wt.shade) end end)
  for _, rr in ipairs({ { 384, 200, 12, 3 }, { 384, 200, 18, 4 } }) do
    c:ellipse(rr[1], rr[2], rr[3], rr[4]):edge():each(function(x, y) if inner:has(x, y) and hash(x, y, 163) < .6 then px(x, y, GL) end end)
  end
  -- moss and ferns creeping up the pool wall
  for x = BX - 40, BX + 40 do if hash(x, 4, 12) < .4 then local n = floor(hash(x, 5, 12) * 4) for k = 0, n do px(x, BY + 8 - k, k == n and moss.hi or moss.base) end end end
end
-- the trickle-pipe from the rock left of the face into a gnome's calabash
do
  local cx, cy = 336, 166
  local pipe = line({ { cx + 6, cy - 3 }, { cx - 2, cy } }, 2)
  rimOf(pipe, L.board) part(pipe, L.board, { nopop = true, noshade = true }) px(cx + 2, cy - 2, L.board.deep)
  for y = cy + 1, 196 do px(cx - 3 + floor((y - cy) * .08), y, ((y // 2) % 2 == 0) and Wt.hi or Wt.base) end
  local _, hx, hy = F.gnome(318, 218, { hat = L.awnA, coat = L.lav, arm = "out" })
  -- a big calabash gourd held out under the drip
  local gourd = c:ellipse(hx + 6, hy - 2, 5, 5):add(c:ellipse(hx + 6, hy - 8, 2, 2))
  c:rim(gourd, L.coconut.edge) part(gourd, L.gold, { nopop = true })
  gourd:each(function(x, y) if x < hx + 4 and y < hy - 1 then px(x, y, L.gold.hi) end end)
  hline(hx + 2, hx + 10, hy, L.gold.shade) px(hx + 5, hy - 11, L.timber.deep) px(hx + 6, hy - 11, L.timber.deep)
  px(hx + 6, hy - 10, Wt.hi) px(hx + 4, hy - 9, GL)
  hline(hx + 2, hx + 10, hy - 2, L.roof2.base) -- a woven carrying band
end
-- QUIRK: a green day gecko in a red gnome hat on a lotus pad in the pool, eyes shut, showering under the spout
do
  local pad = c:ellipse(410, 199, 15, 3):cut(poly{ { 410, 199 }, { 427, 195 }, { 427, 201 } })
  rimOf(pad, L.seagrass) fill(pad, L.seagrass.base)
  pad:edge():each(function(x, y) if y > 199 then px(x, y, L.seagrass.deep) else px(x, y, L.seagrass.hi) end end)
  for k = 1, 3 do line({ { 410, 199 }, { 410 - 12 + k * 4, 197 } }):each(function(x, y) if pad:has(x, y) then px(x, y, L.seagrass.shade) end end) end
  -- the gecko, built from masks: profile facing left, head, body, a tail curled into a spiral, splayed toe pads
  local head = c:ellipse(400, 191, 5, 3):add(poly{ { 393, 192 }, { 398, 189 }, { 398, 194 } })
  local body = c:ellipse(411, 193, 8, 3)
  local tail = line({ { 418, 194 }, { 423, 193 }, { 426, 190 }, { 426, 187 }, { 424, 185 }, { 421, 186 }, { 421, 188 }, { 423, 188 } }, 1)
    :add(line({ { 418, 195 }, { 423, 194 }, { 427, 191 } }, 1))
  local legs = line({ { 403, 194 }, { 401, 197 } }, 1):add(line({ { 414, 195 }, { 417, 197 } }, 1)):add(line({ { 407, 195 }, { 407, 197 } }, 1))
  local toes = HP.mask()
  for _, t in ipairs({ { 399, 198 }, { 401, 198 }, { 403, 198 }, { 405, 198 }, { 407, 198 }, { 409, 198 }, { 416, 198 }, { 418, 198 }, { 420, 198 } }) do toes:set(t[1], t[2]) end
  local gm = union(head, body, tail, legs, toes)
  c:rim(gm, gk.edge)
  gm:each(function(x, y)
    local h = gk.base
    if not gm:has(x, y - 1) then h = gk.hi elseif not gm:has(x, y + 1) or not gm:has(x + 1, y + 1) then h = gk.shade end
    px(x, y, h)
  end)
  toes:each(function(x, y) px(x, y, gk.hi) end)
  tail:each(function(x, y) if x > 419 and (x + y) % 3 == 0 then px(x, y, L.gold.hi) elseif x > 419 and (x + y) % 3 == 1 then px(x, y, gk.hi) end end)
  -- pale throat and belly
  for x = 395, 417 do local y = (x < 405) and 193 or 195 if gm:has(x, y) and gm:has(x, y + 1) then px(x, y, L.gold.hi) end end
  hline(394, 397, 193, gk.deep) -- the smile
  -- eye shut tight: a dark arc with a lash, a pale lid above
  px(397, 190, gk.edge) px(398, 191, gk.edge) px(399, 191, gk.edge) px(400, 190, gk.edge) px(398, 189, gk.hi) px(399, 189, gk.hi)
  px(394, 191, gk.deep) -- nostril
  -- orange-red day-gecko spots down the back
  for _, s in ipairs({ { 406, 191 }, { 409, 190 }, { 412, 191 }, { 415, 191 }, { 410, 192 }, { 404, 190 } }) do px(s[1], s[2], L.hibiscus.base) end
  px(409, 190, L.hibiscus.hi) px(415, 191, L.awnA.base)
  -- the red gnome hat, brim on the head, tip flopping back over the shower
  local hat = poly{ { 394, 188 }, { 405, 188 }, { 402, 182 }, { 404, 178 }, { 409, 176 }, { 403, 175 }, { 399, 179 }, { 397, 184 } }
  c:rim(hat, L.timber.edge) part(hat, L.awnA, { nopop = true })
  hat:each(function(x, y) if x < 399 and y > 180 then px(x, y, L.awnA.hi) end end)
  hline(394, 405, 188, L.awnA.deep) hline(395, 404, 187, L.awnA.shade)
  px(398, 181, L.awnA.hi) px(400, 178, L.awnA.hi)
  -- splash on the hat
  for _, p in ipairs({ { 407, 174 }, { 404, 173 }, { 410, 176 }, { 396, 180 }, { 412, 178 }, { 406, 171 }, { 393, 185 } }) do px(p[1], p[2], Wt.hi) end
  px(402, 172, GL) px(409, 173, GL) px(395, 183, GL)
  -- a pink lotus beside it
  local lx, ly = 420, 205
  fill(c:ellipse(lx, ly, 5, 1), L.seagrass.base) hline(lx - 4, lx + 4, ly - 1, L.seagrass.hi)
  F.sprite({ "..p..", ".pPp.", "pPgPp", ".PPP." }, lx - 2, ly - 5, { p = L.petal.base, P = L.petal.hi, g = L.gold.hi })
end
-- overflow notch and the brook winding down-left over the sand, under the road, into the lotus pool
local brook = HP.mask()
do
  local pts = { { 356, 208 }, { 340, 218 }, { 318, 226 }, { 296, 232 }, { 270, 238 }, { 240, 242 }, { 210, 244 }, { 180, 247 }, { 150, 250 } }
  for i = 1, #pts - 1 do
    local a, b = pts[i], pts[i + 1]
    local w = 12 + floor(i * 1.6)
    brook:add(line({ a, b }, w))
    brook:add(c:ellipse(b[1], b[2], w // 2, w // 2))
  end
  local pond = c:ellipse(84, 252, 76, 18):clip(rect(19, 230, 200, 269))
  brook:add(pond)
end
local onRoad = HP.mask()
brook:each(function(x, y) if F.roadM:has(x, y) then onRoad:set(x, y) end end)
brook:cut(onRoad)
do
  -- banks: wet dark sand with black lava pebbles and pale coral rubble
  local bank = brook:grow(2):cut(brook):cut(F.roadM)
  bank:each(function(x, y) local v = hash(x, y, 51) px(x, y, v < .35 and L.duff or (v < .6 and L.lava.base or (v < .75 and L.lava.hi or L.ground.shade))) end)
  brook:grow(4):cut(brook:grow(2)):cut(F.roadM):each(function(x, y) if hash(x, y, 56) < .5 and c:get(x, y) == F.groundAt(x, y) then px(x, y, L.duff) end end)
  F.water(brook, Wt, { step = 3 })
  -- the brook runs: long lit current lines following the flow, foam ticks, glints
  brook:each(function(x, y)
    if y % 3 == 1 and hash(x // 5, y, 54) < .3 and brook:has(x - 2, y) and brook:has(x + 2, y) and brook:has(x, y + 2) then px(x, y, Wt.hi) end
    if hash(x, y, 55) < .012 and brook:has(x, y - 2) then px(x, y, GL) end
  end)
  -- lava stones in the stream with a foam lip on the upstream side
  for _, s in ipairs({ { 334, 220 }, { 310, 228 }, { 290, 234 }, { 186, 247 } }) do
    local m = c:ellipse(s[1], s[2], 3, 2) rimOf(m, bas) part(m, bas, { nopop = true }) px(s[1] - 1, s[2] - 1, bas.hi) px(s[1] - 2, s[2] - 1, basLit)
    px(s[1] - 2, s[2] - 2, moss.base)
    for k = 0, 3 do px(s[1] + 3 + k, s[2] - 2 + (k % 2), GL) end hline(s[1] - 4, s[1] - 1, s[2] + 3, Wt.hi)
  end
  -- spill over the pool lip
  for y = 204, 212 do px(354 + (y - 204) // 3, y, Wt.hi) px(355 + (y - 204) // 3, y, Wt.base) px(356 + (y - 204) // 3, y, GL) end
end
-- the bridge where the road crosses the brook: coral-stone side walls with lava voussoir arches, bamboo rails
do
  local Y0, Y1 = 226, 258
  local wallL = poly{ { floor(F.xl(234)) - 22, 236 }, { floor(F.xl(234)) - 6, 230 }, { floor(F.xl(256)) - 6, 258 }, { floor(F.xl(256)) - 24, 258 } }
  local wallR = poly{ { floor(F.xr(226)) + 6, 224 }, { floor(F.xr(226)) + 22, 228 }, { floor(F.xr(244)) + 22, 248 }, { floor(F.xr(244)) + 6, 248 } }
  local walls = union(wallL, wallR)
  -- low coral kerbs along both road edges
  local kerb = HP.mask()
  for y = Y0, Y1 do
    local xl, xr = floor(F.xl(y)), floor(F.xr(y) + .99)
    kerb:add(rect(xl - 5, y - 3, xl + 1, y)):add(rect(xr - 1, y - 3, xr + 5, y))
  end
  rimOf(union(kerb, walls), L.stone)
  part(walls, L.stone, { nopop = true }) F.courses(walls, 236, 4, 8, L.stone)
  walls:each(function(x, y) if hash(x // 4, y // 4, 170) < .14 and y % 4 ~= 0 then px(x, y, hash(x, y, 171) < .3 and L.lava.hi or L.lava.base) end end)
  for _, a in ipairs({ { floor(F.xl(244)) - 15, 251, wallL }, { floor(F.xr(236)) + 14, 242, wallR } }) do
    local arch = c:ellipse(a[1], a[2], 7, 9):clip(rect(a[1] - 7, a[2] - 9, a[1] + 7, a[2] + 4)):clip(a[3])
    fill(arch, Wt.edge)
    arch:each(function(x, y) if y > a[2] - 2 then px(x, y, (x + y) % 3 == 0 and Wt.shade or Wt.deep) end end)
    c:ellipse(a[1], a[2], 9, 11):cut(c:ellipse(a[1], a[2], 7, 9)):clip(rect(a[1] - 9, a[2] - 11, a[1] + 9, a[2])):clip(a[3]):each(function(x, y)
      px(x, y, (math.atan(y - a[2], x - a[1]) * 4 // 1) % 2 == 0 and bas.hi or bas.shade) end)
    for k = 0, 4 do px(a[1] - 4 + k * 2, a[2] + 3, GL) end
  end
  part(kerb, L.stone, { nopop = true })
  kerb:each(function(x, y) if not kerb:has(x, y - 1) then px(x, y, L.stone.hi) end end)
  -- bamboo rails: posts every 8 rows, two canes lashed along each edge
  local rail = HP.mask()
  local posts = HP.mask()
  for _, side in ipairs({ -1, 1 }) do
    local function ex(y) return side < 0 and floor(F.xl(y)) - 2 or floor(F.xr(y) + .99) + 2 end
    for y = Y0, Y1, 8 do posts:add(rect(ex(y), y - 13, ex(y) + 1, y - 2)) end
    rail:add(line({ { ex(Y0), Y0 - 12 }, { ex(Y1), Y1 - 12 } }, 2))
    rail:add(line({ { ex(Y0), Y0 - 7 }, { ex(Y1), Y1 - 7 } }, 1))
  end
  rimOf(union(rail, posts), L.timber)
  part(posts, L.board, { nopop = true, noshade = true })
  posts:each(function(x, y) if not posts:has(x - 1, y) then px(x, y, L.board.hi) elseif y % 5 == 0 then px(x, y, L.board.deep) end end)
  rail:each(function(x, y) px(x, y, rail:has(x, y - 1) and L.board.shade or L.board.hi) if (x * 3 + y) % 11 == 0 then px(x, y, L.board.deep) end end)
  posts:each(function(x, y) if not posts:has(x, y - 1) then px(x, y, L.board.deep) px(x, y + 1, L.rope.base) end end)
end

---------------------------------------------------------------- left: lava-stone well with a palm-thatch roof, a gnome winding
F.depth(3)
do
  local x0, x1, yb = 52, 104, 204
  local wall = c:rrect(x0, yb - 18, x1, yb, 3)
  local postL, postR = rect(x0 + 4, yb - 52, x0 + 7, yb - 18), rect(x1 - 7, yb - 52, x1 - 4, yb - 18)
  local roof = poly{ { x0 - 8, yb - 46 }, { (x0 + x1) // 2, yb - 68 }, { x1 + 8, yb - 46 } }:add(rect(x0 - 8, yb - 48, x1 + 8, yb - 44))
  local axle = rect(x0 + 4, yb - 36, x1 - 4, yb - 34)
  local crank = line({ { x1 - 2, yb - 35 }, { x1 + 4, yb - 35 }, { x1 + 4, yb - 29 } }, 2)
  F.shadow(x0 + 2, x1, yb, 12, 4)
  rimOf(union(wall, postL, postR, roof, axle, crank), L.timber)
  part(wall, L.lava) F.courses(wall, yb - 18, 5, 9, L.lava)
  wall:each(function(x, y) if hash(x, y, 60) < .08 then px(x, y, L.lava.deep) end if x < x0 + 6 and y < yb - 4 and (y - yb + 18) % 5 ~= 0 then px(x, y, L.lava.hi) end end)
  -- a coral-stone coping
  local cope = rect(x0 + 1, yb - 19, x1 - 1, yb - 17) part(cope, L.stone, { nopop = true }) hline(x0 + 2, x1 - 2, yb - 19, L.stone.hi)
  for x = x0, x1 do if hash(x, 7, 61) < .4 then px(x, yb, moss.base) px(x, yb - 1, moss.hi) end end
  part(postL, L.board, { nopop = true }) part(postR, L.board, { nopop = true })
  F.bamboo(union(postL, postR), L.board, 4)
  part(roof, L.roof, { sep = true }) F.thatch(roof, L.roof, yb - 68, (x0 + x1) // 2)
  line({ { x0 - 8, yb - 46 }, { (x0 + x1) // 2, yb - 68 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  -- ragged thatch fringe along the eaves
  for x = x0 - 8, x1 + 8 do local n = floor(hash(x, 1, 64) * 3) for k = 0, n do px(x, yb - 43 + k, k == n and L.roof.deep or L.roof.shade) end end
  -- a ridge knot and a frond laid along the ridge
  fill(rect((x0 + x1) // 2 - 1, yb - 70, (x0 + x1) // 2 + 1, yb - 67), L.rope.base) px((x0 + x1) // 2 - 1, yb - 70, L.rope.hi)
  part(axle, L.timber, { nopop = true, noshade = true })
  fill(rect((x0 + x1) // 2 - 4, yb - 37, (x0 + x1) // 2 + 4, yb - 33), L.rope.base)
  for x = (x0 + x1) // 2 - 4, (x0 + x1) // 2 + 4, 2 do vline(x, yb - 37, yb - 33, L.rope.shade) end
  part(crank, L.iron, { nopop = true, noshade = true })
  local bx = (x0 + x1) // 2
  vline(bx, yb - 32, yb - 26, L.rope.deep)
  local bk = poly{ { bx - 5, yb - 25 }, { bx + 5, yb - 25 }, { bx + 4, yb - 17 }, { bx - 4, yb - 17 } }
  c:rim(bk, L.timber.edge) part(bk, L.timber) hline(bx - 5, bx + 5, yb - 23, L.rope.shade) hline(bx - 4, bx + 4, yb - 25, Wt.hi)
  px(bx + 4, yb - 14, Wt.hi) px(bx - 3, yb - 12, Wt.base)
  local _, hx, hy = F.gnome(x1 + 14, yb + 4, { hat = L.roof2, coat = L.accent, arm = "up", flip = true })
  fill(line({ { hx, hy }, { x1 + 4, yb - 29 } }), L.skin.base)
  -- a hibiscus at the well foot
  F.hibiscus(46, 206, 7, 10, 65)
end

---------------------------------------------------------------- road: gnome carrying bamboo water tubes on a yoke; the spring sign
F.depth(3)
do
  local x, yb = 262, 212
  local _, hx, hy = F.gnome(x, yb, { hat = L.leaf, coat = L.roof2, arm = "hold" })
  local yoke = line({ { x - 17, yb - 12 }, { x, yb - 14 }, { x + 17, yb - 12 } }, 2)
  c:rim(yoke, L.timber.edge) part(yoke, L.board, { nopop = true, noshade = true })
  for _, sx in ipairs({ -16, 16 }) do
    vline(x + sx, yb - 11, yb - 9, L.rope.deep)
    -- a bundle of three bamboo tubes, stoppered with leaves, sloshing
    local tubes = HP.mask()
    for k = -1, 1 do tubes:add(rect(x + sx + k * 3 - 1, yb - 8 + abs(k), x + sx + k * 3 + 1, yb + 4)) end
    rimOf(tubes, L.board)
    tubes:each(function(xx, yy)
      local u = (xx - (x + sx) + 1) % 3
      local h = u == 0 and L.board.hi or (u == 1 and L.board.base or L.board.shade)
      if (yy - yb) % 6 == 0 then h = L.board.deep end
      px(xx, yy, h)
    end)
    hline(x + sx - 4, x + sx + 4, yb - 3, L.rope.base)
    for k = -1, 1 do px(x + sx + k * 3, yb - 9 + abs(k), L.leaf.base) end
    px(x + sx + 4, yb + 6, Wt.hi) px(x + sx - 3, yb + 7, Wt.base)
  end
  for i = 1, 4 do px(x - 2 + (i % 2) * 4, yb - 6 - i * 7, L.road.shade) end
end
do -- the spring sign: a driftwood board with a blue drop, on a bamboo post, ginger at its foot
  local post = rect(205, 168, 207, 196)
  local bd = c:rrect(194, 156, 220, 170, 2)
  rimOf(union(post, bd), L.timber) part(post, L.board, { nopop = true }) F.bamboo(post, L.board, 3)
  part(bd, L.timber, { nopop = true }) F.planks(bd, L.timber, 5, false, 31) c:edgeIn(bd, L.timber.deep)
  local drop = poly{ { 207, 158 }, { 211, 164 }, { 203, 164 } }:add(c:ellipse(207, 165, 4, 3))
  c:rim(drop, Wt.edge) fill(drop, Wt.base) px(205, 164, Wt.hi) px(205, 165, GL) hline(206, 209, 168, Wt.shade)
  hline(196, 200, 160, L.rope.base) hline(214, 218, 160, L.rope.base) -- lashings
  F.flower(198, 158, "hibiscus", true)
end

---------------------------------------------------------------- the calabash stall: gourds and coconut cups of spring water on tapa cloth
F.depth(3)
do
  F.gnome(156, 188, { hat = L.lav, coat = L.awnB, arm = "out", noShadow = true })
  local top = rect(132, 186, 182, 189)
  local legs = rect(135, 190, 136, 200):add(rect(178, 190, 179, 200))
  local cloth = rect(132, 190, 182, 195)
  F.shadow(134, 182, 201, 8, 3)
  rimOf(union(top, legs, cloth), L.timber)
  part(legs, L.board, { nopop = true, noshade = true }) part(top, L.board, { nopop = true }) F.bamboo(top, L.board, 3, { horizontal = true }) hline(132, 182, 186, L.board.hi)
  -- tapa cloth: cream bark-cloth with brown geometric bands
  fill(cloth, L.awnB.base)
  cloth:each(function(x, y)
    local u = (x - 132) % 8
    if y == 191 or y == 194 then px(x, y, L.coconut.base) end
    if y == 192 or y == 193 then if u == 0 or u == 1 or (u == 4 and y == 192) or (u == 5 and y == 193) then px(x, y, L.coconut.shade) end end
    if y == 195 then px(x, y, (x % 2 == 0) and L.coconut.deep or L.awnB.shade) end
  end)
  for i, jx in ipairs({ 137, 147, 165, 174 }) do
    local big = i % 2 == 1
    local gr = big and 4 or 3
    local g = c:ellipse(jx, 185 - gr, gr, gr):add(rect(jx - 1, 185 - gr * 2 - 3, jx, 185 - gr * 2))
    c:rim(g, L.coconut.edge) part(g, i == 3 and L.leaf or L.gold, { nopop = true })
    px(jx - 2, 185 - gr - 1, (i == 3) and L.leaf.hi or L.gold.hi)
    hline(jx - gr, jx + gr, 185 - gr, L.roof2.shade)
    px(jx - 1, 185 - gr * 2 - 4, L.timber.base) px(jx, 185 - gr * 2 - 4, L.timber.base)
  end
  -- coconut-shell cups
  for _, cx in ipairs({ 155, 160 }) do fill(rect(cx - 1, 184, cx + 1, 185), L.coconut.base) px(cx - 1, 184, L.coconut.hi) hline(cx - 1, cx + 1, 183, Wt.hi) end
  -- green coconuts stacked by the leg
  F.coconut(130, 198, 3, true) F.coconut(126, 199, 2, true) F.coconut(128, 194, 2, false)
end

---------------------------------------------------------------- mid: a driftwood log bench under the palms, a far gnome on the road
F.depth(2)
do
  local lg = rect(112, 158, 146, 162) rimOf(lg, L.timber) part(lg, L.timber, { nopop = true })
  lg:each(function(x, y) if (x + y * 3) % 7 == 0 then px(x, y, L.timber.hi) end end)
  for x = 114, 144, 6 do px(x, 160, L.timber.deep) end F.logEnd(112, 160, 2)
  F.gnome(124, 160, { small = true, hat = L.roof2, coat = L.leaf, arm = "out", noShadow = true })
  F.gnome(136, 160, { small = true, hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  F.gnome(238, 146, { small = true, hat = L.lav, coat = L.roof, arm = "out" })
  px(248, 139, L.gold.base) px(248, 140, L.gold.shade)
end
F.depth(3)
for _, s in ipairs({ { 200, 206 }, { 186, 210 }, { 170, 212 }, { 150, 210 }, { 132, 208 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, bas) part(m, bas, { nopop = true }) px(s[1] - 2, s[2] - 1, basLit) px(s[1] - 1, s[2] - 1, bas.hi)
end

---------------------------------------------------------------- right of the road: hibiscus bushes, a small gnome with a coconut
F.depth(2)
F.hibiscus(278, 150, 14, 12, 61) F.hibiscus(298, 146, 10, 10, 62, "orange")
F.depth(3)
do
  local _, hx, hy = F.gnome(286, 192, { hat = L.awnA, coat = L.accent, arm = "hold" })
  F.coconut(hx, hy - 2, 3, true)
  vline(hx + 1, hy - 9, hy - 5, L.board.hi) px(hx + 2, hy - 9, L.awnA.base) -- a straw in it
end

---------------------------------------------------------------- the lotus pool: pads and flowers, taro, a gnome doing the washing
F.depth(3)
for _, p in ipairs({ { 60, 246 }, { 98, 258 }, { 124, 246 }, { 40, 260 }, { 150, 254 }, { 78, 238 } }) do
  local pad = c:ellipse(p[1], p[2], 6, 2):cut(poly{ { p[1], p[2] }, { p[1] + 7, p[2] - 2 }, { p[1] + 7, p[2] + 1 } })
  fill(pad, L.seagrass.base) px(p[1] - 4, p[2] - 1, L.seagrass.hi) px(p[1] - 3, p[2] - 1, L.seagrass.hi) px(p[1] + 2, p[2] + 1, L.seagrass.deep)
end
for _, f in ipairs({ { 98, 256 }, { 40, 258 }, { 78, 236 } }) do
  F.sprite({ "..p..", "p.P.p", "pPgPp", ".PPP." }, f[1] - 2, f[2] - 5, { p = L.petal.base, P = L.petal.hi, g = L.gold.hi })
end
-- taro / elephant-ear leaves at the pool's left edge
local function taro(x, yb, h, seed, flip)
  local s = flip and -1 or 1
  local m, stems = HP.mask(), HP.mask()
  for i = 1, 3 do
    local lx = x + (i - 2) * 6 * s
    local ly = yb - h + floor(hash(i, 1, seed) * 6)
    stems:add(line({ { x + (i - 2), yb }, { lx, ly + 6 } }, 1))
    local leaf = poly{ { lx - 6, ly }, { lx, ly - 4 }, { lx + 6, ly }, { lx + 1, ly + 9 } }:add(c:ellipse(lx, ly + 2, 5, 4))
    m:add(leaf)
  end
  c:rim(union(m, stems), L.foliage2.edge)
  stems:each(function(xx, yy) px(xx, yy, L.foliage2.shade) end)
  m:each(function(xx, yy)
    local lit = (xx - x) * s < 0 or hash(xx // 3, yy // 3, seed) < .3
    px(xx, yy, lit and L.foliage2.hi or L.foliage2.base)
    if not m:has(xx, yy + 1) then px(xx, yy, L.foliage2.shade) end
  end)
  for i = 1, 3 do
    local lx = x + (i - 2) * 6 * s
    local ly = yb - h + floor(hash(i, 1, seed) * 6)
    vline(lx, ly - 2, ly + 7, L.foliage2.deep) px(lx - 2, ly + 2, L.foliage2.shade) px(lx + 2, ly + 2, L.foliage2.shade)
  end
end
taro(30, 250, 24, 3)
taro(178, 266, 18, 4, true)
do -- the washer gnome on a flat lava stone with a pandanus basket of laundry and a washboard
  local st = c:ellipse(170, 236, 12, 3) rimOf(st, bas) part(st, bas, { nopop = true }) hline(162, 172, 234, bas.hi)
  local _, hx, hy = F.gnome(168, 232, { hat = L.awnB, coat = L.leaf, arm = "out", flip = true, noShadow = true })
  local wb = rect(hx - 6, hy - 6, hx, hy + 4) c:rim(wb, L.timber.edge) part(wb, L.timber, { nopop = true })
  for y = hy - 4, hy + 3, 2 do hline(hx - 5, hx - 1, y, L.timber.deep) end
  for k = 0, 2 do hline(hx - 12 - k * 2, hx - 6 + k * 2, hy + 7 + k * 2, Wt.hi) end
  local bsk = c:rrect(184, 222, 202, 234, 3) rimOf(bsk, L.rope) part(bsk, L.rope)
  bsk:each(function(x, y) if ((x // 2 + y // 2) % 2 == 0) then px(x, y, L.rope.shade) end end)
  fill(c:ellipse(189, 221, 4, 2), L.accent.base) fill(c:ellipse(196, 220, 4, 2), L.hibiscus.base) px(194, 219, L.hibiscus.hi) px(187, 220, L.accent.hi)
end

---------------------------------------------------------------- tree ferns, heliconia, torch ginger round the rocks
F.depth(3)
local function treeFern(x, yb, h, seed)
  local tr = rect(x - 1, yb - h, x + 1, yb)
  rimOf(tr, fernTrunk) part(tr, fernTrunk, { nopop = true })
  tr:each(function(xx, yy) if hash(xx, yy, seed) < .35 then px(xx, yy, fernTrunk.deep) elseif xx == x - 1 and yy % 3 == 0 then px(xx, yy, fernTrunk.hi) end end)
  for k, a in ipairs({ -2.8, -2.2, -1.6, -1.0, -.35, 2.95, .2 }) do
    F.frond(x, yb - h, a + (hash(k, seed, 1) - .5) * .2, h * .7, .55, tfern, seed * 7 + k, { wide = .28 })
  end
  fill(rect(x - 1, yb - h - 1, x + 1, yb - h), fernTrunk.base) px(x, yb - h - 2, tfern.hi) -- a fiddlehead
  px(x + 1, yb - h - 3, tfern.base) px(x + 2, yb - h - 3, tfern.shade)
end
treeFern(462, 212, 30, 71)
local function fern(x, yb, s)
  for k = -2, 2 do
    local a = k * .45 - pi / 2
    local len = s - abs(k) * 2
    for t = 0, len do
      local fx = floor(x + cos(a + t * .04 * k) * t + .5)
      local fy = floor(yb + sin(a) * t + t * t * .02 * abs(k) + .5)
      px(fx, fy, t < 2 and tfern.deep or tfern.base)
      if t % 2 == 0 and t > 1 then px(fx - 1, fy + 1, tfern.shade) px(fx + 1, fy + 1, (t > len - 3) and tfern.hi or tfern.shade) end
    end
  end
end
fern(292, 214, 12) fern(306, 222, 10) fern(446, 218, 11) fern(376, 222, 9) fern(34, 214, 10) fern(16, 214, 9)
-- heliconia: paddle leaves and a hanging zig-zag of red bracts tipped gold
local function heliconia(x, yb, h, seed)
  local lv = HP.mask()
  for k = -1, 1 do
    local lx = x + k * 5
    lv:add(line({ { x + k, yb }, { lx, yb - h + 6 } }, 1))
    lv:add(c:ellipse(lx + k, yb - h + 4 + abs(k) * 2, 2, 5))
  end
  c:rim(lv, L.foliage.edge)
  lv:each(function(xx, yy) px(xx, yy, xx < x and L.foliage.hi or (hash(xx, yy, seed) < .4 and L.foliage.shade or L.foliage.base)) end)
  local sx, sy = x + 2, yb - h + 2
  vline(sx, sy, sy + 12, L.foliage2.deep)
  for i = 0, 4 do
    local bx = sx + ((i % 2 == 0) and -1 or 1) * 2
    local by = sy + 1 + i * 3
    local m = rect(math.min(sx, bx), by, math.max(sx, bx), by + 1)
    c:rim(m, L.apple.edge) fill(m, L.apple.base) px(bx, by, L.gold.hi) px(sx, by + 1, L.apple.shade)
  end
end
heliconia(344, 230, 22, 81) heliconia(458, 226, 18, 82)
-- torch ginger: long blade leaves, a stalk, a waxy red cone of overlapping bracts with a pink rim
for _, g in ipairs({ { 440, 226 }, { 450, 227 }, { 286, 222 } }) do
  local x, y = g[1], g[2]
  local lv = line({ { x, y }, { x - 7, y - 9 } }, 1):add(line({ { x, y }, { x + 6, y - 10 } }, 1)):add(line({ { x + 1, y }, { x + 9, y - 5 } }, 1))
  c:rim(lv, L.foliage2.edge) lv:each(function(xx, yy) px(xx, yy, xx < x and L.foliage2.hi or L.foliage2.base) end)
  vline(x, y - 12, y, L.foliage2.shade)
  local cone = poly{ { x - 3, y - 13 }, { x, y - 19 }, { x + 3, y - 13 }, { x, y - 11 } }
  c:rim(cone, L.apple.edge) fill(cone, L.awnA.base)
  cone:each(function(xx, yy) if (yy + (xx < x and 0 or 1)) % 2 == 0 then px(xx, yy, L.awnA.shade) end if xx < x and yy < y - 14 then px(xx, yy, L.awnA.hi) end end)
  hline(x - 3, x + 3, y - 13, L.petal.hi) px(x, y - 19, L.petal.base)
end
-- small orchid and ground flowers between the rocks
for i = 0, 9 do
  local x, y = 300 + floor(hash(i, 1, 71) * 160), 220 + floor(hash(i, 2, 71) * 12)
  if not F.roadM:has(x, y) and not brook:grow(3):has(x, y) and not (x >= 380 and y >= 228) then
    for k = -3, 3 do px(x + k, y + 1, L.seagrass.shade) if k % 2 == 0 then px(x + k, y, L.seagrass.base) end end
    F.flower(x - 1, y - 2, i % 3 == 0 and "plumeria" or (i % 3 == 1 and "orange" or "white"), true)
  end
end
-- lava stepping stones from the road to the pool
for _, s in ipairs({ { 292, 206 }, { 306, 202 }, { 322, 204 } }) do
  local m = c:ellipse(s[1], s[2], 5, 2) rimOf(m, bas) part(m, bas, { nopop = true }) px(s[1] - 2, s[2] - 1, basLit) px(s[1] - 1, s[2] - 1, bas.hi)
end

---------------------------------------------------------------- foreground life: taro by the brook, a water cart, birds, dragonflies
F.depth(3)
taro(352, 238, 18, 21) taro(366, 264, 20, 22, true)
do -- a gnome hauling a little water cart: a barrel on two wheels, slopping over
  local x, yb = 322, 266
  local bar = c:rrect(330, 242, 354, 260, 5)
  local shaft = line({ { 332, 256 }, { 326, 258 } }, 2)
  local wh = c:ellipse(342, 262, 6, 6)
  F.shadowM(c:ellipse(346, 268, 16, 1))
  rimOf(union(bar, shaft, wh), L.timber)
  part(bar, L.timber) F.planks(bar, L.timber, 4, true, 12)
  for _, hy in ipairs({ 245, 256 }) do hline(330, 354, hy, L.rope.shade) hline(331, 353, hy - 1, L.rope.hi) end -- coir rope hoops
  part(shaft, L.board, { nopop = true, noshade = true })
  part(wh, L.timber, { nopop = true }) fill(c:ellipse(342, 262, 3, 3), L.timber.shade)
  vline(342, 257, 267, L.timber.deep) hline(337, 347, 262, L.timber.deep) px(342, 262, L.iron.hi)
  fill(rect(339, 240, 345, 241), Wt.base) px(340, 240, Wt.hi)
  for _, p in ipairs({ { 348, 239 }, { 351, 238 }, { 355, 241 }, { 357, 245 }, { 336, 239 } }) do px(p[1], p[2], Wt.hi) end
  F.frond(338, 240, -2.6, 9, .3, L.leaf, 501, { wide = .3 }) -- a banana leaf over the bung
  F.gnome(x, yb, { hat = L.roof2, coat = L.board, arm = "out" })
end
-- a sacred kingfisher on the bridge rail: teal back, cream front, long dark bill
local kf = { "..TT...", ".TTTk..", "bbTeTT.", ".cTTTT.", ".ccTTt.", "..cct..", "..l.l.." }
local kf2 = {}
for _, row in ipairs(kf) do
  local r2 = ""
  for i = 1, #row do r2 = r2 .. row:sub(i, i):rep(2) end
  kf2[#kf2 + 1] = r2 kf2[#kf2 + 1] = r2
end
F.sprite(kf2, floor(F.xr(230)) - 6, 195,
  { T = L.accent.base, k = L.accent.hi, b = L.timber.edge, e = L.timber.edge, c = L.awnB.hi, t = L.accent.deep, l = L.timber.deep })
-- a lory perched on the basalt above the fall, and a white tern pair over the rocks
F.parrot(412, 104, "lory", true)
for _, d in ipairs({ { 296, 226 }, { 228, 236 }, { 120, 236 } }) do
  local x, y = d[1], d[2]
  hline(x - 3, x + 3, y, Wt.hi) px(x - 2, y - 1, GL) px(x + 2, y - 1, GL)
  vline(x, y - 1, y + 4, L.awnA.shade) px(x, y - 1, L.awnA.hi)
end

-- salt-crust and sand blown up the foot of the black rock so it sits on the sand rather than against it
do
  local bases = { bas.shade, bas.deep, bas.base }
  for y = 176, 214 do for x = 438, 474 do
    if rockM:has(x, y) then
      local v = c:get(x, y)
      for _, b in ipairs(bases) do
        if v == b and hash(x, y, 311) < (y - 170) / 90 then px(x, y, F.mix(v, "#e8d6b0", .3 + (y - 176) / 90)) break end
      end
    end
  end end
end
-- shells, tufts and a little driftwood on the plain sand left of the well and road
F.shell(62, 196, "conch", true) F.shell(120, 210, "scallop", true) F.shell(88, 214, "cowrie") F.shell(156, 200, "cowrie")
F.fern(48, 214, 5, L.mossGround) F.fern(104, 202, 4, L.mossGround) F.fern(188, 212, 4, L.mossGround)
F.flower(76, 206, "plumeria", true) F.flower(140, 214, "hibiscus", true) F.flower(34, 200, "white", true)
F.coral(70, 212, 4, L.coral)
F.depth(0)
F.birds({ { 330, 44, 2 }, { 340, 50, 1 }, { 168, 64, 2 }, { 186, 58, 2 }, { 236, 70, 1 } })
for _, t in ipairs({ { 402, 74 }, { 416, 80 } }) do -- white fairy terns
  local x, y = t[1], t[2]
  hline(x - 3, x + 3, y, L.awnB.hi) px(x - 4, y - 1, L.awnB.hi) px(x + 4, y - 1, L.awnB.hi) px(x, y + 1, L.awnB.shade) px(x + 1, y, L.timber.edge)
end
F.finish()
