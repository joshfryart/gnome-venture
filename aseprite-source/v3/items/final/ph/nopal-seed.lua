-- nopal-seed (C3, Opus single pass): three prickly-pear seeds (hard pale-tan lentils, thick bony rim, dished centre) on
-- a torn scrap of nopal pad (blue-green waxy skin, felt areoles, ripped end showing pale juicy flesh). The right seed has
-- germinated into a cactus seedling: a fleshy hypocotyl, two plump pink-tipped cotyledons and a first tiny paddle with
-- areoles and spines, showing the nopal shape.
-- quirk: one seed still wears a dab of magenta tuna pulp.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC30_3.lua")
local HP, X, K, B = A.HP, A.X, A.K, A.B
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("nopal-seed")
local PAD = { "#173a3a", "#1f5246", "#2b6e50", "#43905a", "#6db468", "#a6d88a" }
local FL = { "#8fb86a", "#bcd88e", "#e2f0b8" }
local SEED = { "#5a4030", "#86684a", "#ae9068", "#ccb088", "#e6d0a8", "#faecc8" }
local STEM = { "#5e7a4a", "#86a45e", "#b0c87e", "#d8e6a8" }
local FELT, SPINE = "#efe2b0", "#fff4d6"

-- pad scrap
local LP = { { 8, 52 }, { 20, 48 }, { 36, 48 }, { 56, 44 } }
local pm, pn, PT, PS = A.tube(LP, function(t)
  if t > 0.98 then return -1 end
  return max(0.5, 6.4 * sin(pi * min(1, t * 0.75 + 0.18)) ^ 0.5)
end, { flat = 0.6 })
local rip = HP.mask()
pm:each(function(x, y) if x > 50 - floor(X.hash(0, y, 9) * 3) - (y % 2) then rip:set(x, y) end end)
pm:cut(rip)
local seeds = { { 16, 48, 3.3, 2.7, 0.2 }, { 25.5, 49.5, 3.3, 2.7, -0.15 }, { 37, 46, 3.1, 2.6, 0 } }
local bias = {}
for _, s in ipairs(seeds) do s.m = A.ell(s[1], s[2], s[3], s[4], s[5]) X.ao(bias, pm, s.m, 1, -1) end
local ptok = A.tok("pad")
local pn2 = X.pillow(pm, 3)
local n = {}
pm:each(function(x, y) local k = K(x, y) local a, b = pn2[k], pn[k]
  local nx, ny, nz = a[1] + b[1] * 0.5, a[2] + b[2] * 0.5, a[3] + b[3]
  local l = sqrt(nx * nx + ny * ny + nz * nz) n[k] = { nx / l, ny / l, nz / l } end)
local idx = A.toneN(c, pm, n, PAD, { tok = ptok, bias = bias, amb = 0.12, wrap = 0.3 })
-- torn end: juicy flesh, 2 px deep
pm:each(function(x, y)
  if rip:has(x + 1, y) or rip:has(x + 1, y - 1) then c:put(x, y, (y % 3 == 0) and FL[1] or FL[3], ptok)
  elseif rip:has(x + 2, y) then c:put(x, y, FL[2], ptok) end
end)
-- areoles on the scrap (felt dot + dimple + glochid)
for _, q in ipairs{ { 12, 48 }, { 20, 45 }, { 31, 44 }, { 44, 43 }, { 21, 53 }, { 33, 51 }, { 45, 49 } } do
  local x, y = q[1], q[2]
  if pm:has(x, y) and not bias[K(x, y)] then
    c:put(x, y, FELT, ptok)
    if pm:has(x + 1, y + 1) then c:put(x + 1, y + 1, PAD[max(1, (idx[K(x + 1, y + 1)] or 3) - 1)], ptok) end
    if pm:has(x - 1, y - 1) and y < 47 then c:put(x - 1, y - 1, SPINE, ptok) end
  end
end
-- cool reflected light on the lower edge, waxy specular
pm:edge():each(function(x, y) local k = K(x, y) if PS[k] and PS[k] > 0.72 and PT[k] > 0.2 and not bias[k] and not rip:has(x + 1, y) then c:put(x, y, "#4a8a88", ptok) end end)
c:put(41, 42, A.CREAM, ptok) c:put(42, 42, PAD[6], ptok)

-- seedling: hypocotyl, cotyledons, first paddle
local stok = A.tok("stem")
local sm, sn = A.tube({ { 37, 45 }, { 36, 40 }, { 38, 35 }, { 37, 30 } }, function(t) return 1.3 - 0.2 * t end, { N = 40 })
A.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.52, 0.76 } })
local ctok = A.tok("coty")
local CO = { "#1f5246", "#2b6e50", "#43905a", "#6db468", "#a6d88a", "#d4f0a8" }
local function coty(p)
  local m, cn, T, S = A.tube(p, function(t) return 1.2 + 1.5 * sin(pi * min(1, t * 0.85 + 0.1)) end, { N = 40 })
  m:cut(sm)
  A.toneN(c, m, cn, CO, { tok = ctok, amb = 0.12, wrap = 0.3 })
  m:each(function(x, y) if T[K(x, y)] > 0.84 then c:put(x, y, S[K(x, y)] < 0 and "#f08aa8" or "#c84a72", ctok) end end)
  return m
end
local c1 = coty({ { 36, 32 }, { 33, 31 }, { 30, 30 }, { 27, 27 } })
local c2 = coty({ { 38, 32 }, { 41, 31 }, { 44, 30 }, { 47, 27 } })
-- first paddle: small obovate pad with areoles and spines
local pad = A.ell(37, 21, 3.8, 6.6, 0.12)
local pdb = {}
X.ao(pdb, pad, c1:copy():add(c2), 1, -1)
local ktok = A.tok("paddle")
local kidx = A.toneN(c, pad, X.pillow(pad, 2.6), PAD, { tok = ktok, bias = pdb, amb = 0.12, wrap = 0.3 })
for _, q in ipairs{ { 36, 17 }, { 38, 20 }, { 36, 23 }, { 38, 26 } } do
  c:put(q[1], q[2], FELT, ktok)
  c:put(q[1] + 1, q[2] + 1, PAD[max(1, (kidx[K(q[1] + 1, q[2] + 1)] or 3) - 1)], ktok)
end
-- spines out of the paddle rim (1 px each)
c:put(35, 14, "#d8cc9c", ktok) c:put(41, 17, "#d8cc9c", ktok) c:put(33, 21, "#d8cc9c", ktok)
c:put(35, 18, PAD[6], ktok)
-- contact shadow of the paddle on the stem top
c:put(37, 29, STEM[1], stok)

-- seeds last: bony rim, dished centre
for i, s in ipairs(seeds) do
  local tok = A.tok("seed" .. i)
  A.seed(c, s[1], s[2], s[3], s[4], s[5], SEED, { shadow = PAD[1], clip = pm, tok = tok, dent = 0.5 })
  c:put(floor(s[1] - s[3] * 0.5), floor(s[2] - s[4] * 0.55), A.CREAM, tok)
end
-- sprouting seed: coat split around the hypocotyl
c:put(37, 44, STEM[3], stok) c:put(36, 44, SEED[1], A.tok("seed3")) c:put(38, 44, SEED[2], A.tok("seed3"))
-- quirk: magenta tuna pulp on seed 2
local mt = A.tok("seed2")
c:put(27, 48, "#e8508a", mt) c:put(28, 48, "#c8306a", mt) c:put(27, 47, "#ff8ab0", mt) c:put(28, 49, "#8e1e50", mt)
A.shift(c, 4, 0)
A.fin()
