-- broken-wheelbarrow (pass A). Side view, facing left: spoked wooden wheel with an iron tyre, slim plank tray
-- painted moss green (worn to bare wood on the edges), iron corner strap, slim handle beam and leg.
-- broken: the handle has snapped behind the tray (splintered stub, grip end lying on the ground, a chip flying),
-- the top plank is split at the back corner.
-- quirk: a seedling has sprouted in the leftover soil.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b1g3.lua")
local HP, X, c, P = G.start(debug.getinfo(1, "S").source)
local K = G.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos

local PAINT = { "#22423f", "#2d5e4f", "#3c7d57", "#56995f", "#7fb86e", "#b2d68e" }
local WOOD  = { "#4a2a22", "#6a3c2a", "#8b5233", "#ad6d3e", "#c98a50", "#e0aa6e" }
local FRESH = { "#d7a66a", "#f0cd95" }
local IRON  = { "#2e2c3c", "#43425a", "#5c5c78", "#7a7c96", "#a0a3b8", "#cfd2de" }
local SOIL  = { "#3a2622", "#5a3a2c", "#7a5038" }
local LEAF  = { "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(34, 58, 22, 2)

-- handle beam (axle -> back), drawn first so the tray sits on it; snapped at BRK
local AX, AY, BX, BY = 17, 46, 60, 28
local BRK = 0.78
local hm, hn, hT, hS = X.cyl(AX, AY, BX, BY, function(t) return 1.4 end)
local beam = hm:copy()
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local function woodPaint(m, v, S, T, dx, dy)
  m:each(function(x, y)
    local k = K(x, y)
    local i = floor((v[k] or 0.4) * 5.99) + 1
    if S and S[k] and abs(S[k] - 0.1 - 0.1 * sin((T[k] or 0) * 40)) < 0.12 then i = i - 1 end   -- grain
    c:put(x + (dx or 0), y + (dy or 0), WOOD[max(1, min(6, i))])
  end)
end
local stub = HP.mask()
beam:each(function(x, y) local t = hT[K(x, y)] if t < BRK + ((x + y) % 3 == 0 and 0.03 or 0) then stub:set(x, y) end end)
woodPaint(stub, hv, hS, hT)
-- fresh splintered end
stub:each(function(x, y) if not stub:has(x + 1, y) and hT[K(x, y)] > BRK - 0.05 then c:px(x, y, FRESH[2]) end end)

-- the snapped grip lying on the ground (rotated copy: a short beam)
local gm, gn, gT, gS = X.cyl(44, 55, 58, 52, function(t) return t > 0.85 and 1.8 or 1.4 end)
woodPaint(gm, X.light(gn, { amb = 0.12, wrap = 0.3 }), gS, gT)
c:px(44, 55, FRESH[2]) c:px(44, 54, FRESH[1]) c:px(43, 55, FRESH[1])
-- flying chip
c:paint({ ".ab", "ab." }, 53, 33, { a = FRESH[2], b = WOOD[4] })

-- leg
local lm, ln = X.cyl(41, 38, 43, 56, function(t) return 1.3 end)
woodPaint(lm, X.light(ln, { amb = 0.12, wrap = 0.3 }))
for x = 41, 45 do c:px(x, 57, WOOD[2]) end c:px(41, 56, WOOD[3]) c:px(45, 56, WOOD[2])

-- tray: three planks, painted, bevelled, worn edges
local tray = c:poly{ {11,24},{49,24},{43,40},{20,40} }
local planks = { {24, 28}, {29, 34}, {35, 40} }
for pi, pl in ipairs(planks) do
  local m = tray:copy():clip(c:rect(0, pl[1], 63, pl[2]))
  local n = X.pillow(m, 1.6)
  local v = X.light(n, { amb = 0.2, wrap = 0.3 })
  local bias = {}
  m:each(function(x, y)
    local k = K(x, y)
    if y == pl[2] then bias[k] = -1 end
    if (x * 7 + pi * 5) % 13 == 0 and y > pl[1] then bias[k] = (bias[k] or 0) - 1 end   -- brush streaks
  end)
  G.paint(c, m, v, PAINT, { 0.25, 0.42, 0.58, 0.74, 0.88 }, bias)
  -- worn: bare wood on the top-left edge of each plank
  m:each(function(x, y) if not m:has(x, y - 1) and (x % 9 < 3) then c:px(x, y, WOOD[5]) end end)
end
-- split at the back corner of the top plank: dark gap with pale lips
for i, p in ipairs{ {45,25},{44,26},{43,27},{42,27} } do c:px(p[1], p[2], i == 1 and SOIL[1] or WOOD[1]) c:px(p[1] + 1, p[2], FRESH[1]) end
-- iron corner strap with rivets (front corner)
local strap = c:poly{ {11,24},{15,24},{22,39},{20,40},{18,40} }:clip(tray)
G.paint(c, strap, X.light(X.pillow(strap, 1), { amb = 0.15 }), IRON)
c:px(15, 27, IRON[6]) c:px(18, 34, IRON[6])

-- soil heap + seedling (quirk)
local soil = c:ellipse(30, 24, 12, 2):clip(c:rect(0, 0, 63, 23))
soil:each(function(x, y) c:px(x, y, (x + y) % 5 == 0 and SOIL[3] or (y < 23 and SOIL[2] or SOIL[1])) end)
c:paint({
  "aa...bb",
  "bab.bcb",
  ".bbcbb.",
  "...a...",
  "...a...",
}, 27, 15, { a = LEAF[1], b = LEAF[2], c = LEAF[3] })

-- wheel
local WX, WY, R = 16, 47, 9
local tyre = c:ellipse(WX, WY, R, R):cut(c:ellipse(WX, WY, R - 2, R - 2))
G.paint(c, tyre, X.light(G.ringNormals(tyre, WX, WY, R - 0.5, R - 0.5, 0.9), { amb = 0.1, wrap = 0.2 }), IRON)
local fel = c:ellipse(WX, WY, R - 2, R - 2):cut(c:ellipse(WX, WY, R - 4, R - 4))
G.paint(c, fel, X.light(G.ringNormals(fel, WX, WY, R - 3, R - 3, 1.0), { amb = 0.15, wrap = 0.3 }), WOOD)
for i = 0, 5 do
  local a = i * math.pi / 3 + 0.3
  c:line({ { WX, WY }, { floor(WX + cos(a) * 5.5 + 0.5), floor(WY + sin(a) * 5.5 + 0.5) } }, 1):each(function(x, y)
    c:px(x, y, (sin(a) + cos(a) < 0) and WOOD[5] or WOOD[3])
  end)
end
local hub = c:ellipse(WX, WY, 1, 1)
G.paint(c, hub, X.light(X.sphere(WX - 0.4, WY - 0.4, 1.5, hub), {}), IRON)
c:px(WX - 1, WY - 1, IRON[6])

G.fin(c)
