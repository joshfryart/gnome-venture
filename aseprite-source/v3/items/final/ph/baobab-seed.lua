-- baobab-seed (aR3_3, final single pass). Three hard kidney-shaped baobab seeds (glossy dark red-brown coat, notch
-- on the inner curve, chalky crumbs of white fruit pulp still clinging = bloom, sharp specular, cool rim) on a torn
-- scrap of baobab leaflet: midrib + paired lateral veins, ragged torn end, slight cupped light, contact shadows. The
-- middle-left seed has cracked open: a pale curving shoot rises from it carrying a little five-fingered palmate leaf,
-- the baobab's own leaf shape.
-- quirk: a crumbly cube of chalky baobab pulp ("monkey bread") sits beside the seeds.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local G = dofile(DIR .. "/../_helpers/_aR3_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, max, min, abs, sqrt, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos, math.pi
local NAME = "baobab-seed"
local c = G.new2(NAME)

local LEAF = { "#1b4636", "#275f40", "#367d48", "#52994f", "#78b85a", "#a6d276" }
local RIB  = { "#4a6a34", "#6a8a42", "#8eaa54", "#b2c86c", "#d2e090", "#eaf0b8" }
local SEED = { "#1e1218", "#361c1e", "#552a24", "#76402c", "#9a5a38", "#c07e52" }
local CHALK = { "#a89c94", "#cfc4b6", "#ebe2d2", "#faf4e6" }
local SHOOT = { "#6a7a4a", "#a8b47a", "#dfe2b4" }
local SPRL = { "#1d4a3a", "#2a6644", "#3f8a4c", "#62aa52", "#8ec85e", "#c0e07e" }
local CUTS = { 0.2, 0.38, 0.55, 0.72, 0.88 }

-- leaf scrap: a broad leaflet lying on the diagonal, torn off at the lower-left
local m0, ln, LT, LS, LEN = G.blade(9, 52, 30, 44, 56, 26, function(t)
  return 9.2 * sin(pi * min(1, 0.32 + t * 0.7)) ^ 0.6 + 0.6
end, { fold = 0.34 })
G.tear(m0, 14, 48, -0.86, 0.5, 2.6, 5)
G.tear(m0, 15, 45, -0.95, -0.3, 2.2, 9)
-- seeds
local seeds = {
  { 24, 44, 4.4, 3.0, -0.5, 1 },      -- cracked, sprouting
  { 35, 42, 4.6, 3.1, 0.35, 2 },
  { 44, 34, 4.2, 2.9, -0.2, 3 },
}
local seedAll = HP.mask()
for _, s in ipairs(seeds) do
  local m, n = G.oval(s[1], s[2], s[3], s[4], s[5])
  -- kidney notch on the inner (upper) curve
  local nx, ny = -sin(s[5]), cos(s[5])
  m:cut(c:ellipse(s[1] - nx * (s[4] + 1.4), s[2] - ny * (s[4] + 1.4), 1.6, 1.6))
  s.m, s.n = m, n
  seedAll:add(m)
end
-- pulp cube (quirk) position
local CUBE = { 29, 48 }
local cubeM = c:rect(CUBE[1], CUBE[2], CUBE[1] + 5, CUBE[2] + 4)

-- leaf tone
local lb = {}
X.ao(lb, m0, seedAll, 1, -1) G.cast(lb, m0, seedAll, 1, 2, -1) G.cast(lb, m0, seedAll, 2, 2, -1)
X.ao(lb, m0, cubeM, 1, -1) G.cast(lb, m0, cubeM, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, m0, ln, LEAF, { tok = ltok, bias = lb, amb = 0.1, wrap = 0.25, cuts = { 0.24, 0.4, 0.56, 0.72, 0.88 } })
-- midrib + paired lateral veins sweeping toward the tip
m0:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  if lb[k] then return end
  if abs(s) < 0.1 then c:put(x, y, RIB[s < 0 and 5 or 3], ltok) return end
  if s > 0.1 and s < 0.2 then c:put(x, y, LEAF[max(1, (lidx[k] or 3) - 1)], ltok) return end
  for _, vt in ipairs{ 0.14, 0.3, 0.46, 0.62, 0.78 } do
    local d = t * LEN - (vt * LEN + abs(s) * 6.5)
    if d > -0.5 and d < 0.5 and abs(s) > 0.12 and abs(s) < 0.8 then
      c:put(x, y, s < 0 and RIB[3] or LEAF[min(6, (lidx[k] or 3) + 1)], ltok)
    end
  end
end)
-- pale torn edge (exposed tissue) on the ragged lower-left
m0:edge():each(function(x, y) local k = K(x, y) if LT[k] and LT[k] < 0.2 then c:put(x, y, RIB[4], ltok) end end)

-- sprout: shoot from the cracked seed curving up, palmate leaf on top
local stok = { r = { name = "shoot" } }
local sp = { { 23, 42 }, { 18, 35 }, { 27, 29 }, { 23, 22 } }
for i = 0, 40 do local x, y = G.bez(sp, i / 40) x, y = floor(x + .5), floor(y + .5)
  c:put(x, y, SHOOT[2], stok) c:put(x + 1, y, SHOOT[1], stok) end
for i = 6, 30, 4 do local x, y = G.bez(sp, i / 40) c:put(floor(x + .5), floor(y + .5), SHOOT[3], stok) end
-- palmate leaf: five leaflets from one point
local PX, PY = 23, 21
local pm = HP.mask()
local fingers = {}
for j = 0, 4 do
  local a = -pi / 2 + (j - 2) * 0.68 + 0.08
  local L = (j == 2) and 8.0 or ((j == 1 or j == 3) and 7.0 or 5.4)
  local ux, uy = cos(a), sin(a)
  local fm = G.rell(PX + ux * L * 0.56, PY + uy * L * 0.56, ux, uy, L * 0.5, 1.6)
  pm:add(fm) fingers[#fingers + 1] = { fm, ux, uy, L }
end
local pn = X.pillow(pm, 1.4)
local pb = {}
for j = 2, #fingers do X.ao(pb, fingers[j][1], fingers[j - 1][1], 1, -1) end
local ptok = { r = { name = "sprout-leaf" } }
G.toneN(c, pm, pn, SPRL, { tok = ptok, cuts = CUTS, bias = pb, amb = 0.15, wrap = 0.3 })
for _, f in ipairs(fingers) do for d = 1, floor(f[4] * 0.8) do
  local x, y = floor(PX + f[2] * d + 0.5), floor(PY + f[3] * d + 0.5)
  if pm:has(x, y) then c:put(x, y, d <= 1 and SPRL[2] or SPRL[5], ptok) end end end
c:put(PX, PY, SPRL[1], ptok)

-- seeds: glossy coat, chalky pulp crumbs, notch, specular, cool rim
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 1 then X.ao(sb, s.m, c:rect(20, 30, 26, 41), 1, -1) end
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, amb = 0.05, wrap = 0.15, cuts = { 0.22, 0.4, 0.56, 0.7, 0.84 }, bias = sb })
  -- chalky bloom crumbs
  s.m:each(function(x, y) local h = X.hash(x, y, i * 7)
    if h > 0.92 then c:put(x, y, (idx[K(x, y)] or 3) >= 4 and CHALK[3] or CHALK[2], tok)
    elseif h > 0.89 and X.hash(x + 1, y, i * 7) > 0.5 then c:put(x, y, CHALK[1], tok) end end)
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if rim[K(x, y)] > 0.72 then c:put(x, y, "#6a5a7e", tok) end end)
  local bx, by = G.specAt(s.m, s.n, 40)
  c:put(bx, by, "#fff0e0", tok) c:put(bx + 1, by, SEED[6], tok)
end
-- the crack on seed 1 where the shoot leaves (dark split + pale inner edge)
c:put(22, 42, SEED[1]) c:put(24, 42, SEED[1]) c:put(21, 43, SEED[1]) c:put(25, 43, SEED[1])
c:put(23, 42, SHOOT[1], stok) c:put(23, 43, SHOOT[2], stok)

-- quirk: chalky pulp cube, top face lit, right face shaded, crumbly corners
local qtok = { r = { name = "pulp" } }
local cube = {
  ".TTTT.",
  "TttttF",
  "FFFFFf",
  "FFfFFf",
  ".FFFf.",
}
G.map(c, CUBE[1], CUBE[2], cube, { T = CHALK[4], t = CHALK[3], F = CHALK[2], f = CHALK[1] }, qtok)
c:put(CUBE[1] + 2, CUBE[2] + 3, CHALK[1], qtok) c:put(CUBE[1] + 6, CUBE[2] + 4, CHALK[2], qtok)
G.save2(c, NAME)
