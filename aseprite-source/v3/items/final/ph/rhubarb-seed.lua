-- rhubarb-seed (final, agent aD12_3). Three papery three-winged rhubarb seeds (red-brown nut + pale ribbed wings) on a
-- torn scrap of broad rhubarb leaf (ruffled margin, red palmate veins, pale fibrous torn edge, contact shadows). The right
-- seed has sprouted: a pink stem, two oval cotyledons and a first crinkled cordate leaf with red palmate veins.
-- quirk: the empty seed husk is still perched on one cotyledon tip like a tiny hat.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD12_3.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.max, math.min, math.sqrt, math.atan
local c = A.new("rhubarb-seed")
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local PINK = { "#6e1f3a", "#a02a4a", "#d04060", "#ec6280", "#f6a0b0", "#ffd0d8" }
local WING = { "#7a4a3a", "#a87860", "#d0a080", "#e8c0a0", "#f6dcc0", "#fff0dc" }
local BODY = { "#3a1618", "#5e2420", "#843a2c", "#a85a3c", "#c87e4e", "#e8a870" }
local VEIN, VEIN2 = "#b0305a", "#e07896"

-- leaf scrap: wavy margin on three sides, torn (jagged) on the left
local zig = { 0, 2, 1, 3, 1, 0, 2, 3, 1, 0, 2, 1, 3, 2, 0, 1, 2, 3, 1, 0, 2 }
local scrap = A.maskFrom(function(x, y)
  local dx, dy = (x - 31) / 21.5, (y - 47) / 10.5
  local ang = atan(dy, dx)
  local r = sqrt(dx * dx + dy * dy)
  local lim = 1 + 0.06 * sin(ang * 9) + 0.04 * sin(ang * 5 + 1)
  return r <= lim and x >= 11 + zig[(y % #zig) + 1]
end, 5, 33, 56, 62)
local bias = {}
local seeds = { { 21, 51, 0.5 }, { 31, 45, -0.3 }, { 44, 48, 0.15 } }
local function seedMasks(cx, cy, rot)
  local tri = { { 0, -1 }, { 0.87, 0.5 }, { -0.87, 0.5 } }
  local function T(s) return A.rotpts(tri, cx, cy, rot, s) end
  local wing = c:poly(T(7.2)):clip(c:ellipse(cx, cy, 5.1, 5.2))
  local body = c:poly(T(3.6)):clip(c:ellipse(cx, cy, 2.8, 2.9))
  return wing, body
end
local sm = {}
for i, s in ipairs(seeds) do sm[i] = { seedMasks(s[1], s[2], s[3]) } end
for i, s in ipairs(seeds) do
  local w = sm[i][1]
  w:shift(1, 2):each(function(x, y) if scrap:has(x, y) and not w:has(x, y) then bias[K(x, y)] = -2 end end)
end
local tok = { r = { name = "leaf" } }
A.lit(c, scrap, LEAF, 4, { amb = 0.12, wrap = 0.3, bias = bias, tok = tok })
-- ruffled margin: dark crinkle dots along the lower rim, pale along the upper
scrap:edge():each(function(x, y) end)
local inner = scrap:copy():shrink(1)
scrap:copy():cut(inner):each(function(x, y)
  if x > 13 then
    if y > 47 and (x + y) % 4 < 2 then c:px(x, y, LEAF[2]) elseif y <= 47 and (x * 3 + y) % 5 < 2 then c:px(x, y, LEAF[5]) end
  end
end)
-- palmate veins from the torn base
local VC = scrap:copy():shrink(1)
local ox, oy = 13, 47
for _, q in ipairs{ {50,43},{44,36},{34,35},{26,36},{47,54},{37,57},{26,57} } do
  A.line(c, ox, oy, q[1], q[2], function(i, n) return i < n * 0.55 and VEIN or "#8a7a8a" end, VC)
end
for _, q in ipairs{ {50,43},{44,36},{34,35} } do A.line(c, ox, oy - 1, q[1], q[2] - 1, function(i, n) return i < n * 0.5 and VEIN2 or LEAF[5] end, VC) end
for x = 13, 24 do c:px(x, 47, VEIN) c:px(x, 48, "#8a2848") end
-- torn edge: pale fibres
for y = 33, 62 do
  for x = 5, 40 do if scrap:has(x, y) then
    c:px(x, y, (y % 2 == 0) and "#e8f0a8" or "#c2e48c")
    if scrap:has(x + 1, y) then c:px(x + 1, y, LEAF[5]) end
    break end end
end

-- sprouting stem + cotyledons + first leaf (behind the right seed)
local stp = { { 44, 47 }, { 43, 39 }, { 45, 29 }, { 43, 21 } }
local stm, stn = G.tube(stp, function(t) return 1.5 - 0.35 * t end)
X.tone(c, stm, X.light(stn, { amb = 0.12, wrap = 0.3 }), PINK, { cuts = { 0.22, 0.42, 0.6, 0.78, 0.9 }, tok = { r = { name = "stem" } } })
local ltok = { r = { name = "leaf2" } }
local function cot(cx, cy, rx, ry, ang)
  local m, n = G.oval(cx, cy, rx, ry, ang, 0.9)
  m:cut(stm)
  G.toneN(c, m, n, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  for u = -rx + 1, rx - 0.5, 1 do c:put(floor(cx + u * ca + .5), floor(cy + u * sa + .5), LEAF[6], ltok) end
  m:copy():shift(1, 2):cut(m):each(function(x, y) if scrap:has(x, y) then c:px(x, y, LEAF[1]) end end)
  return m
end
cot(38.5, 33.5, 4.8, 2.2, -0.5)
cot(50, 32, 4.8, 2.2, 0.45)
-- crinkled cordate first leaf, palmate red veins
local blade = c:ellipse(39.5, 14.5, 5.8, 5.6):add(c:ellipse(47, 14.5, 5.8, 5.6)):add(c:ellipse(43.3, 10.5, 7.5, 5.2)):add(c:rect(41, 17, 45, 20))
local cut = {}
blade:each(function(x, y) if (x * 7 + y * 3) % 11 == 0 and not blade:copy():shrink(1):has(x, y) then cut[#cut + 1] = { x, y } end end)
for _, p in ipairs(cut) do blade:cut(c:rect(p[1], p[2], p[1], p[2])) end
local bb = {}
blade:each(function(x, y) bb[K(x, y)] = floor(sin(x * 1.3 + y * 0.8) * 0.95) end)
A.lit(c, blade, LEAF, 4.5, { amb = 0.12, wrap = 0.3, bias = bb, tok = ltok })
local bv = blade:copy():shrink(1)
for _, q in ipairs{ {35,12},{37,7},{43,5},{49,7},{52,12} } do
  A.line(c, 43, 19, q[1], q[2], function(i, n) return i < n * 0.6 and VEIN2 or VEIN end, bv)
end
for y = 17, 20 do c:px(43, y, PINK[3]) end
blade:copy():cut(bv):each(function(x, y) if (x + y) % 3 == 0 then c:px(x, y, LEAF[5]) end end)
c:px(41, 9, LEAF[6]) c:px(42, 9, LEAF[6])
-- husk hat on the right cotyledon tip (quirk)
local hat = c:poly{ { 53, 28 }, { 56, 30 }, { 52, 31 } }
A.lit(c, hat, WING, 1.2)
c:px(54, 29, WING[6]) c:px(53, 31, WING[1])

-- seeds
local function drawSeed(i)
  local w, b = sm[i][1], sm[i][2]
  A.lit(c, w, WING, 2.4, { amb = 0.1, wrap = 0.3 })
  local s = seeds[i]
  for k = 0, 2 do
    local a = s[3] - 1.5708 + k * 2.0944
    A.line(c, s[1] + cos(a) * 2, s[2] + sin(a) * 2, s[1] + cos(a) * 5.2, s[2] + sin(a) * 5.2, WING[2], w)
  end
  w:copy():cut(w:copy():shrink(1)):each(function(x, y) c:px(x, y, WING[2]) end)
  b:grow(1):cut(b):each(function(x, y) if w:has(x, y) then c:px(x, y, WING[1]) end end)
  A.lit(c, b, BODY, 2.2, { amb = 0.1 })
  c:px(s[1] - 1, s[2] - 1, "#ffe0b0")
end
drawSeed(1) drawSeed(2)
-- seed 3 sits over the stem foot
drawSeed(3)
A.save(c, "rhubarb-seed")
