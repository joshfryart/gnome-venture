-- gooseberry-seed (B3, Opus single pass aB35_3). Three small tan gooseberry seeds (oval, a dark hilum dot, a lit cap) on a
-- torn scrap of a palmate gooseberry leaf: five rounded, toothed lobes fanning from the base notch, palmate veins, pleat
-- shading along the veins, a cool reflected lower edge, pale torn tissue on the right, AO and contact shadows under the
-- seeds. The middle seed has germinated: a pale stem, two oval cotyledons and a first three-lobed true leaf.
-- quirk: the seedling already grows one tiny red-tipped thorn on its stem.
local NAME = "gooseberry-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB35_3.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt, atan = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt, math.atan
local c = A.new(NAME)

local LEAF = { "#1c4034", "#275a3e", "#357a46", "#4f9a4e", "#76b85a", "#a6d478" }
local VEIN, COOL, TORN = "#cfe89a", "#3c7070", "#d8ec9e"
local SEED = { "#4a3020", "#6e4a2c", "#97703e", "#bd9658", "#dcbc80", "#f4e0aa" }
local STEM = { "#4c8a52", "#82b868", "#b4da8e", "#e0f2b8" }
local THORN = { "#7a2a30", "#b8463a", "#f08a6a" }

local function angd(a, b) local d = (a - b) % (2 * pi) if d > pi then d = d - 2 * pi end return abs(d) end
-- palmate mask: lobes at angles, centre cx,cy, vertical squash sq
local function palm(cx, cy, r0, r1, lobes, sq, teeth)
  local m = HP.mask()
  local R = r0 + r1 + 2
  for y = floor(cy - R), floor(cy + R) do for x = floor(cx - R), floor(cx + R) do
    local dx, dy = x - cx, (y - cy) / sq
    local th = atan(dy, dx)
    local L = 0
    for _, a in ipairs(lobes) do L = max(L, math.exp(-(angd(th, a) / 0.36) ^ 2)) end
    local r = r0 + r1 * L
    if teeth and L > 0.25 and ((th * 13) % 1) < 0.35 then r = r - 0.7 end
    if sqrt(dx * dx + dy * dy) <= r then m:set(x, y) end
  end end
  return m
end

-- leaf scrap
local LX, LY = 31, 46
local lobes = { -2.95, -2.2, -1.57, -0.94, -0.19 }
local lm = palm(LX, LY, 9, 16, lobes, 0.6, true)
-- torn right side
local torn = HP.mask()
lm:each(function(x, y) if x > 45 + floor(X.hash(0, y, 5) * 3) + ((y % 3 == 0) and 1 or 0) then torn:set(x, y) end end)
lm:cut(torn)
local tornEdge = HP.mask()
lm:each(function(x, y) if not lm:has(x + 1, y) and x >= 45 then tornEdge:set(x, y) end end)

-- seeds
local seeds = { { 21, 48, 2.9, 1.9, -0.3 }, { 31, 50, 3.0, 2.0, 0.15 }, { 40, 46, 2.7, 1.8, -0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = A.oval(s[1], s[2], s[3], s[4], s[5], 0.8) end

-- leaf normals: pillow + pleats along the palmate veins (origin at the base notch)
local OX, OY = LX, LY + 4
local ln = X.pillow(lm, 3)
lm:each(function(x, y) local k = K(x, y)
  local th = atan((y - OY) / 0.6, x - OX)
  local best, bd = 9, 0
  for _, a in ipairs(lobes) do local d = angd(th, a) if d < best then best, bd = d, ((th - a + pi) % (2 * pi)) - pi end end
  local f = max(-1, min(1, bd / 0.3)) * 0.35
  local p = ln[k]
  ln[k] = { A.norm(p[1] - sin(th) * f, p[2] + cos(th) * f * 0.6, p[3]) }
end)
local bias = {}
for _, s in ipairs(seeds) do X.ao(bias, lm, s.m, 1, -1) A.cast(bias, lm, s.m, 1, 2, -1) end
local ltok = { r = { name = "leaf" } }
local lidx = A.shade(c, lm, ln, LEAF, { bias = bias, tok = ltok, amb = 0.14, wrap = 0.3 })
-- palmate veins: midline to each lobe tip
for i, a in ipairs(lobes) do
  local L = 9 + 15
  for t = 0.05, 0.92, 0.02 do
    local x = floor(OX + cos(a) * L * t + 0.5)
    local y = floor(OY + sin(a) * L * t * 0.6 - 4 * t + 0.5)
    local k = K(x, y)
    if lm:has(x, y) and not bias[k] then c:put(x, y, (i <= 3) and VEIN or LEAF[(lidx[k] or 3) >= 4 and 6 or 4], ltok) end
  end
end
-- cool reflected lower-right edge and pale torn tissue
lm:edge():each(function(x, y) local k = K(x, y)
  if not bias[k] and y > LY + 3 and x > LX - 4 then c:put(x, y, COOL, ltok) end end)
tornEdge:each(function(x, y) c:put(x, y, TORN, ltok) end)
-- petiole stub out of the base notch
for _, q in ipairs{ { 31, 52, 4 }, { 31, 53, 3 }, { 30, 54, 3 }, { 30, 55, 2 } } do c:put(q[1], q[2], LEAF[q[3]], ltok) end

-- sprout (behind the middle seed's front) --------------------------------------------
local stok = { r = { name = "stem" } }
local sm, sn, ST, SS = A.tube({ { 31, 48 }, { 30, 41 }, { 32, 34 }, { 31, 27 } }, function() return 1.05 end)
for _, s in ipairs(seeds) do sm:cut(s.m) end
A.shade(c, sm, sn, STEM, { cuts = { 0.3, 0.55, 0.8 }, amb = 0.15, wrap = 0.3, tok = stok })
-- quirk: tiny thorn at a node
c:put(33, 37, THORN[2], stok) c:put(34, 36, THORN[3], stok) c:put(33, 38, THORN[1], stok)

-- cotyledons: smooth ovals
local cl = A.leaf(c, 30, 29, 25, 26, 19, 28, 2.6, LEAF, { pw = 0.55, vs = 99 })
local cr = A.leaf(c, 32, 29, 37, 25, 43, 27, 2.6, LEAF, { pw = 0.55, vs = 99 })
-- first true leaf: three toothed lobes
local tl = palm(31, 20, 2.4, 4.2, { -2.5, -1.57, -0.64 }, 0.9, false)
tl:cut(cl):cut(cr)
local tn = X.pillow(tl, 2)
local tidx = A.shade(c, tl, tn, LEAF, { amb = 0.12, wrap = 0.25 })
for t = 0, 5 do c:put(31, 25 - t, t < 2 and STEM[3] or LEAF[6]) end
c:put(29, 21, LEAF[6]) c:put(28, 20, LEAF[6]) c:put(33, 21, LEAF[4]) c:put(34, 20, LEAF[4])
c:put(31, 26, STEM[2], stok)

-- seeds last
for i, s in ipairs(seeds) do
  local vis = s.m:copy()
  local tok = { r = { name = "seed" .. i } }
  local idx = A.shade(c, vis, s.n, SEED, { amb = 0.08, wrap = 0.2, tok = tok })
  -- hilum dot at one end, lit cap
  local ca, sa = cos(s[5]), sin(s[5])
  c:put(floor(s[1] + ca * (s[3] - 0.6) + 0.5), floor(s[2] + sa * (s[3] - 0.6) + 0.5), SEED[1], tok)
  local sx, sy = A.specAt(vis, s.n, 40)
  if sx then c:put(sx, sy, SEED[6], tok) end
end
-- glint on the front seed
c:put(30, 49, "#fff4d6")

A.save(c, NAME)
