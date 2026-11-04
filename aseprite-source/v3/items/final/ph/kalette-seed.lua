-- kalette-seed (final pass, Opus single pass). Three round brassica seeds (glossy plum-brown spheres, net texture,
-- one glint each) on a torn scrap of kalette leaf lying on a rising diagonal (frilled lower margin edged in violet,
-- violet midrib and veins, cool rim, AO + contact shadow under every seed). The left seed has sprouted: a pale,
-- violet-flushed stem, two kidney cotyledons and a tiny frilly rosette (two ruffled true leaves, purple-edged):
-- the kalette floret in miniature.
-- quirk: the right-hand seed has split open and shows its pale yellow folded embryo.
local NAME = "kalette-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1c2a3a", "#26453f", "#356548", "#4c8650", "#72a95e", "#a6cf80" }
local PURP = { "#2e1838", "#4a2156", "#6e3478", "#94509a", "#bb7cc0", "#e0b2e0" }
local COOL, VEIN, TISSUE = "#4a6a86", "#d2b8dc", "#d4eab4"
local SEED = { "#1e1220", "#361c30", "#552a3e", "#774048", "#9c6055", "#d09a80" }
local SPR = { "#2a5640", "#3d7648", "#5c9a54", "#84bc66", "#b2da88", "#e0f2b8" }
local STEM = { "#6a5a7a", "#a78fb0", "#d2c2d6", "#f2ecf0" }
local EMB = { "#8a6a2a", "#c8a84a", "#ecd47a", "#fff0b0" }

-- seeds (cx, cy, r); #4 is split
local seeds = { { 20, 49, 2.6 }, { 28, 48, 2.5 }, { 34, 45, 2.5 }, { 43, 43, 2.7 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3], 0, 1) end

-- leaf scrap: rising diagonal, frilled lower (+s) margin, torn at the upper right end
local lm, ln, LT, LS, len = A.blade(8, 56, 28, 54, 56, 38, function(t)
  if t > 0.995 then return -1 end
  return max(0.6, 8.0 * sin(pi * min(1, t * 0.82 + 0.1)) ^ 0.5)
end, { fold = 0.35 })
local F = A.frill(lm, LT, LS, len, 4.0, function(t) return 0.34 end, 0.06, 0.92)
A.ruffle(ln, LT, LS, len, 4.0, 0.6, 0.66, 1, -0.3)
local torn = A.tear(lm, LT, LS, 0.85, { 0.04, -0.03, 0.06, -0.02, 0.05, -0.04, 0.03, 0 })
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = PURP[5], cool = COOL, per = 5.2, sweep = 4, len = len,
  torn = torn, tissue = TISSUE, tok = ltok, bias = bias, t1 = 0.86, veins = false })
-- violet veins and violet frilled margin (the kalette flush)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if (bias[k] or 0) < 0 or torn:has(x, y) then return end
  local ph = (t * len - abs(s) * 4) / 5.2 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.06 and t < 0.84 then
    c:put(x, y, s < 0 and PURP[4] or PURP[3], ltok) end
  if abs(s) > 0.8 and t > 0.05 and t < 0.84 then
    local i = max(1, min(6, (lidx[k] or 3)))
    c:put(x, y, PURP[i], ltok) end
end)
for _, q in ipairs{ { 7, 56, 3 }, { 6, 57, 2 }, { 5, 58, 2 } } do c:put(q[1], q[2], STEM[q[3]], ltok) end

-- sprout: stem from the left seed, gentle S
local stok = { r = { name = "stem" } }
local sp = { { 20, 47 }, { 18, 40 }, { 22, 33 }, { 20, 26 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })

-- kidney cotyledons on short stalks
local function coty(sx, sy, ux, uy, ra, rb)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local cx, cy = sx + ux * (ra + 1.2), sy + uy * (ra + 1.2)
  local m = A.rell(cx, cy, ux, uy, ra, rb)
  m:cut(A.rell(cx + ux * (ra + 0.4), cy + uy * (ra + 0.4), ux, uy, 1.5, 1.2))
  for i = 0, 6 do local t = i / 6 m:set(floor(sx + ux * 1.6 * t + 0.5), floor(sy + uy * 1.6 * t + 0.5)) end
  return m, X.pillow(m, 1.8), cx, cy, ux, uy
end
local ctok = { r = { name = "coty" } }
local cl, cln, lcx, lcy, lux, luy = coty(19, 27, -1, -0.15, 4.0, 2.8)
local cr, crn, rcx, rcy, rux, ruy = coty(21, 27, 1, -0.3, 4.0, 2.8)
local sb = {}
X.ao(sb, cl, sm, 1, -1) X.ao(sb, cr, sm, 1, -1)
A.shade(c, cl, cln, SPR, { tok = ctok, bias = sb, amb = 0.1, wrap = 0.3 })
A.shade(c, cr, crn, SPR, { tok = ctok, bias = sb, amb = 0.1, wrap = 0.3 })
for i = 1, 4 do
  c:put(floor(lcx - lux * (2 - i) + 0.5), floor(lcy - luy * (2 - i) + 0.5), SPR[6], ctok)
  c:put(floor(rcx - rux * (2 - i) + 0.5), floor(rcy - ruy * (2 - i) + 0.5), SPR[3], ctok)
end

-- rosette: two ruffled true leaves in a V, violet-edged
local function tleaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.98 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.6)
  end, { fold = 0.4 })
  A.frill(m, T, S, L, 2.4, function(t) return 0.4 end, 0.2, 0.96)
  m:cut(cl):cut(cr)
  local idx = A.shade(c, m, n, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3, cuts = { 0.12, 0.28, 0.44, 0.6, 0.76 } })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.12 and T[k] < 0.85 then c:put(x, y, PURP[5], ltok)
    elseif abs(S[k]) > 0.62 then c:put(x, y, PURP[max(2, min(6, idx[k]))], ltok) end end)
  return m
end
local t1 = tleaf(20, 25, 16, 19, 15, 12, 3.0)
local t2 = tleaf(21, 25, 25, 19, 26, 13, 2.8)

-- seeds last: lambert + net + glint
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local b = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(b, s.m, seeds[j].m, 1, -1) end
  if i == 1 then X.ao(b, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = b, amb = 0.06, wrap = 0.15, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
  vis:each(function(x, y) local k = K(x, y) if (x * 3 + y * 5) % 7 == 0 and idx[k] >= 4 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  if i < 4 then local gx, gy = A.specAt(vis, s.n, 30) if gx then c:put(gx, gy, "#fff4d6", tok) end end
end
-- quirk: split seed, a jagged dark crack and the pale folded embryo peeking out (upper-left half)
do
  local tok = { r = { name = "embryo" } }
  local s = seeds[4]
  local ex, ey = s[1], s[2]
  for _, q in ipairs{ { -1, -2, 4 }, { 0, -2, 3 }, { -2, -1, 3 }, { -1, -1, 3 }, { 0, -1, 2 }, { -2, 0, 2 }, { -1, 0, 2 } } do
    c:put(ex + q[1], ey + q[2], EMB[q[3]], tok) end
  for _, q in ipairs{ { 1, -2 }, { 1, -1 }, { 0, 0 }, { -1, 1 }, { -2, 1 } } do c:put(ex + q[1], ey + q[2], SEED[1], tok) end
  c:put(ex - 1, ey - 2, "#fff4d6", tok)
end
c:put(20, 47, STEM[2], stok) c:put(20, 48, STEM[1], stok)

A.save(c, NAME)
