-- broken-masterwork-secateurs (final, Opus single pass). Bypass pruners lying on the diagonal: slim curved red-lacquer
-- grips with brass bolsters and brass end caps, a twisted steel coil spring between them, a gilt pivot screw, a thin
-- convex steel cutting blade (bevel, honed edge, specular streak) and a stouter hooked anvil blade behind it.
-- broken: the cutting blade has snapped two-thirds along; the tip lies off to the upper right, a steel chip flies off.
-- quirk: a single pink rose petal is still caught on the anvil hook.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB12_1.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, sin, cos, pi, max, min = math.floor, math.sin, math.cos, math.pi, math.max, math.min
local c = A.new("broken-masterwork-secateurs")
local ST, BR, RD = A.STEEL, A.BRASS, A.RED

local PX, PY = 34, 28
local function gripW(t) if t < 0.26 then return 1.25 elseif t > 0.92 then return 1.55 end return 1.45 + 0.25 * sin((t - 0.26) / 0.66 * pi) end
local h1 = A.geo({ { 35, 29 }, { 32, 39 }, { 27, 46 }, { 25, 52 } }, gripW)       -- back handle
local h2 = A.geo({ { 33, 28 }, { 27, 33 }, { 19, 39 }, { 12, 44 } }, gripW)       -- front handle
local b2 = A.geo({ { 35, 28 }, { 42, 25 }, { 49, 22 }, { 53, 15 } }, function(t) return 1.9 - 0.7 * t end) -- anvil hook
local BP = { { 33, 27 }, { 34, 19 }, { 40, 12 }, { 48, 7 } }
local function bw(t) return 0.45 + 1.9 * (1 - t) ^ 0.85 end
local b1 = A.geo(BP, function(t) if t > 0.58 then return 0 end return bw(t) end) -- cutting blade, snapped

-- anvil blade (back)
A.paint(c, b2, ST, { ao = { b1.m }, name = "anvil" })
A.streak(c, b2, -0.6, -0.25, 0.15, 0.8)
-- back handle: brass bolster, red grip, brass cap
local function handle(h, ao)
  local s1, s2, s3 = A.sub(h, 0, 0.26), A.sub(h, 0.26, 0.92), A.sub(h, 0.92, 1)
  A.paint(c, s1, BR, { ao = ao, name = "bolster" })
  A.paint(c, s2, RD, { ao = { s1.m, s3.m, table.unpack(ao or {}) }, name = "grip" })
  A.paint(c, s3, BR, { ao = { s2.m }, name = "cap" })
  A.streak(c, s2, -0.65, -0.3, 0.32, 0.6, RD[6], 4)
  A.band(c, h, 0.68, BR, s2.tok) -- gilt inlay ring
  return s2
end
handle(h1, { h2.m })
-- coil spring between the grips (twisted wire: alternating lit / dark turns)
do
  local ax, ay = A.at(h1, 0.33)
  local bx, by = A.at(h2, 0.36)
  local n = 6
  local tok = A.tok("spring")
  for i = 0, n do
    local t = i / n
    local x, y = ax + (bx - ax) * t, ay + (by - ay) * t
    local ox, oy = 0.6, 0.9
    local xi, yi = floor(x + .5), floor(y + .5)
    c:put(xi, yi, (i % 2 == 0) and ST[5] or ST[2], tok)
    c:put(xi + (i % 2 == 0 and 0 or 1), yi + 1, (i % 2 == 0) and ST[3] or ST[4], tok)
  end
end
handle(h2, nil)
-- cutting blade (front)
A.paint(c, b1, ST, { name = "blade" })
A.streak(c, b1, -0.55, -0.2, 0.12, 0.55)
-- honed bevel along the cutting (inner, lower-right) edge
b1.m:edge():each(function(x, y) local k = K(x, y) if b1.S[k] > 0.45 and b1.T[k] > 0.12 then c:put(x, y, ST[5], b1.tok) end end)
-- jagged break: bite a notch out of the stump end
for _, q in ipairs{ { 39, 13 }, { 40, 13 } } do A.clear(c, HP.rect(q[1], q[2], q[1], q[2])) end
-- the snapped tip, displaced up-right and turned a little
do
  local function bez(t) local u = 1 - t
    return u^3*BP[1][1] + 3*u*u*t*BP[2][1] + 3*u*t*t*BP[3][1] + t^3*BP[4][1],
           u^3*BP[1][2] + 3*u*u*t*BP[2][2] + 3*u*t*t*BP[3][2] + t^3*BP[4][2] end
  local ox, oy = bez(0.66)
  local a = -0.32
  local pts = {}
  for i, t in ipairs{ 0.66, 0.77, 0.88, 1 } do
    local x, y = bez(t)
    local dx, dy = x - ox, y - oy
    pts[i] = { ox + 4 + dx * cos(a) - dy * sin(a), oy - 3 + dx * sin(a) + dy * cos(a) }
  end
  local tip = A.geo(pts, function(t) return bw(0.66 + 0.34 * t) end)
  A.paint(c, tip, ST, { name = "tip" })
  A.streak(c, tip, -0.6, -0.2, 0.1, 0.7)
  -- raw broken face on the tip end: dark steel
  tip.m:each(function(x, y) if tip.T[K(x, y)] < 0.08 then c:put(x, y, ST[2], tip.tok) end end)
end
-- flying chip
A.chip(c, { { 36.5, 9 }, { 39.5, 8 }, { 38.5, 10.5 } }, ST)
-- gilt pivot screw with a dark slot
do
  local s = A.ball(c, PX, PY, 2.2, BR, { amb = 0.15 })
  c:put(PX - 1, PY + 1, BR[1], s.tok) c:put(PX, PY, BR[1], s.tok) c:put(PX + 1, PY - 1, BR[1], s.tok)
  c:put(PX - 1, PY - 1, BR[6], s.tok)
end
-- quirk: a rose petal caught on the anvil hook
do
  local tok = A.tok("petal")
  A.map(c, { ".ab", "abc", "bcd" }, 49, 17, { a = A.PINK[6], b = A.PINK[4], c = A.PINK[3], d = A.PINK[2] }, tok)
end
A.save(c, "broken-masterwork-secateurs")
