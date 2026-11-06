-- buckwheat-seed (final, Opus aB13_2 single pass). Three glossy triangular buckwheat achenes (faceted pyramids,
-- bright ridges, one cream glint) on a torn arrow-heart buckwheat leaf scrap (jagged tear on the tip end, midrib +
-- swept veins, V-fold light, cool reflected edge, AO + contact shadow under each seed). The right seed has sprouted:
-- a red hypocotyl, two broad kidney cotyledons and a first arrow-heart true leaf showing the buckwheat leaf shape.
-- quirk: the split seed hull still sits like a little cap on the tip of one cotyledon.
local NAME = "buckwheat-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB13_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, max, min, sin, pi = math.floor, math.abs, math.max, math.min, math.sin, math.pi
local c = A.new(NAME)

local LEAF  = { "#173f36", "#23593f", "#317546", "#4a954d", "#70b457", "#a2d070" }
local TORN  = "#d6e8a0"
local STEM  = { "#44182c", "#6c2238", "#94303f", "#b84a4a", "#d8705c", "#f2a080" }
local HULL  = { "#2a1a1c", "#4a2c26", "#6e4430", "#946038", "#bc8448", "#e4b474" }
local COT   = { "#1f4a3a", "#2c6a44", "#3f8a4a", "#5ea852", "#86c460", "#b8e080" }
local ltok = { r = { name = "leaf" } }

-- seeds (triangles) first as masks for AO
local seedP = {
  { { 13, 41 }, { 21, 40 }, { 16, 48 } },
  { { 24, 43 }, { 32, 45 }, { 26, 51 } },
  { { 35, 38 }, { 43, 39 }, { 39, 46 } },
}
local seeds = {}
for i, p in ipairs(seedP) do local m, F, n = A.tri(p, { (p[1][1] + p[2][1] + p[3][1]) / 3 + 0.9, (p[1][2] + p[2][2] + p[3][2]) / 3 + 0.6 }, 1.0) seeds[i] = { m = m, F = F, n = n } end

-- leaf scrap: arrow-heart blade lying diagonal, base lower-left, tip torn off upper-right
local lm, ln, LT, LS, len, lb = A.heart(14, 47, 32, 46, 58, 39, 6.2, 2.2)
-- jagged tear across the tip end
local tear = HP.mask()
lm:each(function(x, y) local k = K(x, y)
  local w = (LS[k] or 0) * 6.2
  local zig = abs((w / 2.2) % 2 - 1) * 2.2
  if (LT[k] or 0) * len > 0.74 * len + zig + 0.3 * w then tear:set(x, y) end end)
lm:cut(tear)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local lidx = A.shade(c, lm, ln, LEAF, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = ltok, bias = bias })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] or lb:has(x, y) then return end
  if abs(s) < 0.13 and t < 0.74 then c:put(x, y, s <= 0 and LEAF[6] or LEAF[3], ltok)
  elseif t > 0.06 and abs(s) > 0.28 and abs(s) < 0.8 then
    local d = (t * len - abs(s) * 6.2 * 1.1) % 4
    if d < 0.9 then c:put(x, y, s < 0 and LEAF[min(6, (lidx[k] or 3) + 1)] or LEAF[max(1, (lidx[k] or 3) - 1)], ltok) end
  end end)
-- torn edge: pale fibrous rim
lm:edge():each(function(x, y) if tear:grow(1):has(x, y) then c:put(x, y, TORN, ltok) end end)
-- cool reflected edge on the shade side
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] and LS[k] > 0.7 and LT[k] > 0.15 and not tear:grow(1):has(x, y) then c:put(x, y, "#3c6e74", ltok) end end)
-- petiole stub
A.stem(c, { { 12, 47 }, { 10, 49 }, { 8, 50 }, { 6, 51 } }, function() return 0.7 end, STEM, { cut = lm })

-- sprout from seed 3: red hypocotyl, cotyledons, arrow-heart true leaf
local stok = { r = { name = "stem" } }
local sm, _, ST, SS = A.stem(c, { { 39, 40 }, { 41, 34 }, { 37, 29 }, { 38, 23 } }, function(t) return 1.0 end, STEM, { tok = stok, cut = seeds[3].m })
sm:each(function(x, y) local k = K(x, y) if SS[k] < -0.4 and ST[k] < 0.9 then c:put(x, y, STEM[6], stok) end end)
-- cotyledons: broad kidneys
local function coty(cx, cy, ux, uy, ra, rb)
  local m = A.rell(cx, cy, ux, uy, ra, rb)
  m:cut(sm)
  local n = X.pillow(m, 2)
  local idx = A.shade(c, m, n, COT, { amb = 0.12, wrap = 0.28, tok = { r = { name = "coty" } } })
  -- midline crease
  m:each(function(x, y) local dx, dy = x - cx, y - cy
    if abs(-dx * uy + dy * ux) < 0.5 and abs(dx * ux + dy * uy) < ra - 1.5 then c:put(x, y, COT[min(6, (idx[K(x, y)] or 3) + 1)], { r = { name = "coty" } }) end end)
  return m
end
local cl = coty(32, 22, -0.92, -0.38, 5.2, 3.0)
local cr = coty(44, 22, 0.92, -0.38, 5.2, 3.0)
-- first true leaf: arrow-heart, between the cotyledons, pointing up
local tm, tn, TT, TS, tlen, tlb = A.heart(38, 21, 38, 16, 39, 10, 3.4, 1.4)
tm:cut(sm)
local tidx = A.shade(c, tm, tn, LEAF, { amb = 0.12, wrap = 0.28, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, tok = ltok })
tm:each(function(x, y) local k = K(x, y) if not tlb:has(x, y) and abs(TS[k]) < 0.15 and TT[k] < 0.85 then c:put(x, y, LEAF[6], ltok) end end)
for _, s in ipairs{ cl, cr } do s:each(function(x, y) if tm:shift(0, 1):has(x, y) and not tm:has(x, y) then c:px(x, y, COT[1]) end end) end

-- seeds on top
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, s.m, s.n, HULL, { amb = 0.2, wrap = 0.35, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, tok = tok })
  s.m:each(function(x, y) local k = K(x, y)
    for _, d in ipairs{ { 1, 0 }, { 0, 1 } } do local q = s.F[K(x + d[1], y + d[2])]
      if q and q ~= s.F[k] and (idx[k] or 1) >= 3 then c:put(x, y, HULL[min(6, idx[k] + 2)], tok) end end
  end)
  local p = seedP[i]
  local gx, gy = (p[1][1] + p[2][1] + p[3][1]) / 3, (p[1][2] + p[2][2] + p[3][2]) / 3
  s.m:edge():each(function(x, y) c:put(x, y, (x - gx) + (y - gy) > -0.5 and HULL[1] or HULL[3], tok) end)
  local bx, by = A.specAt(s.m:shrink(1), s.n, 30)
  if bx then c:put(bx, by, "#fff0dc", tok) end
end

-- quirk: split hull cap on the tip of the left cotyledon
local cm, cF, cn = A.tri({ { 24, 17 }, { 29, 16 }, { 25, 22 } }, { 25.5, 18 }, 1.0)
A.shade(c, cm, cn, HULL, { amb = 0.08, wrap = 0.2, cuts = { 0.25, 0.42, 0.58, 0.74, 0.9 }, tok = { r = { name = "cap" } } })
c:px(27, 19, HULL[1]) c:px(26, 20, HULL[1]) -- split seam

A.save(c, NAME)
