-- stage-rainforest v3: clear-day base backdrop (no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-rainforest" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local R6 = GX.ramp6

local EM1 = { hi = "#8ff070", base = "#2fb55a", shade = "#14845a", deep = "#0b4a46" }
local EM2 = { hi = "#6ee07a", base = "#1f9a58", shade = "#0f6a52", deep = "#08403e" }
local LIM = { hi = "#e4ff80", base = "#9ad848", shade = "#4ea84a", deep = "#1f6a46" }
local TEALL = { hi = "#7af0d0", base = "#2cb8a0", shade = "#17808a", deep = "#0c4a60" }
local BARK = { hi = "#b88a5c", base = "#82583a", shade = "#5a3a34", deep = "#33222a" }
local MOSS = { hi = "#a8e868", base = "#4cb046", shade = "#287a46", deep = "#144a40" }
local GROUND = { hi = "#6cba5c", base = "#3a9650", shade = "#24704c", deep = "#124440" }
local DIRT = { hi = "#d8a870", base = "#b07e54", shade = "#845a46", deep = "#523640" }
local HILL = { hi = "#7cc8a0", base = "#4ea088", shade = "#3a7e78", deep = "#2c5c64" }
local ORG = { hi = "#ffd070", base = "#ff8a2a", shade = "#c8501e", deep = "#6e2a22" }
local PINK = { hi = "#ffb0e0", base = "#f0509c", shade = "#b82c80", deep = "#5e1a56" }
local RED = { hi = "#ff9a80", base = "#e8503c", shade = "#b03038", deep = "#6e2038" }
local CREAM = { hi = "#fffaf0", base = "#f4ead8", shade = "#d0c0c0", deep = "#9a8aa0" }

-- clear sky, gentle gradient (no clouds)
GX.bands(c, 0, 138, { "#7cc4ee", "#98d4f4", "#b4e4f6", "#cdf0f4", "#d8f6e8", "#e4fae0" }, 4, .18)
-- tiny sun glare, upper left of centre
do
  local g = mk(); E(g, 150, 22, 7, 6); g = GX.rough(g, 5, 1)
  GX.lit(c, g, R6({ hi = "#fffbe0", base = "#fff2b0", shade = "#ffe48a", deep = "#f8d070" }), { R = 4, tex = .1, seed = 3, ink = false })
end

-- far misty trunks
for _, t in ipairs{ { 30, 14 }, { 130, 10 }, { 290, 12 }, { 380, 10 }, { 420, 12 } } do
  local far = { hi = "#8cd0b0", base = "#68b8a0", shade = "#58a090", deep = "#488880" }
  GX.trunk(c, t[1], t[1] + t[2] - 1, 40, 150, far, t[1], { noink = true })
end
-- far hills
GX.ground(c, function(x) return 118 + floor(6 * sin(x / 33) + 3 * sin(x / 13)) end, HILL, 5, { top = .78, fall = .3, tex = .3 })
-- cliff and waterfall (centre)
do
  local cl = mk()
  for x = 196, 286 do
    local top = 60 + floor((GX.vn(x, 0, 6, 9) - .5) * 8) + floor(abs(x - 241) * .4)
    for y = top, 140 do cl:set(x, y) end
  end
  cl = GX.rough(cl, 31, 1)
  GX.lit(c, cl, R6({ hi = "#8ab8a0", base = "#5e9488", shade = "#46747a", deep = "#34545e" }), { R = 14, tex = .5, sc = 3, seed = 31, ink = false })
  -- tree-top crown along the cliff
  for i = 0, 6 do GX.foliage(c, 206 + i * 12, 58 + floor(abs(i - 3) * 4), 12, 7, ({ EM1, EM2, LIM })[1 + i % 3], 300 + i) end
  for x = 230, 252 do
    local top = 66 + floor(abs(x - 241) * .3)
    for y = top, 140 do
      local v = GX.vn(x * 2.5, y * .12, 1.6, 5)
      c:px(x, y, v > .6 and "#fdfdf4" or (v > .3 and "#d8f4ff" or "#a8dcf0"))
    end
  end
  for x = 218, 266 do for y = 136, 146 do   -- mist pool
    if GX.vn(x, y, 3, 8) > .3 and abs(x - 241) < 20 + (y - 136) then c:px(x, y, (y % 2 == 0) and "#fdfdf4" or "#d8f4ff") end
  end end
end
-- mid rainforest wall behind the clearing
GX.ground(c, function(x) return 144 + floor(5 * sin(x / 21 + 1) + 2 * sin(x / 8)) end, { hi = "#58b078", base = "#388a60", shade = "#256a52", deep = "#16463e" }, 9, { top = .8, fall = .5, tex = .4, sc = 5 })
-- ground
GX.ground(c, function(x) return 166 + floor(3 * sin(x / 27 + 2) + 1.5 * sin(x / 9)) end, GROUND, 7, { top = .86, fall = .6, tex = .34, sc = 7 })

-- walkable dirt trail (calm), wide and soft-edged
local function trail_c(x) return 206 + floor(5 * sin(x / 60 + 1) + 2 * sin(x / 19)) end
local tm = mk()
for x = 0, 479 do for y = trail_c(x) - 17, trail_c(x) + 17 do tm:set(x, y) end end
tm = GX.rough(tm, 12, 2)
tm:each(function(x, y)
  local t = (y - (trail_c(x) - 17)) / 34
  local v = .78 - abs(t - .4) * .4 + (GX.vn(x, y, 6, 2) - .5) * .4 + (GX.vn(x, y, 2, 5) - .5) * .1
  c:px(x, y, R6(DIRT)[GX.idx(v)])
end)
for i = 0, 70 do   -- pebbles and roots flecks on the trail
  local x = 4 + floor(H(i, 1, 2) * 470); local y = trail_c(x) - 12 + floor(H(i, 2, 2) * 24)
  if tm:has(x, y) then
    local col = (i % 3 == 0) and DIRT.hi or ((i % 3 == 1) and DIRT.deep or DIRT.shade)
    c:px(x, y, col); c:px(x + 1, y, col); if i % 3 == 0 then c:px(x, y + 1, DIRT.shade) end
  end
end

-- dappled light patches on grass (no shafts)
for i = 0, 10 do
  local x, y = 20 + floor(H(i, 51, 1) * 440), 170 + floor(H(i, 53, 1) * 90)
  if not tm:has(x, y) then local m = mk(); E(m, x, y, 9 + i % 4 * 3, 2); m = GX.rough(m, i, 1); c:fillMask(m, GX.mix(GROUND.base, GROUND.hi, .5)) end
end

-- canopy corners and top
local CL = { { 20, 12, 56, 26 }, { 96, 4, 48, 18 }, { 160, 0, 44, 14 }, { 300, 2, 48, 16 }, { 360, 8, 48, 20 }, { 430, 10, 54, 26 }, { 470, 30, 30, 18 }, { 14, 42, 30, 12 } }
local CAN = { EM1, EM2, LIM, EM2, TEALL, EM1, EM2, LIM }
for i, g in ipairs(CL) do GX.foliage(c, g[1], g[2], g[3], g[4], CAN[i], 400 + i * 13) end

-- giant buttress trunks, left and right, with moss
GX.trunk(c, 10, 44, 20, 178, BARK, 11, { moss = MOSS })
GX.trunk(c, 440, 476, 14, 182, BARK, 13, { moss = MOSS })
-- hanging vines
local function vine(x, y0, len, seed)
  for y = y0, y0 + len do
    local vx = x + floor(sin(y / 9 + seed) * 2)
    c:px(vx, y, "#145a3c"); c:px(vx + 1, y, "#1f8a50")
    if (y - y0) % 11 == 6 then
      local dir = ((y + seed) % 2 == 0) and 1 or -1
      for k = 1, 3 do c:px(vx + dir * k, y + k // 2, "#2fb55a"); c:px(vx + dir * k, y + k // 2 + 1, "#14845a") end
      c:px(vx + dir * 4, y + 2, "#8ff070")
    end
  end
end
for i, x in ipairs{ 54, 66, 78, 116, 130, 330, 346, 410, 424 } do vine(x, 22 + (i % 3) * 5, 34 + floor(H(i, 7, 1) * 40), i * 3) end

-- orchids on trunks
local function orchid(x, y, R)
  for i = 0, 3 do c:px(x + i, y - i * 2, MOSS.shade); c:px(x + i, y - i * 2 + 1, MOSS.deep) end
  for _, p in ipairs{ { 3, -6 }, { 1, -3 }, { 5, -8 }, { -1, 0 } } do
    local m = mk(); E(m, x + p[1], y + p[2], 2, 2)
    GX.lit(c, m, R6(R), { R = 2, tex = 0, ink = INK })
    c:px(x + p[1], y + p[2], "#ffe38a")
  end
end
orchid(30, 110, PINK); orchid(446, 96, ORG); orchid(458, 134, PINK)

-- upper-edge details only (the bottom 90 px stays calm)
local function frond(x, y, dir, len)
  for i = 0, 6 do
    local ang = (-80 + i * 24) * dir
    local l = len - abs(i - 3) * 3
    local ex, ey = x + floor(l * sin(ang / 57.3)), y - floor(l * cos(ang / 57.3))
    local mx, my = (x + ex) // 2 - dir * 3, (y + ey) // 2 - 4
    local fr = c:poly{ { x, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 4 } }
    GX.lit(c, fr, R6(i % 2 == 0 and EM1 or LIM), { R = 3, tex = .25, sc = 2, seed = i, rimlight = true })
  end
end
frond(60, 176, 1, 24); frond(414, 178, -1, 22)
local function banana(x, y, len, dir, R, seed)
  local m = mk()
  for t = 0, len do
    local px_ = x + dir * t
    local py_ = y - floor(sin(t / len * 1.6) * len * .34) + floor((t / len) ^ 2 * 8)
    local w = floor(sin(t / len * 3.0) * 5) + 1
    for yy = py_ - w, py_ + w do m:set(px_, yy) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, R6(R), { R = 4, tex = .3, sc = 3, seed = seed, rimlight = true })
  for t = 0, len do c:px(x + dir * t, y - floor(sin(t / len * 1.6) * len * .34) + floor((t / len) ^ 2 * 8), R.deep) end
end
banana(46, 172, 40, 1, LIM, 43); banana(436, 170, 38, -1, EM1, 44)

-- calm ground: tufts, flowers, leaf litter, mushrooms (sparse, y>150)
local function blocked(x, y) return x < 50 and y < 180 or x > 436 and y < 184 end
for i = 0, 26 do
  local x, y = 10 + floor(H(i, 61, 1) * 460), 172 + floor(H(i, 63, 1) * 94)
  if not blocked(x, y) and not tm:has(x, y) then
    GX.tuft(c, x, y, y > 230 and { hi = GROUND.base, base = GROUND.shade, shade = GROUND.deep, deep = GROUND.deep } or { hi = LIM.hi, base = EM1.base, shade = EM2.shade, deep = EM2.deep })
  end
end
for i = 0, 9 do
  local x, y = 20 + floor(H(i, 41, 1) * 440), 176 + floor(H(i, 43, 1) * 86)
  if not blocked(x, y) and not tm:has(x, y) then GX.flower(c, x, y, ({ "#ff6cb0", "#ff9a3a", "#c27cff", "#ffe38a" })[1 + i % 4]) end
end
local LIT = { "#e8b030", "#d87828", "#a8522c", "#c4d860", "#7a4a30" }
for i = 0, 60 do
  local x, y = floor(H(i, 31, 1) * 480), 172 + floor(H(i, 37, 1) * 96)
  if not blocked(x, y) then
    local col = LIT[1 + i % #LIT]
    c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y + 1, GX.mix(col, "#2b1c26", .3))
  end
end
local function mushroom(x, y, s)
  local st = c:rect(x - 1, y - 4 * s, x + 1, y); GX.lit(c, st, R6(CREAM), { R = 2, tex = .1, seed = x, rimlight = true })
  local cap = mk(); E(cap, x, y - 5 * s, 4 * s, 3 * s); cap = GX.rough(cap, x, 1)
  GX.lit(c, cap, R6(RED), { R = 3 * s, tex = .2, seed = x + 1, rimlight = true })
  c:px(x - 1, y - 6 * s, "#fffaf0"); c:px(x + 2, y - 5 * s, "#fffaf0")
end
mushroom(96, 250, 1); mushroom(104, 254, 1); mushroom(392, 248, 1)
-- quirk: a tiny red-eyed tree frog on a mossy stone by the trail
do
  local x, y = 330, 238
  local st = mk(); E(st, x, y, 8, 4); st = GX.rough(st, 7, 1)
  GX.lit(c, st, R6({ hi = "#b4c0b8", base = "#7a9488", shade = "#546e70", deep = "#34484e" }), { R = 4, tex = .4, seed = 5, rimlight = true })
  for k = -6, 0 do c:px(x + k, y - 3, MOSS.base); c:px(x + k, y - 2, MOSS.shade) end
  local FR = { hi = "#b8ff60", base = "#4ed048", shade = "#228a48", deep = "#0f4a3c" }
  local b = mk(); E(b, x + 2, y - 6, 3, 2)
  GX.lit(c, b, R6(FR), { R = 2, tex = .1, seed = 8, rimlight = true })
  c:px(x + 1, y - 9, INK); c:px(x + 3, y - 9, INK); c:px(x + 1, y - 8, "#ff2a3a"); c:px(x + 3, y - 8, "#ff2a3a")
end

c:save{ aseprite = d.."/out/stage-rainforest.aseprite", png = d.."/out/stage-rainforest.png", scale = 1 }
