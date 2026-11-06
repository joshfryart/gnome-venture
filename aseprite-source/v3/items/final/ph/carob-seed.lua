-- carob-seed (final, Opus single pass). Three carob seeds (flat glossy ovals, dark mahogany, a pale hilum notch at
-- one end) on a torn scrap of carob leaflet (leathery oval, notched tip, ragged torn base, midrib + paired veins,
-- V-fold light, cool reflected edge, AO + contact shadow under each seed). The right seed has germinated: pale
-- radicle, a green stem, two fleshy oval cotyledons and a first pinnate true leaf with two pairs of rounded leaflets
-- (the carob leaf in miniature).
-- quirk: a single dewdrop sits on the leaf scrap, catching the light.
local NAME = "carob-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163a33", "#1f533d", "#2b6e43", "#3f8a47", "#62a650", "#93c464" }
local VEIN, COOL = "#b6d987", "#386a70"
local SEED = { "#260f16", "#45191b", "#6a2a22", "#8e3f2a", "#b65e38", "#de8a52" }
local STEM = { "#3f7a4a", "#72aa5e", "#a8d080", "#d8eeb0" }
local COT = { "#355f2c", "#4f8636", "#6fa640", "#94c254", "#bcdc74", "#e0f0a4" }
local ROOT = { "#b8a68a", "#e2d6b8", "#fbf3dc" }
local DROP = { "#3a86b0", "#5fc4c8", "#b6f0e0", "#f2fffa" }
local CUTS = A.CUTS

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 16, 46, 4.3, 2.9, 0.25 }, { 27, 49, 4.4, 3.0, -0.1 }, { 39, 44, 4.0, 2.8, -0.55 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.55) end

-- leaf scrap: oval carob leaflet, rounded notched tip at the right, torn base at the left
local lm, ln, LT, LS, len = A.blade(6, 49, 30, 55, 57, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.2 * sin(pi * min(1, 0.22 + t * 0.8)) ^ 0.55)
end, { fold = 0.35 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  -- ragged torn base: zigzag cut line across the blade
  local tear = 0.1 + 0.035 * sin(s * 11) + 0.025 * X.hash(floor(s * 6), 3, 1)
  if t < tear then cut[#cut + 1] = k end
  -- notched (emarginate) tip
  if t > 0.95 and abs(s) < 0.22 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = A.tok("leaf")
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.08 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- paired veins sweeping toward the tip
  local ph = (t * len - abs(s) * 7) / 6.5
  local f = ph - floor(ph)
  if f > 0.86 and abs(s) > 0.14 and abs(s) < 0.78 and t > 0.12 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.7 and LT[k] > 0.2 and LT[k] < 0.86 then c:put(x, y, COOL, ltok) end
  -- torn edge: pale broken fibres
  if LT[k] < 0.17 and X.hash(x, y, 5) > 0.45 then c:put(x, y, LEAF[5], ltok) end
end)

-- radicle: pale root from the sprouting seed, curling over the leaf
local rtok = A.tok("root")
local rm, rn = A.tube({ { 42, 46 }, { 45, 49 }, { 47, 51 }, { 46, 54 } }, function(t) return 1.0 - t * 0.5 end)
rm:cut(seeds[3].m)
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.7 }, tok = rtok })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- stem
local stok = A.tok("stem")
local sp = { { 38, 42 }, { 36, 35 }, { 39, 30 }, { 38, 22 } }
local sm, sn = A.tube(sp, function(t) return 1.1 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: fleshy rounded ovals
local ctok = A.tok("cot")
local cots = HP.mask()
for _, q in ipairs{ { 33.5, 29, 4.0, 2.2, 0.35 }, { 43, 28, 4.0, 2.2, -0.4 } } do
  local m, n = A.oval(q[1], q[2], q[3], q[4], q[5], 0.7)
  m:cut(sm)
  local cb = {}
  X.ao(cb, m, sm, 1, -1)
  A.shade(c, m, n, COT, { tok = ctok, bias = cb, amb = 0.12, wrap = 0.3 })
  local sx, sy = A.specAt(m, n, 30)
  if sx then c:put(sx, sy, COT[6], ctok) end
  cots:add(m)
end
-- first true leaf: rachis + two pairs of rounded leaflets + a terminal pair
local rach = { { 38, 23 }, { 38, 19 }, { 39, 15 }, { 40, 12 } }
local tl = HP.mask()
local tn = {}
for _, q in ipairs{ { 0.25, -1 }, { 0.25, 1 }, { 0.8, -1 }, { 0.8, 1 } } do
  local x, y = A.bez(rach, q[1])
  local ang = q[2] < 0 and (pi + 0.35) or -0.35
  local cx, cy = x + cos(ang) * 3.4, y + sin(ang) * 3.4 - 0.4
  local m, n = A.oval(cx, cy, 3.1, 1.8, ang, 0.8)
  for k, v in pairs(n) do tn[k] = v end
  tl:add(m)
end
tl:cut(cots)
local tb = {}
X.ao(tb, tl, sm, 1, -1)
A.shade(c, tl, tn, LEAF, { tok = ltok, bias = tb, amb = 0.14, wrap = 0.3 })
-- leaflet midribs
tl:each(function(x, y) end)
for i = 0, 24 do local x, y = A.bez(rach, i / 24) c:put(floor(x + .5), floor(y + .5), i < 3 and STEM[2] or STEM[3], stok) end
c:put(40, 11, STEM[2], stok)

-- seeds last: glossy flat ovals with a hilum notch, AO between neighbours
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  local sb = {}
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, bias = sb, amb = 0.08, wrap = 0.25, cuts = { 0.16, 0.32, 0.48, 0.64, 0.84 } })
  -- satin band: a lighter ring just inside the lit rim
  s.m:edge():each(function(x, y) local k = K(x, y) if idx[k] and idx[k] >= 4 then c:put(x, y, SEED[idx[k] - 1], tok) end end)
  -- hilum: small pale notch at the lower-right end of the long axis
  local ca, sa = cos(s[5]), sin(s[5])
  local hx, hy = floor(s[1] + ca * (s[3] - 0.6) + .5), floor(s[2] + sa * (s[3] - 0.6) + .5)
  if s.m:has(hx, hy) then c:put(hx, hy, "#e8c48a", tok) end
  if s.m:has(hx - 1, hy) then c:put(hx - 1, hy, SEED[1], tok) end
  -- glossy specular + a 2 px streak
  local gx, gy = A.specAt(s.m, s.n, 60)
  c:put(gx, gy, A.CREAM, tok)
  if s.m:has(gx + 1, gy) then c:put(gx + 1, gy, SEED[6], tok) end
end

-- quirk: dewdrop on the leaf (glass: dark lower rim, pale core, bright glint, cast shadow)
local dtok = A.tok("drop")
local dx, dy = 50, 46
for _, q in ipairs{ { 1, 2 }, { 2, 2 }, { 2, 1 }, { 3, 1 } } do c:put(dx + q[1], dy + q[2], LEAF[1], ltok) end
local drop = {
  ".bb.",
  "bdcb",
  "bcca",
  ".aa.",
}
local DM = { a = DROP[1], b = DROP[2], c = DROP[3], d = DROP[4] }
for yy, row in ipairs(drop) do for xx = 1, #row do local ch = row:sub(xx, xx)
  if DM[ch] then c:put(dx + xx - 2, dy + yy - 3, DM[ch], dtok) end end end
A.save(c, NAME)
