-- root_cellar-2 (Opus-style single pass, artist D13_1). Tier 2: a taller turf mound with its crown leaning right; the door
-- now sits in a mortared stone arch (radial voussoirs, long-and-short jambs), and a slim pole with a swallow-tail red flag
-- is planted in the crown. Wild flowers dot the turf, loose pebbles lie at the foot.
-- quirk: the flag is tied on with cord and the lower knot has slipped, so a cream string tail dangles and curls.
local NAME = "root_cellar-2"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_1.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local c = A.new(NAME)
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local GR, SO, ST = A.GRASS, A.SOIL, A.STONE

local CX, YB = 29, 54
c:groundShadow(CX + 1, YB + 4, 24, 2)
local m = A.dome(CX, YB, 22, 32, 2.5, 4)
local W, H, TH = 7, 19, 3
local outer = A.arch(CX, YB, W + TH, H + TH)
local crownX = CX + 4

local bias = {}
X.ao(bias, m, outer, 2, -1)
G.cast(bias, m, outer, 1, 1, -1)
G.cast(bias, m, outer, 2, 2, -1)
local gtok = { r = { name = "grass" } }
local idx = A.pill(c, m, GR, 14, { bias = bias, tok = gtok, amb = .1, wrap = .3, cuts = { .22, .4, .56, .72, .88 } })
A.flecks(c, m, idx, GR, 33, .06, gtok)
m:edge():each(function(x, y)
  local k = K(x, y)
  if x > CX + 6 and y > 40 and y < YB - 3 and idx[k] and idx[k] <= 3 then c:put(x, y, "#2f7a72", gtok) end
end)
-- blades along the crown and a few flowers
local function tuft(x, y, h)
  for i = 0, h - 1 do c:put(x, y - i, (i == h - 1) and GR[6] or GR[4], gtok) end
  c:put(x - 1, y - 1, GR[3], gtok) c:put(x + 1, y - 1, GR[5], gtok)
end
tuft(crownX - 5, 23, 3) tuft(crownX + 6, 25, 2) tuft(CX - 14, 37, 3)
for _, p in ipairs{ { 17, 44 }, { 42, 38 }, { 23, 28 } } do
  c:put(p[1], p[2], "#fff4d6", gtok) c:put(p[1] + 1, p[2], "#ffd678", gtok) c:put(p[1], p[2] + 1, GR[2], gtok)
end
-- lilac wildflower pair
c:put(40, 47, "#c9b2f0", gtok) c:put(41, 47, "#8a6fd0", gtok) c:put(40, 48, GR[2], gtok)

-- soil lip, scalloped turf, pebbles
local soil = A.soil(c, CX, YB, 23, 6)
A.soilPaint(c, soil, 8)
for x = CX - 22, CX + 22, 3 do
  local d = (X.hash(x, 1, 12) > .5) and 2 or 1
  for y = YB - 4, YB - 4 + d do c:put(x, y, GR[3], gtok) c:put(x + 1, y, GR[2], gtok) end
end

-- stone arch frame, then the recessed door
A.stoneFrame(c, CX, YB, W, H, TH, 6)
local door = A.door(c, CX, YB, W, H, { pw = 4 })
A.ironwork(c, CX, YB, W, H)
-- keystone: one proud block at the crown
for x = CX - 2, CX + 1 do
  c:put(x, YB - H - TH, ST[5]) c:put(x, YB - H - TH + 1, ST[4])
end
c:put(CX - 2, YB - H - TH, ST[6]) c:put(CX - 1, YB - H - TH, ST[6])
c:put(CX - 3, YB - H - TH + 1, ST[2]) c:put(CX + 2, YB - H - TH + 1, ST[2])
-- doorstep + stray pebbles
local step = c:rect(CX - 8, YB + 1, CX + 7, YB + 2)
A.pill(c, step, ST, 1.5, { amb = .15 })
c:put(CX - 4, YB + 1, ST[6]) c:put(CX - 3, YB + 1, ST[6])
c:put(CX + 14, YB, ST[5]) c:put(CX + 15, YB, ST[3]) c:put(CX - 15, YB - 1, ST[4]) c:put(CX - 14, YB - 1, ST[2])

-- flag on a slim pole planted in the crown
local px, top = crownX, 9
local fm = A.flag(c, px, YB - 28, top, { len = 13, hgt = 9, taper = .12 })
-- the pole's foot sits in a little heap of earth
for _, p in ipairs{ { px - 1, YB - 28 }, { px + 2, YB - 28 } } do c:put(p[1], p[2], SO[4]) end
-- quirk: cord ties. top knot holds, lower knot slipped and the tail curls free
local CORD, CORD2 = "#fff0c8", "#d8b878"
local ty = top + 2
c:put(px - 1, ty, CORD2) c:put(px, ty, CORD) c:put(px + 1, ty, CORD) c:put(px + 2, ty, CORD2)
local by = top + 8
c:put(px, by, CORD) c:put(px + 1, by, CORD2)
c:put(px - 1, by + 1, CORD) c:put(px - 1, by + 2, CORD2) c:put(px - 2, by + 3, CORD) c:put(px - 1, by + 4, CORD2) c:put(px, by + 4, CORD)
c:put(px + 1, by + 3, CORD2)
A.save(c)
