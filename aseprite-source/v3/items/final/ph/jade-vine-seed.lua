-- jade-vine-seed (final pass, Opus single pass). A torn glossy jade-vine leaflet scrap lying on the diagonal (6-tone,
-- midrib, swept veins, cool rim, pale torn tissue on the ripped left end). On it: two big glossy brown bean-like
-- jade-vine seeds (domed, pale hilum scar, glint) and a third that has germinated: a slim twining stem, a curled
-- tendril and a trifoliate leaf of three slim pointed leaflets (the jade vine's leaf shape), AO where they meet.
-- quirk: one fallen claw-shaped flower in that unreal jade-turquoise lies across the scrap.
local NAME = "jade-vine-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#13332e", "#1c4c3a", "#296840", "#3c8846", "#5fa94f", "#99cd67" }
local SLEAF = { "#173f36", "#21583e", "#2f7446", "#45924c", "#6cb256", "#a6d474" }
local SEED = { "#2a1418", "#4a2220", "#6e3626", "#94502e", "#b8743e", "#e0a86a" }
local STEM = { "#3f6a44", "#6e9a58", "#a6c87a", "#d8ecb0" }
local CLAW = { "#123a48", "#16666c", "#1c9890", "#34c8ac", "#7aecc8", "#c8fff0" }
local CALYX = { "#2a1a3a", "#4a2e5e", "#6e4a86" }

-- scrap
local lm, ln, LT, LS, len = A.blade(56, 49, 34, 49, 8, 37, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 6.4 * sin(pi * min(1, t * 0.78 + 0.12)) ^ 0.55)
end, { fold = 0.3 })
local torn = A.tear(lm, LT, LS, 0.85, { -0.03, 0.04, -0.02, 0.05, -0.05, 0.02, 0.04 })

-- seeds
local s1 = { 17, 41, 4.0, 2.7, -0.35 }
local s2 = { 27, 46, 4.0, 2.8, 0.1 }
local s3 = { 38, 46, 3.6, 2.6, -0.15 }       -- sprouting
for _, s in ipairs{ s1, s2, s3 } do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.75) end

-- claw flower (quirk): curved tapering claw on the right of the leaf
local claw = { { 46, 49 }, { 46, 40 }, { 54, 36 }, { 57, 43 } }
local cm, cn, CT, CS = A.tube(claw, function(t) return max(0.45, 3.2 * (1 - t) ^ 0.75) end)
local calm = HP.mask()
for _, q in ipairs{ { 45, 49 }, { 46, 49 }, { 47, 49 }, { 45, 50 }, { 46, 50 }, { 47, 50 }, { 46, 51 }, { 44, 50 } } do calm:set(q[1], q[2]) end

local on = HP.mask():add(s1.m):add(s2.m):add(s3.m):add(cm):add(calm)
local bias = {}
X.ao(bias, lm, on, 1, -1)
A.cast(bias, lm, on, 1, 2, -1)
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = "#a6d47c", cool = "#2e6068", per = 4.4, sweep = 4.5, len = len, bias = bias, torn = torn, tissue = "#cfe49c" })
c:put(51, 47, "#c8eaa0") c:put(52, 47, "#c8eaa0")

-- sprout: twining stem from the sprouting seed
local stem = { { 38, 45 }, { 42, 35 }, { 31, 27 }, { 35, 16 } }
local sm, sn = A.tube(stem, function(t) return 0.95 - t * 0.25 end)
sm:cut(s3.m)
local stok = { r = { name = "stem" } }
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
-- trifoliate leaf: terminal + two laterals (slim, pointed)
local ltok = { r = { name = "sleaf" } }
local leaflets = {
  { 35, 15, 25, 15, 21, 10, 2.8 },  -- left lateral
  { 36, 15, 46, 15, 49, 9, 2.8 },   -- right lateral
  { 35, 14, 33, 9, 37, 3, 3.1 },    -- terminal (front)
}
local lfm = HP.mask()
for _, Lf in ipairs(leaflets) do
  local m, n, T, S, l = A.blade(Lf[1], Lf[2], Lf[3], Lf[4], Lf[5], Lf[6], function(t)
    if t > 0.985 then return -1 end
    if t < 0.08 then return 0.5 end
    return max(0.4, Lf[7] * sin(pi * min(1, (t - 0.08) * 0.9 + 0.1)) ^ 0.7)
  end, { fold = 0.36 })
  local vis = m:copy():cut(sm)
  local lb = {} X.ao(lb, vis, lfm, 1, -1) X.ao(lb, vis, sm, 1, -1)
  A.leaf(c, vis, n, T, S, { ramp = SLEAF, vein = "#b0dc84", cool = "#2e6068", per = 3.2, sweep = 2.4, len = l, bias = lb, tok = ltok, t0 = 0.12 })
  lfm:add(vis)
end
-- node knot where leaflets join
c:put(35, 15, STEM[1], stok) c:put(36, 15, STEM[2], stok) c:put(35, 16, STEM[1], stok)
-- tendril curl off the stem (thin, 1 px)
local ttok = { r = { name = "tendril" } }
for _, q in ipairs{ { 41, 33, 3 }, { 42, 32, 3 }, { 43, 31, 3 }, { 44, 30, 3 }, { 45, 30, 2 }, { 46, 31, 2 }, { 46, 32, 2 }, { 45, 33, 1 }, { 44, 32, 2 } } do
  c:put(q[1], q[2], STEM[q[3]], ttok) end
-- small seed-leaf scar (cotyledon stub) low on the stem
c:put(40, 41, SLEAF[5], stok) c:put(41, 41, SLEAF[4], stok) c:put(41, 40, SLEAF[3], stok)

-- seeds paint: domed, hilum scar, glint
for i, s in ipairs{ s1, s2, s3 } do
  local tok = { r = { name = "seed" .. i } }
  local b = {}
  if i == 3 then X.ao(b, s.m, sm, 1, -1) end
  A.seed(c, s.m, s.n, SEED, { tok = tok, bias = b, glint = SEED[6], cuts = { 0.22, 0.4, 0.58, 0.76, 0.92 }, rim = "#5a5a72" })
  local ca, sa = cos(s[5]), sin(s[5])
  s.m:each(function(x, y) local dx, dy = x - s[1], y - s[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if v > 1.1 and v < 1.9 and abs(u) < 1.1 then c:put(x, y, (u < 0) and "#e8cc98" or "#c4a070", tok) end -- hilum
  end)
  local gx, gy = floor(s[1] - s[3] * 0.45 + 0.5), floor(s[2] - s[4] * 0.5 + 0.5)
  c:put(gx, gy, "#fff4d6", tok)
end
-- split seed coat where the sprout emerges
c:put(38, 44, SEED[1], { r = { name = "seed3" } }) c:put(37, 44, "#e8cc98", { r = { name = "seed3" } })

-- claw flower paint
local ftok = { r = { name = "claw" } }
local v = X.light(cn, { amb = 0.08, wrap = 0.3 })
local idx = X.tone(c, cm, v, CLAW, { cuts = { 0.16, 0.32, 0.5, 0.68, 0.86 }, tok = ftok })
-- keel crease along the inner curve
cm:each(function(x, y) local k = K(x, y) if CS[k] > 0.35 and CS[k] < 0.7 and CT[k] < 0.8 then c:put(x, y, CLAW[max(1, idx[k] - 1)], ftok) end end)
c:put(45, 42, CLAW[6], ftok) c:put(45, 41, "#fff4d6", ftok)
local catok = { r = { name = "calyx" } }
calm:each(function(x, y) c:put(x, y, (x + y) % 2 == 0 and CALYX[2] or CALYX[1], catok) end)
c:put(45, 49, CALYX[3], catok)
A.save(c, NAME)
