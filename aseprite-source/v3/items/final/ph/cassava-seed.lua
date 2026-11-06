-- cassava-seed (final, Opus single pass). Three small mottled cassava seeds (grey-brown oval coats with dark
-- tortoiseshell blotches, a pale caruncle nub at one end, specular, AO + contact shadow) on a torn scrap of palmate
-- cassava leaf: two slender lobes fanning from a ragged base, each with a pale midrib and fine veins, cool reflected
-- edge. The middle seed has sprouted: a red cassava petiole-stem, two oval cotyledons and a first palmate leaf of
-- five narrow lobes.
-- quirk: one seed has rolled out to the very tip of a lobe and sits half over the edge.
local NAME = "cassava-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_5.lua")
local HP, X, K, G = A.HP, A.X, A.K, A
local floor, max, min, abs, sin, cos, pi = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local SCR = { "#1a3c3a", "#245446", "#336e4a", "#4c8c50", "#70ac5c", "#a4cc7a" }
local SEED = { "#2a2026", "#463836", "#665448", "#8a7864", "#b0a088", "#d8ccb2" }
local RED = { "#5a1a34", "#8e2a3c", "#c04448", "#e87a6a" }
local CAR = { "#c8a870", "#f0dca4" }
local COOL = "#3a6c72"
local ltok = { r = { name = "leaf" } }

-- seeds (cx, cy, rx, ry, ang)
local seeds = { { 25, 50, 3.6, 2.4, 0.15 }, { 36, 42, 3.5, 2.3, -0.35 }, { 55, 47, 3.4, 2.3, 0.5 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.85) end

-- leaf scrap: two narrow palmate lobes from a torn base
local lobes = {
  { 11, 55, 32, 57, 57, 47, 4.8 },
  { 11, 54, 26, 46, 47, 37, 4.3 },
}
local scrap = HP.mask()
local parts = {}
for i, L in ipairs(lobes) do
  local m, n, T, S, len = G.blade(L[1], L[2], L[3], L[4], L[5], L[6], function(t)
    if t > 0.985 then return -1 end
    return max(0.5, L[7] * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.8)
  end, { fold = 0.42 })
  -- ragged torn base
  local cut = {}
  m:each(function(x, y) local k = K(x, y) if T[k] < 0.07 + 0.05 * abs(sin(S[k] * 8)) then cut[#cut + 1] = k end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  parts[i] = { m = m, n = n, T = T, S = S, len = len }
end
parts[1].m:cut(parts[2].m)  -- upper lobe overlaps the lower one
for i = #parts, 1, -1 do
  local p = parts[i]
  local bias = {}
  for _, s in ipairs(seeds) do X.ao(bias, p.m, s.m, 1, -1) G.cast(bias, p.m, s.m, 1, 2, -1) end
  if i == 1 then X.ao(bias, p.m, parts[2].m, 1, -1) end
  local tok = { r = { name = "lobe" .. i } }
  G.toneN(c, p.m, p.n, SCR, { bias = bias, tok = tok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
  p.m:each(function(x, y) local k = K(x, y) local s, t = p.S[k], p.T[k]
    if bias[k] then return end
    if abs(s) < 0.13 and t < 0.94 then c:put(x, y, s <= 0 and "#d4e6a0" or SCR[3], tok) return end
    local d = (t * p.len - abs(s) * 5) % 4.2
    if d < 0.8 and abs(s) > 0.2 and abs(s) < 0.78 and t < 0.88 then c:put(x, y, s < 0 and SCR[6] or SCR[2], tok) end
  end)
  p.m:edge():each(function(x, y) local k = K(x, y)
    if not bias[k] and p.S[k] > 0.62 and p.T[k] > 0.15 then c:put(x, y, COOL, tok) end
    if p.T[k] < 0.15 then c:put(x, y, "#c8d89a", tok) end
  end)
  scrap:add(p.m)
end

-- sprout from the middle seed: red stem, cotyledons, palmate true leaf
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 36, 41 }, { 35, 35 }, { 37, 29 }, { 36, 22 } }, function(t) return 1.05 end, RED, { tok = stok })
local function cot(cx, cy, ang)
  local m, n = G.oval(cx, cy, 3.3, 1.7, ang, 0.7)
  m:cut(sm)
  local tok = { r = { name = "cot" } }
  G.toneN(c, m, n, LEAF, { tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  return m
end
local c1 = cot(31.5, 32, 0.35)
local c2 = cot(40.5, 31, -0.35)
-- palmate leaf: five narrow lobes from the top of the stem
local px, py = 36, 21
local pm = HP.mask()
local ltk = { r = { name = "palm" } }
for _, q in ipairs{ { -90, 9.5 }, { -52, 8 }, { -128, 8 }, { -14, 5.5 }, { -166, 5.5 } } do
  local a = q[1] * pi / 180
  local bx, by = px + cos(a) * q[2], py + sin(a) * q[2]
  local mx, my = px + cos(a) * q[2] * 0.5, py + sin(a) * q[2] * 0.5
  local m, n, T, S = G.blade(px, py, mx, my, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.3, 1.6 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.8)
  end, { fold = 0.5 })
  m:cut(pm)
  local idx = G.toneN(c, m, n, LEAF, { tok = ltk, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  if q[2] > 7 then m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.2 and T[k] > 0.15 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltk) end end) end
  pm:add(m)
end
c:put(px, py, RED[2], stok) c:put(px, py + 1, RED[3], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.1, wrap = 0.25 })
  -- mottling: dark tortoiseshell blotches
  s.m:each(function(x, y) local k = K(x, y)
    local h = X.hash(floor((x + i) / 2), floor((y + 2 * i) / 2), 13)
    if h < 0.32 and idx[k] > 2 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok) end
  end)
  -- caruncle nub at the leading end
  local ca, sa = cos(s[5]), sin(s[5])
  local ex, ey = floor(s[1] + ca * (s[3] + 0.6) + .5), floor(s[2] + sa * (s[3] + 0.6) + .5)
  c:put(ex, ey, CAR[1], tok) c:put(ex, ey - 1, CAR[2], tok)
  local bx, by = G.specAt(s.m, s.n, 40) c:put(bx, by, A.CREAM, tok)
end
-- sprout foot over seed 2
c:put(36, 40, RED[3], stok) c:put(36, 39, RED[3], stok)

A.save(c, NAME)
