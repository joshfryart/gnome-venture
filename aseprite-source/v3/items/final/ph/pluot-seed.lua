-- pluot-seed (final pass, Opus). Two pluot stones (flattened almond-shaped plum pits: rose-tan, pitted and wrinkled,
-- a raised keel along the suture rim, pointed tip) on a torn scrap of pluot leaf (elliptic, finely serrated margin,
-- midrib + paired veins, V-fold light, cool reflected edge, AO + contact shadow under each stone). The right stone has
-- cracked along its suture and germinated: a pale stem with two fleshy rounded cotyledons and the first true leaf,
-- an elliptic serrated plum leaf in red-bronze new growth.
-- History: Sonnet draft (dC35) replaced.
-- quirk: a last scrap of red pluot flesh still clings to the tip of the left stone.
local NAME = "pluot-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF  = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local BRONZE = { "#3e1a2a", "#62263a", "#8a3a3e", "#b05a40", "#d0864e", "#eab070" }
local VEIN, COOL = "#c2e48c", "#3a6c72"
local PIT   = { "#3a1e24", "#5c3230", "#80503e", "#a47052", "#c6966c", "#e6c296" }
local STEM  = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local COTY  = { "#2e5a3a", "#4a7e44", "#6ea250", "#98c260", "#c4dc80", "#e6f0b0" }
local FLESH = { "#7a1830", "#b52e3f", "#e8493b" }
local CUTS = A.CUTS

-- leaf scrap: elliptic plum leaf lying on the diagonal, torn off at the base
local lm, ln, LT, LS, len = A.blade(7, 54, 30, 53, 57, 41, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.4 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.75)
end, { fold = 0.4 })
-- torn base: ragged bite
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local tear = 0.07 + 0.05 * X.hash(floor(s * 6), 3, 7)
  if t < tear then lm.s[k] = nil end
end)
-- fine serration: drop one rim px every 3 along t
lm:edge():each(function(x, y) local k = K(x, y)
  local ph = floor(LT[k] * len / 2.6)
  if abs(LS[k]) > 0.7 and ph % 2 == 0 and LT[k] > 0.15 and LT[k] < 0.95 then lm.s[k] = nil end
end)

local seeds = { { 21, 48, 6.2, 3.6, -0.22 }, { 37, 44, 5.4, 3.3, -0.55 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end
-- pointed tip on each stone (toward +u)
for _, s in ipairs(seeds) do
  local ca, sa = cos(s[5]), sin(s[5])
  local tx, ty = s[1] + (s[3] + 1.2) * ca, s[2] + (s[3] + 1.2) * sa
  s.tip = { floor(tx + 0.5), floor(ty + 0.5) }
  s.m:set(s.tip[1], s.tip[2])
  s.n[K(s.tip[1], s.tip[2])] = { A.norm(ca, sa, 0.6) }
end

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.05 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- paired pinnate veins swept toward the tip
  local ph = (t * len - abs(s) * 5.0) / 5.2
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.18 and abs(s) < 0.72 and t > 0.1 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.12 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- sprout from the right stone's upper end
local stok = { r = { name = "stem" } }
local sp = { { 40, 41 }, { 41, 35 }, { 39, 29 }, { 39, 22 } }
local sm, sn = A.tube(sp, function(t) return 1.1 end)
sm:cut(seeds[2].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- two fleshy rounded cotyledons (plum cotyledons are thick paddles)
local ctok = { r = { name = "coty" } }
local function coty(cx2, cy2, ang)
  local m, n = A.oval(cx2, cy2, 4.2, 2.6, ang, 0.7)
  m:cut(sm)
  local idx = A.shade(c, m, n, COTY, { tok = ctok, amb = 0.12, wrap = 0.3 })
  return m, idx
end
local cl = coty(34, 28, 0.35)
local cr = coty(45, 27, -0.3)
-- crease on each cotyledon
for _, p in ipairs{ { 32, 27 }, { 33, 28 }, { 35, 28 }, { 44, 27 }, { 45, 27 }, { 47, 26 } } do c:put(p[1], p[2], COTY[3], ctok) end
-- first true leaf: elliptic, serrated, pointed, bronze new growth
local tm, tn, TT, TS, tlen = A.blade(39, 23, 37, 15, 44, 8, function(t)
  if t > 0.98 then return -1 end
  return max(0.4, 3.4 * sin(pi * min(1, t * 0.95 + 0.05)) ^ 0.8)
end, { fold = 0.45 })
tm:cut(cl):cut(cr)
tm:edge():each(function(x, y) local k = K(x, y)
  if abs(TS[k]) > 0.6 and floor(TT[k] * tlen / 2) % 2 == 1 and TT[k] > 0.2 and TT[k] < 0.9 then tm.s[k] = nil end end)
local btok = { r = { name = "trueleaf" } }
A.toneN(c, tm, tn, BRONZE, { tok = btok, cuts = CUTS, amb = 0.12, wrap = 0.3 })
tm:each(function(x, y) local k = K(x, y)
  if abs(TS[k]) < 0.15 and TT[k] > 0.08 and TT[k] < 0.86 then c:put(x, y, TS[k] <= 0 and BRONZE[6] or BRONZE[3], btok) end end)
-- stem to the leaf
for i = 0, 12 do local x, y = A.bez(sp, 1 - i / 60) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end

-- stones: pitted wrinkled surface, keel along the upper rim, suture crack on the sprouting one
local SC = { 0.18, 0.34, 0.5, 0.66, 0.84 }
for i, s in ipairs(seeds) do
  local tok = { r = { name = "pit" .. i } }
  local idx = A.shade(c, s.m, s.n, PIT, { tok = tok, cuts = SC, amb = 0.06, wrap = 0.22 })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    -- keel: lit ridge just inside the upper rim, groove under it
    if v < -0.55 and v > -0.85 and abs(u) < 0.8 then A.step(c, idx, PIT, x, y, 1, tok) end
    if v >= -0.55 and v < -0.32 and abs(u) < 0.7 then A.step(c, idx, PIT, x, y, -1, tok) end
    -- wrinkles: short worm-like pits
    local h = X.hash(x, y, 11 + i)
    if v > -0.2 and abs(u) < 0.85 and h > 0.8 then A.step(c, idx, PIT, x, y, -1, tok) end
    if v > -0.2 and abs(u) < 0.7 and h < 0.07 then A.step(c, idx, PIT, x, y, 1, tok) end
  end)
  -- glint
  local gx, gy = floor(s[1] - 2.5 * ca + 1.4 * sa + 0.5), floor(s[2] - 2.5 * sa - 1.4 * ca + 0.5)
  if s.m:has(gx, gy) then c:put(gx, gy, "#fff0cc", tok) end
end
-- sprouting stone: suture split at the upper end, sprout foot inside
for _, p in ipairs{ { 39, 41, 1 }, { 40, 41, 1 }, { 40, 40, 2 }, { 41, 40, 1 }, { 39, 42, 2 } } do c:put(p[1], p[2], PIT[p[3]], { r = { name = "pit2" } }) end
c:put(40, 41, STEM[2], stok) c:put(40, 40, STEM[3], stok)

-- quirk: red flesh scrap on the left stone's tip
local ftok = { r = { name = "flesh" } }
local tx, ty = seeds[1].tip[1], seeds[1].tip[2]
for _, p in ipairs{ { -1, -1, 3 }, { 0, -1, 2 }, { -1, 0, 2 }, { 0, 0, 1 }, { -2, -1, 2 } } do c:put(tx + p[1], ty + p[2], FLESH[p[3]], ftok) end

A.save(c, "ph", NAME)
