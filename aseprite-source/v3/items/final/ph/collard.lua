-- collard (Opus single pass). One long blue-green collard leaf on the diagonal, V-folded along a thick pale midrib,
-- paired veins sweeping to a gently ruffled margin (ruffle drawn as light/dark waves along the edge), waxy cool
-- bloom on the lit half, cool reflected rim on the shade edge, pale ribbed stalk with a fresh-cut end.
-- quirk: one round dewdrop beaded on the waxy leaf (collards shed water), casting its own little shadow.
local NAME = "collard"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#11283a", "#1b4248", "#285e58", "#3b7d69", "#5d9f82", "#9cc8b0" }
local BLOOM, COOL = "#c3e2d2", "#3d7286"
local RIB = { "#5f8d6e", "#8dba92", "#bcdcb4", "#e2f2d2" }
local STK = { "#2f5644", "#4d7f5c", "#79a77a", "#a7cc9a", "#d2e8bc", "#eef6dc" }
local DROP = { "#2a5f86", "#4f97bf", "#8fd0e4", "#d8f4f4" }

-- stalk first (leaf base overlaps it)
local stok = { r = { name = "stalk" } }
local sp = { { 10, 57 }, { 13, 53 }, { 16, 49 }, { 20, 44 } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.75 - 0.35 * t end)
X.tone(c, sm, X.light(sn, { amb = 0.12, wrap = 0.3 }), STK, { cuts = { 0.22, 0.4, 0.57, 0.74, 0.9 }, tok = stok })
-- ribs along the stalk (1 px groove on the lit side)
sm:each(function(x, y) local k = K(x, y) if SS[k] > -0.45 and SS[k] < -0.1 and ST[k] > 0.08 then c:put(x, y, STK[4], stok) end end)
-- fresh-cut end: pale disc with a darker ring
for _, p in ipairs{ { 9, 57, 6 }, { 10, 58, 5 }, { 9, 58, 4 }, { 8, 57, 4 }, { 10, 57, 5 } } do c:put(p[1], p[2], STK[p[3]], stok) end

-- leaf blade
local AX, AY, CX, CY, BX, BY = 19, 45, 25, 22, 51, 10
local ux, uy = BX - AX, BY - AY local ul = sqrt(ux * ux + uy * uy) ux, uy = ux / ul, uy / ul
local W = 11.6
local lm, ln, LT, LS, len = G.blade(AX, AY, CX, CY, BX, BY, function(t)
  if t > 0.985 then return -1 end
  local u = 0.06 + t * 0.93
  local base = W * sin(pi * u) ^ 0.62
  local ruff = 1 + 0.085 * sin(t * 47) * min(1, t * 4)
  return max(0.6, base * ruff)
end, { fold = 0.28 })
-- ruffle: tilt normals along the leaf axis in waves near the margin
for k, nn in pairs(ln) do
  local s, t = LS[k], LT[k]
  local e = max(0, (abs(s) - 0.42) / 0.55)
  if e > 0 then
    local w = sin(t * len / 2.3) * 0.75 * e
    local nx, ny, nz = nn[1] + ux * w, nn[2] + uy * w, nn[3]
    ln[k] = { G.norm(nx, ny, nz) }
  end
end
local bias = {}
X.ao(bias, lm, sm, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.4, 0.58, 0.76, 0.92 }, amb = 0.1, wrap = 0.3 })

-- veins: paired, swept toward the tip, lighter on the lit half, faint on the shade half
local PER = 5.6
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local a = abs(s)
  local ph = (t * len - a * 6.5) / PER + (s > 0 and 0.35 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and a > 0.13 and a < 0.8 - 0.25 * t and t > 0.05 and t < 0.9 then
    local i = lidx[k] or 3
    c:put(x, y, s < 0 and (i >= 5 and RIB[4] or RIB[3]) or LEAF[min(6, i + 1)], ltok)
  end
end)
-- midrib: thick pale, lit edge, dark shade edge (tapers to the tip)
lm:each(function(x, y) local k = K(x, y)
  local s, t = LS[k], LT[k]
  local wr = 0.16 * (1 - t) + 0.03
  if t < 0.94 and abs(s) < wr then
    local i = s < -wr * 0.35 and 4 or (s < wr * 0.35 and 3 or 2)
    if t > 0.7 and i == 4 then i = 3 end
    c:put(x, y, RIB[i], ltok)
  elseif t < 0.94 and s >= wr and s < wr + 0.06 then
    c:put(x, y, LEAF[2], ltok)
  end
end)
-- waxy bloom: pale cool patches on the brightest lit facets (between veins)
lm:each(function(x, y) local k = K(x, y)
  if lidx[k] == 6 and LS[k] < -0.3 and X.hash(x // 2, y // 2, 3) > 0.72 then c:put(x, y, BLOOM, ltok) end
end)
-- cool reflected light on the shade-side margin
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.9 and (lidx[k] or 1) <= 2 then c:put(x, y, COOL, ltok) end end)

-- quirk: a dewdrop beaded on the lit half
local dtok = { r = { name = "drop" } }
local DXc, DYc = 24.5, 24.5
local dm = c:ellipse(DXc, DYc, 1.6, 1.4)
-- drop shadow on the leaf (lower right)
dm:shift(1, 1):add(dm:shift(2, 1)):each(function(x, y) if lm:has(x, y) and not dm:has(x, y) then c:put(x, y, LEAF[2], ltok) end end)
dm:each(function(x, y)
  local u, v = x - DXc, y - DYc
  local i = (u + v < -1.2) and 2 or (u + v > 1.2) and 4 or 3
  c:put(x, y, DROP[i], dtok)
end)
local dx0, dy0 = dm:bbox()
c:put(dx0 + 1, dy0, "#fff4d6", dtok)
c:put(dx0 + 2, dy0 + 3, DROP[1], dtok)

-- one specular glint on the leaf shoulder
c:put(19, 35, "#fff4d6", ltok)

G.save2(c, NAME)
