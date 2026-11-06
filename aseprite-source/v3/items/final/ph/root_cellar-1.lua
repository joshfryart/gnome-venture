-- root_cellar-1 (Opus-style single pass, artist D13_1). Tier 1: a low, round turf mound dug into the ground, speckled
-- grass with a scalloped turf lip over bare soil and pebbles, a plain round-top plank door set deep in a dark earth
-- reveal (iron straps, ring handle, planks with grain), one flat doorstep stone.
-- Series: tier 2 adds a stone arch frame + flag, tier 3 adds beam/sign, steps, barrel.
-- quirk: a carrot crown is pushing up out of the turf beside the door, its feathery top waving.
local NAME = "root_cellar-1"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_1.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local c = A.new(NAME)
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local GR, SO, ST = A.GRASS, A.SOIL, A.STONE

local CX, YB = 31, 53
c:groundShadow(CX + 1, YB + 4, 23, 2)

local m = A.dome(CX, YB, 21, 27, 2.3, -1)
local doorW, doorH = 7, 19
local door = A.arch(CX + 1, YB, doorW, doorH)
local reveal = A.arch(CX + 1, YB, doorW + 2, doorH + 2):cut(door)
local carrot, cn = G.oval(14, 43, 3.6, 2.8, -0.5, 1.0)

-- grass dome: lit from the upper left, AO and a reflected cool rim where the reveal bites in
local bias = {}
X.ao(bias, m, reveal, 2, -1)
G.cast(bias, m, reveal, 1, 1, -1)
X.ao(bias, m, carrot, 1, -1)
G.cast(bias, m, carrot, 1, 2, -1)
local gtok = { r = { name = "grass" } }
local idx = A.pill(c, m, GR, 13, { bias = bias, tok = gtok, amb = .1, wrap = .3, cuts = { .22, .4, .56, .72, .88 } })
A.flecks(c, m, idx, GR, 21, .055, gtok)
-- cool violet bounce on the lower-right rim of the dome
m:edge():each(function(x, y)
  local k = K(x, y)
  if x > CX + 6 and y > 38 and y < YB - 3 and idx[k] and idx[k] <= 3 then c:put(x, y, "#2f7a72", gtok) end
end)
-- tufts and a clover flower on the dome
local function tuft(x, y, h)
  for i = 0, h - 1 do c:put(x, y - i, (i == h - 1) and GR[6] or GR[4], gtok) end
  c:put(x - 1, y - 1, GR[3], gtok) c:put(x + 1, y - 1, GR[5], gtok)
end
tuft(CX + 4, 27, 3) tuft(CX - 6, 29, 2) tuft(CX + 13, 34, 3)
for _, p in ipairs{ { 20, 33 }, { 44, 42 } } do
  c:put(p[1], p[2], "#fff4d6", gtok) c:put(p[1] + 1, p[2] + 1, "#ffd678", gtok) c:put(p[1] - 1, p[2] + 1, GR[2], gtok)
end

-- bare soil lip with a scalloped turf overhang and pebbles
local soil = A.soil(c, CX, YB, 22, 3)
A.soilPaint(c, soil, 5)
for x = CX - 21, CX + 21, 3 do
  local d = (X.hash(x, 1, 9) > .5) and 2 or 1
  for y = YB - 4, YB - 4 + d do c:put(x, y, GR[3], gtok) c:put(x + 1, y, GR[2], gtok) end
end
c:put(CX - 10, YB - 1, ST[5]) c:put(CX - 9, YB - 1, ST[4]) c:put(CX - 10, YB, ST[3])
c:put(CX + 14, YB, ST[5]) c:put(CX + 15, YB, ST[3])

-- door recessed into a dark earth reveal
local rtok = { r = { name = "reveal" } }
local rb = {}
local ridx = A.pill(c, reveal, SO, 1.6, { bias = rb, tok = rtok, amb = .02, wrap = .1, cuts = { .35, .55, .7, .82, .92 } })
reveal:each(function(x, y) if X.hash(x, y, 8) > .9 then c:put(x, y, SO[4], rtok) end end)
-- a root hair or two hanging in the reveal
c:put(CX - 6, YB - 17, SO[5], rtok) c:put(CX - 6, YB - 16, SO[4], rtok)
A.door(c, CX + 1, YB, doorW, doorH, { pw = 4 })
A.ironwork(c, CX + 1, YB, doorW, doorH)
-- AO under the reveal's top edge and cast shadow on the door's left side
for y = YB - doorH + 4, YB do c:put(CX - doorW + 1, y, A.WOOD[1]) end
-- doorstep stone
local step = c:rect(CX - 7, YB + 1, CX + 9, YB + 2)
A.pill(c, step, ST, 1.5, { amb = .15 })
c:put(CX - 3, YB + 1, ST[6]) c:put(CX - 2, YB + 1, ST[6])

-- quirk: a carrot crown pushing out of the turf
local ctok = { r = { name = "carrot" } }
G.toneN(c, carrot, cn, A.CARROT, { tok = ctok, amb = .2, wrap = .4 })
c:put(12, 42, "#ffe9a0", ctok) c:put(13, 42, A.CARROT[6], ctok) c:put(16, 44, A.CARROT[2], ctok) c:put(15, 45, A.CARROT[2], ctok)
c:put(10, 44, A.CARROT[1], ctok) c:put(11, 45, A.CARROT[1], ctok)
-- feathery leaves
local function feather(ax, ay, bx, by, bend)
  local mx, my = (ax + bx) / 2, (ay + by) / 2
  local dx, dy = bx - ax, by - ay
  local l = sqrt(dx * dx + dy * dy)
  local m2, n2, T, S = G.blade(ax, ay, mx + (-dy / l) * bend, my + (dx / l) * bend, bx, by, function(t) return max(0.4, 0.95 * (1 - t * .5)) end, { fold = .2 })
  m2:each(function(x, y)
    local k = K(x, y)
    local i = (S[k] < -.2) and 5 or ((S[k] < .4) and 4 or 2)
    c:put(x, y, GR[i], ctok)
  end)
end
feather(13, 41, 7, 35, -1.5) feather(14, 41, 11, 31, -1) feather(15, 41, 16, 30, 1) feather(15, 41, 21, 34, 1.5)
c:put(7, 35, GR[6], ctok) c:put(11, 31, GR[6], ctok) c:put(16, 30, GR[6], ctok) c:put(21, 34, GR[6], ctok)
A.save(c)
