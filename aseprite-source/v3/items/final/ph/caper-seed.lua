-- caper-seed (Opus single pass). Kidney-shaped glossy red-brown caper seeds (notched hilum, fine pitting, one glint each)
-- on a torn, broad, rounded caper-leaf scrap (thick blue-green, midrib, swept veins, mucro tip, pale torn fibre edge,
-- cool reflected rim, AO + contact shadow). The right seed has sprouted: reddish stem, two fleshy oval cotyledons, a
-- pair of round true leaves on short petioles and two tiny hooked stipule spines (the caper's tell).
-- quirk: a split caperberry on its long stalk lies on the scrap, pink flesh studded with seeds, one seed spilling out.
local NAME = "caper-seed"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB1r0_2.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = G.new2(NAME)
local LEAF = { "#173a3a", "#22544a", "#2f7056", "#478e62", "#6cac74", "#a0cf90" }
local SLEAF = { "#1c4438", "#286044", "#3a7e4c", "#559c58", "#7cba6a", "#b2da8a" }
local KS = { "#2a1418", "#4a2220", "#6e3826", "#94542e", "#b8783e", "#d8a05a" }
local STEM = { "#5a2c36", "#86443e", "#b0684e", "#d8946a" }
local RIND = { "#24402a", "#3a5e30", "#567c38", "#76984a", "#9cb862", "#c6d88a" }
local FLESH = { "#8a4e5c", "#b0727e", "#cc96a0", "#e2b8b8", "#f2d6cc", "#fcece2" }
local SPINE = { "#7a5432", "#c09358", "#ecd096" }

-- kidney seed mask + normals
local function kidney(cx, cy, r, ang)
  local m = G.rell(cx, cy, cos(ang), sin(ang), r + 0.35, r)
  local nx, ny = cx + cos(ang + pi / 2) * (r + 0.2), cy + sin(ang + pi / 2) * (r + 0.2)   -- hilum notch on the lower side
  m:cut(G.rell(nx, ny, 1, 0, 1.3, 1.3))
  return m, X.sphere(cx - 0.3, cy - 0.3, r + 0.3, m)
end
local seeds = { { 29, 52, 2.7, 0.2 }, { 35, 55.5, 2.5, -0.4 }, { 42, 49.5, 2.8, 0.1 }, { 25, 56.5, 2.2, 0.6 } }
for _, s in ipairs(seeds) do s.m, s.n = kidney(s[1], s[2], s[3], s[4]) end
-- caperberry half
local BX, BY, BA = 16.5, 50.5, -0.35
local bm, bn = G.oval(BX, BY, 6.3, 3.5, BA, 0.6)
local stalkP = { { 10.5, 48 }, { 8, 46 }, { 8, 42 }, { 10, 39 } }
local stm = G.tube(stalkP, function(t) return 0.7 end)
stm:cut(bm)
local allC = HP.mask() for _, s in ipairs(seeds) do allC:add(s.m) end allC:add(bm)

local lm, LT, LS, ltok = A.scrap(c, {
  a = { 8, 47 }, c = { 30, 59 }, b = { 57, 50 }, W = 8.6, fold = 0.35,
  prof = function(t) return sin(pi * (0.28 + 0.72 * t)) ^ 0.5 end,
  ramp = LEAF, vein = "#b6e0a0", cool = "#3c6878", torn = "#cfe6b0", per = 6.8,
  tear = { t0 = 0.03, amp = 0.08, seed = 21 }, casters = { allC }, name = "leaf" })

-- sprout from seed 3
local stok = { r = { name = "stem" } }
local sm = A.stem(c, { { 42, 48 }, { 40, 40 }, { 43, 33 }, { 41, 22 } }, function(t) return 1.1 - 0.2 * t end, STEM, stok)
local lt = { r = { name = "sleaf" } }
local fleshy = function(t) return sin(pi * min(1, t * 0.9 + 0.1)) ^ 0.45 end
A.leaflet(c, 41, 33, 36, 30, 31, 31, 2.3, fleshy, SLEAF, lt, { cutBy = { sm } })
A.leaflet(c, 43, 33, 48, 30, 53, 30, 2.3, fleshy, SLEAF, lt, { cutBy = { sm } })
-- round true leaves on petioles
local function roundLeaf(px, py, cx, cy, ra, rb, ux, uy)
  for i = 0, 6 do local t = i / 6 c:put(floor(px + (cx - px) * t * 0.6 + 0.5), floor(py + (cy - py) * t * 0.6 + 0.5), STEM[3], stok) end
  local m = G.rell(cx, cy, ux, uy, ra, rb)
  m:set(floor(cx + ux * (ra + 0.8) + 0.5), floor(cy + uy * (ra + 0.8) + 0.5))
  m:cut(sm)
  local n = X.pillow(m, 1.8)
  G.toneN(c, m, n, SLEAF, { tok = lt, cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, amb = 0.12 })
  m:each(function(x, y)
    local dx, dy = x - cx, y - cy
    local a, b = dx * ux + dy * uy, -dx * uy + dy * ux
    if abs(b) < 0.5 and a > -ra + 0.5 and a < ra - 0.5 then c:put(x, y, b <= 0 and SLEAF[6] or SLEAF[3], lt) end end)
end
roundLeaf(41, 23, 35.5, 18.5, 3.6, 2.9, -0.8, -0.6)
roundLeaf(41, 23, 47, 17.5, 3.4, 2.7, 0.75, -0.66)
c:put(41, 21, SLEAF[5], lt) c:put(41, 20, SLEAF[4], lt)          -- shoot tip
-- stipule spines at the cotyledon node
c:put(39, 36, SPINE[3]) c:put(38, 36, SPINE[2]) c:put(45, 36, SPINE[2]) c:put(46, 37, SPINE[1])

-- caperberry: stalk, rind ring, flesh face with seeds
local ktok = { r = { name = "stalk" } }
local _, sn = G.tube(stalkP, function(t) return 0.7 end)
X.tone(c, stm, X.light(sn, { amb = 0.15, wrap = 0.3 }), RIND, { cuts = { 0.2, 0.36, 0.52, 0.68, 0.84 }, tok = ktok })
local rtok, ftok = { r = { name = "rind" } }, { r = { name = "flesh" } }
local inner = bm:shrink(1)
local ring = bm:copy():cut(inner)
G.toneN(c, ring, bn, RIND, { tok = rtok, cuts = { 0.15, 0.3, 0.46, 0.62, 0.8 }, amb = 0.1 })
-- rind ribs: darker ticks along the ring
local ca, sa = cos(BA), sin(BA)
ring:each(function(x, y) local dx, dy = x - BX, y - BY local u = (dx * ca + dy * sa)
  if floor(u + 10) % 3 == 0 then c:put(x, y, RIND[2], rtok) end end)
-- flesh: shallow bowl (lit lower-right inside the rim, dark under the upper-left rim)
local fb = {}
inner:each(function(x, y) local k = K(x, y)
  local dx, dy = x - BX, y - BY
  local u, v = (dx * ca + dy * sa) / 5.3, (-dx * sa + dy * ca) / 2.5
  local d = u * u + v * v
  local i = 5
  if d > 0.55 then i = (u + v < 0) and 3 or 6 end
  if d > 0.55 and (u + v < -0.6) then i = 2 end
  c:put(x, y, FLESH[i], ftok)
end)
-- embedded seeds in two rows
for i = -2, 2 do for _, row in ipairs{ -0.9, 0.9 } do
  local u = i * 1.9 + (row > 0 and 0.9 or 0)
  if abs(u) < 4.2 then
    local x, y = floor(BX + u * ca - row * sa + 0.5), floor(BY + u * sa + row * ca + 0.5)
    if inner:has(x, y) then c:put(x, y, KS[2], ftok) if inner:has(x - 1, y) and row < 0 then c:put(x - 1, y, KS[4], ftok) end end
  end
end end
c:put(floor(BX - 1 + 0.5), floor(BY + 0.5), FLESH[6], ftok)          -- wet glint on the flesh

-- seeds last
for i, s in ipairs(seeds) do
  local tok = { r = { name = "seed" .. i } }
  local vis = s.m:copy()
  if i == 3 then vis:cut(HP.mask()) end
  local idx = G.toneN(c, vis, s.n, KS, { tok = tok, cuts = { 0.15, 0.32, 0.5, 0.66, 0.82 }, amb = 0.08 })
  vis:each(function(x, y) local k = K(x, y)
    if (idx[k] or 3) >= 3 and (idx[k] or 3) <= 4 and X.hash(x, y, 13 + i) > 0.78 then c:put(x, y, KS[(idx[k] or 3) - 1], tok) end end)
  local gx, gy = G.specAt(vis, s.n, 50) if gx then c:put(gx, gy, "#f6dcae", tok) end
end

G.save2(c, NAME)
