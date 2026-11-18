-- shrine.lua : "Wayside shrine" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua), re-cast as a seamen's shrine
-- on a chalk-and-dune headland: road's end: a whitewashed sailors' chapel with tarred posts, a lichened slate roof
-- with gently lifted eaves and a gilded fish vane, a ship's wheel in the sea-blue gable; inside the open bay a
-- votive ship hangs over a candle-lit altar with a ship in a bottle; candles along a granite terrace, votive boats on
-- its corners, between two wind-bent hawthorns. Over the road: a sea-blue painted gate with a slate cap, glass floats
-- in rope cages and an anchor plaque; gulls on the cap. Back left: a tarred three-tier seamark tower with slate roofs
-- and a driftwood-topped cairn. Right back: the rag tree (a wind-bent hawthorn hung with rags, roped trunk, a
-- cormorant drying its wings on top) and the bell frame with a ship's bell and a lifebuoy. Left hero: the holy well
-- under a pantile roof (scallop carving, driftwood spout, shell scoops, a crab on the rim). Right hero: the votive
-- rack of painted boat and fish plaques, rags and knotted cords. Bottom left: a raked sand garden edged in shingle.
-- Paired ship's lanterns on granite posts, a brass censer, sea-buckthorn, marram and sea thrift.
-- Quirk (kept): a real fox kit sits on the plinth beside the stone fox, wearing its red bib.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 318, 352, 440 }, duneLineGap = { 180, 300 },
  boats = { { 164, 97, 7 }, { 330, 99, 9 }, { 352, 95, 6 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local RED, SH, PT, TAR, BLUE = L.awnA, L.roof, L.roof2, L.tar, L.wall2
local BRONZE = F.rp("#e6c27a #b88e50 #8a6a3c #5e4a30 #3a2e26")
local BELL = F.rp("#d6ae68 #a07a46 #7a5a36 #56402a #36281e")
local ROPE = F.rp("#ecdcaa #ccb47a #a68c58 #786440 #4e4230")
local RIB = { L.awnA, L.awnB, L.accent, L.gold, L.wall2, L.petal }

-- warm candle-light spill: tint what is already there toward the glow (hard pixels, no alpha)
local function glowSpill(cx, cy, r, k)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.4) ^ 2)
    if d <= r then local v = c:get(x, y) if v then px(x, y, F.mix(v, L.glow.hi, k * (1 - d / (r + 1)) + .04)) end end
  end end
end
local function candle(x, yb, tall)
  local h = tall or 3
  vline(x, yb - h + 1, yb, L.awnB.hi) px(x + 1, yb - h + 2, L.awnB.shade) vline(x + 1, yb - h + 2, yb, L.awnB.shade)
  px(x, yb - h, L.glow.base) px(x, yb - h - 1, L.glow.hi)
end
-- a rag strip fluttering down from (x,y)
local function ribbon(x, y, len, r, dir)
  dir = dir or 1
  for k = 0, len do
    local xx = x + ((k > len // 2) and dir or 0)
    px(xx, y + k, k == 0 and r.hi or r.base) px(xx + 1, y + k, k == len and r.deep or r.shade)
  end
end
-- a cord sagging from a to b with little signal-flag pennants
local function bunting(x0, y0, x1, y1, sag, every)
  local function ly(xx) local t = (xx - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  for xx = x0, x1 do px(xx, ly(xx), ROPE.deep) end
  local i = 0
  for xx = x0 + 3, x1 - 4, every do
    i = i + 1
    local r = RIB[i % #RIB + 1]
    local yy = ly(xx) + 1
    local m = poly{ { xx, yy }, { xx + 3, yy }, { xx + 1, yy + 4 } }
    fill(m, r.base) px(xx, yy, r.hi) px(xx + 3, yy, r.shade) px(xx + 1, yy + 4, r.deep)
    if i % 3 == 0 then px(xx + 1, yy + 1, L.awnB.hi) end -- a white spot flag
  end
end
-- a little model boat (votive): hull ramp, sail colour, bow right (flip mirrors)
local function modelBoat(x, yb, len, hull, sail, flip)
  local s = flip and -1 or 1
  local h = math.max(2, len // 4)
  local hm = poly{ { x - len // 2 * s, yb - h }, { x + (len // 2 + 1) * s, yb - h - 1 }, { x + (len // 2 - 2) * s, yb }, { x - (len // 2 - 2) * s, yb } }
  local mast = rect(x, yb - h - len + 2, x, yb - h)
  local sl = poly{ { x - 1 * s, yb - h - len + 3 }, { x + floor(len * .4) * s, yb - h - 2 }, { x - floor(len * .2) * s, yb - h - 2 } }
  local m = union(hm, mast, sl)
  rimOf(m, TAR)
  part(hm, hull, { nopop = true }) hline(x - len // 2, x + len // 2, yb - h, L.awnB.hi)
  part(mast, L.timber, { nopop = true, noshade = true })
  part(sl, sail, { nopop = true })
  return m
end

-- lifted-eave roof: eave from x0..x1 at y (bottom), ridge from rx0..rx1 at yt; tips lift a little
local function flare(x0, x1, y, rx0, rx1, yt, r, lk, seed, tile)
  local m = poly{ { x0 - 2, y - 2 }, { x0 + 4, y - 1 }, { rx0, yt }, { rx1, yt }, { x1 - 4, y - 1 }, { x1 + 2, y - 2 }, { x1 - 2, y + 2 }, { x0 + 2, y + 2 } }
  rimOf(m, r) part(m, r, { sep = true })
  if tile then
    F.pantile(m:copy():clip(rect(0, 0, 479, y)), r, yt, seed)
  else
    m:each(function(x, yy)
      if yy < y then
        local row, ry = (yy - yt) // 3, (yy - yt) % 3
        if ry == 2 then px(x, yy, r.deep)
        elseif (x + row * 3) % 6 == 0 then px(x, yy, r.shade)
        elseif ry == 0 and hash(x, yy, 83) < .35 then px(x, yy, r.hi) end
      end
    end)
  end
  F.lichen(m, lk or .05, seed or 81)
  hline(rx0, rx1, yt, r.hi)
  hline(x0 + 2, x1 - 2, y + 2, r.deep) hline(x0 + 2, x1 - 2, y + 1, r.shade)
  return m
end

---------------------------------------------------------------- back-left: tarred three-tier seamark tower
local function seamark(cx, yb)
  F.shadow(cx - 16, cx + 16, yb, 8, 3)
  local base = rect(cx - 18, yb - 4, cx + 18, yb)
  rimOf(base, L.stone) part(base, L.stone) F.courses(base, yb - 4, 5, 8, L.stone) F.lichen(base, .2, 84)
  local y = yb - 4
  for i = 0, 2 do
    local w = 13 - i * 3
    local body = rect(cx - w, y - 11, cx + w, y)
    local bandR = (i == 1) and L.plaster or TAR
    rimOf(body, TAR) part(body, bandR) F.planks(body, bandR, 3, true, 20 + i)
    hline(cx - w, cx + w, y - 11, TAR.edge) hline(cx - w, cx + w, y - 10, bandR.deep)
    F.window(cx - 1, y - 8, cx + 1, y - 5, BLUE, true)
    y = y - 11
    local cap = poly{ { cx - w - 2, y }, { cx - w + 1, y - 6 }, { cx + w - 1, y - 6 }, { cx + w + 2, y } }
    rimOf(cap, SH) part(cap, SH, { sep = true }) hline(cx - w + 1, cx + w - 1, y - 6, SH.hi) hline(cx - w - 1, cx + w + 1, y, SH.deep)
    y = y - 6
  end
  local spire = rect(cx - 1, y - 14, cx, y)
  rimOf(spire, SH) part(spire, SH, { nopop = true, noshade = true })
  for k = 0, 2 do hline(cx - 2, cx + 1, y - 4 - k * 3, SH.shade) end
  -- gilded fish vane
  vline(cx, y - 19, y - 15, TAR.edge)
  F.sprite({ "g..gg.", "ggggGe", "g..gg." }, cx - 3, y - 21, { g = L.gold.base, G = L.gold.hi, e = TAR.edge }, { rimCol = L.gold.edge })
end
F.depth(1)
F.tree(86, 128, 48, 4)
F.tree(22, 132, 34, 1)
seamark(48, 134)
-- a stacked-stone cairn, a bleached driftwood stick standing in its top
local function cairn(x, yb, s, stick)
  local y = yb
  for k = 0, s - 1 do
    local w, h = floor((s - k) * 1.6) + 1, 2 + (s - k) // 2
    local m = c:ellipse(x + (k % 2), y - h // 2 - 1, w, math.max(1, h // 2))
    rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    px(x + (k % 2) - w // 2, y - h + 1, L.stone.hi)
    if k == 0 or hash(k, x, 86) < .5 then px(x + (k % 2), y - h, hash(k, x, 87) < .5 and L.lichen.base or L.moss.base) end
    y = y - h
  end
  if stick then F.driftwood(x + 1, y + 1, x + 3, y - stick, 1) ribbon(x + 3, y - stick + 1, 4, RED) end
end
cairn(76, 136, 5, 9)

---------------------------------------------------------------- the road's end: terrace, steps, the sailors' chapel between two hawthorns
F.depth(2)
F.windTree(172, 128, 68, L.foliage2, 61)
F.windTree(296, 128, 58, L.foliage, 62)
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, L.stone) part(terr, L.stone) F.courses(terr, 112, 5, 12, L.stone) F.lichen(terr, .1, 87)
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, L.road.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
  for x = 229 + k, 251 - k do if hash(x, y, 88) < .14 then px(x, y + 1, L.sand.base) end end
end
-- chapel: whitewashed stone between tarred posts
local hall = rect(204, 92, 276, 112)
rimOf(hall, TAR) part(hall, L.plaster)
hall:each(function(x, y)
  if y % 4 == 0 and hash(x // 5, y, 21) < .35 then px(x, y, L.plaster.shade) end
  if y >= 109 and hash(x // 2, y, 22) < .45 then px(x, y, L.sand.shade) end -- blown sand at the foot
end)
for _, x in ipairs({ 204, 216, 228, 252, 264, 274 }) do fill(rect(x, 92, x + 2, 112), TAR.base) vline(x, 92, 112, TAR.hi) vline(x + 2, 92, 112, TAR.deep) end
for _, d in ipairs({ { 218, 226 }, { 254, 262 } }) do
  local m = rect(d[1], 97, d[2], 110) part(m, BLUE, { nopop = true })
  m:each(function(x, y) if (x - d[1]) % 3 == 0 then px(x, y, BLUE.shade) end if y == 97 then px(x, y, BLUE.hi) end end)
  hline(d[1], d[2], 103, BLUE.deep) px(d[2] - 2, 104, L.gold.base)
end
-- open middle bay: dark nave, a votive ship hanging, a candle-lit altar with a ship in a bottle
fill(rect(231, 96, 249, 112), L.soil.deep)
fill(rect(233, 98, 247, 110), L.tar.shade)
vline(240, 96, 97, ROPE.base)
fill(c:ellipse(240, 98, 7, 3), F.mix(L.tar.shade, L.glow.deep, .28))
modelBoat(240, 100, 9, PT, L.awnB)
local box = rect(232, 107, 248, 112) rimOf(box, TAR) part(box, L.board) for x = 234, 246, 3 do px(x, 109, L.board.deep) end
hline(232, 248, 107, L.board.hi)
-- the bottle on its cradle
local bottle = rect(236, 102, 243, 106):add(rect(244, 103, 245, 105))
rimOf(bottle, L.glass)
bottle:each(function(x, y) px(x, y, F.mix(L.glass.base, L.glow.base, .2)) end)
hline(237, 244, 102, L.glass.hi) px(236, 103, L.glass.base) hline(237, 242, 106, L.glass.deep)
px(246, 103, L.cork.hi) px(246, 104, L.cork.base) px(246, 105, L.cork.shade)
hline(238, 241, 105, PT.deep) px(242, 104, PT.base) vline(239, 103, 104, L.awnB.hi) px(240, 104, L.awnB.hi) px(240, 103, L.awnB.base)
px(237, 107, L.timber.deep) px(242, 107, L.timber.deep)
candle(233, 106, 3) candle(247, 106, 3)
glowSpill(240, 106, 7, .22)
-- slate roof with lifted eaves
flare(188, 292, 90, 214, 266, 66, SH, .03, 89)
local ridge = rect(212, 62, 268, 66) rimOf(ridge, SH) part(ridge, SH, { nopop = true }) hline(212, 268, 62, SH.hi) F.lichen(ridge, .07, 90)
-- stone ridge-end knobs and a gilded fish vane on the ridge
for _, x in ipairs({ 211, 269 }) do local k = c:ellipse(x, 61, 2, 2) rimOf(k, L.stone) part(k, L.stone, { nopop = true }) end
vline(240, 51, 61, TAR.edge) hline(238, 242, 58, TAR.edge)
F.sprite({ "gg...ggg..", ".gggggGge.", "gg...ggg.." }, 235, 48, { g = L.gold.base, G = L.gold.hi, e = TAR.edge }, { rimCol = L.gold.edge })
-- sea-blue boarded gable with a gilded ship's wheel
local gab = poly{ { 228, 88 }, { 240, 72 }, { 252, 88 } } fill(gab, BLUE.base) c:edgeIn(gab, BLUE.deep)
F.planks(gab, BLUE, 3, true, 22)
local wheel = c:ellipse(240, 82, 3, 3):cut(c:ellipse(240, 82, 1, 1))
fill(wheel, L.gold.base) px(238, 80, L.gold.hi) px(239, 79, L.gold.hi) px(242, 84, L.gold.shade) px(241, 85, L.gold.shade)
px(240, 82, L.gold.deep)
for _, d in ipairs({ { -5, 0 }, { 5, 0 }, { 0, -5 }, { 0, 5 }, { -4, -4 }, { 4, -4 }, { -4, 4 }, { 4, 4 } }) do px(240 + d[1], 82 + d[2], L.gold.shade) end
-- hemp rope across the front with signal-flag pennants
for x = 206, 274 do
  local yy = 93 + floor(2 * sin((x - 206) / 68 * pi))
  px(x, yy, ROPE.shade) px(x, yy + 1, (x % 3 == 0) and ROPE.hi or ROPE.base)
end
for i, x in ipairs({ 209, 214, 220, 225, 255, 260, 266, 271 }) do
  local y = 95 + floor(2 * sin((x - 206) / 68 * pi))
  local r = RIB[i % #RIB + 1]
  fill(poly{ { x, y }, { x + 3, y }, { x + 1, y + 4 } }, r.base) px(x, y, r.hi) px(x + 1, y + 4, r.deep)
end
-- candles along the foot of the terrace, either side of the steps
for x = 212, 225, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
for x = 256, 269, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
glowSpill(218, 127, 6, .3) glowSpill(262, 127, 6, .3)
-- votive boats on the terrace corners
modelBoat(196, 124, 9, BLUE, L.awnB)
modelBoat(284, 124, 9, PT, L.gold, true)

---------------------------------------------------------------- right back: the rag tree + bell frame
local function ragTree()
  F.shadow(392, 434, 162, 10, 4)
  local trunk = poly{ { 394, 162 }, { 401, 156 }, { 404, 136 }, { 409, 116 }, { 416, 104 }, { 424, 104 }, { 417, 118 }, { 414, 138 }, { 416, 156 }, { 424, 162 } }
  local boughs = union(line({ { 410, 116 }, { 396, 102 } }, 2), line({ { 416, 108 }, { 446, 96 } }, 2), line({ { 420, 104 }, { 432, 84 } }, 2))
  local function paintTrunk(m, again)
    m:each(function(x, y)
      local edge = not trunk:has(x - 1, y) or not trunk:has(x + 1, y)
      if again and edge then px(x, y, L.timber.edge) return end
      if not again then return end
      px(x, y, x > 410 - (y - 104) * .12 and L.timber.shade or L.timber.base)
    end)
    m:each(function(x, y)
      if again and (not trunk:has(x - 1, y) or not trunk:has(x + 1, y)) then return end
      if hash(x, y // 3, 34) < .22 then px(x, y, L.timber.deep) elseif x < 406 - (y - 130) * .2 and hash(x, y // 2, 35) < .45 then px(x, y, L.timber.hi) end
      if y > 150 and hash(x // 2, y, 36) < .3 then F.lichen(rect(x, y, x, y), 1, 37) end
    end)
  end
  rimOf(union(trunk, boughs), L.timber) part(trunk, L.timber) part(boughs, L.timber, { nopop = true })
  paintTrunk(trunk)
  local crownM = HP.mask()
  for i, lb in ipairs({ { 396, 98, 15, 11 }, { 424, 84, 30, 18 }, { 454, 94, 20, 13 }, { 414, 104, 14, 8 }, { 440, 104, 14, 8 } }) do
    crownM:add(F.crown(lb[1], lb[2], lb[3], lb[4], L.foliage2, 33 + i))
  end
  -- windward (left) face clipped: a lit comb of twig tips; lee side drips darker
  crownM:each(function(x, y)
    if not crownM:has(x, y - 1) and hash(x, y, 38) < .4 then px(x, y - 1, x < 420 and L.foliage2.hi or L.foliage2.shade) end
    if not crownM:has(x, y + 1) and x > 424 and hash(x, y, 39) < .5 then px(x, y + 1, L.foliage2.edge) end
  end)
  local again = trunk:copy():cut(crownM)
  again:each(function(x, y) px(x, y, L.timber.base) end)
  paintTrunk(again, true)
  for y = 108, 160 do for x = 394, 424 do
    if trunk:has(x, y) and not crownM:has(x, y) and trunk:has(x - 1, y) and trunk:has(x + 1, y) then
      if hash(x, y // 5, 41) < .1 and hash(x, y, 42) < .8 then px(x, y, L.timber.deep) end
      if hash(x // 2, y // 4, 43) < .06 then px(x, y, L.lichen.base) end
    end
  end end
  local knot = c:ellipse(409, 126, 2, 3) rimOf(knot, L.timber) fill(knot, L.soil.deep) px(408, 124, L.timber.shade) px(410, 129, L.timber.hi)
  -- roped trunk with knotted cords
  for x = 401, 416 do local yy = 136 + (x - 401) // 6 px(x, yy, ROPE.shade) px(x, yy + 1, (x % 3 == 0) and ROPE.hi or ROPE.base) px(x, yy + 2, ROPE.deep) end
  for _, x in ipairs({ 405, 412 }) do local y = 139 + (x - 401) // 6 vline(x, y, y + 6, ROPE.base) px(x, y + 3, ROPE.deep) px(x, y + 7, ROPE.deep) end
  -- rags tied along the low boughs: find the crown's underside
  local i = 0
  for x = 384, 468, 6 do
    local yb
    for y = 125, 60, -1 do if crownM:has(x, y) then yb = y break end end
    if yb then i = i + 1 ribbon(x, yb - 1, 6 + i % 4, RIB[i % #RIB + 1], (i % 2 == 0) and 1 or -1) end
  end
  -- a cormorant drying its wings on the top of the crown
  F.sprite({
    "K.............K",
    "KK...........KK",
    "KKK...hh....KKK",
    ".KKK.hheY..KKK.",
    ".KKKKhh.YYKKKK.",
    "..KKKhhhKKKKK..",
    "...KKhhhhKKK...",
    ".....hhhhK.....",
    ".....hwwh......",
    "......hh.......",
    "......y.y......",
  }, 418, 55, { K = TAR.base, h = TAR.shade, e = L.glass.hi, Y = L.gold.base, w = L.awnB.base, y = L.tar.deep }, { rimCol = TAR.edge })
end
local function bellFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local roofm = poly{ { x0 - 8, yb - 34 }, { x0 + 4, yb - 44 }, { x0 + 28, yb - 44 }, { x0 + 40, yb - 34 }, { x0 + 38, yb - 31 }, { x0 - 6, yb - 31 } }
  local bm = poly{ { x0 + 13, yb - 31 }, { x0 + 19, yb - 31 }, { x0 + 20, yb - 27 }, { x0 + 21, yb - 22 }, { x0 + 23, yb - 17 }, { x0 + 25, yb - 13 }, { x0 + 25, yb - 11 }, { x0 + 7, yb - 11 }, { x0 + 7, yb - 13 }, { x0 + 9, yb - 17 }, { x0 + 11, yb - 22 }, { x0 + 12, yb - 27 } }
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, roofm, bm), TAR)
  part(posts, TAR, { nopop = true })
  part(roofm, SH) F.courses(roofm, yb - 44, 3, 5, SH) F.lichen(roofm, .04, 91) hline(x0 - 6, x0 + 38, yb - 31, SH.deep)
  part(bm, BELL)
  hline(x0 + 11, x0 + 21, yb - 22, BELL.deep) hline(x0 + 8, x0 + 24, yb - 12, BELL.deep) hline(x0 + 9, x0 + 23, yb - 14, BELL.hi) vline(x0 + 13, yb - 29, yb - 24, BELL.hi)
  bm:each(function(x, y) if y > yb - 20 and hash(x, y, 92) < .14 then px(x, y, L.glass.shade) end end) -- verdigris
  -- the bell rope with a turk's-head knot
  vline(x0 + 16, yb - 11, yb - 4, ROPE.base) px(x0 + 16, yb - 3, ROPE.deep) px(x0 + 15, yb - 4, ROPE.hi) px(x0 + 17, yb - 4, ROPE.shade)
  local log = rect(x0 + 24, yb - 22, x0 + 38, yb - 19) rimOf(log, TAR) part(log, L.timber, { nopop = true }) F.logEnd(x0 + 38, yb - 21, 2)
  vline(x0 + 27, yb - 31, yb - 23, TAR.edge) vline(x0 + 35, yb - 31, yb - 23, TAR.edge)
  -- a lifebuoy hung on the left post
  local ring = c:ellipse(x0 + 1, yb - 14, 5, 5):cut(c:ellipse(x0 + 1, yb - 14, 2, 2))
  rimOf(ring, L.awnA)
  ring:each(function(x, y)
    local a = math.atan(y - (yb - 14), x - (x0 + 1))
    local q = floor((a + pi) / (pi / 2) + .5) % 2
    local r = q == 0 and L.awnA or L.awnB
    local lt = (x - x0 - 1) + (y - yb + 14)
    px(x, y, lt < -3 and r.hi or (lt > 3 and r.shade or r.base))
  end)
  fill(c:ellipse(x0 + 1, yb - 14, 2, 2):cut(c:ellipse(x0 + 1, yb - 14, 1, 1)), BLUE.deep) px(x0 + 1, yb - 14, TAR.base)
  px(x0 - 3, yb - 18, ROPE.hi) px(x0 + 5, yb - 10, ROPE.shade)
end
ragTree()
bellFrame(300, 140)
bunting(334, 107, 398, 118, 3, 6)
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = L.accent, arm = "up", flip = true })
line({ { rx, ry }, { 316, 134 } }):each(function(x, y) px(x, y, ROPE.deep) end)

---------------------------------------------------------------- the painted gate over the road
local function gatePosts()
  local postL, postR = rect(204, 122, 209, 198), rect(271, 122, 276, 198)
  local kasagi = poly{ { 184, 110 }, { 194, 114 }, { 286, 114 }, { 296, 110 }, { 294, 118 }, { 186, 118 } }
  local shimaki = rect(192, 119, 288, 122)
  local nuki = rect(198, 132, 282, 136)
  local plaque = rect(234, 122, 246, 131)
  local feet = rect(202, 194, 211, 199):add(rect(269, 194, 278, 199))
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, kasagi, shimaki, nuki, plaque, feet)
  rimOf(sil, TAR)
  for _, p in ipairs({ { postL, 204 }, { postR, 271 } }) do
    part(p[1], BLUE)
    p[1]:each(function(x, y)
      local k = x - p[2]
      if k == 1 then px(x, y, BLUE.hi) elseif k == 5 then px(x, y, BLUE.shade)
      elseif hash(x, y // 4, 93) < .16 then px(x, y, BLUE.shade) end
      -- flaking paint: bare grey wood showing through
      if hash(x // 2, y // 3, 94) < .1 then px(x, y, k <= 2 and L.timber.hi or L.timber.base) end
      if y > 182 and hash(x, y // 2, 95) < .25 + (y - 182) * .03 then px(x, y, hash(x, y, 96) < .5 and L.awnB.shade or L.kelp.base) end
    end)
  end
  part(nuki, L.timber, { nopop = true }) F.logs(nuki, L.timber, 132, 5)
  F.logEnd(198, 134, 2) F.logEnd(282, 134, 2)
  part(shimaki, TAR, { nopop = true }) hline(192, 288, 119, TAR.hi)
  part(kasagi, SH, { nopop = true }) F.courses(kasagi, 110, 3, 5, SH) F.lichen(kasagi, .06, 97)
  hline(194, 286, 114, SH.hi) hline(186, 294, 117, SH.deep) hline(186, 294, 118, TAR.deep)
  part(feet, L.stone, { nopop = true }) F.barnacles(feet, .3, 98, 0)
  part(plaque, L.board) c:edgeIn(plaque, TAR.base)
  -- a gilded anchor on the plaque
  F.sprite({ "..a..", ".aaa.", "..a..", "a.a.a", ".aaa." }, 238, 124, { a = L.gold.shade }, { rim = false })
  px(240, 124, L.gold.hi) px(238, 127, L.gold.hi)
  -- rope lashings with glass floats in rope cages hanging off the tie beam
  for i, p in ipairs({ { 204, 150 }, { 209, 162 }, { 271, 154 }, { 276, 166 } }) do
    hline(p[1] - (p[1] % 2 == 0 and 0 or 5), p[1] + (p[1] % 2 == 0 and 5 or 0), p[2], ROPE.base)
    hline(p[1] - (p[1] % 2 == 0 and 0 or 5), p[1] + (p[1] % 2 == 0 and 5 or 0), p[2] + 1, ROPE.deep)
    ribbon(p[1] + (i % 2 == 0 and 1 or -1), p[2] + 2, 5, RIB[i % #RIB + 1], i % 2 == 0 and 1 or -1)
  end
  for _, g in ipairs({ { 214, 143 }, { 266, 143 } }) do
    vline(g[1], 137, g[2] - 4, ROPE.deep)
    local b = c:ellipse(g[1], g[2], 3, 3) rimOf(b, L.glass) part(b, L.glass, { nopop = true })
    px(g[1] - 1, g[2] - 2, L.glass.hi) px(g[1] - 2, g[2] - 1, L.foam)
    hline(g[1] - 3, g[1] + 3, g[2], ROPE.shade) vline(g[1], g[2] - 3, g[2] + 3, ROPE.shade)
  end
end

---------------------------------------------------------------- ship's lantern on a granite post, scaled by depth
local function lantern(x, yb, s)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local base = R(-5, -3, 5, 0)
  local post = R(-3, -14, 3, -3)
  local box = R(-4, -22, 4, -14)
  local hood = poly{ { x - 6 * s, yb - 22 * s }, { x - 2 * s, yb - 26 * s }, { x + 2 * s, yb - 26 * s }, { x + 6 * s, yb - 22 * s } }
  local ring = R(-1, -29, 1, -26)
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(base, post, box, hood, ring), TAR)
  part(base, L.stone) part(post, L.stone, { nopop = true }) F.lichen(post, .18, 61 + x)
  part(box, BRONZE, { nopop = true })
  local win = R(-3, -21, 3, -15) fill(win, L.glow.base)
  win:each(function(xx, y) if not win:has(xx + 1, y) or not win:has(xx, y + 1) then px(xx, y, L.glow.shade) end end)
  px(floor(x - 2 * s), floor(yb - 20 * s), L.glow.hi)
  vline(x, floor(yb - 21 * s), floor(yb - 15 * s), BRONZE.shade) -- the glazing bar
  part(hood, TAR, { nopop = true }) hline(floor(x - 6 * s), floor(x + 6 * s), floor(yb - 22 * s), BRONZE.base)
  px(floor(x - 3 * s), floor(yb - 24 * s), TAR.hi)
  if s >= 1 then local rg = R(-1, -29, 1, -26) part(rg, BRONZE, { nopop = true }) px(x, floor(yb - 28 * s), TAR.deep)
  else fill(ring, BRONZE.base) end
  base:each(function(xx, y) if hash(xx, y, 63) < .25 then px(xx, y, L.sand.shade) end end)
end

---------------------------------------------------------------- left hero: holy well under a pantile roof
local function holyWell()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, TAR) part(posts, TAR, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 64) < .2 then px(x, y, TAR.shade) end if y > 204 and hash(x, y, 65) < .5 then px(x, y, L.sand.shade) end end)
  flare(x0 - 6, x1 + 6, yt + 8, x0 + 16, x1 - 16, yt - 14, PT, .025, 66, true)
  local rid = rect(x0 + 14, yt - 18, x1 - 14, yt - 14) rimOf(rid, PT) part(rid, PT, { nopop = true }) F.lichen(rid, .08, 67)
  local tri = poly{ { 128, yt + 4 }, { 140, yt - 10 }, { 152, yt + 4 } } fill(tri, L.plaster.base) c:edgeIn(tri, L.plaster.deep)
  tri:each(function(x, y) if y % 3 == 0 and hash(x // 4, y, 23) < .3 then px(x, y, L.plaster.shade) end end)
  -- carved scallop shell (the pilgrim's mark)
  F.sprite({ ".sssss.", "sSsSsSs", "sSsSsSs", ".sSsSs.", "..sss..", "...s..." }, 137, yt - 5, { s = L.gold.shade, S = L.gold.hi }, { rim = false })
  -- granite basin, lichen on top
  local front = rect(112, 190, 168, 208)
  local topm = poly{ { 108, 190 }, { 172, 190 }, { 168, 182 }, { 112, 182 } }
  rimOf(union(front, topm), L.stone)
  part(front, L.stone) F.courses(front, 190, 9, 14, L.stone, 3) F.lichen(front, .08, 68)
  part(topm, L.stone, { sep = true }) F.lichen(topm, .07, 69)
  local wat = poly{ { 114, 188 }, { 166, 188 }, { 163, 184 }, { 117, 184 } } F.water(wat, L.water, { step = 2 })
  -- floating thrift petals
  for _, k in ipairs({ { 124, 186 }, { 140, 187 }, { 156, 185 } }) do px(k[1], k[2], L.petal.hi) px(k[1] + 1, k[2], L.petal.base) end
  -- lichened rock spring with a driftwood spout and a trickle
  F.lichen(F.rock(178, 190, 9, 14), .35, 70)
  local sp = rect(148, 168, 176, 171)
  rimOf(sp, TAR) part(sp, L.timber, { nopop = true }) hline(149, 175, 168, L.timber.hi) hline(149, 175, 169, L.water.base)
  F.logEnd(148, 170, 2)
  vline(148, 172, 184, L.water.hi) vline(149, 173, 184, L.water.base)
  px(147, 184, L.water.hi) px(151, 184, L.water.hi)
  vline(164, 172, 181, L.timber.base) vline(165, 172, 181, L.timber.deep)
  -- scallop-shell scoops on driftwood handles laid across
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 181 }, { lx + 10, 178 } }), L.timber.hi)
    hline(lx - 2, lx + 1, 180, L.awnB.hi) hline(lx - 3, lx + 1, 181, L.awnB.base) hline(lx - 2, lx, 182, L.awnB.shade)
    px(lx - 2, 181, L.petal.hi) px(lx, 181, L.awnB.shade)
  end
  -- a little shore crab on the basin rim
  F.sprite({ "c.e.e.c", ".CCCCC.", "CcCCCcC", "c.c.c.c" }, 158, 179, { e = TAR.edge, C = PT.base, c = PT.shade }, { rimCol = PT.edge })
end

---------------------------------------------------------------- right hero: votive rack of boat and fish plaques, rags and knotted cords
local function votiveRack()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local roofm = poly{ { x0 - 6, yt }, { x0 + 4, yt - 8 }, { x1 - 4, yt - 8 }, { x1 + 6, yt }, { x1 + 4, yt + 3 }, { x0 - 4, yt + 3 } }
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, roofm, rails), TAR)
  part(posts, TAR, { nopop = true }) part(rails, L.timber, { nopop = true, noshade = true })
  part(roofm, PT) F.pantile(roofm:copy():clip(rect(0, 0, 479, yt + 1)), PT, yt - 8, 72) F.lichen(roofm, .025, 72) hline(x0 - 4, x1 + 4, yt + 3, PT.deep)
  local cols = { L.awnA, L.accent, L.wall2, L.produce, L.gold }
  for row = 0, 1 do
    local yy = row == 0 and 174 or 192
    for k = 0, 9 do
      local x = x0 + 5 + k * 8 + (row == 1 and 3 or 0)
      if x + 6 < x1 - 3 then
        if row == 1 and k % 3 ~= 1 then
          for j = 0, 2 do
            if (k + j) % 4 == 0 then -- a knotted cord
              vline(x + j * 2, yy, yy + 8, ROPE.base) px(x + j * 2, yy + 3, ROPE.deep) px(x + j * 2, yy + 6, ROPE.deep) px(x + j * 2 + 1, yy + 8, ROPE.shade)
            else ribbon(x + j * 2, yy, 7 + (j + k) % 4, RIB[(k + j) % #RIB + 1]) end
          end
        else
          local m = poly{ { x, yy + 2 }, { x + 3, yy }, { x + 6, yy + 2 }, { x + 6, yy + 9 }, { x, yy + 9 } }
          c:rim(m, L.board.edge) fill(m, L.board.hi) hline(x, x + 6, yy + 9, L.board.shade) vline(x + 6, yy + 2, yy + 9, L.board.base)
          local cr = cols[(k + row * 2) % 5 + 1]
          if k % 2 == 0 then -- a painted little boat under sail
            vline(x + 3, yy + 3, yy + 6, L.timber.deep) px(x + 2, yy + 4, L.awnB.base) px(x + 2, yy + 5, L.awnB.shade) px(x + 4, yy + 5, L.awnB.base)
            hline(x + 1, x + 5, yy + 7, cr.base) hline(x + 2, x + 4, yy + 8, cr.shade)
          else -- a painted fish
            hline(x + 2, x + 4, yy + 5, cr.base) px(x + 3, yy + 4, cr.hi) px(x + 3, yy + 6, cr.shade) px(x + 1, yy + 4, cr.shade) px(x + 1, yy + 6, cr.shade) px(x + 4, yy + 4, TAR.edge)
          end
          px(x + 3, yy + 1, RED.base)
        end
      end
    end
  end
end
local function fox(x, yb, flip, real, bare)
  local s = flip and -1 or 1
  local r = real and L.produce or L.stone
  local body = poly{ { x - 4 * s, yb }, { x - 4 * s, yb - 10 }, { x - 2 * s, yb - 14 }, { x + 3 * s, yb - 14 }, { x + 4 * s, yb } }
  local head = poly{ { x - 3 * s, yb - 14 }, { x - 3 * s, yb - 20 }, { x - 1 * s, yb - 18 }, { x + 2 * s, yb - 18 }, { x + 3 * s, yb - 21 }, { x + 4 * s, yb - 16 }, { x + 7 * s, yb - 15 }, { x + 3 * s, yb - 13 } }
  local tail = line({ { x - 4 * s, yb - 2 }, { x - 8 * s, yb - 6 }, { x - 7 * s, yb - 12 } }, 3)
  local m = union(body, head, tail)
  rimOf(m, r) part(m, r)
  px(x + 1 * s, yb - 16, r.edge) px(x + 7 * s, yb - 15, TAR.edge)
  if not real then
    m:each(function(xx, y) if not m:has(xx, y - 1) and hash(xx, y, 74) < .45 then px(xx, y, hash(xx, y, 73) < .5 and L.lichen.base or L.moss.base) elseif hash(xx // 2, y // 2, 75) < .1 then px(xx, y, L.moss.shade) end end)
    if not bare then local bib = poly{ { x - 3 * s, yb - 13 }, { x + 3 * s, yb - 13 }, { x, yb - 8 } } fill(bib, RED.base) px(x, yb - 12, RED.hi) end
  end
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, L.stone) part(m, L.stone) hline(x - w, x + w, yb - h, L.stone.hi) F.lichen(m, .14, 76 + x)
end

---------------------------------------------------------------- raked sand garden edged in shingle (bottom-left)
local function sandGarden()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(3):cut(g)
  edge:each(function(x, y) local v = hash(x // 2, y // 2, 77) px(x, y, v < .35 and L.shingle.base or (v < .6 and L.shingle.shade or (v < .85 and L.shingle.hi or L.shingle.deep))) end)
  g:each(function(x, y) px(x, y, L.sand.hi) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    if best < 14 then if floor(best) % 3 == 0 then px(x, y, L.sand.shade) end
    elseif (y + floor(sin(x / 20) * 1.5)) % 3 == 0 then px(x, y, L.sand.base) end
  end)
  local r1 = F.rock(56, 250, 12, 12) F.lichen(r1, .18, 79) F.barnacles(r1, .06, 79, 246)
  F.lichen(F.rock(120, 251, 9, 9), .2, 80) F.lichen(F.rock(129, 252, 5, 5), .2, 81)
  -- a few shells laid in the raked sand
  for _, s in ipairs({ { 36, 240 }, { 88, 236 }, { 100, 258 }, { 146, 244 } }) do F.shell(s[1], s[2], true) end
  for _, f in ipairs({ { 18, 232, 6 }, { 24, 228, 5 }, { 160, 228, 6 }, { 166, 262, 7 } }) do F.marram(f[1], f[2], f[3]) end
  F.thrift(28, 266, true) F.thrift(154, 268, false)
end

---------------------------------------------------------------- compose
F.depth(3)
-- brass censer with a smoke curl (left middle), a cairn beside it
do
  local legs = rect(54, 214, 55, 220):add(rect(66, 214, 67, 220))
  local bowl = c:rrect(50, 204, 71, 215, 4)
  local lid = poly{ { 53, 204 }, { 61, 196 }, { 68, 204 } }
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(legs, bowl, lid), TAR)
  part(legs, BRONZE, { nopop = true }) part(bowl, BRONZE) part(lid, BRONZE, { sep = true })
  hline(50, 71, 208, BRONZE.deep) for x = 53, 68, 3 do px(x, 211, BRONZE.hi) end
  bowl:each(function(x, y) if y > 210 and hash(x, y, 83) < .15 then px(x, y, L.glass.shade) end end)
  F.smoke(61, 190, 7, .4, 2)
  cairn(38, 222, 6)
end
holyWell()
votiveRack()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  lantern(floor(F.xl(y)) - p[3], y, p[2])
  lantern(floor(F.xr(y)) + p[3], y, p[2])
end
gatePosts()
plinth(194, 214, 7, 6) fox(194, 208, false)
plinth(291, 214, 14, 6) fox(283, 208, true, false, true)
-- quirk: a real fox kit poses on the plinth beside the stone fox, wearing its red bib (the stone fox's neck is bare)
F.sprite({
  ".o....o........",
  ".oO..Oo........",
  ".OOOOOO........",
  "OOOOOOOO.......",
  "OeOOOeOO.......",
  "OOwwwOOO.......",
  ".wwnwwO........",
  "..wwwO.....OO..",
  "..RRRRR...OOOO.",
  ".RRrRRRR..OOOO.",
  "..RRRRR...OOO..",
  "..OwwOO...OO...",
  "..OwwwOO..OO...",
  "..OwwwOOOOOO...",
  "..OwwwOOOOWW...",
  "..OOOOOOOWWW...",
  "..kk..kk.......",
}, 291, 191, { o = TAR.edge, O = L.produce.base, e = TAR.edge, w = L.awnB.hi, n = TAR.edge, R = RED.base, r = RED.hi, W = L.awnB.base, k = TAR.deep })
sandGarden()
-- sea-buckthorn and a hawthorn at the right edge
F.tree(436, 228, 40, 1)
F.windTree(452, 226, 56, L.foliage2, 54)
for i = 0, 14 do local x, y = 420 + floor(hash(i, 1, 55) * 44), 214 + floor(hash(i, 2, 55) * 14)
  px(x, y, L.produce.hi) px(x + 1, y, L.produce.shade) end -- buckthorn berries dropped
for _, f in ipairs({ { 414, 228, 7 }, { 300, 224, 6 }, { 290, 232, 7 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(432, 228, true) F.thrift(446, 227, false) F.thrift(404, 226, true)
F.shell(398, 227, true) F.shell(409, 228, false)
-- gorse cushion and a gnome sweeping blown wrack and shells by the right lanterns
local gorse = F.bush(406, 222, 12, 8, L.foliage2, 12)
gorse:each(function(x, y) if hash(x, y, 43) < .16 then px(x, y, hash(x, y, 44) < .5 and L.gorse.base or L.gorse.hi) end end)
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.wall2, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), L.timber.base)
local broom = poly{ { bx - 11, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 12, by + 10 } }
rimOf(broom, ROPE) part(broom, ROPE, { nopop = true }) for x = bx - 11, bx - 4, 2 do vline(x, by + 7, by + 10, ROPE.deep) end
-- the heap of wrack and shells he is sweeping up
for k = 0, 3 do F.wrack(312 + k * 3, 238 + k % 2 * 2 + (k == 3 and 3 or 0), 6, k) end
F.shell(318, 237, true) F.shell(326, 241, false) F.shell(312, 243, false)
-- a gnome tying a rag on the rack
local _, ex, ey = F.gnome(392, 214, { hat = L.fern, coat = L.lav, arm = "up", flip = true })
ribbon(ex, ey - 1, 7, L.awnA)
-- gulls on the gate cap and over the chapel
F.depth(0)
local GS = { W = L.gull.hi, G = L.gull.shade, K = TAR.deep, Y = L.gold.base, e = TAR.edge }
F.sprite({ ".WW..", "eWWG.", "YWGGK", ".WGGK", "..y.." }, 194, 105, { W = L.gull.hi, G = L.gull.shade, K = TAR.deep, Y = L.gold.base, e = TAR.edge, y = L.gold.shade }, { rimCol = L.gull.edge })
F.sprite({ "..WW.", ".GWWe", "KGGWY", "KGGW.", "..y.." }, 278, 105, { W = L.gull.hi, G = L.gull.shade, K = TAR.deep, Y = L.gold.base, e = TAR.edge, y = L.gold.shade }, { rimCol = L.gull.edge })
F.gull(330, 38, 3) F.gull(346, 46, 2) F.gull(152, 50, 2) F.gull(164, 44, 1) F.gull(374, 30, 2)
F.depth(3)
-- shells, pebbles and bits of wrack scattered about
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 130 + floor(hash(i, 2, 77) * 130)
  if not (x > 376 and y > 226) then
    if i % 3 == 0 then F.shell(x, y, false)
    elseif i % 3 == 1 then px(x, y, L.shingle.base) px(x + 1, y, L.shingle.deep) px(x, y - 1, L.shingle.hi)
    else px(x, y, L.kelp.base) px(x + 1, y, L.kelp.deep) end
  end
end
F.finish()
