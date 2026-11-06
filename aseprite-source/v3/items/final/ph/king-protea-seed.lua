-- king-protea-seed (final, Opus single pass). Three king protea nutlets (dark ovoid achenes shaggy with tawny
-- hairs, a hair tuft at one end) on a torn scrap of leathery protea leaf (glaucous grey-green, red margin, pale
-- midrib + swept veins, ragged torn end with pale fibre, AO + contact shadow under each seed). The right nutlet has
-- split and sprouted: a red-tinged stem, two fleshy oblong cotyledons and two spoon-shaped protea true leaves on long
-- petioles (red rim, midrib).
-- quirk: the seedling already wears a tiny pink protea crown bud on its tip.
local NAME = "king-protea-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_2.lua")
local G, HP, X, K = A, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)

local LEAF = { "#1e3a3a", "#2c5450", "#3f7064", "#5a8e78", "#7fae90", "#acccaa" }
local RIM, RIMHI, VEIN, FIBRE = "#a23a48", "#d8606a", "#c8dcb0", "#e4ecc4"
local SEED = { "#2e1a1a", "#4a2a22", "#6a3e2a", "#8c5634", "#ad7444", "#cc9658" }
local HAIR = { "#9a6e40", "#d2a86c", "#f2d8a0" }
local STEM = { "#5a2a34", "#8a3e44", "#b85a56", "#dc8270" }
local COT = { "#24544a", "#3f9150", "#5aa85a", "#7cc35a", "#a4d878", "#d0ec9c" }
local PINK = { "#6a1e44", "#9e2e5a", "#cc4a74", "#ec7896", "#ffa8c0", "#ffd6e2" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 18, 48, 3.6, 2.3, -0.35 }, { 28, 46, 3.4, 2.2, 0.25 }, { 40, 44, 3.2, 2.2, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: leathery oblong blade lying on the diagonal, torn off at the left end
local lm, ln, LT, LS, len = G.blade(8, 51, 30, 53, 55, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 7.0 * sin(pi * min(1, t * 0.82 + 0.18)) ^ 0.55)
end, { fold = 0.3 })
local tear, cut = {}, {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local e = 1.5 + 3.2 * abs(((s * 3.1 + 7) % 2) - 1) + 1.2 * X.hash(floor(s * 6), 1, 3)
  if t * len < e then cut[#cut + 1] = k elseif t * len < e + 1.3 then tear[k] = true end
  if s < -0.72 and t > 0.58 and t < 0.66 then cut[#cut + 1] = k end    -- small nibble out of the upper edge
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.16, wrap = 0.3 })
local edge = lm:edge()
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if tear[k] then c:put(x, y, FIBRE, ltok) return end
  if edge:has(x, y) and t > 0.08 then c:put(x, y, s < 0 and RIMHI or RIM, ltok) return end
  if abs(s) < 0.13 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5) / 6.5
  local f = ph - floor(ph)
  if f < 0.12 and abs(s) > 0.2 and abs(s) < 0.72 and t > 0.12 and t < 0.9 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)

-- sprout stem out of the right nutlet
local stok = { r = { name = "stem" } }
local sp = { { 41, 42 }, { 38, 34 }, { 44, 26 }, { 41, 15 } }
local sm, sn = G.tube(sp, function(t) return 1.05 - 0.25 * t end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- fleshy oblong cotyledons low on the stem
local function cot(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.97 then return -1 end
    return max(0.5, w * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.35)
  end, { fold = 0.15 })
  m:cut(sm)
  G.toneN(c, m, n, COT, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  return m
end
local c1 = cot(39, 35, 35, 33, 31, 35, 1.5)
local c2 = cot(40, 34, 44, 31, 48, 33, 1.5)
-- spoon-shaped true leaves: long petiole, rounded obovate blade, red rim, midrib
local function spoon(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    if t < 0.38 then return 0.55 end
    local u = (t - 0.38) / 0.62
    return max(0.6, w * sin(pi * min(1, u * 0.78 + 0.22)) ^ 0.5)
  end, { fold = 0.35 })
  m:cut(sm):cut(c1):cut(c2)
  G.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.3 })
  local e = m:edge()
  m:each(function(x, y) local k = K(x, y) local s, t = S[k], T[k]
    if t < 0.38 then c:put(x, y, s <= 0 and STEM[3] or STEM[2], ltok)
    elseif e:has(x, y) and t > 0.45 then c:put(x, y, s < 0 and RIMHI or RIM, ltok)
    elseif abs(s) < 0.16 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) end
  end)
  return m
end
spoon(41, 27, 35, 24, 26, 22, 3.3)
spoon(43, 23, 48, 19, 55, 18, 3.0)

-- quirk: a tiny pink protea crown bud on the tip: bract cup + pointed bracts + silvery centre
local cup = c:ellipse(41, 13, 3, 2)
local bn = X.sphere(40.4, 12.4, 3.4, cup)
X.tone(c, cup, X.light(bn, { amb = 0.12, wrap = 0.3 }), PINK, { cuts = CUTS, tok = { r = { name = "bud" } } })
for _, b in ipairs{ { 38, 11, 5 }, { 37, 10, 6 }, { 40, 10, 5 }, { 40, 9, 6 }, { 42, 10, 4 }, { 42, 9, 5 }, { 44, 11, 3 }, { 45, 10, 4 } } do
  c:px(b[1], b[2], PINK[b[3]]) end
c:px(41, 11, "#e2e0e6") c:px(41, 10, "#fff4d6")
for _, p in ipairs{ { 39, 14 }, { 41, 15 }, { 43, 14 } } do c:px(p[1], p[2], PINK[2]) end   -- bract seams

-- seeds last: shaggy tawny hair over a dark nutlet, hair tuft at the far end
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local idx = X.tone(c, vis, X.light(s.n, { amb = 0.08, wrap = 0.25 }), SEED, { cuts = CUTS, bias = sb, tok = tok })
  local ca, sa = cos(s[5]), sin(s[5])
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u = (dx * ca + dy * sa) / (s[3] + .45)
    local v = (-dx * sa + dy * ca) / (s[4] + .45)
    local h = X.hash(floor(u * 3 + 9), floor(v * 5 + 9), i)
    if h > 0.78 and (idx[k] or 1) >= 4 then c:put(x, y, (idx[k] or 1) >= 5 and HAIR[3] or HAIR[2], tok)
    elseif h < 0.12 then c:put(x, y, SEED[1], tok) end
  end)
  -- hairs bristling past the rim (lit side pale, shade side dark gold)
  for a = 0, 11 do
    local th = a / 12 * 2 * pi
    local ex, ey = cos(th) * (s[3] + 1.2), sin(th) * (s[4] + 1.2)
    local px = s[1] + ex * ca - ey * sa
    local py = s[2] + ex * sa + ey * ca
    local xi, yi = floor(px + .5), floor(py + .5)
    if a % 2 == 0 and not s.m:has(xi, yi) then
      local lit = (px - s[1]) + (py - s[2]) < 0
      c:put(xi, yi, lit and HAIR[3] or HAIR[1], tok)
    end
  end
  -- tuft at the +u end
  local tx, ty = s[1] + ca * (s[3] + 1.5), s[2] + sa * (s[3] + 1.5)
  c:put(floor(tx + .5), floor(ty + .5), HAIR[2], tok)
  c:put(floor(tx + ca * 1.2 - sa * 0.9 + .5), floor(ty + sa * 1.2 + ca * 0.9 + .5), HAIR[3], tok)
end
-- split seed coat where the stem emerges
c:px(40, 41, SEED[2]) c:px(41, 41, STEM[2])

A.save2(c, NAME)
