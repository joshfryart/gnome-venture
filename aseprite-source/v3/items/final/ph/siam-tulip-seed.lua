-- siam-tulip-seed (D15 final, Sonnet). Three finger-like rhizome "seeds" (knobbly pale-tan fingers with ring nodes and a
-- pink bud eye) on a torn scrap of broad curcuma leaf (pointed tip, ragged torn base with fibres, pleated parallel
-- veins, bright midrib, cool reflected edge, contact shadow under each seed). The right seed has sprouted: a pale-pink
-- stem, one broad lance leaf with a strong midrib and pleats, and a tulip-like pink bract cone with a lilac coma tuft.
-- quirk: a round water bead sits on the leaf scrap, magnifying a vein.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD15_4.lua")
local G, HP, X, K = A, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("siam-tulip-seed")

local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local VEIN, COOL = "#c6e68e", "#3c6e74"
local RHZ = { "#4a2c30", "#72463c", "#9c6a4c", "#c4916a", "#e3b88c", "#f6dcb4" }
local PINK = { "#6e2a5a", "#a03f78", "#d2619a", "#f283ae", "#ffaac6", "#ffd6e2" }
local LILAC = { "#4e3a82", "#6f58aa", "#9780cc", "#b9a6e2", "#d8ccf4", "#f1eaff" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }
local ltok = { r = { name = "leaf" } }

-- seeds (rhizome fingers): cx, cy, rx, ry, angle
local seeds = { { 14, 49, 5.2, 2.7, -0.15 }, { 24, 45, 5.0, 2.6, 0.35 }, { 38, 43, 4.8, 2.6, -1.35 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf scrap: broad, pointed at the right, torn at the left
local lm, ln, LT, LS, len = G.blade(7, 54, 30, 50, 57, 36, function(t)
  if t > 0.99 then return -1 end
  return max(0.5, 8.2 * min(1, (1 - t) / 0.55) ^ 0.75 * min(1, t * 8 + 0.35))
end, { fold = 0.34 })
-- torn base: ragged diagonal edge + a few fibre notches
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local u = LT[k] * len
  local s = LS[k]
  local tear = 2.4 + X.hash(floor(s * 6 + 10), 1, 2) * 3.2 + abs(s) * 2.2
  if u < tear then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 2, -1) end
-- pleats: alternate narrow bands across the leaf shade up/down
lm:each(function(x, y) local k = K(x, y)
  local ph = floor((LS[k] + 1) * 5.5)
  if ph % 2 == 1 and not bias[k] then bias[k] = (bias[k] or 0) + ((LS[k] < 0) and 0 or -1) end
end)
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] and bias[k] < 0 and (X.ao and false) then return end
  if abs(s) < 0.1 and t > 0.03 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  -- parallel pleat veins
  for _, vs in ipairs{ 0.28, 0.5, 0.72 } do
    if abs(abs(s) - vs) < 0.055 and t > 0.1 and t < 0.9 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
-- torn fibres: a few pale threads dangling off the torn end
for _, p in ipairs{ { 6, 52 }, { 5, 53 }, { 6, 55 }, { 5, 56 }, { 7, 57 } } do if not lm:has(p[1], p[2]) then c:put(p[1], p[2], LEAF[5], ltok) end end
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] > 0.7 and LT[k] > 0.16 and LT[k] < 0.88 then c:put(x, y, COOL, ltok) end end)

-- sprout: stem from the right seed, broad lance leaf out to the upper left, bract cone straight up
local stok = { r = { name = "stem" } }
local sm, sn = G.tube({ { 38, 42 }, { 38, 38 }, { 39, 34 }, { 39, 30 } }, function(t) return 1.2 end)
sm:cut(seeds[3].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- the broad leaf
local bm, bn, BT, BS, blen = G.blade(38, 35, 29, 27, 17, 23, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 5.4 * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.62)
end, { fold = 0.4 })
bm:cut(sm)
G.toneN(c, bm, bn, LEAF, { tok = ltok, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, amb = 0.14, wrap = 0.3 })
bm:each(function(x, y) local k = K(x, y) local s, t = BS[k], BT[k]
  if abs(s) < 0.12 and t > 0.04 and t < 0.92 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  for _, vs in ipairs{ 0.4, 0.72 } do
    if abs(abs(s) - vs) < 0.07 and t > 0.12 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
  end
end)
bm:edge():each(function(x, y) local k = K(x, y) if BS[k] > 0.62 and BT[k] > 0.15 then c:put(x, y, COOL, ltok) end end)
-- ambient where the leaf joins the stem
sm:each(function(x, y) if bm:has(x - 1, y) or bm:has(x + 1, y) then c:put(x, y, STEM[1], stok) end end)

-- bract cone (tulip): overlapping pink bracts, upper ones lilac, a coma tuft on top
local btok = { r = { name = "bract" } }
local function bract(cx, cy, rx, ry, ang, ramp, cuts)
  local m, n = G.oval(cx, cy + 6, rx, ry * 0.88, ang, 0.7)
  G.toneN(c, m, n, ramp, { tok = btok, cuts = cuts or { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1, wrap = 0.28 })
  -- midrib + dark edge lower-right
  m:edge():each(function(x, y) if x + y > cx + cy + 7 then c:put(x, y, ramp[2], btok) end end)
  return m
end
local cone = HP.mask()
-- coma tuft (lilac, top)
cone:add(bract(41, 11, 2.0, 3.2, 0.35, LILAC))
cone:add(bract(37, 12, 2.0, 3.0, -0.35, LILAC))
cone:add(bract(39, 9, 1.8, 3.0, 0, LILAC))
-- body bracts: back, left, right, front
cone:add(bract(36, 20, 3.1, 6.4, -0.12, PINK))
cone:add(bract(42, 20, 3.1, 6.4, 0.12, PINK))
cone:add(bract(39, 22, 3.4, 6.8, 0, PINK))
-- fold line between the front bract and its neighbours, lit tip
for y = 23, 31 do c:put(39, y, PINK[3], btok) end
for y = 22, 28 do c:put(36, y, PINK[2], btok) c:put(42, y, PINK[2], btok) end
c:put(37, 23, PINK[6], btok) c:put(38, 23, PINK[6], btok) c:put(37, 24, PINK[5], btok)
-- bract tips greenish (the real bracts are green-flushed at the base)
for _, p in ipairs{ { 36, 32 }, { 37, 33 }, { 38, 33 }, { 39, 33 }, { 40, 33 }, { 41, 33 }, { 42, 32 } } do if cone:has(p[1], p[2]) then c:put(p[1], p[2], STEM[2], btok) end end
-- stem hides under the cone base
for _, p in ipairs{ { 38, 34 }, { 39, 34 }, { 38, 35 }, { 39, 35 } } do c:put(p[1], p[2], STEM[1], stok) end
c:put(38, 33, STEM[1], stok) c:put(39, 33, STEM[1], stok)

-- quirk: a water bead on the leaf, magnifying the midrib
do
  local bx, by = 50, 41
  local bd = c:ellipse(bx, by, 3, 3)
  local bn2 = X.sphere(bx - 0.4, by - 0.4, 3, bd)
  local tok = { r = { name = "bead" } }
  X.tone(c, bd, X.light(bn2, { amb = 0.1, wrap = 0.3 }), { "#2d6d78", "#3f8d90", "#6dbab4", "#a6dcd2", "#d4f0e6", "#f4fff8" }, { cuts = A.CUTS, tok = tok })
  c:put(bx - 1, by - 1, A.CREAM, tok) c:put(bx, by - 1, A.CREAM, tok)
  c:put(bx + 1, by + 1, LEAF[6], tok)
end

-- seeds last: banded rhizome fingers with ring nodes, bud eye, bristle roots
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  vis:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    local idx
    if v < -0.55 then idx = 5 elseif v < -0.1 then idx = 4 elseif v < 0.35 then idx = 3 elseif v < 0.7 then idx = 2 else idx = 2 end
    if v > 0.45 and v < 0.75 and u < -0.1 then idx = 3 end            -- cool-ish bounce on the shade edge
    -- ring nodes: dark bands across the finger at three places
    for _, nu in ipairs{ -0.45, 0.05, 0.55 } do
      if abs(u - nu) < 0.09 then idx = idx - 1 end
    end
    if abs(u) > 0.88 then idx = idx - 1 end
    if v < -0.3 and v > -0.62 and u > -0.75 and u < -0.3 then idx = 6 end
    if sb[k] then idx = idx - 1 end
    c:put(x, y, RHZ[max(1, min(6, idx))], tok)
  end)
  -- bud eye: a pink 2x2 at one end
  local ex = s[1] + ((i == 3) and 0 or (s[3] * 0.55) * ca)
  local ey = s[2] + ((i == 3) and (-s[3] * 0.65) or (s[3] * 0.55) * sa)
  if i ~= 3 then
    local xi, yi = floor(ex + 0.5), floor(ey + 0.5)
    c:put(xi, yi, PINK[4], tok) c:put(xi + 1, yi, PINK[3], tok) c:put(xi, yi - 1, PINK[5], tok)
  end
  -- fine roots: two pale single-pixel hairs off the lower side
  for _, b in ipairs{ { -0.5, 1 }, { 0.3, 1 } } do
    local px = s[1] + (b[1] * s[3]) * ca - (b[2] * (s[4] + 1.1)) * sa
    local py = s[2] + (b[1] * s[3]) * sa + (b[2] * (s[4] + 1.1)) * ca
    local xi, yi = floor(px + .5), floor(py + .5)
    if i ~= 3 and not s.m:has(xi, yi) then c:put(xi, yi, RHZ[5], tok) end
  end
end
-- shoot collar: a pink ring where the sprout leaves the rhizome
c:put(37, 41, PINK[4], { r = { name = "seed3" } }) c:put(38, 41, PINK[5], { r = { name = "seed3" } }) c:put(39, 41, PINK[3], { r = { name = "seed3" } })

A.save(c, "siam-tulip-seed")
