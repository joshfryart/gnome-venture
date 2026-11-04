-- kangkong-seed (final pass, Opus single pass). Three kangkong (water spinach) seeds: dark brown rounded wedges with
-- one flat facet each (four sit in a capsule), velvety coat with pale hairs on the rims, lying on a torn scrap of a
-- glossy kangkong leaf (midrib, swept veins, V-fold light, cool rim, pale torn tissue, AO + contact shadow).
-- The right seed has sprouted: a pinkish hollow-looking hypocotyl, two butterfly-notched morning-glory cotyledons and
-- a first true leaf in the plant's arrowhead (sagittate) shape.
-- quirk: a bead of water (it is water spinach) sits on the leaf tip, with a bright caustic and its own shadow.
local NAME = "kangkong-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC13_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local LEAF = { "#173a34", "#215440", "#2f7246", "#4a9450", "#72b45c", "#a6d474" }
local VEIN, COOL, TISSUE = "#c8ea94", "#3e6e7c", "#dcefb0"
local SEED = { "#1c1214", "#30201e", "#4a3026", "#684430", "#8c6040", "#b88a5e" }
local FUZZ = "#cdb89c"
local HYP = { "#5a3050", "#8a4a68", "#b8728a", "#e2a8ac" }
local SPR = { "#1d4838", "#2c6844", "#448e4c", "#68b058", "#9ace6e", "#d0eca0" }
local DROP = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#9ee4dc", "#d6fbf0" }

local function line(pts, f)
  for i = 1, #pts - 1 do
    local x0, y0, x1, y1 = pts[i][1], pts[i][2], pts[i + 1][1], pts[i + 1][2]
    local n = max(abs(x1 - x0), abs(y1 - y0))
    for j = 0, n do local t = n == 0 and 0 or j / n
      f(floor(x0 + (x1 - x0) * t + 0.5), floor(y0 + (y1 - y0) * t + 0.5), (i - 1 + t) / (#pts - 1)) end
  end
end

-- leaf scrap: pointed tip to the right, torn across the base on the left
local lm, ln, LT, LS, len = A.blade(7, 52, 30, 57, 56, 45, function(t)
  if t > 0.985 then return -1 end
  return max(0.5, 7.4 * (1 - t) ^ 0.75 * min(1, 0.75 + t * 1.6))
end, { fold = 0.4 })
local torn = A.tear(lm, LT, LS, 0.07, { -0.03, 0.03, -0.01, 0.05, -0.02, 0.04, 0.0, 0.02 }, true)

-- seeds: cx, cy, rx, ry, angle, facet dir
local seeds = { { 17, 51, 3.0, 2.3, -0.35, { -0.8, -0.6 } }, { 26, 50, 2.8, 2.3, 0.55, { 0.7, -0.7 } },
                { 37, 48, 3.0, 2.4, -0.15, { -0.3, -0.95 } } }
for _, s in ipairs(seeds) do
  s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.75)
  local fx, fy = s[6][1], s[6][2]
  s.face = HP.mask()
  s.m:each(function(x, y) local d = (x - s[1]) * fx + (y - s[2]) * fy
    if d > 1.5 then s.m.s[K(x, y)] = nil elseif d > 0.6 then s.face:set(x, y) end end)
  s.face:clip(s.m)
end
-- water bead (quirk) near the leaf tip
local dm = c:ellipse(48, 46, 2, 1.5)

local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
A.cast(bias, lm, dm, 1, 1, -1)
local ltok = { r = { name = "leaf" } }
A.leaf(c, lm, ln, LT, LS, { ramp = LEAF, vein = VEIN, cool = COOL, len = len, torn = torn, tissue = TISSUE, tok = ltok,
  bias = bias, per = 5.5, sweep = 3.5, amb = 0.18 })

-- sprout: hypocotyl from seed 3
local htok = { r = { name = "hypocotyl" } }
local hm, hn, HT, HS = A.tube({ { 37, 47 }, { 39, 41 }, { 35, 36 }, { 36, 30 } }, function(t) return 1.05 end)
hm:cut(seeds[3].m)
local hidx = A.shade(c, hm, hn, HYP, { tok = htok, amb = 0.15, wrap = 0.3, cuts = { 0.3, 0.55, 0.8 } })
-- hollow-stem hint: a faint pale line down the lit side
hm:each(function(x, y) local k = K(x, y) if HS[k] < -0.2 and HS[k] > -0.7 and HT[k] > 0.2 and HT[k] < 0.9 and (y % 3 ~= 0) then c:put(x, y, HYP[4], htok) end end)

-- cotyledons: two butterfly (V-notched) blades
local stok = { r = { name = "sprout" } }
local function cotyledon(cx, cy, ux, uy)
  local l = sqrt(ux * ux + uy * uy) ux, uy = ux / l, uy / l
  local px, py = -uy, ux
  local m = HP.mask()
  for _, sd in ipairs{ -1, 1 } do
    m:add(A.rell(cx + ux * 1.0 + px * sd * 1.9, cy + uy * 1.0 + py * sd * 1.9, ux, uy, 3.2, 2.0))
  end
  m:add(A.rell(cx - ux * 1.2, cy - uy * 1.2, ux, uy, 2.2, 1.6))
  local n = X.pillow(m, 1.6)
  local bb = {}
  X.ao(bb, m, hm, 1, -1)
  local idx = A.shade(c, m, n, SPR, { tok = stok, bias = bb, amb = 0.14, wrap = 0.3 })
  -- midvein from base into the notch
  for t = -2, 2 do local x, y = floor(cx + ux * t + 0.5), floor(cy + uy * t + 0.5)
    if m:has(x, y) then c:put(x, y, SPR[min(6, (idx[K(x, y)] or 4) + 1)], stok) end end
  return m
end
local cl = cotyledon(28.5, 30, -1, -0.25)
local cr = cotyledon(44, 29.5, 1, -0.3)
-- petiole stubs joining the hypocotyl top
for _, p in ipairs{ { 33, 30, 3 }, { 34, 30, 3 }, { 35, 30, 4 }, { 38, 30, 3 }, { 39, 30, 3 }, { 37, 30, 2 } } do c:put(p[1], p[2], SPR[p[3]], stok) end

-- first true leaf: arrowhead on a short petiole
local ptok = { r = { name = "petiole" } }
for y = 23, 29 do c:put(36, y, y < 26 and SPR[3] or HYP[3], ptok) c:put(37, y, SPR[2], ptok) end
local am = c:poly{ { 37, 9 }, { 41, 14 }, { 42, 18 }, { 45, 24 }, { 40, 21 }, { 37, 21 }, { 34, 21 }, { 29, 24 }, { 32, 18 }, { 33, 14 } }
local an = X.pillow(am, 2)
for k, nn in pairs(an) do local x = k % 1024 - 256
  local f = (x < 37) and -0.32 or (x > 37 and 0.32 or 0)
  an[k] = { A.norm(nn[1] + f, nn[2], nn[3]) } end
local ab = {}
for x = 35, 39 do local k = K(x, 21) if am:has(x, 21) then ab[k] = -1 end end
local aidx = A.shade(c, am, an, SPR, { tok = stok, bias = ab, amb = 0.12, wrap = 0.28 })
-- veins: midrib to the tip, one into each basal lobe
line({ { 37, 20 }, { 37, 11 } }, function(x, y) if am:has(x, y) then c:put(x, y, SPR[6], stok) end end)
line({ { 36, 20 }, { 31, 23 } }, function(x, y) if am:has(x, y) and not am:edge():has(x, y) then c:put(x, y, SPR[5], stok) end end)
line({ { 38, 20 }, { 43, 23 } }, function(x, y) if am:has(x, y) and not am:edge():has(x, y) then c:put(x, y, SPR[3], stok) end end)
for _, v in ipairs{ { 36, 16, 34, 15 }, { 36, 13, 35, 12 }, { 38, 16, 40, 15 }, { 38, 13, 39, 12 } } do
  line({ { v[1], v[2] }, { v[3], v[4] } }, function(x, y) if am:has(x, y) then c:put(x, y, x < 37 and SPR[5] or SPR[3], stok) end end)
end
c:put(34, 13, SPR[6], stok) c:put(35, 13, SPR[6], stok)

-- seeds last: velvety dark wedges with one flat facet and pale rim hairs
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local b = {}
  for j = i + 1, #seeds do vis:cut(seeds[j].m) X.ao(b, s.m, seeds[j].m, 1, -1) end
  if i == 3 then vis:cut(hm) end
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { tok = tok, bias = b, amb = 0.08, wrap = 0.22, cuts = { 0.16, 0.32, 0.48, 0.64, 0.8 } })
  -- facet: flat plane, one tone lighter if it faces the light, with a pale ridge where it meets the round back
  local lit = (s[6][1] * -0.55 + s[6][2] * -0.7) > 0
  s.face:each(function(x, y) if vis:has(x, y) then
    c:put(x, y, SEED[lit and 5 or 3], tok) end end)
  -- velvet: scattered lighter specks
  vis:each(function(x, y) local k = K(x, y)
    if not s.face:has(x, y) and X.hash(x, y, i + 3) > 0.8 and (idx[k] or 1) >= 2 then c:put(x, y, SEED[min(6, idx[k] + 1)], tok) end end)
  -- rim hairs just outside the seed on the upper side
  local hairs = { { -0.6, -1 }, { 0.2, -1 }, { 0.75, 1 } }
  local ca, sa = cos(s[5]), sin(s[5])
  for _, h in ipairs(hairs) do
    local u, sd = h[1], h[2]
    local hx = floor(s[1] + u * s[3] * ca - sd * (s[4] + 1.0) * sa + 0.5)
    local hy = floor(s[2] + u * s[3] * sa + sd * (s[4] + 1.0) * ca + 0.5)
    if not s.m:has(hx, hy) and lm:has(hx, hy) then c:put(hx, hy, FUZZ, tok) end
  end
  local gx, gy = A.specAt(vis, s.n, 30) if gx then c:put(gx, gy, SEED[6], tok) end
end
c:put(37, 47, HYP[2], htok)

-- water bead: dark upper-left rim, caustic lower-right, cream glint upper-left
do local tok = { r = { name = "drop" } }
  dm:each(function(x, y) local dx, dy = x - 48, y - 46
    local i = 3
    if dx + dy <= -2 then i = 2 elseif dx + dy >= 2 then i = 4 end
    c:put(x, y, DROP[i], tok) end)
  c:put(50, 47, DROP[5], tok) c:put(49, 47, DROP[4], tok)
  c:put(46, 45, DROP[1], tok)
  c:put(47, 45, "#fff4d6", tok)
end

A.save(c, NAME)
