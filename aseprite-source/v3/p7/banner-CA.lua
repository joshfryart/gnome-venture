-- banner-CA: desert header strip, v3 style
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos = math.floor, math.max, math.min, math.abs, math.sin, math.cos
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 120, scale = 1, name = "banner-CA" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function R(m, x0, y0, x1, y1) for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end end

local SKY = { "#f08a5a", "#f6a064", "#fbb86c", "#fdd078", "#ffe08e", "#ffeaa8" }
local SAND = { hi = "#fff0b8", base = "#f2c070", shade = "#d08e52", deep = "#9c5e3e" }
local FARG = { hi = "#f8cc90", base = "#e6a470", shade = "#cc8062", deep = "#a8605c" }
local ADO = { hi = "#ffe4b0", base = "#f2b87a", shade = "#cf8a62", deep = "#96605c" }
local VIO = { hi = "#d0a4b4", base = "#a67894", shade = "#7c5478", deep = "#523a62" }
local ROOF = { hi = "#f4b078", base = "#c87450", shade = "#96544c", deep = "#683a48" }
local CACT = { hi = "#d0ec80", base = "#74b85a", shade = "#3f8a52", deep = "#1f5446" }
local CLAY = { hi = "#f09a60", base = "#c8603c", shade = "#94443c", deep = "#62303a" }
local ROCK = { hi = "#f0d0bc", base = "#c08c84", shade = "#8c5c7a", deep = "#5a3a5a" }
local SHADOW = "#b4703e"
local HEM, GOLD = "#3d2a1c", "#f5cf6a"

-- sky
for y = 0, 76 do for x = 0, 479 do
  local t = y / 76 + (GX.vn(x, y, 14, 4) - .5) * .22
  c:px(x, y, SKY[max(1, min(6, floor(t * 6) + 1))])
end end
-- sun glow
local sun = mk(); E(sun, 300, 62, 22, 14); c:fillMask(GX.rough(sun, 3, 1), "#fff0b4")
local s2 = mk(); E(s2, 300, 64, 12, 8); c:fillMask(GX.rough(s2, 4, 1), "#fff8d4")
-- clouds
local CL = { hi = "#fff4d0", base = "#ffd89a", shade = "#f4a878", deep = "#d6805e" }
for i, p in ipairs{ { 70, 26, 26, 5 }, { 190, 20, 30, 6 }, { 400, 28, 28, 5 }, { 330, 40, 16, 3 } } do
  local m = mk()
  E(m, p[1], p[2], p[3], p[4]); E(m, p[1] - p[3] // 2, p[2] - 3, p[3] // 2, p[4]); E(m, p[1] + p[3] // 3, p[2] - 4, p[3] // 2, p[4] - 1)
  m = GX.rough(m, 10 + i, 2)
  GX.lit(c, m, GX.ramp6(CL), { ink = false, R = 5, tex = .35, sc = 3, seed = 10 + i, amb = .35 })
end

-- distant mesa ridge + far houses
local far = mk()
for x = 0, 479 do
  local top = 66 + floor(4 * sin(x / 31 + 1) + 2 * sin(x / 11))
  for y = top, 80 do far:set(x, y) end
end
GX.lit(c, GX.rough(far, 20, 1), GX.ramp6(FARG), { ink = false, R = 14, tex = .3, sc = 6, seed = 21, amb = .5 })
local function farhouse(x, y, w, h, s)
  local m = mk(); R(m, x, y - h, x + w, y); R(m, x + 3, y - h - 3, x + w - 3, y - h)
  m = GX.rough(m, s, 1)
  local rp = {}; for k, v in pairs(ADO) do rp[k] = GX.mix(v, "#e8b49c", .35) end
  GX.lit(c, m, GX.ramp6(rp), { ink = false, R = 5, tex = .2, seed = s, amb = .4 })
  c:fillMask(c:rect(x + w // 2 - 1, y - 4, x + w // 2 + 1, y), "#9c6a62")
  c:px(x + 3, y - h + 3, "#ffd070")
end
for i, p in ipairs{ { 18, 74, 14, 9 }, { 60, 73, 12, 7 }, { 150, 72, 16, 10 }, { 214, 73, 12, 8 }, { 260, 72, 14, 7 },
  { 388, 73, 16, 9 }, { 436, 72, 13, 8 }, { 466, 74, 11, 7 } } do farhouse(p[1], p[2], p[3], p[4], 30 + i) end

-- ground band
local function gy(x) return 78 + floor(2 * sin(x / 40 + 2) + sin(x / 13)) end
local GR6 = GX.ramp6(SAND)
for x = 0, 479 do for y = gy(x), 111 do
  local t = (y - gy(x)) / 34
  local v = .86 - .3 * t + (GX.vn(x, y, 7, 5) - .5) * .4 + (GX.vn(x, y, 2.2, 8) - .5) * .06
  local w = y + floor(GX.vn(x, y, 12, 9) * 5) + floor(3 * sin(x / 19))   -- wind ripples
  if w % 6 == 0 and GX.vn(x, y, 6, 12) > .45 then v = v - .2 elseif w % 6 == 1 and GX.vn(x, y, 6, 13) > .55 then v = v + .15 end
  c:px(x, y, GR6[GX.idx(v)])
end end

local function shadow(cx, cy, rx, ry) local s = mk(); E(s, cx, cy, rx, ry); c:fillMask(GX.rough(s, cx, 1), SHADOW) end

-- adobe house: lit front, violet right side, flat roof with parapet, lit windows
local function house(x, yb, w, h, sd, o)
  o = o or {}
  local sw = 12
  shadow(x + w // 2 + sw // 2 + 4, yb, w // 2 + sw + 4, 3)
  local front = mk(); R(front, x, yb - h, x + w, yb)
  if o.tier then R(front, x + 4, yb - h - o.tier, x + w - 14, yb - h) end
  local side = mk(); R(side, x + w + 1, yb - h + 3, x + w + sw, yb)
  if o.tier then R(side, x + w - 13, yb - h - o.tier + 3, x + w - 6, yb - h) end
  front = GX.rough(front, sd, 1); side = GX.rough(side, sd + 1, 1)
  GX.lit(c, side, GX.ramp6(VIO), { R = 8, tex = .3, sc = 3, seed = sd + 2, amb = .35, rimlight = false })
  GX.lit(c, front, GX.ramp6(ADO), { R = 10, tex = .45, sc = 4, seed = sd + 3, amb = .3, rimlight = true,
    fn = function(xx, yy) return (yy < yb - h + 3 and .1 or 0) + (yy > yb - 4 and -.12 or 0) end })
  -- roof parapet lip
  c:fillMask(c:rect(x - 1, yb - h - 1, x + w + sw, yb - h), ADO.hi)
  c:fillMask(c:rect(x + w + 1, yb - h + 1, x + w + sw, yb - h + 2), VIO.hi)
  -- vigas (roof beams poking out of the wall)
  for k = 0, 2 do local vx = x + 5 + k * 6
    c:fillMask(c:rect(vx, yb - h + 4, vx + 2, yb - h + 5), "#8a5238"); c:px(vx, yb - h + 4, "#c88458")
  end
  -- door
  local dx = x + (o.doorx or w // 2 - 4)
  local door = mk(); R(door, dx, yb - 13, dx + 8, yb); door:cut((function() local k = mk(); k:set(dx, yb - 13); k:set(dx + 8, yb - 13); return k end)())
  door = GX.rough(door, sd + 4, 1)
  GX.lit(c, door, GX.ramp6({ hi = "#b87850", base = "#7a4a3e", shade = "#52303a", deep = "#34202c" }), { R = 4, tex = .3, seed = sd + 5, ink = true })
  c:px(dx + 6, yb - 6, "#ffd070")
  -- glowing windows
  for _, wp in ipairs(o.win or {}) do
    local wx, wy = x + wp[1], yb - wp[2]
    local m = mk(); R(m, wx, wy, wx + 5, wy + 6)
    GX.lit(c, m, GX.ramp6({ hi = "#fff6b8", base = "#ffd25a", shade = "#f09a40", deep = "#c0642c" }), { R = 3, tex = .1, seed = sd + 6, amb = .6, wrap = .6 })
    c:fillMask(c:rect(wx + 2, wy, wx + 2, wy + 6), "#8a5238"); c:fillMask(c:rect(wx, wy + 3, wx + 5, wy + 3), "#8a5238")
    c:fillMask(c:rect(wx - 1, wy + 7, wx + 6, wy + 7), VIO.shade)
  end
  -- side-wall window glow (violet side, tiny lit slit)
  c:fillMask(c:rect(x + w + 5, yb - h + 8, x + w + 7, yb - h + 12), "#ffcf5a")
  c:fillMask(c:rect(x + w + 5, yb - h + 8, x + w + 7, yb - h + 8), "#fff2a0")
  -- crack
  for k = 0, 5 do c:px(x + w - 6 - (k % 2), yb - h + 10 + k, ADO.shade) end
end

-- saguaro
local function saguaro(cx, yb, yt, w, arms, seed)
  local m = mk()
  R(m, cx - w, yt + w, cx + w, yb); E(m, cx, yt + w, w)
  for _, a in ipairs(arms) do
    local ay, side, reach, rise = a[1], a[2], a[3], a[4]
    local aw = max(2, w - 2); local ex = cx + side * reach
    R(m, min(cx, ex), ay - aw, max(cx, ex), ay + aw)
    R(m, ex - aw, ay - rise, ex + aw, ay + aw); E(m, ex, ay - rise, aw)
  end
  m = GX.rough(m, seed, 1)
  shadow(cx + w + 6, yb, w * 3, 3)
  GX.lit(c, m, GX.ramp6(CACT), { R = w + 2, tex = .35, sc = 3, seed = seed, rimlight = true, amb = .22,
    fn = function(x, y) return (((x + 1000) // 3) % 2 - .5) * .16 end })
  m:each(function(x, y) if H(x, y, seed) < .02 and m:has(x - 1, y) and m:has(x + 1, y) then c:px(x, y, "#fff4b8") end end)
  c:fillMask(c:rect(cx - 1, yt - 1, cx + 1, yt), "#ff7aa8"); c:px(cx, yt - 2, "#ffe38a")   -- blossom
end

local function rock(x, y, rx, ry, seed)
  local m = mk(); E(m, x, y, rx, ry); m = GX.rough(m, seed, 1)
  shadow(x + 3, y + ry, rx + 3, 2)
  GX.lit(c, m, GX.ramp6(ROCK), { R = rx, tex = .4, sc = 3, seed = seed, rimlight = true })
end

local function pot(x, yb, w, h, seed, plant)
  shadow(x + w // 2 + 3, yb, w, 2)
  local m = mk(); R(m, x + 2, yb - h, x + w - 2, yb); R(m, x, yb - h, x + w, yb - h + 3); R(m, x + 2, yb - h * 2 // 3 , x + w + 0, yb - 2)
  E(m, x + w // 2, yb - h // 2, w // 2, h // 2 + 1)
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, GX.ramp6(CLAY), { R = w // 2 + 1, tex = .3, sc = 3, seed = seed, rimlight = true })
  for k = 1, w - 2 do if k % 3 == 0 then c:px(x + k, yb - h // 2, "#ffd070") end end   -- painted zigzag
  c:fillMask(c:rect(x + 1, yb - h + 1, x + w - 1, yb - h + 1), "#3a2430")
  if plant then
    for k = -2, 2 do
      for s = 1, 6 - abs(k) do c:px(x + w // 2 + k * (s > 3 and 2 or 1) // 1, yb - h - s, s > 4 and CACT.hi or CACT.base) end
    end
    c:px(x + w // 2, yb - h - 8, "#ff7aa8"); c:px(x + w // 2 + 1, yb - h - 8, "#ffe38a")
  end
end

-- composition (nothing important above y=14 or below y=112)
pot(20, 106, 14, 12, 41, true); pot(38, 109, 11, 10, 42, false)
saguaro(66, 105, 42, 6, { { 80, 1, 14, 22 }, { 68, -1, 12, 14 } }, 71)
house(100, 104, 52, 36, 50, { win = { { 8, 24 }, { 36, 24 } }, doorx = 20, tier = 10 })
rock(176, 106, 8, 5, 61); rock(190, 108, 5, 3, 62)
saguaro(222, 106, 30, 7, { { 84, -1, 17, 30 }, { 70, 1, 14, 22 } }, 72)
house(266, 106, 56, 32, 52, { win = { { 9, 22 }, { 38, 22 } }, doorx = 24 })
-- quirk: lizard on the roof of the second house
do
  local x, y = 296, 106 - 32 - 2
  local lz = mk(); R(lz, x, y - 1, x + 6, y); R(lz, x + 7, y - 2, x + 9, y); lz:set(x - 1, y); lz:set(x - 2, y + 0); lz:set(x - 3, y - 1); lz:set(x - 4, y - 1)
  lz:set(x + 1, y + 1); lz:set(x + 5, y + 1); lz:set(x + 2, y - 2); lz:set(x + 6, y - 2)
  GX.lit(c, lz, GX.ramp6({ hi = "#d8f080", base = "#74b85a", shade = "#3f8a52", deep = "#1f5446" }), { R = 2, tex = .1, seed = 99 })
  c:px(x + 9, y - 2, "#ffe38a")
end
rock(352, 107, 7, 4, 63)
saguaro(392, 106, 36, 6, { { 76, -1, 13, 20 } }, 73)
pot(414, 107, 13, 11, 43, true)
house(436, 105, 30, 26, 54, { win = { { 5, 17 } }, doorx = 14 })
rock(470, 108, 7, 4, 64)
-- scattered tufts and pebbles
for i = 0, 30 do
  local x, y = 4 + floor(H(i, 71, 1) * 470), 88 + floor(H(i, 73, 1) * 22)
  GX.tuft(c, x, y, { hi = "#fff0a0", base = "#dcbc58", shade = "#a88040", deep = "#76502e" })
end

-- hems (stitched, copied from the old banner)
for y = 0, 5 do for x = 0, 479 do c:px(x, y, HEM) end end
for x = 0, 479 do if x % 6 < 4 then for y = 2, 3 do c:px(x, y, GOLD) end end end
for x = 0, 479 do   -- scalloped fringe under the top hem
  local f = 6 + floor(GX.vn(x, 0, 5, 77) * 3)
  for y = 6, f + (x % 8 < 3 and 2 or 0) do c:px(x, y, "#4a2c1a") end
end
for y = 112, 119 do for x = 0, 479 do c:px(x, y, "#c9a96e") end end
for x = 0, 479 do c:px(x, 111, "#74462a"); if x % 6 < 4 then for y = 116, 117 do c:px(x, y, GOLD) end end end

c:save{ aseprite = d.."/out/banner-CA.aseprite", png = d.."/out/banner-CA.png", scale = 1 }
