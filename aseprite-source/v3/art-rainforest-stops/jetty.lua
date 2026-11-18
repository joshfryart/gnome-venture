-- jetty.lua : "Lakeside jetty" stop look, RAINFOREST (rainforest_canopy), 480x270 gate view.
-- Same composition as the Maplewold jetty (art-2701-batch3/stops/opus3/jetty.lua) and the forest jetty, re-cast for a
-- jungle river: right half: a jade river under a dark canopy wall (its trees and hanging vines mirrored in the still
-- water), mist lying on the water; a bamboo landing on hardwood piles lashed with rattan, a moored dugout canoe with a
-- painted eye, a bamboo lantern pole and a gnome fishing off the end; a palm-thatch fishing hut on stilts and a far
-- dugout with a paddler; a bamboo fish weir with a conical trap, pink river dolphins, a leaping peacock bass, water
-- hyacinth, a caiman's eyes by the landing. Left: the fisher's bamboo hut (green palm thatch), a fish-drying rack, the
-- bamboo net frame with gourd floats, a dugout canoe being carved on trestles (resin pot on a fire), conical bamboo
-- fish traps, clay water jars, a coati eyeing the fish basket. Quirk (kept): a rufescent tiger-heron in a red gnome hat
-- helping itself to the fish basket.
local DIR = "/home/user/gnome-venture/aseprite-source/v3/art-rainforest-stops/"
local F = dofile(DIR .. "_frame.lua").build{ name = "jetty", out = DIR, farTrees = { 24, 52, 120, 196, 290, 352, 440 },
  treeLineGap = { 220, 490 } } -- the right half gets its own darker canopy wall over the river
local c, L, HP = F.c, F.L, F.HP
local part, rect, poly, line, fill, px, rimOf, hline, vline, union, hash = F.part, F.rect, F.poly, F.line, F.fill, F.px, F.rimOf, F.hline, F.vline, F.union, F.hash
local floor, sin, cos, pi = math.floor, math.sin, math.cos, math.pi
local mix, rp = F.mix, F.rp
local W = L.water

-- local ramps: dark riverbank canopy, a deep jungle green, a tannin-tinted river, a rattan lashing colour
local darkJungle = rp("#70b090 #3e8268 #2a6454 #1c4a44 #103234")
local deepGreen = rp("#8ccf78 #44975a #2a744a #1c5440 #10362e")
local rattan = rp("#e6c88a #c09a5c #94703e #684c2e #403020")
local hbody = rp("#c4c4a0 #96987a #74765e #545646 #36382e") -- barred olive-grey back
local heron = rp("#e8a070 #c46a42 #964a32 #683228 #42201c") -- rufous neck
local function lum(h)
  local r, g, b = tonumber(h:sub(2, 3), 16), tonumber(h:sub(4, 5), 16), tonumber(h:sub(6, 7), 16)
  return (r * .3 + g * .59 + b * .11) / 255
end

-- local helpers ----------------------------------------------------------------
-- a round clay water jar with a narrow neck and a lip, lit upper left
local function jar(x, yb, h, r)
  r = r or L.soil
  local rr = floor(h * .42)
  local body = c:ellipse(x, yb - rr, rr, rr)
  local neck = rect(x - 2, yb - h, x + 2, yb - 2 * rr + 1)
  local lip = rect(x - 3, yb - h - 1, x + 3, yb - h)
  local m = union(body, neck, lip)
  rimOf(m, r) part(m, r, { nopop = true })
  body:each(function(xx, yy)
    local d = (xx - x) / rr + (yy - (yb - rr)) / rr
    if d < -.8 then px(xx, yy, r.hi) elseif d > .9 then px(xx, yy, r.deep) end
  end)
  hline(x - 3, x + 3, yb - h - 1, r.hi) hline(x - 2, x + 2, yb - h + 1, r.deep)
  hline(x - rr + 1, x + rr - 1, yb - rr - 1, r.shade) -- incised band
  for xx = x - rr + 2, x + rr - 2, 3 do px(xx, yb - rr - 2, r.deep) end
  px(x - floor(rr * .5), yb - floor(rr * 1.4), L.wet)
  return m
end
-- a conical bamboo fish trap lying on its side: open mouth (left or right), ribs, rattan rings, a tied tail
local function fishTrap(x, yb, len, flip, r)
  r = r or L.board
  local s = flip and -1 or 1
  local mh = 6
  local m = poly{ { x, yb - mh * 2 }, { x + s * len, yb - mh - 3 }, { x + s * (len + 2), yb - mh - 2 }, { x + s * (len + 2), yb - mh + 2 }, { x + s * len, yb - mh + 3 }, { x, yb } }
  rimOf(m, r)
  part(m, r, { nopop = true })
  m:each(function(xx, yy)
    local t = (xx - x) * s / len
    local cy = yb - mh
    local half = mh * (1 - t * .5)
    local v = (yy - cy) / math.max(1, half)
    local h = v < -.3 and r.hi or (v > .45 and r.shade or r.base)
    if floor((yy - cy) / math.max(1, half) * 2.5 + 3) ~= floor((yy - cy + 1) / math.max(1, half) * 2.5 + 3) then h = r.deep end -- ribs
    if ((xx - x) * s) % 5 == 3 then h = rattan.shade end -- rings
    px(xx, yy, h)
  end)
  local mouth = c:ellipse(x, yb - mh, 2, mh)
  rimOf(mouth, r) fill(mouth, r.base) fill(c:ellipse(x, yb - mh, 1, mh - 2), L.soil.deep)
  px(x - s, yb - mh - 3, r.hi)
  px(x + s * (len + 4), yb - mh, rattan.deep) px(x + s * (len + 5), yb - mh + 1, rattan.shade)
  return m
end
-- an upright conical trap standing in the water (bubu), mouth down
local function standingTrap(x, yb, h)
  local m = poly{ { x - 4, yb }, { x + 4, yb }, { x + 1, yb - h }, { x - 1, yb - h } }
  rimOf(m, L.board)
  m:each(function(xx, yy)
    local h2 = xx < x and L.board.hi or (xx == x and L.board.base or L.board.shade)
    if (yy - yb) % 3 == 0 then h2 = rattan.shade end
    px(xx, yy, h2)
  end)
  vline(x, yb - h - 3, yb - h, rattan.deep)
end
-- the dugout canoe: a long hardwood hull with raised carved ends, a hollow (dark inside), a teal painted band
-- and an eye on the prow. o.short for the far one.
local function dugout(x0, x1, y, o)
  o = o or {}
  local hull = poly{ { x0 - 5, y - 4 }, { x0, y - 1 }, { x1, y - 1 }, { x1 + 5, y - 4 }, { x1 + 3, y + 2 }, { x1 - 6, y + 6 }, { x0 + 6, y + 6 }, { x0 - 3, y + 2 } }
  local inside = c:ellipse((x0 + x1) // 2, y - 1, (x1 - x0) // 2 - 2, 1)
  rimOf(union(hull, inside), L.timber)
  part(hull, L.redbark)
  hull:each(function(xx, yy) if yy < y + 1 and hash(xx // 3, yy, 41) < .3 then px(xx, yy, L.redbark.hi) end end)
  if not o.short then
    hline(x0 + 1, x1 - 1, y + 1, L.accent.base) hline(x0 + 2, x1 - 2, y + 2, L.accent.shade)
    for xx = x0 + 4, x1 - 4, 6 do px(xx, y + 1, L.gold.hi) end
    -- eye on the prow (right end)
    px(x1 - 1, y, L.awnB.hi) px(x1, y, L.timber.edge) px(x1 - 1, y - 1 + 1, L.awnB.hi)
    hull:each(function(xx, yy) if yy > y + 3 and hash(xx, yy, 42) < .25 then px(xx, yy, L.moss.shade) end end)
  end
  fill(inside, L.timber.deep) inside:each(function(xx, yy) if xx < (x0 + x1) // 2 - 6 then px(xx, yy, L.timber.shade) end end)
  -- carved end posts
  px(x0 - 5, y - 5, L.redbark.hi) px(x1 + 5, y - 5, L.redbark.base)
  return hull
end
local function reed(rx, ry, h, kind)
  vline(rx, ry - h, ry, (rx % 2 == 0) and L.fern.shade or L.fern.deep)
  px(rx - 1, ry - h // 2, L.fern.base)
  if kind == 1 then -- a little arrowhead leaf
    px(rx - 1, ry - h, L.leaf.hi) px(rx - 2, ry - h + 1, L.leaf.base) px(rx + 1, ry - h, L.leaf.base) px(rx + 2, ry - h + 1, L.leaf.shade) px(rx, ry - h - 1, L.leaf.hi)
  elseif kind == 2 then -- a red ginger head
    px(rx, ry - h - 1, L.helic.base) px(rx, ry - h - 2, L.helic.hi) px(rx + 1, ry - h, L.helic.shade) px(rx - 1, ry - h, L.helic.base)
  end
end

---------------------------------------------------------------- the river
local WL = 118 -- waterline under the far bank
local lake = poly{ { 268, WL }, { 479, WL }, { 479, 228 }, { 372, 228 }, { 350, 220 }, { 326, 202 }, { 304, 176 }, { 288, 150 }, { 276, 130 } }
-- the far bank strip (dark wet humus and moss under the canopy)
local shore = poly{ { 258, 112 }, { 479, 112 }, { 479, WL }, { 268, WL } }
shore:each(function(x, y)
  local v = hash(x, y, 81)
  px(x, y, v < .35 and L.mossGround.deep or (v < .7 and L.mossGround.shade or L.ground.deep))
end)
-- wet red mud bank with roots and pebbles along the near diagonal edge
local beach = lake:grow(4):cut(lake):clip(rect(0, WL, 479, 269))
beach:each(function(x, y)
  local v = hash(x, y, 5)
  local h = v < .35 and L.soil.base or (v < .55 and L.soil.shade or (v < .75 and L.mossGround.base or L.mossGround.shade))
  if hash(x // 2, y // 2, 6) < .12 then h = L.stone.base end
  if hash(x, y, 7) < .06 then h = L.wet end
  px(x, y, h)
end)
lake:edge():each(function(x, y) if y > WL then px(x, y, L.soil.hi) end end)
-- jade water with a tannin tint: hazy pale far off, jade in the middle, deep green-brown near the landing
local T1 = mix(W.hi, L.mist, .4)
local T2 = mix(mix(W.hi, W.base, .5), L.mist, .15)
local T3 = mix(W.base, "#7a9a6a", .25)
local T4 = mix(T3, W.shade, .45)
local T5 = mix(mix(W.base, W.shade, .7), L.soil.shade, .2)
local shallowC = mix(W.hi, L.soil.base, .4)
local shallow2 = mix(T3, L.soil.shade, .3)
lake:shrink(1):each(function(x, y)
  local d = y - WL
  local h
  if d < 5 then h = T1
  elseif d < 18 then h = hash(x // 7, y, 14) < .55 and T1 or T2
  elseif d < 30 then h = hash(x // 7, y, 14) < .5 and T2 or T3
  elseif d < 58 then h = T3
  elseif d < 85 then h = hash(x // 6, y // 2, 15) < .55 and T3 or T4
  else h = hash(x // 6, y // 2, 16) < .3 and T4 or T5 end
  if not lake:has(x - 7, y) or not lake:has(x, y + 7) or not lake:has(x + 5, y + 5) then h = shallow2 end
  if not lake:has(x - 4, y) or not lake:has(x, y + 4) or not lake:has(x + 3, y + 3) then h = shallowC end
  px(x, y, h)
end)

---------------------------------------------------------------- the canopy wall across the river
F.depth(1)
local i = 0
for x = 262, 486, 7 do
  i = i + 1
  local hh = 14 + floor(hash(x, 1, 82) * 12)
  F.canopy(x + floor(hash(x, 2, 82) * 4), 114 + floor(hash(x, 3, 82) * 2), hh, L.farTree, 500 + i, { far = true, w = floor(hh * .5) + 2 })
end
F.depth(2)
-- an emergent kapok towering out of the canopy, upriver
F.canopy(300, WL, 46, L.foliage, 61, { w = 22, bark = L.birch, noVines = true })
i = 0
local x = 262
while x < 490 do
  i = i + 1
  local hh = 16 + floor(hash(x, 4, 83) * 16)
  if x > 380 and x < 452 then hh = hh - 5 end -- lower behind the fishing hut roof
  local kv = hash(x, 5, 83)
  if kv < .22 then F.palm(x, WL - 1, hh + 10, 600 + i, { ramp = deepGreen })
  else F.canopy(x, WL - 1 + floor(hash(x, 6, 83) * 2), hh, (i % 3 == 0) and L.foliage2 or darkJungle, 600 + i, { w = floor(hh * .5) + 2, small = true, bark = L.timber }) end
  x = x + 9 + floor(hash(x, 7, 83) * 8)
end
-- lianas dropping from the canopy edge to the water
for _, v in ipairs({ { 276, 98, 16 }, { 318, 96, 20 }, { 346, 100, 15 }, { 372, 98, 17 }, { 458, 100, 15 } }) do F.vine(v[1], v[2], v[3], v[1], L.vine, (v[1] % 3 == 0) and L.orchid or nil) end
F.depth(0)
-- the canopy mirrored in the still water: everything dark above the waterline, sunk toward the water colour,
-- broken by ripple rows
for xx = 268, 479 do
  for k = 1, 32 do
    local sy, dy = WL - k, WL - 1 + k
    if lake:has(xx, dy) and lake:has(xx, dy + 1) and not beach:has(xx, dy) then
      local v = c:get(xx, sy)
      if v and lum(v) < .52 and not (dy % 3 == 0 and hash(xx // 4, dy, 84) < .55) then
        local t = .22 + k * .012
        local h = mix(mix(v, T5, t), L.mist, k < 6 and .22 or .08)
        if (xx + dy) % 2 == 0 and k > 24 then h = mix(h, T3, .4) end
        px(xx, dy, h)
      end
    end
  end
end
-- lit ripple pairs (pale crest over a shade trough), longer and wider apart nearer
for y = 124, 226 do
  local d = y - 112
  local gap = 2 + d // 18
  if y % gap == 0 then
    local len = 2 + d // 9
    local x0 = 268 + floor(hash(y, 1, 13) * 30)
    while x0 < 478 do
      if hash(x0 // 9, y, 16) < .45 then
        for xx = x0, x0 + len do if lake:has(xx, y) and lake:has(xx, y + 1) and not beach:has(xx, y) then
          px(xx, y, y < 150 and T1 or W.hi) if d > 30 then px(xx, y + 1, T5) end end end
      end
      x0 = x0 + len + 6 + floor(hash(x0, y, 17) * 18)
    end
  end
end
-- warm glints of the hazy sun
for k = 0, 34 do local gx, gy = 276 + floor(hash(k, 1, 18) * 200), 124 + floor(hash(k, 2, 18) * 96) if lake:has(gx, gy) then px(gx, gy, "#f6eeb6") px(gx + 1, gy, W.hi) end end
-- floating leaves drifting downstream
for k = 0, 14 do
  local gx, gy = 290 + floor(hash(k, 3, 19) * 180), 140 + floor(hash(k, 4, 19) * 80)
  if lake:has(gx, gy) and lake:has(gx + 2, gy) then local r = (k % 3 == 0) and L.litter or L.leaf px(gx, gy, r.base) px(gx + 1, gy, r.shade) px(gx - 1, gy, r.hi) end
end
-- a leaping peacock bass over its rings
do
  local fx, fy = 364, 156
  c:ellipse(fx, fy + 6, 9, 2):edge():each(function(x2, y2) px(x2, y2, W.hi) end)
  c:ellipse(fx, fy + 6, 13, 3):edge():each(function(x2, y2) if (x2 // 2) % 2 == 0 then px(x2, y2, W.hi) end end)
  F.sprite({ "...ff..", ".fGGGf.", "fGkGkGe", ".fGGGr.", "r.f....", }, fx - 3, fy - 4,
    { f = L.leaf.shade, G = L.gold.base, k = L.leaf.deep, r = L.apple.base, e = L.timber.edge })
  for _, d in ipairs({ { -6, 2 }, { 5, 3 }, { -4, -1 }, { 7, 0 } }) do px(fx + d[1], fy + d[2], W.hi) end
end
-- water hyacinth rafts with lilac flower spikes in the shallows by the reeds
for _, p in ipairs({ { 312, 168 }, { 322, 182 }, { 336, 196 }, { 344, 208 }, { 298, 154 } }) do
  for q = -1, 1 do
    local lx, ly = p[1] + q * 3, p[2] + (q == 0 and -1 or 0)
    fill(c:ellipse(lx, ly, 2, 1), L.fern.base) px(lx - 1, ly - 1, L.fern.hi) px(lx + 1, ly + 1, L.fern.deep)
  end
  hline(p[1] - 4, p[1] + 4, p[2] + 2, T5)
  px(p[1], p[2] - 3, L.lav.hi) px(p[1] + 1, p[2] - 3, L.lav.base) px(p[1], p[2] - 4, L.lav.hi) px(p[1] + 1, p[2] - 2, L.lav.shade) px(p[1], p[2] - 2, L.gold.hi)
end

---------------------------------------------------------------- pink river dolphins (the loon's place) + a far one
do
  local lx, ly = 312, 148
  F.sprite({
    "........hhh.........",
    "......hhPPPhh.......",
    "....hhPPPPPPPhd.....",
    "..hhPPPPPPPPPPPd....",
    ".hPPePPPPPPPPPPPd...",
    "hhPPPPpPPPPPPPPPPd..",
    "bbbbppppppppppppppd.",
  }, lx, ly, { h = L.petal.hi, P = L.petal.base, p = L.petal.shade, d = L.petal.deep, b = L.petal.shade, e = L.timber.edge })
  hline(lx + 1, lx + 19, ly + 7, W.hi) hline(lx - 2, lx + 22, ly + 8, T5) hline(lx - 6, lx, ly + 7, W.hi)
  for _, d in ipairs({ { -3, 5 }, { 22, 6 }, { 24, 4 } }) do px(lx + d[1], ly + d[2], W.hi) end
end
F.depth(1)
F.sprite({ "..pPPd..", ".pPPPPd.", "pPPPPPPd" }, 346, 131, { p = L.petal.shade, P = L.petal.base, d = L.petal.deep })
hline(344, 356, 134, T1)

---------------------------------------------------------------- far water: a dugout with a paddler, the fish weir, the stilt fishing hut
F.depth(2)
do
  local fx, fy = 302, 138
  local _, ghx, ghy = F.gnome(fx, fy - 1, { small = true, hat = L.awnA, coat = L.wall2, arm = "out", noShadow = true })
  dugout(fx - 10, fx + 10, fy, { short = true })
  local pad = line({ { fx + 12, fy - 10 }, { fx + 4, fy + 3 } })
  fill(pad, L.board.shade) fill(c:ellipse(fx + 3, fy + 4, 1, 2), L.board.base)
  for k = 1, 3 do hline(fx - 9 + k, fx + 9 - k, fy + 6 + k * 2, T4) end
  hline(fx + 2, fx + 6, fy + 7, W.hi)
end
-- the bamboo fish weir: a fence of stakes angled across the current, a standing trap at its point
do
  local prev
  for k = 0, 12 do
    local sx, sy = 330 + k * 3, 126 + floor(k * 1.2)
    local h = 5 + (k % 2)
    vline(sx, sy - h, sy, (k % 2 == 0) and L.timber.base or L.timber.shade) px(sx, sy - h, L.bamboo.hi) px(sx, sy - h + 1, L.bamboo.base)
    px(sx, sy + 1, T4)
    if prev then line({ { prev[1], prev[2] - 2 }, { sx, sy - 2 } }):each(function(x2, y2) if x2 ~= sx and x2 ~= prev[1] then px(x2, y2, rattan.base) end end) end
    prev = { sx, sy }
  end
  standingTrap(372, 143, 9)
  hline(368, 377, 144, T4)
end
F.depth(2)
local function fishingHut()
  local top, cx, wallM, roofM = F.building{ x0 = 388, x1 = 444, yb = 140, wh = 26, rh = 20, wall = L.bamboo, roof = L.roof,
    noShadow = true, noFrame = true, noAttic = true }
  F.bambooWall(wallM:copy():clip(rect(388, top + 4, 444, 140)), L.bamboo, 3, false, 44)
  local posts = union(rect(388, top + 4, 389, 140), rect(443, top + 4, 444, 140), rect(388, 138, 444, 140))
  part(posts, L.timber, { nopop = true, noshade = true })
  F.window(424, 120, 430, 125, L.timber)
  -- big water door, the dark water inside, a dugout stowed
  local d = rect(396, 124, 416, 140) fill(d, L.soil.deep) fill(rect(398, 134, 414, 140), W.deep)
  hline(399, 413, 136, W.edge) hline(398, 414, 124, L.timber.hi) vline(396, 124, 140, L.timber.base) vline(416, 124, 140, L.timber.shade)
  hline(400, 412, 132, L.redbark.base) hline(401, 411, 133, L.redbark.shade) px(400, 131, L.redbark.hi) px(412, 131, L.redbark.base)
  -- a fish trap and a gourd hanging on the wall
  fishTrap(434, 136, 7, false)
  px(421, 129, L.gold.base) px(420, 128, L.gold.hi) px(421, 128, L.gold.base) px(420, 130, L.gold.shade) px(421, 130, L.gold.shade) px(421, 127, rattan.deep)
  -- bamboo stilts in the water
  local piles = HP.mask()
  for x2 = 390, 442, 8 do piles:add(rect(x2, 141, x2 + 1, 150)) end
  rimOf(piles, L.timber) part(piles, L.bamboo, { nopop = true, noshade = true })
  piles:each(function(x2, y2) if y2 % 5 == 0 then px(x2, y2, L.bamboo.deep) end if y2 > 146 and hash(x2, y2, 86) < .5 then px(x2, y2, L.moss.shade) end end)
  for x2 = 390, 442, 8 do for y2 = 152, 160, 2 do px(x2, y2, T5) end end
  for y2 = 152, 158, 2 do hline(392, 440, y2, (y2 % 4 == 0) and T4 or T3) end
  -- a hammock slung under the eave on the left
  for x2 = 378, 388 do local y2 = 132 + floor(3 * sin((x2 - 378) / 10 * pi) + .5) px(x2, y2, L.awnA.base) px(x2, y2 + 1, L.awnA.shade) end
  vline(378, 126, 132, L.timber.base)
  F.smoke(422, top - 16, 5, .7, 2)
end
fishingHut()
F.depth(0)
-- mist lying on the water: long soft banks, ragged at the ends, veiling the far bank and the hut stilts
for _, b in ipairs({ { 270, 400, 117, 2 }, { 300, 479, 121, 2 }, { 380, 479, 150, 2 }, { 374, 430, 141, 1 } }) do
  for y2 = b[3], b[3] + b[4] - 1 do
    for x2 = b[1], b[2] do
      local edge = math.min(x2 - b[1], b[2] - x2)
      if lake:has(x2, y2) or y2 < WL then
        if hash(x2 // 5, y2, 87) < .75 and hash(x2, y2, 88) < math.min(1, edge / 18 + .25) then
          px(x2, y2, (y2 + x2 // 7) % 2 == 0 and L.mist2 or L.mist)
        end
      end
    end
  end
end

---------------------------------------------------------------- the bamboo landing, moored dugout, lantern pole, fisher gnome
F.depth(3)
local deck = rect(300, 178, 470, 185)
local face = rect(300, 186, 470, 188)
local piles = HP.mask()
for x2 = 312, 466, 18 do piles:add(rect(x2, 189, x2 + 2, 206)) end
for x2 = 312, 466, 18 do for y2 = 208, 220, 3 do if lake:has(x2, y2) and lake:has(x2 + 1, y2 + 1) then px(x2, y2, W.deep) px(x2 + 1, y2 + 1, T5) end end end
rimOf(union(deck, face, piles), L.timber)
part(piles, L.timber, { nopop = true, noshade = true })
piles:each(function(x2, y2)
  if y2 > 197 and hash(x2, y2, 90) < .55 then px(x2, y2, y2 > 201 and L.moss.shade or L.moss.base) end
  if (y2 == 191 or y2 == 192) then px(x2, y2, rattan.base) end -- rattan bindings
end)
for x2 = 312, 466, 18 do hline(x2, x2 + 2, 203, W.hi) end
-- split-bamboo slats across the deck, nodes staggered, lashed to two long poles
part(deck, L.board)
F.bambooWall(deck, L.board, 3, false, 21)
for _, py in ipairs({ 178, 184 }) do
  hline(300, 470, py, L.bamboo.hi) hline(300, 470, py + 1, L.bamboo.shade)
  for x2 = 300, 470 do if (x2 + py) % 23 == 0 then px(x2, py, L.bamboo.deep) px(x2, py + 1, L.bamboo.deep) end end
end
for x2 = 304, 468, 12 do px(x2, 179, rattan.base) px(x2 + 1, 179, rattan.shade) px(x2, 185, rattan.base) px(x2 + 1, 185, rattan.shade) end
F.shine(deck, .05, 92)
for x2 = 300, 470 do if (x2 // 3) % 2 == 0 then px(x2, 189, T5) end end
-- the deck edge: the ends of the bamboo poles, wet and mossy
part(face, L.bamboo, { nopop = true })
face:each(function(x2, y2) if y2 == 188 and hash(x2 // 2, 0, 92) < .5 then px(x2, y2, L.moss.shade) end if (x2 - 300) % 9 == 0 then px(x2, y2, L.bamboo.deep) end end)
dugout(368, 420, 212)
for k = 0, 3 do hline(368 + 6 + k, 420 - 6 - k, 219 + k * 2, T5) end
for k = 0, 2 do hline(378 + k * 2, 404 - k * 2, 220 + k * 2, mix(L.redbark.base, T4, .55)) end
-- a paddle laid across the dugout
fill(line({ { 380, 208 }, { 412, 212 } }), L.board.shade) fill(c:ellipse(413, 212, 3, 1), L.board.base) px(411, 211, L.board.hi)
fill(line({ { 366, 208 }, { 360, 189 } }), rattan.shade) -- mooring rope
-- a caiman's eyes and snout watching from the water by the landing
F.sprite({ "..kK......kK.", ".GgGG.g.g.GgG", "GgGgGgGgGgGgG" }, 424, 195, { k = L.gold.hi, K = L.timber.edge, G = L.mossGround.hi, g = L.mossGround.shade })
hline(422, 437, 198, W.hi) hline(424, 435, 199, T5) px(420, 197, W.hi) px(439, 197, W.hi)
-- bamboo lantern pole at the end of the landing, a kingfisher on top
local lp = rect(460, 140, 461, 177) rimOf(lp, L.timber) part(lp, L.bamboo, { nopop = true, noshade = true })
lp:each(function(x2, y2) if y2 % 7 == 0 then px(x2, y2, L.bamboo.deep) end end)
local arm = rect(452, 140, 461, 141) fill(arm, L.bamboo.base) hline(452, 461, 140, L.bamboo.hi)
local lam = c:rrect(449, 143, 456, 152, 2) rimOf(lam, L.timber) fill(lam, L.glow.base)
lam:each(function(x2, y2) if (y2 - 143) % 3 == 0 then px(x2, y2, L.glow.shade) end end)
px(451, 145, L.glow.hi) px(451, 146, L.glow.hi) vline(456, 145, 151, L.glow.shade) vline(452, 142, 142, L.timber.deep)
F.sprite({ "..BB..", ".BBBe=", "BBWW..", ".OOO..", "..OO..", "..k..." }, 457, 133,
  { B = "#2e8ab0", e = L.timber.edge, ["="] = L.timber.deep, W = L.awnB.hi, O = L.produce.base, k = L.timber.edge })
-- fisher gnome on an upturned basket, a bamboo rod out over the water, a float bobbing on the line
do
  local bk = c:rrect(424, 171, 436, 177, 2) rimOf(bk, rattan) part(bk, rattan, { nopop = true })
  bk:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, rattan.shade) end end)
end
local _, fhx, fhy = F.gnome(430, 171, { hat = L.awnA, coat = L.leaf, arm = "out", noShadow = true })
local rod = line({ { fhx, fhy }, { 448, 152 }, { 452, 146 } })
fill(rod, L.bamboo.shade) rod:each(function(x2, y2) if (x2 + y2) % 5 == 0 then px(x2, y2, L.bamboo.deep) end end)
vline(452, 147, 176, L.awnB.shade) vline(452, 189, 213, L.awnB.shade) fill(rect(451, 213, 453, 215), L.awnA.base) px(451, 213, L.awnA.hi) px(452, 215, L.awnB.hi)
for k = 0, 2 do hline(448 - k * 2, 456 + k * 2, 217 + k * 2, W.hi) end
jar(316, 177, 10, L.soil)
-- a basket of fish on the deck
do
  local b = poly{ { 328, 170 }, { 342, 170 }, { 340, 177 }, { 330, 177 } }
  rimOf(b, rattan) part(b, rattan) b:each(function(x2, y2) if (x2 - y2) % 3 == 0 then px(x2, y2, rattan.shade) end end)
  for k = 0, 3 do local fx = 330 + k * 3 fill(c:ellipse(fx, 169, 2, 1), L.stone.hi) px(fx + 2, 169, L.gold.shade) px(fx - 1, 169, L.apple.base) end
end
-- a hand of bananas and a coconut cup on the deck
for k = 0, 3 do local bx = 404 + k * 2 vline(bx, 172, 176, L.gold.base) px(bx, 172, L.gold.hi) px(bx, 176, L.gold.shade) px(bx + 1, 175, L.gold.shade) end
hline(404, 410, 177, L.vine.deep) px(403, 174, L.vine.shade)
do local cup = c:ellipse(346, 175, 2, 2) rimOf(cup, L.soil) fill(cup, L.soil.base) px(345, 174, L.soil.hi) hline(344, 348, 173, L.awnB.hi) end

---------------------------------------------------------------- shore wedge: the tiger-heron in a red gnome hat at the fish basket (quirk)
F.eraseGround(rect(300, 236, 324, 251)) -- keep the basket's silhouette clear
-- a big elephant-ear leaf behind the heron, so its rufous neck reads against green
F.bigLeaf(304, 252, 24, -pi * .62, L.foliage, 35, 9, { heart = true })
F.bigLeaf(312, 250, 16, -pi * .35, L.leaf, 36, 6, { heart = true })
do
  local bk = poly{ { 303, 252 }, { 319, 252 }, { 316, 264 }, { 306, 264 } }
  rimOf(bk, rattan) part(bk, rattan)
  bk:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, rattan.shade) elseif (y2 - 252) % 4 == 2 then px(x2, y2, rattan.deep) end end)
  hline(303, 319, 252, rattan.hi)
  for k = 0, 3 do local fx = 306 + k * 3 fill(rect(fx, 248 - (k % 2), fx + 1, 252), L.stone.hi) px(fx, 248 - (k % 2), L.leaf.shade) px(fx + 1, 250, L.apple.base) end
end
F.shadowM(c:ellipse(294, 263, 10, 1))
F.sprite({
  ".............kkkk...............",
  "...........kkwwwwk..............",
  "..............wwwwwyyyy.........",
  "..............wwwewyyyyyyy......",
  "...............wwwwYYYYYYYYYff..",
  "...............wSww........fFff.",
  "...............wwSw.........ff..",
  "..............wwSw..............",
  ".............wwSw...............",
  "............wwSkw...............",
  "............wSww................",
  "...........wwSkw................",
  "...........wSww.................",
  "...........wwSw.................",
  ".....GGGGGgwwSw.................",
  "...GGGGgggggwww.................",
  "..GGggggggggggw.................",
  ".Gggggggdddgggg.................",
  ".gggggdddddggggg................",
  "kgggddddddddgggg................",
  "kkggdddDDddddggd................",
  ".kkgdddDDDdddddd................",
  "..kkddDDDDDdddd.................",
  "...kkdDDDDDddd..................",
  ".....DDDDDDdd...................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  "........l..l....................",
  ".......ll.ll....................",
  "......l.l.l.l...................",
}, 284, 230, { k = "#3a3438", w = heron.hi, S = L.awnB.hi, e = L.gold.hi, y = L.gold.hi, Y = L.gold.shade, f = L.stone.hi, F = L.leaf.shade,
  G = hbody.hi, g = hbody.base, d = hbody.shade, D = hbody.deep, l = L.gold.deep })
-- barred rufous neck, then the red gnome hat flopping back off the crest
for y2 = 233, 244, 2 do for x2 = 294, 302 do if c:get(x2, y2) == heron.hi then px(x2, y2, heron.base) end end end
for y2 = 247, 252 do for x2 = 286, 298 do if c:get(x2, y2) == hbody.base and (x2 + y2) % 3 == 0 then px(x2, y2, hbody.shade) end end end
px(298, 231, heron.hi) px(299, 232, heron.hi) px(300, 232, heron.hi)
local hat = poly{ { 295, 230 }, { 302, 230 }, { 300, 226 }, { 297, 222 }, { 292, 220 }, { 294, 224 } }
rimOf(hat, L.awnA) part(hat, L.awnA, { nopop = true })
hline(295, 302, 230, L.awnA.deep) px(297, 225, L.awnA.hi) px(298, 227, L.awnA.hi) px(296, 226, L.awnA.hi)
fill(c:ellipse(291, 220, 1, 1), L.awnB.hi) -- pompom
-- coiled rattan rope + a stone anchor lashed in a rattan cradle
local coil = c:ellipse(354, 248, 9, 4) rimOf(coil, rattan) part(coil, rattan) fill(c:ellipse(354, 248, 4, 1), rattan.deep)
for k = 0, 2 do c:ellipse(354, 248, 8 - k * 2, 3 - k // 2):edge():each(function(x2, y2) if y2 > 247 then px(x2, y2, rattan.shade) end end) end
do
  local st = F.rock(336, 245, 7, 9) F.shine(st, .12, 93) F.moss(st, .15, 94)
  for _, ry in ipairs({ 239, 242 }) do hline(330, 342, ry, rattan.base) px(330, ry, rattan.deep) end
  vline(336, 228, 237, rattan.shade) vline(337, 229, 237, rattan.deep)
  fill(c:ellipse(336, 228, 2, 2):cut(c:ellipse(336, 228, 1, 1)), rattan.base)
end
F.moss(F.rock(368, 262, 9, 8), .32, 94)
F.moss(F.rock(326, 268, 6, 5), .3, 95)
for _, f in ipairs({ { 372, 250, 7 }, { 346, 264, 6 }, { 276, 248, 6 }, { 362, 234, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(292, 214, L.produce, true) F.mushroom(298, 216, L.produce) F.mushroom(287, 216, L.apple)
F.bigLeaf(268, 236, 13, -pi * .7, L.foliage, 31, 5, { heart = true, stem = { 272, 248 } })
F.bigLeaf(274, 240, 11, -pi * .35, L.leaf, 32, 4, { heart = true, stem = { 273, 250 } })
F.heliconia(352, 238, 16, 33)

---------------------------------------------------------------- left: the fisher's bamboo hut (green palm thatch), fish-drying rack
F.depth(1)
F.tree(84, 128, 38, 3)
F.tree(10, 134, 40, 1)
local ctop, ccx, cwall, croof = F.building{ x0 = 20, x1 = 70, yb = 136, wh = 32, rh = 22, wall = L.bamboo, roof = L.roof2, noFrame = true }
F.bambooWall(cwall:copy():clip(rect(20, ctop + 4, 70, 136)), L.bamboo, 3, true, 45)
part(union(rect(20, ctop + 4, 21, 136), rect(69, ctop + 4, 70, 136)), L.timber, { nopop = true, noshade = true })
F.window(26, 112, 32, 118, L.timber) F.door(48, 122, 55, 135, L.timber)
F.smoke(36, 84, 6, .5, 2)
-- a fish-shaped carved sign on the hut, a string of gourd floats under the eave
local fs = c:ellipse(37, 128, 6, 3):add(poly{ { 42, 128 }, { 47, 124 }, { 47, 132 } })
rimOf(fs, L.accent) part(fs, L.accent) px(33, 127, L.timber.edge) px(36, 127, L.gold.hi) px(39, 129, L.gold.hi)
for k = 0, 5 do local gx = 60 + k * 2 px(gx, 109 + (k % 2), L.gold.base) px(gx, 108 + (k % 2), L.gold.hi) end
local function fishRack(x0, x1, yb)
  local posts = rect(x0, yb - 22, x0 + 1, yb):add(rect(x1, yb - 22, x1 + 1, yb))
  local bar = rect(x0 - 2, yb - 22, x1 + 3, yb - 21)
  F.shadow(x0, x1, yb, 6, 3)
  rimOf(union(posts, bar), L.timber) part(posts, L.bamboo, { nopop = true, noshade = true }) part(bar, L.bamboo, { nopop = true, noshade = true })
  posts:each(function(x2, y2) if y2 % 6 == 0 then px(x2, y2, L.bamboo.deep) end end)
  -- a palm-leaf awning over the rack
  local aw = poly{ { x0 - 4, yb - 23 }, { x1 + 5, yb - 23 }, { x1 + 2, yb - 27 }, { x0 - 1, yb - 27 } }
  rimOf(aw, L.roof) F.palmThatch(aw, L.roof, yb - 27, 9999, 71)
  for x2 = x0 - 4, x1 + 5 do if hash(x2, 1, 72) < .5 then px(x2, yb - 22, L.roof.deep) end end
  for x2 = x0 + 4, x1 - 2, 5 do
    vline(x2, yb - 20, yb - 19, rattan.deep)
    local fsh = poly{ { x2 - 1, yb - 18 }, { x2 + 2, yb - 18 }, { x2 + 2, yb - 9 }, { x2, yb - 7 }, { x2 - 1, yb - 9 } }
    local tl = poly{ { x2 - 2, yb - 7 }, { x2 + 3, yb - 7 }, { x2, yb - 9 } }
    local bass = (x2 // 5) % 2 == 0
    fill(union(fsh, tl), bass and L.gold.shade or L.stone.base) vline(x2 + 2, yb - 18, yb - 10, bass and L.leaf.deep or L.stone.deep) px(x2, yb - 16, L.timber.edge)
    if bass then px(x2, yb - 13, L.leaf.shade) px(x2 + 1, yb - 11, L.leaf.shade) px(x2, yb - 8, L.apple.base) end
  end
end
fishRack(96, 150, 140)
-- a stack of bamboo poles and coconuts against the hut, a mossy stump with a machete in it
F.depth(2)
for k = 0, 3 do local e = c:ellipse(76 + k * 5, 146, 2, 2) c:rim(e, L.bamboo.edge) fill(e, L.bamboo.base) px(75 + k * 5, 145, L.bamboo.hi) px(76 + k * 5, 146, L.soil.deep) end
for k = 0, 2 do local e = c:ellipse(78 + k * 5, 142, 2, 2) c:rim(e, L.bamboo.edge) fill(e, L.bamboo.base) px(77 + k * 5, 141, L.bamboo.hi) px(78 + k * 5, 142, L.soil.deep) end
F.depth(1)
for _, f in ipairs({ { 18, 140, 4 }, { 74, 139, 4 }, { 88, 142, 3 } }) do F.fern(f[1], f[2], f[3]) end
F.depth(3)

---------------------------------------------------------------- left hero: bamboo net frame with gourd floats
local function netFrame(x0, x1, yt, yb)
  local posts = rect(x0, yt, x0 + 3, yb):add(rect(x1 - 3, yt, x1, yb)):add(rect((x0 + x1) // 2 - 1, yt, (x0 + x1) // 2 + 1, yb))
  local bar = rect(x0 - 3, yt, x1 + 3, yt + 3)
  F.shadow(x0, x1, yb, 14, 5)
  rimOf(union(posts, bar), L.timber)
  part(posts, L.bamboo, { nopop = true }) part(bar, L.bamboo, { nopop = true })
  posts:each(function(x2, y2) if y2 % 9 == 0 then px(x2, y2, L.bamboo.deep) elseif y2 % 9 == 1 and x2 % 4 == x0 % 4 then px(x2, y2, L.shine) end end)
  bar:each(function(x2, y2) if x2 % 11 == 0 then px(x2, y2, L.bamboo.deep) end end)
  hline(x0 - 3, x1 + 3, yt, L.bamboo.hi)
  -- rattan lashings where bar meets post
  for _, lx in ipairs({ x0, (x0 + x1) // 2 - 1, x1 - 3 }) do for k = 0, 3 do px(lx + k, yt + 4, rattan.base) px(lx + k, yt + 5, rattan.deep) end end
  F.moss(posts:copy():clip(rect(x0, yb - 14, x1, yb)), .2, 97)
  local function sag(x2) local t = ((x2 - x0) % ((x1 - x0) // 2)) / ((x1 - x0) // 2) return floor(yb - 14 - 10 * sin(t * pi)) end
  for x2 = x0 + 4, x1 - 4 do
    local y1 = sag(x2)
    for y2 = yt + 6, y1 do
      local a, b = (x2 + y2) % 5, (x2 - y2) % 5
      if a == 0 or b == 0 then px(x2, y2, L.board.shade) elseif hash(x2, y2, 2) < .06 then px(x2, y2, L.board.base) end
    end
    px(x2, y1, L.board.deep)
    if x2 % 8 == 0 then -- a gourd float
      fill(rect(x2 - 1, y1 + 1, x2 + 1, y1 + 4), L.gold.base) px(x2 - 1, y1 + 1, L.gold.hi) px(x2 - 1, y1 + 2, L.gold.hi) px(x2 + 1, y1 + 4, L.gold.deep) px(x2, y1 + 4, L.gold.shade)
    end
  end
  -- weed and a leaf snagged in the net
  px(120, 170, L.leaf.base) px(121, 171, L.leaf.shade) px(160, 176, L.litter.base) px(161, 177, L.litter.shade)
end
netFrame(92, 192, 150, 214)
jar(110, 222, 14, L.soil) jar(124, 224, 11, L.needle)
-- basket of fish
local bk = poly{ { 160, 214 }, { 182, 214 }, { 179, 224 }, { 163, 224 } }
rimOf(bk, rattan) part(bk, rattan) bk:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, rattan.shade) end end)
for k = 0, 4 do local fx = 162 + k * 4 fill(c:ellipse(fx, 212, 2, 1), (k % 2 == 0) and L.stone.hi or L.gold.base) px(fx + 2, 212, L.leaf.shade) px(fx - 1, 212, L.apple.base) end
-- dugout paddles leaning (leaf-shaped blades)
fill(line({ { 194, 228 }, { 186, 176 } }, 2), L.board.base) fill(c:ellipse(186, 174, 3, 7), L.board.shade) px(185, 170, L.board.base) px(184, 172, L.board.hi)
fill(line({ { 199, 226 }, { 196, 186 } }, 1), L.timber.base) fill(c:ellipse(196, 183, 2, 5), L.redbark.base) px(195, 180, L.redbark.hi)
-- a coati sitting by the basket, ringed tail up, eyeing the fish
F.sprite({
  "..................r.",
  ".o...o...........rR.",
  ".occcco..........R..",
  "cceCccec.........rr.",
  "cccKKKccc.......R...",
  "..cmmmn.........r...",
  "..ccccc........R....",
  ".cccCccc......rR....",
  "ccCCcccccc...rR.....",
  "ccCcccccccccrR......",
  "cCcccccccccRr.......",
  "ccccccccccc.........",
  ".cccccccccc.........",
  "wc.cw..wc.cw........",
}, 143, 211, { o = L.timber.edge, c = L.litter.base, C = L.litter.shade, e = L.timber.edge, m = L.awnB.hi, n = L.timber.edge, K = L.timber.edge,
  r = L.ground.deep, R = L.litter.hi, w = L.awnB.base })
-- the ground between the fisher's hut and the net frame: a fish-drying mat, ferns and a mushroom ring
do
  local mat = poly{ { 56, 160 }, { 82, 160 }, { 86, 168 }, { 52, 168 } }
  rimOf(mat, L.timber) part(mat, rattan, { nopop = true })
  mat:each(function(x2, y2) if (x2 + y2) % 3 == 0 then px(x2, y2, rattan.shade) end end)
  for k = 0, 3 do local fx = 59 + k * 7 fill(c:ellipse(fx, 164, 3, 1), (k % 2 == 0) and L.stone.hi or L.gold.base) px(fx + 3, 164, L.apple.base) px(fx - 1, 163, L.timber.edge) end
  F.fern(52, 158, 5) F.fern(84, 158, 5) F.fern(70, 172, 4) F.fern(20, 160, 5)
  F.mushroom(48, 172, L.produce, true) F.mushroom(53, 174, L.produce)
  F.heliconia(26, 150, 13, 53)
end

---------------------------------------------------------------- bottom-left: big palm, a dugout being carved on trestles, resin pot, fish traps
F.palm(44, 206, 56, 6, { lean = -6 })
F.treeFern(16, 214, 26, 8)
jar(64, 210, 12, L.soil) jar(77, 212, 12, L.redbark) jar(70, 201, 10, L.needle)
local function carveDugout()
  -- an upright log hull, half hollowed: raised carved ends, the hollow dark with fresh pale chips at the cut
  local pts = { { 22, 228 }, { 30, 232 } }
  for x2 = 30, 128, 4 do pts[#pts + 1] = { x2, 232 } end
  pts[#pts + 1] = { 136, 228 } pts[#pts + 1] = { 134, 234 }
  for x2 = 128, 30, -4 do pts[#pts + 1] = { x2, 232 + floor(10 * sin((x2 - 24) / 110 * pi) ^ .5) } end
  pts[#pts + 1] = { 24, 234 }
  local hull = poly(pts)
  local tre = rect(36, 240, 38, 256):add(rect(110, 239, 112, 256)):add(rect(30, 252, 44, 253)):add(rect(104, 252, 118, 253))
  F.shadow(26, 136, 258, 6, 3)
  rimOf(union(hull, tre), L.timber)
  part(tre, L.timber, { nopop = true, noshade = true })
  part(hull, L.redbark)
  hull:each(function(x2, y2)
    local bot = 232 + floor(10 * sin((x2 - 24) / 110 * pi) ^ .5)
    if y2 > bot - 3 then px(x2, y2, L.redbark.deep) elseif y2 <= 234 then px(x2, y2, L.redbark.hi) end
    if hash(x2 // 3, y2, 99) < .1 then px(x2, y2, L.redbark.shade) end
    if x2 < 66 and y2 > 234 and y2 < bot - 3 and (x2 + y2) % 6 == 0 then px(x2, y2, L.redbark.shade) end -- adze marks
  end)
  -- the hollow: dark on the finished stern half, pale fresh wood where the gnome is still cutting
  for x2 = 32, 126 do
    local fresh = x2 > 92
    px(x2, 231, fresh and L.board.shade or L.timber.deep)
    if x2 > 36 and x2 < 122 then px(x2, 230, fresh and L.board.base or L.timber.shade) end
  end
  -- carved prow with a painted eye, a teal band
  hline(30, 128, 233, L.accent.base) hline(32, 126, 234, L.accent.shade)
  px(130, 230, L.awnB.hi) px(131, 230, L.timber.edge) px(22, 226, L.redbark.hi)
  -- wood chips on the ground
  for k = 0, 9 do px(84 + floor(hash(k, 1, 98) * 30), 256 + floor(hash(k, 2, 98) * 8), (k % 2 == 0) and L.board.hi or L.board.base) end
  -- a resin pot over a little fire
  local pot = c:ellipse(60, 254, 4, 4) rimOf(pot, L.iron) part(pot, L.soil) hline(56, 64, 250, L.timber.edge)
  fill(line({ { 62, 250 }, { 68, 244 } }), L.board.base)
  px(58, 259, L.glow.base) px(60, 259, L.glow.shade) px(62, 259, L.glow.base) px(59, 260, L.glow.hi) px(61, 260, L.produce.base)
  fishTrap(166, 250, 14, false) fishTrap(172, 263, 16, false) fishTrap(204, 262, 12, true)
  local _, thx, thy = F.gnome(144, 266, { hat = L.awnA, coat = L.roof2, arm = "up", flip = true })
  -- an adze raised over the prow
  fill(line({ { thx, thy + 2 }, { thx + 1, thy - 3 } }), L.timber.base)
  local blade = poly{ { thx - 1, thy - 4 }, { thx + 2, thy - 4 }, { thx - 2, thy - 1 } } c:rim(blade, L.iron.edge) fill(blade, L.iron.base) px(thx, thy - 4, L.iron.hi)
  for k = 0, 2 do px(132 - k * 2, 226 - k * 2, L.board.hi) end -- flying chips
end
carveDugout()
px(59, 247, L.mist2) px(61, 245, L.mist) px(60, 243, L.mist2) -- steam off the resin
for _, f in ipairs({ { 190, 254, 7 }, { 200, 238, 5 }, { 120, 268, 5 } }) do F.fern(f[1], f[2], f[3]) end
F.mushroom(196, 264, L.produce, true) F.mushroom(201, 266, L.produce)
F.orchid(8, 200, L.orchid, 2)
-- reeds, arrowhead leaves and gingers along the waterline, and in the corner by the landing foot
for k = 0, 13 do
  local rx = 298 + k * 3 + (k % 2) local ry = 168 + k * 3
  reed(rx, ry, 5 + floor(hash(k, 4, 3) * 7), k % 3)
end
for k = 0, 7 do reed(346 + k * 3, 218 + k + (k % 2), 6 + floor(hash(k, 5, 3) * 6), (k % 4 == 1) and 2 or 1) end
for k = 0, 4 do reed(270 + k * 3, 128 + k * 4, 4 + floor(hash(k, 6, 3) * 4), k == 2 and 1 or 0) end
F.bamboo(264, 140, 26, 3, 51)
-- signpost with a hanging fish board by the road
F.sign(206, 148, 18, 10, L.board)
F.moss(F.rock(222, 196, 6, 5), .35, 100)
F.fern(206, 176, 5) F.fern(214, 210, 6)
F.heliconia(282, 208, 14, 52)
-- butterflies: an orange-and-black heliconian and a yellow sulphur
F.sprite({ "OO.OO", "oOkOo", ".o.o." }, 208, 230, { O = L.produce.base, o = L.produce.deep, k = L.timber.edge }, { rim = false })
F.sprite({ "YY.YY", "yYkYy" }, 334, 222, { Y = L.gold.hi, y = L.gold.base, k = L.timber.edge }, { rim = false })
F.depth(0)
-- parrots and white egrets over the river
F.birds({ { 360, 60, 3, L.awnB.hi }, { 376, 52, 2, L.awnB.hi }, { 300, 76, 2, L.awnB.hi }, { 150, 50, 2, "#2e7a46" }, { 162, 56, 1, "#2e7a46" }, { 140, 58, 1, "#b03a36" } })
fill(c:ellipse(205, 153, 5, 2):add(poly{ { 209, 153 }, { 212, 150 }, { 212, 156 } }), L.accent.base) px(202, 152, L.timber.edge) px(203, 152, L.accent.hi)
F.finish()
