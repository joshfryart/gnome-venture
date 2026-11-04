-- marsh-marigold-seed (final, Opus single pass). Three plump glossy dark-brown marsh-marigold seeds (raphe ridge, one
-- bright specular each: they are glossy) on a torn scrap of a round, crenate, kidney-shaped Caltha leaf (palmate veins
-- fanning from the sinus, waxy sheen streaks, cool reflected edge, AO + contact shadow under each seed). The right seed
-- has germinated: pale stem, two oval cotyledons and a first true leaf that is a tiny glossy kidney with a heart sinus.
-- quirk: a bead of marsh water sits on the leaf, lensing it.
local NAME = "marsh-marigold-seed"
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aC22_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)
local LEAF = { "#173a2c", "#1f5536", "#2d7340", "#479449", "#72b854", "#aedb72" }
local SHEEN, COOL = "#dff3a2", "#3a7072"
local SEED = { "#24161c", "#3a2224", "#56302a", "#7a4630", "#a0663e", "#c99260" }
local STEM = { "#4c7a3e", "#7fae58", "#b3d77e", "#e2f1b0" }
local WATER = { "#2f6b72", "#5aa3a2", "#94d3c4", "#d6f4e8" }

-- crenate kidney mask (with sinus notch at angle `sa`) + its dome normals
local function kidney(cx, cy, rx, ry, crenN, crenA, sa, sinW)
  local m = HP.mask()
  for y = floor(cy - ry) - 2, floor(cy + ry) + 2 do for x = floor(cx - rx) - 2, floor(cx + rx) + 2 do
    local u, v = (x - cx) / (rx + .4), (y - cy) / (ry + .4)
    local r, th = sqrt(u * u + v * v), atan(v, u)
    local d = (th - sa + pi) % (2 * pi) - pi
    if r <= 1 - crenA + crenA * abs(cos(th * crenN / 2)) and not (abs(d) < sinW * (1.15 - r) and r > 0.22) then m:set(x, y) end
  end end
  return m
end

-- leaf scrap
local LX, LY, RX, RY = 30, 41, 21, 12.5
local lm = kidney(LX, LY, RX, RY, 14, 0.045, pi / 2 + 0.25, 0.55)
-- torn away along a ragged line on the left
do local drop = {}
  lm:each(function(x, y) local v = (y - LY) / RY
    local z = abs(((v * 2.3 + 0.2) % 1) - 0.5) * 2
    if x < LX - RX * (0.62 - 0.16 * z) - X.hash(y // 2, 1, 7) * 1.0 then drop[#drop + 1] = K(x, y) end end)
  for _, k in ipairs(drop) do lm.s[k] = nil end end
local ln = X.pillow(lm, 6, 0.8)
local SX, SY = LX + 3, LY + RY * 0.72                 -- sinus / vein origin

-- seeds: cx, cy, rx, ry, angle
local seeds = { { 21, 40, 3.4, 2.4, -0.5 }, { 29, 45, 3.5, 2.5, 0.25 }, { 37, 38, 3.2, 2.3, -1.25 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.9) end
-- water bead
local WX, WY, WR = 45, 44, 2.6
local wm = c:ellipse(WX, WY, WR, WR - 0.3)

local bias = {}
for _, s in ipairs(seeds) do A.shadow(bias, lm, s.m, 1, 2) end
A.shadow(bias, lm, wm, 1, 1)
local ltok = { r = { name = "leaf" } }
local lidx = A.toneN(c, lm, ln, LEAF, { bias = bias, tok = ltok, cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, amb = 0.18, wrap = 0.3 })
-- palmate veins fanning out from the sinus, plus waxy sheen streaks
local sp = X.spec(ln, 18)
lm:each(function(x, y) local k = K(x, y)
  if bias[k] then return end
  local dx, dy = x - SX, y - SY
  local r = sqrt(dx * dx + dy * dy)
  local a = atan(dy, dx)
  local f = abs(((a / 0.36) % 1) - 0.5) * 2
  if r > 2 and r < RX * 0.95 and f > 0.84 then c:put(x, y, (lidx[k] or 3) >= 4 and LEAF[6] or LEAF[lidx[k] + 2], ltok) end
  if sp[k] > 0.55 and (x + y) % 4 ~= 0 then c:put(x, y, SHEEN, ltok) end
end)
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and x > LX + 4 and y > LY + 2 then c:put(x, y, COOL, ltok) end end)
-- petiole stub into the sinus
for _, q in ipairs{ { SX + 1, SY + 1, 3 }, { SX + 1, SY + 2, 3 }, { SX + 2, SY + 3, 2 }, { SX + 2, SY + 4, 2 }, { SX + 3, SY + 5, 2 } } do
  c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- quirk: water bead lensing the leaf (dark top-left rim, bright caustic lower right, cream glint)
do local wtok = { r = { name = "water" } }
  wm:each(function(x, y) local dx, dy = x - WX, y - WY
    local i = 2
    if dx + dy > 1.2 then i = 3 end
    if dx + dy > 2.6 then i = 4 end
    if dx + dy < -2.2 then i = 1 end
    c:put(x, y, WATER[i], wtok) end)
  c:put(WX - 1, WY - 1, A.CREAM, wtok) c:put(WX - 1, WY - 2, WATER[4], wtok)
end

-- sprout from the third seed
local stok = { r = { name = "stem" } }
local spp = { { 38, 36 }, { 39, 31 }, { 37, 26 }, { 38, 21 } }
local stm, stn = A.tube(spp, function(t) return 1.0 end)
stm:cut(seeds[3].m)
X.tone(c, stm, X.light(stn, { amb = 0.15, wrap = 0.3 }), STEM, { cuts = { 0.3, 0.55, 0.8 }, tok = stok })
local function coty(cx, cy, ang)
  local ux, uy = cos(ang), sin(ang)
  local m = A.rell(cx, cy, ux, uy, 3.6, 2.0)
  m:cut(stm)
  local n = X.pillow(m, 2)
  A.toneN(c, m, n, LEAF, { tok = ltok, cuts = A.CUTS6, amb = 0.16, wrap = 0.3 })
  for i = -2, 2 do local x, y = floor(cx + ux * i + .5), floor(cy + uy * i + .5) if m:has(x, y) then c:put(x, y, LEAF[i < 0 and 5 or 4], ltok) end end
  return m
end
local cl = coty(33, 23, pi + 0.35)
local cr = coty(43, 23, -0.3)
-- first true leaf: small glossy kidney with heart sinus on a petiole
for i = 0, 16 do local x, y = A.bez({ { 38, 22 }, { 38, 19 }, { 39, 17 }, { 39, 15 } }, i / 16) c:put(floor(x + .5), floor(y + .5), STEM[3], stok) end
local tl = kidney(39, 12, 5.2, 4.0, 10, 0.1, pi / 2, 0.7)
tl:cut(cl):cut(cr)
local tn = X.pillow(tl, 2.5)
local tidx = A.toneN(c, tl, tn, LEAF, { tok = ltok, cuts = A.CUTS6, amb = 0.14, wrap = 0.25 })
tl:each(function(x, y) local dx, dy = x - 39, y - 15
  local a = atan(dy, dx)
  if dy < -1 and abs(((a / 0.6) % 1) - 0.5) * 2 > 0.85 then c:put(x, y, LEAF[max(2, (tidx[K(x, y)] or 3) - 1)], ltok) end end)
do local bx, by = A.specAt(tl, tn, 30) c:put(bx, by, SHEEN, ltok) end

-- seeds last: glossy, raphe ridge, AO between neighbours, a specular each
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local sb = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(sb, s.m, seeds[j].m, 1, -1) end
  local tok = { r = { name = "seed" .. i } }
  X.tone(c, vis, X.light(s.n, { amb = 0.08, wrap = 0.25 }), SEED, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = sb, tok = tok })
  -- raphe: a pale ridge along the long axis on the lit half
  local ca, sa = cos(s[5]), sin(s[5])
  for u = -2, 2 do
    local x, y = floor(s[1] + u * ca - 0.9 * (-sa) * (ca - sa > 0 and 1 or -1) * 0 + .5), floor(s[2] + u * sa + .5)
    if vis:has(x, y) and abs(u) <= 1 then c:put(x, y, SEED[4], tok) end
  end
  local bx, by = A.specAt(vis, s.n, 50)
  c:put(bx, by, "#fff0d0", tok)
  if vis:has(bx + 1, by) then c:put(bx + 1, by, SEED[6], tok) end
end

A.save(c, NAME)
