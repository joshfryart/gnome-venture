-- parsley (final, Opus). A slim sprig of flat-leaf parsley: three thin stems fanning out of a twine tie, each ending in
-- a trifoliate leaf of wedge-shaped, three-lobed, toothed leaflets (6-tone, V-fold light, midrib + lobe veins, AO where
-- leaflets overlap and where they meet the stem), plus one small side leaf. Stems are lit tubes with a pale ridge;
-- the cut ends show pale green end grain. Twine has a 2-tone twist and a loose tail.
-- quirk: a tiny striped swallowtail caterpillar is inching up the right stem.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "parsley"
local c = A.new(NAME)

local LEAF  = { "#163c34", "#1f5a3c", "#2c7a42", "#43994a", "#6cba50", "#a6d96a" }
local STEM  = { "#2f6a3e", "#4f9448", "#7cbc5a", "#b4de86" }
local TWINE = { "#6e4424", "#a86e34", "#d9a24c", "#f2cf7c" }
local ltok, stok, ttok = { r = { name = "leaf" } }, { r = { name = "stem" } }, { r = { name = "twine" } }

-- stems (cubic beziers from the tie up to each leaf)
local BX, BY = 31, 55
local stems = {
  { { BX - 1, BY }, { 29, 44 }, { 22, 34 }, { 17, 26 } },
  { { BX, BY },     { 31, 42 }, { 32, 30 }, { 32, 19 } },
  { { BX + 1, BY }, { 34, 44 }, { 41, 35 }, { 46, 27 } },
}
local stemM = HP.mask()
local stemData = {}
for i, p in ipairs(stems) do
  local m, n, T, S, samp = A.tube(p, function(t) return 1.25 - 0.35 * t end)
  stemM:add(m)
  stemData[i] = { m = m, n = n, T = T, S = S, samp = samp }
end

-- leaflet: wedge blade from (bx,by) along unit (ux,uy), length L, max half width W; three lobes + teeth at the tip
local function leaflet(bx, by, ux, uy, L, W)
  local cx, cy = bx + ux * L * 0.5 + uy * 0.6, by + uy * L * 0.5 - ux * 0.6
  local ex, ey = bx + ux * L, by + uy * L
  local m, n, T, S, len = A.blade(bx, by, cx, cy, ex, ey, function(t)
    if t > 0.99 then return -1 end
    if t < 0.72 then return max(0.5, W * (t / 0.72) ^ 0.7) end
    local q = (t - 0.72) / 0.28
    return max(0.6, W * sqrt(max(0, 1 - q * q * 0.85)))
  end, { fold = 0.45 })
  -- lobes: two notches near the tip; teeth along the outer edge
  local cut = {}
  m:each(function(x, y) local k = K(x, y) local t, s = T[k], S[k]
    if t > 0.74 and abs(abs(s) - 0.36) < 0.13 then cut[#cut + 1] = k end
    if t > 0.45 and abs(s) > 0.8 and floor(t * len + (s > 0 and 1 or 0)) % 3 == 0 then cut[#cut + 1] = k end
  end)
  for _, k in ipairs(cut) do m.s[k] = nil n[k] = nil end
  return m, n, T, S, len
end

local function paintLeaflet(m, n, T, S, len, bias)
  local idx = A.toneN(c, m, n, LEAF, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.37, 0.53, 0.69, 0.85 }, tok = ltok, bias = bias })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if bias and bias[k] then return end
    if abs(s) < 0.14 and t > 0.05 and t < 0.82 then
      c:put(x, y, s <= 0 and LEAF[min(6, (idx[k] or 3) + 2)] or LEAF[max(2, (idx[k] or 3) - 1)], ltok)
    elseif t > 0.5 and t < 0.86 and abs(abs(s) - 0.62) < 0.1 and (t * len) % 2 < 1.1 then
      c:put(x, y, s < 0 and LEAF[min(6, (idx[k] or 3) + 1)] or LEAF[max(1, (idx[k] or 3) - 1)], ltok)
    end
  end)
  return idx
end

-- a trifoliate leaf at (px,py) facing angle `a` (radians, 0 = up). side leaflets first, centre on top
local allLeaf = HP.mask()
local function trifoliate(px, py, a, L, W)
  local ux, uy = sin(a), -cos(a)
  local parts = {}
  for _, q in ipairs{ { -0.95, 0.82 }, { 0.95, 0.82 }, { 0, 1 } } do
    local vx, vy = A.rot(ux, uy, q[1])
    local m, n, T, S, len = leaflet(px + vx * 0.5, py + vy * 0.5, vx, vy, L * q[2], W * q[2])
    parts[#parts + 1] = { m = m, n = n, T = T, S = S, len = len }
  end
  -- AO: earlier leaflets darken under later ones
  for i, p in ipairs(parts) do
    local bias = {}
    for j = i + 1, #parts do p.m:cut(parts[j].m) X.ao(bias, p.m, parts[j].m, 1, -1) end
    p.bias = bias
  end
  for _, p in ipairs(parts) do paintLeaflet(p.m, p.n, p.T, p.S, p.len, p.bias) allLeaf:add(p.m) end
  -- dark base where leaflets join the petiole
  c:put(floor(px + .5), floor(py + .5), LEAF[1], ltok)
end

-- paint stems first (leaves overlap their tips)
local SB = {}
for i, d in ipairs(stemData) do
  local bias = {}
  -- AO where stems cross / bunch at the tie
  for j, e in ipairs(stemData) do if j ~= i then
    d.m:each(function(x, y) local k = K(x, y) if d.T[k] < 0.22 and e.m:has(x + (j > i and 1 or -1), y) then bias[k] = -1 end end)
  end end
  local idx = A.shade(c, d.m, d.n, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, bias = bias, tok = stok })
  -- pale ridge along the lit side
  d.m:each(function(x, y) local k = K(x, y) if d.S[k] < -0.35 and d.S[k] > -0.75 and d.T[k] > 0.25 and d.T[k] < 0.9 and (idx[k] or 1) >= 3 then c:put(x, y, STEM[4], stok) end end)
end
-- cut stem ends: pale end grain below the tie
for _, q in ipairs{ { 30, 56, 4 }, { 31, 56, 3 }, { 32, 56, 4 }, { 33, 56, 2 }, { 29, 56, 2 } } do c:put(q[1], q[2], STEM[q[3]], stok) end
c:put(31, 55, STEM[4], stok)

-- small side leaf on the centre stem
do
  local px, py = 33, 34
  local m, n, T, S, len = leaflet(px, py, 0.75, -0.66, 7, 2.6)
  paintLeaflet(m, n, T, S, len, nil)
  allLeaf:add(m)
end
trifoliate(17, 26, -0.75, 10, 3.3)
trifoliate(32, 19, 0.0, 10.5, 3.4)
trifoliate(46, 27, 0.8, 10, 3.3)

-- twine tie: 3 rows of twisted cord across the bunched stems + a loose tail to the left
for y = 47, 49 do for x = 28, 35 do
  local ph = (x + y) % 3
  local tone = (y == 47) and (ph == 0 and 2 or 4) or ((y == 49) and (ph == 0 and 1 or 2) or (ph == 0 and 1 or 3))
  if x == 35 and y > 47 then tone = max(1, tone - 1) end
  c:put(x, y, TWINE[tone], ttok)
end end
for i, p in ipairs{ { 27, 49 }, { 26, 50 }, { 25, 51 }, { 25, 52 }, { 24, 53 } } do c:put(p[1], p[2], i % 2 == 0 and TWINE[2] or TWINE[3], ttok) end
c:put(27, 48, TWINE[3], ttok)
-- AO on stems right under the tie
for x = 29, 34 do if stemM:has(x, 50) then c:put(x, 50, STEM[1], stok) end end

-- quirk: swallowtail caterpillar on the right stem (green body, ink bands with yellow dots), head up-right
local ctok = { r = { name = "caterpillar" } }
local map = {
  "......hk",
  "....gGgk",
  "..gKgy..",
  ".GgK....",
  "gyg.....",
}
local pal = { g = "#8fd06a", G = "#c8ec9a", K = "#2b1c26", y = "#f5c02e", h = "#e9f7c8", k = "#4f9448" }
A.map(c, map, 36, 37, pal, ctok)

-- one glint on the centre leaf
c:put(30, 12, "#e8f6b0", ltok)

A.save(c, NAME)
