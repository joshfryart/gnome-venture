-- choca-mocha-cosmos-seed (final, Opus single pass). Two slim milk-mocha cosmos achenes crossed in an X (ribbed, a pale
-- cream ridge, dark forked awn tips) on a broad bronze-green leaf scrap (ovate, dark midrib, paired veins, maroon-tinged
-- margin, cool lower-right rim, pale ragged tear on the left end, AO + contact shadows). A third seed on the left has
-- sprouted: pale stem curving up, two strap cotyledons and a first three-lobed true leaf of the compact Choca Mocha.
-- quirk: a single glossy coffee bean has rolled in among the seeds.
local NAME = "choca-mocha-cosmos-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#1b3530", "#284a38", "#3a633e", "#557e44", "#7c9c52", "#a9bf6e" }
local VEIN, RIB, EDGE, COOL, TORN = "#cfdc94", "#22402f", "#6e3a3a", "#3e5f6e", "#e2e6a8"
local SEED = { "#200f10", "#3a1d18", "#5a3022", "#7a4a30", "#a06a44", "#e0b680" }
local AWN = { "#4a2a1e", "#8e6a44" }
local STEM = { "#5a7f50", "#93b46c", "#c2d896", "#e8f0c0" }
local BEAN = { "#24110e", "#3e1d14", "#5e2e1c", "#7e4226", "#a35e34", "#d79a62" }
local CUTS = { 0.2, 0.36, 0.52, 0.68, 0.84 }

local sw = function(t) return max(0.4, 2.35 * sin(pi * min(1, 0.12 + t * 0.95)) ^ 0.6) end
local seeds = {
  { { 17, 51 }, { 17, 48 }, { 17, 44 }, { 17, 40 } },          -- sprouting
  { { 22, 41 }, { 27, 45 }, { 32, 49 }, { 38, 53 } },
  { { 21, 53 }, { 26, 50 }, { 31, 46 }, { 37, 42 } },
}
local smask = {}
for i, p in ipairs(seeds) do smask[i] = A.tube(p, sw) end
local bm = A.rell(46.5, 47.5, 0.94, -0.34, 3.6, 2.6)

-- broad leaf scrap: base on the right, torn tip on the left
local lm, ln, LT, LS, len = A.blade(54, 50, 32, 59, 9, 47, function(t)
  if t > 0.985 then return -1 end
  return max(0.6, 8.8 * sin(pi * min(1, t * 0.85 + 0.12)) ^ 0.5)
end, { fold = 0.32 })
local torn = A.tear(lm, LT, LS, 0.8, 0.05, 23, -0.05)
local bias = {}
for _, m in ipairs(smask) do X.ao(bias, lm, m, 1, -1) A.cast(bias, lm, m, 1, 2, -1) end
X.ao(bias, lm, bm, 1, -1) A.cast(bias, lm, bm, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.12, 0.27, 0.43, 0.6, 0.78 }, amb = 0.18, wrap = 0.3 })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.12 and t > 0.02 then c:put(x, y, s <= 0 and VEIN or RIB, ltok) return end
  local d = (t * len + abs(s) * 6) % 7.5
  if d < 0.9 and abs(s) > 0.15 and abs(s) < 0.75 then c:put(x, y, s < 0 and LEAF[6] or LEAF[2], ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if LS[k] > 0.6 then c:put(x, y, COOL, ltok) elseif LS[k] < -0.55 and (x + y) % 3 ~= 0 then c:put(x, y, EDGE, ltok) end end)
torn:each(function(x, y) if not bias[K(x, y)] then c:put(x, y, TORN, ltok) end end)
for _, q in ipairs{ { 55, 50, 3 }, { 56, 50, 2 }, { 57, 51, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout
local stok = { r = { name = "stem" } }
local sp = { { 17, 41 }, { 17, 33 }, { 20, 27 }, { 21, 18 } }
local sm, sn = A.tube(sp, function(t) return 1.05 end)
X.tone(c, sm, X.light(sn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function strap(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S = A.blade(ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    return max(0.4, w * sin(pi * min(1, t * 0.85 + 0.15)) ^ 0.45)
  end, { fold = 0.3 })
  m:cut(sm)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = CUTS, amb = 0.16, wrap = 0.3 })
  m:each(function(x, y) local k = K(x, y) if abs(S[k]) < 0.14 and T[k] > 0.1 and T[k] < 0.85 then c:put(x, y, S[k] <= 0 and LEAF[6] or LEAF[3], ltok) end end)
  return m
end
local cl = strap(19, 28, 14, 26, 8, 21, 1.7)
local cr = strap(21, 28, 27, 28, 33, 24, 1.7)
-- three-lobed true leaf on the stem tip
local tl = HP.mask()
for _, q in ipairs{ { 0, -1, 4.6 }, { -0.95, -0.35, 3.6 }, { 0.95, -0.35, 3.6 } } do
  local ux, uy = q[1], q[2] local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  tl:add(A.rell(21 + ux * q[3] * 0.65, 19 + uy * q[3] * 0.65, ux, uy, q[3] * 0.72, 1.35))
end
tl:cut(cl):cut(cr)
A.toneN(c, tl, X.pillow(tl, 1.5), LEAF, { tok = ltok, cuts = CUTS, amb = 0.14, wrap = 0.25 })
c:put(21, 18, LEAF[3]) c:put(21, 17, LEAF[6]) c:put(21, 16, LEAF[6]) c:put(20, 19, LEAF[3]) c:put(22, 19, LEAF[3])
for i = 0, 20 do local x, y = A.bez(sp, i / 20) if i < 19 then c:put(floor(x + .5), floor(y + .5), i < 3 and STEM[2] or STEM[3], stok) end end

-- seeds: the first (sprouting) and the X pair, upper one last
for i, p in ipairs(seeds) do
  local b = {}
  for j = i + 1, #seeds do X.ao(b, smask[i], smask[j], 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  local m, n, T, S = A.needle(c, p, sw, SEED, tok, { 0.05, 0.55 }, b)
  m:each(function(x, y) local k = K(x, y) if S[k] < -0.3 and S[k] > -0.7 and T[k] > 0.2 and T[k] < 0.65 and not b[k] then c:put(x, y, SEED[6], tok) end end)
  if i > 1 then
    local x, y = p[4][1], p[4][2]
    local dx, dy = p[4][1] - p[3][1], p[4][2] - p[3][2]
    local l = sqrt(dx * dx + dy * dy) dx, dy = dx / l, dy / l
    for s = 1, 2 do
      local a1x, a1y = A.rot(dx, dy, -0.6) local a2x, a2y = A.rot(dx, dy, 0.6)
      c:put(floor(x + a1x * (s + 0.6) + .5), floor(y + a1y * (s + 0.6) + .5), AWN[2], tok)
      c:put(floor(x + a2x * (s + 0.6) + .5), floor(y + a2y * (s + 0.6) + .5), AWN[1], tok)
    end
  end
end

-- quirk: glossy coffee bean, S-shaped crease
local btok = { r = { name = "bean" } }
local bn = X.pillow(bm, 2.2)
X.tone(c, bm, X.light(bn, { amb = 0.1, wrap = 0.25 }), BEAN, { cuts = CUTS, tok = btok })
for _, q in ipairs{ { 43, 49 }, { 44, 48 }, { 45, 48 }, { 46, 47 }, { 47, 47 }, { 48, 46 }, { 49, 46 }, { 50, 45 } } do c:put(q[1], q[2], BEAN[1], btok) end
c:put(44, 46, BEAN[6]) c:put(45, 46, A.CREAM)
c:put(20, 47, A.CREAM)
A.save(c, NAME)
