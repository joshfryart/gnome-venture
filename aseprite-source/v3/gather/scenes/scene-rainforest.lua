-- scene-rainforest: DAY palette, 480x270. Satchel zone x286..436,y60..216 kept calm.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "rainforest" }
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function mk() return HP.mask() end

local EM1 = { hi = "#8ff070", base = "#2fb55a", shade = "#14845a", deep = "#0b4a46" }
local EM2 = { hi = "#6ee07a", base = "#1f9a58", shade = "#0f6a52", deep = "#08403e" }
local LIM = { hi = "#e4ff80", base = "#9ad848", shade = "#4ea84a", deep = "#1f6a46" }
local TEALL = { hi = "#7af0d0", base = "#2cb8a0", shade = "#17808a", deep = "#0c4a60" }
local PINK = { hi = "#ffb0e0", base = "#f0509c", shade = "#b82c80", deep = "#5e1a56" }
local ORG = { hi = "#ffd070", base = "#ff8a2a", shade = "#c8501e", deep = "#6e2a22" }
local PUR = { hi = "#d8a8ff", base = "#9a52d8", shade = "#6430a0", deep = "#341860" }
local BARK = { hi = "#b88a5c", base = "#82583a", shade = "#5a3a34", deep = "#33222a" }
local MOSS = { hi = "#a8e868", base = "#4cb046", shade = "#287a46", deep = "#144a40" }
local GROUND = { hi = "#4aa060", base = "#2a7a4e", shade = "#1a5444", deep = "#0e3236" }
local HILL = { hi = "#7cc8a0", base = "#4ea088", shade = "#3a7e78", deep = "#2c5c64" }
local BG = { "#d8f8e0", "#bff0d0", "#a0e4c0", "#80d4b0", "#60c0a0", "#48a890" }
local SHADOW = "#12403a"

---------------------------------------------------------------- backdrop
local function shaft(x, y)
  for i = 0, 5 do
    local x0 = 50 + i * 78
    local t = y / 150
    if x >= x0 + t * 50 and x <= x0 + 16 + t * 60 then return true end
  end
  return false
end
GX.bands(c, 0, 150, BG, 4, .22, shaft, "#ffffd8")
-- far trunks (misty, no ink)
for _, t in ipairs{ { 20, 16 }, { 140, 12 }, { 255, 14 }, { 345, 10 }, { 410, 14 } } do
  local far = { hi = "#8cd0b0", base = "#68b8a0", shade = "#58a090", deep = "#488880" }
  GX.trunk(c, t[1], t[1] + t[2] - 1, 24, 150, far, t[1], { noink = true })
end
-- far cliff + waterfall
GX.ground(c, function(x) return 126 + floor(5 * sin(x / 31)) end, HILL, 5, { top = .75, fall = .3, tex = .3 })
do
  local cl = mk()
  for x = 196, 246 do
    local top = 64 + floor((GX.vn(x, 0, 6, 9) - .5) * 8) + floor(abs(x - 221) * .35)
    for y = top, 135 do cl:set(x, y) end
  end
  GX.lit(c, cl, GX.ramp6({ hi = "#8ab8a0", base = "#5e9488", shade = "#46747a", deep = "#34545e" }), { R = 14, tex = .5, sc = 3, seed = 31, ink = false })
  for x = 212, 228 do
    local top = 66 + floor(abs(x - 220) * .3)
    for y = top, 134 do
      local v = GX.vn(x * 2.5, y * .12, 1.6, 5)
      c:px(x, y, v > .6 and "#ffffff" or (v > .3 and "#d8f4ff" or "#a8dcf0"))
    end
  end
  for x = 206, 236 do for y = 132, 138 do   -- mist pool
    if GX.vn(x, y, 3, 8) > .3 and abs(x - 221) < 15 + (y - 132) then c:px(x, y, (y % 2 == 0) and "#ffffff" or "#d8f4ff") end
  end end
end
GX.ground(c, function(x) return 140 + floor(4 * sin(x / 23 + 2)) end, GROUND, 7, { top = .86, fall = .62, tex = .34, sc = 7 })

---------------------------------------------------------------- canopy
local CAN = { EM1, EM2, LIM, EM1, TEALL, EM2, EM1, LIM, EM2, TEALL, EM1, EM2 }
local CL = { { 40, 14, 52, 24 }, { 110, 6, 46, 20 }, { 170, 16, 46, 20 }, { 236, 6, 48, 20 }, { 300, 14, 50, 20 }, { 362, 6, 46, 18 }, { 424, 14, 50, 22 }, { 474, 6, 34, 20 },
  { 14, 40, 32, 14 }, { 250, 36, 30, 10 }, { 372, 34, 30, 10 }, { 70, 42, 26, 10 } }
for pass = 1, 2 do
  for i, g in ipairs(CL) do
    if (pass == 1) == (g[2] < 30) then GX.foliage(c, g[1], g[2], g[3], g[4], CAN[i], 200 + i * 17) end
  end
end

---------------------------------------------------------------- giant buttress trunks
local function buttress(x0, x1, y0, y1, seed, moss)
  GX.trunk(c, x0, x1, y0, y1, BARK, seed, { moss = moss and MOSS or nil })
end
buttress(76, 108, 14, 140, 11, true)
buttress(168, 178, 24, 124, 12, false)
buttress(442, 479, 0, 170, 13, true)
-- orchids clinging to trunks
local function orchid(x, y, R)
  for i = 0, 3 do   -- arching stem
    c:px(x + i, y - i * 2, MOSS.shade); c:px(x + i, y - i * 2 + 1, MOSS.deep)
  end
  for _, p in ipairs{ { 3, -6 }, { 1, -3 }, { 5, -8 }, { -1, 0 } } do
    local m = mk(); E(m, x + p[1], y + p[2], 2, 2)
    GX.lit(c, m, GX.ramp6(R), { R = 2, tex = 0, ink = INK })
    c:px(x + p[1], y + p[2], "#ffe38a")
  end
end
orchid(90, 96, PINK); orchid(98, 66, PUR); orchid(460, 112, ORG); orchid(452, 80, PINK)

---------------------------------------------------------------- hanging vines
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
  local ey = y0 + len
  c:px(x + floor(sin(ey / 9 + seed) * 2), ey + 1, "#9ad848")
end
for i, x in ipairs{ 6, 30, 52, 120, 142, 186, 206, 232, 262, 276, 450, 466, 440 } do
  vine(x, 20 + (i % 3) * 8, 38 + floor(H(i, 7, 1) * 40), i * 3)
end
for i, x in ipairs{ 296, 318, 344, 372, 396, 420 } do vine(x, 22, 26 + floor(H(i, 8, 1) * 10), i * 2) end

---------------------------------------------------------------- ground detail
local function blocked(x, y) return (x < 156 and y > 120 and y < 200) or (x > 280 and x < 432 and y > 60 and y < 218) or (abs(x - 240) < 50 and abs(y - 214) < 18) end
for _, t in ipairs{ { 94, 172, 38, 5 }, { 172, 152, 14, 3 }, { 462, 180, 24, 5 } } do
  local m = mk(); E(m, t[1], t[2], t[3], t[4]); m = GX.rough(m, t[1], 1); c:fillMask(m, GX.mix(GROUND.shade, GROUND.base, .3))
end
for i = 0, 9 do   -- damp puddles / light dapples
  local x, y = 30 + floor(H(i, 51, 1) * 420), 156 + floor(H(i, 53, 1) * 100)
  if not blocked(x, y) then local m = mk(); E(m, x, y, 10 + i % 4 * 3, 3); m = GX.rough(m, i, 1); c:fillMask(m, GX.mix(GROUND.hi, "#e8ffc0", .25)) end
end
-- tangled roots on ground
for _, r in ipairs{ { 190, 190, 1 }, { 230, 244, -1 }, { 40, 232, 1 }, { 168, 128, 1 } } do
  local x, y = r[1], r[2]
  for i = 0, 22 do
    local yy = y + floor(sin(i / 4 + x) * 2)
    local xx = x + i * r[3] * 2
    local m = c:rect(xx, yy, xx + 2, yy + 2)
    c:fillMask(m, BARK.shade); c:px(xx, yy, BARK.base); c:px(xx + 1, yy, BARK.hi); c:px(xx + 2, yy + 2, BARK.deep)
  end
end
local function frond(x, y, dir, len)
  for i = 0, 6 do
    local ang = (-80 + i * 24) * dir
    local l = len - abs(i - 3) * 3
    local ex, ey = x + floor(l * sin(ang / 57.3)), y - floor(l * cos(ang / 57.3))
    local mx, my = (x + ex) // 2 - dir * 3, (y + ey) // 2 - 4
    local fr = c:poly{ { x, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 4 } }
    GX.lit(c, fr, GX.ramp6(i % 2 == 0 and EM1 or LIM), { R = 3, tex = .25, sc = 2, seed = i, rimlight = true })
  end
end
-- monstera leaf: holey, cut by slits
local function monstera(cx, cy, r, seed, R)
  local m = mk()
  E(m, cx, cy, r, floor(r * .85)); m = GX.rough(m, seed, 1)
  for k = 0, 4 do
    local ang = (k - 2) * .55
    for t = r * .45, r * 1.1, 1 do
      local hx, hy = cx + floor(sin(ang + 1.2) * t * -1) * 1, cy + floor(cos(ang + 1.2) * t * .6)
      local hole = mk(); GX.disc(hole, cx + floor(t * cos(ang)), cy + floor(t * sin(ang) * .8) + floor(r * .15), 0, 0)
      m:cut(hole)
    end
  end
  GX.lit(c, m, GX.ramp6(R), { R = floor(r * .7), tex = .35, sc = 3, seed = seed, rimlight = true })
  for t = 0, r - 2 do c:px(cx - r + 2 + t, cy + floor((t - r / 2) * 0) , R.shade) end   -- midrib
  c:px(cx - r + 1, cy, R.deep)
end
-- banana leaf: long arching blade with midrib
local function banana(x, y, len, dir, R, seed)
  local m = mk()
  for t = 0, len do
    local px_ = x + dir * t
    local py_ = y - floor(sin(t / len * 1.6) * len * .34) + floor((t / len) ^ 2 * 8)
    local w = floor(sin(t / len * 3.0) * 5) + 1
    for yy = py_ - w, py_ + w do m:set(px_, yy) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(R), { R = 4, tex = .3, sc = 3, seed = seed, rimlight = true })
  for t = 0, len do
    c:px(x + dir * t, y - floor(sin(t / len * 1.6) * len * .34) + floor((t / len) ^ 2 * 8), R.deep)
  end
end
-- bromeliad rosette
local function brom(x, y, R)
  for i = 0, 8 do
    local a = (-90 + (i - 4) * 18) / 57.3
    local ex, ey = x + floor(cos(a) * 11), y + floor(sin(a) * 10)
    local lf = c:poly{ { x - 2, y }, { x + 2, y }, { ex, ey } }
    GX.lit(c, lf, GX.ramp6(i % 2 == 0 and R or LIM), { R = 3, tex = .1, rimlight = true, seed = i })
  end
  local ct = mk(); E(ct, x, y - 3, 2, 2); GX.lit(c, ct, GX.ramp6(PINK), { R = 2, tex = 0, ink = INK })
end

for i = 0, 40 do   -- grass/tufts
  local x, y = 10 + floor(H(i, 61, 1) * 460), 150 + floor(H(i, 63, 1) * 118)
  if not blocked(x, y) then GX.tuft(c, x, y, y > 214 and { hi = GROUND.base, base = GROUND.shade, shade = GROUND.deep } or { hi = LIM.hi, base = EM1.base, shade = EM2.shade, deep = EM2.deep }) end
end
for i = 0, 18 do
  local x, y = 20 + floor(H(i, 41, 1) * 440), 152 + floor(H(i, 43, 1) * 112)
  if not blocked(x, y) then GX.flower(c, x, y, ({ "#ff6cb0", "#ff9a3a", "#c27cff", "#ffe38a" })[1 + i % 4]) end
end

---------------------------------------------------------------- mossy fallen log (hero)
local LOGR = { hi = "#b88a5c", base = "#8a5e3c", shade = "#5e3e38", deep = "#36242c" }
local lg = mk()
for x = 10, 140 do local top = 138 + floor((GX.vn(x, 0, 12, 4) - .5) * 4); for y = top, 190 - floor(GX.vn(x, 9, 10, 5) * 3) do lg:set(x, y) end end
E(lg, 12, 164, 5, 26)
GX.lit(c, lg, GX.ramp6(LOGR), { R = 24, tex = .3, sc = 2.2, seed = 9, rimlight = true, fn = function(x, y) return (GX.vn(x * .22, y, 2, 6) - .5) * .5 end })
local ms = mk()
for x = 12, 140 do local top = 131 + floor(GX.vn(x, 3, 7, 8) * 4); local bot = 141 + floor(GX.vn(x, 7, 6, 2) * 9); for y = top, bot do ms:set(x, y) end end
GX.lit(c, ms, GX.ramp6(MOSS), { R = 5, tex = .6, sc = 3, seed = 4, rimlight = true })
-- moss drip patches on side
for i = 0, 7 do local m = mk(); E(m, 20 + floor(H(i, 3, 1) * 110), 160 + floor(H(i, 4, 1) * 22), 4, 3); m = GX.rough(m, i, 1)
  m:cut(c:rect(0, 0, 0, 0)); GX.lit(c, m, GX.ramp6(MOSS), { R = 3, tex = .5, sc = 2, seed = i + 20, ink = false }) end
local face = mk(); E(face, 142, 164, 14, 28)
GX.lit(c, face, GX.ramp6({ hi = "#e8b888", base = "#c08a58", shade = "#8e5c44", deep = "#5e3a34" }), { R = 12, tex = .15, seed = 2, rimlight = true,
  fn = function(x, y) local dd = sqrt(((x - 143) / 14) ^ 2 + ((y - 165) / 28) ^ 2); return (floor(dd * 5) % 2) * .16 - .08 end })
local hl = mk(); E(hl, 144, 167, 7, 14)
GX.lit(c, hl, GX.ramp6({ hi = "#23352f", base = "#142420", shade = "#0c1614", deep = "#060a0a" }), { R = 4, tex = .1, seed = 3, ink = "#0c1614" })
-- bromeliads and orchids on the log
brom(34, 134, ORG); brom(72, 133, PINK)
orchid(52, 134, PUR)
-- glossy ferns hugging log
frond(24, 196, 1, 26); frond(130, 196, -1, 24)

-- quirk: red-eyed tree frog on the moss
do
  local x, y = 108, 132
  local FR = { hi = "#b8ff60", base = "#4ed048", shade = "#228a48", deep = "#0f4a3c" }
  for _, p in ipairs{ { -5, 0 }, { 5, 0 }, { -3, 1 }, { 3, 1 } } do   -- orange toes
    c:px(x + p[1], y + p[2], INK); c:px(x + p[1], y + p[2] - 1, "#ff8a2a")
  end
  local b = mk(); E(b, x, y - 4, 5, 4)
  GX.lit(c, b, GX.ramp6(FR), { R = 4, tex = .1, seed = 8, rimlight = true })
  c:px(x - 3, y - 8, INK); c:px(x + 3, y - 8, INK); c:px(x - 3, y - 7, "#ff2a3a"); c:px(x + 3, y - 7, "#ff2a3a")
  c:px(x - 2, y - 7, INK); c:px(x + 2, y - 7, INK)
  c:fillMask(c:rect(x - 3, y - 2, x + 3, y - 1), "#f4ffd0")
  c:px(x - 1, y - 4, INK); c:px(x + 1, y - 4, INK)
end

---------------------------------------------------------------- big glossy leaves at edges
monstera(196, 196, 20, 41, EM1)
banana(160, 246, 52, 1, LIM, 43)
banana(20, 262, 46, 1, EM2, 44)
monstera(456, 226, 18, 45, EM2)
banana(478, 256, -1 + 0, -1, EM1, 46)
banana(474, 214, 40, -1, LIM, 47)
brom(250, 250, ORG); brom(450, 258, PINK)
frond(270, 266, -1, 24); frond(460, 268, -1, 22)
-- fallen leaf litter + seeds
local LIT = { "#e8b030", "#d87828", "#a8522c", "#c4d860", "#7a4a30" }
for i = 0, 140 do
  local x, y = floor(H(i, 31, 1) * 480), 150 + floor(H(i, 37, 1) * 120)
  if not (x > 280 and x < 432 and y > 60 and y < 218) then
    local col = LIT[1 + i % #LIT]
    c:px(x, y, col); c:px(x + 1, y, col); c:px(x + 1, y + 1, GX.mix(col, "#000000", .3)); c:px(x, y + 1, GX.mix(col, "#ffffff", .2))
  end
end
-- floating mist motes in light shafts (hard pixels)
for i = 0, 30 do
  local x, y = 20 + floor(H(i, 71, 1) * 440), 40 + floor(H(i, 73, 1) * 100)
  if not (x > 280 and x < 436 and y > 56) then c:px(x, y, "#fffff0") end
end

---------------------------------------------------------------- satchel contact shadow
local sh = mk(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, SHADOW)
c:save{ aseprite = d .. "/../out/scene-rainforest.aseprite", png = d .. "/../out/scene-rainforest.png", scale = 1 }
