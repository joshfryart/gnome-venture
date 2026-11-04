-- acanthus-seed (final pass, Opus). Two big flat acanthus seeds (glossy chestnut, irregular kidney discs with a
-- bevelled rim and a pale hilum notch) on a torn scrap of acanthus leaf (deep glossy green, pinnately cut into pointed,
-- spine-tipped lobes, midrib + a vein into each lobe, sheen streak along the fold). The right seed has germinated: a
-- pale shoot, two broad round cotyledons and the first true leaf, already deeply lobed like the parent.
-- Material: seeds pillow-bevel light on a 6-tone ramp, gloss streak and glint, fine growth lines; leaf V-fold light,
-- cool reflected edge, AO + contact shadow under each seed.
-- History: Sonnet draft replaced.
-- quirk: the tip of the first true leaf curls into a tiny spiral, like the volute on a Corinthian column.
local NAME = "acanthus-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR1_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#123528", "#1b4c36", "#266640", "#38824a", "#58a456", "#8cc868" }
local SPR  = { "#1f4c38", "#2e6c40", "#468e48", "#68ae54", "#92c866", "#c2e288" }
local VEIN, COOL, SHEEN = "#a8d47e", "#3a6478", "#b4e090"
local SEED = { "#3a1e1c", "#5e2e22", "#8a4628", "#b4642e", "#d88e44", "#f4c07a" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local CREAM = "#fff4d6"

-- seeds: cx, cy, rx, ry, angle (flat irregular discs)
local seeds = { { 20, 46, 6.0, 4.0, -0.35 }, { 37, 44, 5.4, 3.7, 0.25 } }
for _, s in ipairs(seeds) do
  local m = A.oval(s[1], s[2], s[3], s[4], s[5], 0.6)
  -- irregular: flatten one shoulder and cut a hilum notch at the right end
  local ca, sa = cos(s[5]), sin(s[5])
  local nx, ny = s[1] + ca * (s[3] + 0.3), s[2] + sa * (s[3] + 0.3)
  m:cut(c:ellipse(nx, ny, 1.3, 1.1))
  local sx, sy = s[1] - ca * s[3] * 0.4 - sa * (s[4] + 0.6), s[2] - sa * s[3] * 0.4 + ca * (s[4] + 0.6)
  m:cut(c:ellipse(sx, sy, 1.6, 0.9))
  s.m = m
end

-- leaf scrap on the diagonal, pointed spiny lobes, torn at the lower-left base
local PER = 10.0
local lm, ln, LT, LS, len = A.blade(6, 53, 30, 51, 58, 37, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.9 + 0.1)
  return max(0.5, 8.4 * sin(pi * u ^ 1.05) ^ 0.62)
end, { fold = 0.42 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.1 + abs(s) * 0.35   -- lobes swept toward the tip
  local f = abs((ph - floor(ph)) - 0.5) * 2         -- 0 at notch, 1 at lobe point
  local lim = 0.97 - (1 - f) ^ 2.2 * (0.62 + 0.14 * t)
  if t > 0.12 and t < 0.95 and abs(s) > lim then cut[#cut + 1] = k end
  -- torn base
  local d = t * len
  if d < 1.5 + 2.6 * X.hash(floor(s * 5 + 0.5), 1, 23) then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.7, 0.88 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 4.2) / PER + (s > 0 and 0.5 or 0) + 0.1
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.86 and abs(s) > 0.16 and abs(s) < 0.75 and t > 0.1 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  -- glossy sheen streak on the lit half, near the fold
  if s < -0.2 and s > -0.32 and t > 0.3 and t < 0.75 and X.hash(x, y, 4) > 0.3 then c:put(x, y, SHEEN, ltok) end
end)
-- spine at each lobe point (1 px, pushed out past the margin)
local spines = {}
lm:edge():each(function(x, y) local k = K(x, y) local t, s = LT[k], LS[k]
  if t < 0.14 or t > 0.9 or abs(s) < 0.8 then return end
  local ph = t * len / PER + (s > 0 and 0.5 or 0) + 0.1 + abs(s) * 0.35
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if f > 0.9 then
    local sg = s > 0 and 1 or -1
    local ox, oy = x + sg * (s > 0 and 0 or -1), y + sg
    if not lm:has(ox, oy) then spines[#spines + 1] = { ox, oy, s > 0 and LEAF[2] or LEAF[4] } end
  end
end)
for _, q in ipairs(spines) do c:put(q[1], q[2], q[3], ltok) end
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LS[k] < 0.8 and LT[k] > 0.12 and LT[k] < 0.9 and not lm:has(x, y + 1) then c:put(x, y, COOL, ltok) end end)

-- sprout from the right seed's hilum end
local stok = { r = { name = "stem" } }
local sp = { { 40, 42 }, { 40, 35 }, { 37, 30 }, { 37, 24 } }
local sm, sn = A.tube(sp, function(t) return 1.15 - 0.15 * t end)
sm:cut(seeds[2].m)
A.shade(c, sm, sn, STEM, { amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- broad round cotyledons
local function coty(cx, cy, rx, ry, ang)
  local m, n = A.oval(cx, cy, rx, ry, ang, 1.4)
  m:cut(sm)
  A.shade(c, m, n, SPR, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
  local ca, sa = cos(ang), sin(ang)
  m:each(function(x, y) local dx, dy = x - cx, y - cy
    local v = -dx * sa + dy * ca local u = dx * ca + dy * sa
    if abs(v) < 0.5 and abs(u) < rx - 0.8 then c:put(x, y, SPR[4], ltok) end end)
  return m
end
local C1 = coty(31.5, 32, 4.2, 2.4, 0.3)
local C2 = coty(44, 31, 4.0, 2.3, -0.3)
-- first true leaf: lobed blade rising to the upper right
local tl, tn, TT, TS, tlen = A.blade(37, 25, 37, 19, 42, 14, function(t)
  if t > 0.97 then return -1 end
  return max(0.5, 4.8 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.7)
end, { fold = 0.35 })
local tcut = {}
tl:each(function(x, y) local k = K(x, y) local t, s = TT[k], TS[k]
  local ph = t * tlen / 4.4 + (s > 0 and 0.5 or 0) + abs(s) * 0.3
  local f = abs((ph - floor(ph)) - 0.5) * 2
  if t > 0.12 and t < 0.86 and abs(s) > 0.98 - (1 - f) ^ 1.2 * 0.72 then tcut[#tcut + 1] = k end
end)
for _, k in ipairs(tcut) do tl.s[k] = nil end
tl:cut(C1):cut(C2)
A.shade(c, tl, tn, SPR, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) if abs(TS[k]) < 0.14 and TT[k] < 0.85 then c:put(x, y, TS[k] <= 0 and SPR[6] or SPR[3], ltok) end end)
-- quirk: volute curl at the leaf tip
c:paint({
  ".aab.",
  "ab.ab",
  "a.cb.",
  "ab...",
}, 41, 10, { a = SPR[4], b = SPR[2], c = SPR[6] })

-- seeds last
for i, s in ipairs(seeds) do
  local m = s.m
  local tok = { r = { name = "seed" .. i } }
  local n = X.pillow(m, 3.2)
  local sb = {}
  local idx = A.shade(c, m, n, SEED, { amb = 0.08, wrap = 0.25, tok = tok, bias = sb, cuts = { 0.2, 0.38, 0.55, 0.7, 0.86 } })
  local ca, sa = cos(s[5]), sin(s[5])
  -- fine growth lines following the outline (concentric), one tone down
  m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / s[3], (-dx * sa + dy * ca) / s[4]
    local r = sqrt(u * u + v * v)
    if r > 0.3 and r < 0.75 and abs(r - 0.6) < 0.05 and u > 0.1 then A.step(c, idx, SEED, x, y, -1, tok) end
  end)
  -- gloss streak along the lit upper rim + glint
  m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / s[3], (-dx * sa + dy * ca) / s[4]
    if v < -0.35 and v > -0.62 and u > -0.55 and u < 0.1 then c:put(x, y, SEED[6], tok) end
  end)
  local gx, gy = floor(s[1] - s[3] * 0.3 + 0.5), floor(s[2] - s[4] * 0.5 + 0.5)
  c:put(gx, gy, CREAM, tok) c:put(gx + 1, gy, CREAM, tok)
  -- pale hilum lip inside the notch
  local nx, ny = floor(s[1] + ca * (s[3] - 1.2) + 0.5), floor(s[2] + sa * (s[3] - 1.2) + 0.5)
  if m:has(nx, ny) then c:put(nx, ny, SEED[5], tok) end
end
-- shoot foot: collar where it leaves the seed
c:put(40, 43, STEM[1], stok) c:put(41, 43, STEM[2], stok)

A.save(c, "ph", NAME)
