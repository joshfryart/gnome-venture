-- cabbage-seed (final pass, Opus aB13_4). Four tiny round cabbage seeds (glossy red-brown spheres, one glint each,
-- AO + contact shadow) on a torn scrap of waxy blue-green cabbage leaf (thick pale midrib, pale branching veins, ragged
-- pale torn edge on the left, cool lower-right rim). The fifth seed has germinated: split coat, pale stem, two
-- kidney-shaped brassica seed-leaves (notched tips) on short stalks and a first crinkled true leaf.
-- quirk: a round water bead sits on the waxy leaf without wetting it.
local NAME = "cabbage-seed"
local M = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB13_4.lua")
local HP, X, K = M.HP, M.X, M.K
local floor, max, min, abs, sin, cos, pi, sqrt = math.floor, math.max, math.min, math.abs, math.sin, math.cos, math.pi, math.sqrt
local c = M.new(NAME)

local LEAF = { "#183c44", "#22564e", "#2f705a", "#468c68", "#68a87e", "#98c8a0" }
local VEIN, TORN, COOL = "#cfe8c0", "#e2f0c4", "#3e6e84"
local SEED = { "#2a141c", "#481e26", "#6c2c2e", "#904234", "#b4603e", "#d68c5c" }
local STEM = { "#5a8c58", "#86b46a", "#b4d690", "#e0f0c0" }
local COT = { "#1f4e44", "#2c6c50", "#3e8a5a", "#5ca868", "#86c47c", "#b8e09a" }

local seeds = { { 18, 48, 2.3 }, { 24, 52, 2.3 }, { 29, 46.5, 2.4 }, { 35, 51, 2.3 } }
local sprout = { 41, 45, 2.6 }
local allS = HP.mask()
for _, s in ipairs(seeds) do s.m = c:ellipse(s[1], s[2], s[3], s[3]) allS:add(s.m) end
local spm = c:ellipse(sprout[1], sprout[2], sprout[3], sprout[3] - 0.3) allS:add(spm)

-- leaf scrap: broad cabbage leaf piece, torn on the left and nibbled bottom-right
local lm, ln, LT, LS, len = M.blade(6, 55, 30, 44, 57, 40, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 10 * sin(pi * min(1, t * 0.8 + 0.2)) ^ 0.55 * (1 - 0.06 * abs(sin(t * 7 * pi))))
end, { fold = 0.3 })
local torn = M.tear(lm, 12, 50, -1, -0.35, 1.6, 3)
local torn2 = M.tear(lm, 44, 55, 0.4, 1, 1.2, 5)
local bias = {}
X.ao(bias, lm, allS, 1, -1) M.cast(bias, lm, allS, 1, 1, -1) M.cast(bias, lm, allS, 1, 2, -1)
local ltok = { r = { name = "leaf" } }
local lidx = M.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.1, wrap = 0.25, cuts = { 0.3, 0.46, 0.62, 0.77, 0.9 } })
lm:each(function(x, y) local k = K(x, y) local s, t = LS[k], LT[k]
  if bias[k] then return end
  if abs(s) < 0.1 then c:put(x, y, VEIN, ltok) return end
  if s > 0.1 and s < 0.2 then c:put(x, y, LEAF[max(1, lidx[k] - 1)], ltok) return end
  local ph = (t * len - abs(s) * 7) / 6.5
  if abs(ph - floor(ph + .5)) < 0.08 and abs(s) > 0.15 and abs(s) < 0.85 then c:put(x, y, s < 0 and VEIN or LEAF[min(6, lidx[k] + 1)], ltok) end
end)
local rim = X.rim(ln)
lm:edge():each(function(x, y) local k = K(x, y) if not bias[k] and rim[k] > 0.3 and not torn:has(x, y) then c:put(x, y, COOL, ltok) end end)
torn:each(function(x, y) c:put(x, y, TORN, ltok) end)
torn2:each(function(x, y) c:put(x, y, LEAF[5], ltok) end)

-- quirk: water bead on the waxy leaf
M.bead(c, 49.5, 43.5, 2.2, { nil, "#3f7c78", "#7cbcb4", "#acdcd2", "#d4f4ea" })
c:put(51, 46, LEAF[2], ltok) c:put(52, 45, LEAF[2], ltok)

-- sprout stem, petioles, seed-leaves, true leaf
local stok = { r = { name = "stem" } }
local sm, sn = M.tube({ { 41, 43 }, { 42, 36 }, { 38, 30 }, { 38, 23 } }, function(t) return 1.05 end)
sm:cut(spm)
M.toneN(c, sm, sn, STEM, { tok = stok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
local pl = M.tube({ { 38, 23 }, { 36, 22 }, { 34, 21.5 }, { 32, 21.5 } }, function() return 0.7 end)
local pr = M.tube({ { 38, 23 }, { 40, 22 }, { 42, 21 }, { 44, 20.5 } }, function() return 0.7 end)
pl:add(pr) pl:each(function(x, y) c:put(x, y, STEM[3], stok) end)
local function kidney(cx, cy, rx, ry, ang, nx, ny)
  local m, n = M.oval(cx, cy, rx, ry, ang, 0.7)
  m:cut(c:ellipse(nx, ny, 1.2, 1.2))
  local tok = { r = { name = "cot" } }
  local b = {} X.ao(b, m, sm:grow(1), 1, -1)
  local id = M.toneN(c, m, n, COT, { tok = tok, bias = b, amb = 0.12, wrap = 0.3 })
  -- midrib to the notch
  local ca, sa = cos(ang), sin(ang)
  m:each(function(x, y) local u, v = (x - cx) * ca + (y - cy) * sa, -(x - cx) * sa + (y - cy) * ca
    if abs(v) < 0.5 and abs(u) < rx - 1.5 then c:put(x, y, COT[min(6, (id[K(x, y)] or 3) + 1)], tok) end end)
  local rm = X.rim(n)
  m:edge():each(function(x, y) if rm[K(x, y)] > 0.35 then c:put(x, y, COT[2], tok) end end)
  local bx, by = M.specAt(m, n, 25) c:put(bx, by, COT[6], tok)
  return m
end
local kl = kidney(27.5, 21, 5, 3.4, -0.2, 22.6, 20)
local kr = kidney(48.5, 19.5, 5, 3.4, 0.2, 53.4, 20.5)
-- first true leaf: small crinkled oval with a pale midrib
do
  local m, n = M.oval(38.5, 15.5, 2.6, 3.6, 0.1, 0.6)
  m:cut(c:ellipse(36, 13, 0.5, 0.5)):cut(c:ellipse(41, 16, 0.5, 0.5))
  local tok = { r = { name = "true" } }
  local id = M.toneN(c, m, n, COT, { tok = tok, amb = 0.15, wrap = 0.3 })
  for y = 14, 19 do c:put(38, y, COT[6], tok) end
  c:put(37, 16, COT[2], tok) c:put(39, 17, COT[3], tok)
  for y = 19, 22 do c:put(38, y, STEM[3], stok) end
end

-- seeds last: glossy spheres
for i, s in ipairs(seeds) do
  local b = {} for j = i + 1, #seeds do X.ao(b, s.m, seeds[j].m, 1, -1) end
  M.ball(c, s[1], s[2], s[3], s[3], 0, SEED, { bias = b, tok = { r = { name = "seed" .. i } }, glint = "#f8e0c8" })
end
-- sprouting seed: coat split, pale embryo showing in the crack
do
  local tok = { r = { name = "seed5" } }
  local m = M.ball(c, sprout[1], sprout[2], sprout[3], sprout[3] - 0.3, 0, SEED, { tok = tok, glint = "#f8e0c8" })
  for _, p in ipairs{ { 41, 43 }, { 42, 43 }, { 41, 44 } } do c:put(p[1], p[2], "#e8eec0", tok) end
  c:put(40, 44, SEED[1], tok) c:put(43, 44, SEED[1], tok)
  -- tiny root down into the leaf
  for _, p in ipairs{ { 43, 47 }, { 44, 48 }, { 44, 49 }, { 45, 50 } } do c:put(p[1], p[2], "#eae2c4", { r = { name = "root" } }) end
end

M.save(c, NAME)
