-- kale-seed (final pass, Opus single pass). Four round brassica seeds (glossy red-brown spheres, fine net texture,
-- one hard glint each) on a torn scrap of blue-green kale leaf (frilled upper margin, ragged torn right end, pale
-- midrib, veins, cool rim, AO + contact shadow under every seed). The last seed has sprouted: pale hooked stem,
-- two notched heart-shaped brassica cotyledons on stalks and a first frilly true leaf (the kale shape in miniature).
-- quirk: the split seed coat still sits like a tiny cap on the tip of the right cotyledon.
local NAME = "kale-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#122a36", "#1b4244", "#275d4e", "#367a58", "#529866", "#86b88a" }
local COOL, VEIN, TISSUE = "#3d6f80", "#c6e2a6", "#cfe6b0"
local SEED = { "#1f1418", "#3a2024", "#5a2f2c", "#7d4535", "#a3653f", "#d6a070" }
local SPR = { "#2c5a3e", "#3f7a48", "#5f9e56", "#86bf68", "#b4dc8a", "#def3b4" }
local STEM = { "#5b7f58", "#97b98a", "#c9e2b0", "#eef6d8" }

-- seeds (cx, cy, r)
local seeds = { { 14, 48, 2.6 }, { 21, 50, 2.6 }, { 27, 46, 2.5 }, { 37, 46, 2.7 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3], 0, 1) end

-- leaf scrap: kale blade lying left->right, frilled top margin, torn off on the right
local lm, ln, LT, LS, len = A.blade(6, 52, 28, 42, 56, 47, function(t)
  if t > 0.995 then return -1 end
  return max(0.6, 8.4 * sin(pi * min(1, t * 0.85 + 0.08)) ^ 0.55)
end, { fold = 0.35 })
A.frill(lm, LT, LS, len, 4.4, function(t) return 0.32 end, 0.06, 0.9)
A.ruffle(ln, LT, LS, len, 4.4, 0.6, 0.7, 1, -0.2)
local torn = A.tear(lm, LT, LS, 0.84, { 0.03, -0.04, 0.05, -0.02, 0.06, -0.05, 0.02, 0 })
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = VEIN, cool = COOL, per = 5.5, sweep = 5, len = len, torn = torn,
  tissue = TISSUE, tok = ltok, bias = bias, t1 = 0.86 })
-- petiole stub at the left base
for _, q in ipairs{ { 5, 53, 4 }, { 4, 54, 3 }, { 3, 55, 3 } } do c:put(q[1], q[2], STEM[q[3] - 1], ltok) end

-- sprout: stem from the last seed, slight hook
local stok = { r = { name = "stem" } }
local sp = { { 37, 44 }, { 38, 37 }, { 36, 30 }, { 37, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
A.shade(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })

-- cotyledons: notched kidney/heart shapes on short stalks
local function coty(sx, sy, ux, uy, ra, rb)
  local l = math.sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local cx, cy = sx + ux * (ra + 1.2), sy + uy * (ra + 1.2)
  local m = A.rell(cx, cy, ux, uy, ra, rb)
  m:cut(A.rell(cx + ux * (ra + 0.3), cy + uy * (ra + 0.3), ux, uy, 1.6, 1.1))   -- heart notch
  -- stalk
  for i = 0, 6 do local t = i / 6 m:set(floor(sx + ux * 1.6 * t + 0.5), floor(sy + uy * 1.6 * t + 0.5)) end
  local n = X.pillow(m, 1.8)
  return m, n, cx, cy, ux, uy
end
local ctok = { r = { name = "coty" } }
local cl, cln, lcx, lcy, lux, luy = coty(36, 24, -1, -0.35, 5.2, 3.5)
local cr, crn, rcx, rcy, rux, ruy = coty(38, 24, 1, -0.45, 5.2, 3.5)
local sb = {}
X.ao(sb, cl, sm, 1, -1) X.ao(sb, cr, sm, 1, -1)
local cli = A.shade(c, cl, cln, SPR, { tok = ctok, bias = sb, amb = 0.1, wrap = 0.3 })
local cri = A.shade(c, cr, crn, SPR, { tok = ctok, bias = sb, amb = 0.1, wrap = 0.3 })
-- midvein on each cotyledon
for i = 1, 4 do
  c:put(floor(lcx - lux * (2 - i) + 0.5), floor(lcy - luy * (2 - i) + 0.5), SPR[6], ctok)
  c:put(floor(rcx - rux * (2 - i) + 0.5), floor(rcy - ruy * (2 - i) + 0.5), SPR[3], ctok)
end
-- first true leaf: small frilly oval, upright, between the cotyledons
local tm, tn, TT, TS, tlen = A.blade(37, 22, 36, 15, 38, 9, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 3.2 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6)
end, { fold = 0.4 })
A.frill(tm, TT, TS, tlen, 2.6, function(t) return 0.35 end, 0.15, 0.95)
tm:cut(cl):cut(cr)
local ti = A.shade(c, tm, tn, LEAF, { tok = ltok, amb = 0.12, wrap = 0.3, cuts = { 0.12, 0.28, 0.44, 0.6, 0.76 } })
tm:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.16 and TT[k] > 0.15 and TT[k] < 0.85 then c:put(x, y, VEIN, ltok) end end)

-- quirk: seed-coat cap on the right cotyledon tip
local qx, qy = floor(rcx + rux * 5.4 + 0.5), floor(rcy + ruy * 5.4 + 0.5)
local qtok = { r = { name = "cap" } }
for _, q in ipairs{ { 0, -1, 4 }, { 1, -1, 3 }, { -1, 0, 5 }, { 0, 0, 3 }, { 1, 0, 2 }, { 2, 0, 1 }, { 2, -1, 2 } } do
  c:put(qx + q[1], qy + q[2], SEED[q[3]], qtok) end
c:put(qx - 1, qy - 1, SEED[6], qtok)

-- seeds last: lambert + net texture + glint, AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local b = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(b, s.m, seeds[j].m, 1, -1) end
  if i == #seeds then X.ao(b, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = b, amb = 0.06, wrap = 0.15, cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 } })
  -- reticulate seed-coat: faint darker net dots on the lit part
  vis:each(function(x, y) local k = K(x, y) if (x * 3 + y * 5) % 7 == 0 and idx[k] >= 4 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, "#fff4d6", tok) end
end
-- sprout stem foot over the last seed (it breaks out of the coat)
c:put(37, 44, STEM[2], stok) c:put(37, 45, STEM[1], stok)

A.save(c, NAME)
