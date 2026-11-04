-- celery-seed (final, Opus aB1r1_1). Tiny ribbed olive-brown celery seeds (ovoid, a pale lit rib and a dark groove)
-- on a torn scrap of a toothed celery leaflet (two deep lobe notches, saw-toothed margin, midrib + veins, cool
-- reflected edge, pale torn rim, AO + contact shadows). A dried straw umbel lies across the scrap, its spokes still
-- holding seeds. The middle seed has sprouted: a slim stem, two narrow cotyledons and a first true leaf, three
-- toothed lobes, that shows the celery top.
-- quirk: the left cotyledon still wears its seed coat like a little brown hat.
local NAME = "celery-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r1_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#163c2c", "#1f5832", "#2c763a", "#469844", "#6cb850", "#a4d878" }
local VEIN, COOL, TORN = "#d4f0a8", "#36607a", "#e0f2c0"
local SEED = { "#2a2018", "#463420", "#664c2a", "#8a6a38", "#ae8c4e", "#d4b478" }
local STRAW = { "#6e5430", "#a08048", "#ccae6a", "#ecd8a0" }
local STEM = { "#4c8048", "#7eb466", "#b0d88e", "#dcf0bc" }
local SL = { "#1a4a30", "#266838", "#388842", "#56a84c", "#7ec45c", "#b2e084" }
local ltok = { r = { name = "leaf" } }

-- leaf scrap: torn at the lower left, toothed lobed tip to the upper right
local lm, ln, LT, LS, len = A.blade(8, 54, 32, 52, 57, 39, function(t)
  if t > 0.985 then return -1 end
  local w = 9.2 * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.6
  for _, nt in ipairs{ 0.5, 0.74 } do local d = abs(t - nt) if d < 0.06 then w = w * (0.62 + d * 6.3) end end
  local ph = t * 52 / 3.4
  return max(0.5, w * (1 - 0.13 * (ph - floor(ph))))
end, { fold = 0.36 })
local rim = A.tear(lm, LT, LS, len, 2.2, 11)

-- seeds on the leaf: cx, cy, rx, ry, angle
local loose = { { 23, 49, 2.6, 1.6, 0.3 }, { 31, 48, 2.6, 1.6, -0.6 }, { 46, 44, 2.6, 1.6, 0.9 }, { 51, 41, 2.4, 1.5, -0.2 } }
local sprouter = { 38, 46, 2.7, 1.7, -0.15 }
-- umbel: hub + spokes with seeds at their tips; stalk lies down-right
local hub = { 15, 44 }
local spokes = { { -0.95, -0.3, 5 }, { -0.7, -0.75, 5.5 }, { -0.2, -1, 5.5 }, { 0.35, -0.95, 5 } }
local useeds = {}
for _, sp in ipairs(spokes) do
  local l = sqrt(sp[1] ^ 2 + sp[2] ^ 2) local ux, uy = sp[1] / l, sp[2] / l
  useeds[#useeds + 1] = { hub[1] + ux * (sp[3] + 1.6), hub[2] + uy * (sp[3] + 1.6), 2.0, 1.3, math.atan(uy, ux), ux = ux, uy = uy, L = sp[3] }
end
local all = {}
for _, s in ipairs(loose) do all[#all + 1] = s end
all[#all + 1] = sprouter
for _, s in ipairs(useeds) do all[#all + 1] = s end
for _, s in ipairs(all) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

local umb = HP.line({ { hub[1], hub[2] }, { 21, 47 }, { 27, 51 } }, 1)
local spm = HP.mask()
for _, s in ipairs(useeds) do spm:add(HP.line({ { hub[1], hub[2] }, { hub[1] + s.ux * s.L, hub[2] + s.uy * s.L } }, 1)) end

local bias = {}
for _, s in ipairs(all) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 1, -1) end
A.cast(bias, lm, umb, 1, 1, -1) A.cast(bias, lm, spm, 1, 1, -1)
local stemPts = { { 38, 45 }, { 37, 37 }, { 40, 30 }, { 40, 23 } }
local sm, sn = A.tube(stemPts, function(t) return 1.0 end)
A.cast(bias, lm, sm, 1, 1, -1)
A.leaf(c, lm, ln, LT, LS, len, LEAF, { bias = bias, tok = ltok, per = 6, sweep = 3, vein = VEIN, cool = COOL, rim = rim, rimCol = TORN })

-- dried umbel stalk + spokes (2-tone straw with a lit top)
local utok = { r = { name = "umbel" } }
umb:each(function(x, y) c:put(x, y, STRAW[2], utok) end)
umb:shift(0, -1):each(function(x, y) if not umb:has(x, y) then c:put(x, y, STRAW[3], utok) end end)
spm:each(function(x, y) c:put(x, y, STRAW[3], utok) end)
c:put(hub[1], hub[2], STRAW[1], utok) c:put(hub[1] - 1, hub[2] + 1, STRAW[2], utok)

-- sprout stem
local stok = { r = { name = "stem" } }
sm:cut(sprouter.m)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
-- cotyledons: narrow, strap-like
local stk = { r = { name = "sl" } }
local function blade(ax, ay, cx, cy, bx, by, W)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, W * sin(pi * min(1, t * 0.9 + 0.12)) ^ 0.5)
  end, { fold = 0.3 })
  A.toneN(c, m, n, SL, { tok = stk, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and SL[6] or SL[3], stk) end end)
  return m
end
blade(38, 32, 33, 29, 27, 28, 1.7)
blade(40, 32, 45, 29, 51, 29, 1.7)
-- first true leaf: petiole + three toothed lobes
for y = 17, 23 do c:put(40, y, y > 20 and STEM[2] or STEM[3], stok) end
local tl = HP.mask()
tl:add(A.tooth(40, 17, 0, -1, 7, 2.8, 3, 0.4))
local lx, ly = A.rot(0, -1, -1.0) local rx, ry = A.rot(0, -1, 1.0)
tl:add(A.tooth(40, 18, lx, ly, 5.5, 2.3, 2, 0.4))
tl:add(A.tooth(40, 18, rx, ry, 5.5, 2.3, 2, 0.4))
A.toneN(c, tl, X.pillow(tl, 1.6), SL, { tok = stk, cuts = { 0.18, 0.34, 0.5, 0.66, 0.84 }, amb = 0.12, wrap = 0.25 })
for i = 0, 5 do c:put(40, 17 - i, i < 2 and SL[3] or SL[5], stk) end
for i = 1, 3 do c:put(floor(40 + lx * i + .5), floor(18 + ly * i + .5), SL[5], stk) c:put(floor(40 + rx * i + .5), floor(18 + ry * i + .5), SL[4], stk) end

-- seeds: ribbed ovoids
local function seed(s, tok)
  local ca, sa = cos(s[5]), sin(s[5])
  local flip = ((-sa) + ca) > 0 and 1 or -1
  local v = X.light(s.n, { amb = 0.06, wrap = 0.25 })
  local idx = X.tone(c, s.m, v, SEED, { cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, tok = tok })
  s.m:each(function(x, y) local k = K(x, y)
    local dx, dy = x - s[1], y - s[2]
    local u, w = (dx * ca + dy * sa) / (s[3] + .45), flip * (-dx * sa + dy * ca) / (s[4] + .45)
    if abs(u) < 0.75 then
      if w > -0.55 and w < -0.1 then c:put(x, y, SEED[6], tok) elseif w >= 0.15 and w < 0.55 then c:put(x, y, SEED[2], tok) end
    end
  end)
end
for i, s in ipairs(all) do seed(s, { r = { name = "seed" .. i } }) end

-- quirk: seed coat hat on the left cotyledon tip
local hat = A.oval(27.5, 27, 2.4, 1.5, -0.3, 0.8)
local htok = { r = { name = "hat" } }
hat:each(function(x, y) c:put(x, y, (y < 27 and x < 29) and SEED[5] or SEED[3], htok) end)
c:put(26, 26, SEED[6], htok) c:put(28, 28, SEED[2], htok)
A.save(c, NAME)
