-- mexican-sunflower-seed (aC23_2, Opus single pass). Three slim Tithonia achenes (narrow wedges, charcoal-brown with
-- pale lengthwise ribs and a tiny cream crown of pappus scales on the broad end) lying across a torn, toothed scrap of
-- the velvety Tithonia leaf (horizontal blade, ragged pale torn edge on the left, serrate margin, midrib + swept veins,
-- soft hair flecks, cool reflected edge, AO + contact shadow under each seed). The left seed has germinated: pale stem,
-- two oval cotyledons and a first true leaf with the plant's three-lobed, serrate outline.
-- quirk: one fallen flame-orange ray petal of the flower lies curled on the leaf tip.
local NAME = "mexican-sunflower-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new2(NAME)
local LEAF = { "#1c3e34", "#2a5a40", "#3c7646", "#58944e", "#7eb260", "#b0d47e" }
local SEED = { "#1e1620", "#33252a", "#4a3630", "#66503e", "#8c7458", "#b8a280" }
local STEM = { "#5a8a52", "#8cba6c", "#bcdc94", "#e4f2c0" }
local PET  = { "#6e2038", "#b52e2e", "#e8502a", "#ff7a2e", "#ffa452", "#ffd08a" }
local TORN, HAIR, COOL, CROWN = "#d8e8a8", "#a6c88a", "#3a6c72", "#efe2c2"

-- leaf scrap: broad horizontal blade, tip to the right
local lm, ln, LT, LS, len = A.blade(8, 47, 30, 52, 57, 42, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 9.5 * sin(pi * min(1, t * 0.88 + 0.12)) ^ 0.62)
end, { fold = 0.34 })
A.serrate(lm, LT, LS, len, 3.2, 0.12, 0.95, 0.84)
local torn = A.tear(lm, LT, LS, len, true, 2.4, 2)

-- seeds: achene wedges (u=0 narrow base, u=1 broad crowned top)
local function prof(u) if u > 0.93 then return 2.1 - (u - 0.93) * 8 end return 0.7 + 1.5 * u ^ 0.8 end
local seeds = {
  { 18, 46, 10, -1.75 },  -- upright: sprouting one (base down)
  { 29, 49, 10, 0.25 },
  { 40, 45, 9.5, -0.55 },
}
for _, s in ipairs(seeds) do s.m, s.U, s.V = A.seed(s[1], s[2], s[3], prof, s[4]) end

-- sprout masks first (for AO and cast shadow)
local sp = { { 17, 41 }, { 16, 35 }, { 18, 30 }, { 18, 25 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
-- radicle: short pale root from the narrow base, curling onto the leaf
local rp = { { 18, 51 }, { 18, 53 }, { 16, 55 }, { 13, 55 } }
local rm, rn = A.tube(rp, function(t) return 0.9 - 0.4 * t end)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.cast(bias, lm, rm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.28, 0.44, 0.6, 0.8 }, amb = 0.16, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.13 and t > 0.06 and t < 0.94 then c:put(x, y, s <= 0 and STEM[3] or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 5.5) / 6.2 + (s > 0 and 0.5 or 0)
  local f = ph - floor(ph)
  if f < 0.14 and abs(s) > 0.15 and abs(s) < 0.74 and t > 0.08 and t < 0.86 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) return end
  -- velvety hair flecks on the lit half
  if s < -0.2 and X.hash(x, y, 4) > 0.9 then c:put(x, y, HAIR, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.62 and LT[k] > 0.15 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)

-- quirk: fallen ray petal, curled, on the leaf tip (contact shadow under it)
local pm, pn, PT, PS = A.blade(43, 40, 48, 36, 54, 38, function(t)
  if t > 0.97 then return -1 end
  return max(0.4, 2.1 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.5)
end, { fold = 0.2 })
local pb = {}
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) then c:put(x, y, LEAF[1], ltok) end end)
local ptok = { r = { name = "petal" } }
A.toneN(c, pm, pn, PET, { tok = ptok, cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, amb = 0.15, wrap = 0.3 })
pm:each(function(x, y) local k = K(x, y)
  if abs(PS[k]) < 0.2 and PT[k] > 0.2 and PT[k] < 0.8 and (x % 2 == 0) then c:put(x, y, PET[3], ptok) end end)
c:put(54, 37, PET[2], ptok) -- notched tip

-- radicle
local rtok = { r = { name = "root" } }
X.tone(c, rm, X.light(rn, { amb = 0.15, wrap = 0.3 }), { "#9a8a6a", "#d8cca8", "#f4ead0" }, { cuts = { 0.4, 0.7 }, tok = rtok })

-- sprout stem
local stok = { r = { name = "stem" } }
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: two ovals
local function blade(ax, ay, cx, cy, bx, by, w, veins)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.92 + 0.08)) ^ 0.6)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.15 and T[k] > 0.12 and T[k] < 0.8 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m, n, T, S
end
local cl = blade(17, 27, 13, 26, 7, 24, 2.3)
local cr = blade(19, 27, 23, 26, 29, 25, 2.3)
-- first true leaf: three-lobed, serrate (Tithonia outline): central lobe up, two side lobes
local tl = HP.mask()
local tn, TT, TS = {}, {}, {}
for _, b in ipairs{ { 18, 24, 18, 18, 19, 10, 3.6 }, { 18, 22, 15, 20, 12, 16, 2.2 }, { 18, 22, 21, 19, 25, 16, 2.2 } } do
  local m, n, T, S, L = A.blade(b[1], b[2], b[3], b[4], b[5], b[6], function(t)
    if t > 0.985 then return -1 end
    return max(0.4, b[7] * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.7)
  end, { fold = 0.32 })
  A.serrate(m, T, S, L, 2.4, 0.3, 0.9, 0.8)
  for k, v in pairs(n) do if m.s[k] and not tl.s[k] then tn[k], TT[k], TS[k] = v, T[k], S[k] end end
  tl:add(m)
end
tl:cut(cl):cut(cr)
local tb = {}
tl:each(function(x, y) if y >= 22 then tb[K(x, y)] = -1 end end)
A.toneN(c, tl, tn, LEAF, { tok = ltok, bias = tb, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
tl:each(function(x, y) local k = K(x, y) if TS[k] and abs(TS[k]) < 0.15 and TT[k] > 0.15 and TT[k] < 0.82 then c:put(x, y, TS[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)

-- seeds last: ribbed wedges with a pale pappus crown
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local sb = {}
  if i == 1 then X.ao(sb, s.m, sm, 1, -1) end
  s.m:each(function(x, y) local k = K(x, y)
    local u, v = s.U[k], s.V[k]
    local j
    if v < -0.55 then j = 4 elseif v < -0.1 then j = 5 elseif v < 0.3 then j = 3 elseif v < 0.7 then j = 2 else j = 1 end
    if v > -0.1 and v < 0.12 then j = 2 end                   -- central rib groove
    if v < -0.1 and v > -0.55 and u > 0.35 and u < 0.7 then j = 6 end -- lit rib catches light
    if u < 0.12 then j = j - 1 end
    j = j + (sb[k] or 0)
    c:put(x, y, SEED[max(1, min(6, j))], tok)
  end)
  -- crown of pappus scales just past the broad end
  local ca, sa = cos(s[4]), sin(s[4])
  local ex, ey = s[1] + ca * (s[3] / 2 + 0.6), s[2] + sa * (s[3] / 2 + 0.6)
  local px, py = -sa, ca
  for _, o in ipairs{ -1.4, 0, 1.4 } do
    local x, y = floor(ex + px * o + .5), floor(ey + py * o + .5)
    if not s.m:has(x, y) then c:put(x, y, o > 0 and SEED[5] or CROWN, tok) end
  end
end

A.save2(c, NAME)
