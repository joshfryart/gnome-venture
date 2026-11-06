-- itoh-peony-seed (final pass, Opus single pass). Three round, glossy blue-black peony seeds (violet sheen, cream
-- glints, cool rim) huddled on a torn lanceolate peony leaflet (midrib, swept veins, pale torn tissue on the ripped
-- right end, contact shadow under each seed). A fourth seed has split: pale radicle down, a red peony shoot
-- curving up into the first ternate leaf (two lanceolate side leaflets and a three-lobed middle one).
-- quirk: a fallen yellow Itoh petal with the red basal flare, curled on the torn end of the scrap.
local NAME = "itoh-peony-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_0.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sqrt, max, min, sin, cos, pi = math.floor, math.abs, math.sqrt, math.max, math.min, math.sin, math.cos, math.pi
local c = A.new(NAME)
local LEAF = { "#1a3638", "#234f46", "#2e6b50", "#448c58", "#69ab64", "#a2d083" }
local SEED = { "#140f1e", "#221a32", "#33284a", "#4a3d68", "#6c5e92", "#a597cc" }
local SHOOT = { "#4a1a30", "#76293f", "#a33f52", "#cc6a6e", "#ec9e90" }
local ROOT = { "#b49a7a", "#dcc6a0", "#f4e6c4" }
local PET = { "#b06a1c", "#e09a28", "#f7c43a", "#ffe07a", "#fff2b8" }
local FLARE = "#c23a4a"

-- leaf scrap
local lm, ln, LT, LS, len = A.blade(7, 50, 30, 56, 56, 43, function(t)
  if t > 0.99 then return -1 end
  return max(0.6, 7.2 * sin(pi * min(1, t * 0.8 + 0.1)) ^ 0.7)
end, { fold = 0.34 })
local torn = A.tear(lm, LT, LS, 0.8, { 0.03, -0.05, 0.02, 0.06, -0.03, 0.04, -0.02 })

-- seeds: three on the leaf + the split one
local seeds = { { 15, 46, 3.6 }, { 24, 49, 3.8 }, { 22, 41, 3.4 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[3] - 0.2, 0, 1) end
local sp4 = { 34, 46, 3.6 }
sp4.m, sp4.n = A.oval(sp4[1], sp4[2], sp4[3], sp4[3] - 0.3, 0, 1)

-- shoot (behind the split seed) and radicle
local shoot = { { 35, 44 }, { 40, 36 }, { 31, 29 }, { 36, 21 } }
local stm, stn = A.tube(shoot, function(t) return 0.95 - t * 0.15 end)
local rad = { { 37, 48 }, { 40, 49 }, { 42, 51 }, { 42, 54 } }
local rm, rn = A.tube(rad, function(t) return 0.9 * (1 - t) + 0.25 end)

local bias = {}
local all = HP.mask()
for _, s in ipairs(seeds) do all:add(s.m) end
all:add(sp4.m)
X.ao(bias, lm, all, 1, -1)
A.cast(bias, lm, all, 1, 2, -1)
A.cast(bias, lm, rm, 1, 1, -1)
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = "#b4dc8c", cool = "#3a6c72", per = 5.2, sweep = 4, len = len, bias = bias, torn = torn, tissue = "#cfe6a0" })

-- radicle
rm:cut(sp4.m)
A.shade(c, rm, rn, ROOT, { tok = { r = { name = "root" } }, cuts = { 0.4, 0.7 } })

-- shoot
stm:cut(sp4.m)
local stok = { r = { name = "shoot" } }
A.shade(c, stm, stn, SHOOT, { tok = stok, cuts = { 0.25, 0.45, 0.65, 0.85 }, amb = 0.15 })

-- ternate leaf at the shoot tip
local tx, ty = 36, 21
local ltok = { r = { name = "tleaf" } }
local function leaflet(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.35, w * sin(pi * min(1, t * 0.88 + 0.1)) ^ 0.8)
  end, { fold = 0.36 })
  return { m = m, n = n, T = T, S = S, L = L }
end
local lfs = {
  leaflet(tx - 1, ty, tx - 7, ty - 3, tx - 14, ty - 11, 2.6),   -- left
  leaflet(tx + 1, ty, tx + 9, ty - 2, tx + 16, ty + 4, 2.6),   -- right
  leaflet(tx, ty - 1, tx + 1, ty - 6, tx - 1, ty - 13, 2.3),   -- middle
  leaflet(tx, ty - 5, tx - 3, ty - 7, tx - 7, ty - 10, 1.5),   -- middle side lobes
  leaflet(tx, ty - 5, tx + 3, ty - 7, tx + 6, ty - 10, 1.5),
}
local leafM = HP.mask()
for i, l in ipairs(lfs) do
  local own = l.m:copy():cut(leafM)
  local lb = {}
  if i >= 4 then X.ao(lb, own, lfs[3].m, 1, -1) end
  A.leaf(c, own, l.n, l.T, l.S, { ramp = LEAF, vein = "#b4dc8c", cool = i == 2 and "#3a6c72" or nil, per = 3.2, sweep = 2, len = l.L, bias = lb, veins = i <= 3, t0 = 0.08 })
  own:edge():each(function(x, y) local k = K(x, y) if l.S[k] and l.S[k] > 0.55 and l.T[k] > 0.2 and l.T[k] < 0.92 then c:put(x, y, "#7a3448", ltok) end end)
  leafM:add(l.m)
end
-- red petiole knot where the leaflets meet
A.map(c, { ".a.", "abc", ".c." }, tx - 1, ty - 1, { a = SHOOT[4], b = SHOOT[3], c = SHOOT[2] }, stok)

-- seeds: glossy, sheen, glints
local function paintSeed(s, cover, nm)
  local vis = s.m:copy()
  local sb = {}
  for _, o in ipairs(cover) do vis:cut(o.m) X.ao(sb, s.m, o.m, 1, -1) end
  A.seed(c, vis, s.n, SEED, { bias = sb, tok = { r = { name = nm } }, rim = "#4c6e94", glint = A.CREAM, cuts = { 0.12, 0.3, 0.5, 0.7, 0.88 }, amb = 0.05 })
end
paintSeed(seeds[3], { seeds[1], seeds[2] }, "s3")
paintSeed(seeds[1], {}, "s1")
paintSeed(seeds[2], {}, "s2")
paintSeed(sp4, {}, "s4")
-- the split: a pale cream crack on the sprouting seed's top right, shoot emerging
for _, q in ipairs{ { 35, 43, ROOT[2] }, { 36, 44, ROOT[1] }, { 37, 45, ROOT[2] } } do c:put(q[1], q[2], q[3]) end

-- quirk: curled yellow petal on the torn end
local pm, pn = A.oval(50, 42, 4.8, 3.2, -0.45, 0.8)
pm:add(A.oval(53, 39, 2.6, 2.2, -0.45, 0.8))
for _, q in ipairs{ { 55, 38 }, { 54, 36 } } do pm.s[K(q[1], q[2])] = nil end
local pidx, ptok = A.shade(c, pm, (function() local n = {} pm:each(function(x, y) n[K(x, y)] = pn[K(x, y)] or { A.norm(0.2, -0.6, 0.8) } end) return n end)(), PET, { cuts = { 0.2, 0.4, 0.6, 0.8 }, amb = 0.2 })
-- curl: a darker fold line and a pale rolled lip
for _, q in ipairs{ { 49, 44 }, { 50, 44 }, { 51, 43 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], PET[2], ptok) end end
for _, q in ipairs{ { 52, 38 }, { 53, 38 }, { 54, 38 } } do if pm:has(q[1], q[2]) then c:put(q[1], q[2], PET[5], ptok) end end
-- red flare at the petal base
c:put(47, 43, FLARE, ptok) c:put(48, 43, FLARE, ptok) c:put(47, 42, "#e05a5a", ptok)
A.cast({}, lm, pm, 1, 1, -1)
pm:shift(1, 1):each(function(x, y) if lm:has(x, y) and not pm:has(x, y) and not all:has(x, y) then c:put(x, y, LEAF[1]) end end)
A.save(c, NAME)
