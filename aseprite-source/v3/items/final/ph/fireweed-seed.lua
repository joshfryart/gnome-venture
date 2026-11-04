-- fireweed-seed (B3, Opus single pass). Two slender brown fireweed seeds, each with its silky white coma, lying on a
-- torn narrow lance-shaped fireweed-leaf scrap (pink midrib, laterals that loop into a pale submarginal vein - the
-- fireweed tell; jagged torn base, AO + contact shadow). The lower seed has sprouted: a red-flushed stem, two tiny
-- round cotyledons and a pair of narrow willowy true leaves with pink midribs.
-- quirk: a third seed is drifting away on its open silk parachute.
local NAME = "fireweed-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB31_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1a3a3a", "#24544a", "#33704f", "#4a8e56", "#6eac62", "#a4cc82" }
local RIB = { "#7d2c5e", "#b04a78", "#e07a9e" }
local SUB = "#9cc88a"
local SEED = { "#3a2622", "#5a3a2a", "#7e5634", "#a07444", "#c49a62" }
local SILK = { "#8a82a4", "#b4adc8", "#dcd6e8", "#fbf5ea" }
local STEM = { "#6e2a44", "#9a3e52", "#5e9a52", "#8cc06a" }

-- seeds on the leaf: cx, cy, rx, ry, angle (silk leaves from the -u end, i.e. up-left)
local seeds = { { 25, 49, 3.0, 1.15, 0.45 }, { 35, 44, 3.0, 1.15, 0.3 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: narrow lance
local lm, ln, LT, LS, len = A.blade(8, 58, 28, 52, 57, 32, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 6.0 * sin(pi * min(1, 0.16 + t * 0.84)) ^ 0.62)
end, { fold = 0.36 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local jag = 2.0 + 3.0 * X.hash(floor(LS[k] * 4 + 9), 5, 3)
  if LT[k] * len < jag then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.02 and t < 0.94 then c:put(x, y, s <= 0 and RIB[3] or RIB[2], ltok) return end
  -- submarginal loop vein
  if abs(s) > 0.66 and abs(s) < 0.8 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and SUB or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 3.0) / 4.6 + (s > 0 and 0.5 or 0)
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.88 and abs(s) > 0.15 and abs(s) < 0.66 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[5] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] * len < 5.5 then c:put(x, y, LEAF[2], ltok)
  elseif not bias[k] and LS[k] > 0.72 and LT[k] < 0.88 then c:put(x, y, "#2e5e72", ltok) end end)

-- silk coma: fan of 1px curved strands from (x,y), direction a, spread, length L
local function coma(x, y, a, spread, L, n, tok, under)
  for i = 0, n - 1 do
    local f = (i / (n - 1)) * 2 - 1
    local aa = a + f * spread
    local lit = -cos(aa) * 0.6 - sin(aa) * 0.8
    local Li = L * (1 - 0.18 * abs(f))
    for d = 1, Li, 0.5 do
      local bend = f * 0.0025 * d * d
      local px = x + cos(aa + bend) * d
      local py = y + sin(aa + bend) * d
      local xi, yi = floor(px + .5), floor(py + .5)
      if not (under and under:has(xi, yi)) then
        local tone = (d < 2) and 1 or ((d > Li - 1.5) and 4 or (lit > 0.25) and 3 or (lit > -0.3 and 3 or 2))
        c:put(xi, yi, SILK[tone], tok)
      end
    end
  end
end

-- sprout from seed 1 (behind its silk)
local stok = A.tok("stem")
local sm, sn = A.tube({ { 26, 47 }, { 28, 40 }, { 27, 33 }, { 29, 25 } }, function(t) return 1.0 end)
local sidx = A.tone(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
sm:each(function(x, y) if y > 37 then c:put(x, y, (sidx[K(x, y)] or 2) >= 3 and STEM[2] or STEM[1], stok) end end)
local function lance(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, 0.1 + t * 0.9)) ^ 0.6)
  end, { fold = 0.35 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.17 and T[k] > 0.08 and T[k] < 0.86 then c:put(x, y, S[k] <= 0 and RIB[3] or RIB[2], ltok) end end)
  return m
end
-- cotyledons: tiny round
local cm1, cn1 = A.oval(24.5, 36, 2.4, 1.5, 0.3, 0.7) cm1:cut(sm)
A.toneN(c, cm1, cn1, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.16, wrap = 0.3 })
local cm2, cn2 = A.oval(31.5, 35, 2.4, 1.5, -0.3, 0.7) cm2:cut(sm)
A.toneN(c, cm2, cn2, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.16, wrap = 0.3 })
-- true leaves: narrow willowy pair + small terminal leaf
local l1 = lance(28, 27, 23, 22, 15, 21, 2.3)
local l2 = lance(29, 26, 34, 20, 42, 17, 2.3)
local l3 = lance(29, 25, 29, 20, 31, 13, 1.7)
for _, p in ipairs{ { 28, 26 }, { 30, 26 } } do if not sm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

-- seeds with silk on the leaf
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  local ca, sa = cos(s[5]), sin(s[5])
  local ex, ey = s[1] - (s[3] + 0.6) * ca, s[2] - (s[3] + 0.6) * sa
  local ang = math.atan(-sa, -ca)
  coma(ex, ey, ang + (i == 1 and 0.15 or -0.1), 0.55, 9.5, 5, A.tok("silk" .. i), i == 2 and sm or nil)
  local idx = A.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.22, 0.42, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })
  -- fine ridge along the seed
  for u = -0.6, 0.6, 0.15 do
    local xi, yi = floor(s[1] + u * s[3] * ca + .5), floor(s[2] + u * s[3] * sa + .5)
    if s.m:has(xi, yi) then A.step(c, idx, SEED, xi, yi, 1, tok) end
  end
end

-- quirk: drifting seed, parachute open above it
local dtok = A.tok("drift")
local dm, dn = A.oval(13, 26, 2.4, 1.0, -1.15, 0.8)
coma(12.0, 23.4, -1.6, 0.85, 8.5, 6, A.tok("dsilk"))
A.toneN(c, dm, dn, SEED, { tok = dtok, cuts = { 0.22, 0.42, 0.62, 0.8 }, amb = 0.12, wrap = 0.3 })

A.save(c, NAME)
