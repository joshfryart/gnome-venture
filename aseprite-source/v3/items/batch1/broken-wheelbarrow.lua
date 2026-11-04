-- broken-wheelbarrow (pass B, final). Side view, facing left: spoked wooden wheel with an iron tyre and hub, slim
-- plank tray painted moss green (bevelled planks, chipped to bare wood, nail heads, pale end grain on the back edge,
-- lit top rim), iron corner strap, slim handle beam and leg.
-- broken: the handle has snapped behind the tray (splintered stub with long slivers, grip end lying on the ground,
-- a chip flying off), and the top plank is split at the back corner (dark gap, pale lips).
-- Realism (hpx.lua): tube-lit tyre and felloe, cylinder-lit beam/leg/grip with grain, pillow-lit planks, AO under
-- the tray and at the leg joint, ground shadow.
-- History: broken-wheelbarrow.pA (pass A).
-- quirk: a seedling has sprouted in the leftover soil.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b1g3.lua")
local HP, X, c, P = G.start(debug.getinfo(1, "S").source)
local K = G.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos

local PAINT = { "#22423f", "#2d5e4f", "#3c7d57", "#56995f", "#7fb86e", "#b2d68e" }
local WOOD  = { "#4a2a22", "#6a3c2a", "#8b5233", "#ad6d3e", "#c98a50", "#e0aa6e" }
local FRESH = { "#d7a66a", "#f0cd95" }
local IRON  = { "#2e2c3c", "#43425a", "#5c5c78", "#7a7c96", "#a0a3b8", "#cfd2de" }
local SOIL  = { "#3a2622", "#5a3a2c", "#7a5038", "#9a6a48" }
local LEAF  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local DY = -2                                  -- whole drawing nudged up (applied at the end)

c:groundShadow(33, 58, 22, 2)

local function woodPaint(m, v, S, T, grainAt)
  m:each(function(x, y)
    local k = K(x, y)
    local i = floor((v[k] or 0.4) * 5.99) + 1
    if S and S[k] then
      local g = S[k] - (grainAt or 0.15) - 0.12 * sin((T[k] or 0) * 30)
      if abs(g) < 0.13 then i = i - 1 end
    end
    c:put(x, y, WOOD[max(1, min(6, i))])
  end)
end

-- handle beam (axle -> back), snapped at BRK; slivers stick out of the stub
local AX, AY, BX, BY = 17, 46, 60, 29
local BRK = 0.76
local hm, hn, hT, hS = X.cyl(AX, AY, BX, BY, function(t) return 1.4 end)
local hv = X.light(hn, { amb = 0.12, wrap = 0.3 })
local stub = HP.mask()
hm:each(function(x, y)
  local k = K(x, y)
  local lim = BRK + (hS[k] < -0.3 and 0.05 or (hS[k] > 0.4 and 0.025 or 0))
  if hT[k] < lim then stub:set(x, y) end
end)
woodPaint(stub, hv, hS, hT)
stub:each(function(x, y) if not stub:has(x + 1, y) and hT[K(x, y)] > BRK - 0.05 then c:px(x, y, FRESH[2]) end end)
c:px(52, 33, FRESH[1]) c:px(53, 33, FRESH[2])         -- long sliver on top

-- grip end lying on the ground: jagged fresh end at left, worn rounded grip at right
local gm, gn, gT, gS = X.cyl(48, 56, 59, 54, function(t) return t > 0.7 and 1.7 or 1.4 end)
woodPaint(gm, X.light(gn, { amb = 0.12, wrap = 0.3 }), gS, gT)
gm:each(function(x, y) local t = gT[K(x, y)]
  if t < 0.08 then c:px(x, y, FRESH[(x + y) % 2 + 1]) end
  if t > 0.7 and gS[K(x, y)] < 0 then c:px(x, y, WOOD[4]) end end)
c:px(47, 55, FRESH[2])
-- the chip that broke out of the split plank, flying up-right
c:paint({ "..ab", ".ab.", "bb.." }, 52, 21, { a = FRESH[2], b = WOOD[4] })

-- leg (slightly raked) with a foot block, AO where it meets the tray
local lm, ln, lT, lS = X.cyl(40, 39, 43, 56, function(t) return 1.3 end)
woodPaint(lm, X.light(ln, { amb = 0.12, wrap = 0.3 }), lS, lT, -0.1)
for x = 41, 45 do c:px(x, 57, x < 43 and WOOD[3] or WOOD[2]) end c:px(41, 56, WOOD[4]) c:px(45, 56, WOOD[2])

-- tray: three planks, painted, bevelled
local tray = c:poly{ {11,25},{49,25},{43,40},{20,40} }
local planks = { {25, 29}, {30, 34}, {35, 40} }
local pm = {}
for pi, pl in ipairs(planks) do
  local m = tray:copy():clip(c:rect(0, pl[1], 63, pl[2]))
  pm[pi] = m
  local n = X.pillow(m, 1.6)
  local v = X.light(n, { amb = 0.2, wrap = 0.3 })
  local bias = {}
  m:each(function(x, y)
    local k = K(x, y)
    if y == pl[2] then bias[k] = -1 end
    if (x * 7 + pi * 5) % 11 == 0 and y > pl[1] and y < pl[2] then bias[k] = (bias[k] or 0) - 1 end   -- brush streaks
  end)
  G.paint(c, m, v, PAINT, { 0.25, 0.42, 0.58, 0.74, 0.88 }, bias)
  -- pale end grain on the back (right) edge of each plank
  m:each(function(x, y) if not m:has(x + 1, y) then c:px(x, y, y == pl[2] and WOOD[4] or WOOD[5]) end end)
  -- nail head near the back end
  local ny = floor((pl[1] + pl[2]) / 2)
  for x = 48, 20, -1 do if m:has(x, ny) then c:px(x - 2, ny, IRON[2]) c:px(x - 3, ny - 1, IRON[5]) break end end
end
-- chipped paint: small irregular patches of bare wood (lit edge pale, lower-right shade)
for _, ch in ipairs{ {14, 26, 3}, {27, 30, 2}, {35, 26, 2}, {31, 36, 3}, {24, 25, 2} } do
  local x0, y0, w = ch[1], ch[2], ch[3]
  for i = 0, w - 1 do
    if tray:has(x0 + i, y0) then c:px(x0 + i, y0, WOOD[5]) end
    if i > 0 and tray:has(x0 + i, y0 + 1) then c:px(x0 + i, y0 + 1, WOOD[4]) end
  end
end
-- lit top rim (plank top face) and the split at the back corner
for x = 12, 48 do if tray:has(x, 25) then c:px(x, 25, (x < 30) and PAINT[6] or PAINT[5]) end end
for _, p in ipairs{ {44,25},{44,26},{43,27},{42,28} } do c:px(p[1], p[2], WOOD[1]) c:px(p[1] + 1, p[2], FRESH[2]) end
c:px(43, 26, FRESH[1])
-- AO: dark row on the beam / leg just under the tray
for x = 20, 44 do if not tray:has(x, 41) and c:get(x, 41) then c:px(x, 41, WOOD[1]) end end
-- iron corner strap with rivets (front corner)
local strap = c:poly{ {11,25},{15,25},{22,39},{20,40},{18,40} }:clip(tray)
G.paint(c, strap, X.light(X.pillow(strap, 1), { amb = 0.15 }), IRON)
c:px(15, 28, IRON[6]) c:px(18, 35, IRON[6]) c:px(16, 28, IRON[1]) c:px(19, 35, IRON[1])

-- soil heap (crumbly, a pebble) + seedling (quirk)
local soil = c:ellipse(30, 25, 13, 2):clip(c:rect(0, 0, 63, 24))
soil:each(function(x, y)
  local i = y < 23 and 3 or 2
  if (x * 3 + y) % 7 == 0 then i = 4 end
  if not soil:has(x, y - 1) and x > 30 then i = 2 end
  c:px(x, y, SOIL[i])
end)
c:px(37, 23, "#aaa9b8") c:px(38, 23, "#74758c")
c:paint({
  "bc.....",
  "bdcb.cdc",
  ".bbcbcdb",
  "...ab.bb",
  "...a....",
  "...a....",
}, 26, 16, { a = LEAF[2], b = LEAF[2], c = LEAF[3], d = LEAF[4] })
c:px(29, 22, LEAF[1])

-- wheel: iron tyre (flat where it meets the ground), wooden felloe with joints, 6 spokes, iron hub
local WX, WY, R = 16, 47, 9
local tyre = c:ellipse(WX, WY, R, R):cut(c:ellipse(WX, WY, R - 2, R - 2))
G.paint(c, tyre, X.light(G.ringNormals(tyre, WX, WY, R - 0.5, R - 0.5, 0.9), { amb = 0.1, wrap = 0.2 }), IRON)
local fel = c:ellipse(WX, WY, R - 2, R - 2):cut(c:ellipse(WX, WY, R - 3.6, R - 3.6))
G.paint(c, fel, X.light(G.ringNormals(fel, WX, WY, R - 2.8, R - 2.8, 1.0), { amb = 0.15, wrap = 0.3 }), WOOD)
for i = 0, 5 do
  local a = i * math.pi / 3 + 0.3
  local lit = (sin(a) + cos(a) < 0)
  local sm = c:line({ { WX, WY }, { floor(WX + cos(a) * 5.6 + 0.5), floor(WY + sin(a) * 5.6 + 0.5) } }, 1)
  sm:each(function(x, y)
    if not fel:has(x, y) or c:get(x, y) == nil then
      c:px(x, y, lit and WOOD[5] or WOOD[3])
    end
  end)
  -- felloe joint between segments
  local ja = a + math.pi / 6
  c:px(floor(WX + cos(ja) * 6 + 0.5), floor(WY + sin(ja) * 6 + 0.5), WOOD[1])
end
local hub = c:ellipse(WX, WY, 1.5, 1.5)
G.paint(c, hub, X.light(X.sphere(WX - 0.5, WY - 0.5, 1.8, hub), { amb = 0.1 }), IRON)
c:px(WX - 1, WY - 1, IRON[6]) c:px(WX, WY, IRON[1])

G.move(c, 0, DY)
G.fin(c)
