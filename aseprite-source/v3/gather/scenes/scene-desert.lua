-- scene-desert: sunlit dunes, red mesas, saguaro, bone arch, oasis puddle, scorpion. DAY palette.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d .. "/../gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H = X.hash
local INK = GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "scene-desert" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function R(m, x0, y0, x1, y1) for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end end

local SKY = { "#bfe6ee", "#d4eee6", "#eaf4d4", "#fff2c4", "#ffe6b0", "#ffd8a0" }
local SAND = { hi = "#fff0b8", base = "#f6c874", shade = "#da9a52", deep = "#a8643c" }
local FAR = { hi = "#fbd8a0", base = "#eeb078", shade = "#d89068", deep = "#b8705c" }
local MESA = { hi = "#f08a58", base = "#cc5640", shade = "#9c3e3e", deep = "#6a2a3a" }
local CACT = { hi = "#d0ec80", base = "#74b85a", shade = "#3f8a52", deep = "#1f5446" }
local BONE = { hi = "#fffaea", base = "#f0e2c0", shade = "#c8b08c", deep = "#8e7460" }
local GRASS = { hi = "#fff0a0", base = "#dcbc58", shade = "#a88040", deep = "#76502e" }
local SHADOW = "#b4703e"

---------------------------------------------------------------- sky, sun glare, mesas
GX.bands(c, 0, 150, SKY, 4, .2, nil)
local sun = mk(); E(sun, 90, 22, 26, 16); c:fillMask(GX.rough(sun, 3, 1), "#fffbe0")
local s2 = mk(); E(s2, 90, 22, 14, 9); c:fillMask(GX.rough(s2, 4, 1), "#ffffff")
for _, w in ipairs{ { 190, 30, 60 }, { 330, 18, 44 }, { 400, 40, 50 } } do   -- thin wisps
  local m = mk(); E(m, w[1], w[2], w[3], 2); m = GX.rough(m, w[1], 1); c:fillMask(m, "#fff8e0")
end
local function mesa(x0, x1, yb, h, x2, x3, h2, seed, haze)
  local m = mk()
  for x = x0, x1 do
    local e = min(x - x0, x1 - x)
    local top = yb - h + max(0, 9 - e * 2) + floor((GX.vn(x, 0, 6, seed) - .5) * 3)
    if x2 and x >= x2 and x <= x3 then
      local e2 = min(x - x2, x3 - x)
      top = yb - h - h2 + max(0, 6 - e2 * 2)
    end
    for y = top, yb do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  local rp = {}
  for k, v in pairs(MESA) do rp[k] = GX.mix(v, "#ffd8b0", haze) end
  GX.lit(c, m, GX.ramp6(rp), { R = 22, tex = .3, sc = 4, seed = seed, ink = false, amb = .35,
    fn = function(x, y) return ((y // 5) % 2) * .09 - .045 + (GX.vn(x * .3, y, 2, seed) - .5) * .12 end })
end
mesa(40, 120, 150, 40, 62, 92, 16, 31, .3)
mesa(150, 196, 150, 28, nil, nil, 0, 32, .3)
mesa(236, 330, 150, 52, 262, 300, 20, 33, .15)
mesa(352, 420, 150, 36, nil, nil, 0, 34, .3)
mesa(438, 479, 150, 44, 450, 468, 14, 35, .25)

---------------------------------------------------------------- dunes
GX.ground(c, function(x) return 136 + floor(6 * sin(x / 38 + 1) + 3 * sin(x / 13)) end, FAR, 5, { top = .78, fall = .35, tex = .3, sc = 9 })
GX.ground(c, function(x) return 150 + floor(7 * sin(x / 52 + 3) + 2 * sin(x / 17)) end, SAND, 7, { top = .9, fall = .62, tex = .3, sc = 10 })
local function blocked(x, y)
  return (x > 276 and x < 442 and y > 56 and y < 222) or (x < 156 and y > 116 and y < 232) or (abs(x - 357) < 80 and y > 206 and y < 220)
end
-- wind ripples on dunes
for y = 156, 262 do for x = 0, 479 do
  if not blocked(x, y) then
    local w = y + floor(GX.vn(x, y, 14, 9) * 7) + floor(4 * sin(x / 21))
    if w % 5 == 0 and GX.vn(x, y, 6, 12) > .4 then c:px(x, y, SAND.shade)
    elseif w % 5 == 1 and GX.vn(x, y, 6, 13) > .55 then c:px(x, y, SAND.hi) end
  end
end end

---------------------------------------------------------------- cracked clay patches
local function clay(cx, cy, rx, ry, seed)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  local CL = { hi = "#f0c890", base = "#d89c64", shade = "#b87850", deep = "#8a5440" }
  GX.lit(c, m, GX.ramp6(CL), { R = 5, tex = .25, sc = 4, seed = seed, ink = false, amb = .4 })
  for i = 1, 9 do
    local x, y = cx + floor((H(i, seed, 1) - .5) * rx * 1.7), cy + floor((H(i, seed, 2) - .5) * ry * 1.7)
    local dx, dy = H(i, seed, 3) < .5 and 1 or 0, H(i, seed, 4) < .5 and 1 or -1
    for s = 1, 9 + floor(H(i, seed, 5) * 6) do
      if m:has(x, y) then c:px(x, y, CL.deep); if m:has(x, y + 1) and H(x, y, seed) < .5 then c:px(x, y + 1, CL.shade) end end
      local r = H(x, y, seed + i)
      if r < .45 then x = x + (dx == 1 and 1 or -1) elseif r < .8 then y = y + dy else x = x + 1; y = y + dy end
    end
  end
end
clay(104, 250, 34, 8, 41); clay(236, 258, 30, 6, 42); clay(20, 232, 14, 5, 43)

---------------------------------------------------------------- oasis puddle with reeds
do
  local wet = mk(); E(wet, 206, 238, 27, 8); wet = GX.rough(wet, 51, 2); c:fillMask(wet, "#c88650")
  local w = mk(); E(w, 206, 238, 23, 6); w = GX.rough(w, 52, 1)
  GX.lit(c, w, GX.ramp6({ hi = "#d8fcf0", base = "#6ccad8", shade = "#3a98b8", deep = "#2a6a98" }),
    { R = 5, tex = .3, sc = 3, seed = 53, ink = false, amb = .5, wrap = .5,
      fn = function(x, y) return ((y % 3 == 0 and GX.vn(x, y, 3, 8) > .55) and .18 or 0) end })
  for _, t in ipairs{ { 188, 233 }, { 192, 235 }, { 226, 234 }, { 222, 236 } } do GX.tuft(c, t[1], t[2], { hi = "#c8f070", base = "#6cc050", shade = "#3a9048", deep = "#1f5a44" }) end
end

---------------------------------------------------------------- scattered ground detail
local function rock(x, y, rx, ry, seed)
  local m = mk(); E(m, x, y, rx, ry); m = GX.rough(m, seed, 1)
  local sh = mk(); E(sh, x + 2, y + ry, rx + 2, 2); c:fillMask(sh, SHADOW)
  GX.lit(c, m, GX.ramp6({ hi = "#f4d8c0", base = "#c89080", shade = "#94607a", deep = "#5e3a58" }), { R = rx, tex = .4, sc = 3, seed = seed, rimlight = true })
end
for i, r in ipairs{ { 168, 206, 6, 4 }, { 150, 262, 5, 3 }, { 262, 244, 7, 4 }, { 276, 192, 5, 3 }, { 330, 252, 4, 3 }, { 120, 214, 4, 3 } } do rock(r[1], r[2], r[3], r[4], 60 + i) end
for i = 0, 40 do   -- dry grass
  local x, y = 6 + floor(H(i, 71, 1) * 468), 158 + floor(H(i, 73, 1) * 108)
  if not blocked(x, y) and abs(x - 206) > 30 + 0 * y then GX.tuft(c, x, y, GRASS) end
end
for i = 0, 70 do   -- sand pebbles / sparkle
  local x, y = floor(H(i, 81, 1) * 480), 156 + floor(H(i, 83, 1) * 112)
  if not blocked(x, y) then c:px(x, y, SAND.shade); c:px(x + 1, y, SAND.hi) end
end
for _, p in ipairs{ { 262, 224 }, { 236, 200 }, { 168, 252 }, { 38, 262 }, { 300, 262 } } do   -- small bleached bones
  c:fillMask(c:rect(p[1], p[2], p[1] + 6, p[2] + 1), BONE.base); c:px(p[1], p[2] - 1, BONE.hi); c:px(p[1] + 6, p[2] + 2, BONE.shade)
  c:px(p[1] - 1, p[2] + 1, BONE.hi); c:px(p[1] + 7, p[2], BONE.hi); c:px(p[1] + 1, p[2] + 2, BONE.shade)
end

---------------------------------------------------------------- cacti
local function saguaro(cx, yb, yt, w, arms, seed)
  local m = mk()
  R(m, cx - w, yt + w, cx + w, yb); E(m, cx, yt + w, w)
  for _, a in ipairs(arms) do
    local ay, side, reach, rise = a[1], a[2], a[3], a[4]
    local aw = max(2, w - 2)
    local ex = cx + side * reach
    R(m, min(cx, ex) - 0, ay - aw, max(cx, ex) + 0, ay + aw)
    R(m, ex - aw, ay - rise, ex + aw, ay + aw); E(m, ex, ay - rise, aw)
  end
  m = GX.rough(m, seed, 1)
  local sh = mk(); E(sh, cx + w + 6, yb, w * 3, 4); c:fillMask(sh, SHADOW)
  GX.lit(c, m, GX.ramp6(CACT), { R = w + 2, tex = .35, sc = 3, seed = seed, rimlight = true, amb = .22,
    fn = function(x, y) return (((x + 1000) // 3) % 2 - .5) * .16 end })
  m:each(function(x, y) if H(x, y, seed) < .02 and m:has(x - 1, y) and m:has(x + 1, y) then c:px(x, y, "#fff4b8") end end)
  return m
end
saguaro(9, 222, 24, 7, { { 118, 1, 22, 40 } }, 71)
saguaro(462, 204, 36, 7, { { 128, -1, 20, 46 }, { 90, 1, 12, 22 } }, 72)
local function barrel(cx, cy, rx, ry, seed)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 1)
  local sh = mk(); E(sh, cx + 3, cy + ry, rx + 4, 3); c:fillMask(sh, SHADOW)
  GX.lit(c, m, GX.ramp6(CACT), { R = rx, tex = .3, sc = 3, seed = seed, rimlight = true,
    fn = function(x, y) return (floor(((x - cx) / rx) * 5) % 2 - .5) * .22 end })
  m:each(function(x, y) if H(x, y, seed + 1) < .035 then c:px(x, y, "#fff4b8") end end)
  E(c:rect(cx, cy, cx, cy), cx, cy - ry, 0)   -- no-op guard
  c:fillMask(c:rect(cx - 1, cy - ry - 1, cx + 1, cy - ry), "#ff7aa8"); c:px(cx, cy - ry - 2, "#ffe38a")
end
barrel(40, 250, 11, 9, 81); barrel(58, 258, 7, 6, 82); barrel(452, 244, 9, 8, 83)

local function agave(x, y, seed)
  local sh = mk(); E(sh, x + 3, y + 1, 20, 3); c:fillMask(sh, SHADOW)
  local ramps = { { hi = "#c8ecd0", base = "#78b8a0", shade = "#468c80", deep = "#285a62" }, { hi = "#b0e0b8", base = "#5ca890", shade = "#3a7a74", deep = "#244e5a" } }
  for i = 0, 8 do
    local ang = (-84 + i * 21)
    local len = 26 - abs(i - 4) * 2.5
    local ex, ey = x + floor(len * sin(ang / 57.3)), y - floor(len * cos(ang / 57.3)) * 0.9
    local mx, my = (x + ex) // 2, (y + ey) // 2 - 2
    local lf = c:poly{ { x - 2, y }, { mx - 3, my }, { floor(ex), floor(ey) }, { mx + 3, my + 3 }, { x + 2, y } }
    GX.lit(c, lf, GX.ramp6(ramps[1 + i % 2]), { R = 3, tex = .25, sc = 2, seed = seed + i, rimlight = true })
  end
  c:px(x, y - 22, "#ffe38a")
end
agave(250, 212, 90)

---------------------------------------------------------------- hero: bleached bone arch + skull
do
  local m = mk()
  local cx, cy, rx, ry = 82, 196, 46, 62
  for a = 0, 180, 1 do
    local t = a / 57.296
    local x, y = cx + floor(cos(t) * rx + .5), cy - floor(sin(t) * ry + .5)
    local th = 3 + floor(sin(t) * 2)
    E(m, x, y, th, th)
  end
  for i = -1, 1, 2 do   -- flared bone ends at the ground
    local x = cx + i * rx
    E(m, x, cy + 1, 6, 4); E(m, x + i * 2, cy + 4, 4, 2)
  end
  m = GX.rough(m, 91, 1)
  local sh = mk(); E(sh, cx + 10, cy + 5, rx + 8, 4); c:fillMask(GX.rough(sh, 92, 1), SHADOW)
  GX.lit(c, m, GX.ramp6(BONE), { R = 6, tex = .4, sc = 3, seed = 93, rimlight = true, amb = .3,
    fn = function(x, y) return (GX.vn(x, y * .5, 2, 5) - .5) * .25 end })
  -- rib ridges: little grooves
  for k = 1, 5 do
    local t = (20 + k * 28) / 57.296
    local x, y = cx + floor(cos(t) * rx), cy - floor(sin(t) * ry)
    c:px(x, y, BONE.shade); c:px(x + 1, y + 1, BONE.deep)
  end
  -- skull resting beside the arch
  local sx, sy = 124, 214
  local ss = mk(); E(ss, sx + 3, sy + 8, 20, 3); c:fillMask(ss, SHADOW)
  local sk = mk(); E(sk, sx, sy, 13, 10); E(sk, sx + 10, sy + 5, 8, 6)   -- cranium + snout
  sk = GX.rough(sk, 95, 1)
  local horn = mk()
  for a = 0, 50 do local t = a / 50; E(horn, sx - 12 - floor(t * 10), sy - 6 - floor(sin(t * 3) * 7), 1, 1) end
  for a = 0, 50 do local t = a / 50; E(horn, sx + 8 + floor(t * 10), sy - 8 - floor(sin(t * 3) * 6), 1, 1) end
  GX.lit(c, horn, GX.ramp6(BONE), { R = 2, tex = .1, seed = 96, rimlight = true })
  GX.lit(c, sk, GX.ramp6(BONE), { R = 10, tex = .4, sc = 3, seed = 97, rimlight = true, amb = .3 })
  local eye = mk(); E(eye, sx - 2, sy - 1, 3, 3); c:fillMask(eye, "#3a2430")
  local eye2 = mk(); E(eye2, sx + 7, sy + 1, 2, 3); c:fillMask(eye2, "#3a2430")
  c:fillMask(c:rect(sx + 14, sy + 5, sx + 15, sy + 7), "#3a2430")
  c:px(sx - 3, sy - 2, "#6a4a58")
  for i = 0, 3 do c:px(sx + 11 + i * 2, sy + 10, BONE.deep) end   -- teeth line
end

---------------------------------------------------------------- quirk: tiny scorpion by the puddle
do
  local x, y = 170, 244
  local sc = mk()
  R(sc, x, y, x + 5, y + 2)            -- body
  R(sc, x - 2, y - 1, x - 1, y)        -- claw arm
  R(sc, x - 4, y - 2, x - 3, y - 1); R(sc, x - 4, y + 1, x - 3, y + 2)   -- pincers
  for _, p in ipairs{ { 6, 1 }, { 7, 0 }, { 8, -1 }, { 8, -2 }, { 7, -3 }, { 6, -4 }, { 5, -4 } } do sc:set(x + p[1], y + p[2]) end   -- curled tail
  for k = 0, 2 do sc:set(x + 1 + k * 2, y + 3) end   -- legs
  local ss = mk(); E(ss, x + 3, y + 4, 8, 1); c:fillMask(ss, SHADOW)
  GX.lit(c, sc, GX.ramp6({ hi = "#ffb070", base = "#d8683a", shade = "#a8402c", deep = "#6a2630" }), { R = 2, tex = .1, seed = 99 })
  c:px(x + 5, y - 5, "#ffe38a")   -- stinger tip glints
  c:px(x + 4, y - 4, INK)
end

---------------------------------------------------------------- contact shadow for satchel
local sh = mk(); GX.disc(sh, 357, 213, 74, 5); c:fillMask(sh, SHADOW)

c:save{ aseprite = d .. "/../out/scene-desert.aseprite", png = d .. "/../out/scene-desert.png", scale = 1 }
