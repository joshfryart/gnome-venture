-- flame-of-the-forest-seed (final, Opus aB32_0). One big flat kidney-shaped Butea seed, glossy russet with a wrinkle
-- groove and a pale hilum in the notch, lying on a torn broad leathery leaflet (olive, midrib + curved side veins, waxy
-- sheen, ragged tear on the right). The seed has sprouted: green stem rising to the plant's trifoliate leaf (three
-- broad rounded leaflets). AO + contact shadow under seed and flower.
-- quirk: a single orange "parrot-beak" flame flower, curved keel with its velvety dark calyx, lies beside the seed.
local NAME = "flame-of-the-forest-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB32_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#1a3a2e", "#2a5236", "#3e6e3c", "#5a8c44", "#80aa52", "#b0c872" }
local FRESH = { "#173f36", "#21593f", "#2e7646", "#45954c", "#6ab455", "#9dd06c" }
local STEM = { "#3f7448", "#6aa05a", "#9cc874", "#d0e8a0" }
local SEED = { "#2e1218", "#561e22", "#80302a", "#a84a34", "#cc7048", "#eea072" }
local FL = { "#7a2030", "#c2361e", "#e8601e", "#f88a26", "#ffb648", "#ffe08a" }
local CAL = { "#1c1620", "#2e2430", "#463844", "#5e5058" }

-- seed: flat kidney
local sm, sn = A.oval(27, 44, 7.2, 4.6, -0.18, 0.45)
sm:cut(HP.ellipse(27.5, 49.2, 1.6, 1.3))
-- flower (quirk)
local fm, fnn, FT, FS = A.tube({ { 41, 47 }, { 43, 41 }, { 49, 39 }, { 52, 43 } }, function(t) return 2.2 * (1 - t) ^ 0.7 + 0.3 end)
local cm, cn = A.oval(40.5, 47.5, 2.4, 2.0, 0.6, 0.8)
fm:cut(cm)

-- torn broad leaflet
local bias = {}
local lm0 = A.blade(9, 49, 31, 42, 55, 47, function(t) if t > 0.985 then return -1 end return max(0.5, 9.6 * sin(pi * min(1, t * 0.97 + 0.03)) ^ 0.62) end, { fold = 0.3 })
local tear = HP.ellipse(50, 40, 3.5, 3):add(HP.ellipse(45, 38.5, 2.2, 2)):add(HP.ellipse(53, 44, 1.6, 1.4))
for _, m in ipairs{ sm, fm, cm } do X.ao(bias, lm0, m, 1, -1) A.cast(bias, lm0, m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lm, LT, LS, lidx = A.leaf(c, 9, 49, 31, 42, 55, 47, 9.6, LEAF, { pw = 0.62, fold = 0.3, vs = 5.5, cut = tear, bias = bias, tok = ltok,
  wfn = function(t) if t > 0.985 then return -1 end return max(0.5, 9.6 * sin(pi * min(1, t * 0.97 + 0.03)) ^ 0.62) end })
-- waxy sheen band on the lit half, pale torn fibres on the tear edge
lm:each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] < -0.45 and LS[k] > -0.7 and LT[k] > 0.15 and LT[k] < 0.45 and (x + y) % 3 == 0 then c:put(x, y, LEAF[6], ltok) end end)
lm:edge():each(function(x, y) if tear:grow(1):has(x, y) then c:put(x, y, "#c8d08a", ltok) end end)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and LS[k] > 0.7 and not tear:grow(1):has(x, y) then c:put(x, y, "#2f5e66", ltok) end end)
for _, p in ipairs{ {7, 50, "#6aa05a"}, {6, 51, "#3f7448"} } do c:put(p[1], p[2], p[3], ltok) end

-- sprout stem
local stok = { r = { name = "stem" } }
local stm = A.stem(c, { { 30, 41 }, { 33, 33 }, { 28, 26 }, { 31, 17 } }, function(t) return 1.15 - t * 0.2 end, STEM, { cut = sm, tok = stok })
for _, p in ipairs{ {31, 15}, {31, 16} } do c:put(p[1], p[2], STEM[2], stok) end
-- trifoliate leaf
local function rnd(w) return function(t) if t > 0.97 then return -1 end return max(0.5, w * sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.45 * (0.55 + 0.45 * min(1, t * 1.6))) end end
local ttok = { r = { name = "tri" } }
local tmid = A.leaf(c, 31, 15, 30, 9, 32, 2, 4.4, FRESH, { wfn = rnd(4.4), fold = 0.35, vs = 3.0, tok = ttok })
local tl = A.leaf(c, 30, 17, 25, 15, 18, 18, 3.6, FRESH, { wfn = rnd(3.6), fold = 0.35, vs = 3.0, tok = ttok, cut = tmid })
local tr = A.leaf(c, 32, 17, 38, 15, 45, 18, 3.6, FRESH, { wfn = rnd(3.6), fold = 0.35, vs = 3.0, tok = ttok, cut = tmid })
-- AO at the leaflet junction
for _, p in ipairs{ {30, 16}, {32, 16}, {31, 14} } do c:put(p[1], p[2], FRESH[2], ttok) end

-- flower: calyx (velvet) + curved orange keel
local ctk = { r = { name = "calyx" } }
local cidx = A.shade(c, cm, cn, CAL, { amb = 0.1, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 }, tok = ctk })
for _, p in ipairs{ {39, 46}, {41, 48} } do c:put(p[1], p[2], CAL[4], ctk) end
local ftk = { r = { name = "flower" } }
local fidx = A.shade(c, fm, fnn, FL, { amb = 0.12, wrap = 0.3, tok = ftk })
fm:each(function(x, y) local k = K(x, y) if FS[k] < -0.4 and FT[k] > 0.15 and FT[k] < 0.6 then c:put(x, y, FL[6], ftk) end
  if FS[k] > 0.55 and FT[k] > 0.1 then c:put(x, y, FL[2], ftk) end end)

-- seed: glossy flat kidney, wrinkle groove, hilum in the notch
local stk = { r = { name = "seed" } }
local sidx = A.shade(c, sm, sn, SEED, { amb = 0.08, wrap = 0.22, tok = stk, cuts = { 0.14, 0.3, 0.48, 0.66, 0.84 } })
for _, p in ipairs{ {22, 42}, {23, 41}, {24, 41}, {25, 40}, {31, 44}, {32, 45} } do A.step(c, sidx, SEED, p[1], p[2], -2, stk) end
for _, p in ipairs{ {22, 43}, {24, 42}, {25, 41} } do A.step(c, sidx, SEED, p[1], p[2], 1, stk) end
c:put(27, 47, "#e8c49a", stk) c:put(28, 47, "#b88a66", stk)
local bx, by = A.specAt(sm, sn, 40)
c:put(bx, by, A.CREAM, stk) c:put(bx + 1, by, SEED[6], stk) c:put(bx, by + 1, SEED[6], stk)
-- stem root over the seed rim (sprout emerges from the edge)
c:put(30, 40, STEM[2], stok) c:put(31, 40, STEM[1], stok)

A.save(c, NAME)
