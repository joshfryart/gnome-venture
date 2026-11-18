-- shrine.lua : "Wayside shrine" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold shrine (art-2701-batch3/stops/opus3/shrine.lua) and the forest shrine, re-cast as
-- a vine-swallowed jungle temple: road's end: a weathered sandstone shrine hall with a corbelled stone roof, naga
-- finials and a lotus-bud spire, a strangler fig's pale roots pouring over it, between a fig and a buttressed canopy
-- tree, on a terrace with fruit-tower offerings, candles and incense. Over the road: a gate of carved stone pillars
-- with a palm-thatched hardwood beam, a lashed bamboo tie beam and marigold swags. Back left: a three-tier stone
-- tower being eaten by a fig. Right back: the sacred banyan with buttress fins and prop roots, a checked cloth round
-- its trunk, ribbons, a hornbill; the bronze gong in a bamboo frame. Left hero: the spring basin under green palm
-- thatch, fed by a bamboo spout from a mossy rock; lotus, fish and a blue dart frog. Right hero: the offering stand
-- of palm-leaf trays, lontar wish strips and marigolds. Bottom left: a rain-wet raked gravel garden edged in moss.
-- A joss-stick urn, stone lanterns with ferns on their caps, frangipani, heliconia, elephant ears, parrots, birdwings.
-- Quirk (kept): a real ocelot kitten sits on the plinth beside the stone jaguar, wearing its red bib.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "shrine", out = DIR, farTrees = { 24, 150, 300, 318, 352, 440 }, treeLineGap = { 180, 300 },
  shafts = { { 30, 16 }, { 128, 9 }, { 300, 18 }, { 400, 10 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local RED = L.awnA
local TST = F.rp("#dcd6b2 #b6ae8a #8e8a6c #68684f #42453a")    -- weathered temple sandstone, lichen-gold
local BRONZE = F.rp("#e2c47c #b48e4e #866838 #5e4a2c #3a2e22")
local ROPE = F.rp("#ecd890 #ccb066 #a48848 #765e36 #4c3c26")   -- palm-fibre cord, lidi broom ribs
local MARI = F.rp("#ffe680 #ffb43c #f08424 #b8561c #6e3018")   -- marigold
local KAPOK = F.rp("#d4dac6 #aab49e #828e7e #5e6a60 #3a4440")  -- banyan / frangipani grey bark
local FRANG = F.rp("#fff4d6 #f6e2b0 #e8c27a #c0904c #7a5a34")  -- frangipani petals
local INK = "#2e2a30"
local ROOT = F.rp("#d2c8a6 #a69a7c #7c725e #585046 #38322e") -- strangler-fig roots, warm grey
local RIB = { L.awnA, MARI, L.accent, L.gold, L.lav, L.petal, L.helic }

---------------------------------------------------------------- local helpers
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
-- a joss stick from (x,yb) up h px, glowing tip, a thin wisp of smoke above
local function joss(x, yb, h, lean)
  lean = lean or 0
  F.obj()
  for k = 0, h do px(x + floor(lean * k / h + .5), yb - k, k < 2 and L.timber.deep or RED.shade) end
  local tx = x + floor(lean + .5)
  px(tx, yb - h - 1, L.glow.base)
  for k = 2, 9 do px(tx + floor(sin((k + x) * .7) * 1.2 + .5), yb - h - k, k < 6 and "#d0d6c2" or "#e2e6d4") end
end
local function ribbon(x, y, len, r, dir)
  dir = dir or 1
  for k = 0, len do
    local xx = x + ((k > len // 2) and dir or 0)
    px(xx, y + k, k == 0 and r.hi or r.base) px(xx + 1, y + k, k == len and r.deep or r.shade)
  end
end
-- marigold swag sagging from a to b; drop = spacing of hanging jasmine-and-marigold strands
local function swag(x0, y0, x1, y1, sag, drop, dlen)
  local function ly(xx) local t = (xx - x0) / (x1 - x0) return floor(y0 + (y1 - y0) * t + sag * 4 * t * (1 - t) + .5) end
  F.obj()
  for xx = x0, x1 do
    local y = ly(xx)
    local k, b = (xx - x0) % 3, (xx - x0) // 3
    local r = (b % 5 == 4) and RED or ((b % 3 == 1) and L.gold or MARI)
    if k == 0 then px(xx, y, r.hi) px(xx, y + 1, r.base)
    elseif k == 1 then px(xx, y, r.base) px(xx, y + 1, r.shade)
    else px(xx, y, r.shade) px(xx, y + 1, r.deep) end
  end
  if drop then
    local i = 0
    for xx = x0 + drop // 2, x1 - 2, drop do
      i = i + 1
      local y = ly(xx) + 2
      local n = (dlen or 5) + (i % 2)
      for k = 0, n do
        local r = (k % 2 == 0) and L.awnB or MARI
        px(xx, y + k, k == n and RED.base or r.base) px(xx + 1, y + k, k == n and RED.deep or r.shade)
      end
    end
  end
end
-- a pale strangler-fig root along a polyline
local function root(pts, w, r)
  r = r or ROOT
  local m = line(pts, w)
  rimOf(m, r)
  m:each(function(x, y)
    local h = r.base
    if w > 1 then
      if not m:has(x - 1, y) or not m:has(x, y - 1) then h = r.hi elseif not m:has(x + 1, y) or not m:has(x, y + 1) then h = r.shade end
    elseif (x + y) % 3 == 0 then h = r.hi end
    if hash(x, y, 17) < .07 then h = r.deep end
    if hash(x // 2, y // 2, 18) < .1 then h = L.moss.base end
    px(x, y, h)
  end)
  return m
end
-- a buttress fin from a trunk at x, top at yb-h, reaching dx along the ground
local function fin(x, yb, h, dx, r)
  local s = dx > 0 and 1 or -1
  local pts = { { x, yb - h } }
  for k = 1, 7 do local t = k / 7 pts[#pts + 1] = { x + dx * t, yb - h * (1 - t) ^ 2.4 } end
  pts[#pts + 1] = { x + dx, yb } pts[#pts + 1] = { x, yb }
  local m = poly(pts)
  rimOf(m, r)
  m:each(function(xx, yy)
    local top = not m:has(xx, yy - 1)
    local h2 = s < 0 and (top and r.hi or r.base) or (top and r.base or r.shade)
    if math.abs(xx - x) < 2 then h2 = r.deep end
    if yy > yb - 4 and hash(xx, yy, 19) < .45 then h2 = hash(xx, yy, 20) < .5 and L.moss.base or L.moss.shade end
    if not top and hash(xx // 2, yy, 21) < .08 then h2 = r.deep end
    px(xx, yy, h2)
  end)
  return m
end
-- the shared roof outline: eave x0..x1 at y, ridge rx0..rx1 at yt, upswept tips
local function roofPoly(x0, x1, y, rx0, rx1, yt)
  return poly{ { x0 - 2, y - 3 }, { x0 + 4, y - 1 }, { rx0, yt }, { rx1, yt }, { x1 - 4, y - 1 }, { x1 + 2, y - 3 }, { x1 - 2, y + 2 }, { x0 + 2, y + 2 } }
end
-- corbelled sandstone roof: 4 px tiers, staggered joints, moss on every lip, the right slope in shade
local function stoneRoof(x0, x1, y, rx0, rx1, yt, r, seed)
  local m = roofPoly(x0, x1, y, rx0, rx1, yt)
  rimOf(m, r) part(m, r, { sep = true })
  local cx = (rx0 + rx1) / 2
  m:each(function(x, yy)
    if yy <= y then
      local row, ry = (yy - yt) // 4, (yy - yt) % 4
      local sh = x > cx + 6
      local h
      if ry == 3 then h = r.deep
      elseif ry == 0 then h = sh and r.base or r.hi
      elseif (x + (row % 2) * 5) % 10 == 0 then h = r.deep
      elseif ry == 2 then h = sh and r.deep or r.shade
      else h = sh and r.shade or r.base end
      if ry <= 1 and hash(x // 2, row, seed) < .32 then h = ry == 0 and L.moss.hi or L.moss.base end
      if ry == 2 and hash(x // 3, row, seed + 1) < .14 then h = L.moss.shade end
      px(x, yy, h)
    end
  end)
  hline(rx0, rx1, yt, r.hi)
  hline(x0 + 2, x1 - 2, y + 2, r.deep) hline(x0 + 2, x1 - 2, y + 1, r.shade)
  F.shine(m, .04, seed + 2)
  return m
end
-- palm-leaf thatch roof with a ragged leaf fringe and a bamboo ridge pole
local function thatchRoof(x0, x1, y, rx0, rx1, yt, r, seed)
  local m = roofPoly(x0, x1, y, rx0, rx1, yt)
  rimOf(m, r) part(m, r, { sep = true })
  F.palmThatch(m, r, yt, (rx0 + rx1) // 2, seed)
  line({ { x0 + 2, y - 2 }, { rx0, yt } }):each(function(x, yy) if m:has(x, yy) then px(x, yy, r.hi) end end)
  for x = x0, x1 do
    local len = 1 + floor(hash(x, y, seed) * 3)
    for k = 1, len do px(x, y + 2 + k, k == len and r.edge or (k == 1 and r.deep or r.shade)) end
  end
  local rp_ = rect(rx0 - 2, yt - 2, rx1 + 2, yt)
  rimOf(rp_, L.bamboo) part(rp_, L.bamboo, { nopop = true }) hline(rx0 - 1, rx1 + 1, yt - 2, L.bamboo.hi)
  for x = rx0 + 3, rx1, 7 do vline(x, yt - 2, yt, L.bamboo.deep) end
  return m
end
local function bromeliad(x, y)
  F.obj()
  px(x, y, L.helic.base) px(x - 1, y - 1, L.helic.hi) px(x + 1, y - 1, L.helic.shade) px(x, y - 2, L.helic.hi)
  px(x - 2, y, L.vine.hi) px(x + 2, y, L.vine.shade) px(x - 3, y - 1, L.vine.base) px(x + 3, y - 1, L.vine.deep) px(x, y + 1, L.vine.deep)
end
local function frangi(x, y)
  px(x, y, L.gold.base) px(x - 1, y, FRANG.hi) px(x + 1, y, FRANG.base) px(x, y - 1, FRANG.hi) px(x, y + 1, FRANG.shade)
end
-- a stacked fruit tower offering on a footed tray (gebogan): rows of fruit narrowing upward, a flower on top
local function fruitTower(x, yb, h)
  local foot = rect(x - 2, yb - 2, x + 2, yb)
  local tray = rect(x - 5, yb - 4, x + 5, yb - 3)
  rimOf(union(foot, tray), L.timber) part(foot, L.timber, { nopop = true }) part(tray, BRONZE, { nopop = true })
  local fr = { L.produce, L.apple, L.leaf, L.gold, MARI, L.helic }
  local y = yb - 5
  local m = HP.mask()
  for row = 0, h - 1 do local w = 5 - floor(row * 4 / h) m:add(rect(x - w, y - row * 2 - 1, x + w, y - row * 2)) end
  rimOf(m, L.soil)
  for row = 0, h - 1 do
    local w = 5 - floor(row * 4 / h)
    for xx = x - w, x + w do
      local r = fr[(row + (xx - x + 10) // 2) % #fr + 1]
      px(xx, y - row * 2 - 1, (xx - x) % 2 == 0 and r.hi or r.base) px(xx, y - row * 2, (xx - x) % 2 == 0 and r.base or r.shade)
    end
  end
  local ty = y - h * 2
  px(x, ty - 1, FRANG.hi) px(x - 1, ty, FRANG.base) px(x + 1, ty, FRANG.base) px(x, ty, L.gold.base) px(x, ty - 2, L.leaf.base)
end

---------------------------------------------------------------- low mist lying in the clearing behind the shrine
F.depth(1)
for y = 115, 128 do for x = 0, 479 do
  local v = hash(x // 13, y // 2, 88)
  if v < .42 - (y - 115) * .03 and (y % 2 == 0 or hash(x, y, 89) < .45) then px(x, y, (y % 3 == 0) and L.mist2 or L.mist) end
end end

---------------------------------------------------------------- back-left: three-tier stone tower, a fig eating it
local function tower(cx, yb)
  F.shadow(cx - 16, cx + 16, yb, 8, 3)
  local base = rect(cx - 19, yb - 5, cx + 19, yb)
  rimOf(base, TST) part(base, TST) F.courses(base, yb - 5, 5, 9, TST) F.moss(base, .3, 84)
  local y = yb - 5
  for i = 0, 2 do
    local w = 14 - i * 3
    local body = rect(cx - w, y - 12, cx + w, y)
    local corn = rect(cx - w - 3, y - 15, cx + w + 3, y - 12)
    rimOf(union(body, corn), TST)
    part(body, TST) F.courses(body, y - 12, 4, 7, TST, i)
    vline(cx - w + 1, y - 11, y, TST.hi) vline(cx + w - 1, y - 11, y, TST.deep) -- pilasters
    -- an arched niche with a lamp
    local n = c:rrect(cx - 3, y - 10, cx + 3, y - 1, 3)
    fill(n, TST.edge) fill(rect(cx - 2, y - 6, cx + 2, y - 1), L.soil.deep)
    px(cx, y - 4, L.glow.base) px(cx, y - 5, L.glow.hi) px(cx - 1, y - 3, L.glow.shade) px(cx + 1, y - 3, L.glow.shade)
    part(corn, TST, { nopop = true })
    hline(cx - w - 3, cx + w + 3, y - 15, TST.hi) hline(cx - w - 3, cx + w + 3, y - 12, TST.deep)
    for x = cx - w - 2, cx + w + 2, 3 do px(x, y - 13, TST.shade) end
    F.moss(corn, .35, 85 + i)
    y = y - 15
  end
  -- lotus-bud crown
  local bud = poly{ { cx - 6, y }, { cx + 6, y }, { cx + 5, y - 6 }, { cx + 2, y - 11 }, { cx, y - 13 }, { cx - 2, y - 11 }, { cx - 5, y - 6 } }
  rimOf(bud, TST) part(bud, TST)
  for k = 0, 3 do hline(cx - 5 + k, cx + 5 - k, y - 2 - k * 3, TST.deep) end
  bud:each(function(x, yy) if x < cx - 1 and hash(x, yy, 86) < .5 then px(x, yy, TST.hi) end end)
  F.moss(bud, .25, 87)
  px(cx, y - 14, L.gold.hi) px(cx, y - 15, L.gold.base)
  return y
end
F.tree(86, 128, 52, 1)
F.palm(14, 134, 44, 3, { lean = -4 })
F.depth(2)
local ty = tower(48, 134)
-- the strangler fig: roots pouring down the left of the tower from a crown on its shoulder
root({ { 40, 86 }, { 35, 96 }, { 33, 108 }, { 31, 122 }, { 28, 134 } }, 3)
root({ { 36, 100 }, { 26, 108 }, { 23, 120 }, { 21, 134 } }, 2)
root({ { 44, 88 }, { 46, 98 }, { 43, 106 }, { 44, 118 }, { 41, 130 } }, 2)
root({ { 33, 112 }, { 38, 122 }, { 37, 134 } }, 1)
root({ { 50, 86 }, { 56, 94 }, { 61, 104 }, { 62, 114 } }, 1)
F.crown(36, 80, 11, 7, L.leaf, 41)
F.crown(28, 86, 6, 4, L.foliage, 42)
F.vines(F.crown(46, 84, 6, 4, L.leaf, 43), .2, 44, 8)
bromeliad(58, 104) bromeliad(36, 120)
F.fern(64, 118, 4) F.fern(30, 103, 3)
-- a little stack of river stones with a frangipani on top
local function cairn(x, yb, s)
  local y = yb
  for k = 0, s - 1 do
    local w, h = floor((s - k) * 1.6) + 1, 2 + (s - k) // 2
    local m = c:ellipse(x + (k % 2), y - h // 2 - 1, w, math.max(1, h // 2))
    rimOf(m, L.stone) part(m, L.stone, { nopop = true })
    px(x + (k % 2) - w // 2, y - h + 1, L.wet)
    if k == 0 or hash(k, x, 86) < .5 then px(x + (k % 2), y - h, L.moss.base) end
    y = y - h
  end
  frangi(x + (s % 2), y - 1)
end
cairn(76, 136, 4)

---------------------------------------------------------------- the road's end: terrace, steps, the stone shrine hall
F.depth(2)
F.tree(182, 128, 74, 3)
F.tree(300, 128, 66, 1)
local terr = poly{ { 188, 126 }, { 292, 126 }, { 288, 112 }, { 192, 112 } }
F.shadow(190, 292, 128, 8, 3)
rimOf(terr, TST) part(terr, TST) F.courses(terr, 112, 5, 12, TST) F.moss(terr, .22, 87) F.shine(terr, .05, 88)
for k = 0, 4 do
  local y = 124 - k * 3
  local m = rect(228 + k, y, 252 - k, y + 2)
  fill(m, L.road.base) hline(228 + k, 252 - k, y, L.road.hi) hline(228 + k, 252 - k, y + 2, L.road.deep)
  for x = 229 + k, 251 - k do if hash(x, y, 88) < .14 then px(x, y + 1, L.moss.base) elseif hash(x, y, 89) < .05 then px(x, y, L.wet) end end
end
-- hall walls of sandstone block between carved pillars
local hall = rect(204, 92, 276, 112)
rimOf(hall, TST) part(hall, TST) F.courses(hall, 92, 4, 9, TST, 2)
for _, x in ipairs({ 204, 216, 228, 249, 261, 273 }) do
  fill(rect(x, 92, x + 3, 112), TST.base) vline(x, 92, 112, TST.hi) vline(x + 3, 92, 112, TST.deep)
  hline(x, x + 3, 93, TST.hi) hline(x, x + 3, 95, TST.deep) hline(x, x + 3, 109, TST.deep) hline(x, x + 3, 110, TST.hi)
  for y = 98, 106, 4 do px(x + 1, y, TST.shade) px(x + 2, y + 1, TST.shade) end
end
-- carved relief panels: a lotus in a frame
for _, d in ipairs({ { 220, 226 }, { 254, 260 } }) do
  local m = rect(d[1], 96, d[2], 108) fill(m, TST.shade) c:edgeIn(m, TST.deep)
  local mx = (d[1] + d[2]) // 2
  F.sprite({ "...h...", "..hbh..", ".hbbbh.", "hbbhbbh", ".bbbbb.", "..ddd..", "...d...", ".ddddd." }, mx - 3, 98, { h = TST.hi, b = TST.base, d = TST.deep }, { rim = false })
  F.moss(m, .1, d[1])
end
-- open middle bay: candle-lit altar, a little mossy stone gnome idol garlanded with marigolds
fill(rect(232, 96, 248, 112), L.soil.deep)
fill(rect(234, 99, 246, 110), L.soil.shade)
fill(rect(236, 100, 244, 108), L.glow.deep) fill(rect(238, 101, 242, 106), L.glow.shade)
F.sprite({ "...h...", "..hhh..", "..hhhh.", ".sfffs.", ".sbbbs.", "smmmmms", ".sbbbs.", ".sssss." }, 237, 99,
  { h = L.moss.base, s = TST.shade, f = TST.hi, b = TST.base, m = MARI.base })
for _, x in ipairs({ 234, 236, 244, 246 }) do candle(x, 105 + (x % 3), 3) end
glowSpill(240, 104, 8, .35)
-- offering ledge: banana-leaf trays with fruit
local box = rect(232, 107, 248, 112) rimOf(box, L.timber) part(box, L.timber) for x = 234, 246, 3 do px(x, 108, L.timber.deep) end
for _, o in ipairs({ { 235, L.gold }, { 240, L.apple }, { 245, L.produce } }) do
  hline(o[1] - 2, o[1] + 2, 106, L.leaf.base) px(o[1] - 2, 106, L.leaf.hi) px(o[1] + 2, 106, L.leaf.deep)
  px(o[1] - 1, 105, o[2].hi) px(o[1], 105, o[2].base) px(o[1] + 1, 105, o[2].shade) px(o[1], 104, o[2].base)
end
-- corbelled stone roof
local roofM = stoneRoof(188, 292, 90, 214, 266, 66, TST, 89)
local ridge = rect(212, 62, 268, 66) rimOf(ridge, TST) part(ridge, TST, { nopop = true }) hline(212, 268, 62, TST.hi) F.moss(ridge, .3, 90)
for x = 215, 265, 6 do -- a cresting of little lotus buds along the ridge
  local b = rect(x, 59, x + 2, 61) rimOf(b, TST) fill(b, TST.base) px(x, 59, TST.hi) px(x + 2, 61, TST.shade) px(x + 1, 58, TST.hi)
end
-- central lotus-bud spire on the ridge
local sp = poly{ { 234, 62 }, { 246, 62 }, { 244, 54 }, { 241, 48 }, { 240, 46 }, { 239, 48 }, { 236, 54 } }
rimOf(sp, TST) part(sp, TST)
for k = 0, 3 do hline(235 + k, 245 - k, 60 - k * 3, TST.deep) end
sp:each(function(x, y) if x < 239 and hash(x, y, 91) < .5 then px(x, y, TST.hi) end end)
px(240, 45, L.gold.hi) px(240, 44, L.gold.base)
-- naga heads rearing at both eave tips
do
  local naga = { ".hhh...", "hhsss..", "esssSS.", ".ddssS.", "...ssS.", "...hsS.", "..hssS.", ".hssS..", "hssS..." }
  local mir = {}
  for i, r in ipairs(naga) do mir[i] = r:reverse() end
  local map = { h = TST.hi, s = TST.base, S = TST.shade, d = TST.edge, e = L.glow.base }
  F.sprite(naga, 182, 77, map) F.sprite(mir, 292, 77, map)
end
-- carved pediment with a gilded sunburst
local gab = poly{ { 226, 88 }, { 240, 71 }, { 254, 88 } } fill(gab, TST.shade) c:edgeIn(gab, TST.deep)
gab:each(function(x, y) if (y - 71) % 4 == 3 then px(x, y, TST.deep) elseif x < 240 and hash(x, y, 92) < .3 then px(x, y, TST.base) end end)
local sun = c:ellipse(240, 82, 3, 3) c:rim(sun, TST.edge) fill(sun, L.gold.base) px(239, 81, L.gold.hi) px(241, 83, L.gold.shade) px(242, 82, L.gold.deep)
for _, d in ipairs({ { -6, 1 }, { 6, 1 }, { 0, -6 }, { -4, -4 }, { 4, -4 } }) do px(240 + d[1], 82 + d[2], L.gold.shade) end
-- bell rope and bronze bell
vline(240, 91, 104, RED.base) vline(241, 91, 104, L.gold.base)
local bell = c:ellipse(240, 93, 2, 2) fill(bell, BRONZE.base) px(239, 92, BRONZE.hi) px(241, 94, BRONZE.deep)
-- marigold swags across the front with jasmine strands
swag(206, 93, 274, 93, 2, 8, 4)
-- the pale fig's roots pouring over the left of the roof, down the hall and over the terrace
root({ { 184, 80 }, { 194, 74 }, { 204, 71 }, { 214, 69 } }, 3)
root({ { 196, 76 }, { 202, 84 }, { 205, 94 }, { 204, 106 }, { 200, 118 }, { 196, 126 } }, 3)
root({ { 204, 71 }, { 212, 78 }, { 215, 88 }, { 214, 100 }, { 217, 110 } }, 2)
root({ { 203, 100 }, { 196, 108 }, { 192, 118 }, { 191, 126 } }, 2)
root({ { 214, 69 }, { 224, 70 }, { 230, 76 } }, 1)
root({ { 215, 92 }, { 222, 96 }, { 224, 104 } }, 1)
F.vines(roofM:copy():clip(rect(220, 80, 292, 92)), .08, 93, 9)
bromeliad(278, 80) bromeliad(206, 66)
F.orchid(268, 92, L.orchid, 2) F.orchid(213, 92, L.petal, 2, true)
for _, f in ipairs({ { 232, 74, 3 }, { 258, 70, 3 }, { 276, 84, 4 } }) do F.fern(f[1], f[2], f[3]) end
-- buttress roots of the canopy tree spilling over the terrace's right corner
fin(300, 128, 12, -14, L.timber) fin(300, 128, 8, 10, L.timber)
-- candles and incense along the foot of the terrace, fruit towers at the corners
for x = 212, 225, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
for x = 256, 269, 3 do candle(x, 129 - (x % 2), 2 + (x % 3)) end
glowSpill(218, 127, 6, .3) glowSpill(262, 127, 6, .3)
joss(226, 126, 6, -1) joss(254, 126, 6, 1)
fruitTower(198, 124, 4) fruitTower(282, 124, 4)

---------------------------------------------------------------- right back: the sacred banyan + the gong
local function banyan()
  F.shadow(380, 440, 162, 10, 4)
  -- prop roots dropped from the limbs
  for i, p in ipairs({ { 368, 92, 154 }, { 374, 96, 158 }, { 452, 90, 152 }, { 458, 94, 150 }, { 446, 96, 156 }, { 386, 98, 160 } }) do
    local pts = {}
    for y = p[2], p[3], 4 do pts[#pts + 1] = { p[1] + floor(sin(y / 7 + i) * 1.5 + .5), y } end
    pts[#pts + 1] = { p[1], p[3] }
    local m = line(pts, 1 + (i % 2))
    m:add(line({ { p[1], p[3] - 4 }, { p[1] - 3, p[3] } })):add(line({ { p[1], p[3] - 3 }, { p[1] + 3, p[3] } }))
    rimOf(m, ROOT)
    m:each(function(x, y) px(x, y, (not m:has(x - 1, y)) and ROOT.hi or (hash(x, y // 3, 30 + i) < .3 and ROOT.shade or ROOT.base)) end)
  end
  local trunk = poly{ { 398, 162 }, { 402, 152 }, { 403, 124 }, { 404, 96 }, { 416, 96 }, { 417, 124 }, { 418, 152 }, { 422, 162 } }
  local limbs = line({ { 406, 104 }, { 386, 94 }, { 366, 90 } }, 3):add(line({ { 414, 100 }, { 434, 92 }, { 460, 88 } }, 3)):add(line({ { 410, 98 }, { 410, 76 } }, 3))
  rimOf(union(trunk, limbs), KAPOK)
  part(trunk, KAPOK) part(limbs, KAPOK, { nopop = true })
  trunk:each(function(x, y)
    if not trunk:has(x - 1, y) then px(x, y, KAPOK.hi)
    elseif (x + floor(sin(y / 9 + x) * 1.5 + .5)) % 4 == 0 then px(x, y, KAPOK.deep) -- fluted, braided stems
    elseif (x + floor(sin(y / 9 + x) * 1.5 + .5)) % 4 == 1 and x < 410 then px(x, y, KAPOK.hi)
    elseif x > 412 and hash(x, y, 34) < .5 then px(x, y, KAPOK.shade) end
    if y > 146 and hash(x // 2, y, 36) < .35 then px(x, y, hash(x, y, 37) < .5 and L.moss.base or L.moss.shade) end
  end)
  limbs:each(function(x, y) if not limbs:has(x, y - 1) then px(x, y, KAPOK.hi) end end)
  -- great buttress fins
  fin(404, 162, 26, -24, KAPOK) fin(416, 162, 22, 22, KAPOK) fin(406, 162, 14, -10, KAPOK) fin(414, 162, 12, 9, KAPOK)
  -- wide flat crown
  local cm = HP.mask()
  for i, cr in ipairs({ { 404, 54, 44, 16, L.foliage2 }, { 366, 70, 24, 12, L.foliage }, { 450, 66, 24, 13, L.foliage2 }, { 386, 84, 18, 9, L.foliage }, { 436, 84, 20, 10, L.foliage }, { 412, 74, 22, 10, L.foliage2 } }) do
    cm:add(F.crown(cr[1], cr[2], cr[3], cr[4], cr[5], 30 + i))
  end
  F.vines(cm, .06, 38, 16)
  -- a checked cloth (black-and-white in spirit, ink-and-cream here) round the trunk, a red sash tied over it
  local cl = rect(403, 126, 417, 138)
  rimOf(cl, L.timber)
  cl:each(function(x, y)
    local k = ((x - 403) // 2 + (y - 126) // 2) % 2 == 0
    local h = k and L.awnB.hi or "#3e3a40"
    if x > 412 then h = k and L.awnB.shade or "#302c34" elseif x < 405 then h = k and FRANG.hi or "#4a4650" end
    px(x, y, h)
  end)
  hline(403, 417, 126, L.gold.base) hline(403, 417, 138, L.gold.shade)
  hline(402, 418, 132, RED.base) hline(402, 418, 133, RED.shade)
  ribbon(400, 133, 9, RED, -1) ribbon(397, 134, 7, L.gold, -1)
  -- ribbons on the low boughs, epiphytes on the limbs
  for i, p in ipairs({ { 380, 98 }, { 392, 100 }, { 432, 96 }, { 444, 94 }, { 372, 94 }, { 452, 96 } }) do
    ribbon(p[1], p[2], 5 + i % 3, RIB[i % #RIB + 1], (i % 2 == 0) and 1 or -1)
  end
  bromeliad(388, 91) bromeliad(436, 88)
  F.orchid(396, 95, L.orchid, 3, true) F.orchid(424, 92, L.petal, 2)
  F.fronds(404, 112, 5, 6, L.fern, 39, "fern") -- a staghorn fern in the fork
  -- a little spirit house at the foot: a stone stand with an offering tray
  local sh = rect(424, 150, 432, 160) rimOf(sh, TST) part(sh, TST)
  fill(rect(426, 152, 430, 157), L.soil.deep) px(428, 155, L.glow.base) px(428, 154, L.glow.hi) candle(426, 157, 2)
  local shr = poly{ { 421, 150 }, { 428, 144 }, { 435, 150 } } rimOf(shr, RED) part(shr, RED, { nopop = true }) hline(422, 434, 150, RED.deep)
  F.moss(sh, .2, 39)
  -- a rhinoceros hornbill on the left limb
  F.sprite({
    "..Oo.......",
    ".YYOK......",
    "YYYYeKK....",
    "Y.Y.KKKK...",
    ".....KWKKK.",
    ".....KKKKKK",
    "......KKWWW",
    ".......k...",
  }, 370, 80, { O = MARI.base, o = MARI.shade, Y = L.gold.hi, K = INK, e = L.awnA.base, W = L.awnB.hi, k = L.gold.shade })
end
local function gongFrame(x0, yb)
  local posts = rect(x0, yb - 34, x0 + 2, yb):add(rect(x0 + 30, yb - 34, x0 + 32, yb))
  local beam = rect(x0 - 3, yb - 35, x0 + 35, yb - 33)
  F.shadow(x0, x0 + 34, yb, 8, 3)
  rimOf(union(posts, beam), L.timber)
  part(posts, L.bamboo, { nopop = true }) posts:each(function(x, y) if (y - yb) % 7 == 0 then px(x, y, L.bamboo.deep) elseif x == x0 or x == x0 + 30 then px(x, y, L.bamboo.hi) end end)
  part(beam, L.bamboo, { nopop = true }) hline(x0 - 2, x0 + 34, yb - 35, L.bamboo.hi)
  thatchRoof(x0 - 8, x0 + 40, yb - 37, x0 + 4, x0 + 28, yb - 46, L.roof, 91)
  -- the hanging bronze gong
  local gx, gy = x0 + 16, yb - 18
  for _, rx in ipairs({ gx - 5, gx + 5 }) do line({ { rx, yb - 32 }, { gx + (rx - gx) // 2, gy - 8 } }):each(function(x, y) px(x, y, ROPE.deep) end) end
  local g = c:ellipse(gx, gy, 9, 9)
  rimOf(g, BRONZE) part(g, BRONZE)
  g:each(function(x, y)
    local d = math.sqrt((x - gx) ^ 2 + (y - gy) ^ 2)
    if d > 7.2 then px(x, y, (x - gx) + (y - gy) < 0 and BRONZE.hi or BRONZE.deep)
    elseif d > 6.2 then px(x, y, BRONZE.shade)
    elseif (x - gx) + (y - gy) < -6 then px(x, y, BRONZE.hi) end
    if y > gy + 3 and hash(x, y, 92) < .1 then px(x, y, L.accent.shade) end -- verdigris
  end)
  local boss = c:ellipse(gx, gy, 3, 3) c:rim(boss, BRONZE.deep) fill(boss, BRONZE.base) px(gx - 1, gy - 1, BRONZE.hi) px(gx - 2, gy - 1, L.wet) px(gx + 1, gy + 1, BRONZE.shade)
  F.vines(rect(x0 - 3, yb - 33, x0 + 6, yb - 33), .5, 93, 9)
end
banyan()
gongFrame(300, 140)
swag(334, 105, 398, 116, 3, 10, 3)
local _, rx, ry = F.gnome(352, 142, { hat = L.lav, coat = L.roof2, arm = "up", flip = true })
line({ { rx, ry }, { 329, 120 } }):each(function(x, y) px(x, y, L.timber.edge) end)
local mal = c:ellipse(327, 120, 2, 2) c:rim(mal, RED.edge) fill(mal, RED.base) px(326, 119, RED.hi)

---------------------------------------------------------------- the gate over the road: stone pillars, thatched beam
local function gate()
  local postL, postR = rect(203, 122, 209, 198), rect(271, 122, 277, 198)
  local kasagi = poly{ { 184, 110 }, { 194, 114 }, { 286, 114 }, { 296, 110 }, { 294, 118 }, { 186, 118 } }
  local cap = poly{ { 186, 106 }, { 196, 109 }, { 284, 109 }, { 294, 106 }, { 296, 110 }, { 286, 114 }, { 194, 114 }, { 184, 110 } }
  local shimaki = rect(192, 119, 288, 122)
  local nuki = rect(198, 132, 282, 136)
  local plaque = rect(233, 122, 247, 131)
  local feet = rect(200, 194, 212, 199):add(rect(268, 194, 280, 199))
  local caps = rect(201, 122, 211, 125):add(rect(269, 122, 279, 125))
  F.shadow(204, 280, 199, 10, 4)
  local sil = union(postL, postR, kasagi, cap, shimaki, nuki, plaque, feet, caps)
  rimOf(sil, TST)
  for _, p in ipairs({ { postL, 203 }, { postR, 271 } }) do
    part(p[1], TST)
    p[1]:each(function(x, y)
      local k = x - p[2]
      local h
      if (y - 122) % 9 == 0 then h = TST.deep elseif (y - 122) % 9 == 1 then h = TST.hi end -- carved drums
      if k == 0 or k == 1 then h = h == TST.deep and TST.shade or TST.hi elseif k == 6 then h = TST.deep elseif k == 5 then h = h or TST.shade end
      if (y - 122) % 9 == 5 and k > 1 and k < 5 then h = TST.shade end
      if h then px(x, y, h) end
      if y > 176 and hash(x, y // 2, 95) < .3 + (y - 176) * .03 then px(x, y, hash(x, y, 96) < .5 and L.moss.base or L.moss.shade) end
    end)
  end
  part(caps, TST, { nopop = true }) hline(201, 211, 122, TST.hi) hline(269, 279, 122, TST.hi)
  part(nuki, L.bamboo, { nopop = true }) F.bambooWall(nuki, L.bamboo, 2, true, 94)
  for _, x in ipairs({ 202, 212, 268, 278 }) do vline(x, 132, 136, ROPE.shade) vline(x + 1, 132, 136, ROPE.deep) end
  part(shimaki, RED, { nopop = true }) hline(192, 288, 119, RED.hi) hline(192, 288, 122, RED.deep)
  for x = 196, 286, 6 do px(x, 120, L.gold.base) px(x, 121, L.gold.shade) end
  part(kasagi, L.timber, { nopop = true }) hline(194, 286, 114, L.timber.hi) hline(186, 294, 117, L.timber.deep) hline(186, 294, 118, L.timber.edge)
  part(cap, L.roof2, { nopop = true }) F.palmThatch(cap, L.roof2, 106, 9999, 97)
  for x = 186, 294 do if hash(x, 4, 98) < .5 then px(x, 115 + floor(hash(x, 5, 98) * 2), L.roof2.deep) end end
  part(feet, L.stone, { nopop = true }) F.moss(feet, .45, 98)
  part(plaque, L.timber) c:edgeIn(plaque, L.gold.shade)
  F.sprite({ ".p.p.", "pPgPp", ".pPp.", "..l..", ".lll." }, 238, 124, { p = L.orchid.base, P = L.orchid.hi, g = L.gold.hi, l = L.leaf.shade }, { rim = false })
  -- vines from the beam, a fig root wrapping the left pillar, orchids climbing the right
  F.vines(rect(196, 118, 284, 118), .1, 99, 12)
  for y = 124, 196 do
    local x = 203 + floor((sin(y / 6) + 1) * 3.2 + .5)
    px(x, y, L.birch.base) px(x + 1, y, (sin(y / 6) > 0) and L.birch.shade or L.birch.hi)
  end
  for y = 128, 196 do
    local x = 276 - floor((sin(y / 4.5 + 1) + 1) * 1.6 + .5)
    px(x, y, L.vine.shade)
    if y % 5 == 0 then px(x - 1, y, L.vine.hi) px(x + 1, y + 1, L.vine.base) end
  end
  F.orchid(277, 150, L.orchid, 2) F.orchid(278, 172, L.petal, 2) F.orchid(202, 162, L.orchid, 2, true)
  -- marigold swags under the tie beam, red sashes round the pillars
  swag(210, 137, 270, 137, 4, 12, 3)
  for i, p in ipairs({ { 203, 150 }, { 271, 154 } }) do
    hline(p[1], p[1] + 6, p[2], RED.base) hline(p[1], p[1] + 6, p[2] + 1, RED.shade)
    ribbon(p[1] + (i == 1 and -1 or 6), p[2] + 2, 7, RED, i == 1 and -1 or 1)
  end
end

---------------------------------------------------------------- stone lantern with a stepped cap, scaled by depth
local function toro(x, yb, s, seed)
  local function R(a, b, cc, d) return rect(floor(x + a * s), floor(yb + b * s), floor(x + cc * s), floor(yb + d * s)) end
  local base = R(-5, -3, 5, 0)
  local post = R(-2, -13, 2, -3)
  local fire = R(-5, -20, 5, -13)
  local c1, c2, c3 = R(-7, -22, 7, -20), R(-5, -24, 5, -22), R(-3, -26, 3, -24)
  local knob = c:ellipse(x, floor(yb - 28 * s), math.max(1, floor(1.5 * s)), math.max(1, floor(2 * s)))
  F.shadow(floor(x - 4 * s), floor(x + 5 * s), yb, floor(5 * s), floor(2 * s))
  rimOf(union(base, post, fire, c1, c2, c3, knob), L.stone)
  part(base, L.stone) part(post, L.stone, { nopop = true }) part(fire, L.stone, { sep = true })
  local win = R(-2, -18, 2, -15) fill(win, L.glow.base) px(floor(x - 2 * s), floor(yb - 18 * s), L.glow.hi)
  win:each(function(xx, y) if not win:has(xx + 1, y) or not win:has(xx, y + 1) then px(xx, y, L.glow.shade) end end)
  for _, m in ipairs({ c1, c2, c3 }) do part(m, L.stone, { nopop = true }) local x0, y0, x1 = m:bbox() hline(x0, x1, y0, L.stone.hi) end
  part(knob, L.stone, { nopop = true })
  union(c1, c2, c3):each(function(xx, y) if hash(xx, y, 61 + seed) < .35 then px(xx, y, hash(xx, y, 62) < .4 and L.moss.hi or L.moss.base) end end)
  base:each(function(xx, y) if hash(xx, y, 63) < .3 then px(xx, y, L.moss.shade) end end)
  F.shine(union(base, fire), .06, seed)
  if s >= 1 then F.fern(floor(x + 4 * s), floor(yb - 22 * s), 3) end
  if s >= .7 and seed % 2 == 0 then bromeliad(floor(x - 4 * s), floor(yb - 22 * s)) end
end

---------------------------------------------------------------- left hero: spring basin under green palm thatch
local function basinPavilion()
  local x0, x1, yt, yb = 96, 184, 150, 214
  local posts = rect(x0 + 6, yt + 8, x0 + 9, yb):add(rect(x1 - 9, yt + 8, x1 - 6, yb))
  F.shadow(x0 + 6, x1, yb, 12, 5)
  rimOf(posts, L.timber) part(posts, L.timber, { nopop = true })
  posts:each(function(x, y) if hash(x, y // 3, 64) < .2 then px(x, y, L.timber.shade) end if y > 204 and hash(x, y, 65) < .5 then px(x, y, L.moss.base) end end)
  local rm = thatchRoof(x0 - 6, x1 + 6, yt + 8, x0 + 16, x1 - 16, yt - 14, L.roof2, 66)
  local tri = poly{ { 128, yt + 4 }, { 140, yt - 10 }, { 152, yt + 4 } } fill(tri, L.timber.base) c:edgeIn(tri, L.timber.deep)
  F.planks(tri, L.timber, 3, true, 23)
  F.sprite({ "e...e", "GGGGG", "GgGgG", ".G.G.", "g...g" }, 138, yt - 4, { e = L.gold.hi, G = L.gold.base, g = L.gold.shade }, { rim = false }) -- gilded frog
  F.vines(rm:copy():clip(rect(x0 - 6, yt + 4, x1 + 6, yt + 12)), .06, 67, 10)
  -- vines spiralling up the posts
  for _, px0 in ipairs({ x0 + 6, x1 - 9 }) do
    for y = yt + 10, yb do
      local x = px0 + floor((sin(y / 4 + px0) + 1) * 1.6 + .5)
      px(x, y, L.vine.shade) if y % 4 == 0 then px(x - 1, y, L.vine.hi) px(x + 1, y + 1, L.vine.base) end
    end
  end
  F.orchid(x0 + 10, yt + 22, L.orchid, 2) F.orchid(x1 - 10, yt + 30, L.petal, 2, true)
  -- sandstone basin with a carved wave band
  local front = rect(112, 190, 168, 208)
  local topm = poly{ { 108, 190 }, { 172, 190 }, { 168, 182 }, { 112, 182 } }
  rimOf(union(front, topm), TST)
  part(front, TST) F.courses(front, 199, 9, 14, TST, 3) F.moss(front, .16, 68)
  for x = 113, 167 do local w = floor(sin(x / 2.2) * 1.2 + .5) px(x, 194 + w, TST.deep) px(x, 193 + w, TST.hi) end
  hline(112, 168, 197, TST.deep)
  F.shine(front, .05, 69)
  part(topm, TST, { sep = true }) F.moss(topm, .12, 69)
  local wat = poly{ { 114, 188 }, { 166, 188 }, { 163, 184 }, { 117, 184 } } F.water(wat, L.water, { step = 2 })
  -- lily pads, a pink lotus and two orange fish
  for _, k in ipairs({ { 122, 186, 3 }, { 152, 187, 2 }, { 133, 185, 2 } }) do
    local m = c:ellipse(k[1], k[2], k[3], 1) fill(m, L.leaf.base) px(k[1] - k[3], k[2], L.leaf.hi) px(k[1] + 1, k[2], L.leaf.deep)
  end
  F.sprite({ ".p.", "pPp" }, 121, 184, { p = L.petal.base, P = L.petal.hi }, { rim = false })
  for _, k in ipairs({ { 140, 187 }, { 158, 186 } }) do px(k[1], k[2], MARI.base) px(k[1] + 1, k[2], MARI.hi) px(k[1] - 1, k[2], MARI.deep) end
  -- mossy rock spring with a bamboo spout and a trickle
  local rk = F.rock(178, 190, 9, 14) F.moss(rk, .6, 70) F.shine(rk, .1, 71)
  local spm = rect(148, 168, 176, 171)
  rimOf(spm, L.bamboo) part(spm, L.bamboo, { nopop = true }) hline(149, 175, 168, L.bamboo.hi)
  for x = 156, 174, 8 do vline(x, 168, 171, L.bamboo.deep) end
  local e = c:ellipse(148, 169, 1, 2) fill(e, L.bamboo.shade) px(148, 169, L.soil.deep)
  F.vines(rect(160, 171, 176, 171), .3, 72, 5)
  vline(148, 172, 184, L.water.hi) vline(149, 173, 184, L.water.base)
  px(147, 184, L.water.hi) px(151, 184, L.water.hi) px(146, 185, L.wet)
  vline(164, 172, 181, L.bamboo.base) vline(165, 172, 181, L.bamboo.deep)
  -- coconut-shell dippers on bamboo handles
  for k = 0, 2 do
    local lx = 118 + k * 10
    fill(line({ { lx, 181 }, { lx + 10, 178 } }), L.bamboo.base)
    local cup = rect(lx - 2, 180, lx + 1, 183) fill(cup, L.soil.base) px(lx - 2, 180, L.soil.hi) px(lx, 182, L.soil.deep) hline(lx - 2, lx + 1, 180, FRANG.base)
  end
  -- a blue poison-dart frog on the basin rim
  F.sprite({ ".e..e.", "BBBBBB", "BkBBkB", "bb..bb" }, 160, 179, { e = INK, B = "#58a6ec", k = "#22305a", b = "#2c5aa8" })
end

---------------------------------------------------------------- right hero: the offering stand
local function offeringStand()
  local x0, x1, yt, yb = 300, 384, 160, 214
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb))
  local rails = rect(x0, 176, x1, 177):add(rect(x0, 192, x1, 193))
  F.shadow(x0, x1, yb, 12, 4)
  rimOf(union(posts, rails), L.timber)
  part(posts, L.timber, { nopop = true }) posts:each(function(x, y) if x == x0 or x == x1 - 3 then px(x, y, L.timber.hi) end if hash(x, y // 3, 71) < .15 then px(x, y, L.timber.deep) end end)
  part(rails, L.bamboo, { nopop = true, noshade = true }) F.bambooWall(rails, L.bamboo, 2, true, 72)
  thatchRoof(x0 - 6, x1 + 6, yt, x0 + 6, x1 - 6, yt - 9, L.roof, 73)
  -- top shelf: woven palm-leaf trays heaped with flowers, a joss stick in some
  local fl = { RED, FRANG, MARI, L.lav, L.petal, L.helic }
  for k = 0, 9 do
    local x = x0 + 5 + k * 8
    if x + 6 < x1 - 3 then
      local m = rect(x, 172, x + 6, 175)
      c:rim(m, L.leaf.edge)
      m:each(function(xx, yy) px(xx, yy, ((xx + yy) % 2 == 0) and L.leaf.base or L.leaf.shade) end) hline(x, x + 6, 172, L.leaf.hi)
      for q = 0, 2 do local r = fl[(k + q) % #fl + 1] px(x + 1 + q * 2, 171, r.base) px(x + 2 + q * 2, 171, r.shade) px(x + 1 + q * 2, 170, r.hi) end
      local r2 = fl[(k + 3) % #fl + 1] px(x + 2, 169, r2.hi) px(x + 3, 169, r2.base) px(x + 4, 169, r2.shade) px(x + 3, 168, r2.hi)
      if k % 3 == 1 then joss(x + 3, 170, 4) end
    end
  end
  -- marigold swags between the shelves
  swag(x0 + 4, 179, x1 - 4, 179, 4)
  -- bottom rail: lontar palm-leaf wish strips and cloth ribbons
  for k = 0, 19 do
    local x = x0 + 6 + k * 4
    if x + 2 < x1 - 3 then
      if k % 4 == 3 then ribbon(x, 194, 7 + k % 3, RIB[k % #RIB + 1])
      else
        local len = 9 + (k % 3)
        local m = rect(x, 194, x + 2, 194 + len)
        c:rim(m, L.board.edge) fill(m, L.board.hi) vline(x + 2, 194, 194 + len, L.board.base)
        for y = 196, 192 + len, 2 do px(x + 1, y, hash(x, y, 74) < .5 and L.timber.deep or L.timber.shade) end
        px(x + 1, 194, RED.base)
      end
    end
  end
end
-- guardian jaguar: seated, round ears, tail curled up behind, carved rosettes
local function jaguar(x, yb, flip, bare)
  local s = flip and -1 or 1
  local r = L.stone
  local body = poly{ { x - 4 * s, yb }, { x - 4 * s, yb - 10 }, { x - 2 * s, yb - 14 }, { x + 3 * s, yb - 14 }, { x + 4 * s, yb } }
  local head = poly{ { x - 3 * s, yb - 14 }, { x - 3 * s, yb - 19 }, { x - 2 * s, yb - 21 }, { x, yb - 19 }, { x + 2 * s, yb - 19 }, { x + 4 * s, yb - 21 }, { x + 5 * s, yb - 18 }, { x + 7 * s, yb - 16 }, { x + 7 * s, yb - 14 }, { x + 3 * s, yb - 13 } }
  local tail = line({ { x - 4 * s, yb - 1 }, { x - 8 * s, yb - 3 }, { x - 9 * s, yb - 8 }, { x - 7 * s, yb - 11 } }, 2)
  local m = union(body, head, tail)
  rimOf(m, r) part(m, r)
  px(x + 2 * s, yb - 17, r.edge) px(x + 3 * s, yb - 17, L.glow.shade) px(x + 7 * s, yb - 15, r.edge) hline(math.min(x + 4 * s, x + 7 * s), math.max(x + 4 * s, x + 7 * s), yb - 13, r.deep)
  m:each(function(xx, y)
    if not m:has(xx, y - 1) and hash(xx, y, 74) < .6 then px(xx, y, L.moss.hi)
    elseif hash(xx // 2, y // 2, 75) < .14 then px(xx, y, L.moss.shade)
    elseif (xx + y * 2) % 7 == 0 and y < yb - 2 and y > yb - 12 then px(xx, y, r.deep) end -- rosettes
  end)
  F.shine(m, .06, 76)
  if not bare then local bib = poly{ { x - 3 * s, yb - 13 }, { x + 3 * s, yb - 13 }, { x, yb - 8 } } fill(bib, RED.base) px(x, yb - 12, RED.hi) end
end
local function plinth(x, yb, w, h)
  local m = rect(x - w, yb - h, x + w, yb) rimOf(m, TST) part(m, TST) hline(x - w, x + w, yb - h, TST.hi) F.moss(m, .25, 76 + x) F.shine(m, .06, x)
  hline(x - w, x + w, yb - 2, TST.deep)
end

---------------------------------------------------------------- rain-wet raked gravel garden edged in moss (bottom-left)
local function gravel()
  local g = poly{ { 20, 230 }, { 150, 226 }, { 162, 264 }, { 20, 266 } }
  local edge = g:grow(3):cut(g)
  edge:each(function(x, y) local v = hash(x // 2, y // 2, 77) px(x, y, v < .4 and L.moss.base or (v < .7 and L.moss.shade or L.moss.hi)) end)
  g:each(function(x, y) px(x, y, L.road.hi) end)
  local rocks = { { 56, 246, 10 }, { 120, 248, 8 } }
  g:each(function(x, y)
    local best = 1e9
    for _, r in ipairs(rocks) do best = math.min(best, math.sqrt(((x - r[1]) / 1.6) ^ 2 + ((y - r[2])) ^ 2) - r[3] * .55) end
    local groove
    if best < 14 then groove = floor(best) % 3 == 0 else groove = (y + floor(sin(x / 20) * 1.5)) % 3 == 0 end
    if groove then px(x, y, hash(x // 4, y, 79) < .12 and L.water.base or L.road.base) end -- rainwater standing in some grooves
    if hash(x, y, 78) < .012 then px(x, y, L.litter.base) end
  end)
  local r1 = F.rock(56, 250, 12, 12) F.moss(r1, .35, 79) F.shine(r1, .1, 80)
  local r2 = F.rock(120, 251, 9, 9) F.moss(r2, .35, 80) F.shine(r2, .1, 81)
  F.moss(F.rock(129, 252, 5, 5), .3, 81)
  bromeliad(52, 239) F.fern(60, 240, 3)
  g:each(function(x, y) if edge:has(x - 2, y) or edge:has(x, y + 2) or edge:has(x + 2, y) then if hash(x // 2, y, 82) < .45 then px(x, y, L.moss.base) end end end)
  for _, p in ipairs({ { 36, 236 }, { 88, 244 }, { 100, 258 }, { 140, 238 }, { 74, 260 }, { 30, 254 } }) do frangi(p[1], p[2]) end
  F.bigLeaf(14, 232, 15, -pi * .62, L.foliage, 21, 6, { heart = true, stem = { 18, 246 } })
  F.bigLeaf(22, 238, 12, -pi * .3, L.leaf, 22, 5, { heart = true, stem = { 20, 250 } })
  for _, f in ipairs({ { 160, 228, 6 }, { 166, 262, 7 }, { 152, 230, 5 } }) do F.fern(f[1], f[2], f[3]) end
end

---------------------------------------------------------------- frangipani tree
local function frangipani(x, yb, h, seed)
  local tips = {}
  local wood = HP.mask()
  local fy = yb - floor(h * .45)
  wood:add(line({ { x, yb }, { x, fy } }, 3))
  for i, d in ipairs({ { -14, -18 }, { -6, -26 }, { 5, -24 }, { 13, -15 } }) do
    local mx, my = x + d[1] // 2, fy + d[2] // 2 + 2
    wood:add(line({ { x, fy }, { mx, my }, { x + d[1], fy + d[2] } }, 2))
    tips[i] = { x + d[1], fy + d[2] }
  end
  rimOf(wood, KAPOK)
  wood:each(function(xx, yy) px(xx, yy, wood:has(xx - 1, yy) and KAPOK.shade or KAPOK.hi) end)
  for i, t in ipairs(tips) do
    for k, a in ipairs({ -pi * .9, -pi * .65, -pi * .4, -pi * .15, -pi * .5 }) do
      F.bigLeaf(t[1], t[2], 10 + (k % 2) * 3, a + (i - 2.5) * .1, k % 2 == 0 and L.foliage or L.leaf, seed + i * 5 + k, 3, { droop = .25 })
    end
    for q, d in ipairs({ { 0, -3 }, { -3, -1 }, { 3, -2 } }) do
      F.sprite({ ".f.", "fyF", ".F." }, t[1] + d[1] - 1, t[2] + d[2] - 1, { f = FRANG.hi, F = FRANG.shade, y = L.gold.base })
    end
  end
end

---------------------------------------------------------------- compose
F.depth(3)
-- a joss-stick urn smoking (left middle), a stone stack beside it
do
  local ped = rect(55, 210, 66, 220)
  local bowl = c:rrect(49, 200, 72, 211, 4)
  F.shadow(52, 70, 220, 6, 2)
  rimOf(union(ped, bowl), L.timber)
  part(ped, TST, { nopop = true }) F.courses(ped, 210, 3, 4, TST) F.moss(ped, .2, 83)
  part(bowl, BRONZE)
  hline(49, 72, 204, BRONZE.deep) for x = 52, 69, 3 do px(x, 207, BRONZE.hi) end
  bowl:each(function(x, y) if y > 206 and hash(x, y, 83) < .15 then px(x, y, L.accent.shade) end end)
  hline(51, 70, 200, L.awnB.base) hline(53, 68, 199, L.awnB.hi) -- sand
  for i, x in ipairs({ 54, 57, 59, 61, 63, 65, 68 }) do joss(x, 199, 8 + (i % 3) * 2, (x - 61) * .4) end
  F.smoke(61, 178, 6, -.3, 2)
  cairn(38, 222, 6)
end
basinPavilion()
offeringStand()
for i, p in ipairs({ { 146, .5, 11 }, { 182, .7, 22 }, { 252, 1.3, 22 } }) do
  local y = p[1]
  toro(floor(F.xl(y)) - p[3], y, p[2], i * 2)
  toro(floor(F.xr(y)) + p[3], y, p[2], i * 2 + 1)
end
gate()
plinth(194, 214, 7, 6) jaguar(194, 208, false)
plinth(291, 214, 14, 6) jaguar(283, 208, true, true)
-- quirk: a real ocelot kitten poses on the plinth beside the stone jaguar, wearing its red bib (the stone one's neck is bare)
F.sprite({
  "..oo...oo......",
  ".oOOo.oOOo.....",
  ".OOOOOOOOO.....",
  ".OdOOOOOdO.....",
  ".OOeOOOeOO.....",
  ".OwwwnwwwO.....",
  "..wwwwwww......",
  "...wwmww....OO.",
  "..RRRRRRR..OdO.",
  ".RRRrRRRRR.OO..",
  "..RRRRRRR..dO..",
  "..OwwwOdO..OO..",
  "..OwwwOOOO.Od..",
  "..OwwwOdOOOOO..",
  "..OwwwOOOdOO...",
  "..OOdOOOOOO....",
  "..kk..kk.......",
}, 291, 191, { o = L.timber.edge, O = "#e8b45c", d = "#6a4a2a", e = "#3e5a3a", w = L.awnB.hi, n = L.apple.shade, m = L.timber.deep, R = RED.base, r = RED.hi, k = L.timber.deep })
gravel()
-- right edge: a frangipani, heliconia, elephant ears (keep x>=380,y>=230 clear: the frame repaints it)
frangipani(446, 226, 64, 52)
F.heliconia(424, 228, 24, 53)
F.heliconia(470, 222, 18, 54)
F.bigLeaf(462, 226, 16, -pi * .7, L.foliage2, 55, 7, { heart = true, stem = { 464, 228 } })
F.bigLeaf(458, 228, 13, -pi * .25, L.leaf, 56, 6, { heart = true, stem = { 456, 228 } })
for i = 0, 14 do local x, y = 420 + floor(hash(i, 1, 55) * 44), 212 + floor(hash(i, 2, 55) * 16) frangi(x, y) end
for _, f in ipairs({ { 414, 228, 7 }, { 436, 228, 6 }, { 300, 224, 6 }, { 290, 232, 7 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(404, 226, L.helic, true) F.mushroom(409, 228, L.helic)
F.orchid(394, 226, L.orchid, 2, true)
F.bush(406, 232, 14, 8, L.moss, 12)
-- a gnome sweeping fallen flowers with a palm-rib broom
local _, bx, by = F.gnome(348, 238, { hat = RED, coat = L.wall2, flip = true, arm = "hold" })
fill(line({ { bx + 1, by - 6 }, { bx - 5, by + 6 } }, 1), L.bamboo.shade)
for k = -5, 4 do line({ { bx - 5, by + 6 }, { bx - 7 + k, by + 11 } }):each(function(x, y) px(x, y, (k % 3 == 0) and ROPE.deep or (k % 2 == 0 and ROPE.hi or ROPE.base)) end) end
hline(bx - 6, bx - 4, by + 7, RED.base)
for i = 0, 34 do local x, y = 314 + floor(hash(i, 1, 5) * 14), 240 + floor(hash(i, 2, 5) * 5) - (i % 3)
  if i % 4 == 0 then frangi(x, y) else local r = L.litter px(x, y, i % 3 == 0 and r.hi or r.base) px(x + 1, y, r.shade) end end
-- a gnome hanging a fresh marigold string on the stand
local _, ex, ey = F.gnome(392, 214, { hat = L.fern, coat = L.lav, arm = "up", flip = true })
for k = 0, 9 do local r = (k % 2 == 0) and MARI or L.gold px(ex, ey + k, r.base) px(ex + 1, ey + k, r.shade) end
px(ex, ey + 10, RED.base)
-- parrots on the gate beam, birds over the hall
F.depth(0)
F.sprite({ ".rr.", "rrYg", "ggggg", ".k.." }, 194, 102, { r = L.apple.base, Y = L.gold.hi, g = "#3aa05a", k = L.gold.shade })
F.sprite({ ".rr.", "gYrr", "ggggg", "..k." }, 280, 102, { r = L.apple.base, Y = L.gold.hi, g = "#3aa05a", k = L.gold.shade })
F.birds({ { 330, 38, 2, "#2e7a46" }, { 342, 44, 1, "#b03a36" }, { 150, 52, 2, "#2e7a46" }, { 160, 46, 1, "#2e7a46" } })
F.depth(3)
-- birdwing butterflies
for _, b in ipairs({ { 186, 222 }, { 288, 190 }, { 86, 180 } }) do
  F.sprite({ "YY.YY", "yYkYy", ".y.y." }, b[1], b[2], { Y = L.gold.hi, y = "#3e6a3a", k = INK }, { rim = false })
end
-- fallen frangipani and orange leaves scattered around
for i = 0, 56 do
  local x, y = 20 + floor(hash(i, 1, 77) * 440), 130 + floor(hash(i, 2, 77) * 130)
  if not (x > 376 and y > 226) then
    if i % 3 == 0 then frangi(x, y)
    else local r = i % 2 == 0 and L.litter or L.helic px(x, y, r.base) px(x + 1, y, r.shade) px(x, y - 1, r.hi) end
  end
end
F.finish()
