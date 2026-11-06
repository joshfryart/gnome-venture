-- damask-rose-seed (final, Opus single pass). Three angular rose achenes (ochre, facetted wedge with a dark ridge
-- and a pale lit facet) on a torn, serrated rose-leaflet scrap (glossy deep green, sunken pinnate veins, bronze-red
-- young-leaf margin, torn base, AO + contact shadow). The right achene has germinated: a red-flushed stem with one
-- hooked thorn, two oval cotyledons and a first true leaf of three serrated leaflets (the rose leaf).
-- quirk: a single curled damask-pink petal has fallen on the scrap.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new("damask-rose-seed")
local LEAF = { "#132f2c", "#1d4a37", "#2a6540", "#3f8247", "#62a352", "#97c66a" }
local VEIN_L, VEIN_D = "#b2d983", "#183d32"
local BRONZE = { "#6e2a2e", "#a3433a" }
local SEED = { "#3c2018", "#653620", "#94572a", "#bd7f3a", "#dfaa58", "#f6d88e" }
local STEM = { "#5a2230", "#8a3a3a", "#6e9a4a", "#a8cc72" }
local PET = { "#6a1f48", "#9e2f5e", "#c94f7c", "#e8769a", "#f8a4bc", "#ffd2dc" }
local CUTS = { 0.18, 0.34, 0.5, 0.66, 0.82 }

-- leaf scrap: one rose leaflet on the diagonal (torn at the base, lower-left)
local function lw(t) if t > 0.99 then return -1 end return max(0.6, 7.6 * sin(pi * min(1, 0.18 + t * 0.84)) ^ 0.7) end
local lm, ln, LT, LS, len = G.blade(9, 53, 30, 54, 55, 37, lw, { fold = 0.32 })
local function sd(k) return LS[k] * (lw(LT[k]) + 0.6) end
-- serrated margin: sawtooth teeth pointing to the tip
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k]
  local f = G.fr(t * len / 4.2 + (LS[k] > 0 and 0.5 or 0))
  if t > 0.1 and abs(sd(k)) > lw(t) - 1.3 * (1 - f) ^ 2 + 0.1 then cut[#cut + 1] = k end
  -- torn base: ragged diagonal tear
  if t < 0.12 and (t * len) < 3.2 + 2.4 * X.hash(x, y, 3) + LS[k] * 2.2 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds (achenes): poly + ridge
local seeds = {
  { pts = { {12,49},{17,45},{22,47},{20,52},{14,53} }, r = { 13, 51, 21, 46 } },
  { pts = { {23,47},{27,43},{32,44},{31,49},{25,50} }, r = { 24, 49, 31, 44 } },
  { pts = { {35,42},{39,39},{44,41},{42,46},{37,46} }, r = { 36, 45, 43, 40 } },
}
for _, s in ipairs(seeds) do s.m = c:poly(s.pts) end

-- quirk petal: curled heart-ish petal lying on the leaf, lower right part
local pm = G.rell(34, 51.5, 0.92, -0.38, 4.4, 2.6)
pm:add(G.rell(36.5, 50.5, 0.92, -0.38, 2.6, 2.0))
pm:cut(G.rell(39.2, 49.3, 0.92, -0.38, 1.1, 1.1))

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
X.ao(bias, lm, pm, 1, -1) G.cast(bias, lm, pm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
-- veins: sunken midrib (pale on lit half, dark groove) + pinnate side veins swept to the tip
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local t, s = LT[k], sd(k)
  if abs(s) < 0.6 and t > 0.06 and t < 0.95 then c:put(x, y, (s <= 0 or t > 0.5) and VEIN_L or LEAF[5], ltok) return end
  local ph = G.fr((t * len - abs(s) * 1.1) / 5.2 + (s > 0 and 0.45 or 0))
  if ph < 0.18 and abs(s) > 1 and abs(s) < lw(t) - 1.4 and t > 0.08 and t < 0.9 then
    c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 4) + 2)] or LEAF[max(1, (lidx[k] or 3) - 2)], ltok)
  end
end)
-- bronze young-leaf margin on the tips of the teeth (lit side) and cool rim on the shade side
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  if s < -0.6 and LT[k] > 0.25 and LT[k] < 0.8 and X.hash(x, y, 7) > 0.6 then c:put(x, y, BRONZE[2], ltok)
  elseif s > 0.7 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, "#2f6062", ltok) end
end)
-- tip glint
c:put(53, 38, LEAF[6], ltok)

-- petal (quirk): rolled lit edge, dark curl underneath, fine veins
local pn = X.pillow(pm, 2.2)
local ptok = { r = { name = "petal" } }
local pidx = G.toneN(c, pm, pn, PET, { tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.2, wrap = 0.35 })
pm:each(function(x, y) local k = K(x, y)
  local u = (x - 34) * 0.92 + (y - 51.5) * -0.38
  if abs(u - 1.5) < 0.5 and (y % 2 == 0) and (pidx[k] or 0) > 2 then c:put(x, y, PET[(pidx[k]) - 1], ptok) end
end)
c:put(31, 51, PET[6]) c:put(32, 51, PET[6])

-- sprout: stem from the right achene, up and slightly left
local sp = { { 39, 41 }, { 38, 35 }, { 40, 28 }, { 38, 21 } }
local stok = { r = { name = "stem" } }
local sm, sn, ST, SS = G.tube(sp, function(t) return 1.0 end)
sm:cut(seeds[3].m)
sm:each(function(x, y) local k = K(x, y)
  local t, s = ST[k], SS[k]
  local col = s < -0.2 and (t < 0.45 and STEM[2] or STEM[4]) or (t < 0.45 and STEM[1] or STEM[3])
  c:put(x, y, col, stok)
end)
-- thorn: hooked, red, pointing down-right
c:put(41, 32, STEM[2], stok) c:put(42, 33, STEM[1], stok)

-- cotyledons: two small ovals, low on the stem
local function lobe(cx, cy, ux, uy, ra, rb, ramp)
  local m = G.rell(cx, cy, ux, uy, ra, rb)
  m:cut(sm)
  local n = X.pillow(m, 1.8)
  local idx = G.toneN(c, m, n, ramp, { tok = ltok, cuts = CUTS, amb = 0.15, wrap = 0.3 })
  return m, idx
end
local cl = lobe(33.5, 32.5, 0.9, 0.42, 4.0, 1.8, LEAF)
local cr = lobe(44.5, 31.5, 0.92, -0.38, 4.0, 1.8, LEAF)
for _, q in ipairs{ {32, 32}, {33, 32}, {44, 31}, {45, 31} } do c:put(q[1], q[2], LEAF[6], ltok) end

-- true leaf: three serrated leaflets on a short rachis
local function leaflet(cx, cy, ux, uy, ra, rb)
  local m = G.rell(cx, cy, ux, uy, ra, rb)
  local px, py = -uy, ux
  -- teeth: notch the margin every 2 px along the long axis
  local rm = {}
  m:each(function(x, y)
    local a = (x - cx) * ux + (y - cy) * uy
    local b = (x - cx) * px + (y - cy) * py
    local edge = (a / ra) ^ 2 + (b / rb) ^ 2
    if edge > 0.62 and floor(a + 20) % 3 == 0 and abs(b) > 0.8 then rm[#rm + 1] = { x, y } end
  end)
  for _, q in ipairs(rm) do m.s[K(q[1], q[2])] = nil end
  local n = X.pillow(m, 1.7)
  local idx = G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  -- midrib
  for i = -floor(ra) + 1, floor(ra) - 1 do
    local x, y = floor(cx + ux * i + 0.5), floor(cy + uy * i + 0.5)
    if m:has(x, y) then c:put(x, y, i < 0 and LEAF[5] or LEAF[3], ltok) end
  end
  return m
end
leaflet(37.5, 14.5, -0.2, -0.98, 4.6, 3.0)
leaflet(31.5, 21.0, -0.88, -0.48, 4.0, 2.6)
leaflet(44.0, 20.0, 0.9, -0.44, 4.0, 2.6)
-- rachis joint (red flush) and AO where leaflets meet the stem
for _, q in ipairs{ {38, 21, STEM[1]}, {38, 20, STEM[2]}, {37, 19, STEM[2]}, {35, 21, LEAF[2]}, {41, 21, LEAF[2]} } do c:put(q[1], q[2], q[3], stok) end

-- achenes last: facets, ridge, AO
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local n = G.facet(s.m, s.r[1], s.r[2], s.r[3], s.r[4], 0.5)
  local b = {}
  if i == 3 then X.ao(b, s.m, sm, 1, -1) end
  local idx = G.toneN(c, s.m, n, SEED, { tok = tok, bias = b, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.12, wrap = 0.3 })
  -- ridge line: dark groove with a lit pixel just above
  local ax, ay, bx, by = s.r[1], s.r[2], s.r[3], s.r[4]
  for j = 0, 8 do local t = j / 8
    local x, y = floor(ax + (bx - ax) * t + 0.5), floor(ay + (by - ay) * t + 0.5)
    if s.m:has(x, y) and not s.m:edge():has(x, y) then c:put(x, y, SEED[2], tok) end
  end
  -- pit marks (achene surface texture)
  s.m:each(function(x, y) if X.hash(x, y, 11 + i) > 0.86 and (idx[K(x, y)] or 0) >= 4 then c:put(x, y, SEED[3], tok) end end)
end
-- radicle stub from the sprouting achene (pale, hooked down-right)
c:put(43, 45, "#e9e2b6") c:put(44, 46, "#d2c48e") c:put(44, 47, "#b8a46e")
-- one glint on the front achene
c:put(26, 45, SEED[6]) c:put(27, 44, "#fff2cc")

G.fin(c)
