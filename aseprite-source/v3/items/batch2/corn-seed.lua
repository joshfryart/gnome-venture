-- corn-seed (batch2, Opus single pass). Two real dent-corn kernels (broad rounded crown, tapering to a tan tip cap,
-- a pale dented germ on the face) lying on a torn scrap of corn leaf (strap blade, pale midrib, parallel veins,
-- ragged torn end, cool bounce on the lower edge). The right kernel has sprouted: a white root curls over the leaf
-- and a slim coleoptile carries two arching strap leaves with pale midribs - the corn leaf shape in small.
-- Material: per-pixel kernel light (6 tones), glossy cream specular, germ dent (inverted light), AO + contact
-- shadow under each kernel and under the sprout.
-- quirk: the left kernel has a nibbled bite out of its crown, with one crumb beside it.
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/_b2g3.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local NAME = "corn-seed"
local c = G.new(NAME)

local GOLD = { "#7a3f1c", "#b0661c", "#d9921f", "#f2bb2e", "#fcd85a", "#fff09a" }
local GERM = { "#c9a35a", "#e2c47c", "#f2dea0", "#fbf0c6" }
local CAP  = { "#6e4a2c", "#9a6c40" }
local LEAF = { "#163a33", "#1f553c", "#2e7243", "#47904b", "#6fae55", "#a3cc6c" }
local SPR  = { "#1f553c", "#33774a", "#4f9a50", "#78b85a", "#a8d473", "#d2ea9a" }
local ROOT = { "#b8ab94", "#e4dccb", "#fbf6ea" }
local SPEC, COOL = "#fffbe0", "#2e6763"

---------------------------------------------------------------- kernel shape
-- crown centre (cx,cy), axis angle ang (crown -> tip), length L, half width W
local function kernel(cx, cy, ang, L, W)
  local ux, uy = cos(ang), sin(ang)
  local px, py = -uy, ux
  local m, V, U = HP.mask(), {}, {}
  for y = floor(cy) - 14, floor(cy) + 14 do for x = floor(cx) - 14, floor(cx) + 14 do
    local dx, dy = x - cx, y - cy
    local a, b = dx * ux + dy * uy, dx * px + dy * py
    local v = (a + W * 0.55) / L               -- 0 at the crown top
    if v >= 0 and v <= 1 then
      local hw
      if v < 0.2 then hw = W * sqrt(max(0, 1 - ((0.2 - v) / 0.23) ^ 2))
      else hw = W * (1 - 0.78 * ((v - 0.2) / 0.8) ^ 1.25) end
      if abs(b) <= hw + 0.2 then m:set(x, y) local k = K(x, y) V[k], U[k] = v, b / max(hw, 0.6) end
    end
  end end
  local n = X.pillow(m, 3.2)
  return { m = m, n = n, V = V, U = U, cx = cx, cy = cy, ux = ux, uy = uy, px = px, py = py, L = L, W = W }
end

local K1 = kernel(20, 46, 2.4, 13, 5.0)   -- lying on its side, tip toward lower-left
local K2 = kernel(37, 36, 1.68, 14, 5.3)        -- standing, tip down, sprouting
-- quirk: bite out of K1's crown (a small round notch on the upper crown corner)
local bx = K1.cx - K1.ux * 0.55 * K1.W + K1.px * K1.W * 0.45 - K1.ux * 0.3
local by = K1.cy - K1.uy * 0.55 * K1.W + K1.py * K1.W * 0.45 - K1.uy * 0.3
local bite = HP.mask()
for y = floor(by) - 4, floor(by) + 4 do for x = floor(bx) - 4, floor(bx) + 4 do if (x - bx) ^ 2 + (y - by) ^ 2 <= 7.3 then bite:set(x, y) end end end
K1.m:cut(bite)

---------------------------------------------------------------- leaf scrap (strap, torn left end, drawn tip right)
local lm, ln, LT, LS, len = G.blade(8, 50, 32, 58, 58, 43, function(t)
  if t > 0.985 then return -1 end
  local w = 4.6
  if t > 0.6 then w = 4.6 * ((1 - t) / 0.4) ^ 0.8 end
  return max(0.45, w)
end, { fold = 0.35 })
-- ragged torn end: bite pixels off the first few columns
lm:each(function(x, y) local k = K(x, y)
  local t = LT[k] * len
  local lim = 1.2 + 1.6 * abs(sin(LS[k] * 5.3 + 0.7))
  if t < lim then lm.s[k] = nil end
end)
-- gentle wavy margin on the upper edge
lm:edge():each(function(x, y) local k = K(x, y)
  if LT[k] and LT[k] > 0.12 and LT[k] < 0.8 and LS[k] < -0.5 and sin(LT[k] * len / 2.1) > 0.7 then lm.s[k] = nil end end)

---------------------------------------------------------------- sprout geometry
local stem = HP.mask()
for _, p in ipairs{ {37, 31}, {37, 30}, {37, 29}, {36, 28}, {36, 27}, {36, 26}, {36, 25}, {36, 24} } do
  stem:set(p[1], p[2]) stem:set(p[1] + 1, p[2])
end
local s1 = { G.blade(36, 26, 27, 9, 13, 11, function(t)
  if t > 0.97 then return -1 end
  return max(0.45, 2.5 * sin(pi * min(1, t * 0.75 + 0.25)) ^ 0.6 * (1 - 0.5 * t))
end, { fold = 0.5 }) }
local s2 = { G.blade(37, 25, 43, 11, 51, 7, function(t)
  if t > 0.97 then return -1 end
  return max(0.45, 2.3 * sin(pi * min(1, t * 0.75 + 0.25)) ^ 0.6 * (1 - 0.5 * t))
end, { fold = 0.5 }) }

-- root (curls down-right over the leaf from K2's tip)
local root = {}
for _, p in ipairs{ {36, 47}, {37, 48}, {37, 49}, {38, 50}, {38, 51}, {39, 52}, {40, 53}, {41, 53}, {42, 54}, {43, 54}, {44, 53}, {45, 53}, {46, 52} } do root[#root + 1] = p end
local rootM = HP.mask() for _, p in ipairs(root) do rootM:set(p[1], p[2]) end

---------------------------------------------------------------- paint leaf
local kall = HP.mask():add(K1.m):add(K2.m)
local bias = {}
X.ao(bias, lm, kall, 1, -1)
G.cast(bias, lm, kall, 1, 2, -1) G.cast(bias, lm, kall, 2, 3, -1)
G.cast(bias, lm, rootM, 0, 1, -1)
local ltok = { r = { name = "leaf" } }
local lidx = G.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.1, wrap = 0.22 })
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  if abs(LS[k]) < 0.1 and LT[k] > 0.03 and LT[k] < 0.93 then c:put(x, y, LS[k] <= 0 and "#c4e08a" or LEAF[3], ltok) end
end)
G.parallelVeins(c, lm, lidx, LS, LT, LEAF, ltok, { -0.62, -0.36, 0.38, 0.66 }, 0.03, 0.85, bias)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and LS[k] > 0.6 and LT[k] > 0.08 and LT[k] < 0.85 then c:put(x, y, COOL, ltok) end end)

---------------------------------------------------------------- kernels
local function paintKernel(Kn, name, cover)
  local kb = {}
  if cover then X.ao(kb, Kn.m, cover, 1, -1) G.cast(kb, Kn.m, cover, 1, 1, -1) end
  local tok = { r = { name = name } }
  local idx = G.toneN(c, Kn.m, Kn.n, GOLD, { bias = kb, tok = tok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.06, wrap = 0.2 })
  -- tip cap and germ
  Kn.m:each(function(x, y) local k = K(x, y)
    local v, u = Kn.V[k], Kn.U[k]
    if v > 0.9 then c:put(x, y, (idx[k] >= 4) and CAP[2] or CAP[1], tok) return end
    local gv, gu = (v - 0.64) / 0.22, u / 0.5
    if gv * gv + gu * gu <= 1 then
      -- dent: inverted light (upper-left wall darker, lower-right wall lit)
      local d = gu * Kn.px + gv * Kn.ux       -- rough screen-x of the dent offset
      local e = gu * Kn.py + gv * Kn.uy
      local w = d + e
      local i = (w < -0.45) and 1 or ((w > 0.35) and 4 or (gv * gv + gu * gu < 0.35 and 3 or 2))
      if kb[k] then i = max(1, i - 1) end
      c:put(x, y, GERM[i], tok)
    end
  end)
  -- crown dimple: the dent of "dent corn" on the top
  Kn.m:each(function(x, y) local k = K(x, y)
    if Kn.V[k] < 0.13 and Kn.V[k] > 0.03 and abs(Kn.U[k]) < 0.3 then c:put(x, y, GOLD[max(1, idx[k] - 2)], tok) end end)
  return idx, tok
end
local i1, t1 = paintKernel(K1, "k1")
local i2, t2 = paintKernel(K2, "k2", stem)
-- crumb by the bite (quirk) + darker bite wall
c:put(27, 48, GOLD[5], t1) c:put(28, 48, GOLD[3], t1) c:put(27, 49, GOLD[2], t1) c:put(28, 49, LEAF[1], t1)
bite:grow(1):each(function(x, y) if K1.m:has(x, y) then c:put(x, y, ((x - bx) + (y - by) > 0) and GOLD[6] or GOLD[2], t1) end end)
-- speculars (one per kernel, glossy)
local sx, sy = G.specAt(K1.m, K1.n, 30) if sx then c:put(sx, sy, SPEC, t1) c:put(sx + 1, sy, SPEC, t1) end
sx, sy = G.specAt(K2.m, K2.n, 30) if sx then c:put(sx, sy, SPEC, t2) end

---------------------------------------------------------------- root
local rtok = { r = { name = "root" } }
for i, p in ipairs(root) do if not rootM:has(p[1], p[2] + 1) then c:put(p[1], p[2] + 1, ROOT[1], rtok) end end
for i, p in ipairs(root) do c:put(p[1], p[2], ROOT[3], rtok) end
c:put(41, 55, ROOT[2], rtok) c:put(44, 55, ROOT[2], rtok)    -- root hairs
c:put(47, 51, ROOT[2], rtok)

---------------------------------------------------------------- sprout
local ptok = { r = { name = "sprout" } }
stem:each(function(x, y) c:put(x, y, x == 35 and SPR[5] or SPR[3], ptok) end)
c:put(37, 32, SPR[2], ptok) c:put(38, 32, SPR[2], ptok) -- emerges from the kernel crown
local function paintBlade(B, name, occl)
  local m, n, T, S = B[1], B[2], B[3], B[4]
  local b = {}
  if occl then X.ao(b, m, occl, 1, -1) end
  local tok = { r = { name = name } }
  G.toneN(c, m, n, SPR, { bias = b, tok = tok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12, wrap = 0.25 })
  m:each(function(x, y) local k = K(x, y)
    if abs(S[k]) < 0.14 and T[k] > 0.08 and T[k] < 0.88 and not b[k] then c:put(x, y, S[k] <= 0 and SPR[6] or SPR[3], tok) end
  end)
end
paintBlade(s2, "s2")
paintBlade(s1, "s1", s2[1])
-- whorl: where the two leaves leave the stem
c:put(36, 26, SPR[2], ptok) c:put(37, 25, SPR[3], ptok)

G.save(c, NAME, -1)
