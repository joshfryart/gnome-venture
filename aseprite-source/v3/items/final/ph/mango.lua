-- mango (ph, Opus final pass, replaces the Sonnet draft). Slim kidney-shaped mango hanging on the diagonal: broad
-- stem shoulder, bowed back, small beak at the bottom. Skin moves from a red-orange blush on the sunny shoulder through
-- gold to a green-yellow belly (three 6-tone ramps, hard borders), pale lenticel speckle, waxy bloom round one specular,
-- cool reflected light on the lower-right rim. Woody stem with an AO collar and one long lanceolate mango leaf.
-- quirk: a bead of amber sap has run from the stem scar down the shoulder.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC22_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("mango")

local BL = { "#5a1838", "#8c2340", "#c23a3a", "#e8603a", "#fb8f4a", "#ffc074" }
local GO = { "#6e3020", "#a9532a", "#dc8a2a", "#f5b42e", "#ffd65a", "#fff0a0" }
local GR = { "#2c4632", "#4a6e36", "#76983a", "#a6bc44", "#cfd862", "#eef29c" }
local STEM = { "#2f2a1e", "#4a3f26", "#6b5a32", "#8c7a40", "#ae9a58", "#d0be80" }
local LEAF = { "#14352c", "#1f4f36", "#2b6a3c", "#3f8a44", "#5fa84c", "#8cc860" }
local CUTS = A.CUTS

-- body: tube along a bowed axis, broad at the stem end, a beak at the bottom
local bm, _, BT, BS = A.tube({ { 26, 20 }, { 39, 23 }, { 45, 39 }, { 36, 52 } }, function(t)
  if t > 0.995 then return -1 end
  return max(1.5, 12.3 * sin(pi * min(1, t * 0.9 + 0.08)) ^ 0.5)
end)
local n = A.body(bm, 36, 35, 22, 6, 0.55)

-- stem + leaf masks first, for AO on the shoulder
local stemPts = { { 26, 16 }, { 25, 13 }, { 25, 11 }, { 24, 8 } }
local smask = A.tube(stemPts, function(t) return 1.35 - 0.25 * t end)
local bias = {}
X.ao(bias, bm, smask, 2, -1)

local v = X.light(n, { amb = 0.06, wrap = 0.22 })
local idx, zone = {}, {}
local btok = { r = { name = "skin" } }
bm:each(function(x, y) local k = K(x, y)
  local i = 1
  for j, t in ipairs(CUTS) do if v[k] >= t then i = j + 1 end end
  i = max(1, min(6, i + (bias[k] or 0)))
  idx[k] = i
  local z = (1 - BT[k]) * 1.0 - BS[k] * 0.32 + 0.05 * sin(x * 0.7 + y * 0.35)
  zone[k] = z > 0.66 and BL or (z > 0.38 and GO or GR)
  c:put(x, y, zone[k][i], btok)
end)
local function step(x, y, d) local k = K(x, y) if idx[k] then idx[k] = max(1, min(6, idx[k] + d)) c:put(x, y, zone[k][idx[k]], btok) end end

-- lenticels: sparse pale dots on the interior
local core = bm:shrink(2)
core:each(function(x, y) local k = K(x, y)
  if X.hash(x, y, 31) > 0.94 and idx[k] >= 2 and idx[k] <= 5 then
    c:put(x, y, zone[k] == BL and "#ffd98a" or zone[k][min(6, idx[k] + 1)], btok) end end)
-- cool reflected light on the lower-right rim
local rim = X.rim(n)
bm:edge():each(function(x, y) local k = K(x, y)
  if rim[k] > 0.55 and idx[k] <= 3 then c:put(x, y, zone[k] == GR and "#5e8a86" or (zone[k] == GO and "#9a6a86" or "#7a4a86"), btok) end end)
-- specular + waxy bloom halo
local sx, sy = A.specAt(bm:shrink(3), n, 40)
for _, o in ipairs{ { -1, 0 }, { 2, 0 }, { 0, -1 }, { 1, -1 }, { 0, 1 }, { 1, 1 }, { -1, 1 } } do
  if bm:has(sx + o[1], sy + o[2]) then c:put(sx + o[1], sy + o[2], "#fde4cc", btok) end end
c:put(sx, sy, "#fff6e4", btok) c:put(sx + 1, sy, "#fff6e4", btok)
-- faint ventral line (the mango's side seam) on the shade side
bm:each(function(x, y) local k = K(x, y)
  if abs(BS[k] - 0.45) < 0.05 and BT[k] > 0.25 and BT[k] < 0.85 then step(x, y, -1) end end)

-- stem: woody, collar where it meets the shoulder
local sm = A.stem(c, stemPts, function(t) return 1.35 - 0.25 * t end, STEM, { cut = nil })
c:put(25, 15, STEM[2]) c:put(27, 15, STEM[2]) c:put(24, 15, STEM[3])
c:put(24, 8, STEM[6])

-- leaf: long lanceolate mango leaf sweeping to the left
local lm = A.leaf(c, 24, 10, 15, 2, 7, 11, 3.4, LEAF, { vs = 2.6, fold = 0.5 })
-- contact shadow of stem and leaf on the shoulder
lm:copy():add(sm):shift(1, 1):each(function(x, y) if bm:has(x, y) and not lm:has(x, y) and not sm:has(x, y) then step(x, y, -2) end end)

-- quirk: amber sap bead running from the stem scar down the shoulder
local SAP = { "#8a3a12", "#c86a1a", "#eea036", "#ffd27a", "#fff2c4" }
local drip = { { 23, 17, 3 }, { 22, 18, 3 }, { 22, 19, 2 }, { 21, 20, 3 }, { 22, 20, 2 }, { 21, 21, 2 }, { 22, 21, 1 } }
for _, p in ipairs(drip) do if bm:has(p[1], p[2]) then c:put(p[1], p[2], SAP[p[3]], btok) end end
if bm:has(21, 20) then c:put(21, 20, SAP[5], btok) end

A.save(c, "mango")
