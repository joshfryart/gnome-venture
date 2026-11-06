-- banana-seed (pass B, final). Three small, hard, glossy black wild-banana seeds (irregular angular pebbles, cool
-- rim, sharp specular, hard contact shadow) on a strip of banana leaf: pale grooved midrib along the top edge,
-- blade with pale parallel vein bands, margin torn into ribbons along the veins; the whole strip is re-cut as a
-- slim curved ribbon (pass A was a boxy straight band). History: banana-seed.pA (pass A).
-- quirk: the end of the leaf strip is still rolled up like a cigar, the way new banana leaves unfurl.
local NAME = "banana-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_g1.lua")
local HP, X, c, P = G.new(NAME)
local K = G.K
local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local RIB  = { "#5a7536", "#7c9545", "#a2b65a", "#c3d275", "#dfe59c", "#f0f2c0" }
local BLOOM = { "#7fa68a", "#a3c4a6", "#c6dcc2" }
local SEED = { "#170f1c", "#23182a", "#332438", "#46334c", "#5e4864", "#7d6684" }

-- ribbon: a curved strip of leaf, midrib on the upper-left edge, torn ribbons on the lower-right edge
local AX, AY, CX, CY, BX, BY = 10, 53, 27, 27, 49, 30
local HW = 6.8
local m0, _, T, S, len = G.blade(AX, AY, CX, CY, BX, BY, function(t)
  if t < 0.06 then return HW * (0.55 + t * 7) end      -- torn start
  return HW
end)
local U, V = {}, {}
local strip, rib, flip = HP.mask(), HP.mask(), HP.mask()
local FING = { 11.4, 13.8, 12.0, 14.2 }
m0:each(function(x, y) local k = K(x, y)
  local u, v = T[k] * len, (S[k] * (HW + 0.6)) + HW       -- v: 0 at the midrib edge
  U[k], V[k] = u, v
  local umin = X.hash(math.floor(v / 1.5), 3, 7) * 2.6
  local f, slit = 1, false
  for _, u0 in ipairs{ -0.5, 7.5, 16.5 } do
    local d = u - (u0 + 0.7 * v)
    if d > 0 then f = f + 1 end
    if math.abs(d) < 0.75 + math.max(0, v - 6) * 0.2 and v > 4 then slit = true end
  end
  local vmax = FING[f] - X.hash(math.floor(u), 1, 9) * 0.8
  if u >= umin and v <= vmax and not slit then
    if v < 2.3 then rib:set(x, y) else strip:set(x, y) end
  end
end)
-- rolled end: a short cylinder lying across the strip end
local tx, ty = BX - CX, BY - CY local tl = math.sqrt(tx * tx + ty * ty) tx, ty = tx / tl, ty / tl
local px, py = -ty, tx if px + py < 0 then px, py = -px, -py end
local RC = { BX + tx * 2.4, BY + ty * 2.4 }
local tube, tn, TT, TS = X.cyl(RC[1] - px * 1.2, RC[2] - py * 1.2, RC[1] + px * 11.5, RC[2] + py * 11.5, function(t) return 3.5 end)
local capC = { RC[1] + px * 11.8, RC[2] + py * 11.8 }
local cap = HP.mask()
for y = math.floor(capC[2]) - 6, math.floor(capC[2]) + 6 do for x = math.floor(capC[1]) - 6, math.floor(capC[1]) + 6 do
  local dx, dy = x - capC[1], y - capC[2]
  local a, b = dx * tx + dy * ty, dx * px + dy * py
  if (a / 4.3) ^ 2 + (b / 2.6) ^ 2 <= 1 then cap:set(x, y) end
end end
tube:cut(cap) strip:cut(tube):cut(cap) rib:cut(tube):cut(cap) flip:clip(strip)

-- seeds: small irregular angular pebbles, placed in strip (u, v)
local function UVtoXY(u, v)
  local best, bx, by = 1e9
  m0:each(function(x, y) local k = K(x, y) local q = (U[k] - u) ^ 2 + (V[k] - v) ^ 2 if q < best then best, bx, by = q, x, y end end)
  return bx, by
end
local seeds = { { 10.5, 7.0, 3.7, 1 }, { 20, 8.4, 3.3, 2 }, { 29, 6.6, 3.6, 3 } }
local seedAll = HP.mask()
for i, s in ipairs(seeds) do
  local x, y = UVtoXY(s[1], s[2])
  local pts = {}
  for j = 0, 5 do
    local a = j / 6 * 2 * math.pi + s[4]
    local r = s[3] * (0.88 + X.hash(j, s[4], 5) * 0.2)
    pts[#pts + 1] = { x + math.cos(a) * r * 1.1, y + math.sin(a) * r * 0.9 }
  end
  local m = c:poly(pts)
  local n = X.pillow(m, 3.0)
  s.m, s.n, s.x, s.y = m, n, x, y
  seedAll:add(m)
end

-- blade: flat, lit evenly; corrugation as alternating tone steps along the parallel veins
local bias = {}
X.ao(bias, strip, seedAll, 1, -1) G.cast(bias, strip, seedAll, 1, 2, -1) G.cast(bias, strip, seedAll, 2, 2, -1)
X.ao(bias, strip, tube, 1, -1) X.ao(bias, strip, cap, 1, -1)
local n = {}
local L3 = X.L
strip:each(function(x, y) local k = K(x, y)
  local ph = (U[k] - 0.7 * V[k]) % 3
  if ph < 1.05 and V[k] > 2.8 and not bias[k] then bias[k] = 1 end
  local cup = (V[k] - 6) / 14
  n[k] = { G.norm(px * cup, py * cup, 1) }
end)
local ltok = { r = { name = "leaf" } }
G.toneN(c, strip, n, LEAF, { bias = bias, tok = ltok, amb = 0.12, wrap = 0.2, cuts = { 0.25, 0.45, 0.62, 0.78, 0.9 } })

-- midrib: rounded rod
local rn = {}
rib:each(function(x, y) local k = K(x, y) local s = (V[k] - 1.15) / 1.6 rn[k] = { G.norm(px * s, py * s, math.sqrt(math.max(0.05, 1 - s * s))) } end)
local rb = {} X.ao(rb, rib, tube, 1, -1)
local rtok = { r = { name = "rib" } }
G.toneN(c, rib, rn, RIB, { tok = rtok, bias = rb })
-- tube
local ttok = { r = { name = "tube" } }
local tb = {} X.ao(tb, tube, cap, 1, -1)
G.toneN(c, tube, tn, LEAF, { tok = ttok, amb = 0.06, wrap = 0.1, bias = tb, cuts = { 0.22, 0.4, 0.56, 0.72, 0.86 } })
tube:each(function(x, y) local k = K(x, y)
  if tb[k] then return end
  local along = TT[k] * 12.7 - 1.2
  if along < 1.1 then c:put(x, y, TS[k] < -0.2 and RIB[5] or RIB[3], ttok)
  elseif TS[k] > -0.62 and TS[k] < -0.38 then c:put(x, y, LEAF[6], ttok)
  elseif math.abs(TS[k] - 0.15 - (along - 6) * 0.06) < 0.13 then c:put(x, y, LEAF[1], ttok) end      -- seam of the outer layer
end)
-- end cap: rolled layers seen end-on
cap:each(function(x, y) local k = K(x, y)
  local dx, dy = x - capC[1], y - capC[2]
  local a, b = (dx * tx + dy * ty) / 4.3, (dx * px + dy * py) / 2.6
  local r = math.sqrt(a * a + b * b)
  local col = r > 0.7 and (a < -0.1 and LEAF[5] or (a > 0.4 and LEAF[2] or LEAF[3])) or LEAF[1]
  if r > 0.28 and r < 0.52 and a < 0.3 then col = BLOOM[1] end
  c:put(x, y, col, ttok)
end)

-- seeds: glossy black
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  G.toneN(c, s.m, s.n, SEED, { tok = tok, amb = 0.04, wrap = 0.1, cuts = { 0.3, 0.46, 0.6, 0.72, 0.84 } })
  local rim = X.rim(s.n)
  s.m:edge():each(function(x, y) if rim[K(x, y)] > 0.7 then c:put(x, y, "#4c5488", tok) end end)
  local bx, by = G.specAt(s.m, s.n, 50)
  c:put(bx, by, "#f4ecf6", tok) c:put(bx + 1, by, SEED[6], tok) c:put(bx, by + 1, SEED[5], tok)
end
G.save(c, NAME)
