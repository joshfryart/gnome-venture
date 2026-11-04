-- coffee (final, Opus single pass). Two slim dark-roast beans, flat face up, S-shaped centre crease with a lit
-- lower lip, oily specular streak, cool reflected rim; back bean sits in the front bean's contact shadow.
-- A ripe red coffee cherry on a short stalk with one glossy wavy coffee leaf tucks in at the lower right.
-- quirk: a thin curl of roast aroma rises off the back bean.
local NAME = "coffee"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB21_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new(NAME)
local BEAN = { "#3a1d1e", "#5a2c24", "#7a3f2a", "#9b5733", "#c07a45", "#e6a866" }
local COOL = "#6c4c5e"
local RED = { "#5e1a2e", "#8e2433", "#c0322f", "#e2513a", "#f6834e", "#ffbe86" }
local LEAF = { "#163a32", "#1f5240", "#2b6c48", "#3f8a4e", "#62a858", "#98cc72" }
local STALK = { "#3c4a2c", "#5e6a36", "#86884a", "#b0a866" }

local beans = {
  { 39, 23, 10.2, 6.6, -0.85 },   -- back
  { 26, 38, 11.4, 7.3, -0.42 },   -- front
}
for _, b in ipairs(beans) do b.m, b.n = A.oval(b[1], b[2], b[3], b[4], b[5], 0.85) end
local cm = c:ellipse(46, 48, 4, 4)
local cn = X.sphere(45.6, 47.6, 4, cm)

-- leaf behind the cherry (drawn first, everything else overlaps it)
local lbias = {}
X.ao(lbias, HP.mask(), cm, 1, -1)
local lm = A.leaf(c, 47, 47, 54, 40, 59, 41, 3.2, LEAF, { fold = 0.5, vs = 2.8 })
-- wavy margin: nick two pixels off the lower edge
for _, q in ipairs{ { 53, 45 }, { 56, 43 } } do if lm:has(q[1], q[2]) then c:put(q[1], q[2], LEAF[2], { r = { name = "leaf" } }) end end

local function bean(i, bias)
  local b = beans[i]
  local tok = { r = { name = "bean" .. i } }
  local idx = A.shade(c, b.m, b.n, BEAN, { amb = 0.05, wrap = 0.18, bias = bias, tok = tok })
  local F = A.frame(b[1], b[2], b[3], b[4], b[5])
  b.m:each(function(x, y) local k = K(x, y)
    local u, v = F(x, y)
    local vc = 0.2 * sin(pi * u * 0.95)
    local d = v - vc
    if abs(u) < 0.8 then
      if abs(d) < 0.19 then c:put(x, y, BEAN[1], tok)
      elseif d >= 0.19 and d < 0.4 then c:put(x, y, BEAN[min(6, (idx[k] or 3) + 1)], tok)
      elseif d <= -0.19 and d > -0.36 then c:put(x, y, BEAN[max(1, (idx[k] or 3) - 1)], tok) end
    end
    -- oily streak along the lit shoulder
    if v > -0.72 and v < -0.5 and u > -0.55 and u < -0.05 and not (bias and bias[k]) then c:put(x, y, BEAN[6], tok) end
  end)
  -- cool reflected light on the shade rim
  b.m:edge():each(function(x, y) local u, v = F(x, y)
    if v > 0.55 and u > -0.5 and u < 0.75 and not (bias and bias[K(x, y)]) then c:put(x, y, COOL, tok) end end)
  return F
end

-- back bean: AO + cast shadow from the front bean and the cherry
local bb = {}
X.ao(bb, beans[1].m, beans[2].m, 2, -1)
A.cast(bb, beans[1].m, beans[2].m, 1, -1, -1)
beans[1].m:cut(beans[2].m)
bean(1, bb)
-- front bean, AO where the cherry presses in
local fb = {}
X.ao(fb, beans[2].m, cm, 1, -1)
beans[2].m:cut(cm)
bean(2, fb)
-- glints
c:put(19, 33, A.CREAM) c:put(20, 33, BEAN[6]) c:put(33, 17, A.CREAM)

-- cherry: stalk up-left into the bean pile, glossy skin, dark navel at the lower right
A.stem(c, { { 45, 45 }, { 44, 43 }, { 43, 42 }, { 41, 41 } }, function() return 0.7 end, STALK, { cut = beans[2].m })
local ctok = { r = { name = "cherry" } }
local cidx = A.shade(c, cm, cn, RED, { amb = 0.05, wrap = 0.2, tok = ctok })
cm:edge():each(function(x, y) if x - 46 + y - 48 >= 4 then c:put(x, y, "#9a3a5a", ctok) end end)
c:put(48, 50, RED[1], ctok) c:put(49, 49, RED[2], ctok) c:put(47, 50, RED[2], ctok)
c:put(44, 46, A.CREAM, ctok) c:put(45, 46, RED[6], ctok)

-- quirk: aroma curl (1px, warm cream-grey) rising off the back bean
local W = "#e9d6c4"
local curl = { { 43, 15 }, { 44, 14 }, { 44, 13 }, { 43, 12 }, { 42, 11 }, { 42, 10 }, { 43, 9 }, { 44, 8 }, { 45, 7 } }
for _, p in ipairs(curl) do if not beans[1].m:has(p[1], p[2]) then c:put(p[1], p[2], W, { r = { name = "aroma" } }) end end

A.save(c, NAME)
