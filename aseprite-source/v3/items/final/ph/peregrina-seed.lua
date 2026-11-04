-- peregrina-seed (final, Opus aC33_1). Two plump oval peregrina (Jatropha integerrima) seeds, mottled grey-brown with
-- dark flecks and a pale cream caruncle at the tip, lying on a torn glossy fiddle-shaped leaf scrap (waisted outline,
-- pale midrib, looping veins, waxy specular, cool reflected edge, AO + contact shadow). A third seed has split open:
-- a pale hooked stem lifts one fiddle-shaped true leaf above two round cotyledons.
-- quirk: a single fallen coral-red peregrina petal lies on the leaf beside the seeds.
local NAME = "peregrina-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC33_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local LEAF = { "#14352f", "#1f5440", "#2c7348", "#3f9150", "#64b05a", "#a2d67a" }
local COOL = "#36687a"
local SEED = { "#231a20", "#3e3236", "#5e5050", "#857464", "#ab9a80", "#d6c8a8" }
local CAR = { "#b49a6a", "#e2cc98", "#fff0c8" }
local STEM = { "#4a7a4a", "#7cae66", "#b2d68e", "#e0f0bc" }
local RED = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }

-- seeds: cx, cy, rx, ry, angle (big, plump)
local seeds = { { 22, 45, 5.2, 3.4, 0.35 }, { 33, 49, 5.0, 3.3, -0.2 }, { 44, 44, 4.4, 3.0, -0.9 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.75) end

-- leaf scrap: fiddle-shaped (waisted) blade rising to the upper right, torn across the lower-left end
local lm, ln, LT, LS, len = A.blade(8, 52, 26, 50, 57, 33, function(t)
  if t > 0.985 then return -1 end
  local w = 9.0 * sin(pi * min(1, 0.32 + t * 0.7)) ^ 0.7
  w = w * (1 - 0.28 * math.exp(-((t - 0.5) / 0.12) ^ 2))  -- the fiddle waist
  return max(0.5, w)
end, { fold = 0.3 })
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  if LT[k] < 0.1 then
    local j = ({ 1, 3, 2, 0, 2, 3, 1, 2, 0, 3, 1, 2, 3, 0, 1, 2 })[(x + y) % 16 + 1]
    if LT[k] * len < j + 0.4 then torn[#torn + 1] = k end
  end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) A.cast(bias, lm, s.m, 2, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
-- veins: pale midrib, laterals looping toward the margin
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local s, t, i = LS[k], LT[k], lidx[k] or 3
  if abs(s) < 0.12 and t > 0.08 and t < 0.95 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  if t > 0.1 and t < 0.9 and abs(s) > 0.18 and abs(s) < 0.72 then
    local d = (t * len - abs(s) ^ 1.1 * 6.5) % 6.5
    if d < 0.85 then c:put(x, y, s < 0 and LEAF[min(6, i + 1)] or LEAF[max(1, i - 1)], ltok) end
  end
end)
-- waxy specular streak along the lit half, cool edge on the shade half, pale torn fibres
local sp = { { 40, 36 }, { 41, 36 }, { 42, 35 }, { 43, 35 }, { 44, 34 } }
for _, p in ipairs(sp) do if lm:has(p[1], p[2]) and not bias[K(p[1], p[2])] then c:put(p[1], p[2], "#d2f0a0", ltok) end end
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.68 and LT[k] > 0.12 and LT[k] < 0.92 then c:put(x, y, COOL, ltok) end
  if LT[k] < 0.1 then c:put(x, y, (x % 2 == 0) and LEAF[5] or "#c6e298", ltok) end end)

-- quirk: fallen coral-red petal (oval, notched tip) on the leaf
local ptok = { r = { name = "petal" } }
local pet = { "..11.", ".1232", "12332", "1223.", ".11.." }
A.map(c, pet, 43, 34, { ["1"] = RED[2], ["2"] = RED[3], ["3"] = RED[4] }, ptok)
c:put(44, 35, "#ffc4a0", ptok)
for _, p in ipairs{ { 44, 39 }, { 45, 39 }, { 46, 38 } } do if lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[1], ltok) end end

-- sprout from the split right seed: hooked stem, two round cotyledons, one fiddle-shaped true leaf
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 44, 42 }, { 42, 33 }, { 34, 28 }, { 33, 18 } }, function(t) return 1.05 end, STEM, { tok = stok, cut = seeds[3].m })
local cot = HP.mask()
for _, q in ipairs{ { 37, 29, 33, 30, 28, 31 }, { 37, 29, 40, 26, 44, 25 } } do
  local m, n = A.blade(q[1], q[2], q[3], q[4], q[5], q[6], function(t) if t > 0.97 then return -1 end return max(0.5, 2.6 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.4) end, { fold = 0.15 })
  m:cut(sm) cot:add(m)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
end
-- fiddle true leaf at the stem tip, leaning left
local tl, tT, tS, tidx = A.leaf(c, 33, 18, 28, 13, 22, 9, 3.6, LEAF, { cut = sm, vs = 3, fold = 0.5, tok = ltok,
  wfn = function(t) if t > 0.98 then return -1 end
    local w = 3.8 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.6
    return max(0.4, w * (1 - 0.3 * math.exp(-((t - 0.45) / 0.12) ^ 2))) end })
-- stem tip pixel and tiny bud
c:put(33, 17, STEM[3], stok) c:put(34, 16, LEAF[5], ltok) c:put(35, 15, RED[3], ptok)

-- seeds last: mottled coat, dark flecks, cream caruncle, glossy spec
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then vis:cut(sm) end
  local tok = { r = { name = "seed" .. i } }
  local v = X.light(s.n, { amb = 0.1, wrap = 0.25 })
  local idx = X.tone(c, vis, v, SEED, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, bias = sb, tok = tok })
  vis:each(function(x, y) local k = K(x, y) local h = X.hash(x, y, i)
    if h < 0.16 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok)
    elseif h > 0.9 and idx[k] >= 3 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end end)
  -- caruncle at the leading end
  local ca, sa = cos(s[5]), sin(s[5])
  local qx, qy = floor(s[1] + (s[3] - 0.2) * ca + 0.5), floor(s[2] + (s[3] - 0.2) * sa + 0.5)
  if i ~= 3 then c:put(qx, qy, CAR[2], tok) c:put(qx, qy + 1, CAR[1], tok) c:put(qx - 1, qy, CAR[3], tok) end
  -- spec glint upper-left
  local gx, gy = A.specAt(vis, s.n, 30)
  if gx then c:put(gx, gy, "#f4ecd6", tok) c:put(gx + 1, gy, SEED[6], tok) end
end
-- split line on the sprouting seed
for _, p in ipairs{ { 42, 45 }, { 43, 44 }, { 45, 42 } } do c:put(p[1], p[2], SEED[1], { r = { name = "seed3" } }) end
A.save(c, NAME)
