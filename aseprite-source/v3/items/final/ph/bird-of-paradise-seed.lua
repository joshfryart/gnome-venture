-- bird-of-paradise-seed (final pass, Opus). Three glossy jet-black strelitzia seeds, each crowned with its bright
-- orange hairy aril tuft, on a torn scrap of blue-green strelitzia leaf (thick midrib, dense parallel side veins,
-- a split torn along the veins, V-fold light, cool edge, AO + contact shadow under the seeds). The right seed has
-- sprouted: a pale stem carrying a first paddle-shaped leaf (midrib, oblique veins) and a second leaf still
-- rolled into a twisted spike.
-- quirk: a loose curl of orange aril fluff has drifted off and sits on the leaf.
local NAME = "bird-of-paradise-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR20_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163538", "#1f4e4b", "#2c6a5a", "#438868", "#67a87a", "#9ccb92" }
local VEIN, COOL = "#b4dca4", "#3c6a80"
local SEED = { "#1c1520", "#2a2030", "#3b3044", "#52465c", "#74688a", "#b8acc8" }
local ARIL = { "#7c2420", "#b23c1c", "#e2621a", "#fb8c22", "#ffb648", "#ffe08a" }
local STEM = { "#4f8a5a", "#82b874", "#b6da98", "#e0f2c0" }
local CUTS = A.CUTS

-- seeds (cx, cy, rx, ry, angle)
local seeds = { { 17, 47, 3.4, 3.0, 0.3 }, { 27, 45, 3.5, 3.1, -0.2 }, { 39, 41, 3.4, 3.0, 0.1 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
local allSeed = HP.mask() for _, s in ipairs(seeds) do allSeed:add(s.m) end

-- leaf scrap: strelitzia blade on the diagonal, ragged torn base, tip torn square
local lm, ln, LT, LS, len = A.blade(8, 54, 30, 51, 56, 39, function(t)
  if t > 0.97 then return -1 end
  return max(0.5, 7.0 * sin(pi * min(1, t * 0.8 + 0.18)) ^ 0.55)
end, { fold = 0.42 })
-- tears along the veins: a long split on the lower side, a short nick on the upper side, ragged ends
local PER = 2.6
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local along = t * len - abs(s) * 3.2
  if s > 0.35 and abs(along - 24) < 0.55 then cut[#cut + 1] = k end
  if s < -0.55 and abs(along - 36) < 0.55 then cut[#cut + 1] = k end
  if t < 0.06 and abs(s) > 0.3 + X.hash(x, y, 5) * 0.5 then cut[#cut + 1] = k end
  if t > 0.9 and abs(s) > 0.75 - (t - 0.9) * 3 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local along = t * len - abs(s) * 3.2
  local f = along / PER - floor(along / PER)
  if f < 0.34 and abs(s) > 0.18 and abs(s) < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end end)
for _, q in ipairs{ { 7, 56, 3 }, { 6, 57, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: drifted curl of aril fluff on the leaf (with its contact shadow)
c:paint({ ".ab", "c.." }, 21, 51, { a = ARIL[5], b = ARIL[3], c = ARIL[4] })
c:put(22, 52, LEAF[1], ltok) c:put(23, 52, LEAF[1], ltok)

-- sprout stem
local stok = { r = { name = "stem" } }
local sm, sn = A.tube({ { 40, 40 }, { 39, 34 }, { 42, 29 }, { 41, 24 } }, function() return 1.0 end)
sm:cut(seeds[3].m)
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok, amb = 0.15, wrap = 0.3 })
-- rolled second leaf: twisted spike off the stem
local rm, rn, RT, RS = A.tube({ { 40, 31 }, { 37, 27 }, { 35, 22 }, { 33, 18 } }, function(t) return 1.4 * (1 - t) + 0.35 end)
rm:cut(sm)
local ridx = A.shade(c, rm, rn, LEAF, { tok = ltok, amb = 0.2, wrap = 0.3 })
rm:each(function(x, y) local k = K(x, y)
  if (floor(RT[k] * 11 + RS[k] * 1.2) % 2 == 0) and RT[k] > 0.08 then A.step(c, ridx, LEAF, x, y, -1, ltok) end end)
-- paddle leaf on the stem tip
local pm, pn, PT, PS = A.blade(41, 25, 44, 17, 53, 14, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 4.2 * sin(pi * min(1, t * 0.92 + 0.06)) ^ 0.6)
end, { fold = 0.36 })
pm:cut(sm)
A.shade(c, pm, pn, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y) local s, t = PS[k], PT[k]
  if abs(s) < 0.16 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok)
  elseif t > 0.1 and t < 0.9 then
    local along = t * 17 - abs(s) * 3.5
    local f = along / 3 - floor(along / 3)
    if f < 0.3 and abs(s) > 0.22 and abs(s) < 0.85 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
  end
end)
pm:edge():each(function(x, y) if PS[K(x, y)] > 0.6 then c:put(x, y, COOL, ltok) end end)
-- petiole highlight
for y = 25, 33 do if sm:has(40, y) then c:put(40, y, STEM[4], stok) end end

-- seeds: glossy black, cool reflected rim, one cream specular; AO between neighbours
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = sb, amb = 0.05, wrap = 0.15, cuts = { 0.15, 0.32, 0.5, 0.7, 0.9 } })
  local rim = X.rim(s.n)
  vis:each(function(x, y) local k = K(x, y) if rim[k] > 0.55 and (idx[k] or 1) <= 2 then c:put(x, y, "#4a5a7a", tok) end end)
  local bx, by = A.specAt(vis, s.n, 30)
  if bx then c:put(bx, by, A.CREAM, tok) c:put(bx + 1, by, SEED[6], tok) end
end

-- aril tufts: hairy orange crowns on the upper side of each seed (sprouted seed's tuft pushed to the left)
local function tuft(cx, cy, w, h)
  local m = A.rell(cx, cy, 1, 0, w, h)
  -- hair tips: little spikes on top
  for i = -2, 2 do local x = floor(cx + i * w / 2.4 + 0.5) local ty = floor(cy - h - 0.5)
    if i % 2 == 0 then m:set(x, ty) end end
  local n = X.pillow(m, 1.6)
  local tok = { r = { name = "aril" } }
  local idx = A.shade(c, m, n, ARIL, { tok = tok, amb = 0.2, wrap = 0.35 })
  m:each(function(x, y) if (x * 2 + y) % 3 == 0 and m:has(x, y + 1) then A.step(c, idx, ARIL, x, y, -1, tok) end end)
  return m
end
tuft(16, 44, 3.2, 1.8)
tuft(27, 42, 3.4, 1.9)
tuft(36, 39, 2.2, 1.6)

A.save(c, NAME)
