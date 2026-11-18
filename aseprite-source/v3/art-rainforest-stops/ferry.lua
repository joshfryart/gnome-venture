-- ferry.lua : "Ferry crossing" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua) and the forest ferry, re-cast for a
-- brown jungle river: a wide, slow, tea-brown river runs across the whole view and the road stops at it on a split-
-- bamboo landing. The ferry is a lashed bamboo raft, the centre hero, mid-river and coming in, hauled across on a
-- guide rope strung from a big canopy tree on the far bank to a hardwood post in the near shallows: the ferryman pulls
-- it hand over hand (a pulley block runs on the rope), a traveller with a banana-leaf bundle and cargo ride it, and a
-- gnome on the landing hauls it in by the tow rope. A kingfisher perches on the guide rope. Far bank: the road goes
-- on from a bamboo landing past the ferryman's stilt house (a little gong, a paper lantern), a stilt hut with smoke,
-- washing, a gnome waving; a giant leaning fig drops a curtain of lianas into the water on the right, a sloth hanging
-- from its limb. River: a dugout fishing canoe, turtles on a drifting log, a caiman's eyes, water hyacinth, a moored
-- raft with a bamboo fish trap. Near bank: a bronze ferry gong under a palm-thatch frame, a painted ferry sign, a
-- bamboo ticket booth with a gnome in the hatch, a bench of waiting travellers, a beached dugout, a barrow of
-- pineapples, cargo, papyrus, elephant ears and heliconia. Quirk: a capybara in a red gnome hat riding the raft on a
-- rattan chest, a little yellow bird on its back.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 70, 120, 168, 330, 372, 446 },
    clouds = { { 150, 44, 40 }, { 290, 34, 50 }, { 420, 70, 28 }, { 196, 78, 24 } },
    shafts = { { 30, 16 }, { 118, 9 }, { 262, 14 }, { 404, 10 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
-- the brown jungle river: tea-and-silt water, an olive sheen far off
local Wt = F.rp("#ccc08a #a6844e #82643c #604632 #3e2e22")
local GLINT = "#f2ecc8"
local clay = F.rp("#f2b07c #d47a48 #a85634 #7a3a28 #4a2418")       -- terracotta jars
local rattan = F.rp("#f0d494 #d2aa62 #a87e42 #7a5630 #4a3420")     -- woven rattan / cane
local burlap = F.rp("#ead6a4 #ccb27c #a68c5c #7a6644 #4c402e")     -- rice-sack hessian
local capy = F.rp("#d0a272 #a8784c #845a3a #5e3e2c #3a261c")       -- capybara fur
local kfB, kfD = "#46b4d4", "#1e6a8c"                               -- kingfisher blue
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end

local function bambooEnd(x, y, rr)
  local m = c:ellipse(x, y, rr, rr)
  c:rim(m, L.bamboo.edge) fill(m, L.bamboo.base)
  m:each(function(xx, yy) if (xx - x) + (yy - y) < -rr * .5 then px(xx, yy, L.bamboo.hi) elseif (xx - x) + (yy - y) > rr * .6 then px(xx, yy, L.bamboo.shade) end end)
  if rr >= 2 then fill(c:ellipse(x, y, rr - 1, rr - 1), L.soil.deep) px(x - 1, y - 1, L.soil.edge) px(x, y, L.bamboo.deep) end
  return m
end
local function sack(x, yb, w)
  local m = F.sack(x, yb, burlap, w)
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 and hash(xx, yy, 5) < .4 then px(xx, yy, burlap.shade) end end)
  px(x, yb - w + 1, L.awnA.base) px(x - 1, yb - w + 2, L.awnA.shade) px(x + 1, yb - w + 2, L.awnA.shade)
  return m
end
local function coconut(x, y, half)
  local m = c:ellipse(x, y, 2, 2)
  c:rim(m, L.soil.edge) fill(m, L.soil.base) px(x - 1, y - 1, L.soil.hi)
  if half then fill(rect(x - 1, y - 1, x + 1, y), L.awnB.hi) px(x, y, L.awnB.shade) end
end
local function jar(x, yb, h)
  h = h or 10
  local w = floor(h * .45)
  local body = c:ellipse(x, yb - floor(h * .45), w, floor(h * .45))
  local neck = rect(x - 1 - w // 3, yb - h - 1, x + 1 + w // 3, yb - floor(h * .7))
  local m = union(body, neck)
  c:rim(m, clay.edge) part(m, clay)
  m:each(function(xx, yy) if xx < x - w * .3 and yy < yb - 2 then px(xx, yy, clay.hi) end end)
  hline(x - w + 1, x + w - 1, yb - floor(h * .55), clay.deep) -- a painted band
  for k = x - w + 2, x + w - 2, 3 do px(k, yb - floor(h * .55) - 1, L.awnB.base) end
  hline(x - 1 - w // 3, x + 1 + w // 3, yb - h - 1, clay.hi)
  return m
end
local function bananas(x, y) -- an upright hand of green bananas, stalk on top
  F.sprite({
    "...k...",
    ".bkbkb.",
    "hbbbbbs",
    "hbsbsbs",
    ".hbbbs.",
    "hbsbsbs",
    ".bbbbs.",
    "..sss..",
  }, x - 3, y - 4, { h = L.leaf.hi, b = L.leaf.base, s = L.leaf.shade, k = L.vine.deep }, { rimCol = L.leaf.edge })
  px(x - 2, y - 1, L.gold.hi) px(x + 1, y + 2, L.gold.base)
end
local function pineapple(x, y)
  local m = c:ellipse(x, y, 3, 4)
  c:rim(m, L.produce.edge) part(m, L.gold, { nopop = true })
  m:each(function(xx, yy) if (xx + yy) % 3 == 0 then px(xx, yy, L.produce.shade) elseif (xx - yy) % 3 == 0 then px(xx, yy, L.produce.base) end end)
  px(x - 2, y - 2, L.gold.hi) px(x - 1, y - 3, L.gold.hi)
  for k = -2, 2 do px(x + k, y - 5 - (2 - abs(k)), abs(k) == 2 and L.leaf.shade or L.leaf.base) px(x + k, y - 5, L.leaf.deep) end
  px(x, y - 8, L.leaf.hi)
end
-- a woven fish trap: a long cone of split bamboo with hoops
local function fishTrap(x0, y0, len)
  local m = poly{ { x0, y0 - 3 }, { x0 + len, y0 - 1 }, { x0 + len, y0 + 1 }, { x0, y0 + 3 } }
  c:rim(m, rattan.edge) part(m, rattan, { nopop = true })
  m:each(function(xx, yy) if (xx - x0) % 4 == 0 then px(xx, yy, rattan.deep) elseif yy < y0 then px(xx, yy, rattan.hi) end end)
end

---------------------------------------------------------------- the river
local river = HP.mask()
for x = 0, 479 do for y = yF(x), yN(x) do river:set(x, y) end end
do
  river:each(function(x, y)
    local f = (y - yF(x)) / math.max(1, yN(x) - yF(x))
    local h
    if f < .18 then h = hash(x // 10, y, 13) < .5 and mix(Wt.hi, L.sky[2], .3) or mix(Wt.hi, L.sky[4], .3)
    elseif f < .4 then h = hash(x // 8, y, 14) < .5 and mix(Wt.hi, Wt.base, .45) or mix(Wt.hi, Wt.base, .7)
    elseif f < .78 then h = hash(x // 12, y // 3, 19) < .3 and mix(Wt.base, Wt.shade, .3) or Wt.base
    else h = hash(x // 6, y // 2, 15) < .6 and mix(Wt.base, Wt.shade, .55) or Wt.shade end
    px(x, y, h)
  end)
  -- current streaks: long thin lit lines drifting with the flow, longer nearer; swirls of silt
  for y = 126, 194 do
    local d = y - 122
    if y % 3 == 0 then
      local x = floor(hash(y, 1, 13) * 30)
      while x < 480 do
        local len = 4 + d // 3 + floor(hash(x, y, 18) * 8)
        if hash(x // 9, y, 16) < .5 then
          for xx = x, x + len do if river:has(xx, y) and river:has(xx, y + 1) then px(xx, y, d > 14 and Wt.hi or mix(Wt.hi, Wt.base, .2)) if d > 14 then px(xx, y + 1, d > 30 and Wt.deep or Wt.shade) end end end
        end
        x = x + len + 10 + floor(hash(x, y, 17) * 22)
      end
    end
  end
  for i = 0, 14 do -- slow eddies: little lit arcs
    local ex, ey = 20 + floor(hash(i, 1, 21) * 440), 140 + floor(hash(i, 2, 21) * 40)
    for k = -4, 4 do local yy = ey + floor(k * k / 8) if river:has(ex + k, yy) then px(ex + k, yy, k < 0 and Wt.hi or mix(Wt.hi, Wt.base, .5)) end end
  end
  for y = 128, 190, 2 do -- the misted sun's glitter path down the river
    local w = 3 + (y - 128) // 10
    for x = 92 - w, 92 + w do if river:has(x, y) and hash(x // 2, y, 24) < .45 then px(x, y, hash(x, y, 25) < .3 and GLINT or Wt.hi) end end
  end
  for i = 0, 60 do local x, y = floor(hash(i, 1, 18) * 480), 126 + floor(hash(i, 2, 18) * 64) if river:has(x, y) and river:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, Wt.hi) end end
  -- far bank: dark root-tangled mud lip; near bank: red mud, roots and wet stones
  for x = 0, 479 do
    px(x, yF(x), Wt.edge) px(x, yF(x) + 1, Wt.deep)
    local v = hash(x, 3, 7)
    px(x, yF(x) - 1, v < .3 and L.soil.deep or (v < .55 and L.mossGround.shade or L.soil.shade))
    local yn = yN(x)
    for k = 1, 4 do
      local col
      if k == 1 then col = L.soil.edge elseif k == 2 then col = L.soil.deep
      else local w = hash(x, k, 5) col = w < .2 and L.stone.base or (w < .4 and L.mossGround.shade or (w < .55 and L.soil.shade or L.soil.base)) end
      px(x, yn + k, col)
    end
    if hash(x, 9, 6) < .2 then px(x, yn + 3, L.moss.hi) end
    if hash(x, 10, 6) < .12 then px(x, yn + 3, L.wet) end
    px(x, yn, mix(Wt.hi, Wt.base, .3))
  end
  -- exposed roots arching over the near-bank mud
  for i = 0, 12 do
    local rx = 10 + floor(hash(i, 1, 23) * 460)
    if not (rx > 180 and rx < 300) then
      for k = 0, 7 do local x = rx + k local y = yN(rx) + 2 - floor(sin(k / 7 * pi) * 2.5 + .5) px(x, y, L.timber.shade) px(x, y + 1, L.timber.edge) end
    end
  end
end

---------------------------------------------------------------- far bank: road on, landing, stilt houses, trees
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 34, 5)
F.palm(20, 122, 40, 3)
F.tree(96, 121, 30, 7)
do -- a stilt hut with hearth smoke
  for _, sx in ipairs({ 38, 50, 64, 78 }) do local s = rect(sx, 116, sx + 1, 124) rimOf(s, L.timber) part(s, L.bamboo, { nopop = true }) end
  local top, cx, wallM, roofM = F.building{ x0 = 36, x1 = 80, yb = 116, wh = 11, rh = 12, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, noShadow = true }
  F.window(44, 108, 48, 111, L.timber) F.window(68, 108, 72, 111, L.timber)
  hline(34, 82, 117, L.timber.base) hline(34, 82, 118, L.timber.deep)
  F.smoke(62, 88, 4, .6, 2)
end
-- far bank plants: little papyrus and grass clumps with tufted heads
local function bankClump(x, yb, n, hmax, seed, near)
  local blades = {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.6)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .5) * (near and 8 or 4)
    blades[#blades + 1] = { bx, h, lean, hash(i, 4, seed) }
  end
  local m = HP.mask()
  local heads = {}
  for _, b in ipairs(blades) do
    local bx, h, lean, v = b[1], b[2], b[3], b[4]
    local pts = { { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }
    m:add(line(pts, 1))
    if v < .5 then heads[#heads + 1] = { floor(bx + lean), yb - h - 1 } end
  end
  if near then c:rim(m, L.vine.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local col = t > .6 and L.vine.hi or (t > .25 and L.vine.base or L.vine.shade)
    if hash(xx, yy, seed) < .22 then col = L.vine.shade end
    if yy >= yb - 1 then col = L.vine.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    if near then -- a papyrus umbel: a starburst of thin rays
      local um = HP.mask()
      for k = -4, 4 do um:set(hx + k, hy - 1 + floor(k * k / 6)) end
      for k = -3, 3 do um:set(hx + k, hy - 2 + floor(k * k / 5)) end
      um:set(hx, hy - 3) um:set(hx - 1, hy - 3) um:set(hx + 1, hy - 3)
      c:rim(um, L.leaf.edge)
      um:each(function(xx, yy) px(xx, yy, (xx < hx) and L.leaf.hi or ((xx + yy) % 2 == 0 and L.leaf.base or L.leaf.shade)) end)
      px(hx, hy, L.vine.deep)
    else
      px(hx - 1, hy, L.leaf.base) px(hx, hy - 1, L.leaf.hi) px(hx + 1, hy, L.leaf.shade)
    end
  end
end
for _, r in ipairs({ { 14, 8 }, { 40, 10 }, { 110, 9 }, { 150, 12 }, { 192, 8 }, { 300, 8 }, { 352, 10 }, { 466, 8 } }) do
  bankClump(r[1], yF(r[1]) + 1, r[2], 8, r[1], false)
end
-- far landing: split bamboo on hardwood piles
do
  local d = poly{ { 234, 121 }, { 248, 121 }, { 250, 130 }, { 232, 130 } }
  rimOf(d, L.timber) part(d, L.bamboo) F.bambooWall(d, L.bamboo, 2, true, 4)
  for _, x in ipairs({ 233, 248 }) do vline(x, 131, 135, L.timber.deep) end
end
F.depth(2)
-- far bank trees right of the landing: the big canopy tree that holds the guide rope, a palm, a pale fig
F.palm(330, 123, 42, 9, { lean = 5 })
F.tree(352, 124, 46, 3)
F.treeFern(372, 123, 24, 8)
F.tree(300, 124, 56, 1)
do -- the ferryman's stilt house over the shallows: palm thatch, a paper lantern pole and a gong post
  local st = HP.mask()
  for _, sx in ipairs({ 166, 178, 190, 202, 212 }) do st:add(rect(sx, 118, sx + 1, 131)) end
  st:add(line({ { 167, 128 }, { 178, 119 } })):add(line({ { 211, 128 }, { 202, 119 } }))
  rimOf(st, L.timber) part(st, L.bamboo, { nopop = true, noshade = true })
  st:each(function(x, y) if y % 5 == 0 then px(x, y, L.bamboo.deep) end end)
  for _, sx in ipairs({ 166, 178, 190, 202, 212 }) do hline(sx - 1, sx + 3, 132, Wt.hi) end
  local top, cx, wallM, roofM = F.building{ x0 = 164, x1 = 214, yb = 118, wh = 16, rh = 16, wall = L.bamboo, roof = L.roof, noAttic = true, noFrame = true, noShadow = true }
  F.bambooWall(wallM:copy():clip(rect(164, top + 4, 214, 118)), L.bamboo, 3, false, 41)
  local deck = rect(160, 117, 218, 119) rimOf(deck, L.timber) part(deck, L.timber, { nopop = true }) hline(160, 218, 117, L.timber.hi)
  F.door(184, 106, 192, 117, L.timber)
  F.window(171, 104, 176, 109, L.timber) F.window(201, 104, 206, 109, L.timber)
  F.smoke(204, 72, 6, .7, 2)
  -- a carved hornbill over the door
  F.sprite({ "gg....", "gGkkk.", ".kkk..", "..k..." }, 185, 99, { g = L.gold.base, G = L.produce.base, k = L.timber.deep }, { rim = false })
  -- the far gong post at the landing
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.timber) part(bp, L.timber, { nopop = true, noshade = true })
  local fb = c:ellipse(227, 105, 3, 3) c:rim(fb, L.timber.edge) part(fb, L.gold, { nopop = true }) px(227, 105, L.gold.shade) px(226, 104, L.gold.hi)
  vline(227, 102, 102, L.needle.deep)
  -- a red paper lantern on a bamboo pole
  local lp = rect(256, 98, 257, 125) rimOf(lp, L.bamboo) part(lp, L.bamboo, { nopop = true, noshade = true })
  fill(rect(256, 98, 262, 98), L.bamboo.base)
  local lam = c:ellipse(261, 103, 3, 3) c:rim(lam, L.timber.edge) part(lam, L.awnA, { nopop = true }) px(260, 102, L.glow.hi) px(261, 103, L.glow.base)
  hline(259, 263, 100, L.timber.deep) hline(259, 263, 106, L.timber.deep) px(261, 107, L.gold.base)
  -- washing between the house and a pole
  local wp = rect(132, 100, 133, 124) rimOf(wp, L.bamboo) part(wp, L.bamboo, { nopop = true, noshade = true })
  F.washing(133, 100, 163, 104, { { "shirt", L.awnA }, { "sock", L.accent }, { "sheet", L.helic } }, 3)
end
-- a small gnome waving from the far landing
F.gnome(242, 128, { small = true, hat = L.awnA, coat = L.leaf, arm = "up" })
do -- a giant fig leaning over the water on the right: buttressed grey trunk, an umbrella crown, a curtain of lianas
   -- hanging into the river, orchids on the limb, a sloth hanging under it
  local fig = F.rp("#9ad86a #52a84a #2e8046 #1c5e3e #103e30")
  -- the umbrella crown first, so the limbs and trunk read in front of its underside
  local cm = HP.mask()
  for _, lb in ipairs({ { 436, 48, 16, 8 }, { 428, 58, 26, 11 }, { 400, 70, 18, 9 }, { 458, 62, 18, 10 }, { 382, 80, 10, 6 } }) do
    cm:add(F.crown(lb[1], lb[2], lb[3], lb[4], fig, lb[1]))
  end
  -- the liana curtain: strands of different lengths dropping from the crown underside, leaf pairs, a few reaching
  -- the water; back strands dark, front ones lit on the left
  local function bottomOf(x) for y = 92, 40, -1 do if cm:has(x, y) then return y end end end
  for layer = 1, 2 do
    for sx = 380, 474, layer == 1 and 3 or 4 do
      local top = bottomOf(sx)
      if top and hash(sx, layer, 136) < (layer == 1 and .6 or .45) then
        local bot = math.min(yF(sx) + 1, top + 8 + floor(hash(sx, layer, 134) ^ 1.6 * 46))
        local ph = hash(sx, 3, 137) * 6
        for y = top + 1, bot do
          local xx = sx + floor(sin(y / 7 + ph) * 1.1 + .5)
          local col = layer == 1 and L.vine.deep or ((sx < 432 and (y - top) < 18) and L.vine.base or L.vine.shade)
          px(xx, y, col)
          if (y + sx) % 4 == 0 then local sd = ((y + sx) // 4) % 2 == 0 and -1 or 1
            px(xx + sd, y, layer == 1 and L.vine.shade or (sd < 0 and L.vine.hi or L.vine.base)) px(xx + sd, y + 1, layer == 1 and L.vine.deep or L.vine.shade) end
        end
        if bot >= yF(sx) then hline(sx - 1, sx + 2, bot + 1, Wt.hi) end
        if layer == 2 and hash(sx, 5, 135) < .25 then px(sx, bot + 1, L.orchid.base) px(sx - 1, bot + 1, L.orchid.hi) px(sx, bot + 2, L.orchid.deep) end
      end
    end
  end
  local trunk = poly{ { 446, 128 }, { 462, 128 }, { 456, 112 }, { 446, 92 }, { 434, 70 }, { 427, 72 }, { 438, 94 }, { 446, 112 } }
  local fins = poly{ { 440, 128 }, { 446, 116 }, { 449, 128 } }:add(poly{ { 458, 128 }, { 456, 116 }, { 468, 128 } })
  local limb = line({ { 437, 86 }, { 414, 83 }, { 392, 87 } }, 2)
  local wood = union(trunk, fins, limb)
  rimOf(wood, L.birch) part(wood, L.birch, { nopop = true })
  wood:each(function(x, y)
    if not wood:has(x - 1, y) then px(x, y, L.birch.hi) end
    if hash(x // 2, y // 3, 131) < .16 then px(x, y, L.birch.shade) end
    if hash(x // 2, y // 2, 132) < .1 then px(x, y, L.moss.base) end
  end)
  -- two strangler roots spiralling down the trunk, and a looping liana from the limb to the trunk
  for k = 0, 1 do
    for y = 78 + k * 10, 127 do local x = floor(440 + (y - 76) * .3 + sin(y / 6 + k * 2.6) * 4) if trunk:has(x, y) then px(x, y, L.timber.base) px(x + 1, y, L.timber.deep) end end
  end
  for xx = 398, 440 do local t = (xx - 398) / 42 local y = floor(86 + 18 * 4 * t * (1 - t) - t * 2 + .5) px(xx, y, L.vine.shade) px(xx, y + 1, L.vine.deep) if xx % 5 == 0 then px(xx, y - 1, L.vine.hi) end end
  F.orchid(408, 82, L.orchid, 3, true) F.orchid(446, 64, L.petal, 2)
  -- a three-toed sloth hanging under the limb
  F.sprite({
    "h..h....",
    "hh.hh...",
    ".SSSS...",
    "SSsSSS..",
    "SSSSSSS.",
    "SSSSSsS.",
    ".SSmmS..",
    ".SmeeS..",
    "..SnS...",
  }, 414, 86, { h = L.timber.edge, S = "#b29a76", s = "#8a7458", m = "#efe0bc", e = L.timber.edge, n = "#6a5440" })
  -- its reflection in the water
  for x = 380, 476 do for y = yF(x) + 2, yF(x) + 12 do if river:has(x, y) and (y + x // 4) % 3 == 0 and hash(x, y, 27) < .7 then px(x, y, mix(fig.shade, Wt.base, .5)) end end end
end
-- reflections of the far bank in the water (broken dashes)
for x = 0, 380 do
  local y0 = yF(x) + 2
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .55 then
    for y = y0, y0 + 9, 2 do if river:has(x, y) and hash(x, y, 32) < .7 - (y - y0) * .05 then px(x, y, mix(v, Wt.base, .45 + (y - y0) * .03)) end end
  end
end

---------------------------------------------------------------- humid mist lying over the far half of the river
F.depth(2)
for y = 125, 138 do
  local x = floor(hash(y, 3, 41) * 40)
  while x < 480 do
    local len = 10 + floor(hash(x, y, 42) * 26)
    if hash(x // 11, y, 43) < .36 - (y - 125) * .025 then
      for xx = x, x + len do if river:has(xx, y) and c:get(xx, y) and hash(xx, y, 44) < .8 then px(xx, y, mix(c:get(xx, y), L.mist2, .45)) end end
    end
    x = x + len + 8 + floor(hash(x, y, 45) * 30)
  end
end

---------------------------------------------------------------- left water: a dugout fishing canoe drifting, a cast net
F.depth(2)
do
  local x0, x1, y = 62, 100, 142
  local hull = poly{ { x0 - 5, y - 3 }, { x0, y - 1 }, { x1, y - 1 }, { x1 + 5, y - 3 }, { x1 - 1, y + 3 }, { x0 + 1, y + 3 } }
  F.gnome(78, y - 2, { small = true, hat = L.awnA, coat = L.roof2, arm = "out", noShadow = true })
  rimOf(hull, L.timber) part(hull, L.timber, { nopop = true })
  hline(x0, x1, y - 1, L.timber.hi) hline(x0 + 1, x1 - 1, y + 1, L.timber.deep)
  for k = x0 + 2, x1 - 2, 6 do px(k, y, L.helic.base) px(k + 1, y, L.gold.base) end -- a painted band
  for k = 0, 2 do hline(x0 + k * 3, x1 - k * 3, y + 5 + k * 2, Wt.shade) end
  -- a paddle across, a cast net held out and its float line on the water
  fill(line({ { 88, y - 6 }, { 98, y - 9 } }), L.timber.deep)
  for k = 0, 9 do px(90 + k, y - 4 + floor(k * .7), L.awnB.shade) end
  for k = 0, 8 do px(99 + k * 2, y + 1 + (k % 2), L.awnB.base) end
  for k = 0, 4 do px(100 + k * 4, y + 2, L.helic.base) end
  hline(98, 118, y + 4, Wt.hi)
end
-- a caiman lurking: snout tip, eye bumps and a ridged back breaking the surface
do
  local cx, cy = 120, 160
  F.sprite({ "...........kk......", "kkk.......kKKk...k.", "kKKkkKkKkkKKKKkkKKk", "..kkkkkkkkkkkkkkkk." }, cx, cy - 3, { k = "#3a4028", K = "#7a8450" })
  px(cx + 11, cy - 2, L.gold.hi) px(cx + 12, cy - 2, L.timber.edge) px(cx + 1, cy - 2, "#7a8450")
  hline(cx - 3, cx + 21, cy + 1, Wt.hi) hline(cx + 2, cx + 16, cy + 2, Wt.deep) hline(cx - 6, cx - 2, cy - 1, Wt.hi)
end

---------------------------------------------------------------- the near landing (split bamboo) and its hardwood piles
F.depth(3)
local LY0, LY1 = 166, 180
do
  local deck = poly{ { F.xl(LY0) - 6, LY0 }, { F.xr(LY0) + 6, LY0 }, { F.xr(LY1) + 6, LY1 }, { F.xl(LY1) - 6, LY1 } }
  local face = rect(floor(F.xl(LY0)) - 6, LY0 - 3, floor(F.xr(LY0)) + 6, LY0 - 1)
  local piles = HP.mask()
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do piles:add(rect(x, LY0 - 6, x + 2, LY0 + 6)) end
  rimOf(union(deck, face, piles), L.timber)
  part(piles, L.timber, { nopop = true, noshade = true })
  F.moss(piles, .3, 104)
  part(deck, L.board) F.bambooWall(deck, L.board, 3, true, 9)
  -- rattan lashings across the poles, wet shine, moss at the edges
  for _, lx in ipairs({ floor(F.xl(LY0)) - 3, 240, floor(F.xr(LY0)) + 3 }) do
    for y = LY0, LY1 do if deck:has(lx, y) then px(lx, y, (y % 3 == 0) and L.needle.deep or L.needle.base) end end
  end
  deck:each(function(x, y) if (y >= LY1 - 1 or abs(x - 240) > 16) and hash(x // 2, y, 105) < .22 then px(x, y, hash(x, y, 106) < .5 and L.moss.base or L.moss.shade) end end)
  F.shine(deck, .05, 107)
  part(face, L.timber, { nopop = true, noshade = true })
  for x = floor(F.xl(LY0)) - 5, floor(F.xr(LY0)) + 5, 3 do bambooEnd(x, LY0 - 2, 1) end
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do hline(x - 2, x + 4, LY0 + 7, Wt.hi) fill(rect(x, LY0 - 7, x + 2, LY0 - 7), L.moss.hi) end
end

---------------------------------------------------------------- the guide rope across the river (far tree -> ferryman's hand -> near post)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6 -- where figures stand: the front of the deck stays visible
local GA = { 303, 104 }               -- tied round the far canopy tree's trunk
local GH = { RX1 - 14 + 8, FY - 19 }  -- the ferryman's raised hand
local GP = { 394, 150 }               -- top of the near rope post
local function ropeY(x)
  local a, b, sag
  if x <= GH[1] then a, b, sag = GA, GH, 3 else a, b, sag = GH, GP, 2 end
  local t = (x - a[1]) / (b[1] - a[1])
  return floor(a[2] + (b[2] - a[2]) * t + sag * 4 * t * (1 - t) + .5)
end
local function guideRope()
  local pts = {}
  for x = GA[1], GP[1] do pts[#pts + 1] = { x, ropeY(x) } end
  local r = line(pts, 1)
  c:rim(r, L.timber.edge)
  r:each(function(x, y) px(x, y, (x % 3 == 0) and L.needle.shade or L.needle.base) end)
  -- the wraps round the far trunk
  for k = 0, 2 do px(GA[1] - 2 + k, GA[2] - 1 + k, L.needle.base) px(GA[1] - 2 + k, GA[2] + 1 + k, L.needle.deep) end
end
F.depth(2)
do -- the near rope post in the shallows: a hardwood trunk with a fork at the top, rope wraps, a stay rope
  local pst = rect(GP[1] - 1, GP[2], GP[1] + 1, 186):add(line({ { GP[1] - 1, GP[2] + 1 }, { GP[1] - 4, GP[2] - 4 } })):add(line({ { GP[1] + 1, GP[2] + 1 }, { GP[1] + 4, GP[2] - 4 } }))
  rimOf(pst, L.timber) part(pst, L.timber, { nopop = true })
  vline(GP[1] - 1, GP[2], 186, L.timber.hi)
  F.moss(rect(GP[1] - 1, 172, GP[1] + 1, 186), .4, 141)
  for k = 0, 2 do hline(GP[1] - 1, GP[1] + 1, GP[2] + 2 + k * 2, L.needle.base) end
  fill(line({ { GP[1] + 1, GP[2] + 2 }, { GP[1] + 14, 184 } }), L.needle.shade) -- stay rope down to a stake
  local sk = rect(GP[1] + 14, 180, GP[1] + 15, 186) rimOf(sk, L.timber) part(sk, L.timber, { nopop = true, noshade = true })
  for k = 0, 2 do hline(GP[1] - 4 - k * 2, GP[1] + 4 + k * 2, 187 + k * 2, k == 1 and Wt.shade or Wt.hi) end
end

---------------------------------------------------------------- the ferry raft (centre hero): lashed bamboo
F.depth(3)
local function capybara(x0, y0)
  y0 = y0 - 3
  F.sprite({
    ".........r..........",
    "........RRr.........",
    ".......RRr..........",
    "......RR............",
    ".....RRr............",
    "....HRRr............",
    "....RRRRr...........",
    "...HRRRRRr..........",
    "..bbbbbbbbb...yy....",
    "..aCCCCCCCa..yYyk...",
    ".CCCCeCCCCCCcyyy....",
    "CCCCCCCCCCCCCCCcc...",
    "nCCCCCCCCCCCCCCCCc..",
    "nnCCCCCCCCCCCCCCCc..",
    ".nmCCCcCCCCCCCCCCcd.",
    "..ccc.cCCCCCCCCCCcd.",
    "......cCCCCCCCCCccd.",
    "......cc.cCCcc..cd..",
    "......dd.dd....dd...",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.gold.hi, C = capy.base, c = capy.shade, d = capy.deep,
    a = capy.deep, e = L.timber.edge, n = capy.edge, m = capy.deep, Y = L.gold.hi, y = L.gold.base, k = L.timber.edge })
  y0 = y0 + 3
  -- lit fur on the upper left of the head and back
  for _, p in ipairs({ { 1, 7 }, { 2, 7 }, { 3, 7 }, { 0, 8 }, { 1, 8 }, { 2, 8 }, { 3, 6 }, { 4, 6 }, { 7, 8 }, { 8, 8 }, { 9, 8 }, { 10, 8 }, { 11, 8 } }) do px(x0 + p[1], y0 + p[2], capy.hi) end
  px(x0 + 5, y0 + 6, capy.hi) px(x0 + 1, y0 + 9, capy.deep) -- brow, nostril
  for _, p in ipairs({ { 8, 9 }, { 8, 10 }, { 7, 11 } }) do px(x0 + p[1], y0 + p[2], capy.shade) end -- the jaw / neck
  -- ink round the little bird on its back so it reads
  for _, p in ipairs({ { 13, 4 }, { 14, 4 }, { 15, 4 }, { 12, 5 }, { 16, 5 }, { 17, 6 }, { 16, 7 }, { 12, 7 } }) do px(x0 + p[1], y0 + p[2], L.timber.edge) end
  px(x0 + 14, y0 + 5, L.timber.edge)
end
do
  -- the raft's broken reflection under it and the bow wave
  for x = RX0, RX1 do for y = RY1 + 5, RY1 + 14 do
    if river:has(x, y) and (y % 2 == 0) and hash(x // 2, y, 41) < .55 - (y - RY1) * .03 then px(x, y, mix(L.bamboo.deep, Wt.base, .5)) end
  end end
  for k = 0, 2 do px(RX0 - 3 - k, RY0 + 6 + k * 3, GLINT) hline(RX0 - 6 - k * 3, RX0 - 3 - k * 2, RY0 + 8 + k * 3, Wt.hi) end
  for k = 0, 3 do hline(RX0 - 8 - k * 5, RX0 - 2 - k * 2, RY1 + 6 + k * 2, Wt.hi) hline(RX1 + 2 + k * 2, RX1 + 8 + k * 5, RY1 + 6 + k * 2, Wt.hi) end
  for x = RX0 - 2, RX1 + 2 do if (x // 3) % 2 == 0 then px(x, RY1 + 5, Wt.edge) px(x, RY1 + 6, Wt.deep) end end
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  local face = rect(RX0, RY1 + 1, RX1, RY1 + 4)
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  for _, x in ipairs({ RX0 + 5, RX1 - 6 }) do posts:add(rect(x, RY0 - 8, x + 1, RY0)) end
  rimOf(union(deck, face), L.timber)
  part(deck, L.bamboo)
  -- culms laid front to back, converging slightly into the distance: lit lip, node rings, wet shine
  deck:each(function(x, y)
    local t = (y - RY0) / (RY1 - RY0)
    local x0 = RX0 + 4 * (1 - t)
    local u = floor((x - x0) / (1 - .08 * (1 - t)))
    local k, ci = u % 5, u // 5
    local r = (hash(ci, 1, 150) < .4) and L.board or L.bamboo -- seasoned golden culms among green ones
    local h
    if k == 0 then h = r.deep elseif k == 1 then h = r.hi elseif k == 4 then h = r.shade else h = r.base end
    if (y + floor(hash(ci, 0, 151) * 9)) % 10 == 0 and k ~= 0 then h = r.shade end
    if hash(ci, y // 4, 152) < .1 and k == 2 then h = r.hi end
    px(x, y, h)
  end)
  F.shine(deck, .05, 153)
  -- two cross-bars lashed with rattan
  for _, yy in ipairs({ RY1 - 3 }) do
    for x = RX0 + 2, RX1 - 2 do if deck:has(x, yy) then px(x, yy, L.timber.base) if deck:has(x, yy + 1) then px(x, yy + 1, L.timber.deep) end end end
    for x = RX0 + 6, RX1 - 6, 8 do px(x, yy, L.needle.hi) px(x + 1, yy, L.needle.base) end
  end
  hline(RX0 + 4, RX1 - 4, RY0, L.bamboo.hi)
  -- the face: a row of cut culm ends, lashed
  part(face, L.timber, { nopop = true })
  for x = RX0 + 2, RX1 - 2, 4 do bambooEnd(x, RY1 + 2, 1) end
  face:each(function(x, y) if y >= RY1 + 3 and hash(x // 2, y, 154) < .4 then px(x, y, L.moss.shade) end end)
  -- far rail behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.needle.shade) end
  -- cargo: clay water jars, a basket of mangoes, a bunch of green bananas
  jar(RX0 + 10, RY0 + 6, 11) jar(RX0 + 18, RY0 + 5, 9)
  do
    local bx = RX1 - 34
    local bk = c:rrect(bx, RY0 - 1, bx + 13, RY0 + 6, 2)
    rimOf(bk, rattan) part(bk, rattan, { nopop = true })
    bk:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, rattan.shade) elseif (x - y) % 4 == 0 then px(x, y, rattan.hi) end end)
    for k = 0, 3 do local mx = bx + 2 + k * 3 fill(c:ellipse(mx, RY0 - 2, 1, 1), k % 2 == 0 and L.produce.base or L.gold.base) px(mx - 1, RY0 - 3, L.gold.hi) px(mx + 1, RY0 - 1, L.apple.shade) end
  end
  bananas(RX1 - 16, RY0 - 1)
  -- the rattan chest the capybara rides
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.timber.edge) part(tk, rattan)
  tk:each(function(x, y) if (x + y) % 2 == 0 and (x // 3 + y // 3) % 2 == 0 then px(x, y, rattan.shade) end end)
  hline(T0, T0 + 18, RY0 + 4, L.timber.base) vline(T0 + 6, RY0 + 1, RY0 + 9, rattan.deep) vline(T0 + 12, RY0 + 1, RY0 + 9, rattan.deep)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.gold.base) px(T0 + 8, RY0 + 4, L.gold.hi)
  -- the traveller with a banana-leaf bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.bamboo.shade)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.leaf.edge) part(bun, L.leaf, { nopop = true })
  bun:each(function(x, y) if (x - y) % 3 == 0 then px(x, y, L.leaf.shade) end end) px(gx - 11, FY - 27, L.needle.base) px(gx - 12, FY - 27, L.needle.base) px(gx - 11, FY - 28, L.needle.shade)
  F.gnome(gx, FY, { hat = L.lav, coat = L.roof, arm = "up", noShadow = true })
  -- QUIRK: the capybara in the red gnome hat, riding on the chest, a little yellow bird on its back
  capybara(T0 - 1, RY0 - 15)
  -- the ferryman hauling hand over hand on the guide rope from the back right corner
  F.gnome(RX1 - 14, FY, { hat = L.foliage, coat = L.accent, arm = "up", flip = false, noShadow = true, hatBand = L.gold.base })
  -- near rail and posts in front of everyone
  part(posts, L.bamboo, { nopop = true, noshade = true })
  posts:each(function(x, y) if y % 4 == 0 then px(x, y, L.bamboo.deep) end end)
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.needle.deep) end
end
-- the guide rope over the raft, the ferryman's hand round it, a pulley block on a tether to the back post
guideRope()
do
  local hx, hy = GH[1], GH[2]
  fill(rect(hx - 1, ropeY(hx) - 1, hx, ropeY(hx) + 1), L.skin.base) px(hx - 1, ropeY(hx) - 1, L.skin.hi)
  local px0 = 376
  local blk = c:rrect(px0 - 2, ropeY(px0) - 1, px0 + 2, ropeY(px0) + 4, 1)
  c:rim(blk, L.timber.edge) part(blk, L.timber, { nopop = true }) px(px0, ropeY(px0) + 1, L.iron.hi)
  fill(line({ { px0, ropeY(px0) + 5 }, { RX1 - 1, RY1 - 9 } }), L.needle.shade)
  -- the kingfisher perched on the far run of the rope, eyeing the water
  local kx = 326
  F.sprite({
    "....BBB...",
    "...BBBBB..",
    "kkkBeBBBb.",
    "...WWBBBb.",
    "....OOBBbb",
    "....OOOBbb",
    ".....OOBb.",
    "......o.bb",
  }, kx, ropeY(kx + 6) - 8, { B = kfB, b = kfD, e = L.timber.edge, k = "#2e2a30", W = L.awnB.hi, O = L.produce.base, o = L.apple.base })
  px(kx + 4, ropeY(kx + 6) - 7, "#9ae6f0")
end

---------------------------------------------------------------- near bank: gnome hauling the tow rope on the landing
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.board, arm = "up" })
  local x0, y0 = RX0 + 2, RY1 - 8
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.timber.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.needle.hi or L.needle.base) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 3 and p[1] % 5 == 0 then px(p[1], p[2] + 2, GLINT) end end -- drips where it skims the water
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.timber.edge) part(coil, L.needle, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.needle.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.timber.edge) fill(tail, L.needle.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.needle.shade) end end)
end

-- a palm and a banana clump at the left of the near bank (behind the booth)
F.depth(3)
F.palm(24, 196, 46, 13, { lean = 6 })
do -- a banana plant
  local x, yb, h = 104, 190, 40
  local stem = poly{ { x - 2, yb }, { x + 2, yb }, { x + 1, yb - h * .55 }, { x - 1, yb - h * .55 } }
  rimOf(stem, L.vine) part(stem, L.vine, { nopop = true })
  stem:each(function(xx, yy) if xx < x then px(xx, yy, L.vine.hi) end if hash(xx, yy // 4, 3) < .15 then px(xx, yy, L.litter.shade) end end)
  local ty = floor(yb - h * .55)
  F.bigLeaf(x, ty, floor(h * .5), -pi * .8, L.leaf, 31, nil, { torn = true, droop = .35 })
  F.bigLeaf(x, ty, floor(h * .55), -pi * .2, L.foliage, 32, nil, { torn = true, droop = .4 })
  F.bigLeaf(x, ty, floor(h * .45), -pi * .55, L.leaf, 33, nil, { torn = true, droop = .15 })
end

DY = 10
---------------------------------------------------------------- near bank left: gong frame, ferry sign, booth, bench, dugout
do -- the bronze ferry gong on a bamboo frame under a little palm-thatch roof
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.timber) part(fr, L.bamboo, { nopop = true, noshade = true }) hline(183, 210, 148, L.bamboo.hi)
  fr:each(function(x, y) if y > 150 and y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  F.moss(rect(186, 186, 187, 196):add(rect(206, 186, 207, 196)), .4, 113)
  local roofb = poly{ { 179, 149 }, { 196, 138 }, { 214, 149 } } rimOf(roofb, L.roof) part(roofb, L.roof, { nopop = true })
  F.palmThatch(roofb, L.roof, 138, 196, 71)
  for x = 180, 213 do if hash(x, 1, 72) < .6 then px(x, 150, L.roof.deep) end end
  vline(193, 151, 152, L.needle.deep) vline(199, 151, 152, L.needle.deep)
  local gong = c:ellipse(196, 160, 7, 7)
  c:rim(gong, L.timber.edge) part(gong, L.gold)
  c:ellipse(196, 160, 5, 5):edge():each(function(x, y) px(x, y, L.gold.shade) end)
  fill(c:ellipse(196, 160, 2, 2), L.gold.base) px(195, 159, L.gold.hi) px(197, 161, L.gold.deep)
  gong:each(function(x, y) if (x - 196) + (y - 160) < -8 then px(x, y, L.gold.hi) end end)
  -- the beater hanging on the post
  fill(line({ { 205, 162 }, { 203, 176 } }), L.timber.base) fill(c:ellipse(205, 161, 2, 2), L.awnA.shade)
end
do -- the ferry sign: a painted raft, a palm and a wavy brown river
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.timber) part(post, L.timber, { nopop = true }) part(bd, L.board, { nopop = true })
  F.bambooWall(bd:copy():shrink(1), L.board, 3, true, 155)
  c:edgeIn(bd, L.timber.base)
  for x = 159, 182 do px(x, 164 + floor(sin(x / 2) + .5), Wt.base) px(x, 165 + floor(sin(x / 2) + .5), Wt.shade) end
  fill(rect(162, 160, 180, 162), L.bamboo.base) hline(162, 180, 160, L.bamboo.hi)
  vline(166, 155, 159, L.timber.edge) vline(176, 155, 159, L.timber.edge) fill(rect(169, 155, 173, 159), L.awnA.base) -- passengers on the painted raft
  fill(line({ { 158, 154 }, { 182, 156 } }), L.needle.shade) -- the painted guide rope
  F.sprite({ "g.g.g", ".ggg.", "..t..", "..t..", "..t.." }, 157, 154, { g = L.foliage.shade, t = L.palmTrunk.shade }, { rim = false })
  F.moss(rect(170, 192, 171, 200), .4, 115)
  F.vine(184, 153, 6, 3)
end
F.depth(3)
do -- the bamboo ticket booth with a gnome in the hatch, a palm-thatch roof
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 30, 171 }, { 65, 144 }, { 100, 171 } }:add(rect(30, 168, 100, 171))
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof), L.timber)
  part(wall, L.bamboo) F.bambooWall(wall, L.bamboo, 3, false, 3)
  part(roof, L.roof, { sep = true }) F.palmThatch(roof, L.roof, 144, 65, 81)
  line({ { 31, 170 }, { 65, 145 } }):each(function(x, y) px(x, y, L.roof.hi) end)
  for x = 30, 100 do local len = 1 + floor(hash(x, 171, 82) * 3) for k = 1, len do px(x, 171 + k, k == len and L.roof.edge or L.roof.deep) end end
  -- hatch with awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.timber.base)
  fill(rect(51, 179, 56, 183), L.glow.shade) px(52, 180, L.glow.base) -- a lamp lit inside
  F.gnome(65, 198, { hat = L.awnA, coat = L.helic, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.timber) part(sill, L.timber, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base) -- a ticket
  local aw = poly{ { 46, 175 }, { 84, 175 }, { 88, 180 }, { 42, 180 } }
  rimOf(aw, L.accent) fill(aw, L.accent.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.base) end if y == 180 then px(x, y, ((x // 3) % 2 == 0) and L.accent.deep or L.accent.shade) end end)
  hline(46, 84, 175, L.accent.hi)
  -- a carved toucan plaque on the gable
  F.sprite({ ".kk...", "kWkOOo", ".kk...", ".k...." }, 62, 160, { k = "#2e2a30", W = L.gold.hi, O = L.produce.base, o = L.awnA.base })
  F.vines(rect(30, 171, 60, 172), .1, 83, 8)
end
do -- bamboo bench with two waiting travellers and their luggage
  F.gnome(112, 214, { hat = L.roof2, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.helic, coat = L.accent, flip = true, noShadow = true })
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 104, 218):add(rect(142, 210, 143, 218))
  F.shadow(102, 146, 219, 8, 3)
  rimOf(union(seat, legs), L.timber) part(legs, L.bamboo, { nopop = true, noshade = true }) part(seat, L.bamboo, { nopop = true }) hline(100, 146, 207, L.bamboo.hi)
  for x = 106, 140, 9 do vline(x, 207, 209, L.bamboo.deep) end
  -- luggage: a rattan trunk and a woven palm bag
  local tr = c:rrect(150, 204, 168, 218, 3):clip(rect(150, 204, 168, 218))
  F.shadow(150, 168, 219, 5, 2)
  rimOf(tr, L.timber) part(tr, rattan)
  tr:each(function(x, y) if (x + y) % 2 == 0 and (x // 2 + y // 2) % 2 == 0 then px(x, y, rattan.shade) end end)
  hline(150, 168, 209, L.timber.base) vline(155, 204, 218, rattan.deep) vline(163, 204, 218, rattan.deep) px(159, 211, L.glow.hi)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.timber) part(bag, L.roof2)
  bag:each(function(x, y) if ((x + y) // 2) % 2 == ((x - y) // 2) % 2 then px(x, y, L.roof2.shade) end end)
  hline(152, 166, 226, L.awnA.base)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.timber.base)
end
do -- a dugout canoe pulled up on the mud, paddles across it
  local y = 228
  local hull = poly{ { 16, y - 5 }, { 24, y }, { 76, y + 2 }, { 84, y - 4 }, { 74, y + 9 }, { 26, y + 8 } }
  local inside = c:ellipse(50, y - 1, 26, 2)
  F.shadow(24, 78, y + 10, 6, 3)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.timber) hline(24, 76, y + 4, L.timber.hi)
  for x = 28, 72, 6 do px(x, y + 5, L.helic.base) px(x + 1, y + 5, L.gold.base) px(x + 2, y + 5, L.accent.base) end -- painted band
  hull:each(function(x, y2) if y2 >= y + 6 and hash(x // 2, y2, 117) < .35 then px(x, y2, L.moss.shade) end end)
  fill(inside, L.timber.deep) c:edgeIn(inside, L.timber.base)
  for _, pd in ipairs({ { 30, y - 5, 66, y + 1 }, { 40, y - 3, 74, y - 1 } }) do
    fill(line({ { pd[1], pd[2] }, { pd[3], pd[4] } }), L.board.base)
    local bl = c:ellipse(pd[3] + 2, pd[4], 3, 1) c:rim(bl, L.timber.edge) part(bl, L.board, { nopop = true })
  end
end
DY = 0
-- near bank plants: papyrus beds, elephant ears and heliconia either side of the landing
bankClump(214, yN(214) + 3, 12, 22, 3, true)
bankClump(120, yN(120) + 3, 10, 18, 5, true)
bankClump(452, yN(452) + 3, 9, 20, 9, true)
bankClump(20, yN(20) + 3, 7, 16, 11, true)
F.bigLeaf(398, yN(398) - 4, 14, -pi * .7, L.foliage, 161, 6, { heart = true, stem = { 402, yN(402) + 3 } })
F.bigLeaf(406, yN(406) - 2, 12, -pi * .3, L.leaf, 162, 5, { heart = true, stem = { 403, yN(403) + 3 } })
F.heliconia(384, yN(384) + 3, 18, 163)
F.bigLeaf(214, yN(214) - 2, 12, -pi * .3, L.leaf, 164, 5, { heart = true, stem = { 210, yN(210) + 3 } })

---------------------------------------------------------------- the river right: water hyacinth, turtles on a log, a moored raft
F.depth(3)
DY = 8
local function hyacinth(x, y)
  local pad = c:ellipse(x, y, 5, 2) c:rim(pad, L.leaf.edge) fill(pad, L.leaf.base)
  px(x - 3, y - 1, L.leaf.hi) px(x - 2, y - 1, L.leaf.hi) px(x + 2, y, L.leaf.deep) px(x + 3, y, L.leaf.shade)
  px(x, y - 2, L.orchid.base) px(x - 1, y - 2, L.orchid.hi) px(x, y - 3, L.orchid.hi) px(x + 1, y - 2, L.orchid.shade) px(x, y - 1, L.gold.hi)
  hline(x - 5, x + 5, y + 3, Wt.hi)
end
hyacinth(360, 168) hyacinth(376, 174) hyacinth(344, 176) hyacinth(412, 160)
DY = 0
do -- a drifting log with river turtles sunning on it
  local lg = c:rrect(140, 140, 186, 144, 2)
  rimOf(lg, L.timber) part(lg, L.timber, { nopop = true })
  hline(141, 185, 140, L.timber.hi) F.moss(lg, .2, 171)
  F.logEnd(140, 142, 2)
  fill(line({ { 176, 140 }, { 182, 134 } }), L.timber.shade) px(182, 133, L.leaf.base) px(183, 133, L.leaf.hi)
  for _, t in ipairs({ { 148, 1 }, { 160, 0 }, { 170, 1 } }) do
    F.sprite({ "..sSSs..", ".sShSSs.", "hsSSsSSs" }, t[1], 136 - t[2], { s = L.fern.deep, S = L.fern.shade, h = L.fern.base })
    px(t[1], 138 - t[2], L.gold.base) px(t[1] - 1, 138 - t[2], L.fern.shade)
  end
  for k = 0, 2 do hline(136 - k * 3, 190 + k * 3, 146 + k * 2, k == 1 and Wt.shade or Wt.hi) end
end
DY = 8
do -- a little bamboo raft moored to a stake, a fish trap and a fish basket on it
  local y = 178
  local hull = poly{ { 420, y - 2 }, { 470, y - 2 }, { 468, y + 4 }, { 422, y + 4 } }
  rimOf(hull, L.timber) part(hull, L.bamboo) F.bambooWall(hull, L.bamboo, 2, true, 172)
  for x = 424, 468, 4 do bambooEnd(x, y + 3, 1) end
  for k = 0, 2 do hline(424 + k * 2, 466 - k * 2, y + 6 + k * 2, Wt.shade) end
  fishTrap(430, y - 4, 22)
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.timber) part(st, L.timber, { nopop = true, noshade = true })
  F.moss(st, .3, 119)
  fill(line({ { 412, y - 8 }, { 422, y - 1 } }), L.needle.shade)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a gnome with a mango
F.depth(3)
do
  F.crate(300, 222, 18, 12, L.produce) F.crate(318, 222, 16, 12) F.crate(306, 209, 16, 10, L.apple)
  sack(342, 224, 7) sack(354, 226, 6)
  jar(288, 224, 13)
  bananas(330, 206)
  local _, hx, hy = F.gnome(372, 236, { hat = L.lav, coat = L.leaf, arm = "out", flip = true })
  local ap = c:ellipse(hx - 1, hy - 2, 2, 2) c:rim(ap, L.timber.edge) part(ap, L.produce, { nopop = true }) px(hx - 2, hy - 3, L.gold.hi) px(hx - 1, hy - 5, L.leaf.base)
  -- a paper lantern on a bamboo post at the landing's right
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.timber) part(lp, L.bamboo, { nopop = true, noshade = true })
  lp:each(function(x, y) if y % 6 == 0 then px(x, y, L.bamboo.deep) end end)
  local lam = c:ellipse(281, 155, 4, 5) c:rim(lam, L.timber.edge) part(lam, L.awnA, { nopop = true })
  fill(rect(279, 152, 281, 157), L.glow.base) px(279, 152, L.glow.hi) hline(277, 285, 155, L.awnA.deep)
  hline(278, 284, 150, L.timber.deep) hline(278, 284, 160, L.timber.deep) px(281, 161, L.gold.base) px(281, 162, L.awnA.shade)
end
-- foreground: a wheelbarrow of pineapples waiting for the ferry, mossy rocks, ferns, fungi
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 8, 3)
  rimOf(union(tray, legs, wh), L.timber)
  part(legs, L.bamboo, { nopop = true, noshade = true })
  part(tray, L.board) F.bambooWall(tray, L.board, 3, true, 2)
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep) vline(92, y - 4, y + 4, L.timber.deep)
  for _, p in ipairs({ { 104, y - 16 }, { 112, y - 17 }, { 120, y - 16 }, { 127, y - 15 }, { 108, y - 23 }, { 116, y - 24 } }) do pineapple(p[1], p[2]) end
end
F.moss(F.rock(160, 254, 9, 6), .3, 121) F.shine(F.rock(172, 257, 5, 4), .2, 123)
F.moss(F.rock(70, 254, 6, 4), .3, 122)
for _, f in ipairs({ { 30, 216, 6 }, { 148, 246, 6 }, { 186, 242, 7 }, { 270, 214, 5 }, { 362, 214, 5 }, { 60, 262, 7 }, { 196, 262, 8 }, { 290, 250, 7 }, { 330, 258, 6 }, { 300, 236, 5 }, { 96, 224, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(176, 250, L.produce, true) F.mushroom(181, 252, L.produce) F.mushroom(82, 258, L.apple, true) F.mushroom(268, 222, L.produce)
F.heliconia(208, 260, 20, 181)
F.orchid(150, 262, L.orchid, 2) F.puddle(46, 248, 8, 182) F.puddle(276, 262, 6, 183)
coconut(176, 236) coconut(181, 238, true)
-- blue morpho butterflies over the bank
for _, b in ipairs({ { 222, 226 }, { 334, 196 }, { 140, 194 } }) do
  F.sprite({ "BB.BB", "bBkBb", ".b.b." }, b[1], b[2], { B = "#5aa8f0", b = "#2c62b4", k = L.timber.edge }, { rim = false })
end

---------------------------------------------------------------- bank sedge, a fisher gnome, a coati after the mango
DY = 0
F.depth(3)
for x = 0, 479 do
  local yn = yN(x)
  if hash(x, 1, 91) < .45 and not F.roadM:has(x, yn + 1) and not (x > 190 and x < 290) then
    local h = 2 + floor(hash(x, 2, 91) * 4)
    vline(x, yn + 4 - h, yn + 4, L.vine.deep) px(x, yn + 4 - h, L.vine.base) if h > 3 then px(x, yn + 3 - h, L.vine.hi) end
  end
  if hash(x, 3, 91) < .05 then px(x, yn + 5, L.stone.base) px(x + 1, yn + 5, L.stone.shade) px(x, yn + 4, L.wet) end
end
do -- a fisher gnome on an upturned clay pot at the right bank, a bamboo rod out over the water, a catch in the basket
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  F.shadowM(c:ellipse(418, 222, 10, 1))
  rimOf(bk, clay) part(bk, clay) hline(410, 422, 213, clay.deep) hline(411, 421, 218, clay.deep)
  for k = 412, 420, 3 do px(k, 215, L.awnB.base) end
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.wall2, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  local rod = line({ { hx, hy + 2 }, { 378, 172 } })
  rod:each(function(x, y) px(x, y, (x + y) % 5 == 0 and L.bamboo.deep or L.bamboo.shade) end) px(378, 172, L.bamboo.deep)
  for y = 173, 188 do px(378 - floor((y - 173) * .2), y, L.awnB.shade) end
  px(375, 189, L.awnA.base) px(375, 188, GLINT) hline(370, 380, 190, Wt.hi)
  local cr = c:rrect(428, 212, 442, 222, 2) rimOf(cr, rattan) part(cr, rattan)
  cr:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, rattan.shade) end end)
  F.sprite({ "s..s", "sSSs", ".SS.", ".ss." }, 433, 206, { s = L.iron.hi, S = L.iron.base })
  F.mushroom(446, 220, L.produce, true) F.mushroom(450, 222, L.produce)
end
-- a coati stretching up at the gnome's mango, ringed tail high
F.sprite({
  "tT...............",
  "TtT..............",
  ".tTt........aa...",
  "..TtT......aCCk..",
  "...tTt....CCeCCCs",
  "....TtC.CCCCCmm..",
  "....CCCCCCCCCm...",
  "...CCCCCCCCCc....",
  "...cCCCCCCCc.....",
  "....c.c..cc......",
  "....d.d..d.d.....",
}, 341, 230, { a = "#8a4228", k = "#f0dcb4", C = "#d0703c", c = "#8a4228", e = L.timber.edge, s = "#3e2420", m = "#f0dcb4",
  t = "#3e2420", T = "#f0b070", d = "#3e2420" })

DY = 0
F.depth(0)
-- parrots crossing the sky
F.birds({ { 150, 58, 2, "#2e7a46" }, { 162, 52, 1, "#2e7a46" }, { 360, 46, 2, "#b03a36" }, { 372, 52, 2, "#2e7a46" } })
F.finish()
