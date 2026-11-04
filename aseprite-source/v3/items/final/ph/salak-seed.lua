-- salak-seed (final, artist D14_0). Two big glossy chestnut salak stones (cream hilum scar with a dark eye, pale pulp fibres,
-- one shallow flat facet) lie on a torn strip of a long sword-shaped palm leaflet: dark glossy green, pleated lengthwise
-- with lit ridges and dark valleys, ripped zigzag at the base, cool bounce on the lower edge.
-- The right stone has germinated: a pale cream sheath carries a tall, pleated, spear-shaped first leaf (and a smaller
-- second spear) that shows the palm leaf shape.
-- quirk: the pale sheath is already armed with three baby thorns.
local NAME = "salak-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#10302b", "#1a4934", "#2a683d", "#3e8946", "#5fab54", "#92cc6e" }
local SP   = { "#1f5a38", "#2f7a42", "#4a9a4c", "#70ba5a", "#9ad66c", "#cdf0a0" }
local SH   = { "#5b7a44", "#8fb064", "#c4de88", "#eef6b8" }
local SEED = { "#2a1410", "#4a2418", "#6e3a20", "#935630", "#bc7a40", "#e2a868" }
local HIL  = { "#5a3a2c", "#a07c52", "#d2b282", "#f2e0b0" }

-- leaflet scrap -----------------------------------------------------------------------------
local lm, ln, LT, LS, len = G.blade(7, 52, 29, 58, 57, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.8 * sin(pi * min(1, t * 0.97 + 0.03)) ^ 0.5)
end, { fold = 0.3 })
-- torn zigzag at the base
local tear = { {7,48},{8,49},{7,50},{8,51},{7,52},{8,53},{9,54},{8,55},{9,56},{8,50},{9,52},{9,51},{10,56},{10,55} }
for _, q in ipairs(tear) do lm.s[K(q[1], q[2])] = nil end
-- seeds (positions set now for AO)
local seeds = { { 17.5, 50, 5.3, 3.9, -0.22 }, { 34, 46.2, 5.4, 4.0, -0.3 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaflet" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- lengthwise pleats: dark valley, lit ridge beside it
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t = LS[k], LT[k]
  if t < 0.04 or t > 0.95 then return end
  if abs(s) < 0.13 then c:put(x, y, s <= 0 and "#b2e07e" or LEAF[3], ltok) return end
  local q = s * 3.0
  local f = q - floor(q + 0.5)
  if abs(f) < 0.17 and abs(s) < 0.86 then c:put(x, y, LEAF[2], ltok)
  elseif f > 0.17 and f < 0.4 and abs(s) < 0.86 and s < 0.1 then c:put(x, y, LEAF[5], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.06 and LT[k] < 0.9 then c:put(x, y, "#3a6e6a", ltok) end end)

-- sprout --------------------------------------------------------------------------------------
local stok = { r = { name = "sheath" } }
local sptok = { r = { name = "spear" } }
local function spear(ax, ay, cx, cy, bx, by, w, R)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t ^ 0.72 * 0.99 + 0.02)) ^ 0.85)
  end, { fold = 0.42 })
  G.toneN(c, m, n, R, { tok = sptok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if t > 0.97 then return end
    if abs(s) < 0.14 and t > 0.04 and t < 0.94 then c:put(x, y, s <= 0 and R[6] or R[3], sptok) return end
    local q = s * 2.2
    local f = q - floor(q + 0.5)
    if abs(f) < 0.2 and abs(s) < 0.8 and t > 0.1 and t < 0.92 then c:put(x, y, R[2], sptok) end
  end)
  return m
end
local s2 = spear(33.4, 40, 25.5, 34, 20.5, 23, 2.6, SP)
local s1 = spear(34.4, 37, 32.5, 23.5, 38.5, 9.5, 3.8, SP)
-- sheath
local sm, sn = G.tube({ { 34.6, 44 }, { 34.3, 41 }, { 34.5, 38.5 }, { 34.4, 36 } }, function(t) return 1.7 - 0.3 * t end)
G.toneN(c, sm, sn, SH, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.2, wrap = 0.35 })
-- collar where the leaf leaves the sheath
for x = 33, 36 do c:put(x, 36, SP[1], sptok) end
-- quirk: three baby thorns on the sheath (dark spine, pale tip)
for _, q in ipairs{ { 36, 42 }, { 36, 39.4 }, { 33, 41 } } do
  local x, y = floor(q[1]), floor(q[2])
  local dir = (x > 34) and 1 or -1
  c:put(x, y, "#4a2a1e") c:put(x + dir, y - 1, "#fff0c0") c:put(x, y - 1, "#4a2a1e")
end

-- seeds last ----------------------------------------------------------------------------------
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = G.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.2, 0.36, 0.52, 0.68, 0.86 }, amb = 0.08, wrap = 0.28 })
  local ca, sa = cos(s[5]), sin(s[5])
  -- flat facet on the upper right: slightly lighter plane with a crisp edge
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + 0.45)
    local v = (-dx * sa + dy * ca) / (s[4] + 0.45)
    local ik = idx[K(x, y)] or 3
    if u > 0.2 and u < 0.9 and abs(v + 0.15) < 0.12 then c:put(x, y, SEED[max(1, ik - 1)], tok) end
  end)
  local rim = X.rim(s.n)
  vis:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.76 and not sb[K(x, y)] then c:put(x, y, "#8a5a5c", tok) end end)
  -- hilum scar (pale oval, dark eye) low on the front
  local hx, hy = s[1] - 2 + (i == 2 and 0 or 0), s[2] + 1
  local hm = G.rell(hx + 0.5, hy + 0.5, 1, 0, 2.5, 1.7):clip(vis)
  hm:each(function(x, y)
    local d = ((x - hx - 0.5) / 2.5) ^ 2 + ((y - hy - 0.5) / 1.7) ^ 2
    c:put(x, y, d > 0.6 and HIL[2] or (x < hx and HIL[4] or HIL[3]), tok) end)
  c:put(hx + 1, hy + 1, HIL[1], tok)
  -- pale pulp fibres from the scar
  c:put(hx - 3, hy + 2, "#d0a070", tok) c:put(hx - 2, hy + 3, "#a87648", tok)
  -- gloss: 2x1 specular + one dot
  c:put(floor(s[1] - 2.6), floor(s[2] - 2), "#fff2d8", tok) c:put(floor(s[1] - 1.6), floor(s[2] - 2), "#fff2d8", tok)
  c:put(floor(s[1] - 3.6), floor(s[2] - 1), SEED[6], tok)
end
-- sprouting stone: germ pore where the sheath leaves, lip around it
for _, q in ipairs{ {33,43,"#3a1a12"}, {34,43,"#3a1a12"}, {35,43,"#3a1a12"} } do c:put(q[1], q[2], q[3]) end
for _, q in ipairs{ {32,43,"#d8b080"}, {36,43,"#bc7a40"} } do c:put(q[1], q[2], q[3]) end
G.save2(c, NAME)
