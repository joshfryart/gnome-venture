-- sakura-seed (final, artist D14_0). Three smooth cherry stones (pale pink-tan, pinched seam ridge, stem scar) sit on a
-- torn, serrated dark-green cherry leaf with a pale vein into every tooth. The right stone has split along its seam and
-- a copper-red stem climbs out: two fat cotyledons, then two toothed, pointed cherry leaves, topped by a five-petal
-- blossom with notched petals and gold stamens. Waxy cool bounce on the shade sides, AO + contact shadow under every stone.
-- quirk: one pink petal has landed on the left stone and stuck there.
local NAME = "sakura-seed"
local G = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD14_0.lua")
local HP, X, K = G.HP, G.X, G.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#14352f", "#1e4d37", "#2c6a3f", "#428a48", "#65aa53", "#97c870" }
local SP   = { "#235a3a", "#38783f", "#559846", "#7db856", "#aad674", "#dcf0a2" }
local STEM = { "#4c2230", "#7c3a3e", "#a85a4c", "#d08068" }
local PIT  = { "#5a3228", "#80503a", "#a87250", "#cc9a70", "#e8be94", "#fadcb8" }
local PET  = { "#b84e86", "#e0709a", "#f58eb2", "#ffb4cc", "#ffd8e4", "#fff0f2" }
local COOL = "#3e6f72"

-- scrap: broad ovate cherry leaf, base lower-left, acuminate tip upper-right, torn notch at the base
local lm, ln, LT, LS, len = G.sleaf(c, 8, 52, 30, 50, 56, 38, function(t)
  if t > 0.985 then return -1 end
  local u = min(1, t ^ 0.74)
  return max(0.5, 9.0 * sin(pi * u) ^ 0.85)
end, { fold = 0.38, per = 4.8, depth = 0.55, tmin = 0.12, tmax = 0.95 })
-- torn zigzag end at the base (leaf was ripped off its twig)
for _, q in ipairs{ {8,51},{8,52},{8,53},{9,54},{9,50},{10,55},{10,49} } do lm.s[K(q[1], q[2])] = nil end

-- pits
local pits = { { 17.5, 50, 4.2, 3.6, -0.25 }, { 27.5, 47.5, 4.2, 3.6, -0.2 }, { 38, 43.5, 4.3, 3.7, -0.15 } }
for _, p in ipairs(pits) do p.m, p.n = G.oval(p[1], p[2], p[3], p[4], p[5], 0.85) end

local bias = {}
for _, p in ipairs(pits) do X.ao(bias, lm, p.m, 1, -1) G.cast(bias, lm, p.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
G.paintLeaf(c, lm, ln, LT, LS, len, { ramp = LEAF, per = 4.8, veins = true, vein = "#b5dc82", bias = bias, tok = ltok, cool = COOL, sweep = 3.6 })
-- petiole stub + ripped fibres at the base
for _, q in ipairs{ {7,51,3},{6,52,3},{6,53,2},{5,54,2},{7,52,2} } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout ----------------------------------------------------------------------------------
local stok = { r = { name = "stem" } }
local function leaf(ax, ay, cx, cy, bx, by, w)
  local m, n, T, S, L = G.sleaf(c, ax, ay, cx, cy, bx, by, function(t)
    if t > 0.985 then return -1 end
    local u = min(1, t ^ 0.8)
    return max(0.45, w * sin(pi * u) ^ 0.85)
  end, { fold = 0.42, per = 3.6, depth = 0.5, tmin = 0.14, tmax = 0.94 })
  G.paintLeaf(c, m, n, T, S, L, { ramp = SP, per = 3.6, veins = true, vein = "#f4fbc8", amb = 0.16, wrap = 0.3, sweep = 2.4,
    cuts = { 0.14, 0.3, 0.46, 0.62, 0.8 }, tok = { r = { name = "sleaf" } } })
  return m
end
local l1 = leaf(37.5, 33, 30, 32, 22.5, 26, 4.2)
local l2 = leaf(38.2, 26, 45, 26, 53, 20.5, 4.0)
-- cotyledons (fat, pale, smooth)
local cotok = { r = { name = "coty" } }
local function coty(cx, cy, ux, uy)
  local m = G.rell(cx, cy, ux, uy, 4.0, 2.3)
  G.toneN(c, m, X.pillow(m, 2.2), SP, { tok = cotok, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.14, wrap = 0.3 })
  m:each(function(x, y) if abs((x - cx) * (-uy) + (y - cy) * ux) < 0.5 and abs((x - cx) * ux + (y - cy) * uy) < 2.6 then c:put(x, y, SP[2], cotok) end end)
  return m
end
coty(31.5, 37.8, -0.96, -0.28)
coty(44.2, 37, 0.96, -0.28)
-- stem
local sp = { { 38, 43 }, { 36.5, 35 }, { 39.5, 27 }, { 38, 19.5 } }
local sm, sn = G.tube(sp, function(t) return 1.35 - 0.25 * t end)
G.toneN(c, sm, sn, STEM, { tok = stok, cuts = { 0.3, 0.55, 0.8 }, amb = 0.14, wrap = 0.3 })
-- leaf nodes: darker collar where the leaves leave the stem
for _, q in ipairs{ {37,34}, {37,35}, {39,26}, {39,27} } do if sm:has(q[1], q[2]) then c:put(q[1], q[2], STEM[1], stok) end end

-- blossom (five notched petals, gold stamens)
local BX, BY = 38, 14.4
local ptok = { r = { name = "petal" } }
local allp = HP.mask()
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5
  local ux, uy = cos(a), sin(a)
  local px, py = BX + ux * 3.0, BY + uy * 3.0
  local m = G.rell(px, py, ux, uy, 3.3, 2.5)
  local tipx, tipy = floor(BX + ux * 6.0 + 0.5), floor(BY + uy * 6.0 + 0.5)
  m.s[K(tipx, tipy)] = nil
  -- lit from upper-left: petals facing up-left are brighter
  local lit = -(ux * 0.55 + uy * 0.7)
  local n = X.pillow(m, 2.2)
  G.toneN(c, m, n, PET, { tok = ptok, cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, amb = 0.1 + 0.18 * max(0, lit), wrap = 0.35 })
  allp:add(m)
end
-- midline crease on each petal, darker toward the heart
for i = 0, 4 do
  local a = -pi / 2 + i * 2 * pi / 5
  for r = 1.6, 4.4, 1 do c:put(floor(BX + cos(a) * r + 0.5), floor(BY + sin(a) * r + 0.5), PET[r < 3 and 1 or 2], ptok) end
end
for _, q in ipairs{ {0,0,"#ffe38a"}, {-1,0,"#f5b82e"}, {1,0,"#d98322"}, {0,-1,"#fff4d6"}, {0,1,"#d98322"} } do
  c:put(floor(BX + q[1] + 0.5), floor(BY + q[2] + 0.5), q[3], ptok) end
c:put(floor(BX - 1.5), floor(BY - 2.5), "#fff0f2", ptok) c:put(floor(BX - 0.5), floor(BY - 2.5), "#fff0f2", ptok)
-- contact: the blossom crowns the stem
c:put(38, 19, STEM[1], stok) c:put(37, 19, STEM[2], stok)

-- pits last --------------------------------------------------------------------------------
for i, p in ipairs(pits) do
  local vis = p.m:copy()
  local pb = {}
  for j = i + 1, #pits do vis:cut(pits[j].m) X.ao(pb, p.m, pits[j].m, 1, -1) end
  local tok = { r = { name = "pit" .. i } }
  local idx = G.toneN(c, vis, p.n, PIT, { tok = tok, bias = pb, cuts = { 0.2, 0.38, 0.54, 0.7, 0.86 }, amb = 0.1, wrap = 0.3 })
  local ca, sa = cos(p[5]), sin(p[5])
  -- seam ridge: a pinched line down the right-hand face (lit lip then shadow)
  vis:each(function(x, y)
    local dx, dy = x - p[1], y - p[2]
    local u = (dx * ca + dy * sa) / (p[3] + 0.45)
    local v = (-dx * sa + dy * ca) / (p[4] + 0.45)
    local ik = idx[K(x, y)] or 3
    if u > 0.3 and u < 0.5 and abs(v) < 0.8 then c:put(x, y, PIT[min(6, ik + 1)], tok) end
    if u >= 0.5 and u < 0.72 and abs(v) < 0.7 then c:put(x, y, PIT[max(1, ik - 1)], tok) end
  end)
  -- cool bounce on the lower-right rim
  local rim = X.rim(p.n)
  vis:edge():each(function(x, y) if (rim[K(x, y)] or 0) > 0.78 and not pb[K(x, y)] then c:put(x, y, "#b08a8e", tok) end end)
  -- stem scar at the bottom, paler dot
  c:put(floor(p[1] - 1), floor(p[2] + p[4] - 0.6), PIT[6], tok)
  -- wax glint
  c:put(floor(p[1] - 2), floor(p[2] - 1.6), "#fff6e6", tok) c:put(floor(p[1] - 1), floor(p[2] - 2), "#fff6e6", tok)
end
-- sprouting stone: the seam has split, a dark gap with a pale kernel lip and the stem root inside
do
  local p = pits[3]
  for _, q in ipairs{ {39,40}, {39,41}, {40,42} } do c:put(q[1], q[2], PIT[1]) end
  c:put(38, 40, STEM[3]) c:put(38, 41, STEM[2]) c:put(37, 40, PIT[6]) c:put(40, 40, PIT[6])
end
-- quirk: a petal stuck on the left stone
c:put(15, 47, PET[4]) c:put(16, 47, PET[3]) c:put(17, 47, PET[2]) c:put(16, 48, PET[2]) c:put(17, 48, PET[1]) c:put(15, 48, PET[3])

G.save2(c, NAME)
