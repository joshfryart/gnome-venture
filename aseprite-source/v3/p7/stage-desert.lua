-- stage-desert v3: clear-day base backdrop (no weather painted in)
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "stage-desert" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local function RC(m, x0, y0, x1, y1) for y = y0, y1 do for x = x0, x1 do m:set(x, y) end end end
local R6 = GX.ramp6
local SAND = { hi = "#fff0b8", base = "#f6c874", shade = "#da9a52", deep = "#a8643c" }
local FAR = { hi = "#fbd8a0", base = "#eeb078", shade = "#d89068", deep = "#b8705c" }
local MESA = { hi = "#f08a58", base = "#cc5640", shade = "#9c3e3e", deep = "#6a2a3a" }
local CACT = { hi = "#d0ec80", base = "#74b85a", shade = "#3f8a52", deep = "#1f5446" }
local GRASS = { hi = "#fff0a0", base = "#dcbc58", shade = "#a88040", deep = "#76502e" }
local BONE = { hi = "#fffaea", base = "#f0e2c0", shade = "#c8b08c", deep = "#8e7460" }
local SHADOW = "#b4703e"

-- plain gradient sky, small sun glare
GX.bands(c, 0, 150, { "#a8dcf0", "#c4ecee", "#e0f2dc", "#fff0c0", "#ffe4a8", "#ffd8a0" }, 4, .18)
local sun = mk(); E(sun, 70, 26, 13, 9); c:fillMask(GX.rough(sun, 3, 1), "#fff8d8")
local s2 = mk(); E(s2, 70, 26, 6, 4); c:fillMask(GX.rough(s2, 4, 1), "#fffdf0")

-- mesas
local function mesa(x0, x1, yb, h, x2, x3, h2, seed, haze)
  local m = mk()
  for x = x0, x1 do
    local e = min(x - x0, x1 - x)
    local top = yb - h + max(0, 9 - e * 2) + floor((GX.vn(x, 0, 6, seed) - .5) * 3)
    if x2 and x >= x2 and x <= x3 then top = yb - h - h2 + max(0, 6 - min(x - x2, x3 - x) * 2) end
    for y = top, yb do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  local rp = {}
  for k, v in pairs(MESA) do rp[k] = GX.mix(v, "#ffd8b0", haze) end
  GX.lit(c, m, R6(rp), { R = 22, tex = .3, sc = 4, seed = seed, ink = false, amb = .35,
    fn = function(x, y) return ((y // 5) % 2) * .09 - .045 + (GX.vn(x * .3, y, 2, seed) - .5) * .12 end })
end
mesa(0, 70, 150, 34, nil, nil, 0, 31, .35)
mesa(110, 170, 150, 26, nil, nil, 0, 32, .35)
mesa(190, 300, 150, 62, 214, 268, 18, 33, .12)   -- hero butte, centre
mesa(340, 400, 150, 30, nil, nil, 0, 34, .35)
mesa(420, 479, 150, 40, 440, 462, 12, 35, .3)

-- dunes
GX.ground(c, function(x) return 134 + floor(6 * sin(x / 38 + 1) + 3 * sin(x / 13)) end, FAR, 5, { top = .78, fall = .35, tex = .3, sc = 9 })
local function dune(x) return 152 + floor(6 * sin(x / 52 + 3) + 2 * sin(x / 17)) end
GX.ground(c, dune, SAND, 7, { top = .9, fall = .62, tex = .3, sc = 10 })
for y = 158, 269 do for x = 0, 479 do   -- wind ripples, fading out toward the walk lane
  local w = y + floor(GX.vn(x, y, 14, 9) * 7) + floor(4 * sin(x / 21))
  local keep = y < 180 and 1 or (y < 230 and .35 or .2)
  if H(x, y, 77) < keep then
    if w % 5 == 0 and GX.vn(x, y, 6, 12) > .45 then c:px(x, y, SAND.shade)
    elseif w % 5 == 1 and GX.vn(x, y, 6, 13) > .6 then c:px(x, y, SAND.hi) end
  end
end end

-- cacti (saguaro)
local function saguaro(cx, yb, yt, w, arms, seed)
  local m = mk()
  RC(m, cx - w, yt + w, cx + w, yb); E(m, cx, yt + w, w)
  for _, a in ipairs(arms) do
    local ay, side, reach, rise = a[1], a[2], a[3], a[4]
    local aw = max(2, w - 2); local ex = cx + side * reach
    RC(m, min(cx, ex), ay - aw, max(cx, ex), ay + aw)
    RC(m, ex - aw, ay - rise, ex + aw, ay + aw); E(m, ex, ay - rise, aw)
  end
  m = GX.rough(m, seed, 1)
  local sh = mk(); E(sh, cx + w + 6, yb, w * 3, 3); c:fillMask(sh, SHADOW)
  GX.lit(c, m, R6(CACT), { R = w + 2, tex = .35, sc = 3, seed = seed, rimlight = true, amb = .22,
    fn = function(x, y) return (((x + 1000) // 3) % 2 - .5) * .16 end })
  m:each(function(x, y) if H(x, y, seed) < .02 and m:has(x - 1, y) and m:has(x + 1, y) then c:px(x, y, "#fff4b8") end end)
end
saguaro(24, 176, 56, 6, { { 124, 1, 18, 34 } }, 71)
saguaro(448, 172, 70, 6, { { 126, -1, 16, 30 }, { 100, 1, 12, 16 } }, 72)
saguaro(392, 164, 112, 4, {}, 73)

-- small boulders and a lone agave mid-distance
local function rock(x, y, rx, ry, seed)
  local m = mk(); E(m, x, y, rx, ry); m = GX.rough(m, seed, 1)
  local sh = mk(); E(sh, x + 2, y + ry, rx + 2, 2); c:fillMask(sh, SHADOW)
  GX.lit(c, m, R6({ hi = "#f4d8c0", base = "#c89080", shade = "#94607a", deep = "#5e3a58" }), { R = rx, tex = .4, sc = 3, seed = seed, rimlight = true })
end
rock(150, 172, 7, 4, 61); rock(318, 168, 5, 3, 62); rock(96, 168, 4, 3, 63)
local function agave(x, y, seed)
  local sh = mk(); E(sh, x + 3, y + 1, 16, 2); c:fillMask(sh, SHADOW)
  local ramps = { { hi = "#c8ecd0", base = "#78b8a0", shade = "#468c80", deep = "#285a62" }, { hi = "#b0e0b8", base = "#5ca890", shade = "#3a7a74", deep = "#244e5a" } }
  for i = 0, 8 do
    local ang = -84 + i * 21; local len = 20 - abs(i - 4) * 2
    local ex, ey = x + floor(len * sin(ang / 57.3)), y - floor(len * cos(ang / 57.3) * .9)
    local mx, my = (x + ex) // 2, (y + ey) // 2 - 2
    local lf = c:poly{ { x - 2, y }, { mx - 3, my }, { ex, ey }, { mx + 3, my + 3 }, { x + 2, y } }
    GX.lit(c, lf, R6(ramps[1 + i % 2]), { R = 3, tex = .25, sc = 2, seed = seed + i, rimlight = true })
  end
  c:px(x, y - 18, "#ffe38a")   -- quirk: one agave bud tip glints
end
agave(250, 176, 90)

-- calm walkable ground (y>=180): cracked clay, pebbles, dry tufts, bones
local function clay(cx, cy, rx, ry, seed)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  local CL = { hi = "#f0c890", base = "#d89c64", shade = "#b87850", deep = "#8a5440" }
  GX.lit(c, m, R6(CL), { R = 5, tex = .25, sc = 4, seed = seed, ink = false, amb = .4 })
  for i = 1, 7 do
    local x, y = cx + floor((H(i, seed, 1) - .5) * rx * 1.7), cy + floor((H(i, seed, 2) - .5) * ry * 1.7)
    for s = 1, 8 + floor(H(i, seed, 5) * 5) do
      if m:has(x, y) then c:px(x, y, CL.deep) end
      local r = H(x, y, seed + i)
      if r < .5 then x = x + 1 elseif r < .8 then y = y + (H(i, seed, 4) < .5 and 1 or -1) else x = x + 1; y = y + 1 end
    end
  end
end
clay(110, 244, 30, 6, 41); clay(300, 254, 34, 6, 42); clay(420, 236, 18, 5, 43)
for i = 0, 22 do
  local x, y = 8 + floor(H(i, 21, 5) * 465), 186 + floor(H(i, 22, 5) * 80)
  local m = mk(); E(m, x, y, 1 + i % 3, 1 + (i % 2))
  GX.lit(c, m, R6({ hi = "#f4d8c0", base = "#c89080", shade = "#94607a", deep = "#5e3a58" }), { R = 2, tex = .15, seed = i, rimlight = true })
end
for i = 0, 16 do
  local x, y = 8 + floor(H(i, 71, 1) * 464), 190 + floor(H(i, 73, 1) * 76)
  GX.tuft(c, x, y, GRASS)
end
for i = 0, 40 do local x, y = floor(H(i, 81, 1) * 480), 182 + floor(H(i, 83, 1) * 86); c:px(x, y, SAND.shade); c:px(x + 1, y, SAND.hi) end
for _, p in ipairs{ { 180, 220 }, { 360, 206 }, { 60, 252 } } do   -- small bleached bones
  c:fillMask(c:rect(p[1], p[2], p[1] + 6, p[2] + 1), BONE.base); c:px(p[1], p[2] - 1, BONE.hi); c:px(p[1] + 6, p[2] + 2, BONE.shade)
  c:px(p[1] - 1, p[2] + 1, BONE.hi); c:px(p[1] + 7, p[2], BONE.hi); c:px(p[1] + 1, p[2] + 2, BONE.shade)
end
-- tiny barrel cactus with a pink flower
do
  local cx, cy, rx, ry = 70, 226, 8, 7
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, 83, 1)
  local sh = mk(); E(sh, cx + 3, cy + ry, rx + 4, 2); c:fillMask(sh, SHADOW)
  GX.lit(c, m, R6(CACT), { R = rx, tex = .3, sc = 3, seed = 83, rimlight = true,
    fn = function(x, y) return (floor(((x - cx) / rx) * 5) % 2 - .5) * .22 end })
  c:fillMask(c:rect(cx - 1, cy - ry - 1, cx + 1, cy - ry), "#ff7aa8"); c:px(cx, cy - ry - 2, "#ffe38a")
end

c:save{ aseprite = d.."/out/stage-desert.aseprite", png = d.."/out/stage-desert.png", scale = 1 }
