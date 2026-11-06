-- rubber-sap (final pass, Sonnet). A slim tapped rubber sapling: taupe bark with fissures and lenticels, a diagonal
-- tapping groove (pale cambium strip above, dark lip below) running milky latex down to a curved steel spout, a
-- steel hoop and wire holding a fibrous coconut-shell cup brimming with latex that a fat drop is falling into
-- (impact ring), and a glossy trifoliate crown on top (midrib, veins, one specular streak per leaflet).
-- quirk: a tiny ladybird is crawling up the bark.
local NAME = "rubber-sap"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local BARK = { "#30242a", "#4d3b3a", "#6e5a52", "#90786a", "#b39a86", "#d6c0a8" }
local WOOD = { "#a77c52", "#c9a06a", "#e8c88c", "#f6e6b4" }
local LAT = { "#8b8aa8", "#b9b6cc", "#dcd6e0", "#f4eee6", "#fff9ee", "#fffdf6" }
local STEEL = { "#2b3040", "#46506a", "#6d7a96", "#98a6c0", "#c4d0e2", "#eef4fc" }
local COCO = { "#2c1b17", "#47291f", "#683c28", "#8c5636", "#b27a4c", "#d6a26e" }
local LEAF = { "#122e2c", "#1a4a3a", "#276844", "#3c8a4e", "#5eae5c", "#92d27c" }
local CUTS = A.CUTS
local gtok, btok, ltok, stok, ctok, latok = { r = { name = "ground" } }, { r = { name = "bark" } }, { r = { name = "leaf" } },
  { r = { name = "steel" } }, { r = { name = "cup" } }, { r = { name = "latex" } }

c:groundShadow(30, 58, 21, 1.6)

-- trunk: slim taper, slight lean
local tm, tn, TT, TS = X.cyl(19, 57, 17, 24, function(t) return 5.6 * (1 - 0.62 * t ^ 1.1) end)
local idx = X.tone(c, tm, X.light(tn, { amb = 0.08, wrap = 0.25 }), BARK, { cuts = CUTS, tok = btok })
tm:each(function(x, y) local k = K(x, y) local i = idx[k] or 3
  local seg = (y + (x * 5) % 11) % 11
  if x % 3 == 0 and X.hash(x, 0, 3) > 0.55 and seg < 6 and y < 55 then c:put(x, y, BARK[max(1, i - 2)], btok)
  elseif x % 3 == 1 and X.hash(x - 1, 0, 3) > 0.55 and seg < 6 and y < 55 then c:put(x, y, BARK[min(6, i + 1)], btok)
  elseif X.hash(x, y, 4) > 0.955 then c:put(x, y, BARK[min(6, i + 2)], btok) c:put(x + 1, y, BARK[min(6, i + 1)], btok) end
end)
-- root flare shading
tm:each(function(x, y) if y >= 56 then c:put(x, y, BARK[1], btok) end end)

-- tapping groove with latex run
local gx0, gy0, gx1, gy1 = 12.5, 30.5, 22.6, 42
tm:each(function(x, y)
  local d, side = A.dseg(x, y, gx0, gy0, gx1, gy1)
  if d < 0.95 then
    local i = side > 0.35 and 5 or (side > -0.3 and 4 or 3)
    c:put(x, y, LAT[i], latok)
  elseif d < 2.7 and side > 0 then c:put(x, y, WOOD[d < 1.7 and 3 or (d < 2.2 and 2 or 1)], btok)
  elseif d < 1.6 and side < 0 then c:put(x, y, BARK[1], btok) end
end)
for _, p in ipairs{ { 16, 35 }, { 19, 38 }, { 21, 41 } } do if tm:has(p[1], p[2]) then c:put(p[1], p[2], LAT[6], latok) end end

-- steel hoop round the trunk
for x = 13, 24 do
  if tm:has(x, 48) or tm:has(x, 49) then
    local y = 47 + ((abs(x - 18) < 3) and 1 or 0)
    c:put(x, y, STEEL[5], stok) c:put(x, y + 1, STEEL[2], stok)
  end
end

-- crown: three glossy leaflets
local function leaflet(ax, ay, cx, cy, bx, by)
  local m, n, T, S, len = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.99 then return -1 end
    return max(0.5, 4.4 * sin(pi * min(1, t * 0.9 + 0.07)) ^ 0.62 * (1 - 0.45 * t ^ 3))
  end, { fold = 0.38 })
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.14, 0.3, 0.47, 0.64, 0.82 }, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if abs(s) < 0.13 and t > 0.04 and t < 0.9 then c:put(x, y, s <= 0 and "#bfe69a" or LEAF[3], ltok) return end
    if s < -0.34 and s > -0.5 and t > 0.22 and t < 0.55 then c:put(x, y, "#e4f8c0", ltok) return end   -- gloss streak
    local ph = (t * len - abs(s) * 2.6) / 3.4
    local f = abs((ph - floor(ph)) - 0.5) * 2
    if f > 0.9 and abs(s) > 0.28 and abs(s) < 0.8 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
  end)
  return m
end
leaflet(17, 25, 11, 19, 3, 17)
leaflet(17, 25, 24, 20, 32, 16)
leaflet(17, 25, 18, 16, 22, 9)
for _, q in ipairs{ { 16, 24, 3 }, { 17, 24, 4 }, { 18, 24, 3 }, { 17, 25, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- steel spout (curved gutter) and hanging latex bulb
local sm, sn, ST = G.tube({ { 21.5, 41.5 }, { 26, 42 }, { 30, 43.5 }, { 33, 46 } }, function(t) return 1.5 - 0.4 * t end)
X.tone(c, sm, X.light(sn, { amb = 0.1, wrap = 0.3 }), STEEL, { cuts = CUTS, tok = stok })
sm:each(function(x, y) local k = K(x, y) if abs(sn[k][1] * 0 + (ST[k] or 0)) > 0.5 and (x + y) % 5 == 0 then c:put(x, y, STEEL[6], stok) end end)
-- latex pooling in the gutter
for _, p in ipairs{ { 27, 42 }, { 28, 43 }, { 29, 43 }, { 30, 44 } } do c:put(p[1], p[2], LAT[4], latok) end
c:put(28, 42, LAT[6], latok)
-- falling bulb: rows y 47-49
local drop = { { 33, 47, 4 }, { 32, 48, 3 }, { 33, 48, 5 }, { 34, 48, 3 }, { 32, 49, 2 }, { 33, 49, 4 }, { 34, 49, 2 } }
for _, p in ipairs(drop) do c:put(p[1], p[2], LAT[p[3]], latok) end

-- coconut-shell cup
local body = c:ellipse(36, 51, 10, 7):clip(c:rect(20, 51, 52, 62))
local rimOuter = c:ellipse(36, 51, 10, 2.6)
local cup = body:copy():add(rimOuter)
local cn = X.sphere(36, 49, 11, cup)
local cidx = X.tone(c, cup, X.light(cn, { amb = 0.08, wrap = 0.25 }), COCO, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, tok = ctok })
body:each(function(x, y) local i = cidx[K(x, y)] or 3
  local fib = ((x * 2 + floor((y - 51) ^ 1.5 * 0.6)) % 7)
  if y > 52 and fib == 0 and X.hash(x, y, 8) > 0.3 then c:put(x, y, COCO[max(1, i - 1)], ctok)
  elseif y > 52 and fib == 3 and X.hash(x, y, 9) > 0.6 then c:put(x, y, COCO[min(6, i + 1)], ctok) end
end)
-- rim ring, then latex surface inside
local inner = c:ellipse(36, 51, 8.3, 1.7)
rimOuter:copy():cut(inner):each(function(x, y) c:put(x, y, x < 36 and COCO[6] or (y > 51 and COCO[4] or COCO[3]), ctok) end)
inner:each(function(x, y)
  local i = (x < 33) and 5 or ((x < 40) and 4 or 3)
  if y <= 50 then i = i - 1 end
  c:put(x, y, LAT[max(1, i)], latok)
end)
-- impact ring under the drop + a lit meniscus on the left
for _, p in ipairs{ { 31, 51 }, { 32, 52 }, { 34, 52 }, { 35, 51 } } do if inner:has(p[1], p[2]) then c:put(p[1], p[2], LAT[6], latok) end end
c:put(30, 50, LAT[6], latok) c:put(29, 51, LAT[5], latok)
-- wire from hoop to cup
A.line(c, 24, 48, 27, 50, STEEL[3], stok) c:put(25, 49, STEEL[5], stok)

-- quirk: ladybird climbing the bark
local lb = { r = { name = "ladybird" } }
c:put(14, 52, "#241810", lb)
for _, p in ipairs{ { 13, 53, "#ff7a5a" }, { 14, 53, "#241810" }, { 15, 53, "#d42e28" }, { 13, 54, "#d42e28" }, { 14, 54, "#b02420" }, { 15, 54, "#241810" } } do c:put(p[1], p[2], p[3], lb) end
G.save2(c, NAME)
