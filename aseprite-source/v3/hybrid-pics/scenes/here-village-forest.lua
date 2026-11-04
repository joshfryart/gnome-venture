-- here-village-forest: forest village hub, 240x135 grid x2 = 480x270. Horizon y=56 (112 @2x).
-- Planes: sky (4 bands, sun, puffs) / far ridges (flat, low contrast) / mid village (cottage, shop, well,
-- hero tree, pines) / near (ink-ish edged bushes, grass blades, branch). Paths radiate from the green.
-- quirk: a sparrow sits on the scarecrow's hat; the cat on the cottage ridge has noticed.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 135, scale = 2, name = "here-village-forest" }
local floor, sin, cos, abs, sqrt = math.floor, math.sin, math.cos, math.abs, math.sqrt
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local function H(x, y, s) local v = sin(x * 12.9898 + y * 78.233 + s * 37.719) * 43758.5453 return v - floor(v) end
local HOR = 56

------------------------------------------------------------ SKY: 4 flat bands, sun, puffs, birds
c:stripes(0, HOR, { P.sky.shade, P.sky.base, P.sky.hi, P.gold.hi }, { 14, 14, 14, 14 })
c:fillMask(E(118, 20, 9, 9), P.gold.base) c:fillMask(E(117, 19, 6, 6), P.gold.hi)
c:cloud(46, 34, 28, P.cream, P.sky.hi)
c:cloud(150, 30, 22, P.cream, P.sky.hi)
c:cloud(70, 14, 16, P.cream, P.sky.hi)
for _, b in ipairs{ {150, 10}, {158, 14}, {168, 8} } do
  c:px(b[1], b[2], P.wood.deep) c:px(b[1] + 1, b[2] + 1, P.wood.deep) c:px(b[1] + 2, b[2], P.wood.deep) c:px(b[1] + 3, b[2] + 1, P.wood.deep) c:px(b[1] + 4, b[2], P.wood.deep)
end

------------------------------------------------------------ FAR ridges (flat, low contrast)
c:terrain(function(x) return 40 + 5 * sin(x / 27 + 1) + 2 * sin(x / 9) end, P.dusk.hi, HOR + 1)
local ridge = function(x) return 49 + 3 * sin(x / 19 + 2) + 1.5 * sin(x / 7) end
c:terrain(ridge, P.sea.hi, HOR + 1)
for x = 2, 238, 7 do
  local r = 3 + floor(H(x, 1, 3) * 3)
  c:fillMask(E(x, ridge(x) - 1, r, r):clip(c:rect(0, 0, 239, HOR)), P.sea.hi)
end
c:terrain(function(x) return 54 + 1.5 * sin(x / 11) end, P.sea.base, HOR + 1)

------------------------------------------------------------ GROUND: meadow bands (mid), near
R(0, HOR, 239, 134, P.moss.hi)
c:terrain(function(x) return 70 + 2 * sin(x / 33) end, P.moss.base)
c:terrain(function(x) return 97 + 2 * sin(x / 21 + 1) end, P.moss.base)
for x = 0, 239 do local y = 97 + 2 * sin(x / 21 + 1) if H(x, 2, 1) < .5 then c:px(x, floor(y), P.moss.shade) end end

------------------------------------------------------------ PATHS (8 stubs radiating from the green)
local CX, CY = 120, 85
local exits = { N = {120, 59}, NE = {186, 64}, E = {226, 88}, SE = {198, 118}, S = {120, 129}, SW = {42, 118}, W = {14, 88}, NW = {54, 64} }
local pathM = HP.mask()
for k, e in pairs(exits) do
  local dx, dy = e[1] - CX, e[2] - CY
  local L = sqrt(dx * dx + dy * dy)
  local ex, ey = e[1] + dx / L * 6, e[2] + dy / L * 6
  if ey < 57 then ey = 57 end
  local w0, w1 = 1.5, 1.5 + (ey - 56) / 9
  local nx, ny = -dy / L, dx / L
  pathM:add(c:poly{ { CX + nx * w0, CY + ny * w0 }, { ex + nx * w1, ey + ny * w1 }, { ex - nx * w1, ey - ny * w1 }, { CX - nx * w0, CY - ny * w0 } })
end
local ring = pathM:copy():grow(1):cut(pathM)
ring:each(function(x, y) if y > HOR and H(x, y, 4) < .55 then c:px(x, y, P.moss.shade) end end)
c:fillMask(pathM, P.wood.hi)
pathM:each(function(x, y)
  local h = H(x, y, 5)
  if not pathM:has(x + 1, y + 1) then c:px(x, y, P.wood.base)
  elseif h < .05 then c:px(x, y, P.wood.base) elseif h > .955 then c:px(x, y, P.stone.hi) elseif h > .93 then c:px(x, y, P.gold.hi) end
end)

------------------------------------------------------------ the green (square) + cobble ring
c:fillMask(E(CX, CY, 17, 7), P.moss.hi)
for i = 0, 27 do
  local a = i / 28 * 6.2832
  local x, y = floor(CX + 18 * cos(a) + .5), floor(CY + 7.6 * sin(a) + .5)
  c:fillMask(E(x, y, 1.5, 1), P.stone.base) c:px(x - 1, y - 1, P.stone.hi) c:px(x + 1, y + 1, P.stone.shade)
end
for _, f in ipairs{ {106, 82}, {132, 89}, {112, 90}, {136, 81} } do c:px(f[1], f[2], P.cream) c:px(f[1], f[2] + 1, P.moss.shade) end

------------------------------------------------------------ ground jobs: tufts, litter, moss, stones
local stands = { {100, 100}, {140, 103}, {60, 107}, {180, 107}, {120, 116}, {30, 111} }
local spots = { {120, 85}, {165, 75}, {75, 75} }
local function nearSlot(x, y)
  for _, s in ipairs(stands) do if abs(x - s[1]) < 5 and abs(y - s[2]) < 3 then return true end end
  for _, s in ipairs(spots) do if abs(x - s[1]) < 7 and abs(y - s[2]) < 4 then return true end end
  return false
end
for y = HOR + 2, 134 do for x = 0, 239 do
  if not pathM:has(x, y) and not ring:has(x, y) and not ((x - CX) ^ 2 / 324 + (y - CY) ^ 2 / 64 < 1) and not nearSlot(x, y) then
    local h, near = H(x, y, 1), y > 97
    if h < (near and .022 or .014) then
      c:px(x, y, P.moss.shade) c:px(x, y - 1, P.moss.hi) if near then c:px(x + 1, y - 2, P.moss.hi) c:px(x + 1, y - 1, P.moss.shade) end
    elseif h < .028 then c:px(x, y, P.ember.base) c:px(x + 1, y, P.gold.base)
    elseif h < .033 then c:px(x, y, P.gold.hi)
    elseif h > .985 then c:px(x, y, P.stone.hi) c:px(x + 1, y, P.stone.base) end
  end
end end
for _, m in ipairs{ {42, 102, 7, 2}, {182, 126, 8, 2}, {84, 126, 9, 2}, {160, 100, 6, 2}, {12, 76, 6, 2} } do
  c:fillMask(E(m[1], m[2], m[3], m[4]):cut(pathM), P.moss.shade)
  for i = 0, 4 do c:px(m[1] - m[3] + 2 + i * 3, m[2] - 1, P.moss.hi) end
end
local function stone(x, y, rx, ry, i) c:part(E(x, y, rx, ry), "stone", { band = 1, nopop = i % 2 == 0 }) end
for i, s in ipairs{ {10, 108, 3, 2}, {151, 124, 3, 2}, {100, 130, 2, 1}, {200, 101, 3, 2}, {80, 96, 2, 1}, {170, 94, 2, 1} } do
  c:fillMask(E(s[1] + 1, s[2] + s[4], s[3] + 1, 1), P.moss.shade) stone(s[1], s[2], s[3], s[4], i)
end

------------------------------------------------------------ helpers: trees, barrels, mushrooms
local function speckle(m, cy, hi, sh, dens)
  m:each(function(x, y)
    local h = H(x, y, 9)
    if h < dens * (y >= cy and 1.6 or .8) and m:has(x, y - 1) then c:px(x, y, sh) elseif h > 1 - dens * (y < cy and 1.3 or .6) and m:has(x, y + 1) then c:px(x, y, hi) end
  end)
end
local function pine(x, by, w, hgt)
  local m = HP.mask()
  for i = 0, 3 do
    local ty = by - hgt + i * hgt / 4.5
    local ww = w * (0.45 + i * .22)
    m:add(c:poly{ { x, ty }, { x + ww, ty + hgt / 3 }, { x - ww, ty + hgt / 3 } })
  end
  local tr = c:rect(x - 1, by - 3, x + 1, by)
  c:fillMask(E(x + 2, by, w * .8, 1.5), P.moss.shade)
  c:part(tr, "wood", { band = 1, nopop = true })
  c:part(m, "moss", { band = 2, pop = { x - 2, by - hgt + 6 } })
  speckle(m, by - hgt / 2, P.moss.hi, P.moss.deep, .06)
end
local function roundTree(x, by, rx, ry, th)
  c:fillMask(E(x + 3, by, rx * .7, 2), P.moss.shade)
  local tr = c:poly{ { x - 3, by }, { x + 3, by }, { x + 1, by - th }, { x - 1, by - th } }
  local cr = E(x, by - th - ry * .6, rx, ry):add(E(x - rx * .6, by - th, rx * .5, ry * .55)):add(E(x + rx * .6, by - th, rx * .5, ry * .55))
  c:part(tr, "wood", { band = 1, nopop = true })
  c:part(cr, "moss", { band = 3, pop = { x - rx // 2, by - th - ry } })
  speckle(cr, by - th - ry * .5, P.moss.hi, P.moss.deep, .07)
end
local function barrel(x, y)
  local b = c:rrect(x - 3, y - 7, x + 3, y, 2)
  c:fillMask(E(x + 2, y + 1, 4, 1), P.moss.shade)
  c:rim(b, P.wood.deep) c:part(b, "wood", { band = 2, nopop = true })
  R(x - 3, y - 5, x + 3, y - 5, P.stone.base) R(x - 3, y - 2, x + 3, y - 2, P.stone.base) c:px(x - 2, y - 6, P.wood.hi)
end
local function mush(x, y, s, col)
  local stem = c:rect(x, y - 2 * s, x + s - 1, y)
  c:fillMask(stem, P.cream) c:px(x + s - 1, y - 1, P.stone.hi)
  local cap = E(x + (s - 1) / 2, y - 2 * s, s + 1, s):clip(c:rect(0, 0, 239, y - 2 * s + (s > 1 and 1 or 0)))
  c:part(cap, col or "ember", { band = 1, nopop = true })
  c:px(x, y - 2 * s - 1, P.cream)
end
local function tiles(m, ramp, y0, y1, step, x0, x1)
  c:part(m, ramp, { band = 3, nopop = true, inner = false })
  local k = 0
  for y = y0, y1, step do
    for x = x0, x1 do if m:has(x, y) then c:px(x, y, P[ramp].shade) end end
    for x = x0 + (k % 2) * 2, x1, 4 do for yy = y + 1, y + step - 1 do if m:has(x, yy) then c:px(x, yy, P[ramp].shade) end end end
    for x = x0 + 1, x1, 4 do if m:has(x, y - 1) and m:has(x, y) and H(x, y, 6) < .3 then c:px(x, y - 1, P[ramp].hi) end end
    k = k + 1
  end
end

------------------------------------------------------------ MID: pines and round trees along the back
pine(104, 60, 7, 24) pine(140, 60, 7, 26) pine(94, 58, 5, 17)
roundTree(40, 62, 11, 9, 8)
pine(8, 64, 7, 24)
pine(150, 58, 5, 16)

------------------------------------------------------------ well (hero 2) at far left
do
  local body = c:rrect(17, 63, 31, 72, 1)
  local roof = c:poly{ { 14, 57 }, { 24, 49 }, { 34, 57 } }
  local posts = c:rect(18, 57, 19, 63):add(c:rect(29, 57, 30, 63))
  c:fillMask(E(26, 73, 11, 2), P.moss.shade)
  c:rim(body:copy():add(roof):add(posts), P.stone.deep)
  c:part(posts, "wood", { band = 1, nopop = true })
  R(23, 57, 24, 62, P.wood.shade) R(24, 62, 24, 64, P.cream) c:fillMask(c:rect(22, 63, 26, 64), P.wood.base) c:px(22, 63, P.wood.hi)
  c:part(body, "stone", { band = 3, pop = { 19, 64 } })
  for y = 65, 71, 3 do R(17, y, 31, y, P.stone.shade) end
  for i = 0, 4 do R(18 + i * 3 + (i % 2), 66, 18 + i * 3 + (i % 2), 67, P.stone.shade) end
  c:part(roof, "ember", { band = 2, pop = { 21, 53 } })
  R(15, 57, 33, 57, P.ember.shade)
  for x = 18, 30, 3 do c:px(x, 54, P.ember.shade) c:px(x + 1, 55, P.ember.shade) end
end

------------------------------------------------------------ HERO: cottage (dusk tile roof, timber walls)
do
  local WALL = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
  local wall = c:rect(60, 52, 90, 68)
  local roof = c:poly{ { 54, 54 }, { 75, 34 }, { 96, 54 } }
  local chim = c:rect(83, 28, 88, 46)
  local home = wall:copy():add(roof):add(chim)
  c:fillMask(E(78, 69, 27, 2), P.moss.shade)
  c:rim(home, P.wood.deep)
  c:part(chim, "stone", { band = 1, nopop = true })
  for y = 30, 44, 4 do R(83, y, 88, y, P.stone.shade) end
  R(82, 27, 89, 28, P.stone.base) R(82, 27, 89, 27, P.stone.hi)
  c:part(wall, WALL, { band = 3, nopop = true })
  for _, x in ipairs{ 62, 74, 76, 88 } do R(x, 54, x, 68, P.wood.base) end
  R(60, 60, 90, 60, P.wood.base)
  for x = 62, 88, 5 do c:px(x, 56, P.stone.shade) c:px(x + 2, 64, P.stone.shade) end
  R(60, 66, 90, 68, P.stone.shade) for x = 60, 90, 4 do R(x, 66, x + 2, 67, P.stone.base) c:px(x, 66, P.stone.hi) end
  tiles(roof, "dusk", 37, 53, 3, 54, 96)
  R(54, 54, 96, 54, P.dusk.deep)
  for x = 56, 94, 4 do c:px(x, 55, P.dusk.shade) end
  c:fillMask(E(75, 47, 2, 2), P.gold.hi) c:px(75, 46, P.cream) R(73, 47, 77, 47, P.wood.deep)
  -- door
  local door = E(75, 63, 4, 5):clip(c:rect(0, 0, 239, 68))
  c:rim(door, P.wood.deep) c:part(door, "sea", { band = 2, pop = { 72, 59 } }) R(75, 59, 75, 68, P.sea.shade) c:px(77, 64, P.gold.hi)
  -- windows with flower boxes
  for _, wx in ipairs{ 66, 84 } do
    R(wx - 2, 58, wx + 2, 62, P.wood.deep) R(wx - 1, 59, wx + 1, 61, P.gold.hi) c:px(wx, 59, P.cream) R(wx, 59, wx, 61, P.wood.base)
    R(wx - 3, 63, wx + 3, 64, P.wood.base)
    for i = -2, 2 do c:px(wx + i, 62, (i % 2 == 0) and P.petal.base or P.gold.base) end
    c:px(wx - 3, 62, P.moss.base) c:px(wx + 3, 62, P.moss.base)
  end
  -- smoke
  c:fillMask(E(86, 24, 3, 2), P.cream) c:fillMask(E(89, 19, 4, 2), P.stone.hi) c:fillMask(E(94, 14, 5, 2), P.cream) c:px(85, 23, P.stone.hi)
  -- cat on the ridge (quirk), watching the scarecrow
  c:paint({
    "......k.k",
    "......kkk",
    "t.kkkkkek",
    "t.kkkkkkk",
    "ttkdkdkkk",
    ".tkkkkkkk",
    "..ww..ww.",
  }, 71, 28, { k = "ember.base", t = "ember.shade", d = "ember.shade", e = "#2b1c26", w = "cream" })
end

------------------------------------------------------------ HERO: shop (stall under blue-tile roof)
do
  local wall = c:rect(153, 54, 177, 68)
  local roof = c:poly{ { 148, 56 }, { 165, 41 }, { 182, 56 } }
  local home = wall:copy():add(roof)
  c:fillMask(E(166, 69, 18, 2), P.moss.shade)
  c:rim(home, P.wood.deep)
  c:part(wall, "wood", { band = 3, nopop = true })
  for x = 156, 176, 4 do R(x, 55, x, 67, P.wood.base) end
  R(157, 58, 173, 65, P.wood.deep)
  R(157, 62, 173, 62, P.wood.base)
  for i, x in ipairs{ 159, 163, 167, 171 } do
    c:fillMask(E(x, 61, 1, 1), ({ P.petal.base, P.gold.base, P.ember.base, P.sea.base })[i]) c:px(x - 1, 60, P.cream)
    c:fillMask(E(x, 64, 1, 1), ({ P.sea.hi, P.moss.base, P.petal.hi, P.gold.hi })[i])
  end
  tiles(roof, "sea", 44, 55, 3, 148, 182)
  R(148, 56, 182, 56, P.sea.deep)
  for x = 150, 180, 2 do R(x, 57, x, 58, (x // 2) % 2 == 0 and P.cream or P.petal.base) end
  R(154, 59, 176, 59, P.petal.shade)
  -- hanging sign with a mushroom
  R(147, 58, 150, 58, P.wood.deep) R(148, 59, 148, 60, P.wood.deep)
  R(146, 61, 150, 64, P.wood.base) c:px(146, 61, P.wood.hi) c:fillMask(E(148, 62, 1, 1), P.ember.base) c:px(148, 64, P.cream)
  barrel(145, 70) barrel(184, 70)
  c:part(c:rect(186, 66, 190, 70), "wood", { band = 1, nopop = true }) R(186, 68, 190, 68, P.wood.deep)
end

------------------------------------------------------------ HERO: giant tree (right) with a gnome knot-door
do
  local tr = c:poly{ { 201, 69 }, { 221, 69 }, { 217, 62 }, { 215, 36 }, { 207, 36 }, { 205, 62 } }
  local cr = E(212, 20, 26, 17):add(E(190, 32, 14, 10)):add(E(234, 32, 12, 10)):add(E(214, 36, 20, 7)):add(E(196, 12, 12, 10))
  c:fillMask(E(214, 70, 14, 2), P.moss.shade)
  c:rim(tr, P.wood.deep) c:part(tr, "wood", { band = 3, pop = { 207, 44 } })
  for x = 205, 217 do for y = 38, 67 do
    if tr:has(x, y) and H(x, floor(y / 4), 8) < .17 and y % 4 ~= 0 then c:px(x, y, P.wood.shade) end
  end end
  for _, r in ipairs{ {203, 66}, {219, 66} } do c:px(r[1], r[2], P.wood.deep) end
  c:fillMask(E(210, 61, 2, 3):clip(c:rect(0, 0, 239, 63)), P.wood.deep)
  c:px(210, 60, P.gold.hi) c:px(211, 60, P.gold.base) R(208, 64, 212, 64, P.stone.base) c:px(208, 64, P.stone.hi)
  c:px(213, 58, P.gold.hi)
  c:rim(cr, P.moss.deep) c:part(cr, "moss", { band = 3, pop = { 196, 8 } })
  speckle(cr, 22, P.moss.hi, P.moss.deep, .09)
  for _, a in ipairs{ {200, 40}, {222, 38}, {212, 41}, {186, 36} } do c:px(a[1], a[2], P.ember.base) c:px(a[1] + 1, a[2], P.ember.hi) end
  -- log pile at its root
  for i, l in ipairs{ {226, 71}, {231, 71}, {228, 67} } do
    local lm = E(l[1], l[2], 3, 2)
    c:rim(lm, P.wood.deep) c:part(lm, "wood", { band = 1, nopop = true }) c:px(l[1], l[2], P.wood.hi) c:px(l[1] + 1, l[2], P.wood.base)
  end
  c:px(222, 72, P.gold.hi)
end

------------------------------------------------------------ mid vignettes
-- beehive + bee
do
  local hv = E(100, 69, 3, 3):clip(c:rect(0, 0, 239, 70))
  c:fillMask(E(101, 71, 4, 1), P.moss.shade)
  c:rim(hv, P.wood.deep) c:part(hv, "gold", { band = 1, nopop = true })
  R(98, 67, 102, 67, P.gold.shade) c:px(100, 69, P.wood.deep) c:px(100, 70, P.wood.deep)
  c:px(106, 66, P.gold.base) c:px(107, 66, P.ink) c:px(106, 65, P.cream)
end
-- mushrooms, flowers
mush(48, 80, 1, "ember") mush(51, 81, 2, "ember") mush(54, 80, 1, "petal")
mush(194, 95, 2, "petal") mush(198, 96, 1, "petal") mush(190, 96, 1, "ember")
mush(90, 111, 1, "ember") mush(93, 112, 2, "ember")
for i = 0, 6 do
  local fx, fy = 196 + i * 3, 78 + (i % 3)
  c:px(fx, fy + 1, P.moss.shade) c:px(fx, fy, ({ P.petal.base, P.gold.hi, P.dusk.hi, P.cream })[i % 4 + 1])
end
for i = 0, 5 do local fx, fy = 30 + i * 3, 84 + (i % 2) c:px(fx, fy + 1, P.moss.shade) c:px(fx, fy, ({ P.gold.hi, P.petal.hi, P.cream })[i % 3 + 1]) end
-- picket fence stub near the homes
do
  local fm = HP.mask()
  for x = 94, 112, 4 do fm:add(c:rect(x, 74, x + 1, 78)) end
  fm:add(c:rect(94, 75, 113, 75)):add(c:rect(94, 77, 113, 77))
  c:rim(fm, P.wood.deep) c:fillMask(fm, P.cream) fm:each(function(x, y) if not fm:has(x + 1, y) or not fm:has(x, y + 1) then c:px(x, y, P.stone.hi) end end)
end

------------------------------------------------------------ scarecrow garden (bottom right) + bird quirk
do
  c:fillMask(E(222, 113, 15, 5), P.wood.shade)
  c:fillMask(E(222, 113, 15, 5):clip(c:rect(0, 0, 239, 110)), P.wood.base)
  for i = 0, 3 do
    local x = 210 + i * 8
    c:px(x, 114, P.moss.base) c:px(x + 1, 113, P.moss.hi) c:px(x - 1, 113, P.moss.shade)
  end
  c:fillMask(E(212, 116, 3, 2), P.ember.base) c:px(211, 115, P.ember.hi)
  c:fillMask(E(232, 115, 3, 2), P.gold.base) c:px(231, 114, P.gold.hi)
  local pole = c:rect(221, 98, 222, 116)
  local arms = c:rect(212, 102, 231, 103)
  local body = c:rrect(217, 100, 226, 109, 1)
  local head = E(221.5, 96, 3, 3)
  local hat = c:rect(217, 92, 226, 93):add(c:rect(219, 87, 224, 92))
  c:rim(pole:copy():add(arms):add(body):add(head):add(hat), P.wood.deep)
  c:fillMask(pole, P.wood.base) c:fillMask(arms, P.wood.base)
  c:fillMask(body, P.dusk.base) c:fillMask(c:rect(217, 105, 226, 109), P.dusk.shade) c:px(219, 102, P.dusk.hi) c:px(224, 107, P.gold.base) c:px(223, 106, P.gold.base)
  c:fillMask(head, P.cream) c:px(220, 95, P.ink) c:px(223, 95, P.ink) R(220, 97, 223, 97, P.wood.deep) c:px(221, 97, P.cream)
  c:part(hat, "gold", { band = 1, nopop = true }) R(219, 91, 224, 91, P.wood.shade)
  for _, s in ipairs{ {211, 103}, {212, 105}, {232, 103}, {231, 105} } do c:px(s[1], s[2], P.gold.hi) end
  -- the sparrow on the hat
  c:paint({
    ".bb.",
    "bbbk",
    ".bw.",
  }, 220, 84, { b = "wood.base", k = "#2b1c26", w = "cream" })
  c:px(224, 85, P.gold.base) c:px(219, 86, P.wood.shade)
end

------------------------------------------------------------ NEAR: bushes, blades, branch (ink-ish dark edges)
do
  local b = E(4, 131, 17, 9):add(E(22, 134, 9, 4))
  local ferns = HP.mask()
  for _, f in ipairs{ {4, 122, 12, 114}, {10, 121, 20, 116}, {2, 124, 2, 112} } do ferns:add(c:line({ { f[1], f[2] }, { f[3], f[4] } }, 2)) end
  c:rim(b:copy():add(ferns), P.moss.deep)
  c:part(b, "moss", { band = 3, pop = { 2, 124 } })
  c:fillMask(ferns, P.moss.base) ferns:each(function(x, y) if not ferns:has(x - 1, y - 1) then c:px(x, y, P.moss.hi) end end)
  speckle(b, 130, P.moss.hi, P.moss.deep, .09)
  mush(18, 131, 3, "ember") c:px(18, 123, P.cream) c:px(20, 124, P.cream)
end
do
  local b = E(236, 133, 15, 8):add(E(222, 135, 8, 3))
  c:rim(b, P.moss.deep) c:part(b, "moss", { band = 3, pop = { 230, 127 } })
  speckle(b, 132, P.moss.hi, P.moss.deep, .09)
  for _, f in ipairs{ {232, 126}, {238, 128}, {228, 129} } do c:px(f[1], f[2], P.petal.base) c:px(f[1] + 1, f[2], P.petal.hi) c:px(f[1], f[2] + 1, P.gold.base) end
end
do
  local bl = HP.mask()
  local xs = { 54, 59, 64, 70, 76, 150, 156, 162, 170, 176 }
  for i, x in ipairs(xs) do bl:add(c:line({ { x, 135 }, { x + (i % 3 - 1) * 2, 128 + (i % 3) } }, 2)) end
  c:rim(bl, P.moss.deep) c:fillMask(bl, P.moss.base)
  bl:each(function(x, y) if not bl:has(x, y - 1) or H(x, y, 3) > .85 then c:px(x, y, P.moss.hi) elseif not bl:has(x + 1, y) then c:px(x, y, P.moss.shade) end end)
end
do
  local br = c:line({ { 0, 5 }, { 12, 9 }, { 28, 5 }, { 42, 8 } }, 2)
  local lv = HP.mask()
  for _, l in ipairs{ {6, 13, 5, 3}, {18, 12, 5, 3}, {32, 11, 5, 3}, {44, 11, 4, 3}, {12, 2, 4, 3}, {26, 2, 5, 2}, {3, 9, 4, 3} } do lv:add(E(l[1], l[2], l[3], l[4])) end
  c:rim(br:copy():add(lv), P.moss.deep)
  c:fillMask(br, P.wood.shade)
  c:part(lv, "moss", { band = 1, nopop = true })
  for _, l in ipairs{ {5, 12}, {17, 11}, {31, 10}, {43, 10}, {11, 1} } do c:px(l[1], l[2], P.moss.hi) c:px(l[1] + 1, l[2], P.moss.hi) end
end

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "here-village-forest.aseprite", png = out .. "here-village-forest.png", scale = 2 }
