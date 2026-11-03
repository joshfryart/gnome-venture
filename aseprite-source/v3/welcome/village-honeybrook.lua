-- village-honeybrook FIRST DRAFT. 160x100 scene, full canvas, no outline.
-- Planes: sky + far hills; mid: thatched cottages with beehive skeps, apple trees; a brook with a footbridge
-- crossing it; near: reeds, bank flowers.
-- quirk: a bee towing a tiny scrap of ribbon over the bridge.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local P = HP.P
local out = app.params.out or (d .. "/")
local NAME = "village-honeybrook"
local c = HP.canvas{ w = 160, h = 100, scale = 1, name = NAME }
local sin, floor, abs = math.sin, math.floor, math.abs
local seed = 5
local function rnd() seed = (seed * 1103515245 + 12345) % 2147483648 return seed / 2147483648 end
local E = function(cx, cy, rx, ry) return c:ellipse(cx, cy, rx, ry) end
local R = function(x0, y0, x1, y1, hex) c:fillMask(c:rect(x0, y0, x1, y1), hex) end

c:stripes(0, 40, { P.sky.shade, P.sky.base, P.sky.hi }, { 3, 4, 4 })
c:cloud(8, 22, 24, P.cream, P.sky.hi) c:cloud(104, 16, 28, P.cream, P.sky.hi) c:cloud(140, 32, 14, P.cream, P.sky.hi)
c:terrain(function(x) return 34 + 6 * sin(x / 24 + 2) + 2 * sin(x / 7) end, "#a9dccb")
c:terrain(function(x) return 42 + 4 * sin(x / 18) end, P.moss.hi)
c:terrain(function(x) return 48 + 2 * sin(x / 15 + 1) end, P.moss.base)
for i = 1, 90 do local x, y = floor(rnd() * 160), 50 + floor(rnd() * 26) c:px(x, y, P.moss.shade) c:px(x + 1, y - 1, P.moss.shade) end

-- brook: wavy band from left to right
local function top(x) return 71 + 3 * sin(x / 17 + 1) end
local function bot(x) return 83 + 3 * sin(x / 17 + 1) end
local water = HP.mask()
for x = 0, 159 do for y = floor(top(x)), floor(bot(x)) do water:set(x, y) end end
c:rim(water, P.moss.deep)
c:fillMask(water, P.sea.base)
water:each(function(x, y)
  if y < top(x) + 3 then c:px(x, y, P.sea.shade) end
end)
for i = 1, 40 do local x = floor(rnd() * 156) local y = floor(top(x)) + 3 + floor(rnd() * 8) if water:has(x, y) and water:has(x + 3, y) then R(x, y, x + 2, y, P.sea.hi) end end
for _, p in ipairs{ {18, 78}, {118, 76}, {140, 80} } do c:px(p[1], p[2], P.cream) end
-- bank stones
for x = 2, 158, 9 do c:fillMask(E(x, floor(bot(x)) + 2, 2, 1), P.stone.base) c:px(x - 1, floor(bot(x)) + 2, P.stone.hi) end

-- apple trees (mid)
local function atree(x, y, s)
  c:fillMask(E(x, y + 1, 7 * s, 1), P.moss.shade)
  local tr = c:rect(x - 1, y - 8 * s, x + 1, y)
  local cr = E(x, y - 12 * s, 8 * s, 7 * s):add(E(x - 5 * s, y - 9 * s, 4 * s, 4 * s)):add(E(x + 5 * s, y - 9 * s, 4 * s, 4 * s))
  c:rim(tr:copy():add(cr), P.moss.deep)
  c:part(tr, "wood", { band = 1, nopop = true })
  c:part(cr, "moss", { band = 3, pop = { x = x - 4 * s, y = y - 17 * s } })
  for _, a in ipairs{ {-4, -12}, {2, -15}, {5, -9}, {-1, -8}, {-7, -9} } do
    local ax, ay = x + a[1] * s, y + a[2] * s
    R(ax, ay, ax + 1, ay + 1, P.ember.base) c:px(ax, ay, P.ember.hi)
  end
end
atree(60, 68, 1) atree(150, 66, 1)
-- cottage with skep
local function cottage(x, y, w, hh, wallR)
  local wall = c:rect(x, y - hh, x + w, y)
  local roof = c:poly{ {x - 3, y - hh + 1}, {x + w / 2, y - hh - 11}, {x + w + 3, y - hh + 1} }
  c:rim(wall:copy():add(roof), P.wood.deep)
  c:part(wall, wallR, { band = 2, nopop = true })
  c:part(roof, "gold", { band = 3, pop = { x = x + 3, y = y - hh - 3 } })
  for k = 0, 3 do R(x - 3 + k, y - hh - 1 + k * 0, x + w + 3 - k, y - hh - 1, P.gold.shade) break end
  for yy = y - hh - 8, y - hh, 3 do for xx = x - 2, x + w + 2, 4 do if roof:has(xx, yy) then c:px(xx, yy, P.gold.deep) end end end
  -- door + window
  local dx = x + 3
  c:part(c:rrect(dx, y - 8, dx + 4, y, 2):clip(c:rect(0, 0, 159, y)), "wood", { band = 1, nopop = true, inner = false })
  c:px(dx + 3, y - 4, P.gold.hi)
  local wx = x + w - 6
  c:rim(c:rect(wx, y - hh + 4, wx + 3, y - hh + 7), P.wood.deep)
  R(wx, y - hh + 4, wx + 3, y - hh + 7, P.sea.hi) R(wx + 1, y - hh + 4, wx + 1, y - hh + 7, P.wood.base)
  -- chimney
  R(x + w - 4, y - hh - 11, x + w - 2, y - hh - 6, P.stone.base) c:px(x + w - 3, y - hh - 13, P.stone.hi)
end
-- skep: banded beehive
local function skep(x, y, s)
  local m = E(x, y - 3 * s, 3 * s, 4 * s):clip(c:rect(0, 0, 159, y))
  c:rim(m, P.wood.deep)
  c:part(m, "gold", { band = 1, pop = { x = x - s, y = y - 6 * s } })
  for k = 1, 3 do local yy = y - 2 * k - 1 R(x - 3 * s, yy, x + 3 * s, yy, P.gold.shade) end
  c:fillMask(m:copy():clip(c:rect(x, y - 3, x + 1, y - 1)), P.ink) c:px(x - 1, y - 6 * s + 1, P.gold.hi)
  R(x - 4 * s, y, x + 4 * s, y, P.wood.shade)
end
cottage(14, 66, 28, 15, "wood")
cottage(94, 64, 30, 14, { hi = P.cream, base = P.cream, shade = P.stone.hi, deep = P.stone.base })
skep(48, 68, 1) skep(51, 68, 1) skep(132, 66, 1) skep(10, 69, 1)

-- footbridge across the brook
local bx0, bx1 = 70, 98
local deck = c:rrect(bx0, 70, bx1, 78, 3):clip(c:rect(0, 70, 159, 74)):add(c:rect(bx0, 70, bx1, 71))
local arch = HP.mask()
for x = bx0, bx1 do local u = (x - (bx0 + bx1) / 2) / ((bx1 - bx0) / 2) local h = floor(5 - 5 * u * u + .5) for y = 70 - h, 74 do arch:set(x, y) end end
c:rim(arch, P.wood.deep)
c:part(arch, "wood", { band = 1, nopop = true, inner = false })
for x = bx0 + 2, bx1 - 2, 3 do for y = 70, 73 do if arch:has(x, y) then c:px(x, y, P.wood.shade) end end end
-- rails
for _, x in ipairs{ bx0 + 2, bx0 + 9, bx0 + 16, bx0 + 23 } do R(x, 62 + floor(abs(x - 84) / 7), x, 68, P.wood.deep) end
c:fillMask(c:line({ {bx0 + 2, 64}, {84, 61}, {bx1 - 3, 64} }, 1), P.wood.base)
-- path to bridge
c:fillMask(E(66, 72, 6, 2), P.gold.hi) c:fillMask(E(104, 72, 6, 2), P.gold.hi)
-- quirk: bee towing ribbon
R(84, 55, 86, 56, P.gold.base) c:px(85, 55, P.ink) c:px(83, 54, P.cream) c:px(85, 54, P.cream)
for i, p in ipairs{ {82,56},{80,57},{78,57},{76,58} } do c:px(p[1], p[2], i % 2 == 0 and P.petal.base or P.petal.hi) end

-- foreground bank: grass, reeds, flowers
c:terrain(function(x) return 88 + 2 * sin(x / 13) end, P.moss.shade)
c:terrain(function(x) return 91 + 2 * sin(x / 9 + 2) end, P.moss.deep)
for x = 2, 158, 7 do
  local h = 8 + floor(rnd() * 7)
  R(x, 98 - h, x, 99, P.moss.base) c:px(x - 1, 99 - h + 3, P.moss.base) c:px(x + 1, 99 - h + 5, P.moss.hi)
  if x % 14 == 2 then R(x - 1, 98 - h - 2, x + 1, 98 - h + 1, P.wood.base) c:px(x, 98 - h - 2, P.wood.hi) end
end
local cols = { "petal", "gold", "dusk", "cream" }
for i = 1, 14 do
  local x, y = floor(rnd() * 156) + 2, 87 + floor(rnd() * 8)
  local col = P[cols[1 + i % 3]]
  R(x, y + 1, x, y + 3, P.moss.base) c:px(x, y, col.hi) c:px(x - 1, y, col.base) c:px(x + 1, y, col.base) c:px(x, y - 1, col.base)
end
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
