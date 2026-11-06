-- apple-cider (final, Opus). A slim green-glass cider bottle: long neck, round shoulder, cloudy amber cider up to the
-- shoulder with a pale foam line and rising bubbles, thick glass base with a punt, bright left streak and cool rim.
-- Cork with pale end grain, sealed with glossy red wax that drips down the neck. Cream label wraps the body (bent
-- edges, cylinder shading) with a red apple mark.
-- quirk: a little apple leaf on a twig is pressed into the soft wax seal.
local NAME = "apple-cider"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR2_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sqrt = math.floor, math.abs, math.max, math.min, math.sqrt
local c = A.new(NAME)

local GLASS = { "#1e3e38", "#2e5e50", "#4a8a6e", "#78b48e", "#b0dcb2", "#e6f8dc" }
local CID   = { "#5a2414", "#8c3a16", "#bf5e1a", "#e48a24", "#f6b444", "#ffd884" }
local CORK  = { "#4a2c22", "#6e4530", "#94643f", "#b98552", "#d6a96e", "#efd09a" }
local WAX   = { "#4e1228", "#7e1e34", "#b22c38", "#dc463c", "#f47458", "#ffb090" }
local LAB   = { "#8a6c58", "#b39478", "#d6bc98", "#eedcb8", "#fbf0d2", "#fff8e6" }
local APL   = { "#6e1a2c", "#b42f36", "#e24a3e", "#ff8a62" }
local LEAF  = { "#163a2e", "#1f5436", "#2c703e", "#3f8e46", "#62ae52", "#96cc6c" }
local CX = 31.5
c:groundShadow(32, 51, 12, 1.5)

local function rB(y)
  if y < 9 or y > 50 then return nil end
  if y <= 20 then return 2.9 end
  if y <= 29 then local t = (y - 20) / 9 return 2.9 + 6.6 * (1 - (1 - t) ^ 2.2) end
  if y >= 48 then return ({ [48] = 9.3, [49] = 8.9, [50] = 8.0 })[y] end
  return 9.5
end
local bm, bn, BS = A.lathe(CX, 9, 50, rB)
local gtok, ltok = { r = { name = "glass" } }, { r = { name = "cider" } }
local gidx = A.shade(c, bm, bn, GLASS, { amb = 0.18, wrap = 0.35, tok = gtok, cuts = { 0.22, 0.4, 0.56, 0.72, 0.88 } })

-- cider inside (1 px wall, thick base with a punt)
local lm = HP.mask()
bm:each(function(x, y)
  local r = rB(y)
  local punt = abs(x - CX) < 4 and 46 or 47
  if y >= 23 and y <= punt and abs(x - CX) <= r - 1.2 then lm:set(x, y) end
end)
local ln = {} lm:each(function(x, y) ln[K(x, y)] = bn[K(x, y)] end)
local lb = {} lm:each(function(x, y) if y >= 45 then lb[K(x, y)] = -1 end end)
local lidx = A.shade(c, lm, ln, CID, { amb = 0.12, wrap = 0.35, tok = ltok, bias = lb })
-- foam line + meniscus
lm:each(function(x, y) if y == 23 then c:put(x, y, x < CX and LAB[6] or LAB[4], ltok) elseif y == 24 then c:put(x, y, CID[6], ltok) end end)
-- bubbles rising on the right
for _, p in ipairs{ {35,27}, {36,30}, {34,33}, {36,44}, {35,46} } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], CID[6], ltok) end end

-- label: cream band around the body, edges bowed down at the sides (seen from slightly above)
local labm = HP.mask()
bm:each(function(x, y)
  local s = BS[K(x, y)]
  local bow = floor((1 - sqrt(1 - s * s)) * 2.2 + 0.5)
  if y >= 32 + bow and y <= 42 + bow then labm:set(x, y) end
end)
local ltb = {}
labm:each(function(x, y) local k = K(x, y)
  local s = BS[k]
  local bow = floor((1 - sqrt(1 - s * s)) * 2.2 + 0.5)
  if y == 42 + bow then ltb[k] = -1 end
end)
local labtok = { r = { name = "label" } }
local labIdx = A.shade(c, labm, bn, LAB, { amb = 0.2, wrap = 0.35, tok = labtok, bias = ltb })
-- top / bottom printed rule lines in red
labm:each(function(x, y) local s = BS[K(x, y)]
  local bow = floor((1 - sqrt(1 - s * s)) * 2.2 + 0.5)
  if (y == 33 + bow or y == 41 + bow) and abs(s) < 0.9 then c:put(x, y, s < 0.3 and APL[2] or APL[1], labtok) end
end)
-- contact shade under the label edge
bm:each(function(x, y) if not labm:has(x, y) and labm:has(x, y - 1) and lm:has(x, y) then c:put(x, y, CID[2], ltok) end end)
-- apple mark (slightly left of centre: the label faces the light)
A.map(c, {
  "...gs..",
  "..gs...",
  ".oaoao.",
  "oaahaao",
  "oaaaa1o",
  "oaaa11o",
  ".o111o.",
  "..o.o..",
}, 28, 34, { o = APL[1], a = APL[3], h = APL[4], ["1"] = APL[2], g = LEAF[4], s = CORK[2] }, labtok)

-- glass highlights over everything: left streak, shoulder pop, cool right rim
for y = 26, 46 do if y < 32 or y > 44 then c:put(24, y, GLASS[5], gtok) end end
for y = 35, 41 do c:put(24, y, LAB[6], labtok) end
for y = 15, 20 do c:put(30, y, GLASS[5], gtok) end
c:put(26, 24, A.CREAM, gtok) c:put(27, 24, A.CREAM, gtok) c:put(25, 25, GLASS[6], gtok)
bm:each(function(x, y) local s = BS[K(x, y)] if s > 0.88 and y > 26 and y < 47 and not labm:has(x, y) then c:put(x, y, "#4e7a8a", gtok) end end)
for x = 25, 38 do c:put(x, 49, GLASS[2], gtok) end
for x = 26, 37 do if abs(x - CX) < 4 then c:put(x, 48, GLASS[4], gtok) end end

-- cork (top, above the wax) with pale end grain rings
local ktok = { r = { name = "cork" } }
local km = HP.mask()
for y = 5, 10 do for x = 28, 35 do if not ((y == 5) and (x == 28 or x == 35)) then km:set(x, y) end end end
local kn = {} km:each(function(x, y) local s = (x - CX) / 4.5 kn[K(x, y)] = { A.norm(s, y == 5 and -0.8 or 0, 1) } end)
local kidx = A.shade(c, km, kn, CORK, { amb = 0.15, wrap = 0.3, tok = ktok })
for x = 29, 34 do c:put(x, 5, x < 32 and CORK[6] or CORK[5], ktok) end   -- end grain (top face)
c:put(30, 6, CORK[3], ktok) c:put(32, 7, CORK[2], ktok) c:put(34, 8, CORK[2], ktok) c:put(29, 8, CORK[4], ktok)

-- wax seal: collar over the lip with uneven drips running down the neck
local wtok = { r = { name = "wax" } }
local wm = HP.mask()
for y = 9, 14 do
  local r = ({ [9] = 4.0, [10] = 4.6, [11] = 4.6, [12] = 4.2, [13] = 3.6, [14] = 3.3 })[y]
  for x = 25, 38 do if abs(x - CX) <= r then wm:set(x, y) end end
end
for _, d in ipairs{ { 29, 17 }, { 33, 20 }, { 34, 16 }, { 31, 15 } } do
  for y = 14, d[2] do wm:set(d[1], y) end
  wm:set(d[1], d[2] + 1)
  if d[2] - 14 > 3 then wm:set(d[1] + 1, d[2]) end
end
local wn = X.pillow(wm, 2.2)
local widx = A.shade(c, wm, wn, WAX, { amb = 0.1, wrap = 0.3, tok = wtok })
c:put(28, 10, A.CREAM, wtok) c:put(29, 10, WAX[6], wtok)    -- waxy spec
c:put(33, 18, WAX[5], wtok)                                  -- drip glint

-- quirk: apple leaf on a twig pressed into the wax (sticks out up-right)
local tw = { { 36, 11 }, { 38, 9 }, { 39, 8 }, { 40, 7 } }
for _, p in ipairs(tw) do c:put(p[1], p[2], CORK[2], ktok) end
c:put(37, 10, CORK[3], ktok)
A.leaf(c, 40, 7, 44, 3, 48, 4, 2.2, LEAF, { teeth = 2.2, vs = 2.6, tok = { r = { name = "leaf" } } })

A.save(c, NAME)
