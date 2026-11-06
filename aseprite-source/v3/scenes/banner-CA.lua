-- banner-CA PASS 2 (final). 240x60 grid, x2 = 480x120. Central Asia: steppe at sunrise.
-- Planes: far = Tian Shan (dusk.hi body, cream snow, no ink) over a 4-band sunrise sky;
-- mid = foothills with a meltwater river, grazing horses + foal, far yurt; hero = felt yurt
-- (1px wood.deep edge) with ornament band, ropes, painted door, tethering post;
-- near = ink-edged grass clumps, wild tulips and a rock framing both corners. Gold hem at the bottom.
-- quirk: a goat with a bell stands on the yurt's crown, munching a tulip.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or "./"
local c = HP.canvas{ w = 240, h = 60, scale = 2, name = "banner-CA" }
local floor, sin, abs = math.floor, math.sin, math.abs
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end

------------------------------------------------------------ SKY (4 flat bands, warm toward the horizon)
c:stripes(0, 43, { P.sky.shade, P.sky.base, P.petal.hi, P.gold.hi }, { 2, 3, 3, 3 })
c:fillMask(E(62, 33, 9, 9), P.gold.base)
c:fillMask(E(61, 32, 6, 6), P.gold.hi)
c:cloud(8, 17, 26, P.cream, P.petal.hi)
c:cloud(96, 20, 18, P.cream, P.petal.hi)
c:cloud(200, 16, 30, P.cream, P.petal.hi)

------------------------------------------------------------ FAR: Tian Shan (2 colours)
local peaks = { {-4, 21, 1.05}, {24, 13, 1.15}, {38, 18, 1.0}, {96, 16, 0.95}, {120, 8, 1.1}, {148, 18, 1.25},
  {186, 22, 0.85}, {214, 11, 1.1}, {226, 16, 1.0}, {250, 20, 1.0} }
local function ridge(x)
  local y = 42
  for _, p in ipairs(peaks) do
    local v = p[2] + abs(x - p[1]) * p[3] + ((x * 5 + p[1]) % 7 == 0 and 1 or 0)
    if v < y then y = v end
  end
  return y
end
local mtn = c:terrain(ridge, P.dusk.hi, 46)
for i, p in ipairs(peaks) do
  local w = floor(8 / p[3]) + (i % 2)
  local pts = { {p[1] + .5, p[2] - 1}, {p[1] + w + 1, p[2] + w * p[3] + 1} }
  local n = 4 + (i % 2)
  for k = 1, n - 1 do
    pts[#pts + 1] = { p[1] + w - k * 2 * w / n, p[2] + w * p[3] * ((k % 2 == 1) and 0.5 or 0.95) + ((i + k) % 3 == 0 and 1 or 0) }
  end
  pts[#pts + 1] = { p[1] - w, p[2] + w * p[3] + 1 }
  c:fillMask(c:poly(pts):clip(mtn), P.cream)
end

------------------------------------------------------------ MID-FAR: foothills, river, horses, far yurt
local function foot(x) return 39 + 2.5 * sin(x / 17) + 1.5 * sin(x / 7 + 1) end
c:terrain(foot, P.moss.hi, 59)
for _, g in ipairs{ {40, 44, 22, 1}, {120, 41, 18, 1}, {196, 43, 26, 1} } do c:fillMask(E(g[1], g[2], g[3], g[4]), P.gold.hi) end
local function steppe(x) return 46 + 1.5 * sin(x / 23 + 2) end
c:terrain(steppe, P.moss.base, 59)
-- meltwater river: from the foothills, winding left out of frame
local river = c:line({ {92, 41}, {84, 43}, {94, 45}, {80, 47} }, 1):add(c:line({ {80, 47}, {60, 49}, {72, 51}, {44, 53}, {20, 55}, {-2, 56} }, 2))
c:fillMask(river, P.sea.base)
c:fillMask(c:line({ {66, 49}, {70, 50} }, 1):add(c:line({ {40, 53}, {44, 53} }, 1)), P.sky.hi)
-- horses (mid-far silhouettes) + a foal
local HORSE = {
  "......###",
  ".....##..",
  "t#####...",
  "######...",
  ".#...#...",
  ".#...#...",
  ".#...#...",
}
local FOAL = {
  "....##",
  "...#..",
  "####..",
  "#..#..",
  "#..#..",
}
local function sprite(rows, x, y, hex, flip)
  local wdt = #rows[1]
  for j, row in ipairs(rows) do for i = 1, wdt do
    if row:sub(i, i) ~= "." then c:px(flip and (x + wdt - i) or (x + i - 1), y + j - 1, hex) end
  end end
end
sprite(HORSE, 20, 38, P.wood.shade) sprite(FOAL, 31, 41, P.wood.base)
sprite(HORSE, 44, 39, P.wood.deep, true) sprite(HORSE, 106, 37, P.cream, true)
-- far yurt on the right foothill (low contrast, no edge)
c:fillMask(c:rect(218, 37, 227, 41), P.cream) c:fillMask(E(222.5, 37, 6, 2):clip(c:rect(0, 0, 239, 37)), P.ember.hi)

------------------------------------------------------------ path: door to viewer, widening
local path = c:line({ {172, 53}, {164, 54}, {150, 55}, {134, 57}, {118, 59} }, 2)
path:add(c:line({ {150, 56}, {136, 58}, {124, 60} }, 3))
c:fillMask(path, P.wood.hi)

------------------------------------------------------------ HERO: yurt
local function roofPoly(cx, y0, half, h)
  local pts = {}
  for i = 0, 16 do
    local t = -1 + i / 8
    pts[#pts + 1] = { cx + t * half, y0 - h * (1 - abs(t) ^ 1.25) }
  end
  pts[#pts + 1] = { cx + half, y0 + 1 } pts[#pts + 1] = { cx - half, y0 + 1 }
  return c:poly(pts)
end
local wall = c:poly{ {152, 39}, {192, 39}, {195, 52}, {149, 52} }:cut(c:rect(149, 52, 149, 52)):cut(c:rect(195, 52, 195, 52))
local roof = roofPoly(172, 40, 27, 14)
local crown = c:rrect(167, 24, 177, 27, 1)
local pipe = c:rect(183, 24, 184, 30)
local yurt = wall:copy():add(roof):add(crown):add(pipe)
c:fillMask(E(172, 53, 27, 2), P.moss.shade)
c:rim(yurt, P.wood.deep)
local FELT = { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base }
c:part(wall, FELT, { band = 3, nopop = true })
c:part(roof, "ember", { band = 2, pop = { 160, 31 } })
for _, a in ipairs{ -18, -9, 0, 9, 18 } do
  c:fillMask(c:line({ {172 + a * .3, 28}, {172 + a, 39} }, 1):clip(roof), P.ember.shade)
end
c:fillMask(c:rect(146, 40, 198, 40):clip(roof), P.ember.deep)       -- eave lip
c:part(crown, "wood", { band = 1, nopop = true }) R(169, 24, 175, 24, P.wood.hi)
c:fillMask(pipe, P.stone.shade) c:px(183, 24, P.stone.hi)
-- ornament band: ember felt with gold ram's-horn zigzag
R(151, 42, 193, 44, P.ember.base)
for x = 151, 193 do
  local k = (x - 151) % 6
  if k == 0 or k == 3 then c:px(x, 43, P.gold.base) elseif k == 1 or k == 2 then c:px(x, 42 + (k == 1 and 0 or 0), P.gold.hi) end
end
R(151, 45, 193, 45, P.ember.shade)
-- rope bands
for x = 150, 194 do if (x % 3) ~= 0 then c:px(x, 49, P.wood.base) end end
-- painted door with frame
local door = c:rect(167, 45, 177, 52)
c:fillMask(c:rect(166, 44, 178, 52), P.gold.base)
c:part(door, "ember", { band = 1, nopop = true })
R(172, 45, 172, 52, P.ember.deep)
c:px(169, 48, P.gold.hi) c:px(170, 47, P.gold.hi) c:px(170, 49, P.gold.hi)
c:px(175, 48, P.gold.hi) c:px(174, 47, P.gold.hi) c:px(174, 49, P.gold.hi)
-- smoke from the pipe, drifting right
c:fillMask(E(186, 20, 2, 1), P.stone.hi) c:fillMask(E(190, 16, 3, 2), P.stone.hi) c:fillMask(E(196, 12, 3, 2), P.cream)
-- tethering post with a saddle blanket (left of the yurt)
R(140, 44, 141, 53, P.wood.deep) R(137, 44, 144, 44, P.wood.deep)
c:fillMask(c:rect(138, 45, 143, 49), P.ember.base) R(138, 47, 143, 47, P.gold.base) R(138, 49, 143, 49, P.ember.shade)

------------------------------------------------------------ QUIRK: belled goat on the crown, eating a tulip
local GOAT = {
  "..h.h........",
  "..hhh........",
  ".wwwwk.......",
  "wewww........",
  "wwwwwwwwwwww.",
  ".bwgwwwwwwwwt",
  "..wwwwwwwwww.",
  "..sssssssss..",
  "..w.w...w.w..",
  "..l.l...l.l..",
}
local gm = HP.mask()
for j, row in ipairs(GOAT) do for i = 1, #row do if row:sub(i, i) ~= "." and j < 10 then gm:set(166 + i - 1, 13 + j - 1) end end end
c:rim(gm, P.stone.shade, c:rect(0, 0, 239, 22))
c:paint({
  "..h.h........",
  "..hhh........",
  ".wwwwk.......",
  "wewww........",
  "wwwwwwwwwwww.",
  ".bwgwwwwwwwwt",
  "..wwwwwwwwww.",
  "..sssssssss..",
  "..w.w...w.w..",
  "..l.l...l.l..",
}, 166, 13, { h = "wood.deep", w = "#fff4d6", e = "#2b1c26", b = "stone.base", g = "gold.base", k = "stone.base",
  s = "stone.hi", t = "stone.hi", l = "wood.deep" })
c:px(165, 17, P.ember.base) c:px(164, 17, P.ember.base) c:px(164, 18, P.moss.shade) c:px(163, 19, P.moss.shade)

------------------------------------------------------------ NEAR: ink-edged corners
R(0, 54, 239, 59, P.moss.shade)
for x = 0, 239 do if (x * 7) % 11 == 0 then c:px(x, 54, P.moss.base) end end
c:fillMask(path:clip(c:rect(0, 54, 239, 59)), P.wood.hi)
local function clump(x, y, blades)
  local m = HP.mask()
  for _, b in ipairs(blades) do m:add(c:poly{ {x + b[1], y + 1}, {x + b[1] + 2 + b[3], y - b[2]}, {x + b[1] + 5, y + 1} }) end
  return m
end
local function tulip(x, y, ramp, h)
  local st = c:rect(x, y + 1, x, y + h)
  local lf = c:poly{ {x, y + h}, {x - 3, y + h - 4}, {x, y + h - 2} }
  local hd = c:rect(x - 1, y - 3, x + 1, y):add(c:rect(x - 2, y - 2, x + 2, y)):cut(c:rect(x, y - 3, x, y - 3))
  c:rim(st:copy():add(lf):add(hd), P.ink)
  c:fillMask(st, P.moss.shade) c:fillMask(lf, P.moss.base)
  c:fillMask(hd, P[ramp].base) c:px(x - 1, y - 3, P[ramp].hi) c:fillMask(c:rect(x + 1, y - 1, x + 2, y), P[ramp].shade)
end
-- left corner
local L = clump(-2, 58, { {0, 11, 1}, {5, 14, 2}, {10, 9, 3} })
c:rim(L, P.ink) c:part(L, "moss", { band = 1, nopop = true })
c:px(4, 51, P.moss.hi) c:px(8, 48, P.moss.hi)
tulip(22, 47, "ember", 10) tulip(28, 51, "ember", 7) tulip(17, 52, "gold", 5)
-- right corner
local rock = E(226, 55, 8, 4):add(E(221, 57, 5, 3))
c:rim(rock, P.ink) c:part(rock, "stone", { band = 1, pop = { 222, 52 } })
local Rm = clump(228, 58, { {0, 10, -3}, {5, 14, 0}, {9, 9, 2} })
c:rim(Rm, P.ink) c:part(Rm, "moss", { band = 1, nopop = true })
c:px(234, 46, P.moss.hi) c:px(229, 50, P.moss.hi)
tulip(212, 50, "ember", 8) tulip(206, 54, "petal", 4)
------------------------------------------------------------ hem
R(0, 59, 239, 59, P.moss.deep)
c:hem(59)

c:finish{ outline = false }
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. "banner-CA.aseprite", png = out .. "banner-CA.png", scale = 2 }
