-- oregano (final, Opus single pass aC31_3). One slim cut sprig: a wiry red-violet stem (woody, paler cut end) that
-- forks once, opposite pairs of small ovate grey-green leaves (V-fold light, midrib, a pale fuzz fringe on the lit
-- edge, AO where they tuck under the stem), and two rounded flower heads of overlapping mauve bracts with tiny pink
-- florets peeping out.
-- quirk: one lower leaf has a round caterpillar nibble taken out of its edge.
local NAME = "oregano"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC31_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new(NAME)

local LEAF = { "#1e3a31", "#2e573d", "#467747", "#64964f", "#8db567", "#bad58e" }
local FUZZ, VEIN = "#d8e8b4", "#c4dc98"
local STEM = { "#3a1f30", "#57293c", "#77394a", "#97535a", "#b97670", "#d9a08a" }
local BRACT = { "#4b224e", "#712f69", "#984a86", "#bd6ca2", "#dc96bf", "#f4c6dc" }
local FLO = { "#e58ab0", "#ffd0e2" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- stems (cubic beziers): main and a side branch
local main = { { 29, 57 }, { 27, 45 }, { 33, 31 }, { 31, 18 } }
local bx0, by0 = G.bez(main, 0.42)
local side = { { bx0, by0 }, { bx0 + 4, by0 - 5 }, { 44, by0 - 9 }, { 46, 23 } }
local function stemW(t) return 1.45 - 0.6 * t end
local sm, sn, ST, SS = G.tube(main, stemW)
local bm, bn, BT, BS = G.tube(side, function(t) return 1.0 - 0.3 * t end)

-- leaves: { stem, t, side(+1 right/-1 left), length, width, angle bias }
local leafSpec = {
  { main, 0.16, -1, 10.0, 3.4, 0.2 }, { main, 0.16, 1, 9.5, 3.3, 0.15 },
  { main, 0.33, -1, 9.0, 3.2, 0.3 },  { main, 0.33, 1, 7.5, 2.9, 0.4 },
  { main, 0.57, -1, 7.5, 2.9, 0.35 }, { main, 0.57, 1, 6.0, 2.5, 0.5 },
  { main, 0.78, -1, 5.5, 2.3, 0.5 },  { main, 0.78, 1, 5.0, 2.1, 0.55 },
  { side, 0.5, -1, 5.5, 2.3, 0.6 },   { side, 0.5, 1, 6.5, 2.6, 0.35 },
}
local allLeaf = HP.mask()
local leaves = {}
for i, L in ipairs(leafSpec) do
  local p, t, sd, ln, w, ab = L[1], L[2], L[3], L[4], L[5], L[6]
  local x, y = G.bez(p, t)
  local x2, y2 = G.bez(p, min(1, t + 0.02))
  local tx, ty = x2 - x, y2 - y local tl = sqrt(tx*tx + ty*ty) tx, ty = tx / tl, ty / tl
  -- perpendicular, then tilt toward the stem tip (leaves point upward)
  local px, py = -ty * sd, tx * sd
  if sd < 0 then px, py = ty, -tx end
  local ux, uy = px * (1 - ab) + tx * ab, py * (1 - ab) + ty * ab
  local ul = sqrt(ux*ux + uy*uy) ux, uy = ux / ul, uy / ul
  local ex, ey = x + ux * ln, y + uy * ln
  -- slight droop: control point bowed downward
  local cx, cy = x + ux * ln * 0.5, y + uy * ln * 0.5 + 0.8
  local m, n, T, S = G.blade(x + ux * 0.8, y + uy * 0.8, cx, cy, ex, ey, function(tt)
    if tt > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, tt * 0.82 + 0.12)) ^ 0.62)
  end, { fold = 0.3 })
  leaves[i] = { m = m, n = n, T = T, S = S, x = ex, y = ey }
end
-- quirk nibble on the lower-left leaf: a round bite out of its outer edge
do local L = leaves[1] local nb = HP.ellipse(L.x + 2.2, L.y + 1.6, 2.2, 2.0)
  L.m:cut(nb)
end
-- draw order: back leaves (right side) first, then left; stems over leaf bases
local ltok = { r = { name = "leaf" } }
for i, L in ipairs(leaves) do
  local m = L.m:copy():cut(sm):cut(bm)
  for j = 1, i - 1 do m:cut(leaves[j].m) end
  L.vis = m
  local bias = {}
  X.ao(bias, m, sm, 1, -1) X.ao(bias, m, bm, 1, -1)
  G.cast(bias, m, sm, 1, 1, -1)
  G.toneN(c, m, L.n, LEAF, { bias = bias, tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    local s, t = L.S[k], L.T[k]
    if abs(s) < 0.16 and t > 0.12 and t < 0.8 and not bias[k] then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) end
  end)
  -- fuzz: pale hairs on the lit (S<0) edge every other pixel
  m:edge():each(function(x, y) local k = K(x, y)
    if L.S[k] and L.S[k] < -0.5 and L.T[k] > 0.25 and L.T[k] < 0.85 and (x + y) % 2 == 0 then c:put(x, y, FUZZ, ltok) end
  end)
  allLeaf:add(m)
end

-- stems over the leaves
local stok = { r = { name = "stem" } }
local bvis = bm:copy():cut(sm)
local sb = {}
X.ao(sb, bvis, sm, 1, -1)
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
G.toneN(c, bvis, bn, STEM, { tok = stok, bias = sb, cuts = { 0.18, 0.34, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
-- leaf nodes: a dark ring where each pair joins the stem
for _, t in ipairs{ 0.16, 0.33, 0.57, 0.78 } do
  local x, y = G.bez(main, t) c:put(floor(x + 0.5) + 1, floor(y + 0.5) + 1, STEM[2], stok)
end
-- woody cut end: pale end grain at the base
for _, q in ipairs{ { 28, 57, 6 }, { 29, 57, 5 }, { 30, 57, 4 }, { 28, 58, 5 }, { 29, 58, 4 } } do
  if sm:has(q[1], q[2]) then c:put(q[1], q[2], STEM[q[3]], stok) end
end

-- flower heads: clustered bracts (ovals) with florets
local btok = { r = { name = "bract" } }
local function head(hx, hy, sc)
  local parts = {
    { 0, -3.2, 2.0, 1.6, 0.0 }, { -2.2, -1.2, 2.0, 1.5, 0.5 }, { 2.2, -1.0, 2.0, 1.5, -0.5 },
    { 0, 0.6, 2.2, 1.6, 0.0 }, { -1.4, 2.4, 1.8, 1.3, 0.4 }, { 1.6, 2.6, 1.8, 1.3, -0.4 },
  }
  local hm = HP.mask()
  local ps = {}
  for i, q in ipairs(parts) do
    local m, n = G.oval(hx + q[1] * sc, hy + q[2] * sc, q[3] * sc, q[4] * sc, q[5], 0.9)
    ps[i] = { m = m, n = n }
  end
  -- lower bracts in front (overlapping scales); paint top first
  for i, q in ipairs(ps) do
    local vis = q.m:copy()
    local bias = {}
    for j = i + 1, #ps do vis:cut(ps[j].m) end
    for j = i + 1, #ps do X.ao(bias, vis, ps[j].m, 1, -1) end
    G.toneN(c, vis, q.n, BRACT, { tok = btok, bias = bias, cuts = CUTS, amb = 0.12, wrap = 0.3 })
    hm:add(q.m)
  end
  return hm
end
local tx, ty = G.bez(main, 1)
local h1 = head(tx, ty - 3, 0.95)
local sx, sy = G.bez(side, 1)
local h2 = head(sx + 0.5, sy - 2.5, 0.8)
-- florets: tiny pink two-tone dots peeking from the bracts
for _, q in ipairs{ { tx - 2, ty - 7 }, { tx + 2, ty - 5 }, { tx - 3, ty - 2 }, { sx + 2, sy - 5 }, { sx - 1, sy - 6 } } do
  local x, y = floor(q[1] + 0.5), floor(q[2] + 0.5)
  c:put(x, y, FLO[1], btok) c:put(x, y - 1, FLO[2], btok)
end
-- specular glint on the main head's top bract
c:put(floor(tx - 1), floor(ty - 7), "#fff4d6", btok)

G.save(c, NAME)
