-- breadfruit (final, Opus aB10_3). A slightly oval breadfruit, lime-green rind tiled with small domed hexagonal
-- facets (each lit on its own upper-left, grooves between, a dark pip at the centre of the lit facets), cool
-- reflected light on the lower-right rim, one specular. Short woody stalk with AO where it meets the fruit, and one
-- deeply lobed breadfruit leaf (midrib, a vein into each lobe, V-fold light) swept off to the upper right.
-- quirk: a bead of milky latex is weeping from the stalk scar and running down the rind.
local NAME = "breadfruit"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB10_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, asin = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.asin
local c = A.new(NAME)
local RIND = { "#1d4536", "#2c6239", "#43823a", "#69a33c", "#98c447", "#cfe27a" }
local COOL = "#4f8f86"
local LEAF = { "#133a32", "#1d5139", "#2b6c40", "#3f8a45", "#62a94e", "#93c965" }
local VEIN = "#b8dc84"
local STALK = { "#3c2420", "#5c3726", "#7f5232", "#a37446", "#c79a62" }
local LATEX = { "#d9d2b8", "#f2ecd6", "#fff4d6" }

local CX, CY, RX, RY = 28, 39, 13.5, 15
-- fruit body (slightly taller than wide, a touch flatter at the base)
local fm, fn = HP.mask(), {}
for y = floor(CY - RY - 1), floor(CY + RY + 1) do for x = floor(CX - RX - 1), floor(CX + RX + 1) do
  local u, v = (x - CX) / (RX + .5), (y - CY) / (RY + .5)
  if v > 0.55 then u = u * (1 + (v - 0.55) * 0.35) end
  local q = u*u + v*v
  if q <= 1 then
    fm:set(x, y)
    fn[K(x, y)] = { A.norm(u, v, sqrt(max(1 - q, 0.03))) }
  end
end end

-- facets: hex grid in surface coordinates (compresses toward the rim, so it wraps the ball)
local S = 3.6
local function cell(U, V)
  local best, b2, bu, bv = 1e9, 1e9, 0, 0
  local j0 = floor(V / (S * 0.866))
  for j = j0 - 1, j0 + 2 do
    local cy = j * S * 0.866
    local off = (j % 2) * S / 2
    local i0 = floor((U - off) / S)
    for i = i0 - 1, i0 + 2 do
      local cx = i * S + off
      local d = (U - cx)^2 + (V - cy)^2
      if d < best then b2 = best best, bu, bv = d, cx, cy elseif d < b2 then b2 = d end
    end
  end
  return sqrt(best), sqrt(b2), bu, bv
end
local pn, bias, groove, centre = {}, {}, {}, {}
fm:each(function(x, y) local k = K(x, y) local n = fn[k]
  local U, V = asin(max(-1, min(1, n[1]))) * 10 + 0.7, asin(max(-1, min(1, n[2]))) * 10 + 0.4
  local d1, d2, cu, cv = cell(U, V)
  local du, dv = (U - cu) / S, (V - cv) / S
  pn[k] = { A.norm(n[1] + du * 0.75, n[2] + dv * 0.75, n[3]) }
  if d2 - d1 < 0.55 then groove[k] = true bias[k] = -1 end
  if d1 < 0.42 then centre[k] = true end
end)
-- stalk AO and leaf contact shadow on the fruit
local sp = { { 29, 25 }, { 29, 22 }, { 30, 19 }, { 32, 16 } }
local sm, sn = A.tube(sp, function(t) return 1.6 - t * 0.35 end)
X.ao(bias, fm, sm, 2, -1)
local ftok = { r = { name = "rind" } }
local fidx = A.lit(c, fm, pn, RIND, { tok = ftok, amb = 0.08, wrap = 0.3, bias = bias, cuts = { 0.16, 0.32, 0.5, 0.67, 0.84 } })
-- facet pips: a dark dot in the centre of the brighter facets
fm:each(function(x, y) local k = K(x, y)
  if centre[k] and fidx[k] >= 4 and not groove[k] then c:put(x, y, RIND[fidx[k] - 2], ftok) end end)
-- cool reflected light: rim pixels facing lower-right
local rim = X.rim(fn)
fm:edge():each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and fidx[k] <= 3 then c:put(x, y, COOL, ftok) end end)
fm:each(function(x, y) local k = K(x, y)
  if not fm:has(x + 1, y + 1) and not fm:has(x + 1, y) and fn[k][1] > 0.4 and fn[k][2] > 0.3 then c:put(x, y, COOL, ftok) end end)
-- base: flat blossom scar (small dark star) at the bottom
for _, q in ipairs{ { 28, 53, 1 }, { 27, 53, 2 }, { 29, 53, 2 }, { 28, 52, 2 } } do c:put(q[1], q[2], RIND[q[3]], ftok) end
-- specular glint (2x1 + 1) on the upper-left shoulder
c:put(21, 30, "#f0f7c0", ftok) c:put(22, 30, "#f0f7c0", ftok) c:put(21, 31, RIND[6], ftok)

-- leaf: deeply lobed breadfruit leaf off the stalk tip, to the upper right
local lm, ln, LT, LS, len = A.lobedLeaf(33, 16, 45, 4, 57, 13, 6.2, 3.2, { deep = 0.7, fold = 0.42 })
local ltok = { r = { name = "leaf" } }
local lb = {}
local lidx = A.lit(c, lm, ln, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3, bias = lb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, t < 0.1 and STALK[4] or (s <= 0 and VEIN or LEAF[4]), ltok) return end
  -- a vein into each lobe, swept toward the tip
  local ph = t * 3.2 - abs(s) * 0.28
  local f = abs((ph - floor(ph)) - 0.0)
  if (f < 0.07 or f > 0.93) and abs(s) > 0.2 and abs(s) < 0.75 and t > 0.12 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- cool rim on the leaf's shade edge
lm:edge():each(function(x, y) local k = K(x, y) if LS[k] > 0.7 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, "#2f6a66", ltok) end end)

-- stalk on top: woody, ringed, pale cut end, AO onto leaf base
local stok = { r = { name = "stalk" } }
local sidx = A.lit(c, sm, sn, STALK, { tok = stok, amb = 0.12, wrap = 0.3, cuts = { 0.25, 0.45, 0.65, 0.85 } })
c:put(29, 23, STALK[2], stok) c:put(30, 23, STALK[1], stok)
-- broken stalk end: pale end grain
c:put(31, 16, STALK[5], stok) c:put(32, 16, STALK[4], stok) c:put(32, 15, STALK[5], stok)

-- quirk: milky latex bead running from the stalk scar down the rind
local L = { { 31, 25, 3 }, { 31, 26, 2 }, { 32, 27, 2 }, { 32, 28, 1 }, { 32, 29, 2 }, { 32, 30, 3 }, { 33, 30, 2 },
  { 32, 31, 2 }, { 33, 31, 1 } }
for _, q in ipairs(L) do c:put(q[1], q[2], LATEX[q[3]], ftok) end
c:put(33, 32, RIND[2], ftok) c:put(32, 32, RIND[2], ftok)

A.save(c, NAME)
