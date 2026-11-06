-- lapacho-seed (final, Opus single pass). Two papery winged lapacho seeds (brown lens-shaped body with a dark hilum
-- seam, wide silvery-tan membrane wings with fine radiating striations and a frayed rim) lying on a torn scrap of
-- glossy lapacho leaflet (entire margin, midrib + looping laterals, cool reflected edge, ragged tip tear, AO + cast
-- shadow under each seed). A third seed has germinated: its wing is shrivelled, the pale stem rises to two kidney
-- cotyledons and the first true leaf, palmate with five fanned leaflets, as on the grown tree.
-- quirk: a single fallen pink lapacho trumpet flower rests on the torn tip of the leaf.
local NAME = "lapacho-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC15_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local LEAF = { "#1c3a2a", "#2a5432", "#3c7038", "#588e3e", "#7eac4c", "#b2cc6a" }
local SPR  = { "#1f4a36", "#2f6a42", "#479048", "#6cb056", "#98cc68", "#c8e690" }
local STEM = { "#5a7a4a", "#8eaa66", "#bcd28e", "#e2eebc" }
local WING = { "#6a5444", "#8f7a64", "#b4a084", "#d4c4a6", "#ebdfc2", "#f9f2de" }
local BODY = { "#3a2216", "#583620", "#7a502c", "#9e6c3a", "#c09052", "#ddb470" }
local COOL, TEAR = "#3e6a6c", "#d0dc96"

-- seeds: cx, cy, wing rx, wing ry, angle, body rx, body ry
local seeds = {
  { 15, 40, 5.0, 2.2, -0.25, 2.4, 1.8, sprout = true },
  { 29, 45, 8.2, 3.0, 0.22, 3.0, 2.1 },
  { 44, 50, 8.0, 3.0, 0.55, 2.9, 2.0 },
}
for _, s in ipairs(seeds) do
  s.m = A.oval(s[1], s[2], s[3], s[4], s[5], 0.4)
  s.bm, s.bn = A.oval(s[1], s[2], s[6], s[7], s[5], 0.9)
end

-- leaf scrap: glossy leaflet on a falling diagonal; ragged tear at the tip
local lm, ln, LT, LS, len = A.blade(6, 36, 30, 41, 58, 55, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.95 + 0.05)
  return max(0.5, 8.6 * sin(pi * u ^ 1.05) ^ 0.62)
end, { fold = 0.4 })
local tear = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local s = LS[k]
  local lim = 0.86 - 0.05 * ((floor((s + 1) * 3)) % 2) + 0.03 * cos(s * 9)
  if LT[k] > lim then tear:set(x, y) end
end)
lm:cut(tear)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok) return end
  -- laterals loop toward the margin (brochidodromous)
  local d = (t * len - abs(s) * 6.5 + abs(s) ^ 3 * 4) % 6.0
  if d < 0.8 and abs(s) > 0.16 and abs(s) < 0.78 then c:put(x, y, s < 0 and LEAF[5] or LEAF[2], ltok) end
end)
-- glossy leaf: one long specular streak on the lit half
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] < -0.42 and LS[k] > -0.55 and LT[k] > 0.12 and LT[k] < 0.3 then c:put(x, y, LEAF[6], ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.1 and LT[k] < 0.8 then c:put(x, y, COOL, ltok) end end)
lm:each(function(x, y) if tear:has(x + 1, y) or tear:has(x, y + 1) then c:put(x, y, TEAR, ltok) end end)
-- leaf stalk stub at the base
for _, q in ipairs{ { 6, 36, 3 }, { 5, 35, 3 }, { 4, 35, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout: stem, cotyledons, palmate first leaf
local stok = { r = { name = "stem" } }
local stp = { { 15, 39 }, { 13, 31 }, { 18, 24 }, { 17, 16 } }
local sm = A.stem(c, stp, function(t) return 1.1 - 0.2 * t end, STEM, { tok = stok })
local sprtok = { r = { name = "sprout" } }
local function cot(ax, ay, bx, by)
  return A.leaf(c, ax, ay, (ax + bx) / 2, ay - 2, bx, by, 2.0, SPR, { cut = sm, tok = sprtok, vs = 9, fold = 0.3, wfn = function(t)
    if t > 0.97 then return -1 end return max(0.4, 2.2 * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.4) end })
end
cot(14, 29, 6, 29)
cot(16, 28, 24, 26)
local P = { 17, 16 }
local fan = { { -170, 6.5 }, { -130, 8.8 }, { -90, 9.8 }, { -50, 8.8 }, { -10, 6.5 } }
for i, f in ipairs(fan) do
  local a = f[1] * pi / 180
  local ux, uy = cos(a), sin(a)
  local ax, ay = P[1] + ux * 1.2, P[2] + uy * 1.2
  local bx, by = P[1] + ux * f[2], P[2] + uy * f[2] + 0.8
  A.leaf(c, ax, ay, (ax + bx) / 2 - uy * 0.6, (ay + by) / 2 + ux * 0.6, bx, by, 1.4, SPR, { cut = sm, tok = sprtok, vs = 2.6, fold = 0.5,
    wfn = function(t) if t > 0.98 then return -1 end return max(0.3, 1.45 * sin(pi * min(1, (t * 0.92 + 0.08) ^ 0.9)) ^ 0.7) end })
end
c:put(P[1], P[2], SPR[2], sprtok)

-- seeds last: wings, then bodies
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local wing = s.m:copy():cut(s.bm)
  if s.sprout then wing:cut(sm) end
  local wb = {}
  for j = i + 1, #seeds do X.ao(wb, wing, seeds[j].m, 1, -1) end
  -- wing: gently cupped, lit upper-left; striations radiate from the body
  local wn = {}
  wing:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + 0.45), (-dx * sa + dy * ca) / (s[4] + 0.45)
    local nx, ny = u * 0.25 * ca - v * 0.5 * sa, u * 0.25 * sa + v * 0.5 * ca
    wn[K(x, y)] = { A.norm(nx, ny, 1) }
  end)
  local W = s.sprout and { "#5e4a3a", "#7e6852", "#a08a6e", "#bca88a", "#d4c4a6", "#e6dcc2" } or WING
  local widx = A.shade(c, wing, wn, W, { amb = 0.25, wrap = 0.5, cuts = { 0.2, 0.4, 0.6, 0.75, 0.9 }, bias = wb, tok = tok })
  wing:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa), (-dx * sa + dy * ca)
    local ang = math.atan(v * 1.6, abs(u))
    local ph = (ang / pi * 9) % 1
    if ph < 0.22 and abs(u) > s[6] + 1 then c:put(x, y, W[max(1, (widx[k] or 3) - 1)], tok) end
  end)
  -- frayed lower-right rim
  wing:edge():each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    if (-dx * sa + dy * ca) > 0.5 and X.hash(x, y, 21 + i) > 0.45 then c:put(x, y, W[2], tok) end
  end)
  -- body: plump lens, dark hilum seam along the long axis, one gloss pixel
  local bb = {}
  local bidx = A.shade(c, s.bm, s.bn, BODY, { amb = 0.06, wrap = 0.2, bias = bb, tok = tok })
  s.bm:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local v = (-dx * sa + dy * ca)
    local u = dx * ca + dy * sa
    if abs(v - 0.5) < 0.5 and abs(u) < s[6] - 0.6 then c:put(x, y, BODY[2], tok) end
  end)
  local gx, gy = A.specAt(s.bm, s.bn, 30)
  if gx then c:put(gx, gy, BODY[6], tok) end
end
-- sprouting seed: split seam with the stem foot coming out
c:put(15, 38, STEM[3], stok) c:put(16, 39, BODY[1], { r = { name = "seed1" } })

-- quirk: fallen pink lapacho trumpet on the torn tip
local ftok = { r = { name = "flower" } }
A.map(c, {
  ".pq...",
  "pyYqqg",
  "qYqqqg",
  ".qQ...",
}, 49, 50, { p = "#ffb4d0", q = "#f07ea8", Q = "#b84a82", y = "#ffe27a", Y = "#e8a838", g = "#5a8a40" }, ftok)

A.save(c, NAME)
