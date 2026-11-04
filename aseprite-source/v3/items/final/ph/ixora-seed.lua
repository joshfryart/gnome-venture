-- ixora-seed (final pass, Opus single pass). A torn, leathery oblong ixora leaf lying on the diagonal (glossy:
-- swept veins, midrib, one glint, pale tissue on the ripped upper-left end). On it: a ripe purple-black ixora drupe
-- with its four-point calyx crown, and two brown plano-convex seeds (one shows the domed back, one the flat grooved
-- face). The middle seed has germinated: a slim stem with a decussate pair of oblong seedling leaves and a tiny
-- second pair folded at the tip.
-- quirk: a fallen scarlet ixora floret (long thin tube, four-petal star) lying across the leaf.
local NAME = "ixora-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#13332e", "#1c4c3a", "#296840", "#3c8846", "#5fa94f", "#99cd67" }
local SEED = { "#3a2220", "#5a3426", "#7d4a2e", "#a0663a", "#c48a52", "#e6b87a" }
local BERRY = { "#1c1022", "#30183a", "#4a2250", "#6c2e62", "#9a4878", "#d088a8" }
local STEM = { "#3f7a4c", "#6ea860", "#a6d080", "#dcefb4" }
local FLOR = { "#7a1e2e", "#b52e3f", "#e8493b", "#ff7a4c", "#ffb27e" }

-- scrap
local lm, ln, LT, LS, len = A.blade(55, 52, 34, 51, 9, 36, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 6.6 * sin(pi * min(1, t * 0.78 + 0.12)) ^ 0.55)
end, { fold = 0.3 })
local torn = A.tear(lm, LT, LS, 0.84, { -0.04, 0.03, -0.02, 0.05, -0.05, 0.02, 0.04 })

-- objects on the leaf
local berry = { 20, 41, 4.2 }
berry.m, berry.n = A.oval(berry[1], berry[2], berry[3], berry[3] - 0.3, 0, 1)
local s1 = { 28, 47, 3.8, 2.6, -0.4 }          -- domed back
s1.m, s1.n = A.oval(s1[1], s1[2], s1[3], s1[4], s1[5], 0.7)
local s2 = { 40, 47, 3.6, 2.5, 0.35 }          -- flat face, sprouting
s2.m, s2.n = A.oval(s2[1], s2[2], s2[3], s2[4], s2[5], 1.6)

-- floret (quirk): tube + star, lies across the right half of the leaf
local tube = { { 45, 53 }, { 47, 52 }, { 50, 50 }, { 52, 47 } }
local fm, fn = A.tube(tube, function(t) return 0.6 end)
local star = HP.mask()
local petals = {}
local fx, fy = 53, 46
for i, d in ipairs{ { -1, -1 }, { 1, -1 }, { 1, 1 }, { -1, 1 } } do
  local m, n = A.oval(fx + d[1] * 2, fy + d[2] * 2, 1.9, 1.2, math.atan(d[2], d[1]), 1)
  petals[i] = { m = m, n = n } star:add(m)
end
star:set(fx, fy)
local all = HP.mask():add(berry.m):add(s1.m):add(s2.m):add(fm):add(star)
local bias = {}
X.ao(bias, lm, all, 1, -1)
A.cast(bias, lm, all, 1, 2, -1)
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = "#a6d47c", cool = "#2e6068", per = 4.6, sweep = 4.5, len = len, bias = bias, torn = torn, tissue = "#cfe49c" })
do local gx, gy = 46, 47 end
c:put(47, 45, "#c8eaa0") c:put(48, 45, "#c8eaa0")

-- sprout stem (from the flat seed), then leaves
local stem = { { 40, 46 }, { 38, 36 }, { 35, 27 }, { 36, 15 } }
local sm, sn = A.tube(stem, function(t) return 0.9 - t * 0.2 end)
sm:cut(s2.m)
local stok = { r = { name = "stem" } }
A.shade(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 } })
local function pair(x, y, L, w, tilt)
  local out = {}
  for _, d in ipairs{ -1, 1 } do
    local m, n, T, S, l = A.blade(x + d, y, x + d * L * 0.55, y - 1 - tilt * 0.6, x + d * L, y - tilt * 2 + 1, function(t)
      if t > 0.985 then return -1 end
      return max(0.4, w * sin(pi * min(1, t * 0.86 + 0.12)) ^ 0.6)
    end, { fold = 0.34 })
    out[#out + 1] = { m = m, n = n, T = T, S = S, L = l }
  end
  return out
end
local ltok = { r = { name = "sleaf" } }
local p1 = pair(36, 25, 14, 3.0, 4.5)
for i, l in ipairs(p1) do
  local m = l.m:copy():cut(sm)
  local lb = {} X.ao(lb, m, sm, 1, -1)
  A.leaf(c, m, l.n, l.T, l.S, { ramp = LEAF, vein = "#a6d47c", cool = "#2e6068", per = 3.4, sweep = 2.5, len = l.L, bias = lb, tok = ltok, t0 = 0.08 })
end
-- tiny folded top pair (upright, like praying hands)
local top = HP.mask()
for _, q in ipairs{ { 34, 12 }, { 34, 13 }, { 35, 13 }, { 35, 14 }, { 37, 11 }, { 37, 12 }, { 36, 13 }, { 37, 13 }, { 36, 14 } } do top:set(q[1], q[2]) end
A.map(c, { "a..b", "ac.b", "dcbe", ".ce." }, 34, 11, { a = LEAF[6], b = LEAF[4], c = LEAF[5], d = LEAF[4], e = LEAF[3] }, ltok)
-- node knots
c:put(36, 24, STEM[1], stok) c:put(36, 23, STEM[2], stok)

-- seeds
local s1tok = { r = { name = "s1" } }
local i1 = A.seed(c, s1.m, s1.n, SEED, { tok = s1tok, glint = SEED[6], cuts = { 0.15, 0.32, 0.5, 0.68, 0.86 }, rim = "#6a5a6a" })
-- flat face: pale with a dark groove along the long axis
local s2tok = { r = { name = "s2" } }
local i2 = A.seed(c, s2.m, s2.n, SEED, { tok = s2tok, cuts = { 0.1, 0.2, 0.4, 0.6, 0.9 } })
do local ca, sa = cos(s2[5]), sin(s2[5])
  s2.m:each(function(x, y) local dx, dy = x - s2[1], y - s2[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v) < 0.5 and abs(u) < 2.6 then c:put(x, y, SEED[2], s2tok) end
    if v < -0.5 and v > -1.6 and u < 1 and u > -2 then c:put(x, y, SEED[6], s2tok) end
  end) end
-- berry: glossy drupe + calyx crown + glints
local btok = { r = { name = "berry" } }
local vis = berry.m:copy()
A.seed(c, vis, berry.n, BERRY, { tok = btok, rim = "#4a5a8a", glint = A.CREAM, glint2 = BERRY[6], cuts = { 0.1, 0.26, 0.44, 0.62, 0.82 }, amb = 0.05 })
A.map(c, { "a.a", ".b.", "aba" }, 19, 36, { a = "#5a7a3a", b = "#2f4a2a" }, btok)

-- floret paint
local ftok = { r = { name = "floret" } }
fm:cut(star)
A.shade(c, fm, fn, FLOR, { tok = ftok, cuts = { 0.25, 0.5, 0.75, 0.9 } })
for i = 1, 4 do
  local own = petals[i].m:copy()
  for j = i + 1, 4 do own:cut(petals[j].m) end
  A.shade(c, own, petals[i].n, FLOR, { tok = ftok, cuts = { 0.15, 0.4, 0.62, 0.84 }, amb = 0.15 })
end
c:put(fx, fy, "#ffd86a", ftok) c:put(fx + 1, fy, FLOR[2], ftok) c:put(fx, fy + 1, FLOR[2], ftok) c:put(fx - 1, fy - 1, FLOR[5], ftok)
A.save(c, NAME)
