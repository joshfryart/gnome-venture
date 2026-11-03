-- balloon-flower-seed (final, Opus aR3_1, single pass). Four tiny flat, glossy, dark-brown balloon-flower
-- (Platycodon) seeds scattered on a torn scrap of its leaf: ovate, sharply toothed, cool blue-green, midrib + pinnate
-- veins, torn base in pale tissue, AO and contact shadow under each seed. The rightmost seed has sprouted: a fine
-- radicle, a slim pale stem, two small round cotyledons and a pair of toothed ovate true leaves.
-- quirk: the seedling already carries a fully puffed violet balloon bud, five seams and all.
local NAME = "balloon-flower-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aR3_1.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)

local LEAF = { "#14303a", "#1c4646", "#28604f", "#3a7c5a", "#5a9a68", "#88ba7c" }
local VEIN, TORN = "#b4d8a2", "#a2c8a0"
local SEED = { "#1c1216", "#2e1c1c", "#472a22", "#64402c", "#8a5c3a", "#b88658" }
local STEM = { "#4a7a58", "#7aa872", "#a8cc94", "#d6ecbc" }
local SL   = { "#173a34", "#225443", "#30704c", "#468e56", "#68ac64", "#98c87a" }
local BUD  = { "#2a2258", "#3e3486", "#5548b0", "#7466d0", "#9a8ee6", "#c6bef6" }
local CALYX = { "#24503e", "#3a7450", "#5c9a62" }
local SPEC = "#fff4d6"

-- leaf scrap: ovate, pointing right, torn at the base on the left; toothed margin
local lm, ln, LT, LS, len = G.blade(6, 52, 30, 57, 57, 41, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t * 0.9 + 0.1)
  return max(0.5, 7.0 * sin(pi * u ^ 0.8) ^ 0.75)
end, { fold = 0.5 })
G.serrate(lm, LT, LS, len, 3.4, 0.24, 0.14, 0.95)
G.tear(lm, 10, 53, -0.97, -0.25, 1.4, 5)

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 15, 52, 2.6, 1.6, 0.4 }, { 22, 55, 2.7, 1.6, -0.3 }, { 29, 51, 2.5, 1.5, 1.1 }, { 38, 50, 2.7, 1.7, -0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = G.oval(s[1], s[2], s[3], s[4], s[5], 0.6) end

-- sprout from seed 4
local rm, rn = G.tube({ { 40, 51 }, { 42, 53 }, { 44, 54 }, { 47, 54 } }, function(t) return 0.75 * (1 - t) + 0.3 end)
rm:cut(seeds[4].m)
local sp = { { 39, 49 }, { 36, 41 }, { 44, 33 }, { 41, 22 } }
local sm, sn = G.tube(sp, function(t) return 0.95 end)
sm:cut(seeds[4].m)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) G.cast(bias, lm, s.m, 1, 1, -1) end
G.cast(bias, lm, rm, 1, 1, -1) G.cast(bias, lm, sm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
G.leafTone(c, lm, ln, LEAF, { bias = bias, tok = ltok })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.14 and t > 0.12 and t < 0.94 then c:put(x, y, s <= 0 and VEIN or LEAF[2], ltok) return end
  local ph = (t * len - abs(s) * 5.0) / 5.6 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.14 and abs(s) > 0.2 and abs(s) < 0.78 and t > 0.12 and t < 0.88 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] < 0.2 and (x - 10) * -0.97 + (y - 53) * -0.25 > -2 then c:put(x, y, TORN, ltok)
  elseif not bias[k] and LS[k] > 0.7 and LT[k] > 0.25 then c:put(x, y, "#3c6c7a", ltok) end end)

-- radicle
local rtok = { r = { name = "radicle" } }
X.tone(c, rm, X.light(rn, { amb = 0.2, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = rtok })
-- stem
local stok = { r = { name = "stem" } }
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- cotyledons: small round blades
local function blade(ax, ay, cx, cy, bx, by, w, teeth)
  local m, n, T, S, L = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.6)
  end, { fold = 0.3 })
  if teeth then G.serrate(m, T, S, L, 2.6, 0.2, 0.3, 0.9) end
  m:cut(sm)
  local tok = { r = { name = "sl" .. ax .. bx } }
  G.toneN(c, m, n, SL, { tok = tok, cuts = { 0.16, 0.32, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.1 and T[k] < 0.86 then
    c:put(x, y, S[k] <= 0 and SL[6] or SL[3], tok) end end)
  return m
end
blade(39, 41, 36, 39, 33, 40, 1.8)
blade(40, 40, 43, 38, 46, 39, 1.8)
-- true leaves: toothed ovate pair
blade(41, 29, 35, 26, 28, 28, 3.3, true)
blade(42, 28, 48, 24, 54, 25, 3.3, true)

-- balloon bud (quirk): puffed sphere with five seams, calyx below, glossy
local BX, BY, BRd = 41, 16, 4.6
local bud = c:ellipse(BX, BY, BRd, BRd + 0.4)
bud:set(BX, floor(BY - BRd - 1.2)) bud:set(BX - 1, floor(BY - BRd - 0.4)) bud:set(BX + 1, floor(BY - BRd - 0.4))
local bn = X.sphere(BX - 0.3, BY - 0.3, BRd, bud)
local btok = { r = { name = "bud" } }
local bidx = X.tone(c, bud, X.light(bn, { amb = 0.06, wrap = 0.2 }), BUD, { cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 }, tok = btok })
-- seams: meridians from the top point, seen on a sphere (x offset = sin(phi) * sqrt(1 - yy^2))
bud:each(function(x, y) local k = K(x, y)
  local yy = (y - BY) / (BRd + 0.5)
  local r = sqrt(max(0, 1 - yy * yy)) * (BRd + 0.5)
  for j = 0, 4 do
    local phi = j * 2 * pi / 5 - 0.25
    if cos(phi) > 0.05 then
      local sx = BX + sin(phi) * r
      if abs(x - sx) < 0.5 and yy > -0.8 and yy < 0.85 then c:put(x, y, BUD[max(1, min(3, bidx[k] - 2))], btok)
        if bud:has(x - 1, y) and bidx[K(x - 1, y)] >= 3 and abs(x - 1 - sx) >= 0.5 then c:put(x - 1, y, BUD[min(6, bidx[K(x - 1, y)] + 1)], btok) end end
    end
  end
end)
local brim = X.rim(bn)
bud:edge():each(function(x, y) if brim[K(x, y)] > 0.75 then c:put(x, y, "#5c8ab4", btok) end end)
c:put(38, 13, SPEC, btok) c:put(39, 13, SPEC, btok) c:put(38, 14, BUD[6], btok)
-- calyx: five small green points cupping the bud base
local ctok = { r = { name = "calyx" } }
G.map(c, BX - 3, BY + 4, { ".a.b.c.", "abbcbbc", "..bcc.." }, { a = CALYX[3], b = CALYX[2], c = CALYX[1] }, ctok)
c:put(BX, BY + 7, STEM[2], ctok) c:put(BX, BY + 6, STEM[2], ctok)

-- seeds last: flat, glossy, a pale wing rim, one glint each (glossy material)
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = G.toneN(c, s.m, s.n, SEED, { tok = tok, cuts = { 0.12, 0.28, 0.46, 0.64, 0.82 }, amb = 0.06, wrap = 0.2 })
  s.m:edge():each(function(x, y) local k = K(x, y) if idx[k] and idx[k] >= 3 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end end)
  local gx, gy = G.specAt(s.m, s.n, 30)
  c:put(gx, gy, SPEC, tok)
end

G.save2(c, NAME)
