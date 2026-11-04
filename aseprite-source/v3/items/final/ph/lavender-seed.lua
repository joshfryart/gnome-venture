-- lavender-seed (final, Opus single pass). Three tiny glossy near-black lavender seeds (oblong, one bright glint each,
-- AO + contact shadow) on a torn sage-green leaf scrap (midrib, veins, ragged pale torn end, cool edge). The right seed
-- has germinated: thin stem, two round cotyledons, then two pairs of narrow silvery linear lavender leaves.
-- quirk: the seedling is already showing a tiny violet flower spike at its tip, far too early.
local NAME = "lavender-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#1d3b34", "#2a5444", "#3f7052", "#5c8d62", "#86ad78", "#b5d29a" }
local SIL = { "#24413f", "#3a6058", "#5a8576", "#80a896", "#acc9b8", "#d9ecdc" }
local SEED = { "#1e1418", "#33201f", "#4c2f28", "#6b4433", "#8e6447", "#c09878" }
local VIO = { "#3a2560", "#5a3a8e", "#7e5cc0", "#a585e0", "#cdb6f6" }
local STEM = { "#3f6a52", "#6a9878", "#9cc4a2", "#d0e8cc" }
local TORN, COOL = "#d6e4b0", "#3a6c72"

-- seeds
local seeds = { { 18, 49, 3.4, 1.9, -0.25 }, { 27, 47, 3.3, 1.9, 0.35 }, { 39, 42, 3.2, 1.8, -0.5 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.7) end

-- leaf scrap: broad blade on the diagonal, tip torn away (ragged end), one bite out of the upper edge
local lm, ln, LT, LS, len = A.blade(7, 55, 30, 52, 57, 38, function(t)
  return max(0.6, 9.0 * sin(pi * min(1, t * 0.62 + 0.06)) ^ 0.6)
end, { fold = 0.4 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local lim = 0.8 + 0.05 * ((floor((s + 1) * 3.5) % 2 == 0) and 1 or 0) + 0.03 * X.hash(x, y, 3)
  if t > lim then lm.s[k] = nil end
  -- bite on the upper (lit) edge
  if s < -0.55 and t > 0.33 and t < 0.43 and s < -0.55 - 0.4 * (1 - abs(t - 0.38) / 0.05) then lm.s[k] = nil end
end)
lm:each(function(x, y) local k = K(x, y) if LT[k] > 0.74 then torn[k] = true end end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.03 and t < 0.8 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  local d = (t * len - abs(s) * 6.5) % 5.2
  if d < 0.85 and abs(s) > 0.18 and abs(s) < 0.78 and t > 0.06 and t < 0.76 then
    c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
end)
local edge = lm:edge()
edge:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] > 0.77 then c:put(x, y, TORN, ltok)          -- fibrous torn end
  elseif LS[k] > 0.62 and LT[k] > 0.08 then c:put(x, y, COOL, ltok) end end)
-- petiole stub
for _, q in ipairs{ { 6, 56, 3 }, { 5, 57, 2 }, { 4, 58, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout from the right seed
local stok = { r = { name = "stem" } }
local sp = { { 40, 41 }, { 39, 34 }, { 41, 28 }, { 40, 18 } }
local sm = A.tube(sp, function() return 0.95 end)
sm:cut(seeds[3].m)
local _, sn = A.tube(sp, function() return 0.95 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: small rounded paddles low on the stem
local ctok = { r = { name = "coty" } }
local function paddle(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.5)
  end, { fold = 0.25 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ctok, cuts = A.CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.15 and T[k] < 0.7 then c:put(x, y, LEAF[5], ctok) end end)
  return m
end
local cotL = paddle(39, 33, 35, 32, 31, 33, 2.1)
local cotR = paddle(41, 33, 45, 32, 49, 33, 2.1)
-- true leaves: narrow linear silvery blades, opposite pairs angled up
local ttok = { r = { name = "true" } }
local function needle(ax, ay, bx, by, w)
  local cx, cy = (ax + bx) / 2 + (by - ay) * 0.08, (ay + by) / 2 - 1
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.45, w * sin(pi * min(1, t * 0.85 + 0.1)) ^ 0.35)
  end, { fold = 0.5 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, SIL, { tok = ttok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if S[k] > 0.35 then c:put(x, y, SIL[max(1, (idx[k] or 3) - 1)], ttok) end            -- rolled-under edge
    if abs(S[k]) < 0.12 and T[k] > 0.1 and T[k] < 0.8 then c:put(x, y, SIL[6], ttok) end  -- pale midrib
  end)
  return m
end
needle(40, 27, 31, 21, 1.5)
needle(41, 27, 50, 21, 1.5)
needle(40, 22, 34, 15, 1.25)
needle(41, 22, 47, 15, 1.25)
-- quirk: tiny violet flower spike (stacked whorls) on the tip
local vtok = { r = { name = "flower" } }
local spike = {
  { 40, 17, 2 }, { 41, 17, 1 },
  { 39, 16, 3 }, { 40, 16, 4 }, { 41, 16, 2 },
  { 40, 15, 2 },
  { 39, 14, 3 }, { 40, 14, 5 }, { 41, 14, 2 },
  { 40, 13, 3 }, { 40, 12, 4 }, { 40, 11, 5 },
}
for _, q in ipairs(spike) do c:put(q[1], q[2], VIO[q[3]], vtok) end
c:put(40, 18, STEM[2], stok)

-- seeds last: glossy oblongs, AO where they touch
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.1, wrap = 0.25 }), SEED, { cuts = { 0.2, 0.36, 0.52, 0.7, 0.9 }, bias = sb, tok = tok })
  -- groove along the seed (a darker line on the lower half)
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if v > 0.4 and v < 1.3 and abs(u) < s[3] - 1 then c:put(x, y, SEED[max(1, (idx[K(x, y)] or 3) - 1)], tok) end
  end)
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, SEED[6], tok) c:put(gx + 1, gy, SEED[5], tok) end
end
c:put(38, 40, "#fff4d6", { r = { name = "seed3" } })  -- one cream glint

A.save(c, NAME)
