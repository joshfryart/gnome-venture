-- trek-crystal-u: a tall glow crystal with two shards, on a stepped lit floor pool, four sparks
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/trek-pixel/"
local c = GV.canvas{ w = 42, h = 42, mode = "scene" }

local su = { g = "#b88850", r = "#a06c3c", b = "#8a5a30" }
local gd = { g = "#fff1c8", r = "#f5cf6a", b = "#e8a317", n = "#d0862a", s = "#b8661a", d = "#7a3a14" }
local U1, U2, U3 = "#74462a", "#4a2c1a", "#2a1a10"
local round = function(v) return math.floor(v + 0.5) end

c:fill(c:rect(0, 0, 41, 41), su.b)

-- lit floor pool: two concentric stepped ellipses (no gradient), >= 4 px from the tile edge
c:fill(c:ellipse(21, 26, 15, 11), su.r)   -- x6..36  y15..37
c:fill(c:ellipse(21, 28, 8, 5), su.g)     -- x13..29 y23..33

-- generic diamond: rows y0..y1, widest at ym, half-width hw; returns mask
local function diamond(cx, y0, ym, y1, hw)
  local m = c:mask()
  for y = y0, y1 do
    local h = y <= ym and round((y - y0) * hw / (ym - y0)) or round((y1 - y) * hw / (y1 - ym))
    for x = cx - h, cx + h do m:set(x, y) end
  end
  return m
end
local function isEdge(m, x, y)
  return not (m:has(x-1, y) and m:has(x+1, y) and m:has(x, y-1) and m:has(x, y+1))
end

-- main crystal: tips (21,4) (21,31) (13,17) (29,17)
local M = diamond(21, 4, 17, 31, 8)
local I = c:mask()
M:each(function(x, y) if not isEdge(M, x, y) then I:set(x, y) end end)
-- facets: lit left gd_rim, right gd_base
I:each(function(x, y) c:px(x, y, x < 21 and gd.r or gd.b) end)
-- lower-right: 1 px bounce on the edge, 2 px shade inside it
for y = 18, 31 do
  local xr
  for x = 41, 0, -1 do if I:has(x, y) then xr = x break end end
  if xr then
    for x = xr, xr - 2, -1 do
      if I:has(x, y) and x >= 21 then c:px(x, y, x == xr and gd.n or gd.s) end
    end
  end
end
-- bottom tip deep
I:each(function(x, y) if y >= 28 then c:px(x, y, gd.d) end end)
-- inner core diamond: tips (21,10) (21,24) (17,17) (25,17), gd_deep outline, gd_gloss fill
local K = diamond(21, 10, 17, 24, 4)
K:each(function(x, y) c:px(x, y, isEdge(K, x, y) and gd.d or gd.g) end)
-- 3 px gloss comma on the lit facet
c:px(17, 12, gd.g); c:px(16, 13, gd.g); c:px(16, 14, gd.g)
-- outline by light, plus 1 extra umber3 px outside the lower-right edge
M:each(function(x, y)
  if isEdge(M, x, y) then
    local col
    if y <= 17 then col = (x <= 21) and U1 or U2
    else col = (x < 21) and U2 or U3 end
    c:px(x, y, col)
    if y > 17 and x >= 21 and not M:has(x + 1, y) then c:px(x + 1, y, U3) end
  end
end)

-- shards: hand-placed rows; a = umber2, c = umber3, b = gd_base, g = gd_gloss, s = gd_shade
local SL = { a = U2, c = U3, b = gd.b, g = gd.g, s = gd.s }
c:paint({                 -- shard A, 7x12 at x6..12 y22..33
  "...a...",
  "..aba..",
  "..aba..",
  ".agbba.",
  ".agbbc.",
  "agbbbbc",
  "abbbbsc",
  ".abbsc.",
  ".abbsc.",
  "..asc..",
  "..asc..",
  "...c...",
}, 6, 22, SL)
c:paint({                 -- shard B, 6x10 at x30..35 y25..34
  "..aa..",
  ".agba.",
  ".agba.",
  "agbbba",
  "abbbsc",
  "abbbsc",
  ".absc.",
  ".absc.",
  "..cc..",
  "..cc..",
}, 30, 25, SL)

-- four sparks: 3 px plus, gloss centre with rim arms
for _, p in ipairs({ {6,6}, {35,6}, {5,19}, {36,19} }) do
  local x, y = p[1], p[2]
  c:px(x-1, y, gd.r); c:px(x+1, y, gd.r); c:px(x, y-1, gd.r); c:px(x, y+1, gd.r)
  c:px(x, y, gd.g)
end

local t = c:save(R .. "aseprite/trek-crystal-u.aseprite", R .. "png/trek-crystal-u.png")
print(GV.report(t))
