-- pear-butter (final pass, Opus, aC32_5). A slim glass jar of amber pear butter: cylinder-lit butter seen through the
-- glass (pale glass wall, bright rim, vertical specular streak, thin second streak on the shade side), a short glass
-- headspace under a gingham cloth cap (check weave, fold lines, scalloped skirt, AO where it laps the neck), tied with
-- twisted twine and a bow. Cream paper label with a tiny drawn pear. Two-tone ground shadow.
-- quirk: a real pear stalk with one leaf is tucked under the twine.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("pear-butter")

local BUT   = { "#4a2216", "#72361a", "#9a5422", "#bc742e", "#d89a42", "#f0c06a" }
local GLASS = { "#3a5a66", "#5f8a92", "#9cc4c4", "#d2ece4" }
local CLOTH = { "#5e1e30", "#94303a", "#c24a44", "#e06a52", "#f49070" }
local CREAMC= { "#b8a08a", "#dcc8ae", "#f2e4cc", "#fff4dc" }
local TW    = { "#6a4a2a", "#a07a46", "#d0ac6c", "#ecd096" }
local LABEL = { "#c8b08a", "#e6d4b0", "#f8ecd0" }
local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM  = { "#3a2420", "#5e3a2a", "#86583a", "#ae7e52" }
local SPEC  = "#fffbe8"

c:groundShadow(32, 55, 14, 2)
local X0, X1 = 21, 43
local jar = HP.mask():add(c:rrect(X0, 27, X1, 54, 4)):add(c:rrect(24, 22, 40, 28, 1))
-- butter fill: everything below the headspace line
local fill = jar:copy():clip(c:rect(X0, 31, X1, 53))
local head = jar:copy():cut(fill)
local btok = { r = { name = "butter" } }
local bi = {}
do
  local n = {}
  fill:each(function(x, y) local t = max(-.96, min(.96, ((x - X0) / (X1 - X0)) * 2 - 1))
    local bot = (y >= 51) and 0.35 or 0
    n[K(x, y)] = { A.norm(t, bot, sqrt(1 - t * t)) } end)
  bi = A.shade(c, fill, n, BUT, { tok = btok, amb = 0.1, wrap = 0.35 })
end
-- swirl texture inside the butter: soft folded streaks
fill:each(function(x, y) local k = K(x, y)
  local w = sin((y + 0.35 * x) * 0.7 + sin(x * 0.4) * 1.5)
  if w > 0.92 and bi[k] > 1 then c:put(x, y, BUT[bi[k] - 1], btok) end
  if w < -0.95 and bi[k] < 6 then c:put(x, y, BUT[bi[k] + 1], btok) end
end)
-- butter surface (meniscus) at the headspace line
for x = X0 + 1, X1 - 1 do c:put(x, 31, x < 30 and BUT[6] or BUT[5], btok) end
-- headspace glass
local gtok = { r = { name = "glass" } }
head:each(function(x, y) local t = (x - X0) / (X1 - X0)
  c:put(x, y, t < 0.3 and GLASS[3] or (t < 0.75 and GLASS[2] or GLASS[1]), gtok) end)
-- glass wall: 1 px edge, pale on the lit side, cool dark on the shade side; thick bottom
jar:edge():each(function(x, y) local t = (x - X0) / (X1 - X0)
  c:put(x, y, (t < 0.5 and y < 52) and GLASS[3] or GLASS[1], gtok) end)
for x = X0 + 2, X1 - 2 do c:put(x, 53, GLASS[2], gtok) end
-- specular streaks (glass)
for y = 33, 49 do if y ~= 41 and y ~= 42 then c:put(X0 + 2, y, GLASS[4], gtok) end end
for y = 34, 38 do c:put(X0 + 3, y, SPEC, gtok) end
for y = 36, 46 do if y % 4 ~= 0 then c:put(X1 - 2, y, GLASS[2], gtok) end end
c:put(X0 + 3, 51, GLASS[4], gtok)

-- label: cream paper with a tiny pear drawn on it
local lab = c:rrect(26, 38, 38, 47, 1)
local ltok = { r = { name = "label" } }
lab:each(function(x, y) local t = (x - 26) / 12
  c:put(x, y, t < 0.15 and LABEL[2] or (t > 0.82 and LABEL[1] or LABEL[3]), ltok) end)
for x = 27, 37 do c:put(x, 47, LABEL[1], ltok) end
A.map(c, { "...a.", "..bb.", ".bccb", "bccdb", "bcddb", ".bbb." }, 30, 40,
  { a = "#5e3a2a", b = "#46682c", c = "#c8d852", d = "#9cba3c" }, ltok)

-- cloth cap: dome over the neck + scalloped skirt
local cap = HP.mask():add(c:ellipse(32, 19, 12.5, 5)):add(c:rect(20, 19, 44, 23))
for i = 0, 4 do local sx = 21 + i * 5.5 cap:add(c:ellipse(sx, 24, 2.6, 2.2)) end
cap:cut(c:rect(0, 27, 63, 63))
local ctok = { r = { name = "cloth" } }
local cn = X.pillow(cap, 3)
local cv = X.light(cn, { amb = 0.1, wrap = 0.3 })
cap:each(function(x, y) local k = K(x, y)
  local lum = cv[k]
  -- folds: vertical-ish ridges fanning from the top centre
  local f = sin((x - 32) / (1 + (y - 13) * 0.18) * 1.6)
  lum = lum + 0.12 * f
  local i = lum < 0.35 and 1 or (lum < 0.55 and 2 or (lum < 0.72 and 3 or 4))
  -- gingham: stripes every 3 px both ways
  local sxs, sys = (x % 4 < 2), (y % 4 < 2)
  local col
  if sxs and sys then col = CLOTH[i]
  elseif sxs or sys then col = CLOTH[min(5, i + 1)]
  else col = CREAMC[i] end
  c:put(x, y, col, ctok)
end)
-- AO under the skirt onto the glass neck/shoulder
for x = 22, 42 do if jar:has(x, 27) and not cap:has(x, 27) then c:put(x, 27, GLASS[1], gtok) end
  if jar:has(x, 28) and cap:has(x, 26) then c:put(x, 28, GLASS[1], gtok) end end
-- twine band with twist (alternating light/dark diagonal pairs)
local twtok = { r = { name = "twine" } }
for x = 20, 44 do
  local p = (x % 3)
  c:put(x, 21, p == 0 and TW[4] or (p == 1 and TW[3] or TW[2]), twtok)
  c:put(x, 22, p == 0 and TW[2] or (p == 1 and TW[1] or TW[3]), twtok)
end
-- bow: two loops + tails at front centre
A.map(c, { ".aab.bba.", "abccdccba", ".bddedb..", "...cdc...", "...b.c...", "...a..b.." }, 28, 19,
  { a = TW[2], b = TW[3], c = TW[4], d = TW[1], e = "#4a3020" }, twtok)

-- quirk: pear stalk + leaf tucked under the twine at the right
local sm = A.stem(c, { { 41, 22 }, { 43, 18 }, { 45, 15 }, { 47, 12 } }, function(t) return 0.9 - t * 0.2 end, STEM, { tok = twtok })
A.leaf(c, 46, 13, 50, 7, 55, 9, 2.6, LEAF, { cut = sm, vs = 2.6 })
c:put(42, 21, TW[3], twtok) c:put(42, 22, TW[2], twtok)   -- twine laps back over the stalk
c:put(41, 23, CLOTH[1], ctok)

A.save(c, "pear-butter")
