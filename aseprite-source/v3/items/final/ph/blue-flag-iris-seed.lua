-- blue-flag-iris-seed (final, Opus single pass). Three flat D-shaped iris seeds (corky brown coat with pits, pale
-- keel rim, one glint each) on a torn strip of glaucous sword leaf (parallel veins, ragged torn ends, cool edge,
-- AO + contact shadow under each seed). The right seed has split and pushed up an equitant fan of three slim
-- sword leaves that overlap at the base (dark sheath, AO where they meet).
-- quirk: the tallest sword leaf has flopped over at the tip like a bent ear.
local NAME = "blue-flag-iris-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#17393f", "#1f5050", "#2c6b5e", "#45896e", "#6aa882", "#9cc8a0" }
local FAN = { "#1a4246", "#235b56", "#337864", "#4f9874", "#7cbb8a", "#b2dbaa" }
local VEIN, COOL = "#2a6058", "#3d6c86"
local SEED = { "#3b2420", "#5a3426", "#7e4a2e", "#a3683a", "#c48e55", "#e2b77c" }

-- seeds (cx, cy, rx, ry, angle of the flat side normal)
local seeds = { { 17, 47, 3.6, 3.0, 0.5 }, { 26, 45, 3.7, 3.1, -0.2 }, { 36, 42, 3.6, 3.0, 0.3 } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], 0, 0.7)
  -- D shape: shave the side the flat face points to
  local fx, fy = cos(s[5] + pi / 2), sin(s[5] + pi / 2)
  local cut = {}
  s.m:each(function(x, y) if (x - s[1]) * fx + (y - s[2]) * fy > s[4] * 0.62 then cut[#cut + 1] = K(x, y) end end)
  for _, k in ipairs(cut) do s.m.s[k] = nil end
end

-- torn sword-leaf strip
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 48, 57, 39, function(t) return 4.4 - 0.5 * t end, { fold = 0.22 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local j = X.hash(floor(s * 6), 3, 7)
  if LT[k] < 0.02 + 0.06 * j or LT[k] > 0.93 + 0.05 * X.hash(floor(s * 5), 9, 2) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- fan of sword leaves (drawn before seeds so the split seed coat sits over the fan foot)
local fans = {
  { { 34, 42 }, { 32, 34 }, { 29, 26 }, { 26, 19 } , 1.7 },
  { { 39, 42 }, { 42, 35 }, { 45, 29 }, { 48, 23 }, 1.6 },
  { { 36, 42 }, { 36, 28 }, { 36, 15 }, { 42, 11 }, 1.8 },          -- tallest, flopped tip
}
local fanm = {}
for i, f in ipairs(fans) do
  local m, n, T, S = A.tube({ f[1], f[2], f[3], f[4] }, function(t)
    if t > 0.97 then return 0.3 end return f[5] * (1 - t ^ 3 * 0.75) + 0.1 end)
  f.m, f.n, f.T, f.S = m, n, T, S
  fanm[i] = m
end
local fall = HP.mask()
for _, f in ipairs(fans) do fall:add(f.m) end
local lbias = {}
for _, s in ipairs(seeds) do X.ao(lbias, lm, s.m, 1, -1) A.cast(lbias, lm, s.m, 1, 2, -1) end
X.ao(lbias, lm, fall, 1, -1)
local ltok = { r = { name = "strip" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = lbias, tok = ltok, cuts = { 0.14, 0.3, 0.47, 0.63, 0.8 }, amb = 0.18, wrap = 0.3 })
-- parallel veins + a pale fold line
lm:each(function(x, y) local k = K(x, y)
  if lbias[k] then return end
  local sp = LS[k] * 5.0
  local r = floor(sp + 0.5)
  if (r == -3 or r == 2) and abs(sp - r) < 0.32 then c:put(x, y, VEIN, ltok) end
  if r == -1 and abs(sp - r) < 0.3 then c:put(x, y, LEAF[6], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not lbias[k] and LS[k] > 0.7 then c:put(x, y, COOL, ltok) end end)
-- torn ends: pale fibres
lm:edge():each(function(x, y) local k = K(x, y)
  if (LT[k] < 0.09 or LT[k] > 0.92) and abs(LS[k]) < 0.6 and X.hash(x, y, 4) > 0.45 then c:put(x, y, LEAF[5], ltok) end end)

-- fan: back leaves first, tallest last; sheath darker at the foot, AO where they overlap
local done = HP.mask()
for i, f in ipairs(fans) do
  local m = f.m:copy():cut(done)
  local bias = {}
  m:each(function(x, y) local k = K(x, y) if f.T[k] < 0.16 then bias[k] = -1 end end)
  if i == 3 then X.ao(bias, m, done, 1, -1) end
  local tok = { r = { name = "fan" .. i } }
  local idx = A.shade(c, m, f.n, FAN, { bias = bias, tok = tok, amb = 0.12, wrap = 0.3, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 } })
  -- keel line along each sword
  m:each(function(x, y) local k = K(x, y)
    if abs(f.S[k] + 0.05) < 0.2 and f.T[k] > 0.15 and f.T[k] < 0.92 then A.step(c, idx, FAN, x, y, 1, tok) end end)
  if i > 1 then A.sep(c, m, done, FAN[1], tok) end
  A.sep(c, m, lm, FAN[2], tok)
  done:add(m)
end
-- flopped tip: crease shadow where the tallest leaf bends
c:put(36, 15, FAN[2], { r = { name = "crease" } }) c:put(37, 14, FAN[3], { r = { name = "crease" } })

-- seeds: corky D-shapes with pitted coat, keel rim on the curved side, AO against neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { bias = sb, tok = tok, amb = 0.1, wrap = 0.2, cuts = { 0.16, 0.32, 0.5, 0.68, 0.85 } })
  -- flat face: one tone darker band along the shaved side
  local fx, fy = cos(s[5] + pi / 2), sin(s[5] + pi / 2)
  vis:each(function(x, y) local d = (x - s[1]) * fx + (y - s[2]) * fy
    if d > s[4] * 0.2 then A.step(c, idx, SEED, x, y, -1, tok) end end)
  -- cork pits
  vis:each(function(x, y) if X.hash(x, y, 11 + i) > 0.82 and (idx[K(x, y)] or 1) > 2 then A.step(c, idx, SEED, x, y, -2, tok) end end)
  -- glint
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[5], tok) end
  if i > 1 then A.sep(c, vis, seeds[i - 1].m, SEED[1], tok) end
end
-- split in the sprouting seed coat
c:put(36, 40, SEED[1], { r = { name = "split" } }) c:put(37, 40, SEED[2], { r = { name = "split" } })

A.save(c, NAME)
