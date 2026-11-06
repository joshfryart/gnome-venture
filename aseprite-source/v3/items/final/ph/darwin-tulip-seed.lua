-- darwin-tulip-seed (final, Opus single pass). Three flat papery tulip seeds (D-shaped, pale translucent wing rim,
-- darker embryo core, fanned like dropped coins with contact shadows) on a torn strip of tulip leaf (glaucous
-- blue-green strap, parallel veins, waxy bloom speckle, rolled pale rim, ragged tears at both ends). The left seed
-- has germinated into the tulip's own leaf: a broad, slightly wavy lanceolate blade with a fold line, and a second
-- narrow leaf wrapping its foot.
-- quirk: the empty seed coat is still stuck on the tip of the first leaf like a little cap.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB23_3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new("darwin-tulip-seed")
local GL = { "#1b3440", "#264f55", "#367064", "#4f8f74", "#79ae8c", "#aacdaa" }
local BLOOM, UNDER = "#cfe3cf", "#8fb9a6"
local SEED = { "#4a2a22", "#6e4430", "#94643c", "#ba8a54", "#dab47c", "#f4dcae" }
local CUTS = { 0.16, 0.32, 0.48, 0.64, 0.8 }

-- leaf strip (upper-left to lower-right), even width, torn both ends
local function sw(t) if t > 0.995 then return -1 end return 6.0 + 0.6 * sin(t * 9) end
local lm, ln, LT, LS, len = G.blade(8, 39, 32, 46, 58, 51, sw, { fold = 0.22 })
local function sd(k) return LS[k] * (sw(LT[k]) + 0.6) end
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local a = LT[k] * len
  if a < 2.5 + 3.0 * X.hash(floor(sd(k) / 1.6), 0, 5) + sd(k) * 0.3 then cut[#cut + 1] = k end
  if a > len - 2.2 - 3.2 * X.hash(floor(sd(k) / 1.4), 1, 9) + sd(k) * 0.25 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- seeds: flat D discs; {cx, cy, rx, ry, ang}
local seeds = { { 31, 43.5, 4.6, 3.4, -0.35 }, { 38.5, 45.5, 4.6, 3.4, 0.25 }, { 46, 47.5, 4.4, 3.3, -0.15 }, { 17.5, 39.5, 3.8, 2.8, 0.3 } }
for _, s in ipairs(seeds) do
  s.m = G.rell(s[1], s[2], cos(s[5]), sin(s[5]), s[3], s[4])
  -- flat (straight) side on the upper-right edge of each D
  local ux, uy = -sin(s[5]), cos(s[5])
  local rm = {}
  s.m:each(function(x, y) if (x - s[1]) * ux + (y - s[2]) * uy < -(s[4] - 0.8) then rm[#rm + 1] = K(x, y) end end)
  for _, k in ipairs(rm) do s.m.s[k] = nil end
end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, GL, { bias = bias, tok = ltok, cuts = { 0.12, 0.28, 0.44, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y)
  local s, i = sd(k), lidx[k] or 3
  if bias[k] then return end
  -- parallel veins (tulip leaves have no midrib branching)
  if abs(abs(s) - 2.4) < 0.5 or abs(s) < 0.4 then c:put(x, y, GL[max(1, i - 1)], ltok) end
  -- waxy bloom speckle on the lit half
  if i >= 4 and X.hash(x, y, 21) > 0.9 then c:put(x, y, BLOOM, ltok) end
end)
-- rolled rim on the upper (lit) edge, pale underside showing on the lower edge
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s = LS[k]
  if s < -0.75 then c:put(x, y, GL[6], ltok) elseif s > 0.75 then c:put(x, y, UNDER, ltok) end
end)
-- dark row under the rolled rim
lm:each(function(x, y) local k = K(x, y)
  local s = sd(k) if s < -(sw(LT[k]) - 1.6) and s > -(sw(LT[k]) - 0.6) and not bias[k] then c:put(x, y, GL[3], ltok) end end)

-- sprout from the left seed: broad blade + narrow wrapping leaf
local stok = { r = { name = "sprout" } }
local function bw(t) if t > 0.99 then return -1 end return max(0.6, 4.2 * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.8) end
local am, an, AT, AS = G.blade(19, 38, 25, 22, 14, 11, bw, { fold = 0.5 })
local function nw(t) if t > 0.99 then return -1 end return max(0.5, 2.0 * sin(pi * min(1, t * 0.9 + 0.12)) ^ 0.7) end
local bm, bn, BT, BS = G.blade(21, 38, 29, 33, 31, 21, nw, { fold = 0.45 })
bm:cut(am)
local bb = {}
X.ao(bb, bm, am, 1, -1)
local bi = G.toneN(c, bm, bn, GL, { tok = stok, bias = bb, cuts = CUTS, amb = 0.14, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y) if abs(BS[k]) < 0.15 and BT[k] > 0.15 and BT[k] < 0.85 then c:put(x, y, GL[5], stok) end end)
local ab = {}
am:each(function(x, y) local k = K(x, y) if AT[k] < 0.06 then ab[k] = -1 end end)
local ai = G.toneN(c, am, an, GL, { tok = stok, bias = ab, cuts = CUTS, amb = 0.14, wrap = 0.3 })
am:each(function(x, y) local k = K(x, y)
  local t, s = AT[k], AS[k]
  -- fold line: lit crease left of the centre, dark groove right of it
  if t > 0.08 and t < 0.9 then
    if s > -0.22 and s < 0.0 then c:put(x, y, GL[6], stok) elseif s >= 0.0 and s < 0.2 then c:put(x, y, GL[3], stok) end
  end
  -- parallel veins
  if abs(abs(s) - 0.55) < 0.1 and t > 0.2 and t < 0.8 then c:put(x, y, GL[max(1, (ai[k] or 3) - 1)], stok) end
  if (ai[k] or 0) >= 5 and X.hash(x, y, 31) > 0.85 then c:put(x, y, BLOOM, stok) end
end)
-- wavy margin: nick the shade edge every 4 px
am:edge():each(function(x, y) local k = K(x, y) if AS[k] > 0.6 and floor(AT[k] * 30) % 4 == 0 and AT[k] > 0.2 and AT[k] < 0.85 then c:put(x, y, GL[2], stok) end end)
-- cool reflected light lower-right edge of the blade
am:edge():each(function(x, y) local k = K(x, y) if AS[k] > 0.7 and AT[k] > 0.3 and AT[k] < 0.7 and floor(AT[k] * 30) % 4 ~= 0 then c:put(x, y, "#5c7f96", stok) end end)

-- seeds: papery discs
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 4 then vis:cut(am):cut(bm) X.ao(sb, s.m, am, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local n = X.pillow(s.m, 1.4)
  local idx = G.toneN(c, vis, n, SEED, { tok = tok, bias = sb, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.2, wrap = 0.3 })
  local e = s.m:edge()
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local ca, sa = cos(s[5]), sin(s[5])
    local u, v = (dx * ca + dy * sa) / s[3], (-dx * sa + dy * ca) / s[4]
    -- translucent wing rim: lit side pale, shade side mid
    if e:has(x, y) then
      if dx + dy < 0 then c:put(x, y, SEED[6], tok) else c:put(x, y, SEED[3], tok) end
    elseif u * u + (v + 0.15) ^ 2 < 0.28 then
      -- embryo core
      c:put(x, y, (u < -0.15 and v < 0) and SEED[4] or SEED[2], tok)
    end
    if sb[k] and not e:has(x, y) then c:put(x, y, SEED[max(1, (idx[k] or 3))], tok) end
  end)
  local gx, gy = floor(s[1] - s[3] * 0.45 + 0.5), floor(s[2] - 1 + 0.5)
  if vis:has(gx, gy) and not e:has(gx, gy) then c:put(gx, gy, SEED[6], tok) end
end
-- radicle: thin pale root from the sprouting seed curling over the lower edge of the strip
for _, q in ipairs{ {15, 42, "#e9e2c2"}, {14, 43, "#d4c9a0"}, {14, 44, "#d4c9a0"}, {13, 45, "#b8aa80"}, {13, 46, "#b8aa80"}, {12, 47, "#9a8c66"} } do c:put(q[1], q[2], q[3]) end

-- quirk: empty seed coat cap on the blade tip
local cap = { "..ab.", ".abcc", "abccd", ".cdd." }
local CM = { a = SEED[6], b = SEED[5], c = SEED[4], d = SEED[3] }
for yy, row in ipairs(cap) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if CM[ch] then c:put(11 + xx, 7 + yy, CM[ch], { r = { name = "cap" } }) end end end

G.fin(c)
