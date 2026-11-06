-- egusi-soup (final pass, Opus single pass). A low terracotta serving bowl in 3/4 view on a short foot ring, filled
-- with golden curdled egusi: clumpy ground-melon-seed lumps, torn bitter-leaf greens, beads of red palm oil and one
-- browned chunk of meat.
-- Material: per-pixel ellipsoid light on the clay (6 tones, cool-violet shade), pillow-lit lip with a bright rim edge,
-- dark inner back wall, AO under the lip and where the foot meets the belly, a painted ochre zigzag band that follows
-- the curve, clumped soup lumps (lit top-left, shadow bottom-right), glossy oil beads with a bright pip, ground shadow.
-- quirk: one escaped egusi seed sits on the back of the rim.
local NAME = "egusi-soup"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB2r0_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min = math.floor, math.abs, math.sqrt, math.max, math.min
local c = A.new(NAME)

local CLAY = { "#4a1d26", "#7a2f2c", "#a8462e", "#c9653a", "#e08c56", "#f6b980" }
local SOUP = { "#7a3d1a", "#b0601e", "#d68a26", "#eeb03a", "#f8d266", "#fff0b4" }
local LEAF = { "#1d4a34", "#2f6e3e", "#4f9a48", "#86c45a" }
local OIL  = { "#a8281e", "#e2502a", "#ff9a5a" }
local MEAT = { "#3e2020", "#6a3626", "#94573a", "#c08458" }
local BAND = { "#7a4a2a", "#b98444", "#e6bf6e", "#f8e2a0" }
local SEED = { "#9a8460", "#d8c79c", "#f7eed2" }
local tokC, tokS = { r = { name = "clay" } }, { r = { name = "soup" } }

local CX, RY0 = 32, 27
c:groundShadow(CX, 47, 15, 2)

-- foot ring (behind the belly)
local foot = c:rect(25, 42, 39, 46)
local fn = {}
foot:each(function(x, y) local t = max(-.95, min(.95, (x - 32) / 7.5)) fn[K(x, y)] = { t, 0.15, sqrt(1 - t * t) } end)
local fb = {}
foot:each(function(x, y) if y <= 43 then fb[K(x, y)] = -2 end end)
A.shade(c, foot, fn, CLAY, { bias = fb, tok = tokC })
for x = 26, 38 do c:put(x, 46, CLAY[1], tokC) end                       -- dark foot base row

-- belly: lower half of an ellipsoid
local belly, bn = A.oval(CX, RY0, 21, 17, 0)
belly:cut(c:rect(0, 0, 63, RY0 - 1))
belly:cut(c:rect(0, 45, 63, 63))
local rimO = c:ellipse(CX, RY0, 21, 6)
local bb = {}
X.ao(bb, belly, rimO, 2, -1)
local bidx = A.shade(c, belly, bn, CLAY, { bias = bb, tok = tokC, amb = 0.05, wrap = 0.2 })
-- painted zigzag band following the curve, groove line above it
belly:each(function(x, y) if not rimO:has(x, y) then
  local dx = x - CX
  local q = 1 - (dx / 20.5) ^ 2
  if q > 0 then
    local yb = RY0 + 5 + 5.6 * sqrt(q)
    local tri = ({ 0, 1, 2, 1 })[(x % 4) + 1]
    local i = bidx[K(x, y)] or 3
    if floor(yb + tri - 1 + .5) == y then c:put(x, y, BAND[max(1, min(4, i - 2))], tokC) end
    if floor(yb - 2.4 + .5) == y and abs(dx) < 19 then c:put(x, y, CLAY[max(1, i - 1)], tokC) end
    if floor(yb + 2.6 + .5) == y and abs(dx) < 19 then c:put(x, y, CLAY[max(1, i - 1)], tokC) end
  end
end end)
-- cool reflected light lower-right on the belly
local rim = X.rim(bn)
belly:edge():each(function(x, y) if y > 33 and rim[K(x, y)] and rim[K(x, y)] > 0.6 and x > CX + 4 then c:put(x, y, "#8a4a6e", tokC) end end)

-- rim lip + opening
local open = c:ellipse(CX, RY0 + 0.4, 18, 4.2)
local lip = rimO:copy():cut(open)
local ln = X.pillow(lip, 1.6)
local lidx = A.shade(c, lip, ln, CLAY, { tok = tokC, amb = 0.25, wrap = 0.35, bias = {} })
lip:each(function(x, y)                                                  -- bright top edge of the front lip
  if y > RY0 and not lip:has(x, y - 1) then c:put(x, y, CLAY[6], tokC) end end)
c:put(17, 30, "#fff1d8", tokC) c:put(18, 31, CLAY[6], tokC)                -- glaze specular on the lip
-- inner back wall
open:each(function(x, y) c:put(x, y, (y <= RY0 - 3) and CLAY[2] or CLAY[1], tokC) end)

-- soup surface
local soup = c:ellipse(CX, RY0 + 1.2, 17.4, 3.4):clip(open)
local sn = X.pillow(soup, 2.2)
local sb = {}
soup:each(function(x, y) if not soup:has(x, y - 1) then sb[K(x, y)] = -1 end end)   -- meniscus shadow under back wall
local sidx = A.shade(c, soup, sn, SOUP, { tok = tokS, bias = sb, amb = 0.2, wrap = 0.3, cuts = { 0.25, 0.45, 0.62, 0.8, 0.95 } })
-- curdled lumps (seeded jitter grid)
for gy = 0, 3 do for gx = 0, 12 do
  local x = floor(16 + gx * 2.7 + (gy % 2) * 1.3 + X.hash(gx, gy, 3) * 1.4)
  local y = floor(25 + gy * 1.7 + X.hash(gx, gy, 7) * 1.2)
  if soup:has(x, y) and soup:has(x + 1, y + 1) and X.hash(gx, gy, 11) > 0.25 then
    local i = sidx[K(x, y)] or 4
    c:put(x, y, SOUP[min(6, i + 2)], tokS)
    c:put(x + 1, y, SOUP[min(6, i + 1)], tokS)
    c:put(x + 1, y + 1, SOUP[max(1, i - 1)], tokS)
    if soup:has(x, y + 1) then c:put(x, y + 1, SOUP[i], tokS) end
  end
end end
-- bitter-leaf greens (torn pieces)
for _, p in ipairs{ { 19, 27 }, { 27, 29 }, { 40, 26 }, { 45, 29 }, { 33, 25 } } do
  local x, y = p[1], p[2]
  c:put(x, y, LEAF[4], tokS) c:put(x + 1, y, LEAF[3], tokS) c:put(x + 2, y, LEAF[2], tokS)
  c:put(x + 1, y + 1, LEAF[1], tokS)
end
-- palm-oil beads
for _, p in ipairs{ { 23, 28 }, { 37, 29 }, { 30, 26 }, { 43, 27 } } do
  c:put(p[1], p[2], OIL[3], tokS) c:put(p[1] + 1, p[2], OIL[2], tokS) c:put(p[1] + 1, p[2] + 1, OIL[1], tokS)
end
-- browned meat chunk
A.map(c, { ".abb.", "abccd", "bccdd", ".dd.." }, 34, 26, { a = MEAT[4], b = MEAT[3], c = MEAT[2], d = MEAT[1] }, tokS)

-- quirk: a single escaped egusi seed on the back of the rim (pokes above the silhouette)
A.map(c, { ".hb.", "hbbd", ".dd." }, 44, 19, { h = SEED[3], b = SEED[2], d = SEED[1] }, tokC)
A.save(c, NAME)
