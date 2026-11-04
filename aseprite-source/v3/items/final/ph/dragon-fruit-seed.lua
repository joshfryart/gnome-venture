-- dragon-fruit-seed (final pass, Opus). Tiny glossy black dragon-fruit seeds bedded in a dab of white pulp on a torn,
-- broad leaf scrap lying flat (gentle S curve, ragged tear on the right end, magenta-tinged rim from the fruit).
-- Leaf: 6-tone, V-fold light, midrib + paired veins, cool reflected edge, AO + contact shadow under pulp and seeds.
-- A seedling rises from the pulp: pale stem, two fat succulent cotyledons and a little three-ribbed green cactus
-- stem with cream areole spines (the plant's real "leaf").
-- quirk: the seedling still wears its black seed coat on the cactus tip like a tiny hat.
local NAME = "dragon-fruit-seed"
local D = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB24_2.lua")
local G, HP, X, K = D.G, D.HP, D.X, D.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = D.new(NAME)
local LEAF = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local MAG = "#c0306e"
local PULP = { "#9a8a9c", "#c8bcc6", "#e6dee2", "#f6f0ee", "#fffaf2" }
local SEED = { "#1e1420", "#2b1c26", "#43303e", "#6a5468", "#a48ea6" }
local CAC = { "#1a4a34", "#26663c", "#3a8a44", "#5cae4e", "#8ed062", "#c6ec8e" }
local STEM = { "#4f8a55", "#86b86c", "#b8dc92", "#e2f2bc" }

-- leaf scrap, horizontal with a soft S, torn on the right
local lm, ln, LT, LS, len = G.blade(8, 46, 30, 54, 56, 44, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 8.0 * sin(pi * min(1, t * 0.75 + 0.06)) ^ 0.75)
end, { fold = 0.4 })
local cut = {}
lm:each(function(x, y) local k = K(x, y)
  -- ragged tear across the right end
  local lim = 0.8 + X.hash(floor(LS[k] * 7), 3, 2) * 0.15 + (abs(LS[k]) * 0.08)
  if LT[k] > lim then cut[#cut + 1] = k end
end)
for _, k in ipairs(cut) do lm.s[k] = nil end

-- pulp dab + seeds
local pulp = HP.ellipse(25, 47, 6.5, 3.2)
pulp:add(HP.ellipse(31, 49, 3.5, 2.2))
local seeds = { { 21, 46 }, { 24, 48 }, { 27, 46 }, { 30, 49 }, { 18, 49 } }
local sm = HP.mask()
local seedMasks = {}
for i, s in ipairs(seeds) do
  local m = HP.mask()
  for _, d in ipairs{ { 0, 0 }, { 1, 0 }, { 0, 1 }, { 1, 1 }, { 0, -1 } } do m:set(s[1] + d[1], s[2] + d[2]) end
  seedMasks[i] = m sm:add(m)
end

local bias = {}
X.ao(bias, lm, pulp, 1, -1) G.cast(bias, lm, pulp, 1, 2, -1)
X.ao(bias, lm, sm, 1, -1)

-- seedling stem from the pulp
local sp = { { 26, 46 }, { 25, 38 }, { 29, 33 }, { 28, 26 } }
local stm, stn = G.tube(sp, function(t) return 1.0 end)
G.cast(bias, lm, stm, 1, 1, -1)

local ltok = D.tok("leaf")
G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.03 and t < 0.86 then c:put(x, y, s <= 0 and D.VEIN or LEAF[3], ltok) return end
  local ph = (t * len - abs(s) * 6.0) / 6.0
  local f = ph - floor(ph)
  if f < 0.1 and abs(s) > 0.16 and abs(s) < 0.72 and t > 0.08 and t < 0.8 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
-- edges: magenta tinge on the lit rim near the tip, cool reflected light on the shade rim, pale torn fibres
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LT[k] > 0.76 then c:put(x, y, LEAF[5], ltok)
  elseif LS[k] > 0.6 and LT[k] > 0.08 then c:put(x, y, D.COOL, ltok)
  elseif LS[k] < -0.6 and LT[k] < 0.35 and LT[k] > 0.05 then c:put(x, y, MAG, ltok) end
end)

-- pulp: soft pillow, glossy
local ptok = D.tok("pulp")
local pn = X.pillow(pulp, 2)
local pb = {}
X.ao(pb, pulp, sm, 1, -1)
D.toneV(c, pulp, pn, PULP, { cuts = { 0.2, 0.42, 0.62, 0.82 }, bias = pb, tok = ptok, amb = 0.2 })

-- stem
local stok = D.tok("stem")
local stv = stm:copy() stv:cut(sm)
X.tone(c, stv, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })

-- fat succulent cotyledons
local function cot(ax, ay, cx, cy, bx, by)
  local m, n, T, S = G.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.5, 2.6 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.5)
  end, { fold = 0.12 })
  m:cut(stm)
  local tok = D.tok("cot")
  local idx = G.toneN(c, m, n, CAC, { tok = tok, cuts = D.CUTS, amb = 0.14, wrap = 0.3 })
  return m
end
local cl = cot(27, 30, 21, 27, 15, 29)
local cr = cot(29, 30, 35, 28, 41, 31)

-- cactus stem: three-ribbed column with areoles
local cm, cn, CT, CS = G.tube({ { 28, 30 }, { 28, 25 }, { 29, 20 }, { 29, 15 } }, function(t) return 2.6 - t * 0.6 end)
cm:cut(cl):cut(cr)
local ctok = D.tok("cactus")
local cidx = {}
cm:each(function(x, y) local k = K(x, y)
  local s = CS[k]
  -- three ribs: lit rib left, centre rib, shade rib right, with grooves between
  local i
  if s < -0.55 then i = 5 elseif s < -0.25 then i = 3 elseif s < 0.15 then i = 4 elseif s < 0.45 then i = 2 else i = 3 end
  if s < -0.7 then i = 6 end
  if CT[k] > 0.9 then i = i + 1 end
  if CT[k] < 0.08 then i = i - 1 end
  c:put(x, y, CAC[max(1, min(6, i))], ctok)
end)
-- areoles: cream spine dots on the rib edges
for _, a in ipairs{ { 26, 26 }, { 31, 23 }, { 27, 20 }, { 31, 18 } } do c:put(a[1], a[2], D.CREAM, ctok) end
c:put(25, 26, STEM[3], ctok) c:put(32, 23, STEM[3], ctok)

-- quirk: seed-coat hat on the cactus tip
local htok = D.tok("hat")
for _, h in ipairs{ { 28, 13, 3 }, { 29, 13, 2 }, { 30, 13, 2 }, { 29, 12, 3 }, { 28, 14, 2 }, { 31, 14, 1 } } do c:put(h[1], h[2], SEED[h[3]], htok) end
c:put(28, 12, SEED[5], htok)

-- seeds: glossy black teardrops with a glint each
for i, s in ipairs(seeds) do
  local tok = D.tok("seed" .. i)
  seedMasks[i]:each(function(x, y)
    local dx, dy = x - s[1], y - s[2]
    local t = 3
    if dx == 1 and dy == 1 then t = 1 elseif dx == 1 or dy == 1 then t = 2 elseif dy == -1 then t = 4 end
    c:put(x, y, SEED[t], tok)
  end)
  c:put(s[1], s[2], SEED[5], tok)
end
-- pulp gloss
c:put(22, 45, PULP[5], ptok) c:put(23, 45, PULP[5], ptok)

D.save(c, NAME)
