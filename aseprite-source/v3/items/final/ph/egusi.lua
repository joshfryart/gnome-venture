-- egusi (Opus single pass, aB25_3). An egusi melon: round, pale green rind with dark mottled meridian stripes
-- converging on the stem dimple, cream speckles, waxy bloom on the lit shoulder, one specular, cool reflected
-- light on the lower right, AO ring round the stem. Ribbed woody stem with a pale cut end, a three-lobed
-- melon leaf (veins), small ground shadow.
-- quirk: a ladybird is out for a walk on the leaf.
local NAME = "egusi"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB25_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = G.new2(NAME)
local LT = { "#24503e", "#3a7a4a", "#5a9e56", "#86c26a", "#b2da88", "#d8eeb0" }
local DK = { "#132c2c", "#1c4334", "#275e3e", "#3a7c48", "#56985a", "#80b872" }
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#2e3022", "#4f5530", "#76803e", "#a3ac5a", "#cdd28a", "#ece8b4" }
local COOL, BLOOM, SPEC, FLECK = "#3e7c7a", "#cfe6c2", "#f6fbe2", "#e8f2c0"
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.86 }

local cx, cy, rx, ry = 31, 37, 15.5, 14
c:groundShadow(cx + 2, cy + ry + 1, 12, 2)
local mm, mn = G.oval(cx, cy, rx, ry, 0, 1)
local v = X.light(mn, { amb = 0.1, wrap = 0.3 })
local rim = X.rim(mn)
local tok = { r = { name = "melon" } }
local sx, sy = cx, cy - ry + 0.5           -- stem dimple
mm:each(function(x, y) local k = K(x, y)
  local i = G.qi(v[k], CUTS)
  local d = sqrt((x - sx)^2 + (y - sy)^2)
  if d < 2.6 then i = i - 2 elseif d < 3.8 then i = i - 1 end
  i = max(1, min(6, i))
  local u, w = (x - cx) / (rx + 0.45), (y - cy) / (ry + 0.45)
  local ring = sqrt(max(0.0001, 1 - w * w))
  local phi = asin(max(-1, min(1, u / ring)))
  local st = sin(phi * 7 + 0.55 * sin(w * 9 + phi * 4) + 0.4)
  local dark = st > 0.28
  local col = (dark and DK or LT)[i]
  if not dark and i >= 3 and i <= 5 and X.hash(x, y, 11) > 0.9 and st < -0.2 then col = FLECK end
  if not dark and i == 6 then col = BLOOM end
  if rim[k] > 0.72 and i <= 2 and d > 4 then col = COOL end
  c:put(x, y, col, tok)
end)
-- one specular, 2x1
do local bx, by = G.specAt(mm, mn, 40) c:put(bx, by, SPEC, tok) c:put(bx + 1, by, "#e2f2c6", tok) end

-- stem: ribbed, woody, pale cut end
local stok = { r = { name = "stem" } }
local sp = { { 31, 25 }, { 31, 20 }, { 33, 16 }, { 36, 13 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.7 - 0.4 * t end)
local sidx = X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STEM, { cuts = { 0.2, 0.38, 0.56, 0.74, 0.9 }, tok = stok })
sm:each(function(x, y) local k = K(x, y) if SS[k] > 0.15 and SS[k] < 0.5 then c:put(x, y, STEM[max(1, sidx[k] - 1)], stok) end end)
for _, q in ipairs{ { 36, 12 }, { 37, 12 }, { 37, 13 } } do c:put(q[1], q[2], STEM[6], stok) end
c:put(38, 13, STEM[4], stok)

-- leaf: three lobes, attached at the stem, lying out to the upper left
local B = { 30, 18 }
local lobes = { { -1, -0.5, 13, 3.3 }, { -0.45, -1, 10, 2.8 }, { -1, 0.35, 9, 2.6 } }
local lf = G.palm(B[1] - 1, B[2], lobes, 2.6)
lf:cut(sm)
local lb = {}
X.ao(lb, lf, sm, 1, -1)
G.cast(lb, mm, lf, 1, 2, 0)    -- (no-op guard)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lf, X.pillow(lf, 2), LEAF, { bias = lb, tok = ltok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.14, wrap = 0.25 })
for _, l in ipairs(lobes) do
  local l2 = sqrt(l[1]^2 + l[2]^2)
  for i = 1, l[3] - 2 do local x, y = floor(B[1] - 1 + l[1] / l2 * i + 0.5), floor(B[2] + l[2] / l2 * i + 0.5)
    if lf:has(x, y) then c:put(x, y, i < 3 and LEAF[4] or LEAF[6], ltok) end end
end
-- contact shadow of the leaf on the melon's top
lf:shift(1, 1):each(function(x, y) if mm:has(x, y) and not lf:has(x, y) and not sm:has(x, y) then c:put(x, y, DK[2], tok) end end)

-- quirk: ladybird on the big lobe
do local lx, ly = 19, 12
  local q = { r = { name = "ladybird" } }
  c:put(lx, ly, "#ff8a5c", q) c:put(lx + 1, ly, "#e8493b", q) c:put(lx + 2, ly, "#e8493b", q)
  c:put(lx, ly + 1, "#e8493b", q) c:put(lx + 1, ly + 1, "#2b1c26", q) c:put(lx + 2, ly + 1, "#b52e3f", q)
  c:put(lx - 1, ly + 1, "#2b1c26", q) c:put(lx + 1, ly - 1, "#2b1c26", q)
end

G.save2(c, NAME)
