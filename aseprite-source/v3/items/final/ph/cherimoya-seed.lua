-- cherimoya-seed (final, Opus single pass). Two glossy black-brown cherimoya beans (elongated, slightly flattened, a
-- pale hilum notch at one end, bright specular + cool reflected rim) lie on an arched scrap of cherimoya leaf (elliptic
-- leaf, V-fold light, midrib + curving pinnate veins, jagged torn lower edge, AO + contact shadow under each bean).
-- A third bean has germinated: a white root curls over the scrap, a pale stem rises to a pair of elliptic pointed true
-- leaves (the cherimoya leaf shape) around a tight green bud.
-- quirk: the bud is still wearing its seed coat like a little glossy brown hat.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aB1r1_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "cherimoya-seed"
local c = A.new(NAME)

local LEAF = { "#1a4038", "#255a42", "#347648", "#4d9350", "#74b25a", "#a6d17a" }
local BEAN = { "#1c1014", "#301a1c", "#4a2824", "#6a3a2a", "#90553a", "#ba7a55" }
local STEM = { "#5a8c5a", "#8cbc72", "#bcdc98", "#e4f2c2" }
local TRUE = { "#1d4a38", "#2c6842", "#43884a", "#62a652", "#8ec466", "#bfe08a" }
local ROOT = { "#a89c86", "#d8ccb0", "#f0e6cc", "#fbf5e4" }

-- beans
local beans = { { 17, 46, 5.2, 2.6, 0.32 }, { 42, 47, 5.0, 2.5, -0.42 } }
for _, b in ipairs(beans) do b.m, b.n = A.oval(b[1], b[2], b[3], b[4], b[5], 0.8) end
-- sprout masks
local stemPts = { { 29, 47 }, { 28, 40 }, { 31, 33 }, { 30, 25 } }
local sm, sn = A.tube(stemPts, function(t) return 1.2 - 0.25 * t end)
local rootPts = { { 29, 48 }, { 27, 52 }, { 24, 53 }, { 22, 51 } }
local rm, rn = A.tube(rootPts, function(t) return 1.0 - 0.6 * t end)

-- leaf scrap: arched elliptic blade, jagged torn lower edge
local bias = {}
local ltok = { r = { name = "leaf" } }
local LT, LS, len
local lm = A.leaf(c, 8, 51, 31, 41, 55, 51, 8.4, LEAF, { fold = 0.5, vs = 3.6, bias = bias, tok = ltok, pw = 0.55,
  pre = function(m, T, S, L)
    LT, LS, len = T, S, L
    local cut = {}
    m:each(function(x, y) local k = K(x, y)
      local lim = 0.62 + 0.22 * X.hash(floor(T[k] * L / 2.2), 1, 3)
      if S[k] > lim and T[k] > 0.12 and T[k] < 0.9 then cut[#cut + 1] = k end
    end)
    for _, k in ipairs(cut) do m.s[k] = nil end
    for _, b in ipairs(beans) do X.ao(bias, m, b.m, 1, -1) A.cast(bias, m, b.m, 1, 2, -1) end
    A.cast(bias, m, rm, 1, 1, -1) A.cast(bias, m, sm, 1, 1, -1)
  end })
-- torn edge: pale fibre; lit rim: cool bounce on the shade side
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.55 and LT[k] > 0.12 and LT[k] < 0.9 then c:put(x, y, "#c9e39c", ltok)
  elseif LS[k] > 0.5 then c:put(x, y, "#3c6e74", ltok) end
end)

-- root + stem
A.shade(c, rm, rn, ROOT, { cuts = { 0.3, 0.55, 0.8 }, tok = { r = { name = "root" } } })
c:put(21, 50, ROOT[2])
local stok = { r = { name = "stem" } }
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- true leaves: elliptic, pointed, pinnate veins
local ttok = { r = { name = "true" } }
local l1 = A.leaf(c, 29, 29, 22, 22, 13, 24, 3.8, TRUE, { fold = 0.45, vs = 2.6, tok = ttok, pw = 0.7, cut = sm })
local l2 = A.leaf(c, 31, 28, 38, 20, 47, 20, 3.8, TRUE, { fold = 0.45, vs = 2.6, tok = ttok, pw = 0.7, cut = sm:copy():add(l1) })
-- bud
local bud = A.rell(30.5, 22.5, 0, -1, 2.6, 1.7)
bud:cut(l1):cut(l2)
A.shade(c, bud, X.sphere(30, 22, 2.4, bud), TRUE, { tok = ttok, amb = 0.12 })

-- quirk: seed-coat hat on the bud
local hat, hn = A.oval(30.8, 19.6, 3.4, 2.1, -0.22, 0.8)
local hb = {}
local hidx = A.shade(c, hat, hn, BEAN, { tok = { r = { name = "hat" } }, amb = 0.05, wrap = 0.2 })
-- split lower lip of the coat (pale inner skin)
for _, q in ipairs{ { 28, 21 }, { 29, 22 }, { 32, 22 }, { 33, 21 } } do if hat:has(q[1], q[2]) then c:put(q[1], q[2], "#c99a72") end end
c:put(29, 18, "#fff1dc") c:put(30, 18, BEAN[6])

-- beans last
for i, b in ipairs(beans) do
  local tok = { r = { name = "bean" .. i } }
  local idx = A.shade(c, b.m, b.n, BEAN, { tok = tok, amb = 0.04, wrap = 0.2 })
  local rim = X.rim(b.n)
  b.m:edge():each(function(x, y) if rim[K(x, y)] > 0.55 then c:put(x, y, "#5a4a6e", tok) end end)
  -- hilum: pale notch at the narrow end
  local ca, sa = cos(b[5]), sin(b[5])
  local hx, hy = floor(b[1] + ca * (b[3] - 0.6) + 0.5), floor(b[2] + sa * (b[3] - 0.6) + 0.5)
  c:put(hx, hy, "#d9b48a", tok) c:put(hx - 1, hy, BEAN[3], tok)
  -- glossy specular streak (2x1 cream + hi tail)
  local sx, sy = A.specAt(b.m, b.n, 30)
  c:put(sx, sy, "#fff1dc", tok) c:put(sx + 1, sy, "#fff1dc", tok) c:put(sx + 2, sy, BEAN[6], tok) c:put(sx, sy + 1, BEAN[5], tok)
end
A.save(c, NAME)
