-- wonder-glowworm-grotto v3: night cave, glowworm threads, teal pool, glow mushrooms, treasure alcove
local d = debug.getinfo(1,"S").source:match("^@(.*)[/\\][^/\\]*$")
local GX = dofile(d.."/../gather/gx.lua")
local HP, X = GX.HP, GX.X
local floor, max, min, abs, sin, cos, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.sqrt
local H, INK = X.hash, GX.INK
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "glowworm-grotto" }
local function mk() return HP.mask() end
local function E(m, cx, cy, rx, ry) return GX.disc(m, cx, cy, rx, ry or rx) end
local vn = GX.vn

local ROCK = { hi = "#9a8ac8", base = "#5e5294", shade = "#3c3470", deep = "#241e4a" }
local ROCK6 = GX.ramp6(ROCK)
local WAT = { hi = "#a4f4e4", base = "#2cb0b8", shade = "#1c7494", deep = "#143a68" }
local STN = { hi = "#b4b0d4", base = "#7a78a8", shade = "#504e80", deep = "#322f5a" }
local MUSH = { hi = "#c4fff0", base = "#46d0cc", shade = "#2a8aa8", deep = "#1c4a80" }
local WOOD = { hi = "#f0b068", base = "#b4683c", shade = "#7a3c3c", deep = "#46243c" }
local GOLD = { hi = "#fff0a0", base = "#f5cf6a", shade = "#c8883c", deep = "#7a4a3c" }
local CY, CORE = "#6ff0e4", "#eafffa"

-- soft flat-ring glow: per-pixel colour mix with what is already there (hard pixels, no alpha)
local function glow(cx, cy, r, col, str)
  str = str or 1
  local ts = { .10, .20, .36 }
  for y = cy - r, cy + r do for x = cx - r, cx + r do
    local dd = sqrt(((x - cx)) ^ 2 + ((y - cy) * 1.1) ^ 2) + (vn(x, y, 2.5, cx + cy) - .5) * 1.6
    local k = nil
    if dd < r * .38 then k = 3 elseif dd < r * .68 then k = 2 elseif dd < r then k = 1 end
    if k then local cur = c:get(x, y); if cur then c:px(x, y, GX.mix(cur, col, ts[k] * str)) end end
  end end
end
local function bead(x, y, col)
  col = col or CY
  glow(x, y, 7, col)
  c:px(x, y, CORE); c:px(x - 1, y, col); c:px(x + 1, y, col); c:px(x, y - 1, col); c:px(x, y + 1, col)
end

---------------------------------------------------------------- backdrop
GX.bands(c, 0, 269, { "#171335", "#1d1940", "#241f4e", "#2a2860", "#2a3468", "#25406c", "#1f3e66" }, 3, .22)
-- distant haze and far ridges
local function ridge(yfn, col, seed)
  for x = 0, 479 do for y = yfn(x), 215 do c:px(x, y, col) end end
end
ridge(function(x) return 150 + floor(14 * sin(x / 41) + 7 * sin(x / 15 + 2) + vn(x, 0, 9, 4) * 8) end, "#2b2d63")
ridge(function(x) return 172 + floor(9 * sin(x / 33 + 1) + 5 * sin(x / 11) + vn(x, 0, 7, 6) * 6) end, "#262856")
-- far stalagmites
for i = 0, 14 do
  local cx = 20 + floor(H(i, 1, 1) * 440); local h = 12 + floor(H(i, 2, 1) * 22)
  for y = 0, h do local hw = floor((h - y) * .16) ; for x = cx - hw, cx + hw do c:px(x, 190 - y + 6, x < cx and "#2f3170" or "#292b62") end end
end
-- distant crystal arch with stars (quirk of the original: a tiny window in the far wall)
do
  local m = mk()
  for y = 88, 130 do local hw = (y < 100) and floor((y - 86) * .9) or 12; for x = 406 - hw, 406 + hw do m:set(x, y) end end
  m = GX.rough(m, 17, 1)
  GX.lit(c, m, GX.ramp6({ hi = "#8a88d0", base = "#5c5aa6", shade = "#3c3a80", deep = "#262458" }), { R = 8, tex = .4, seed = 17, ink = "#1c1a40" })
  for _, p in ipairs{ { 403, 105 }, { 410, 98 }, { 400, 116 }, { 412, 112 } } do c:px(p[1], p[2], CORE) end
  c:px(404, 105, CY); c:px(402, 105, CY)
end

---------------------------------------------------------------- ceiling
local function ceilY(x) return 30 + floor(12 * sin(x / 52 + .6) + 7 * sin(x / 17 + 2) + vn(x, 0, 8, 9) * 10) end
local ceil = mk()
for x = 0, 479 do for y = 0, ceilY(x) do ceil:set(x, y) end end
c:rim(ceil, INK)
for x = 0, 479 do
  local yb = ceilY(x)
  for y = 0, yb do
    local t = (yb - y) / max(1, yb)
    local v = .72 - .62 * t + (vn(x, y, 6, 5) - .5) * .55 + (vn(x, y, 2.3, 8) - .5) * .12
    c:px(x, y, ROCK6[GX.idx(max(0, min(1, v)))])
  end
  -- warm-ish lip where light grazes, ink edge handled by rim
end
-- stalactites
local function stalac(cx, y0, h, w, seed, tipglow)
  local m = mk()
  for y = y0, y0 + h do
    local t = (y - y0) / h
    local hw = floor(w * (1 - t) ^ .9 + .5) + (t < .05 and 2 or 0)
    local off = floor((vn(0, y, 8, seed) - .5) * 4)
    for x = cx - hw + off, cx + hw + off do m:set(x, y) end
  end
  m = GX.rough(m, seed, 1)
  GX.lit(c, m, ROCK6, { R = w * 1.2, tex = .5, sc = 3, seed = seed, amb = .25, rimlight = true })
  -- cool light catching the tip
  m:each(function(x, y) if y > y0 + h * .78 and not m:has(x, y + 1) then c:px(x, y, CY) end end)
  if tipglow then glow(cx, y0 + h + 3, 6, CY, .8) ; c:px(cx, y0 + h + 3, CORE) end
end
for _, s in ipairs{ { 30, 34, 38, 10, 21, true }, { 66, 62, 24, 9, 22 }, { 168, 36, 56, 15, 23, true }, { 254, 58, 44, 11, 24 }, { 300, 54, 40, 12, 25, true },
  { 372, 54, 32, 9, 26 }, { 450, 52, 28, 8, 27, true }, { 120, 40, 20, 6, 28 }, { 224, 44, 18, 5, 29 }, { 410, 46, 22, 6, 30 } } do
  stalac(s[1], s[2], s[3], s[4], s[5], s[6])
end
-- glowing moss dots along the ceiling lip
for x = 4, 476, 3 do
  if H(x, 5, 3) < .33 then
    local y = ceilY(x) + 2 + floor(H(x, 6, 3) * 6)
    c:px(x, y, CY); if H(x, 7, 3) < .4 then c:px(x + 1, y + 1, "#2aa8b0") end
    if H(x, 8, 3) < .15 then c:px(x, y, CORE) end
  end
end

---------------------------------------------------------------- side walls
local function wallL(y) return 22 + floor(8 * sin(y / 31) + 4 * sin(y / 11 + 1) + (y - 40) * .06) end
local function wallR(y) return 458 - floor(6 * sin(y / 27 + 2) + 4 * sin(y / 9) + max(0, (y - 120)) * .02) - max(0, 130 - y) * 0 end
local function sideWall(fx, left, seed)
  local m = mk()
  for y = 0, 269 do
    local e = fx(y)
    if left then for x = 0, e do m:set(x, y) end else for x = e, 479 do m:set(x, y) end end
  end
  m = GX.rough(m, seed, 1)
  c:rim(m, INK)
  m:each(function(x, y)
    local e = fx(y)
    local dist = left and (e - x) or (x - e)
    local v = .62 - dist * .018 + (left and .1 or -.12) + (vn(x, y, 7, seed) - .5) * .6 + (vn(x, y, 2.4, seed + 3) - .5) * .12
    if dist < 4 then v = v + (left and .18 or -.06) end
    if H(x // 2, y // 6, seed) < .05 then v = v - .2 end
    c:px(x, y, ROCK6[GX.idx(max(0, min(1, v)))])
  end)
  return m
end
sideWall(wallL, true, 61)
sideWall(wallR, false, 63)
-- walls' glowing moss
for y = 30, 240, 4 do
  if H(y, 2, 5) < .4 then c:px(wallL(y) - 1 - floor(H(y, 3, 5) * 3), y, CY) end
  if H(y, 4, 5) < .3 then c:px(wallR(y) + 1 + floor(H(y, 5, 5) * 3), y, "#46d8d0") end
end

---------------------------------------------------------------- floor
GX.ground(c, function(x) return 196 + floor(4 * sin(x / 23) + 2 * sin(x / 9)) end, ROCK, 71, { top = .55, fall = .5, tex = .5, sc = 6 })
-- re-cover walls over floor edges
sideWall(wallL, true, 61); sideWall(wallR, false, 63)

---------------------------------------------------------------- pool
local pm = mk(); E(pm, 236, 224, 190, 32); pm = GX.rough(pm, 81, 2)
local bank = pm:copy():grow(2); bank = GX.rough(bank, 83, 1)
c:fillMask(bank, ROCK.deep)
c:rim(bank, INK)
local W6 = GX.ramp6(WAT)
GX.lit(c, pm, W6, { R = 16, tex = .3, sc = 5, seed = 9, amb = .4, wrap = .5, ink = INK,
  fn = function(x, y) return (vn(x * .25, y, 4, 12) - .5) * .3 - ((y - 192) / 64) * .12 - .22 end })
-- horizontal ripple dashes + reflected glow
for i = 0, 70 do
  local x, y = 60 + floor(H(i, 1, 9) * 360), 196 + floor(H(i, 2, 9) * 54)
  if pm:has(x, y) and pm:has(x + 5, y) then
    local w = 3 + floor(H(i, 3, 9) * 5)
    for k = 0, w do if pm:has(x + k, y) then c:px(x + k, y, i % 3 == 0 and WAT.hi or WAT.shade) end end
  end
end
-- reflected strand cluster (vertical dotted streaks)
for i = 0, 14 do
  local x = 214 + floor(H(i, 5, 9) * 50); local y = 202 + floor(H(i, 6, 9) * 30)
  for k = 0, 3 do if pm:has(x, y + k * 2) then c:px(x, y + k * 2, k == 0 and CORE or CY) end end
end
for i = 0, 22 do
  local x, y = 70 + floor(H(i, 7, 9) * 340), 200 + floor(H(i, 8, 9) * 48)
  if pm:has(x, y) then c:px(x, y, CORE) end
end
-- bank highlight along far (upper) edge
pm:each(function(x, y) if not pm:has(x, y - 1) and vn(x, y, 4, 3) > .3 then c:px(x, y, GX.mix(WAT.base, WAT.hi, .5)) end end)

---------------------------------------------------------------- boulders / stepping stones
local function stone(cx, cy, rx, ry, seed, wet)
  local sh = mk(); E(sh, cx + 2, cy + ry, rx + 2, 2); c:fillMask(sh, wet and WAT.deep or ROCK.deep)
  local m = mk(); E(m, cx, cy, rx, ry); m = GX.rough(m, seed, 2)
  GX.lit(c, m, GX.ramp6(STN), { R = max(rx, ry) * .9, tex = .45, sc = 3, seed = seed, rimlight = true })
  -- cyan water-glow bounce on the lower edge, moss fleck
  m:each(function(x, y)
    if not m:has(x, y + 1) and H(x, y, seed) < .55 then c:px(x, y, GX.mix(STN.shade, WAT.base, .5)) end
    if H(x // 2, y // 2, seed + 4) < .06 and y < cy then c:px(x, y, "#5ac8b4") end
  end)
end
for _, s in ipairs{ { 160, 221, 17, 7 }, { 209, 233, 17, 8 }, { 261, 225, 17, 8 }, { 309, 236, 17, 8 }, { 192, 257, 20, 8 }, { 298, 256, 20, 8 } } do
  stone(s[1], s[2], s[3], s[4], 90 + s[1] % 17, true)
end
stone(40, 248, 26, 13, 101); stone(120, 255, 19, 8, 103); stone(386, 246, 28, 13, 105); stone(436, 244, 22, 10, 107)
stone(66, 214, 10, 5, 109)

---------------------------------------------------------------- glow mushrooms (left)
local function mush(cx, cy, cr, seed)
  -- stem
  local st = c:rect(cx - 1, cy, cx + 1, cy + 8); GX.lit(c, st, GX.ramp6({ hi = "#f0e8ff", base = "#b4a8d8", shade = "#7a6eac", deep = "#463e78" }), { R = 2, seed = seed })
  glow(cx, cy, 16, CY, .9)
  local m = mk(); E(m, cx, cy, cr, floor(cr * .7)); m = GX.rough(m, seed, 1)
  m:cut(c:rect(cx - cr - 2, cy + floor(cr * .45), cx + cr + 2, cy + cr + 2))
  GX.lit(c, m, GX.ramp6(MUSH), { R = cr, tex = .35, sc = 2.5, seed = seed, amb = .35, rimlight = true })
  for _, p in ipairs{ { -cr // 2, -1 }, { 0, -cr // 2 }, { cr // 2, 0 } } do c:px(cx + p[1], cy + p[2], CORE); c:px(cx + p[1] + 1, cy + p[2], CY) end
  c:px(cx, cy + 10, "#ffd870"); c:px(cx, cy + 11, "#e8a030")
end
mush(80, 226, 9, 121); mush(100, 232, 7, 123); mush(60, 238, 5, 125)
for _, p in ipairs{ { 130, 218 }, { 48, 222 } } do bead(p[1], p[2]) end

---------------------------------------------------------------- treasure alcove (right)
do
  local hol = mk()
  for y = 158, 224 do
    local t = (y - 158) / 66
    local hw = (t < .32) and floor(sqrt(max(0, 1 - ((.32 - t) / .32) ^ 2)) * 25) or 25
    for x = 444 - hw, 444 + hw do hol:set(x, y) end
  end
  hol = GX.rough(hol, 131, 1)
  local frame = hol:copy():grow(3); frame = GX.rough(frame, 133, 1)
  c:fillMask(frame, ROCK.shade); c:rim(frame, INK)
  hol:each(function(x, y)  -- warm gold glow interior, brighter toward chest
    local dd = sqrt((x - 444) ^ 2 + ((y - 214) * 1.1) ^ 2)
    local k = 1; if dd < 34 then k = 2 end; if dd < 24 then k = 3 end; if dd < 14 then k = 4 end
    local cols = { "#2a1c3a", "#5a3040", "#8c4c40", "#c8783c" }
    c:px(x, y, cols[k])
  end)
  c:rim(hol, INK)
  -- ledge slab
  local led = c:rect(410, 222, 476, 232); led = GX.rough(led, 135, 1)
  GX.lit(c, led, GX.ramp6(STN), { R = 8, tex = .4, seed = 135, rimlight = true })
  -- chest
  local body = c:rect(430, 205, 458, 221); GX.lit(c, body, GX.ramp6(WOOD), { R = 6, tex = .3, seed = 137, rimlight = true })
  for x = 430, 458 do if (x - 430) % 7 == 3 then for y = 205, 221 do c:px(x, y, WOOD.shade) end end end
  local lid = mk(); for y = 195, 205 do local t = (205 - y) / 10; local hw = floor(14 - t * t * 5); for x = 444 - hw, 444 + hw do lid:set(x, y) end end
  GX.lit(c, lid, GX.ramp6(WOOD), { R = 6, tex = .3, seed = 139, rimlight = true })
  for y = 195, 221 do c:px(444, y, GOLD.base); c:px(445, y, GOLD.shade) end
  c:fillMask(c:rect(441, 208, 447, 212), GOLD.base); c:px(441, 208, GOLD.hi); c:px(442, 208, GOLD.hi); c:px(444, 210, INK)
  for x = 430, 458 do c:px(x, 205, GOLD.base) end
  -- coins spill
  for _, p in ipairs{ { 424, 221 }, { 428, 220 }, { 460, 221 }, { 463, 220 }, { 452, 222 } } do c:px(p[1], p[2], GOLD.base); c:px(p[1] + 1, p[2], GOLD.hi); c:px(p[1], p[2] + 1, GOLD.shade) end
  -- warm light bleeding onto ledge
  glow(444, 214, 40, "#ffb860", .5)
  for _, p in ipairs{ { 438, 196 }, { 452, 193 }, { 460, 200 } } do c:px(p[1], p[2], GOLD.hi) end
end

---------------------------------------------------------------- glowworm threads
local function strand(x0, y0, len, seed, col)
  local x = x0
  for k = 0, len do
    x = x0 + floor(sin(k / 7 + seed) * 2 + .5)
    local y = y0 + k
    c:px(x, y, GX.mix("#6a60a8", CY, .35))
    if k > 3 and k % 6 == 0 then bead(x, y, col) end
  end
  bead(x, y0 + len + 1, col)
end
local cluster = { { 214, 40, 54 }, { 224, 44, 70 }, { 233, 38, 80 }, { 242, 42, 62 }, { 250, 40, 92 }, { 259, 44, 56 }, { 268, 46, 72 }, { 205, 42, 40 }, { 278, 48, 46 } }
for i, s in ipairs(cluster) do strand(s[1], ceilY(s[1]) - 2, s[3] - 28 + floor(H(i, 1, 4) * 6), i * 1.7) end
for i, s in ipairs{ { 140, 70 }, { 180, 30 }, { 316, 20 }, { 340, 36 }, { 366, 12 } } do strand(s[1], ceilY(s[1]) + 1 - ((i == 2) and 40 or 0) + ((i == 2) and 40 or 0), s[2], i * 2.3 + 1) end
-- drifting lights toward the alcove, each with a little tail
for i, p in ipairs{ { 282, 138 }, { 306, 150 }, { 332, 160 }, { 358, 168 }, { 388, 178 }, { 410, 190 } } do
  bead(p[1], p[2]); c:px(p[1] - 1, p[2] + 3, CY); c:px(p[1] - 1, p[2] + 4, "#2aa8b0")
end

---------------------------------------------------------------- quirk: tiny glow-snail on the front stone
do
  local sx, sy = 392, 232
  local body = c:rect(sx, sy + 3, sx + 7, sy + 4); GX.lit(c, body, GX.ramp6({ hi = "#e8ffe8", base = "#9ad8b8", shade = "#5a9c94", deep = "#2c5a6c" }), { R = 2, seed = 5 })
  local shell = mk(); E(shell, sx + 3, sy + 1, 3, 3); GX.lit(c, shell, GX.ramp6(MUSH), { R = 3, seed = 6, rimlight = true })
  c:px(sx + 3, sy + 1, CORE); c:px(sx + 8, sy + 1, STN.hi); c:px(sx + 8, sy + 2, INK)
  glow(sx + 3, sy + 1, 8, CY, .7)
end

---------------------------------------------------------------- floating dust-spores
for i = 0, 40 do
  local x, y = 30 + floor(H(i, 1, 6) * 420), 60 + floor(H(i, 2, 6) * 150)
  if H(i, 3, 6) < .5 and not (x > 405 and y > 150) then c:px(x, y, i % 4 == 0 and CORE or CY) end
end

---------------------------------------------------------------- gold stitched hem (top and bottom)
for _, y in ipairs{ 2, 3, 266, 267 } do
  for x = 0, 479 do if x % 6 < 4 then c:px(x, y, "#f5cf6a") else c:px(x, y, "#3a3a66") end end
end
for x = 0, 479 do for _, y in ipairs{ 0, 1, 4, 264, 265, 268, 269 } do
  if y <= 1 or y == 4 or y >= 264 then
    if y == 0 or y == 1 or y == 269 or y == 268 then c:px(x, y, "#3a3a66") end
  end
end end

c:save{ aseprite = d.."/out/wonder-glowworm-grotto.aseprite", png = d.."/out/wonder-glowworm-grotto.png", scale = 1 }
