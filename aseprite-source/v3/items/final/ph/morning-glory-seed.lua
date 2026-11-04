-- morning-glory-seed (ph, Opus single pass). Three matte black-brown wedge seeds (orange-segment shape: rounded
-- lit back, a darker flat face, a pale hilum notch, a fine velvet fleck) on a torn heart-shaped leaf lying on the
-- diagonal (sinus at the lower-left, ragged tear across the upper lobe, midrib + swept veins, cool reflected edge,
-- AO + contact shadow under each seed). The middle seed has sprouted: slim stem, the unmistakable butterfly
-- cotyledons (two broad, deeply notched seed leaves), a first small heart leaf on a petiole, and the vine tip
-- already twining upward as a little corkscrew (front turns lit, back turns dark).
-- quirk: the corkscrew tip ends in a tiny furled blue-violet flower bud, twisted like a closed umbrella.
local NAME = "morning-glory-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC2r0_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = G.new2(NAME)
local LEAF = { "#183a30", "#22573a", "#2f7840", "#4a9a48", "#72ba58", "#a6d66e" }
local VEIN, COOL = "#cdeb94", "#3a6a70"
local SEED = { "#140e16", "#21161f", "#30212b", "#43323c", "#5c4852", "#7a6670" }
local HIL = "#b89c7c"
local STEM = { "#3e7a4c", "#6ea65e", "#a6d084", "#d8eeb2" }
local BUD = { "#30285e", "#4c3c9c", "#7466d4", "#a89cf0", "#d9d0ff" }
local PINK = "#e07ab4"

local function heart(ax, ay, bx, by, W, o)
  local m, n, T, S, len = G.blade(ax, ay, (ax + bx) / 2, (ay + by) / 2 + (o and o.bend or 0), bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, W * sin(pi * min(1, 0.3 + t * 0.78)) ^ 0.75)
  end, { fold = 0.3 })
  local cut = {}
  m:each(function(x, y) local k = K(x, y)
    if T[k] < 0.16 and abs(S[k]) < (0.16 - T[k]) / 0.16 * 0.42 then cut[#cut + 1] = k end end)
  for _, k in ipairs(cut) do m.s[k] = nil end
  return m, n, T, S, len
end

-- seeds: centre, back direction angle
local seeds = { { 19, 45, -0.6 }, { 29, 44, -1.9 }, { 39, 45, -2.6 } }
for _, s in ipairs(seeds) do
  local ca, sa = cos(s[3]), sin(s[3])
  s.m, s.n, s.u = HP.mask(), {}, {}
  for y = floor(s[2]) - 5, floor(s[2]) + 5 do for x = floor(s[1]) - 5, floor(s[1]) + 5 do
    local dx, dy = x - s[1], y - s[2]
    local u, v = (dx * ca + dy * sa) / 3.7, (-dx * sa + dy * ca) / 3.5
    if u * u + v * v <= 1 and u >= -0.22 then
      s.m:set(x, y)
      local k = K(x, y)
      local q = max(0.05, 1 - u * u - v * v)
      local nx, ny, nz = ca * u - sa * v, sa * u + ca * v, sqrt(q)
      if u < 0.12 then nx, ny, nz = -ca * 0.7 + nx * 0.3, -sa * 0.7 + ny * 0.3, 0.6 end   -- flat face
      local l = sqrt(nx * nx + ny * ny + nz * nz)
      s.n[k] = { nx / l, ny / l, nz / l } s.u[k] = u
    end
  end end
end
local allSeeds = HP.mask() for _, s in ipairs(seeds) do allSeeds:add(s.m) end

-- leaf scrap: heart leaf, sinus lower-left, tip upper-right; tear across the upper lobe
local lm, ln, LT, LS, len = heart(9, 50, 57, 38, 7.8, { bend = 2 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  local t, s = LT[k], LS[k]
  local tear = 0.36 + 0.18 * t + 0.09 * X.hash(floor(t * 14), 3, 2)
  if s < 0 and -s > tear + 0.25 and t < 0.62 then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end
local bias = {}
X.ao(bias, lm, allSeeds, 1, -1) G.cast(bias, lm, allSeeds, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.09 and t > 0.12 and t < 0.95 then c:put(x, y, s <= 0 and VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.5) / 8
  local f = ph - floor(ph)
  if f < 0.1 and abs(s) > 0.12 and abs(s) < 0.8 and t > 0.1 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.72 and LT[k] > 0.15 and LT[k] < 0.9 then c:put(x, y, COOL, ltok) end end)
-- torn edge: a pale bruised row along the tear
lm:edge():each(function(x, y) local k = K(x, y)
  if LS[k] < -0.45 and LT[k] < 0.6 and LT[k] > 0.08 and not bias[k] then c:put(x, y, "#b6d98a", ltok) end end)

-- sprout from the middle seed
local stok = { r = { name = "stem" } }
local sp = { { 29, 44 }, { 31, 38 }, { 27, 31 }, { 29, 25 } }
local sm, sn = G.tube(sp, function(t) return 1.1 end)
sm:cut(seeds[2].m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- butterfly cotyledons
local function coty(cx, cy, a)
  local ca, sa = cos(a), sin(a)
  local m = G.rell(cx, cy, ca, sa, 4.8, 3.4)
  -- deep V notch at the outer end
  local cutm = HP.mask()
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if u > 1.2 and abs(v) < (u - 1.2) * 0.62 then cutm:set(x, y) end
  end)
  m:cut(cutm):cut(sm)
  local n = X.pillow(m, 2.2)
  local b = {} X.ao(b, m, sm, 1, -1)
  local idx = G.toneN(c, m, n, LEAF, { tok = ltok, bias = b, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.12, wrap = 0.3 })
  -- midrib running out to the notch
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v) < 0.5 and u > -3.2 and u < 1.0 then c:put(x, y, (idx[K(x, y)] or 3) >= 4 and LEAF[6] or LEAF[3], ltok) end
  end)
  return m
end
local tx, ty = 29, 25
coty(tx - 5.0, ty - 1.2, pi + 0.25)
coty(tx + 5.2, ty - 1.4, -0.28)
-- first true leaf: small heart on a petiole, hanging to the right
G.pline(c, { { 30, 22 }, { 34, 19 }, { 37, 19 } }, STEM[2], stok)
local hm, hn, HT, HS = heart(37, 18, 45, 12, 3.6)
hm:cut(sm)
local hidx = G.toneN(c, hm, hn, LEAF, { tok = ltok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.14, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y) if abs(HS[k]) < 0.14 and HT[k] > 0.15 and HT[k] < 0.85 then c:put(x, y, HS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
-- twining vine tip: corkscrew up from the stem top
local prev
for y = 23, 12, -1 do
  local ph = (23 - y) * 0.95
  local x = floor(29 + 1.7 * sin(ph) + 0.5 - (23 - y) * 0.12)
  local front = cos(ph) > 0
  local col = front and STEM[3] or STEM[1]
  if prev and abs(prev - x) > 1 then
    local step = x > prev and 1 or -1
    for xx = prev + step, x - step, step do c:put(xx, y + 1, col, stok) end
  end
  c:put(x, y, col, stok)
  if front and y % 3 == 0 then c:put(x, y, STEM[4], stok) end
  prev = x
end
-- quirk: tiny furled bud at the tip, twisted stripes
local btok = { r = { name = "bud" } }
local bx, by = prev, 11
local rows = {
  "..d..",
  ".dbB.",
  ".bBp.",
  ".Bbd.",
  "..g..",
}
local map = { d = BUD[2], b = BUD[3], B = BUD[4], p = PINK, g = STEM[2] }
for j, r in ipairs(rows) do for i = 1, #r do local ch = r:sub(i, i)
  if map[ch] then c:put(bx - 3 + i, by - 5 + j, map[ch], btok) end end end
c:put(bx - 1, by - 3, BUD[5], btok)

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.05, wrap = 0.2 })
  s.m:each(function(x, y) local k = K(x, y)
    -- ridge line between back and flat face
    if s.u[k] >= 0.12 and s.u[k] < 0.32 and (idx[k] or 1) > 2 then c:put(x, y, SEED[max(1, idx[k] - 2)], tok) end
    -- velvet flecks on the lit back
    if s.u[k] > 0.45 and (idx[k] or 1) >= 4 and X.hash(x, y, 21 + i) > 0.82 then c:put(x, y, SEED[6], tok) end
  end)
  -- hilum: small pale notch at the middle of the flat face
  local hx, hy = floor(s[1] - cos(s[3]) * 0.6 + 0.5), floor(s[2] - sin(s[3]) * 0.6 + 0.5)
  if s.m:has(hx, hy) then c:put(hx, hy, HIL, tok) end
end
-- the sprouting seed: split coat where the stem emerges
c:put(29, 43, STEM[2], stok)
-- one soft specular on the front seed's back
do local s = seeds[3] local bxx, byy = G.specAt(s.m, s.n, 30) c:put(bxx, byy, "#a8949c", { r = { name = "seed3" } }) end

G.save2(c, NAME)
