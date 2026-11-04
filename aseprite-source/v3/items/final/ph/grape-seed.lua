-- grape-seed (final pass, Opus aB35_4). Two pear-shaped brown grape pips (short beak, pale oval chalaza dimple on the
-- face, glossy glint, contact shadow) lying on a torn scrap of a serrated vine leaf (palmate veins, ragged tear,
-- cool rim). A third pip has germinated: pale root, curved green stem, two oval seed-leaves and a first true leaf
-- that already has the grape's five-lobed, toothed shape.
-- quirk: the seedling's first tendril is already coiling, reaching for a trellis that is not there yet.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_4.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new("grape-seed")
local LEAF = { "#173f33", "#225a3d", "#2f7744", "#46954b", "#68b452", "#98d06a" }
local COT  = { "#24544a", "#3a8049", "#559e4c", "#76bb56", "#a2d46a", "#cdea92" }
local HYP  = { "#3d6236", "#5c8642", "#80aa52", "#a3c66a", "#c5dc8c", "#e4efba" }
local SEED = { "#3e2026", "#5e3128", "#844c2e", "#a96a38", "#cc904c", "#ecbd74" }
local VEIN, COOL, GLINT = "#b7dc84", "#3c6f74", "#fff4d6"

-- pips: cx, cy, half length, half width, beak angle
local pips = {
  { 31.5, 46.5, 4.6, 3.3, 2.6 },
  { 36, 53.5, 4.6, 3.3, 0.5 },
  { 45, 47.5, 4.6, 3.3, 2.2 },  -- germinating (beak down-left)
}
local all = HP.mask()
for _, s in ipairs(pips) do s.m, s.n, s.U = A.drop(s[1], s[2], s[3], s[4], s[5], 0.75) all:add(s.m) end

-- leaf scrap: a vine leaf lying flat, base at the right, lobes reaching left; torn on the lower right
local lm, ln, inf = A.vine(52, 58, -2.62, 26, { sp = 0.66, spread = 2.4 })
lm:each(function(x, y) if x - y * 0.7 > 17 + X.hash(floor(y / 2), 3, 5) * 4 then lm.s[K(x, y)] = nil end end)
lm:each(function(x, y) if y > 60 then lm.s[K(x, y)] = nil end end)
local bias = {}
X.ao(bias, lm, all, 1, -1) A.cast(bias, lm, all, 1, 2, -1) A.cast(bias, lm, all, 2, 2, -1)
A.leafPaint(c, lm, ln, inf, LEAF, { bias = bias, vein = VEIN, tok = A.tok("leaf") })
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and rim[k] > 0.25 and y > 50 then c:put(x, y, COOL) end end)

-- pip painter: 6-tone body, beak darker, chalaza ring on the face, glint
local function pip(s, i)
  local tok = A.tok("pip" .. i)
  local idx = A.shade(c, s.m, s.n, SEED, { tok = tok, amb = 0.1, wrap = 0.25 })
  s.m:each(function(x, y) local u = s.U[K(x, y)]
    if u.u > 0.62 then c:put(x, y, SEED[max(1, idx[K(x, y)] - 1)], tok) end
    -- chalaza: small oval dimple, a bit behind the centre
    local du, dv = (u.u + 0.25) / 0.32, u.v / 0.42
    local q = du * du + dv * dv
    if q < 1 then c:put(x, y, q < 0.35 and SEED[3] or SEED[5], tok) end
  end)
  local gx, gy = A.specAt(s.m, s.n, 30)
  if gx then c:put(gx, gy, GLINT, tok) end
end
pip(pips[1], 1) pip(pips[2], 2)

-- germination: root from the beak, curved stem up to the seed-leaves
local s3 = pips[3]
local bx, by = s3[1] + cos(s3[5]) * s3[3], s3[2] + sin(s3[5]) * s3[3]
local hm, hn = A.tube({ { s3[1] + 0.5, s3[2] - 2 }, { 49, 38 }, { 39, 33 }, { 40, 25 } }, function(t) return 1.05 + 0.25 * (1 - t) end)
local htok = A.tok("hyp")
A.shade(c, hm, hn, HYP, { tok = htok, amb = 0.15, wrap = 0.3 })
pip(s3, 3)
-- split seed coat where the stem came out
c:put(floor(s3[1] + 1), floor(s3[2] - 2), SEED[1])
local root = A.path({ { bx, by + 0.5 }, { bx - 2, by + 2.5 }, { bx - 1.5, by + 5 } })
root:each(function(x, y) c:put(x, y, (y % 2 == 0) and "#f4ecd2" or "#e3d6b0", A.tok("root")) end)

-- seed-leaves
local cots = { { 34, 24, 5.6, 2.8, -0.35 }, { 46, 23.5, 5.6, 2.8, 0.3 } }
local cmk = {}
for i, ct in ipairs(cots) do
  local m, n = A.oval(ct[1], ct[2], ct[3], ct[4], ct[5], 0.7)
  m:cut(hm)
  local b = {} X.ao(b, m, c:ellipse(40, 25, 1.5, 1.5), 1, -1)
  local tok = A.tok("cot" .. i)
  local id = A.shade(c, m, n, COT, { tok = tok, bias = b, amb = 0.12, wrap = 0.3 })
  local ca, sa = cos(ct[5]), sin(ct[5])
  m:each(function(x, y) local dx, dy = x - ct[1], y - ct[2]
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if abs(v) < 0.5 and abs(u) < ct[3] - 1.5 then c:put(x, y, COT[max(1, (id[K(x, y)] or 3) - 1)], tok) end
  end)
  cmk[i] = m
end
-- first true leaf: tiny 5-lobed toothed vine leaf on a short petiole
local tl, tn, ti = A.vine(40, 20.5, -pi / 2 - 0.1, 9.5, { sp = 0.8 })
local tb = {} X.ao(tb, tl, cmk[1], 1, -1) X.ao(tb, tl, cmk[2], 1, -1)
tl:cut(cmk[1]) tl:cut(cmk[2])
A.leafPaint(c, tl, tn, ti, LEAF, { bias = tb, side = false, tok = A.tok("true") })
for y = 20, 24 do c:put(39, y, HYP[4]) c:put(40, y, HYP[2]) end

-- quirk: a coiling tendril reaching out to the right
do
  local pts = { { 41, 31 }, { 45, 29.5 }, { 49, 28 } }
  for i = 0, 40 do local t = i / 40 local a = -pi / 2 + t * 2.6 * pi local r = 3 - t * 1.8
    pts[#pts + 1] = { 52 + cos(a) * r, 28 + r + sin(a) * r } end
  local tt = A.tok("tendril")
  A.path(pts):each(function(x, y) c:put(x, y, ((x + y) % 3 == 0) and HYP[2] or HYP[4], tt) end)
end
A.save(c, "grape-seed")
