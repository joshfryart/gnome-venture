-- coconut-curry (final, Opus single pass). Golden curry served in half a coconut shell: hairy-fibred brown shell
-- (sphere-lit, fibre streaks, cool bounce), a cream flesh rim with a thin brown lip, glossy curry (oil glint,
-- potato cubes, chilli rings, a coriander leaf), a slim wooden spoon leaning out. Ground shadow (it stands).
-- quirk: one lazy curl of steam, rising from the spoon.
local NAME = "coconut-curry"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aB20_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)

local SHELL = { "#24141a", "#3e2220", "#5c3426", "#7c4a2e", "#9c663a", "#c08a50" }
local FLESH = { "#8a7a6a", "#b5a68c", "#d8c9a8", "#ecdfbe", "#fff4d6" }
local CUR = { "#8a3a1a", "#b4521c", "#d6721e", "#ec9428", "#f8b84a", "#ffe08a" }
local WOOD = { "#4e2e26", "#7c4a32", "#a66c40", "#c98e56", "#e8b982" }
local STEAM = { "#c8c0d8", "#e6e2ee", "#fff4d6" }
local CH = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c" }
local HERB = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local POT = { "#c4943e", "#e8c060", "#fbe49a" }
local CX, CY = 32, 32

c:groundShadow(32, 50, 16, 2)

-- shell bowl: lower half of a sphere plus the rim ellipse
local bowl = HP.mask()
A.rell(CX, CY, 1, 0, 21.5, 17.5):each(function(x, y) if y >= CY then bowl:set(x, y) end end)
local rimE = A.rell(CX, CY, 1, 0, 21.5, 6.2)
local curry = A.rell(CX, CY + 0.6, 1, 0, 18.2, 4.3)
local stok, ftok, ctok = { r = { name = "shell" } }, { r = { name = "flesh" } }, { r = { name = "curry" } }
local bn = X.sphere(CX - 1, CY - 4, 21, bowl)
local bview = bowl:copy():cut(rimE)
local sidx = A.shade(c, bview, bn, SHELL, { tok = stok, amb = 0.08, wrap = 0.25 })
-- fibre streaks: short dark/pale strokes following the curve
bview:each(function(x, y) local k = K(x, y)
  local h = X.hash(floor(x / 1), floor((y + x * 0.35) / 3), 21)
  if h > 0.8 and sidx[k] > 1 then c:put(x, y, SHELL[sidx[k] - 1], stok)
  elseif h < 0.08 and sidx[k] < 6 then c:put(x, y, SHELL[sidx[k] + 1], stok) end end)
local rim = X.rim(bn)
bview:edge():each(function(x, y) if rim[K(x, y)] > 0.72 and y > CY + 4 then c:put(x, y, "#5a4a72", stok) end end)
-- rim: thin brown lip at the outer edge, cream flesh ring inside
local ring = rimE:copy():cut(curry)
ring:each(function(x, y)
  local u, v = (x - CX) / 21.5, (y - CY) / 6.2
  local q = u * u + v * v
  if q > 0.8 then c:put(x, y, (y >= CY) and SHELL[4] or SHELL[3], stok)
  else
    local i = (y < CY) and ((x < CX) and 3 or 2) or ((x < CX - 6) and 5 or 4)
    if y < CY and q < 0.62 then i = i - 1 end          -- inner back wall falls into shade
    c:put(x, y, FLESH[max(1, i)], ftok)
  end end)
-- curry surface: shallow pillow + slow ripples
local cn = X.pillow(curry, 2.5, 0.6)
local cb = {}
X.ao(cb, curry, ring, 1, -1)
local cidx = A.shade(c, curry, cn, CUR, { tok = ctok, bias = cb, amb = 0.42, wrap = 0.3, cuts = { 0.2, 0.36, 0.55, 0.7, 0.86 } })
curry:each(function(x, y) local k = K(x, y)
  if not cb[k] and ((x * 0.45 + y * 1.6) % 5.0) < 0.7 and cidx[k] > 2 then c:put(x, y, CUR[cidx[k] - 1], ctok) end end)

-- toppings
local function cube(x, y) c:put(x, y, POT[3], ctok) c:put(x + 1, y, POT[2], ctok) c:put(x, y + 1, POT[2], ctok) c:put(x + 1, y + 1, POT[1], ctok) c:put(x, y + 2, CUR[2], ctok) c:put(x + 1, y + 2, CUR[2], ctok) end
cube(21, 31) cube(36, 33) cube(28, 34)
local function chilli(x, y) c:put(x, y, CH[3], ctok) c:put(x + 1, y, CH[4], ctok) c:put(x + 2, y, CH[3], ctok)
  c:put(x, y + 1, CH[2], ctok) c:put(x + 1, y + 1, POT[3], ctok) c:put(x + 2, y + 1, CH[2], ctok) c:put(x + 1, y + 2, CH[1], ctok) end
chilli(16, 33) chilli(31, 30)
for _, q in ipairs{ { 42, 31, 3 }, { 43, 31, 4 }, { 44, 32, 3 }, { 43, 32, 2 }, { 42, 32, 2 }, { 45, 33, 2 }, { 44, 33, 1 } } do c:put(q[1], q[2], HERB[q[3]], ctok) end
-- oil glint
c:put(24, 30, "#fff4d6", ctok) c:put(25, 30, CUR[6], ctok)

-- spoon: handle rising out of the curry to the upper right
local wtok = { r = { name = "spoon" } }
local hp = { { 38, 31 }, { 43, 25 }, { 48, 19 }, { 53, 13 } }
local hm, hn, HT, HS = A.tube(hp, function(t) return 1.25 + 0.2 * t end)
hm:each(function(x, y) if curry:has(x, y) and HT[K(x, y)] < 0.08 then hm.s[K(x, y)] = nil end end)
local hidx = A.shade(c, hm, hn, WOOD, { tok = wtok, cuts = { 0.25, 0.45, 0.65, 0.83 }, amb = 0.12, wrap = 0.3 })
hm:each(function(x, y) local k = K(x, y)
  if abs(HS[k]) < 0.25 and (HT[k] * 26) % 4 < 1 then c:put(x, y, WOOD[max(1, hidx[k] - 1)], wtok) end end)
do local x, y = A.bez(hp, 1) c:put(floor(x + .5), floor(y + .5), WOOD[5], wtok) end
-- dark curry meniscus where the handle enters
for _, q in ipairs{ { 37, 32 }, { 38, 32 }, { 39, 32 }, { 40, 31 } } do if curry:has(q[1], q[2]) and not hm:has(q[1], q[2]) then c:put(q[1], q[2], CUR[1], ctok) end end

-- quirk: a single curl of steam
local etok = { r = { name = "steam" } }
local sp1 = { { 26, 25 }, { 21, 20 }, { 31, 16 }, { 25, 9 } }
for i = 0, 60 do local t = i / 60 local x, y = A.bez(sp1, t)
  local xi, yi = floor(x + .5), floor(y + .5)
  c:put(xi, yi, t < 0.3 and STEAM[1] or (t < 0.75 and STEAM[2] or STEAM[3]), etok)
end

A.save(c, NAME)
