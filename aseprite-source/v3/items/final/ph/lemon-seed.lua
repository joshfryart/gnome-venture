-- lemon-seed (final pass, Opus). Three plump cream lemon pips (pointed teardrops with a faint ridge) on a torn
-- scrap of glossy lemon leaf (elliptic, smooth edge, V-fold light, pale midrib and side veins, a ragged torn end
-- showing pale tissue, cool reflected lower edge, AO + contact shadow under each pip). The front-right pip has
-- germinated: a pale root down over the leaf and a green stem carrying two glossy, pointed lemon leaves with
-- midribs and a tiny terminal bud.
-- quirk: the seedling already grows one sharp little citrus thorn on its stem.
-- History: Sonnet draft (_dC20) replaced.
local NAME = "lemon-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC20_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#123a30", "#1d5638", "#2c7440", "#469646", "#71b655", "#a6d474" }
local VEIN, COOL, TORN = "#c8e692", "#3a6c72", "#d6eca4"
local SEED = { "#6d5233", "#9c7e52", "#c4a874", "#e0cb98", "#f2e2b8", "#fff6dc" }
local STEM = { "#3f7a44", "#6aa95a", "#9fcf78", "#d6efb0" }
local ROOT = { "#b39a74", "#e2d2b0", "#fbf1d8" }

-- seeds: cx, cy, rx, ry, angle (tip points along +u)
local seeds = { { 17, 47, 4.2, 2.4, 0.25 }, { 27, 47.5, 4.2, 2.4, -0.35 }, { 37, 42, 4.0, 2.3, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8)
  -- pointed tip
  local tx, ty = s[1] + cos(s[5]) * (s[3] + 1.3), s[2] + sin(s[5]) * (s[3] + 1.3)
  s.tip = { floor(tx + 0.5), floor(ty + 0.5) }
  s.m:set(s.tip[1], s.tip[2]) s.n[K(s.tip[1], s.tip[2])] = { A.norm(cos(s[5]), sin(s[5]), 0.6) }
end

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(8, 53, 30, 51, 55, 38, function(t)
  local u = min(1, t * 0.9 + 0.06)
  return max(0.5, 9.0 * sin(pi * u) ^ 0.55)
end, { fold = 0.4 })
-- torn end: ragged line across the blade near the tip
local torn = {}
lm:each(function(x, y) local k = K(x, y)
  local lim = 0.8 + 0.05 * sin(LS[k] * 7.0) + 0.035 * (X.hash(x, y, 3) - 0.5)
  if LT[k] > lim then torn[#torn + 1] = k end
end)
for _, k in ipairs(torn) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
-- midrib + pinnate veins (lemon: fine, looping toward the margin)
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 6.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.06 then c:put(x, y, s < 0 and LEAF[6] or LEAF[3], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.66 and LT[k] > 0.08 and LT[k] < 0.76 then c:put(x, y, COOL, ltok) end end)
-- pale tissue along the torn edge
lm:each(function(x, y) local k = K(x, y)
  if LT[k] > 0.7 and (not lm:has(x + 1, y) or not lm:has(x, y - 1)) and not lm:has(x + 1, y - 1) then c:put(x, y, TORN, ltok) end end)
-- glossy leaf glint
c:put(15, 48, LEAF[6], ltok) c:put(14, 48, "#e4f5b8", ltok)
-- petiole stub
for _, q in ipairs{ { 7, 54, 3 }, { 6, 55, 2 }, { 5, 56, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- root from the sprouting seed, down-right over the leaf
local rp = { { 38, 46 }, { 40, 49 }, { 43, 51 }, { 46, 53 } }
local rm, rn = A.tube(rp, function(t) return 1.1 * (1 - t) + 0.35 end)
rm:cut(seeds[3].m)
local rtok = { r = { name = "root" } }
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), ROOT, { cuts = { 0.35, 0.7 }, tok = rtok })
rm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not rm:has(x, y) and not seeds[3].m:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)

-- stem
local stok = { r = { name = "stem" } }
local sp = { { 37, 39 }, { 36, 32 }, { 38, 25 }, { 37, 17 } }
local sm, sn = A.tube(sp, function(t) return 1.1 - 0.25 * t end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- quirk: thorn at a node (pointing up-right)
c:put(39, 28, STEM[2], stok) c:put(40, 27, STEM[1], stok) c:put(41, 26, STEM[3], stok)

-- two lemon leaves: elliptic, pointed tip, short winged petiole
local function lemleaf(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t < 0.08 then return 0.6 end
    if t > 0.985 then return -1 end
    local u = (t - 0.08) / 0.92
    return max(0.3, W * sin(pi * min(1, u ^ 0.85)) ^ 0.7)
  end, { fold = 0.4 })
  m:cut(sm)
  local idx = A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.16 and T[k] > 0.05 and T[k] < 0.88 then c:put(x, y, S[k] <= 0 and VEIN or LEAF[3], ltok) end end)
  local bx0, by0 = A.specAt(m, n, 30)
  if bx0 then c:put(bx0, by0, "#e4f5b8", ltok) end
  return m
end
local L1 = lemleaf(36, 22, 29, 17, 20, 17, 3.4)
local L2 = lemleaf(38, 19, 45, 13, 53, 13, 3.6)
-- terminal bud
c:put(37, 16, STEM[3], stok) c:put(37, 15, STEM[4], stok) c:put(36, 16, STEM[2], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  if i == 3 then X.ao(sb, s.m, sm, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.toneN(c, vis, s.n, SEED, { tok = tok, bias = sb, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, amb = 0.12, wrap = 0.3 })
  -- faint ridge along the back (shade side of the long axis)
  local ca, sa = cos(s[5]), sin(s[5])
  for u = -2, 2 do
    local x = floor(s[1] + u * ca + 0.9 * (-sa) * (((-sa) + ca) > 0 and -1 or 1) + 0.5)
    local y = floor(s[2] + u * sa + 0.9 * ca * (((-sa) + ca) > 0 and -1 or 1) + 0.5)
    if vis:has(x, y) then A.step(c, idx, SEED, x, y, -1, tok) end
  end
  local gx, gy = A.specAt(vis, s.n, 40)
  if gx then c:put(gx, gy, SEED[6], tok) if vis:has(gx + 1, gy) then c:put(gx + 1, gy, SEED[6], tok) end end
end

A.save(c, "ph", NAME)
