-- ferry.lua : "Ferry crossing" stop look, COAST (coast_driftwood), 480x270 gate view.
-- Same composition as the Maplewold ferry (art-2701-batch4/stops/opus3/ferry.lua), re-cast as an estuary crossing:
-- a tidal channel runs across the whole view between mudflats, and the road stops at it on a granite slipway.
-- The ferry is the centre hero, mid-channel and coming in: a flat-bottomed pontoon ferry with a sea-blue hull, a
-- raised bow ramp and a lifebuoy; an oilskinned ferryman quants it, a traveller with a bundle and cargo ride it,
-- and a gnome on the slipway hauls it in by the tow rope. Far bank: a whitewashed cottage under slate, a tarred
-- harbour hut under red pantiles (bell post, lantern, nets drying on poles), wind-bent hawthorns, a stone slipway
-- with a gnome waving, two luggers lying at their moorings and a little egret in the shallows. Channel: a red can
-- buoy and a green cone, shelducks, a dinghy with a gnome jigging for mackerel, a mudbank with oystercatchers.
-- Near bank: a glistening mudflat with bird tracks, saltmarsh (samphire, sea lavender) and phragmites reed beds,
-- the ferry bell under a slate roof, a painted ferry sign, a tarred ticket booth, a bench of waiting travellers, a
-- beached rowboat with its anchor, a barrow of cockle baskets, cargo, a crabbing gnome and a herring gull going for
-- a gnome's fish. Quirk: a harbour seal in a red gnome hat, riding the ferry on a sea chest.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-coast-stops/"
local F = dofile(DIR .. "_frame.lua")
  .build{ name = "ferry", out = DIR, roadTop = 178, farTrees = { 30, 120, 330, 446 },
    clouds = { { 150, 44, 40 }, { 290, 34, 50 }, { 420, 70, 28 }, { 196, 78, 24 } },
    boats = { { 186, 97, 7 }, { 334, 99, 8 } } }
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi, abs = math.floor, math.sin, math.cos, math.pi, math.abs
local mix = F.mix
-- estuary water: a little greyer and greener than the tide pools, silt in it
local Wt = F.rp("#c0dcd6 #86b6bc #5c8ea2 #3f6a82 #284a5e")
local GLINT = "#f6f4e4"
local mud = F.rp("#b8ab94 #92846e #706454 #544a40 #383029")
local reed = F.rp("#dcd49c #b4ac6c #8a8652 #60623e #3a3e2a")
local plume = F.rp("#dcbeac #b48e80 #8c6862 #664a4a #3e2c30")
local seal = F.rp("#c2bab0 #8e8780 #6a6460 #4a4644 #2e2a2c")
-- DY: a temporary vertical offset for whole near-bank groups (set, draw, reset)
local DY = 0
do local base = c.put c.put = function(self, x, y, h, o) base(self, x, y + DY, h, o) end end

local function yF(x) return 124 + floor(2 * sin(x / 31) + 1.5 * sin(x / 11)) end
local function yN(x) local t = (x - 240) / 240 return 177 + floor(14 * t * t + 3 * sin(x / 23) + 2 * sin(x / 9 + 1)) end
local function samphire(x, y, n, seed)
  for k = 0, n - 1 do
    local xx = x + k * 2 + floor(hash(k, 1, seed) * 2)
    local h = 2 + floor(hash(k, 2, seed) * 3)
    vline(xx, y - h, y, L.leaf.base) px(xx, y - h, L.leaf.hi) px(xx, y, L.leaf.deep)
    if h > 2 then px(xx + 1, y - h + 2, L.leaf.shade) end
  end
end
local function seaLavender(x, y, w, seed)
  for k = 0, w do
    local h = 2 + floor(hash(k, 3, seed) * 3)
    px(x + k, y, L.foliage.shade) px(x + k, y - 1, L.foliage.base)
    if k % 2 == 0 then px(x + k, y - h, hash(k, 4, seed) < .5 and L.lav.hi or L.lav.base) px(x + k, y - h + 1, L.lav.shade) end
  end
end

---------------------------------------------------------------- the tidal channel
local river = HP.mask()
for x = 0, 479 do for y = yF(x), yN(x) do river:set(x, y) end end
do
  river:each(function(x, y)
    local f = (y - yF(x)) / math.max(1, yN(x) - yF(x))
    local h
    if f < .18 then h = Wt.hi
    elseif f < .4 then h = hash(x // 8, y, 14) < .5 and Wt.hi or mix(Wt.hi, Wt.base, .5)
    elseif f < .78 then h = Wt.base
    else h = hash(x // 6, y // 2, 15) < .6 and mix(Wt.base, Wt.shade, .5) or Wt.base end
    -- the sky's blue mirrored in the far half, silt swirls in the near half
    if f < .4 and hash(x // 12, y // 2, 19) < .18 then h = mix(L.sky[3], Wt.hi, .4) end
    if f > .55 and hash(x // 7, y // 2, 20) < .1 then h = mix(Wt.base, mud.base, .3) end
    px(x, y, h)
  end)
  -- the ebb running seaward: long thin lit lines, longer nearer
  for y = 126, 194 do
    local d = y - 122
    if y % 3 == 0 then
      local x = floor(hash(y, 1, 13) * 30)
      while x < 480 do
        local len = 4 + d // 3 + floor(hash(x, y, 18) * 8)
        if hash(x // 9, y, 16) < .5 then
          for xx = x, x + len do if river:has(xx, y) and river:has(xx, y + 1) then px(xx, y, Wt.hi) if d > 22 then px(xx, y + 1, Wt.shade) end end end
        end
        x = x + len + 10 + floor(hash(x, y, 17) * 22)
      end
    end
  end
  -- sun glitter (the sun is upper left)
  for i = 0, 90 do
    local x, y = floor(hash(i, 1, 18) * 300), 126 + floor(hash(i, 2, 18) * 44)
    if river:has(x, y) and river:has(x + 1, y) then px(x, y, GLINT) px(x + 1, y, Wt.hi) end
  end
  -- far bank: a strip of wet mud with a shine line under the saltmarsh; near bank: a broad glistening mudflat
  for x = 0, 479 do
    local yf = yF(x)
    px(x, yf - 1, hash(x, 3, 7) < .4 and mud.hi or L.wetSand.hi)
    px(x, yf, mud.shade) px(x, yf + 1, hash(x, 4, 7) < .5 and mud.base or mud.shade) px(x, yf + 2, Wt.deep) px(x, yf + 3, Wt.shade)
    if hash(x // 3, 5, 7) < .3 then px(x, yf + 1, Wt.hi) end
    local yn = yN(x)
    px(x, yn, Wt.hi)
    if not F.roadM:has(x, yn + 2) then
      local depth = 7 + floor(3 * sin(x / 17) + 2 * hash(x // 5, 1, 8))
      for k = 1, depth do
        local y = yn + k
        local col
        if k == 1 then col = mud.deep
        elseif k == 2 then col = mud.shade
        else
          local v = hash(x // 2, y, 9)
          col = (k > depth - 2) and (v < .5 and L.wetSand.base or L.wetSand.shade) or (v < .55 and mud.base or (v < .8 and mud.shade or mud.hi))
          -- runnels of water left by the tide, mirroring the sky
          local r = math.abs(sin(x / 13 + y * .9) + sin(x / 7.3))
          if k > 2 and k < depth - 1 and r < .3 then col = (hash(x, y, 10) < .5) and L.sky[3] or Wt.hi end
        end
        px(x, y, col)
      end
      if k == 3 and hash(x // 3, 14, 8) < .35 then px(x, yn + 3, Wt.hi) end
      if hash(x, 11, 8) < .05 then px(x, yn + 4, L.shingle.hi) px(x + 1, yn + 4, L.shingle.shade) end
      if hash(x, 12, 8) < .04 then px(x, yn + 5, mud.deep) px(x, yn + 4, mud.hi) end -- worm casts
    end
  end
end

---------------------------------------------------------------- far bank: road on, slipway, cottage, harbour hut, hawthorns
F.depth(1)
F.drawRoad(113, 122)
F.tree(112, 122, 30, 0)
F.tree(20, 122, 36, 2)
F.tree(96, 121, 26, 1)
do -- a whitewashed fisherman's cottage under slate, smoke blown inland
  local top, cx, wallM, roofM = F.building{ x0 = 36, x1 = 80, yb = 122, wh = 13, rh = 11, wall = L.plaster, roof = L.roof, noFrame = true, noAttic = true, chimney = true, shingle = true }
  F.lichen(roofM, .06, 101)
  F.window(44, 113, 48, 116, L.wall2) F.window(68, 113, 72, 116, L.wall2)
  F.door(56, 112, 61, 121, L.wall2)
  do -- dark peat smoke so it shows against the chalk
    local cols = { "#5c6a78", "#74838f", "#8c9aa6", "#a6b4be" }
    for i = 0, 4 do
      local t = i / 4
      local r = 2 + floor(t * 2)
      local sx, sy = 70 + floor(i * i * .4 + 2 * sin(i * 1.7)), 99 - i * 5
      local m = c:ellipse(sx, sy, r, r - 1)
      fill(m, cols[math.min(4, 1 + floor(t * 3.5))])
      m:each(function(xx, yy) if not m:has(xx - 1, yy - 1) then px(xx, yy, cols[math.min(4, 2 + floor(t * 3.5))]) end if not m:has(xx + 1, yy + 1) then px(xx, yy, cols[math.max(1, floor(t * 3.5))]) end end)
    end
  end
end
-- saltmarsh along the far bank: sea lavender cushions, samphire, phragmites with feathery plumes
local function reedClump(x, yb, n, hmax, seed, near)
  local blades = {}
  for i = 1, n do
    local bx = x + floor((hash(i, 1, seed) - .5) * n * 1.6)
    local h = floor(hmax * (.55 + .45 * hash(i, 2, seed)))
    local lean = (hash(i, 3, seed) - .3) * (near and 8 or 4) -- leaning inland, away from the sea wind
    blades[#blades + 1] = { bx, h, lean, hash(i, 4, seed) }
  end
  local m = HP.mask()
  local heads = {}
  for _, b in ipairs(blades) do
    local bx, h, lean, v = b[1], b[2], b[3], b[4]
    local w = near and 2 or 1
    local pts = { { bx, yb }, { bx + lean * .3, yb - h * .5 }, { bx + lean, yb - h } }
    m:add(line(pts, w))
    if v < .5 then heads[#heads + 1] = { floor(bx + lean * .9), yb - h - 1 } end
  end
  if near then c:rim(m, reed.edge) end
  m:each(function(xx, yy)
    local t = (yb - yy) / hmax
    local hsh = hash(xx, yy, seed)
    local col = t > .6 and reed.hi or (t > .25 and reed.base or reed.shade)
    if hsh < .22 then col = reed.shade elseif hsh > .88 then col = L.leaf.base end
    if yy >= yb - 1 then col = reed.deep end
    px(xx, yy, col)
  end)
  for _, hd in ipairs(heads) do
    local hx, hy = hd[1], hd[2]
    if near then
      -- a feathery plume nodding downwind: a loose spray, lit top-left, dark under
      local pm = HP.mask()
      for k = 0, 6 do
        local yy = hy - 6 + k
        local w0 = (k < 2) and 0 or 1
        for dx = -w0, 1 do if hash(hx + dx, yy, seed + 5) < .8 then pm:set(hx + dx + floor(k / 3), yy) end end
      end
      c:rim(pm, plume.edge)
      pm:each(function(xx, yy) px(xx, yy, (not pm:has(xx - 1, yy)) and plume.hi or ((yy > hy - 2) and plume.shade or plume.base)) end)
      px(hx + 2, hy, plume.deep)
    else
      px(hx, hy, plume.base) px(hx + 1, hy - 1, plume.hi) px(hx + 1, hy, plume.shade)
    end
  end
end
for _, r in ipairs({ { 14, 8 }, { 40, 10 }, { 110, 9 }, { 150, 12 }, { 192, 8 }, { 300, 8 }, { 352, 10 }, { 440, 12 }, { 466, 8 } }) do
  reedClump(r[1], yF(r[1]) - 1, r[2], 8, r[1], false)
end
for x = 4, 470, 23 do
  local xx = x + floor(hash(x, 1, 141) * 8)
  if not (xx > 226 and xx < 256) then
    if hash(x, 2, 141) < .5 then seaLavender(xx, yF(xx) - 1, 4, x) else samphire(xx, yF(xx) - 1, 3, x) end
  end
end
-- far slipway: granite setts running down into the water, a timber edge, weed at the foot
do
  local d = poly{ { 233, 119 }, { 249, 119 }, { 252, 133 }, { 230, 133 } }
  rimOf(d, L.stone) part(d, L.stone) F.courses(d, 119, 3, 6, L.stone)
  d:each(function(x, y) if y >= 129 then px(x, y, hash(x, y, 4) < .5 and L.kelp.base or mix(L.stone.shade, Wt.base, .4)) end end)
  F.barnacles(d, .1, 102, 127)
  for _, x in ipairs({ 231, 250 }) do vline(x, 131, 136, L.timber.deep) end
  hline(229, 253, 134, Wt.hi)
end
F.depth(2)
do -- the harbour hut: tarred boards, red pantiles, sea-blue door; bell post, lantern pole, nets on poles
  local top, cx, wallM, roofM = F.building{ x0 = 164, x1 = 214, yb = 125, wh = 20, rh = 16, wall = L.tar, roof = L.roof2, shingle = true, noAttic = true, chimney = true, noFrame = true }
  F.planks(wallM, L.tar, 4, true, 9)
  F.pantile(roofM, L.roof2, top - 16, 103)
  F.lichen(roofM, .04, 104)
  wallM:each(function(x, y) if y > 121 and hash(x, y // 2, 105) < .4 then px(x, y, L.sand.shade) end end)
  F.door(184, 112, 192, 124, L.wall2)
  F.window(171, 110, 176, 115, L.wall2) F.window(201, 110, 206, 115, L.wall2)
  -- a lifebuoy on the wall
  local lb = c:ellipse(197, 118, 3, 3) rimOf(lb, L.awnA)
  lb:each(function(x, y) local a = math.atan(y - 118, x - 197) px(x, y, (floor((a + pi) / (pi / 2)) % 2 == 0) and L.awnA.base or L.awnB.hi) end)
  px(197, 118, L.tar.base)
  F.smoke(205, 78, 6, .9, 2)
  -- the far ferry bell post at the slipway
  local bp = rect(222, 100, 223, 125):add(rect(218, 100, 230, 101)) rimOf(bp, L.tar) part(bp, L.timber, { nopop = true, noshade = true })
  local fb = poly{ { 226, 102 }, { 229, 102 }, { 230, 107 }, { 225, 107 } } c:rim(fb, L.tar.edge) part(fb, L.gold, { nopop = true })
  local lp = rect(256, 98, 257, 125) rimOf(lp, L.tar) part(lp, L.timber, { nopop = true, noshade = true })
  fill(rect(256, 98, 262, 98), L.timber.base)
  local lam = rect(259, 100, 263, 105) rimOf(lam, L.tar) fill(lam, L.glow.base) px(260, 101, L.glow.hi) vline(263, 101, 105, L.glow.shade)
  -- nets drying between a pole and the hut
  local wp = rect(132, 104, 133, 124) rimOf(wp, L.tar) part(wp, L.timber, { nopop = true, noshade = true })
  F.netSwag(134, 162, 106, 9, { floatStep = 6 })
end
-- a small gnome waving from the far slipway
F.gnome(242, 126, { small = true, hat = L.awnA, coat = L.wall2, arm = "up" })
-- two luggers lying at their moorings on the right, mooring buoys, their reflections
do
  local function moored(x, yb, len, o)
    F.boat(x, yb, len, o)
    for k = 0, 2 do hline(x - len // 2 + k * 3, x + len // 2 - k * 3, yb + 2 + k * 2, k == 1 and Wt.shade or Wt.hi) end
    for y = yb + 1, yb + 9 do if (y % 2 == 0) then for xx = x - len // 2 + 2, x + len // 2 - 2 do if hash(xx // 2, y, 151) < .5 then px(xx, y, mix(L.tar.base, Wt.base, .5)) end end end end
  end
  moored(422, 139, 26, {})
  moored(458, 134, 20, { flip = true, sail = L.cork, band = L.awnA })
  for _, b in ipairs({ { 400, 142 }, { 472, 146 } }) do
    local m = c:ellipse(b[1], b[2], 2, 2) rimOf(m, L.produce) fill(m, L.produce.base) px(b[1] - 1, b[2] - 1, L.produce.hi) px(b[1] + 1, b[2] + 1, L.produce.shade)
    hline(b[1] - 3, b[1] + 3, b[2] + 3, Wt.hi)
  end
  line({ { 409, 137 }, { 400, 141 } }):each(function(x, y) px(x, y, L.cork.deep) end)
end
-- reflections of the far bank in the water (broken dashes)
for x = 0, 479 do
  local y0 = yF(x) + 4
  local v = c:get(x, yF(x) - 6)
  if v and hash(x, 1, 31) < .55 and x < 395 then
    for y = y0, y0 + 5, 2 do if river:has(x, y) and hash(x, y, 32) < .6 then px(x, y, mix(v, Wt.base, .55)) end end
  end
end
-- a little egret in the shallows under the moored boats
F.depth(3)
do
  local hx, hy = 380, 118
  F.sprite({
    ".....kk.......",
    "...gWWWk......",
    "yyyyWeWk......",
    "...gWWWWg.....",
    ".....WWWg.....",
    ".....WWg......",
    "......WWg.....",
    "......WWg.....",
    ".....WWg......",
    "....WWWg......",
    "....WWWWWg....",
    "...gWWWWWWgg..",
    "..gWWWWWWWggd.",
    "..gWWWWWWgggdd",
    "...gWWWgggdd.d",
    "....ggggddd...",
    ".....gddd.....",
    "......l.l.....",
    "......l.l.....",
    "......l.l.....",
    "......f..f....",
  }, hx, hy, { k = L.gull.hi, W = L.gull.hi, g = L.gull.base, d = L.gull.shade, e = L.tar.edge, y = L.tar.base, l = L.tar.base, f = L.gold.base },
  { rimCol = L.gull.edge })
  for k = 0, 2 do hline(hx + 3 - k * 2, hx + 11 + k * 2, hy + 21 + k, k == 1 and Wt.shade or Wt.hi) end
end
F.depth(2)

---------------------------------------------------------------- channel left: a dinghy, a gnome jigging for mackerel; a can buoy
F.depth(2)
do
  local x0, x1, y = 62, 100, 142
  local hull = poly{ { x0 - 3, y - 2 }, { x1 + 3, y - 2 }, { x1 - 3, y + 4 }, { x0 + 3, y + 4 } }
  F.gnome(78, y - 2, { small = true, hat = L.awnA, coat = L.gold, arm = "out", noShadow = true })
  rimOf(hull, L.tar) part(hull, L.wall2, { nopop = true }) hline(x0, x1, y, L.awnB.hi) hline(x0 + 2, x1 - 2, y + 3, L.tar.base)
  for k = 0, 2 do hline(x0 + k * 3, x1 - k * 3, y + 6 + k * 2, Wt.shade) end
  fill(line({ { 88, y - 8 }, { 112, y - 22 } }), L.timber.deep)
  vline(112, y - 21, y + 6, L.awnB.shade) px(112, y + 6, L.iron.hi) px(113, y + 6, L.iron.base) hline(108, 116, y + 8, Wt.hi)
  -- a mackerel on the thwart
  hline(70, 74, y - 3, L.accent.hi) px(75, y - 3, L.iron.hi) px(69, y - 4, L.accent.base) px(69, y - 2, L.accent.base)
end
local function canBuoy(x, y, r, cone)
  local m = cone and poly{ { x - 3, y }, { x, y - 7 }, { x + 3, y } } or rect(x - 3, y - 7, x + 3, y)
  m:add(rect(x - 4, y, x + 4, y + 1))
  rimOf(m, r) part(m, r)
  hline(x - 3, x + 3, y - 3, L.awnB.hi)
  vline(x, y - 11, y - 8, L.tar.base) px(x, y - 12, r.base)
  for k = 0, 2 do hline(x - 6 - k * 2, x + 6 + k * 2, y + 2 + k * 2, k == 1 and Wt.shade or Wt.hi) end
  for yy = y + 3, y + 8, 2 do hline(x - 2, x + 2, yy, mix(r.shade, Wt.base, .5)) end
end
canBuoy(132, 152, L.awnA, false)
canBuoy(212, 141, L.foliage2, true)

---------------------------------------------------------------- the near slipway and its piles
F.depth(3)
local LY0, LY1 = 166, 180
do
  local deck = poly{ { F.xl(LY0) - 6, LY0 }, { F.xr(LY0) + 6, LY0 }, { F.xr(LY1) + 6, LY1 }, { F.xl(LY1) - 6, LY1 } }
  local face = rect(floor(F.xl(LY0)) - 6, LY0 - 3, floor(F.xr(LY0)) + 6, LY0 - 1)
  local piles = HP.mask()
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do piles:add(rect(x, LY0 - 6, x + 2, LY0 + 6)) end
  rimOf(union(deck, face, piles), L.stone)
  part(piles, L.timber, { nopop = true, noshade = true })
  F.barnacles(piles, .2, 104, LY0 - 2)
  -- granite setts, sand in the joints, green weed and barnacles low down where the tide covers them
  part(deck, L.stone) F.courses(deck, LY0, 3, 7, L.stone)
  deck:each(function(x, y)
    if y <= LY0 + 2 and hash(x // 2, y, 105) < .5 then px(x, y, hash(x, y, 106) < .5 and L.foliage2.base or L.kelp.base) end
    if (x + y) % 7 == 0 and hash(x, y, 107) < .3 then px(x, y, L.sand.shade) end
  end)
  F.barnacles(deck, .06, 108, LY0)
  part(face, L.stone, { nopop = true, noshade = true })
  face:each(function(x, y) if hash(x, y, 109) < .55 then px(x, y, hash(x, y, 110) < .5 and L.kelp.base or L.foliage2.shade) end end)
  for _, x in ipairs({ floor(F.xl(LY0)) - 6, floor(F.xr(LY0)) + 4 }) do hline(x - 2, x + 4, LY0 + 7, Wt.hi) fill(rect(x, LY0 - 7, x + 2, LY0 - 7), L.timber.hi) end
end

---------------------------------------------------------------- the ferry (centre hero)
local RX0, RX1, RY0, RY1 = 270, 366, 137, 152
local FY = RY1 - 6 -- where figures stand: the front of the deck stays visible
local function sealSprite(x0, y0)
  F.sprite({
    "......R..............",
    ".....RRr.............",
    "....HRRr.............",
    "...HRRRRr............",
    "...RRRRRRr...........",
    "..bbbbbbbbb..........",
    "...hhhhGGGg..........",
    "..hheGGGeGGg.........",
    "..hGGGGGGGGg.........",
    ".wGGGkkkGGGgg........",
    ".wwvGGkGGvGhhgg......",
    "..wwwwwwGGhhhhGggg...",
    "...wwwwGGsGGGGsGGgg.f",
    "....wwGGFGGGsGGGGggff",
    ".....wwwFFGGGGGGggdf.",
    "......ddddddddddddd..",
  }, x0, y0, { R = L.awnA.base, r = L.awnA.shade, H = L.awnA.hi, b = L.awnB.hi, G = seal.base, g = seal.shade, s = seal.shade,
    w = mix(seal.hi, L.awnB.base, .4), h = seal.hi, F = seal.deep, d = seal.deep, e = L.tar.edge, k = L.tar.deep, v = L.awnB.base, f = seal.shade }, { rimCol = seal.edge })
end
do
  -- the ferry's broken reflection under it and the bow wave
  for x = RX0 - 8, RX1 do for y = RY1 + 6, RY1 + 15 do
    if river:has(x, y) and (y % 2 == 0) and hash(x // 2, y, 41) < .55 - (y - RY1) * .03 then px(x, y, mix(L.wall2.shade, Wt.base, .45)) end
  end end
  for k = 0, 2 do px(RX0 - 11 - k, RY0 + 6 + k * 3, GLINT) hline(RX0 - 14 - k * 3, RX0 - 11 - k * 2, RY0 + 8 + k * 3, Wt.hi) end
  for k = 0, 3 do hline(RX0 - 16 - k * 5, RX0 - 10 - k * 2, RY1 + 7 + k * 2, Wt.hi) hline(RX1 + 2 + k * 2, RX1 + 8 + k * 5, RY1 + 7 + k * 2, Wt.hi) end
  for x = RX0 - 2, RX1 + 2 do if (x // 3) % 2 == 0 then px(x, RY1 + 6, Wt.deep) px(x, RY1 + 7, Wt.shade) end end
  local deck = poly{ { RX0 + 4, RY0 }, { RX1 - 4, RY0 }, { RX1, RY1 }, { RX0, RY1 } }
  local face = rect(RX0, RY1 + 1, RX1, RY1 + 5)
  -- the bow ramp, raised on chains at the landing end
  local ramp = poly{ { RX0, RY0 + 3 }, { RX0, RY1 + 4 }, { RX0 - 8, RY1 - 4 }, { RX0 - 8, RY0 - 7 } }
  -- rail: posts at the corners and a rope between
  local posts = HP.mask()
  for _, x in ipairs({ RX0 + 1, RX1 - 2 }) do posts:add(rect(x, RY1 - 9, x + 1, RY1)) end
  for _, x in ipairs({ RX0 + 5, RX1 - 6 }) do posts:add(rect(x, RY0 - 8, x + 1, RY0)) end
  rimOf(union(deck, face, ramp), L.tar)
  part(deck, L.board) F.planks(deck, L.board, 5, true, 17)
  -- salt-bleached planks: grey streaks, sand in the seams, a wet sheen at the edges
  deck:each(function(x, y)
    local v = hash(x // 5, y // 3, 108)
    if v < .22 then px(x, y, ((x % 5) == 0) and L.timber.shade or L.timber.hi) end
    if x % 5 == 0 and hash(x, y, 109) < .3 then px(x, y, L.sand.shade) end
  end)
  hline(RX0 + 4, RX1 - 4, RY0, L.board.hi)
  -- the hull side: sea-blue paint, a white sheer strake, a red boot-top, tar at the waterline, barnacles
  part(face, L.wall2, { nopop = true })
  hline(RX0, RX1, RY1 + 1, L.awnB.hi) hline(RX0, RX1, RY1 + 4, L.awnA.base) hline(RX0, RX1, RY1 + 5, L.tar.base)
  for x = RX0 + 2, RX1 - 2, 8 do vline(x, RY1 + 2, RY1 + 3, L.wall2.deep) end
  F.barnacles(face, .12, 111, RY1 + 4)
  -- rope fenders hanging over the side
  for x = RX0 + 12, RX1 - 10, 22 do
    local fm = c:rrect(x - 1, RY1 + 1, x + 1, RY1 + 5, 1) c:rim(fm, L.cork.edge) fill(fm, L.cork.base) px(x - 1, RY1 + 2, L.cork.hi) px(x + 1, RY1 + 4, L.cork.deep)
  end
  part(ramp, L.timber, { nopop = true })
  ramp:each(function(x, y) if (x - RX0) % 3 == 0 then px(x, y, L.timber.deep) end if y > RY1 then px(x, y, L.tar.base) end end)
  line({ { RX0 - 7, RY0 - 6 }, { RX0 + 5, RY0 - 8 } }):each(function(x, y) if (x % 2 == 0) then px(x, y, L.iron.shade) else px(x, y, L.iron.hi) end end)
  -- far rail behind the cargo
  for x = RX0 + 6, RX1 - 6 do px(x, RY0 - 6 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.cork.shade) end
  -- cargo: lobster pots, a fish box, a coil of rope with an orange float
  F.lobsterPot(RX0 + 10, RY0 + 6, 5)
  F.lobsterPot(RX0 + 21, RY0 + 4, 4)
  F.crate(RX1 - 34, RY0 + 6, 12, 8, L.iron)
  local coil = c:ellipse(RX1 - 16, RY0 + 4, 4, 2) rimOf(coil, L.cork) fill(coil, L.cork.base) hline(RX1 - 19, RX1 - 13, RY0 + 4, L.cork.shade) px(RX1 - 16, RY0 + 4, L.cork.deep) px(RX1 - 19, RY0 + 3, L.cork.hi)
  local fl = c:ellipse(RX1 - 11, RY0 + 1, 2, 2) rimOf(fl, L.produce) fill(fl, L.produce.base) px(RX1 - 12, RY0, L.produce.hi)
  -- the sea chest the seal lies on
  local T0 = RX0 + 40
  local tk = rect(T0, RY0 + 1, T0 + 18, RY0 + 9)
  c:rim(tk, L.tar.edge) part(tk, L.accent) hline(T0, T0 + 18, RY0 + 4, L.accent.deep) vline(T0 + 3, RY0 + 1, RY0 + 9, L.iron.base) vline(T0 + 15, RY0 + 1, RY0 + 9, L.iron.base)
  hline(T0 + 1, T0 + 17, RY0 + 1, L.accent.hi)
  fill(rect(T0 + 8, RY0 + 4, T0 + 10, RY0 + 6), L.gold.base) px(T0 + 8, RY0 + 4, L.gold.hi) px(T0 + 10, RY0 + 6, L.gold.shade)
  -- the traveller with a big bundle on a stick
  local gx = RX0 + 28
  fill(line({ { gx + 7, FY - 17 }, { gx - 9, FY - 23 } }), L.timber.hi)
  local bun = c:ellipse(gx - 11, FY - 23, 4, 4) c:rim(bun, L.tar.edge) part(bun, L.awnA, { nopop = true })
  bun:each(function(x, y) if (x + y) % 4 == 0 then px(x, y, L.awnB.hi) elseif x > gx - 11 and y > FY - 23 then px(x, y, L.awnA.shade) end end) px(gx - 11, FY - 27, L.awnA.deep)
  F.gnome(gx, FY, { hat = L.lav, coat = L.roof2, arm = "up", noShadow = true })
  -- QUIRK: the harbour seal in the red gnome hat, lying on the sea chest
  sealSprite(T0 - 2, RY0 - 15)
  -- the ferryman in yellow oilskins, quanting from the back right corner
  local _, fx, fy = F.gnome(RX1 - 14, FY, { hat = L.accent, coat = L.gold, arm = "up", flip = false, noShadow = true, hatBand = L.awnB.hi })
  local pole = line({ { fx - 3, fy - 10 }, { fx + 14, RY1 + 17 } }, 1)
  fill(pole, L.timber.shade) line({ { fx - 2, fy - 10 }, { fx + 15, RY1 + 17 } }):each(function(x, y) if y < RY1 + 5 then px(x, y, L.timber.hi) end end)
  for k = 0, 2 do hline(fx + 10 - k * 3, fx + 18 + k * 3, RY1 + 18 + k * 2, Wt.hi) end
  -- near rail and posts in front of everyone, a lifebuoy hung on the rail
  part(posts, L.timber, { nopop = true, noshade = true })
  F.barnacles(posts, .1, 112, RY1 - 3)
  for x = RX0 + 2, RX1 - 2 do px(x, RY1 - 7 + floor(2 * sin((x - RX0) / (RX1 - RX0) * pi)), L.cork.deep) end
  local bx, by = RX0 + 66, RY1 - 2
  local ring = c:ellipse(bx, by, 4, 4):cut(c:ellipse(bx, by, 1, 1))
  c:rim(ring, L.awnA.edge)
  ring:each(function(x, y) local a = math.atan(y - by, x - bx) local q = floor((a + pi) / (pi / 2)) % 2
    local col = q == 0 and L.awnA.base or L.awnB.hi
    if x - bx + y - by > 3 then col = q == 0 and L.awnA.shade or L.awnB.shade end
    px(x, y, col) end)
  fill(c:ellipse(bx, by, 1, 1), L.wall2.base)
  vline(bx, by - 8, by - 5, L.cork.deep)
end

---------------------------------------------------------------- near bank: gnome hauling the tow rope on the slipway
F.depth(3)
do
  local _, hx, hy = F.gnome(244, 200, { hat = L.roof2, coat = L.board, arm = "up" })
  local x0, y0 = RX0 - 6, RY1 - 6
  local pts = {}
  for xx = hx, x0 do local t = (xx - hx) / (x0 - hx) pts[#pts + 1] = { xx, floor(hy + (y0 - hy) * t + 9 * 4 * t * (1 - t) + .5) } end
  local rope = line(pts, 2)
  c:rim(rope, L.cork.edge)
  rope:each(function(x, y) local top = not rope:has(x, y - 1) px(x, y, top and L.cork.hi or L.cork.base) if (x + y) % 3 == 0 then px(x, y, L.cork.shade) end end)
  for _, p in ipairs(pts) do if p[2] > yN(p[1]) - 3 and p[1] % 5 == 0 then px(p[1], p[2] + 2, GLINT) end end -- drips where it skims the water
  local coil = c:ellipse(232, 200, 6, 2) c:rim(coil, L.cork.edge) part(coil, L.cork, { nopop = true }) c:ellipse(232, 200, 3, 1):edge():each(function(x, y) px(x, y, L.cork.deep) end)
  local tail = line({ { hx - 1, hy + 1 }, { 236, 198 } }, 2) c:rim(tail, L.cork.edge) fill(tail, L.cork.base) tail:each(function(x, y) if (x + y) % 3 == 0 then px(x, y, L.cork.shade) end end)
end

-- wind-bent hawthorns at the left of the near bank (behind the booth)
F.depth(3)
F.tree(16, 196, 40, 0)
F.tree(100, 186, 26, 1)

DY = 10
---------------------------------------------------------------- near bank left: bell frame, ferry sign, booth, bench, rowboat
do -- the ferry bell on a frame under a little slate roof
  local fr = rect(186, 150, 187, 196):add(rect(206, 150, 207, 196)):add(rect(183, 148, 210, 150))
  F.shadow(186, 208, 197, 6, 3)
  rimOf(fr, L.tar) part(fr, L.timber, { nopop = true, noshade = true }) hline(183, 210, 148, L.timber.hi)
  F.lichen(rect(186, 186, 187, 196):add(rect(206, 186, 207, 196)), .3, 113)
  local roofb = poly{ { 181, 148 }, { 196, 140 }, { 212, 148 } } rimOf(roofb, L.roof) part(roofb, L.roof, { nopop = true })
  F.courses(roofb, 140, 3, 4, L.roof) F.lichen(roofb, .12, 114)
  vline(196, 151, 153, L.iron.shade)
  local bell = poly{ { 193, 154 }, { 199, 154 }, { 201, 163 }, { 203, 165 }, { 189, 165 }, { 191, 163 } }:add(c:ellipse(196, 155, 3, 2))
  c:rim(bell, L.tar.edge) part(bell, L.gold) vline(193, 156, 163, L.gold.hi) hline(190, 202, 164, L.gold.shade)
  -- verdigris on the bronze
  bell:each(function(x, y) if hash(x, y, 115) < .12 and y > 157 then px(x, y, L.glass.base) end end)
  fill(rect(195, 166, 197, 167), L.iron.base)
  fill(line({ { 197, 167 }, { 199, 180 } }), L.cork.shade)
end
do -- the ferry sign: a painted ferry on waves, a gull over it
  local post = rect(170, 168, 171, 200)
  local bd = rect(156, 152, 185, 168)
  rimOf(union(post, bd), L.tar) part(post, L.timber, { nopop = true }) part(bd, L.wall2, { nopop = true })
  c:edgeIn(bd, L.wall2.deep)
  for x = 159, 182 do px(x, 164 + floor(sin(x / 2) + .5), L.awnB.hi) px(x, 165 + floor(sin(x / 2) + .5), L.wall2.shade) end
  fill(rect(162, 160, 180, 162), L.awnB.base) hline(162, 180, 162, L.awnA.base) hline(162, 180, 160, L.awnB.hi)
  vline(166, 155, 159, L.tar.edge) vline(176, 155, 159, L.tar.edge) fill(rect(169, 155, 173, 159), L.awnA.base) -- passengers
  px(160, 155, L.awnB.hi) px(161, 156, L.awnB.hi) px(162, 155, L.awnB.hi) -- the painted gull
  F.barnacles(rect(170, 194, 171, 200), .3, 116)
end
F.depth(3)
do -- the tarred ticket booth with a gnome in the hatch, red pantile roof, blue-and-white awning
  local wall = rect(38, 168, 92, 200)
  local roof = poly{ { 32, 170 }, { 65, 146 }, { 98, 170 } }:add(rect(32, 168, 98, 171))
  F.shadow(40, 92, 200, 10, 4)
  rimOf(union(wall, roof), L.tar)
  part(wall, L.tar) F.planks(wall, L.tar, 4, true, 3)
  wall:each(function(x, y) if y > 195 and hash(x, y // 2, 117) < .4 then px(x, y, L.sand.shade) end end)
  part(roof, L.roof2, { sep = true }) F.pantile(roof, L.roof2, 146, 118)
  F.lichen(roof, .05, 119)
  line({ { 32, 170 }, { 65, 146 } }):each(function(x, y) px(x, y, L.roof2.hi) end)
  -- hatch with awning
  local hatch = rect(50, 178, 80, 192)
  fill(hatch, L.soil.deep) c:edgeIn(hatch, L.wall2.base)
  fill(rect(51, 179, 56, 183), L.glow.shade) px(52, 180, L.glow.base) -- a lamp lit inside
  F.gnome(65, 198, { hat = L.awnA, coat = L.accent, arm = "out", noShadow = true })
  local sill = rect(48, 192, 82, 194) rimOf(sill, L.tar) part(sill, L.board, { nopop = true })
  fill(rect(76, 189, 78, 191), L.awnB.hi) px(77, 189, L.awnA.base) -- a ticket
  local aw = poly{ { 46, 172 }, { 84, 172 }, { 88, 178 }, { 42, 178 } }
  rimOf(aw, L.wall2) fill(aw, L.wall2.base)
  aw:each(function(x, y) if ((x - 42) // 5) % 2 == 1 then px(x, y, L.awnB.hi) end if y == 178 then px(x, y, ((x // 3) % 2 == 0) and L.wall2.deep or L.wall2.shade) end end)
  hline(46, 84, 172, L.wall2.hi)
  F.window(86, 158, 88, 161, L.wall2)
  -- a lifebuoy on the gable and a fish plaque
  local lb = c:ellipse(65, 162, 4, 4):cut(c:ellipse(65, 162, 1, 1)) c:rim(lb, L.awnA.edge)
  lb:each(function(x, y) local a = math.atan(y - 162, x - 65) px(x, y, (floor((a + pi) / (pi / 2)) % 2 == 0) and L.awnA.base or L.awnB.hi) end)
  fill(c:ellipse(65, 162, 1, 1), L.tar.base)
  -- a net draped at the booth's side with cork floats
  F.netSwag(92, 104, 172, 10, { col = L.cork.shade, col2 = L.cork.deep, floatStep = 5 })
end
do -- bench of driftwood with two waiting travellers and their luggage
  local _, ax, ay = F.gnome(112, 214, { hat = L.roof, coat = L.lav, arm = "hold", noShadow = true })
  F.gnome(134, 215, { hat = L.accent, coat = L.awnA, flip = true, noShadow = true })
  local seat = rect(100, 207, 146, 209)
  local legs = rect(103, 210, 104, 218):add(rect(142, 210, 143, 218))
  F.shadow(102, 146, 219, 8, 3)
  rimOf(union(seat, legs), L.tar) part(legs, L.timber, { nopop = true, noshade = true }) part(seat, L.timber, { nopop = true }) hline(100, 146, 207, L.timber.hi)
  seat:each(function(x, y) if hash(x // 4, y, 120) < .2 then px(x, y, L.timber.shade) end end)
  -- luggage: a sea chest and a canvas kitbag
  local tr = c:rrect(150, 204, 168, 218, 3):clip(rect(150, 204, 168, 218))
  F.shadow(150, 168, 219, 5, 2)
  rimOf(tr, L.tar) part(tr, L.roof2) hline(150, 168, 209, L.iron.base) vline(155, 204, 218, L.iron.shade) vline(163, 204, 218, L.iron.shade) px(159, 211, L.glow.hi)
  local bag = c:rrect(152, 222, 166, 232, 3) rimOf(bag, L.tar) part(bag, L.awnB)
  bag:each(function(x, y) if y == 226 then px(x, y, L.accent.base) end end)
  fill(c:ellipse(159, 221, 3, 2):cut(c:ellipse(159, 221, 1, 1)):clip(rect(150, 218, 168, 221)), L.cork.base)
end
do -- a rowboat pulled up on the mud, oars across it, anchor out on its chain
  local y = 228
  local hull = poly{ { 18, y - 4 }, { 24, y }, { 76, y + 2 }, { 82, y - 3 }, { 74, y + 9 }, { 26, y + 8 } }
  local inside = c:ellipse(50, y - 1, 26, 2)
  F.shadow(24, 78, y + 10, 6, 3)
  rimOf(union(hull, inside), L.tar)
  part(hull, L.awnB) hline(24, 76, y + 4, L.wall2.base) hline(26, 74, y + 5, L.wall2.shade)
  hull:each(function(x, y2) if y2 >= y + 6 and hash(x // 2, y2, 121) < .45 then px(x, y2, hash(x, y2, 122) < .5 and L.kelp.base or L.foliage2.shade) end end)
  F.barnacles(hull, .12, 123, y + 6)
  fill(inside, L.timber.shade) c:edgeIn(inside, L.timber.base)
  fill(line({ { 30, y - 5 }, { 74, y + 1 } }), L.board.base) fill(rect(72, y - 1, 78, y + 1), L.board.base)
  -- the anchor chain and a fisherman's anchor in the mud
  for k = 0, 8 do px(84 + k * 2, y + 1 + k // 3, L.iron.shade) px(85 + k * 2, y + 1 + k // 3, L.iron.hi) end
  local an = rect(102, y - 2, 103, y + 6):add(line({ { 98, y + 4 }, { 102, y + 7 }, { 107, y + 4 } })):add(rect(99, y - 2, 106, y - 2))
  c:rim(an, L.iron.edge) fill(an, L.iron.base) px(102, y - 2, L.iron.hi)
end
DY = 0
-- near reeds: phragmites beds on both sides of the slipway, with saltmarsh at their feet
reedClump(214, yN(214) + 3, 14, 22, 3, true)
reedClump(120, yN(120) + 3, 12, 18, 5, true)
reedClump(392, yN(392) + 3, 14, 22, 7, true)
reedClump(452, yN(452) + 3, 10, 20, 9, true)
reedClump(20, yN(20) + 3, 8, 16, 11, true)
for _, s in ipairs({ { 132, 0 }, { 200, 1 }, { 280, 0 }, { 300, 1 }, { 404, 0 }, { 436, 1 }, { 470, 1 }, { 6, 0 } }) do
  local x = s[1]
  if s[2] == 0 then samphire(x, yN(x) + 5, 4, x) else seaLavender(x, yN(x) + 5, 7, x) end
end

---------------------------------------------------------------- channel right: shelducks, a mudbank with oystercatchers, a moored dinghy
F.depth(3)
DY = 8
do -- the mudbank breaking the surface: wet mud with a shine, wrack strands, bird tracks
  local mb = c:ellipse(368, 166, 32, 4):clip(rect(330, 162, 410, 170))
  mb:each(function(x, y)
    local top = not mb:has(x, y - 1)
    local col = top and mud.hi or (hash(x // 2, y, 131) < .6 and mud.base or mud.shade)
    if not mb:has(x, y + 1) then col = mud.deep end
    px(x, y, col)
  end)
  hline(338, 398, 171, Wt.hi)
  F.wrack(352, 165, 6, 3) F.wrack(380, 167, 5, 7)
  for _, t in ipairs({ { 344, 166 }, { 349, 167 }, { 356, 166 } }) do px(t[1], t[2], mud.deep) px(t[1] - 1, t[2] - 1, mud.deep) px(t[1] + 1, t[2] - 1, mud.deep) end
  local function oyc(x, y, flip)
    local rows = { "..KK...", ".KeKoo.", "KKKK...", "KWWWW..", ".WWWW..", "..p.p.." }
    if flip then for i, r in ipairs(rows) do rows[i] = r:reverse() end end
    F.sprite(rows, x, y, { K = L.tar.deep, W = L.gull.hi, e = L.awnA.base, o = L.produce.base, p = L.petal.shade }, { rimCol = L.tar.edge })
  end
  oyc(362, 157, false) oyc(374, 158, true) oyc(388, 159, false)
end
local function shelduck(x, y, big)
  if big then
    local m = c:ellipse(x, y, 5, 3):add(c:ellipse(x - 5, y - 4, 2, 2))
    c:rim(m, L.tar.edge) part(m, L.gull, { nopop = true })
    fill(c:ellipse(x - 5, y - 4, 2, 2), L.foliage2.deep) px(x - 6, y - 5, L.foliage2.shade)
    hline(x - 4, x + 1, y - 2, L.roof2.base) hline(x - 3, x, y - 1, L.roof2.shade) -- chestnut breast band
    hline(x + 1, x + 5, y, L.tar.deep)
    fill(rect(x - 9, y - 4, x - 8, y - 3), L.awnA.base) px(x - 6, y - 5, L.tar.edge) hline(x - 6, x + 6, y + 3, Wt.hi)
  else
    local m = c:ellipse(x, y, 2, 1):add(rect(x - 2, y - 2, x - 1, y - 1))
    c:rim(m, L.tar.edge) part(m, L.gull, { nopop = true })
    px(x - 2, y - 2, L.tar.base) px(x + 1, y - 1, L.tar.base) px(x - 3, y - 2, L.wetSand.shade) hline(x - 3, x + 3, y + 2, Wt.hi)
  end
end
shelduck(150, 140, true) shelduck(162, 144) shelduck(172, 142) shelduck(182, 146)
do -- a clinker dinghy tied to a stake
  local y = 178
  local hull = poly{ { 420, y - 2 }, { 470, y - 2 }, { 466, y + 4 }, { 424, y + 4 } }
  rimOf(hull, L.tar) part(hull, L.roof2) hline(422, 468, y, L.roof2.deep) hline(421, 469, y - 2, L.awnB.hi)
  hull:each(function(x, y2) if y2 >= y + 2 and hash(x // 2, y2, 118) < .4 then px(x, y2, L.kelp.base) end end)
  for k = 0, 2 do hline(424 + k * 2, 466 - k * 2, y + 6 + k * 2, Wt.shade) end
  local st = rect(410, y - 12, 412, y + 6) rimOf(st, L.tar) part(st, L.timber, { nopop = true, noshade = true })
  F.barnacles(st, .25, 119, y - 2)
  fill(line({ { 412, y - 8 }, { 422, y - 1 } }), L.cork.shade)
  F.gull(411, y - 14, 2)
end

---------------------------------------------------------------- near bank right: cargo waiting to cross, a gnome with a fish, a thieving gull
F.depth(3)
DY = 0
do
  -- fish boxes: a painted band, mackerel and ice heaped on top
  local function fishBox(x0, yb, w, h, band)
    F.crate(x0, yb, w, h)
    hline(x0 + 1, x0 + w - 1, yb - h // 2, band.base) hline(x0 + 1, x0 + w - 1, yb - h // 2 + 1, band.shade)
    local top = yb - h - 1
    for k = x0 + 1, x0 + w - 6, 7 do
      local yy = top - 2 - (k // 7) % 2
      F.sprite({ ".MMMMt", "eMmmMtt", ".mmmm." }, k, yy, { M = L.accent.hi, m = L.iron.hi, t = L.accent.shade, e = L.tar.base }, { rimCol = L.accent.deep })
    end
    hline(x0 + 1, x0 + w - 1, top + 1, L.awnB.hi)
  end
  fishBox(300, 222, 18, 12, L.wall2) fishBox(318, 222, 16, 12, L.awnA) fishBox(306, 209, 16, 10, L.wall2)
  F.lobsterPot(348, 226, 7)
  F.sack(362, 228, L.awnB, 5)
  F.barrel(288, 224, L.timber, 12)
  local _, hx, hy = F.gnome(370, 236, { hat = L.lav, coat = L.foliage2, arm = "out", flip = true })
  -- a mackerel held up by the tail
  F.sprite({ "t.", "tt", "MM", "MM", "mM", "mM", "Mm", ".e" }, hx - 1, hy - 1, { t = L.accent.shade, M = L.accent.hi, m = L.iron.hi, e = L.tar.base }, { rimCol = L.tar.edge })
  -- a lantern on a post at the slipway's right
  local lp = rect(280, 160, 281, 200) rimOf(lp, L.tar) part(lp, L.timber, { nopop = true, noshade = true })
  F.barnacles(rect(280, 190, 281, 200), .3, 120)
  local lam = rect(277, 152, 284, 160) rimOf(lam, L.tar) fill(lam, L.glow.base) fill(rect(278, 153, 280, 158), L.glow.hi) vline(284, 153, 160, L.glow.shade)
  fill(rect(276, 150, 285, 151), L.tar.base)
end
-- foreground: a barrow of cockle and mussel baskets, barnacled rocks, marram, thrift, shells, driftwood
do
  local y = 250
  local tray = poly{ { 96, y - 12 }, { 132, y - 12 }, { 128, y - 2 }, { 100, y - 2 } }
  local legs = rect(102, y - 2, 103, y + 4):add(line({ { 132, y - 8 }, { 146, y - 2 } }, 2))
  local wh = c:ellipse(92, y, 5, 5)
  F.shadow(92, 132, y + 5, 8, 3)
  rimOf(union(tray, legs, wh), L.tar)
  part(legs, L.timber, { nopop = true, noshade = true })
  part(tray, L.wall2) F.planks(tray, L.wall2, 5, true, 2)
  part(wh, L.timber, { nopop = true }) px(92, y, L.iron.hi) hline(88, 96, y, L.timber.deep)
  for k, bk in ipairs({ { 106, 7, "m" }, { 122, 7, "c" } }) do
    local bx = bk[1]
    local basket = c:rrect(bx - bk[2], y - 22, bx + bk[2], y - 12, 3)
    local heap = c:ellipse(bx, y - 22, bk[2] - 1, 3):clip(rect(bx - bk[2], y - 26, bx + bk[2], y - 22))
    rimOf(union(basket, heap), L.soil)
    basket:each(function(x, yy) px(x, yy, ((x + yy) % 3 == 0) and L.cork.shade or (x < bx and L.cork.hi or L.cork.base)) end)
    hline(bx - bk[2], bx + bk[2], y - 22, L.cork.deep)
    heap:each(function(x, yy)
      local v = hash(x, yy, 130 + k)
      if bk[3] == "m" then px(x, yy, v < .4 and L.accent.deep or (v < .7 and L.tar.base or L.accent.base)) if v > .92 then px(x, yy, L.accent.hi) end
      else px(x, yy, v < .4 and L.awnB.hi or (v < .75 and L.awnB.base or L.wetSand.shade)) end
    end)
  end
end
F.barnacles(F.rock(160, 254, 9, 6), .14, 121, 0) F.rock(172, 257, 5, 4)
F.barnacles(F.rock(70, 254, 6, 4), .14, 122, 0)
F.wrack(150, 258, 7, 2) F.wrack(56, 260, 6, 5)
F.driftwood(184, 246, 214, 240, 2)
for _, f in ipairs({ { 30, 216, 6 }, { 148, 246, 6 }, { 196, 238, 7 }, { 270, 214, 5 }, { 362, 214, 5 }, { 60, 262, 7 }, { 196, 262, 8 }, { 290, 250, 7 }, { 330, 258, 6 }, { 300, 236, 5 }, { 214, 218, 5 }, { 96, 224, 5 } }) do F.marram(f[1], f[2], f[3]) end
F.thrift(176, 250, true) F.thrift(82, 258, true) F.thrift(268, 222, false) F.thrift(318, 262, true)
F.shell(186, 256, true) F.shell(190, 258, false) F.shell(312, 244, true) F.shell(44, 248, true)
F.pebbles(232, 264, 4, 7) F.pebbles(140, 266, 3, 9)

---------------------------------------------------------------- bank fringe, a crabbing gnome, the gull after the fish
F.depth(3)
-- sea purslane and cordgrass overhanging the near mud edge, pebbles
for x = 0, 479 do
  local yn = yN(x)
  if hash(x, 1, 91) < .4 and not F.roadM:has(x, yn + 1) and not (x > 190 and x < 290) then
    local h = 2 + floor(hash(x, 2, 91) * 3)
    vline(x, yn + 3 - h, yn + 3, reed.shade) px(x, yn + 3 - h, hash(x, 4, 91) < .5 and L.foliage.base or reed.hi)
  end
end
-- a crabbing gnome on an upturned bucket at the right bank, line out over the reeds, crabs in a bucket
do
  local bk = poly{ { 410, 210 }, { 422, 210 }, { 420, 220 }, { 412, 220 } }
  F.shadowM(c:ellipse(418, 222, 10, 1))
  rimOf(bk, L.tar) part(bk, L.wall2) hline(410, 422, 213, L.wall2.deep) hline(411, 421, 218, L.wall2.deep)
  local _, hx, hy = F.gnome(416, 210, { hat = L.awnA, coat = L.accent, arm = "up", flip = true, noShadow = true, hatBand = L.gold.base })
  local rod = line({ { hx, hy + 2 }, { 380, 176 } })
  fill(rod, L.timber.shade) px(380, 176, L.timber.deep)
  for y = 177, 190 do px(380 - floor((y - 177) * .2), y, L.awnB.shade) end
  px(377, 191, L.roof2.base) px(378, 191, L.roof2.shade) px(377, 190, GLINT) hline(372, 382, 192, Wt.hi)
  -- the crab bucket, crabs climbing out
  local cr = poly{ { 428, 211 }, { 442, 211 }, { 440, 222 }, { 430, 222 } } rimOf(cr, L.iron) part(cr, L.iron)
  hline(428, 442, 211, L.iron.hi) hline(429, 441, 214, L.iron.deep) hline(430, 440, 219, L.iron.deep)
  line({ { 428, 212 }, { 435, 204 }, { 442, 212 } }):each(function(x, y) if not cr:has(x, y) then px(x, y, L.iron.deep) end end)
  local crab = { "C.....C", "CC...CC", ".CCCCC.", "CcCCCcC", "c.c.c.c" }
  F.sprite(crab, 431, 207, { C = L.roof2.base, c = L.roof2.shade }, { rimCol = L.roof2.edge })
  px(433, 209, L.tar.edge) px(437, 209, L.tar.edge)
  F.sprite(crab, 444, 218, { C = L.roof2.base, c = L.roof2.shade }, { rimCol = L.roof2.edge })
  px(446, 220, L.tar.edge) px(450, 220, L.tar.edge)
end
-- a herring gull stretching its neck at the gnome's mackerel
do
  local rows = {
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
  }
  for i, r in ipairs(rows) do rows[i] = r:reverse() end
  F.sprite(rows, 336, 228, { W = L.gull.hi, G = L.gull.shade, K = L.tar.deep, w = L.gull.hi, Y = L.gold.base, r = L.apple.base, e = L.tar.edge, p = L.petal.shade }, { rimCol = L.gull.edge })
  F.shadowM(c:ellipse(344, 241, 6, 1))
end

DY = 0
F.depth(0)
F.gull(150, 58, 2) F.gull(162, 52, 1) F.gull(360, 46, 3) F.gull(374, 54, 2) F.gull(300, 26, 2)
F.birds({ { 112, 70, 1 } })
F.finish()
