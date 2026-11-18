-- shrine.lua : "Wayside shrine" stop look, MOUNTAIN (mountain_granite), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua), re-cast for the high mountains:
-- road's end: a tiny whitewashed granite chapel under a weighted slab roof with a bell-cote, candle-lit through its
-- arched door, on a lichened granite terrace between a spruce and a larch, prayer-flag lines strung from the
-- bell-cote, snow peaks behind. Over the road: a granite trilithon gate (standing stones, a snow-dusted lintel
-- slab, a larch tie beam hung with bronze bells and flags). Back left: a three-tier dry-stone cairn tower with slab
-- ledges and a flag pole. Right back: the roped old arolla pine hung with prayer flags (a nutcracker in it) and the
-- bell frame. Left hero: the spring trough pavilion fed by a larch spout from a boulder. Right hero: the offering
-- rack of carved plaques, prayer flags and little bells. Bottom left: a raked scree garden with lichened boulders and
-- small cairns. Granite lanterns, a juniper-incense censer, edelweiss offerings, chamois on the crags, choughs.
-- Quirk (kept): a real fox kit sits on the plinth beside the stone fox, wearing its red bib.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-mountain-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 330, 352, 440 }, treeLineGap = { 176, 304 } }
local c, L, HP = F.c, F.L, F.HP
do local lich = F.lichen F.lichen = function(m, k, sd) return lich(m, k * .55, sd) end end -- calmer lichen speckle
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local RED, SL = L.awnA, L.roof
local BRONZE = F.rp("#dcb878 #ae8a50 #82663c #5c482e #3a2e24")
local ROPE = F.rp("#ecd890 #ccb066 #a48848 #765e36 #4c3c26")
local FLAG = { L.accent, L.awnB, L.awnA, L.leaf, L.gold }

-- warm candle-light spill: tint what is already there toward the glow (hard pixels, no alpha)
local function glowSpill(cx, cy, r, k)
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local d = math.sqrt((x - cx) ^ 2 + ((y - cy) * 1.4) ^ 2)
    if d <= r then local v = c:get(x, y) if v then px(x, y, F.mix(v, L.glow.hi, k * (1 - d / (r + 1)) + .04)) end end
  end end
end
local function candle(x, yb, tall)
  local h = tall or 3
  vline(x, yb - h + 1, yb, L.awnB.hi) vline(x + 1, yb - h + 2, yb, L.awnB.shade)
  px(x, yb - h, L.glow.base) px(x, yb - h - 1, L.glow.hi)
end
-- a little bronze bell hanging from (x, y)
local function bellS(x, y, big)
  px(x, y, BRONZE.deep)
  px(x, y + 1, BRONZE.hi) hline(x - 1, x + 1, y + 2, BRONZE.base) px(x - 1, y + 2, BRONZE.hi)
  hline(x - 2, x + 2, y + 3, BRONZE.shade) px(x - 2, y + 3, BRONZE.base) px(x + 2, y + 3, BRONZE.deep)
  if big then hline(x - 2, x + 2, y + 4, BRONZE.deep) px(x, y + 5, L.iron.deep) else px(x, y + 4, L.iron.deep) end
end
-- a prayer-flag line sagging from a to b: little square cloths in blue / white / red / green / yellow
local function flags(x0, y0, x1, y1, sag, every, sz, off)
  sz = sz or 3
  local function ly(xx) local t = (xx - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  local step = x1 > x0 and 1 or -1
  for xx = x0, x1, step do px(xx, ly(xx), ROPE.deep) end
  local i = off or 0
  for xx = x0 + 2 * step, x1 - 2 * step, every * step do
    i = i + 1
    local r = FLAG[i % #FLAG + 1]
    local yy = ly(xx) + 1
    for k = 0, sz - 1 do
      for j = 0, sz - 2 do
        local h = (k == 0) and r.hi or ((j == sz - 2) and r.shade or r.base)
        if hash(xx + j, yy + k, 41) < .12 then h = r.shade end -- a printed mark
        px(xx + j, yy + k + (hash(xx, k, 42) < .2 and 1 or 0) * 0, h)
      end
    end
    px(xx + sz - 2, yy + sz - 1, r.deep)
  end
end
-- a vertical prayer streamer (a tall narrow flag on a pole or hanging from a rail)
local function streamer(x, y, len, r, dir)
  dir = dir or 1
  for k = 0, len do
    local xx = x + ((k > len // 2) and dir or 0)
    px(xx, y + k, k == 0 and r.hi or r.base) px(xx + 1, y + k, k == len and r.deep or r.shade)
  end
end
-- a small stacked-stone cairn
local function cairn(x, yb, s, seed)
  local y = yb
  for k = 0, s - 1 do
    local w, h = floor((s - k) * 1.6) + 1, 2 + (s - k) // 2
    local m = c:ellipse(x + (k % 2), y - h // 2 - 1, w, math.max(1, h // 2))
    rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    px(x + (k % 2) - w // 2, y - h + 1, L.stone.hi)
    if hash(k, x, seed or 86) < .4 then px(x + (k % 2) + 1, y - h + 1, L.moss.base) end
    y = y - h
  end
  return y
end
-- a dry-stone mask painter: irregular courses, lit tops, dark joints
local function dryStone(m, seed, r)
  r = r or L.stone
  m:each(function(x, y)
    local row = y // 3
    local v = hash((x + row * 2) // 4, row, seed)
    local h = v < .3 and r.hi or (v < .72 and r.base or r.shade)
    if y % 3 == 0 or (x + row * 2) % 4 == 0 and hash(x, row, seed + 1) < .7 then h = r.deep end
    if not m:has(x, y - 1) then h = r.hi end
    if not m:has(x + 1, y) then h = r.deep end
    px(x, y, h)
  end)
end
-- a slab roof: granite slab courses, weighting stones, lichen and a dusting of old snow on the top
local function slabRoof(m, yt, seed, snowK)
  rimOf(m, SL) part(m, SL, { sep = true })
  F.courses(m, yt, 3, 6, SL, seed % 5)
  F.lichen(m, .07, seed)
  if snowK then F.snow(m, snowK, seed + 3) end
end
local function wstone(x, y)
  local ws = c:ellipse(x, y, 3, 2) rimOf(ws, L.stone) part(ws, L.stone, { nopop = true }) px(x - 1, y - 1, L.stone.hi) px(x + 1, y + 1, L.stone.deep)
end

---------------------------------------------------------------- background: crags with chamois behind the tree line (mid left)
F.depth(1)
do
  F.boulder(124, 128, 12, 10, 120)
  F.boulder(158, 129, 8, 7, 122)
  local cr = F.boulder(142, 129, 9, 19, 121)
  F.snow(cr, .5, 123)
  F.goat(141, 111, { k = .42, r = L.chamois, noShadow = true })
  F.goat(160, 122, { k = .3, r = L.chamois, flip = true, noShadow = true })
end

---------------------------------------------------------------- back-left: a three-tier dry-stone cairn tower with slab ledges
local function tower(cx, yb)
  F.shadow(cx - 16, cx + 16, yb, 8, 3)
  local base = rect(cx - 18, yb - 4, cx + 18, yb)
  rimOf(base, L.stone) part(base, L.stone) F.courses(base, yb - 4, 5, 8, L.stone) F.lichen(base, .3, 84)
  local y = yb - 4
  for i = 0, 2 do
    local w = 12 - i * 3
    local body = poly{ { cx - w, y }, { cx - w + 1, y - 13 }, { cx + w - 1, y - 13 }, { cx + w, y } }
    rimOf(body, L.stone) dryStone(body, 90 + i) F.lichen(body, .1, 93 + i)
    if i == 0 then -- a niche with a candle and an edelweiss posy
      local n = c:rrect(cx - 3, y - 11, cx + 3, y - 3, 2) fill(n, L.stone.edge) fill(n:shrink(1), L.soil.deep)
      candle(cx - 1, y - 4, 3) px(cx + 1, y - 5, L.edel.hi) px(cx + 2, y - 4, L.edel.base) px(cx + 1, y - 4, L.fern.shade)
      glowSpill(cx - 1, y - 7, 4, .35)
    elseif i == 1 then F.window(cx - 1, y - 9, cx + 1, y - 6, L.stone) end
    y = y - 13
    local led = poly{ { cx - w - 5, y }, { cx - w - 3, y - 3 }, { cx + w + 3, y - 3 }, { cx + w + 5, y }, { cx + w + 4, y + 1 }, { cx - w - 4, y + 1 } }
    rimOf(led, SL) part(led, SL, { nopop = true })
    hline(cx - w - 3, cx + w + 3, y - 3, SL.hi) hline(cx - w - 4, cx + w + 4, y + 1, SL.deep)
    F.snow(led, .6, 95 + i)
    -- icicles under the ledge on the shady right
    for k = 1, 3 do vline(cx + w + 4 - k * 2, y + 2, y + 1 + (k % 2) + 1, L.snow.shade) end
    y = y - 3
  end
  local top = cairn(cx, y, 4, 96)
  -- flag pole out of the cairn
  vline(cx, top - 16, top, L.timber.base) vline(cx + 1, top - 15, top, L.timber.deep)
  px(cx, top - 17, L.gold.hi) px(cx + 1, top - 17, L.gold.shade)
  streamer(cx + 2, top - 15, 7, L.accent, 1) streamer(cx + 2, top - 7, 5, L.awnA, 1)
  return cx, top - 16
end
F.tree(86, 128, 52, 1)
F.tree(16 + 6, 132, 34, 0)
local tpx, tpy = tower(48, 134)
flags(tpx, tpy, 82, 90, 6, 4, 3)
flags(tpx, tpy, 20, 104, 5, 4, 3, 2)
cairn(76, 136, 5)

---------------------------------------------------------------- the road's end: terrace, steps, granite chapel between a spruce and a larch
F.depth(2)
F.tree(182, 128, 74, 2)
F.larch(300, 128, 66, 7)
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, L.stone) part(terr, L.stone) F.courses(terr, 112, 5, 12, L.stone) F.lichen(terr, .12, 87)
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, L.road.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
  for x = 229 + k, 251 - k do if hash(x, y, 88) < .1 then px(x, y + 1, L.moss.base) end end
end
-- walls: whitewashed granite rubble with granite quoins
local hall = rect(204, 92, 276, 112)
rimOf(hall, L.plaster) part(hall, L.plaster, { nopop = true })
hall:each(function(x, y)
  local row = (y - 92) // 4
  local ry = (y - 92) % 4
  local bw = 6 + floor(hash(row, 1, 19) * 4)
  local rx = (x + row * 3) % bw
  if ry == 0 and hash(x // 3, row, 18) < .6 then px(x, y, L.plaster.shade)
  elseif hash((x + row * 3) // bw, row, 20) < .22 then px(x, y, (ry == 1) and L.stone.hi or L.stone.base)
  elseif ry == 1 and rx == 1 then px(x, y, L.plaster.hi) end
  if y > 108 and hash(x, y, 21) < .35 then px(x, y, L.plaster.shade) end
  if y < 95 then px(x, y, L.plaster.deep) end -- shadow under the eaves
end)
for _, qx in ipairs({ 204, 272 }) do
  for row = 0, 4 do
    local y0 = 95 + row * 4
    local w = (row % 2 == 0) and 5 or 3
    local q = rect(qx == 204 and qx or qx + 5 - w, y0, qx == 204 and qx + w - 1 or qx + 4, y0 + 3)
    fill(q, L.stone.base)
    local x0, _, x1 = q:bbox()
    hline(x0, x1, y0, L.stone.hi) hline(x0, x1, y0 + 3, L.stone.deep) vline(x1, y0, y0 + 3, L.stone.shade)
  end
end
-- arched doorway, candle-lit, with a little edelweiss icon on the altar
local dw = c:rrect(230, 95, 250, 122, 8):clip(rect(230, 95, 250, 112))
fill(dw, L.stone.edge)
local din = dw:shrink(1) fill(din, L.soil.deep)
fill(rect(234, 100, 246, 112), L.soil.shade)
fill(c:rrect(236, 100, 244, 112, 3):clip(rect(236, 100, 244, 110)), L.glow.deep)
fill(c:rrect(238, 101, 242, 110, 2):clip(rect(238, 101, 242, 108)), L.glow.shade)
F.sprite({ ".W.", "WgW", ".W.", ".f." }, 239, 102, { W = L.edel.hi, g = L.gold.base, f = L.fern.shade }, { rim = false })
for _, x in ipairs({ 233, 235, 245, 247 }) do candle(x, 105 + (x % 3), 3) end
glowSpill(240, 104, 8, .35)
-- arched stone surround
dw:each(function(x, y) if not dw:has(x, y - 1) or not dw:has(x - 1, y) then px(x, y, L.stone.hi) end end)
-- small arched windows with glow
F.window(214, 99, 218, 104, L.stone, true) F.window(262, 99, 266, 104, L.stone, true)
-- offering box
local box = rect(232, 106, 248, 112) rimOf(box, L.timber) part(box, L.timber) for x = 234, 246, 3 do px(x, 107, L.timber.deep) end
-- the slab roof
local roofM = poly{ { 186, 93 }, { 212, 66 }, { 268, 66 }, { 294, 93 }, { 292, 95 }, { 188, 95 } }
slabRoof(roofM, 66, 89, .35)
line({ { 187, 92 }, { 212, 67 } }):each(function(x, y) if roofM:has(x, y) then px(x, y, SL.hi) end end)
hline(188, 292, 95, SL.deep) hline(190, 290, 94, SL.shade)
for _, w in ipairs({ { 204, 86 }, { 222, 78 }, { 258, 78 }, { 276, 86 }, { 214, 72 }, { 266, 72 } }) do wstone(w[1], w[2]) end
-- porch gable over the door: granite with a carved sun disc
local gab = poly{ { 226, 92 }, { 240, 74 }, { 254, 92 } }
rimOf(gab, L.stone) fill(gab, L.plaster.base) F.courses(gab, 74, 4, 7, L.plaster)
local gcap = line({ { 224, 93 }, { 240, 72 }, { 256, 93 } }, 2) rimOf(gcap, SL) fill(gcap, SL.base)
line({ { 224, 92 }, { 240, 71 } }):each(function(x, y) if gcap:has(x, y) then px(x, y, SL.hi) end end)
F.snow(gcap, .6, 31)
local sun = c:ellipse(240, 85, 2, 2) fill(sun, L.gold.base) px(239, 84, L.gold.hi) px(241, 86, L.gold.shade)
for _, d in ipairs({ { -4, 0 }, { 4, 0 }, { 0, -4 }, { -3, -3 }, { 3, -3 } }) do px(240 + d[1], 85 + d[2], L.gold.shade) end
-- bell-cote on the ridge
local cote = rect(233, 46, 247, 66)
rimOf(cote, L.stone) dryStone(cote, 33)
local arch = c:rrect(236, 50, 244, 64, 4):clip(rect(236, 50, 244, 62))
fill(arch, L.stone.edge) fill(arch:shrink(1), F.mix(L.sky[3], L.stone.deep, .45))
local bm = poly{ { 238, 53 }, { 242, 53 }, { 243, 59 }, { 237, 59 } }:add(c:rrect(238, 51, 242, 55, 2))
rimOf(bm, BRONZE) part(bm, BRONZE) hline(237, 243, 59, BRONZE.deep) px(240, 60, L.iron.deep) px(238, 53, BRONZE.hi)
local cap = poly{ { 230, 47 }, { 240, 36 }, { 250, 47 }, { 249, 48 }, { 231, 48 } }
rimOf(cap, SL) part(cap, SL, { nopop = true })
line({ { 231, 46 }, { 240, 37 } }):each(function(x, y) if cap:has(x, y) then px(x, y, L.snow.hi) end end)
line({ { 232, 46 }, { 240, 38 } }):each(function(x, y) if cap:has(x, y) then px(x, y, L.snow.base) end end)
vline(240, 31, 36, L.iron.base) px(240, 30, L.gold.hi) hline(238, 242, 33, L.iron.base)
-- bell rope from the cote down into the porch
vline(241, 66, 70, ROPE.deep)
-- prayer-flag lines from the cote to the spruce and the larch
flags(236, 40, 166, 76, 8, 5, 4)
flags(244, 40, 318, 78, 8, 5, 4, 3)
-- candles along the foot of the terrace, edelweiss and juniper offerings on the corners
for x = 212, 225, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
for x = 256, 269, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
glowSpill(218, 127, 6, .3) glowSpill(262, 127, 6, .3)
for _, b in ipairs({ { 196, 123, 0 }, { 284, 123, 1 } }) do
  local m = rect(b[1] - 3, b[2] - 1, b[1] + 3, b[2] + 1)
  rimOf(m, L.stone) part(m, L.stone, { nopop = true })
  if b[3] == 0 then
    F.edelweiss(b[1] - 1, b[2] - 3) F.edelweiss(b[1] + 1, b[2] - 4)  px(b[1] + 2, b[2] - 2, L.fern.base)
  else
    hline(b[1] - 2, b[1] + 2, b[2] - 2, L.juniper.base) px(b[1] - 1, b[2] - 3, L.juniper.hi) px(b[1] + 1, b[2] - 3, "#8c9cc8") px(b[1] + 2, b[2] - 2, L.juniper.shade)
  end
end

---------------------------------------------------------------- right back: the old arolla pine + bell frame
local function sacredTree()
  F.shadow(392, 434, 162, 10, 4)
  local trunk = poly{ { 396, 162 }, { 402, 156 }, { 403, 134 }, { 400, 112 }, { 405, 100 }, { 413, 100 }, { 416, 116 }, { 415, 134 }, { 416, 156 }, { 424, 162 } }
  local brs = line({ { 404, 110 }, { 384, 92 }, { 376, 90 } }, 3):add(line({ { 412, 104 }, { 434, 86 } }, 3)):add(line({ { 408, 100 }, { 404, 72 } }, 3))
  rimOf(union(trunk, brs), L.redbark)
  part(trunk, L.redbark) part(brs, L.redbark, { nopop = true })
  trunk:each(function(x, y)
    if hash(x, y // 3, 34) < .22 then px(x, y, L.redbark.deep) elseif x < 406 and hash(x, y // 2, 35) < .4 then px(x, y, L.redbark.hi) end
    if y > 150 and hash(x // 2, y, 36) < .3 then px(x, y, hash(x, y, 37) < .5 and L.moss.base or L.moss.shade) end
  end)
  -- clumped dark arolla crown: tufts with blue-green lit tops
  local clumps = { { 372, 84, 16, 9 }, { 392, 70, 18, 10 }, { 420, 60, 18, 11 }, { 440, 80, 16, 9 }, { 410, 57, 16, 10 }, { 384, 100, 12, 6 }, { 432, 100, 13, 6 }, { 410, 84, 14, 8 } }
  for i, k in ipairs(clumps) do
    for j = 0, 6 do
      local a = hash(i, j, 44) * 2 * pi
      local d = hash(j, i, 45) * .6
      local mx, my = floor(k[1] + cos(a) * k[3] * d), floor(k[2] + sin(a) * k[4] * d + (j < 3 and 2 or 0))
      local rr = floor(k[3] * (.38 + hash(i, j, 46) * .2))
      local m = F.crown(mx, my, rr, math.max(3, floor(rr * .62)), L.foliage2, 30 + i * 7 + j)
      m:each(function(x, y)
        if not m:has(x, y - 1) and hash(x, y, 40 + i) < .7 then px(x, y, L.juniper.hi)
        elseif not m:has(x, y - 2) and hash(x, y, 47) < .4 then px(x, y, L.foliage2.hi)
        elseif hash(x, y // 2, 48) < .12 then px(x, y, L.foliage2.deep) end
        if not m:has(x, y + 1) then px(x, y, L.foliage2.deep) end
      end)
    end
  end
  -- purple cones
  for _, p in ipairs({ { 386, 66 }, { 416, 52 }, { 436, 72 }, { 400, 80 } }) do px(p[1], p[2], L.lav.shade) px(p[1] + 1, p[2], L.lav.deep) px(p[1], p[2] - 1, L.lav.base) end
  -- roped trunk with zigzags
  for x = 402, 416 do px(x, 136 + (x - 402) // 6, ROPE.shade) px(x, 137 + (x - 402) // 6, (x % 3 == 0) and ROPE.hi or ROPE.base) px(x, 138 + (x - 402) // 6, ROPE.deep) end
  for _, x in ipairs({ 405, 412 }) do local y = 139 + (x - 402) // 6 fill(line({ { x, y }, { x + 2, y + 2 }, { x, y + 4 }, { x + 2, y + 6 } }), L.awnB.hi) end
  -- prayer streamers tied on the low boughs
  for i, p in ipairs({ { 372, 91 }, { 392, 78 }, { 440, 87 }, { 384, 103 }, { 432, 103 }, { 412, 90 }, { 424, 69 }, { 362, 88 } }) do
    streamer(p[1], p[2], 5 + i % 3, FLAG[i % #FLAG + 1], (i % 2 == 0) and 1 or -1)
  end
  -- a spotted nutcracker on a bough, with a pine nut
  F.sprite({
    "..bbb..",
    ".bbbbe.",
    "bWbbbbYY",
    "bbWbWb..",
    ".bWbWbb.",
    "..bbbbb.",
    "...bbWW.",
    "...k.k..",
  }, 424, 72, { b = "#6a4c3c", W = L.edel.hi, e = L.timber.edge, Y = "#4a3a36", k = "#4a3a36" })
end
local function bellFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local roofm = poly{ { x0 - 8, yb - 34 }, { x0 + 4, yb - 44 }, { x0 + 28, yb - 44 }, { x0 + 40, yb - 34 }, { x0 + 38, yb - 31 }, { x0 - 6, yb - 31 } }
  local bm = poly{ { x0 + 11, yb - 28 }, { x0 + 21, yb - 28 }, { x0 + 23, yb - 12 }, { x0 + 9, yb - 12 } }:add(c:rrect(x0 + 11, yb - 31, x0 + 21, yb - 25, 3))
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, roofm, bm), L.timber)
  part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 64) < .2 then px(x, y, L.timber.deep) end end)
  slabRoof(roofm, yb - 44, 91, .5) hline(x0 - 6, x0 + 38, yb - 31, SL.deep)
  wstone(x0 + 16, yb - 44)
  part(bm, BRONZE)
  hline(x0 + 10, x0 + 22, yb - 20, BRONZE.deep) hline(x0 + 9, x0 + 23, yb - 13, BRONZE.deep)
  for y = yb - 27, yb - 22, 2 do for x = x0 + 13, x0 + 19, 2 do px(x, y, BRONZE.hi) end end
  bm:each(function(x, y) if y > yb - 20 and hash(x, y, 92) < .12 then px(x, y, "#6aa69a") end end) -- verdigris
  local log = rect(x0 + 24, yb - 22, x0 + 38, yb - 19) rimOf(log, L.timber) part(log, L.board, { nopop = true }) F.logEnd(x0 + 38, yb - 21, 2)
  vline(x0 + 27, yb - 31, yb - 23, L.timber.edge) vline(x0 + 35, yb - 31, yb - 23, L.timber.edge)
end
sacredTree()
bellFrame(300, 140)
flags(334, 107, 398, 116, 3, 5, 3, 1)
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = L.roof2, arm = "up", flip = true })
line({ { rx, ry }, { 337, 121 } }):each(function(x, y) px(x, y, L.timber.edge) end)

---------------------------------------------------------------- the granite trilithon gate over the road
local function gateStones()
  local postL = poly{ { 203, 198 }, { 204, 124 }, { 210, 122 }, { 210, 198 } }
  local postR = poly{ { 270, 198 }, { 270, 122 }, { 276, 124 }, { 277, 198 } }
  local lint = poly{ { 184, 112 }, { 192, 109 }, { 290, 109 }, { 297, 112 }, { 296, 118 }, { 186, 119 } }
  local nuki = rect(198, 132, 282, 136)
  local plaque = rect(234, 122, 246, 131)
  local hang = rect(239, 119, 241, 121)
  local feet = poly{ { 199, 199 }, { 201, 195 }, { 212, 195 }, { 214, 199 } }:add(poly{ { 266, 199 }, { 268, 195 }, { 279, 195 }, { 281, 199 } })
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, lint, nuki, plaque, feet, hang)
  rimOf(sil, L.stone)
  for _, p in ipairs({ { postL, 204 }, { postR, 271 } }) do
    part(p[1], L.stone)
    p[1]:each(function(x, y)
      local k = x - p[2]
      if k <= 1 and p[1]:has(x - 1, y) == false then px(x, y, L.stone.hi) elseif k == 1 then px(x, y, L.stone.hi)
      elseif k >= 5 then px(x, y, L.stone.shade)
      elseif hash(x, y // 4, 93) < .18 then px(x, y, L.stone.shade) elseif hash(x, y // 3, 94) < .08 then px(x, y, L.stone.deep) end
    end)
    F.lichen(p[1], .12, 95 + p[2])
  end
  part(lint, L.stone, { nopop = true })
  lint:each(function(x, y)
    if y <= 110 then px(x, y, L.stone.hi) elseif y >= 117 then px(x, y, L.stone.deep)
    elseif hash(x // 5, y, 97) < .2 then px(x, y, L.stone.shade) end
  end)
  F.lichen(lint, .1, 98) F.snow(lint, .7, 99)
  for _, x in ipairs({ 214, 252, 262 }) do vline(x, 112, 116, L.stone.deep) end -- cracks
  part(nuki, L.timber, { nopop = true }) F.logs(nuki, L.timber, 132, 5)
  F.logEnd(198, 134, 2) F.logEnd(282, 134, 2)
  part(feet, L.stone, { nopop = true }) F.lichen(feet, .2, 100)
  fill(hang, ROPE.base)
  part(plaque, L.board) c:edgeIn(plaque, L.timber.base)
  F.sprite({ ".W.W.", "WWgWW", ".WWW.", "..f.." }, 238, 124, { W = L.edel.base, g = L.gold.base, f = L.fern.shade }, { rim = false })
  -- bronze bells hung along the tie beam, prayer streamers between
  for i, x in ipairs({ 214, 226, 254, 266 }) do
    vline(x, 137, 139, ROPE.deep) bellS(x, 140, true)
  end
  for i, x in ipairs({ 208, 220, 232, 248, 260, 272 }) do streamer(x, 137, 6 + i % 3, FLAG[i % #FLAG + 1], i % 2 == 0 and 1 or -1) end
end

---------------------------------------------------------------- granite lantern, scaled by depth, candle-lit
local function toro(x, yb, s)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local base = R(-5, -3, 5, 0)
  local post = R(-2, -14, 2, -3)
  local fire = R(-5, -21, 5, -14)
  local capm = poly{ { x - 8 * s, yb - 21 * s }, { x - 3 * s, yb - 26 * s }, { x + 3 * s, yb - 26 * s }, { x + 8 * s, yb - 21 * s }, { x + 7 * s, yb - 20 * s }, { x - 7 * s, yb - 20 * s } }
  local knob = R(-1, -29, 1, -26)
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(base, post, fire, capm, knob), L.stone)
  part(base, L.stone) part(post, L.stone, { nopop = true }) part(fire, L.stone, { sep = true })
  local win = R(-2, -19, 2, -16) fill(win, L.glow.base) px(floor(x - 2 * s), floor(yb - 19 * s), L.glow.hi)
  win:each(function(xx, y) if not win:has(xx + 1, y) or not win:has(xx, y + 1) then px(xx, y, L.glow.shade) end end)
  part(capm, SL, { sep = true }) part(knob, L.stone, { nopop = true })
  F.lichen(capm, .15, 61 + x) F.snow(capm, .45, 62 + x)
  F.lichen(base, .2, 63 + x) F.lichen(post, .1, 64 + x)
end

---------------------------------------------------------------- left hero: spring trough pavilion
local function pavilion()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, L.timber) part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 64) < .2 then px(x, y, L.timber.deep) end if y > 206 and hash(x, y, 65) < .5 then px(x, y, L.stone.base) end end)
  -- stone post footings
  for _, fx in ipairs({ x0 + 7, x1 - 8 }) do local ft = rect(fx - 3, yb - 3, fx + 4, yb) rimOf(ft, L.stone) part(ft, L.stone, { nopop = true }) end
  -- slab roof
  local rm = poly{ { x0 - 6, yt + 8 }, { x0 + 16, yt - 14 }, { x1 - 16, yt - 14 }, { x1 + 6, yt + 8 }, { x1 + 4, yt + 10 }, { x0 - 4, yt + 10 } }
  slabRoof(rm, yt - 14, 66, .4)
  line({ { x0 - 5, yt + 7 }, { x0 + 16, yt - 13 } }):each(function(x, y) if rm:has(x, y) then px(x, y, SL.hi) end end)
  hline(x0 - 4, x1 + 4, yt + 10, SL.deep) hline(x0 - 2, x1 + 2, yt + 9, SL.shade)
  for _, w in ipairs({ { x0 + 8, yt + 2 }, { x0 + 30, yt - 8 }, { x1 - 30, yt - 8 }, { x1 - 8, yt + 2 } }) do wstone(w[1], w[2]) end
  -- larch gable board with a carved edelweiss
  local tri = poly{ { 128, yt + 6 }, { 140, yt - 8 }, { 152, yt + 6 } }
  rimOf(tri, L.timber) fill(tri, L.timber.base) F.planks(tri, L.timber, 3, true, 23)
  F.sprite({ "..w..", ".wgw.", "..w..", "..f.." }, 138, yt - 2, { w = L.board.hi, g = L.gold.base, f = L.timber.deep }, { rim = false })
  -- granite trough
  local front = rect(112, 190, 168, 208)
  local topm = poly{ { 108, 190 }, { 172, 190 }, { 168, 182 }, { 112, 182 } }
  rimOf(union(front, topm), L.stone)
  part(front, L.stone) F.courses(front, 190, 9, 14, L.stone, 3) F.lichen(front, .1, 68)
  part(topm, L.stone, { sep = true }) F.lichen(topm, .12, 69)
  local wat = poly{ { 114, 188 }, { 166, 188 }, { 163, 184 }, { 117, 184 } } F.water(wat, L.water, { step = 2 })
  -- a skin of ice in the shady corner, floating gentian blossoms
  for _, p in ipairs({ { 158, 185 }, { 160, 186 }, { 162, 186 }, { 159, 187 }, { 161, 185 } }) do px(p[1], p[2], L.snow.base) px(p[1] + 1, p[2], L.snow.shade) end
  for _, k in ipairs({ { 124, 186 }, { 140, 187 } }) do px(k[1], k[2], L.gentian.base) px(k[1] + 1, k[2], L.gentian.hi) px(k[1], k[2] + 1, L.gentian.deep) end
  -- boulder spring with a larch spout and a trickle
  F.boulder(178, 192, 9, 15, 70)
  local sp = rect(148, 168, 176, 171)
  rimOf(sp, L.timber) part(sp, L.timber, { nopop = true }) hline(149, 175, 168, L.board.shade) hline(149, 175, 169, L.water.base)
  F.logEnd(148, 170, 2)
  vline(148, 172, 184, L.water.hi) vline(149, 173, 184, L.water.base)
  px(147, 184, L.water.hi) px(151, 184, L.water.hi)
  vline(164, 172, 181, L.timber.base) vline(165, 172, 181, L.timber.deep)
  -- icicles on the spout
  for _, ix in ipairs({ 156, 160, 170 }) do vline(ix, 172, 173 + (ix % 3), L.snow.base) end
  -- wooden ladles laid across
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 181 }, { lx + 10, 178 } }), L.board.base)
    local cup = rect(lx - 2, 180, lx + 1, 183) fill(cup, L.board.shade) px(lx - 2, 180, L.board.hi) px(lx, 182, L.board.deep)
  end
  -- an alpine newt on the trough rim (slate-blue back, orange belly)
  F.sprite({ "e.....", "bbbbb..", "boobbbb", ".k..k.." }, 156, 178, { e = L.timber.edge, b = "#5a6a84", o = L.produce.base, k = "#3e4656" })
  -- edelweiss posies left on the trough
  F.edelweiss(114, 180, true) F.edelweiss(166, 180)
end

---------------------------------------------------------------- right hero: offering rack of plaques, prayer flags and bells
local function rack()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local roofm = poly{ { x0 - 6, yt }, { x0 + 4, yt - 8 }, { x1 - 4, yt - 8 }, { x1 + 6, yt }, { x1 + 4, yt + 3 }, { x0 - 4, yt + 3 } }
  local rails = rect(x0, 172, x1, 173):add(rect(x0, 190, x1, 191))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, roofm, rails), L.timber)
  part(posts, L.timber, { nopop = true }) part(rails, L.timber, { nopop = true, noshade = true })
  posts:each(function(x, y) if hash(x, y // 3, 71) < .2 then px(x, y, L.timber.deep) end end)
  slabRoof(roofm, yt - 8, 72, .5) hline(x0 - 4, x1 + 4, yt + 3, SL.deep)
  for _, w in ipairs({ { x0 + 14, yt - 6 }, { x1 - 14, yt - 6 } }) do wstone(w[1], w[2]) end
  -- little bells under the eave
  for x = x0 + 9, x1 - 8, 12 do bellS(x, yt + 4) end
  local cols = { L.awnA, L.accent, L.produce, L.lav, L.fern }
  for row = 0, 1 do
    local yy = row == 0 and 174 or 192
    for k = 0, 9 do
      local x = x0 + 5 + k * 8 + (row == 1 and 3 or 0)
      if x + 6 < x1 - 3 then
        if row == 1 and k % 3 ~= 1 then
          for j = 0, 2 do streamer(x + j * 2, yy, 7 + (j + k) % 4, FLAG[(k + j) % #FLAG + 1]) end
        else
          local m = poly{ { x, yy + 2 }, { x + 3, yy }, { x + 6, yy + 2 }, { x + 6, yy + 9 }, { x, yy + 9 } }
          c:rim(m, L.board.edge) fill(m, L.board.hi) hline(x, x + 6, yy + 9, L.board.shade) vline(x + 6, yy + 2, yy + 9, L.board.base)
          local cr = cols[(k + row * 2) % 5 + 1]
          if k % 2 == 0 then -- a painted little peak with a snow cap
            px(x + 3, yy + 3, L.snow.shade) hline(x + 2, x + 4, yy + 4, L.snow.shade) hline(x + 2, x + 4, yy + 5, cr.base) hline(x + 1, x + 5, yy + 6, cr.base) hline(x + 1, x + 5, yy + 7, cr.shade)
          else -- an edelweiss / scribbled wish
            px(x + 3, yy + 3, cr.base) px(x + 2, yy + 4, cr.base) px(x + 4, yy + 4, cr.base) px(x + 3, yy + 5, L.gold.base) px(x + 3, yy + 7, cr.shade) px(x + 2, yy + 7, cr.base)
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
  px(x + 1 * s, yb - 16, r.edge) px(x + 7 * s, yb - 15, L.timber.edge)
  if not real then
    F.lichen(m, .15, 74 + x) F.snow(m, .4, 75 + x)
    if not bare then local bib = poly{ { x - 3 * s, yb - 13 }, { x + 3 * s, yb - 13 }, { x, yb - 8 } } fill(bib, RED.base) px(x, yb - 12, RED.hi) end
  end
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, L.stone) part(m, L.stone) hline(x - w, x + w, yb - h, L.stone.hi) F.lichen(m, .25, 76 + x)
end

---------------------------------------------------------------- raked scree garden edged in lichened stones (bottom-left)
local function gravel()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(3):cut(g)
  edge:each(function(x, y)
    local v = hash((x + (y // 3)) // 4, y // 3, 77)
    local h = v < .35 and L.stone.base or (v < .65 and L.stone.hi or L.stone.shade)
    if (x + (y // 3)) % 4 == 0 or y % 3 == 0 and hash(x, y, 78) < .5 then h = L.stone.deep end
    px(x, y, h)
  end)
  F.lichen(edge, .12, 79)
  g:each(function(x, y) px(x, y, L.road.hi) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    if best < 14 then if floor(best) % 3 == 0 then px(x, y, L.road.base) end
    elseif (y + floor(sin(x / 20) * 1.5)) % 3 == 0 then px(x, y, L.road.base) end
    if hash(x, y, 78) < .012 then px(x, y, L.road.shade) end
  end)
  F.boulder(56, 251, 12, 11, 80) F.boulder(120, 252, 9, 9, 81) F.boulder(131, 253, 5, 4, 82)
  -- little cairns built on the boulders
  cairn(52, 240, 3, 83) cairn(118, 243, 3, 84)
  -- juniper and edelweiss at the corners
  F.juniper(18, 232, 7, 5, 85) F.juniper(162, 230, 8, 5, 86)
  for _, f in ipairs({ { 26, 226 }, { 30, 228 }, { 164, 262 }, { 158, 266 } }) do F.edelweiss(f[1], f[2], true) end
end

---------------------------------------------------------------- compose
F.depth(3)
-- bronze censer burning juniper, a cairn and a juniper cushion beside it
do
  local legs = rect(54, 214, 55, 220):add(rect(66, 214, 67, 220))
  local bowl = c:rrect(50, 204, 71, 215, 4)
  local lid = poly{ { 53, 204 }, { 61, 196 }, { 68, 204 } }
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(legs, bowl, lid), L.timber)
  part(legs, L.iron, { nopop = true }) part(bowl, L.iron) part(lid, L.iron, { sep = true })
  hline(50, 71, 208, BRONZE.base) hline(51, 70, 209, BRONZE.deep) for x = 53, 68, 3 do px(x, 211, L.iron.hi) end px(61, 197, BRONZE.hi) px(60, 198, BRONZE.base)
  bowl:each(function(x, y) if y > 210 and hash(x, y, 83) < .15 then px(x, y, "#6aa69a") end end)
  -- smouldering juniper sprigs in the lid vents
  for _, p in ipairs({ { 58, 199 }, { 61, 196 }, { 64, 199 } }) do px(p[1], p[2] - 1, L.juniper.base) px(p[1] + 1, p[2] - 2, L.juniper.hi) end
  px(61, 195, L.glow.base) px(60, 194, L.glow.hi)
  for x = 56, 66, 5 do vline(x, 205, 213, L.iron.shade) end
  for _, x in ipairs({ 52, 58, 64, 69 }) do px(x, 206, BRONZE.hi) end
  hline(54, 67, 213, BRONZE.base) px(55, 199, BRONZE.hi) px(56, 200, BRONZE.hi) px(59, 195, L.glow.hi) px(62, 194, L.glow.base)
  F.smoke(61, 190, 7, -.3, 2)
  cairn(38, 222, 6)
  F.juniper(80, 222, 9, 6, 87)
  -- a basket of juniper sprigs for the incense
  local bk = c:rrect(74, 224, 88, 230, 2) rimOf(bk, L.timber) part(bk, L.board, { nopop = true })
  bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.board.deep) end end)
  for x = 75, 87, 2 do px(x, 223, L.juniper.base) px(x + 1, 222, L.juniper.hi) end
end
pavilion()
rack()
for _, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  toro(floor(F.xl(y)) - p[3], y, p[2])
  toro(floor(F.xr(y)) + p[3], y, p[2])
end
gateStones()
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
}, 291, 191, { o = L.timber.edge, O = L.produce.base, e = L.timber.edge, w = L.awnB.hi, n = L.timber.edge, R = RED.base, r = RED.hi, W = L.awnB.base, k = L.timber.deep })
-- edelweiss posies left at the stone foxes' feet
F.edelweiss(186, 207, true) F.edelweiss(201, 207) F.edelweiss(279, 207, true)
gravel()
-- right edge: a larch, an arolla pine, junipers and a boulder with a chamois on it
F.larch(428, 226, 50, 52)
F.tree(452, 228, 72, 3)
F.boulder(410, 224, 9, 8, 53)
F.goat(410, 216, { r = L.chamois, k = .85, noShadow = true })
F.juniper(440, 228, 10, 5, 54) F.juniper(466, 226, 8, 4, 55)
for _, f in ipairs({ { 398, 224 }, { 424, 228 }, { 460, 218 } }) do F.edelweiss(f[1], f[2], true) end
F.gentian(402, 227, true) F.gentian(446, 220, true)
-- a gnome sweeping fallen golden larch needles by the right lanterns
F.juniper(302, 262, 10, 5, 13)
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.wall2, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 6, by + 6 } }, 1), L.timber.base)
local broom = poly{ { bx - 11, by + 6 }, { bx - 3, by + 6 }, { bx - 4, by + 10 }, { bx - 12, by + 10 } }
rimOf(broom, ROPE) part(broom, ROPE, { nopop = true }) for x = bx - 11, bx - 4, 2 do vline(x, by + 7, by + 10, ROPE.deep) end
for i = 0, 34 do local x, y = 314 + floor(hash(i, 1, 5) * 14), 240 + floor(hash(i, 2, 5) * 5) - (i % 3)
  local r = (i % 3 == 0) and L.gold or L.needle px(x, y, i % 4 == 0 and r.hi or r.base) px(x + 1, y, r.shade) end
-- a gnome tying a prayer flag on the rack
local _, ex, ey = F.gnome(392, 214, { hat = L.fern, coat = L.lav, arm = "up", flip = true })
streamer(ex, ey - 1, 7, L.accent)
-- a marmot by the scree garden
F.marmot(174, 264, { flip = true })
-- alpine choughs on the lintel and over the hall
F.depth(0)
F.sprite({ ".kk..", "kkkky", "kkkk.", "kkkkk", ".r.r." }, 194, 103, { k = "#3c3a44", y = L.gold.base, r = L.apple.base })
F.sprite({ "..kk.", "ykkkk", ".kkkk", "kkkkk", ".r.r." }, 278, 103, { k = "#3c3a44", y = L.gold.base, r = L.apple.base })
F.birds({ { 330, 38, 2 }, { 342, 44, 1 }, { 150, 52, 2 }, { 160, 46, 1 } })
F.depth(3)
-- fallen larch needles and pebbles scattered around
for i = 0, 50 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 130 + floor(hash(i, 2, 77) * 130)
  if not (x > 376 and y > 226) and not F.roadM:has(x, y) then
    if i % 3 == 0 then px(x, y, L.stone.hi) px(x + 1, y, L.stone.shade)
    else px(x, y, L.gold.base) px(x + 1, y, L.needle.shade) end
  end
end
F.finish()
