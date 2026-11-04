-- desert-sage-tea (final pass, Opus). Slim tapered tea glass (Moroccan style) of amber-green sage tea: glass walls with a
-- bright rim ellipse, pale core and a vertical specular streak, thick glass foot with a pale core; gold painted bands
-- that wrap the cylinder; tea lit as a cylinder with a lighter surface ellipse and a meniscus line. A sprig of silvery
-- desert sage leans in the glass: pebbled oval leaves with midribs, AO where the stem leaves the tea.
-- quirk: one steam wisp curls into a tiny loop as it rises.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt = math.floor, math.max, math.min, math.abs, math.sqrt
local OUT = app.params.out or (debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/")
local c = A.new("desert-sage-tea")

local TEA   = { "#4a2f1f", "#77502a", "#a37a32", "#c79d3e", "#dfbd5c", "#f1da8e" }
local GLASS = { "#5d7a96", "#83a3bb", "#a9c6d5", "#c9e0e6", "#e3f1f0", "#f6fbf5" }
local GOLD  = { "#7a3f1c", "#b9702a", "#e0a032", "#f7cf5c", "#fff0a8" }
local SAGE  = { "#26392f", "#3b5646", "#567661", "#77967c", "#9db69b", "#c8d8bf" }
local STEM  = { "#4b5b3e", "#71845a", "#98aa7a" }
local STEAM = { "#c9c3dc", "#e9e6f4" }

c:groundShadow(32, 52, 11, 1.5)

-- glass body: tapered, top ellipse rim, rounded foot
local L0, R0, L1, R1, YT, YB = 22, 41, 25, 38, 21, 50
local body = c:poly{ { L0, YT }, { R0 + 1, YT }, { R1 + 1, YB }, { L1, YB } }
body:add(c:ellipse(31.5, YT, 9.5, 2.5)):add(c:ellipse(31.5, YB - 0.5, 6.5, 1.5))
local function lr(y) local t = (y - YT) / (YB - YT) return L0 + (L1 - L0) * t, R0 + (R1 - R0) * t end
local gtok = { r = { name = "glass" } }
-- base layer: empty glass (pale, cylinder lit)
local nG = {}
body:each(function(x, y) local l, r = lr(math.min(YB, math.max(YT, y)))
  local t = max(-.97, min(.97, ((x + .5 - l) / (r + 1 - l)) * 2 - 1)) nG[K(x, y)] = { t, 0, sqrt(1 - t*t) } end)
local gi = A.shade(c, body, nG, GLASS, { amb = 0.35, wrap = 0.5, tok = gtok })

-- tea column inside (walls 1 px), from the surface down to the thick foot
local TY, FY = 27, 45
local tea = HP.mask()
body:each(function(x, y) local l, r = lr(y)
  if y >= TY and y <= FY and x >= floor(l) + 1 and x <= floor(r + .5) - 1 then tea:set(x, y) end end)
local surf = c:ellipse(31.5, TY, 8.3, 1.6)
surf:clip(body)
tea:add(surf)
local ttok = { r = { name = "tea" } }
local nT = {}
tea:each(function(x, y) local l, r = lr(y)
  local t = max(-.97, min(.97, ((x + .5 - l) / (r + 1 - l)) * 2 - 1)) nT[K(x, y)] = { t, 0.15, sqrt(1 - t*t) } end)
local bias = {}
tea:each(function(x, y) if y >= FY - 1 then bias[K(x, y)] = -1 end end)   -- darker where the tea meets the foot
local ti = A.shade(c, tea, nT, TEA, { amb = 0.12, wrap = 0.3, bias = bias, tok = ttok })
-- surface: lighter, meniscus ring darker at the back, glint
surf:each(function(x, y) local f = (x - 23) / 17
  c:put(x, y, f < 0.3 and TEA[6] or f < 0.75 and TEA[5] or TEA[4], ttok) end)
for x = 25, 38 do if surf:has(x, TY - 2) or surf:has(x, TY - 1) then
  local y = surf:has(x, TY - 2) and TY - 2 or TY - 1 c:put(x, y, TEA[3], ttok) end end
c:put(27, TY, A.CREAM, ttok) c:put(28, TY, TEA[6], ttok)
-- bottom of the tea seen through the glass foot: dark line
for x = 26, 37 do c:put(x, FY + 1, TEA[2], ttok) end
-- thick glass foot: pale core, darker edges
for y = FY + 2, YB do local l, r = lr(y)
  for x = floor(l), floor(r + .5) do if body:has(x, y) then
    local f = (x - l) / (r - l)
    local col = f < 0.18 and GLASS[3] or f < 0.45 and GLASS[6] or f < 0.8 and GLASS[4] or GLASS[2]
    if y == YB then col = f < 0.5 and GLASS[3] or GLASS[1] end
    c:put(x, y, col, gtok) end end end

-- glass walls over the tea: lit wall pale, shade wall cool
for y = TY + 1, FY do local l, r = lr(y)
  c:put(floor(l), y, GLASS[4], gtok) c:put(floor(r + .5), y, GLASS[2], gtok) end
-- vertical specular streak (glass) on the lit side + 1 glint
for y = TY + 3, FY - 3 do local l = lr(y) local x = floor(l) + 2
  if y ~= 32 and y ~= 33 and y ~= 42 then c:put(x, y, (y < TY + 8) and GLASS[6] or GLASS[5], gtok) end end
c:put(floor(lr(TY + 4)) + 3, TY + 4, GLASS[6], gtok)
-- cool reflected light lower right
for y = 36, 43 do local _, r = lr(y) c:put(floor(r + .5) - 1, y, "#8a7a6c", ttok) end

-- rim: bright ellipse; empty glass between rim and tea surface shows the far wall
local rimO = c:ellipse(31.5, YT, 9.5, 2.5)
local rimI = c:ellipse(31.5, YT, 8.5, 1.5)
rimO:each(function(x, y)
  if rimI:has(x, y) then c:put(x, y, y <= YT and GLASS[3] or GLASS[4], gtok)
  else c:put(x, y, (x < 30 and y <= YT) and GLASS[6] or (y > YT and x > 34) and GLASS[3] or GLASS[5], gtok) end end)
-- empty band from rim to surface (front wall, see-through)
for y = YT + 2, TY - 2 do local l, r = lr(y)
  for x = floor(l) + 1, floor(r + .5) - 1 do if not surf:has(x, y) then
    local f = (x - l) / (r - l)
    c:put(x, y, f < 0.25 and GLASS[5] or f < 0.7 and GLASS[4] or GLASS[3], gtok) end end end
c:put(24, YT, A.CREAM, gtok) c:put(25, YT - 1, A.CREAM, gtok)

-- gold painted bands (wrap: bright on the lit side, shade on the right) with dot motif
local function band(y, dots)
  local l, r = lr(y)
  for x = floor(l), floor(r + .5) do if body:has(x, y) then
    local f = (x - l) / (r - l)
    local i = f < 0.15 and 3 or f < 0.4 and 5 or f < 0.65 and 4 or f < 0.85 and 3 or 2
    c:put(x, y, GOLD[i], gtok) end end
  if dots then
    local l2, r2 = lr(y + 2)
    for x = floor(l2) + 2, floor(r2 + .5) - 2, 3 do
      local f = (x - l2) / (r2 - l2)
      c:put(x, y + 2, GOLD[f < 0.5 and 4 or 2], gtok) c:put(x, y + 1, GOLD[f < 0.5 and 3 or 1], gtok) end
  end
end
band(31, true) band(32) band(43)

-- sage sprig: stem from the tea up to the right, leaning on the back rim
local stok = { r = { name = "sage" } }
local stem = { { 35, 26 }, { 36, 23 }, { 37, 20 }, { 38, 17 }, { 39, 15 }, { 40, 13 }, { 41, 11 }, { 42, 9 } }
for i, p in ipairs(stem) do c:put(p[1], p[2], i <= 2 and STEM[1] or STEM[2], stok) c:put(p[1] + 1, p[2], STEM[1], stok)
  if i > 2 then c:put(p[1], p[2] + 1, STEM[3], stok) end end
-- AO ring where the stem leaves the tea
c:put(34, 26, TEA[2], ttok) c:put(37, 26, TEA[3], ttok)
local function leaf(cx, cy, ux, uy, ra, rb)
  local m = A.rell(cx, cy, ux, uy, ra, rb)
  local n = {}
  m:each(function(x, y) local dx, dy = x - cx, y - cy
    local a = (dx*ux + dy*uy) / (ra + .5) local b = (-dx*uy + dy*ux) / (rb + .5)
    local fold = b < 0 and -0.45 or 0.45
    local nx, ny = -uy * (b * 0.6 + fold), ux * (b * 0.6 + fold)
    n[K(x, y)] = { A.norm(nx + ux * a * 0.4, ny + uy * a * 0.4, 1) } end)
  local idx = A.shade(c, m, n, SAGE, { amb = 0.14, wrap = 0.3, tok = stok, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 } })
  m:each(function(x, y) local dx, dy = x - cx, y - cy
    local a = (dx*ux + dy*uy) / ra local b = (-dx*uy + dy*ux) / rb
    if abs(b) < 0.25 and a > -0.85 and a < 0.7 then c:put(x, y, SAGE[min(6, (idx[K(x, y)] or 3) + 1)], stok)
    elseif abs(b) > 0.35 and abs(b) < 0.8 and X.hash(x, y, 7) > 0.72 then A.step(c, idx, SAGE, x, y, 1, stok) end end)
  return m
end
leaf(43.5, 7.5, 0.35, -0.94, 3.6, 1.7)                -- tip leaf
leaf(46, 12.5, 0.8, -0.6, 4.2, 1.9)                   -- right
leaf(36.4, 13.0, -0.82, -0.57, 4.0, 1.8)              -- left
leaf(43.5, 19.0, 0.86, 0.5, 3.6, 1.7)                 -- low right, drooping
-- re-assert stem over the leaf bases
for i = 4, #stem do local p = stem[i] c:put(p[1], p[2], STEM[2], stok) end
c:put(42, 9, STEM[3], stok)

-- quirk: steam wisp rising left of the sprig, curling into a tiny loop
local wisp = { { 28, 18 }, { 27, 17 }, { 27, 16 }, { 28, 15 }, { 29, 14 }, { 29, 13 }, { 28, 12 }, { 27, 11 },
  { 26, 11 }, { 25, 10 }, { 25, 9 }, { 26, 8 }, { 27, 8 }, { 27, 9 } }
for i, p in ipairs(wisp) do c:put(p[1], p[2], (i % 4 == 1) and STEAM[1] or STEAM[2], { r = { name = "steam" } }) end

A.finish(c, "desert-sage-tea", OUT)
