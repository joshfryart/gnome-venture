-- miso (final, Opus single pass). A small cedar miso keg (taru): bulged staves with seams and grain, two twisted bamboo
-- hoops that wrap round the curve, pale end-grain rim, a glossy mound of chunky brown miso with koji grit and one
-- specular, and a slim hinoki paddle sunk in the paste (miso smear on its foot, end-grain cap). Stands on a ground shadow.
-- quirk: one soybean on the mound has sprouted a tiny green shoot.
local NAME = "miso"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC23_5.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local c = A.new(NAME)
local WOOD = { "#3a1a1e", "#5c2a24", "#84402a", "#aa5c34", "#cc7e46", "#e8a466" }
local RIM = { "#6a3a26", "#9a5e36", "#c08452", "#dca870", "#f0c88e", "#fce4b4" }
local BAM = { "#3a3618", "#5e5a22", "#848430", "#a8a648", "#cac86c", "#e8e6a0" }
local MISO = { "#45200f", "#6c3616", "#965220", "#bc722e", "#dc9a46", "#f2c470" }
local PAD = { "#5a3a24", "#86603a", "#ac8652", "#cca86e", "#e6c892", "#f8e6be" }
local BEAN = { "#5a4020", "#86662e", "#b09048", "#d0b468", "#e8d48e", "#f8eec0" }
local CX = 32

c:groundShadow(CX, 57, 15, 1)

local function hw(y) return 12.4 + 1.4 * sin(pi * min(1, max(0, (y - 29) / 26))) end
local function inEl(x, y, cx, cy, rx, ry) return ((x - cx) / rx) ^ 2 + ((y - cy) / ry) ^ 2 <= 1 end

-- masks
local wall, hoop, rimM, rimFront, mound = HP.mask(), HP.mask(), HP.mask(), HP.mask(), HP.mask()
local U, HD = {}, {}
for y = 22, 58 do for x = 14, 50 do
  local w = hw(y)
  local u = (x - CX) / (w + 0.5)
  local front = sqrt(max(0, 1 - u * u))
  if abs(x - CX) <= w and y >= 30 and y <= 53 + 2.4 * front then wall:set(x, y) U[K(x, y)] = u end
  for _, yc in ipairs{ 34.5, 48.5 } do
    local d = y - (yc + 2.3 * front)
    if abs(x - CX) <= w + 1 and d >= -1.5 and d < 1.5 and y >= 30 then hoop:set(x, y) HD[K(x, y)] = { d, u } end
  end
  if inEl(x, y, CX, 30, 13.2, 3.7) and not inEl(x, y, CX, 30.3, 10.8, 2.6) then
    rimM:set(x, y) if y >= 30 then rimFront:set(x, y) end end
  local u2 = (x - CX) / 11.2
  if abs(u2) < 1 then
    local ytop = 30.3 - 2.6 * sqrt(1 - u2 * u2) - 6.2 * (1 - u2 * u2) ^ 1.25
    if (y >= ytop and y <= 30) or inEl(x, y, CX, 30.3, 10.8, 2.6) then mound:set(x, y) end
  end
end end
mound:cut(rimFront)
wall:cut(rimM)
hoop:cut(rimM)

-- paddle: slim hinoki shaft sunk into the paste, up and to the right
local pp = { { 38, 31 }, { 41, 24 }, { 45, 17 }, { 48, 10 } }
local pm, pn, PT, PS = A.tube(pp, function(t) return 1.25 + 0.35 * t end)
local sub = HP.mask()
pm:each(function(x, y) if mound:has(x, y) and y > 27 then sub:set(x, y) end end)
pm:cut(sub):cut(rimFront)

-- soybean (quirk) on the mound, left side
local bm, bn = A.oval(26, 25.5, 2.4, 1.7, -0.35, 0.8)

-- wall: bulged barrel, staves, grain, AO under rim and around hoops
local wb = {}
X.ao(wb, wall, hoop, 1, -1)
X.ao(wb, wall, rimFront, 1, -1)
local wn = {}
wall:each(function(x, y) local u = U[K(x, y)] * 0.96
  local ny = (y - 43) / 34
  wn[K(x, y)] = { A.norm(u, ny, sqrt(max(0.03, 1 - u * u - ny * ny))) } end)
local wtok = { r = { name = "keg" } }
local widx = A.shade(c, wall, wn, WOOD, { amb = 0.08, wrap = 0.3, bias = wb, tok = wtok })
wall:each(function(x, y) local k = K(x, y)
  local th = math.asin(max(-1, min(1, U[k]))) / 0.42 + 0.5
  local st, f = floor(th), th - floor(th)
  if f < 0.13 then A.step(c, widx, WOOD, x, y, -2, wtok)
  elseif abs(f - 0.55) < 0.1 and X.hash(st, floor(y / 3), 5) > 0.35 then A.step(c, widx, WOOD, x, y, -1, wtok)
  elseif f > 0.2 and f < 0.32 and U[k] < -0.2 and X.hash(st, floor(y / 4), 8) > 0.6 then A.step(c, widx, WOOD, x, y, 1, wtok) end
end)
-- cool bounce light on the far right of the wall
wall:each(function(x, y) local k = K(x, y) if U[k] > 0.9 and y > 37 and y < 52 and not wb[k] then c:put(x, y, "#5a3448", wtok) end end)

-- hoops: twisted bamboo, curving round the keg
local hn = {}
hoop:each(function(x, y) local d = HD[K(x, y)] local u = max(-0.95, min(0.95, d[2]))
  local ny = d[1] / 2.2
  hn[K(x, y)] = { A.norm(u, ny, sqrt(max(0.03, 1 - u * u - ny * ny))) } end)
local htok = { r = { name = "hoop" } }
local hidx = A.shade(c, hoop, hn, BAM, { amb = 0.1, wrap = 0.3, tok = htok })
hoop:each(function(x, y) local d = HD[K(x, y)]
  if (x + floor(d[1] + 1.5)) % 4 == 0 then A.step(c, hidx, BAM, x, y, -2, htok)
  elseif (x + floor(d[1] + 1.5)) % 4 == 1 and d[1] < -0.5 then A.step(c, hidx, BAM, x, y, 1, htok) end end)

-- rim: pale end grain, lit from the left, stave seams cut across it
local rtok = { r = { name = "rim" } }
rimM:each(function(x, y)
  local u = (x - CX) / 13.2
  local i = y >= 30 and 5 or 3
  if u < -0.5 then i = i + 1 elseif u > 0.55 then i = i - 1 end
  if y >= 30 and inEl(x, y, CX, 30, 13.2, 3.7) and not inEl(x, y + 1, CX, 30, 13.2, 3.7) then i = i - 1 end
  local th = math.asin(max(-1, min(1, u))) / 0.42 + 0.5
  if th - floor(th) < 0.1 and y >= 30 then i = i - 2 end
  c:put(x, y, RIM[max(1, min(6, i))], rtok)
end)

-- mound: glossy chunky paste with koji grit; AO under the front rim, around paddle and bean
local mb = {}
X.ao(mb, mound, rimFront, 1, -1)
X.ao(mb, mound, pm, 1, -1) A.cast(mb, mound, pm, 1, 1, -1)
X.ao(mb, mound, bm, 1, -1) A.cast(mb, mound, bm, 1, 1, -1)
local mn = A.body(mound, CX - 1, 31, 11.5, 3.5, 0.65)
local mtok = { r = { name = "miso" } }
local midx = A.shade(c, mound, mn, MISO, { amb = 0.06, wrap = 0.24, bias = mb, tok = mtok })
mound:each(function(x, y) local h = X.hash(x, y, 31)
  if h > 0.86 then A.step(c, midx, MISO, x, y, 1, mtok) elseif h < 0.08 then A.step(c, midx, MISO, x, y, -1, mtok) end end)
local sx, sy = A.specAt(mound, mn, 30)
c:put(sx, sy, "#fff0c8", mtok) c:put(sx + 1, sy, MISO[6], mtok)

-- paddle: lit shaft, a grain line, end-grain cap, miso smear on the foot
local ptok = { r = { name = "paddle" } }
local pidx = A.shade(c, pm, pn, PAD, { amb = 0.14, wrap = 0.3, tok = ptok })
pm:each(function(x, y) local k = K(x, y) local t, s = PT[k], PS[k]
  if t < 0.22 then c:put(x, y, MISO[max(2, min(6, (pidx[k] or 3)))], ptok)
  elseif t > 0.94 then c:put(x, y, s < 0.2 and PAD[6] or PAD[4], ptok)
  elseif abs(s - 0.25) < 0.22 and X.hash(floor(t * 12), 1, 4) > 0.3 then A.step(c, pidx, PAD, x, y, -1, ptok) end end)

-- soybean + sprout (quirk)
local btok = { r = { name = "bean" } }
local bidx = A.shade(c, bm, bn, BEAN, { amb = 0.1, wrap = 0.25, tok = btok })
c:put(27, 26, BEAN[2], btok) c:put(25, 24, BEAN[6], btok)
local gtok = { r = { name = "sprout" } }
for _, q in ipairs{ { 26, 23, "#4f8a3a" }, { 26, 22, "#6aa848" }, { 25, 21, "#2e6a36" }, { 27, 21, "#9ad064" }, { 28, 20, "#6aa848" }, { 24, 20, "#4f8a3a" } } do
  c:put(q[1], q[2], q[3], gtok) end

A.save(c, NAME)
