-- folk-grasshopper-2 portrait (folk F2_0) variant: 2
-- Generic rest-stop grasshopper villager, traveller: ochre locust, plum flat cap, teal scarf, canvas pack + bedroll, brass lantern.
local NAME = "folk-grasshopper-2"
local W, H = 80, 100
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = "#2b1c26"
local function R(d, s, b, h) return { deep = d, shade = s, base = b, hi = h } end
local function part(c, m, r, band, px, py)
  if px and m:has(px, py) then c:part(m, r, { band = band or 1, pop = { x = px, y = py } })
  else c:part(m, r, { band = band or 1, nopop = true }) end
  return m
end
local function oval(cx, cy, rx, ry, deg)
  local a = math.rad(deg)
  local ca, sa, m = math.cos(a), math.sin(a), HP.mask()
  for y = math.floor(cy - rx - 1), math.ceil(cy + rx + 1) do for x = math.floor(cx - rx - 1), math.ceil(cx + rx + 1) do
    local dx, dy = x + .5 - cx, y + .5 - cy
    local u, v = dx * ca + dy * sa, -dx * sa + dy * ca
    if (u / (rx + .3)) ^ 2 + (v / (ry + .3)) ^ 2 <= 1 and x >= 0 and y >= 0 and x < W and y < H then m:set(x, y) end
  end end
  return m
end
local function ribs(c, m, r, s, step)
  m:copy():shrink(1):each(function(x, y)
    local k = (s < 0) and (x + y) or (y - x)
    if k % step == 0 then c:put(x, y, r.shade) end
  end)
end
local V = {}
local W, H = 80, 100
local BODY = R("#5a3a4e", "#8e5e48", "#c48e4c", "#ecc684")
local EYE = R("#3a3050", "#5a4a6e", "#8a6a8a", "#c4a0b0")
local PLUM = R("#3e2a52", "#5e3a6e", "#8a4e8a", "#c07ab0")
local TEAL = R("#2a4a62", "#2e7a80", "#3eae9e", "#90e0c8")
local CANVAS = R("#4a4a4e", "#6e7050", "#9ea064", "#d0cc8e")
local RUST = R("#6a3444", "#a04a40", "#cc6a44", "#f09a68")
local BRASS = R("#6a4a3e", "#a0703e", "#d4a04a", "#f4d27e")
local GLOW = R("#c0703e", "#f0a040", "#fcd070", "#fff0b8")
local BG = R("#5a4680", "#80629e", "#b08ac4", "#d4b4e0")
V.back = function(c)
  part(c, c:rrect(20, 62, 59, 80, 5), CANVAS, 2, 22, 63)
  local roll = oval(18, 64, 15, 5, -25)
  part(c, roll, RUST, 2)
  for _, x in ipairs{ 10, 23 } do c:fillMask(c:line({ { x, 56 }, { x + 3, 74 } }, 1):clip(roll), RUST.deep) end
end
V.wear = function(c)
  part(c, c:line({ { 29, 80 }, { 27, 99 } }, 4), CANVAS, 1)
  part(c, c:line({ { 50, 80 }, { 52, 99 } }, 4), CANVAS, 1)
  part(c, c:rect(25, 90, 30, 92), BRASS, 1, 26, 90) part(c, c:rect(49, 90, 54, 92), BRASS, 1, 50, 90)
  for _, q in ipairs{ { 35, 88 }, { 42, 92 }, { 38, 96 }, { 45, 86 }, { 22, 93 }, { 58, 94 } } do c:put(q[1], q[2], BODY.shade) end
end
V.lateAnt = true
V.antP = { { { 30, 28 }, { 20, 15 }, { 13, 10 } }, { { 49, 28 }, { 59, 15 }, { 66, 10 } } }
V.hat = function(c)
  part(c, c:rrect(19, 66, 60, 77, 5), TEAL, 2, 22, 68)
  for _, x in ipairs{ 27, 35, 43, 51 } do c:fillMask(c:line({ { x, 68 }, { x + 2, 75 } }, 1), TEAL.shade) end
  local tail = c:poly{ { 21, 72 }, { 30, 74 }, { 29, 97 }, { 20, 95 } }
  part(c, tail, TEAL, 2, 23, 76)
  tail:each(function(x, y) if not tail:has(x, y + 1) and x % 2 == 0 then c:put(x, y, TEAL.deep) end end)
  part(c, c:ellipse(25, 75, 4.5, 3.5), TEAL, 1, 23, 74)
  local dome = c:ellipse(39.5, 35, 21, 12):clip(c:rect(0, 0, 79, 34))
  part(c, dome, PLUM, 2, 29, 27)
  for _, a in ipairs{ 28, 51 } do c:fillMask(c:line({ { 39, 24 }, { a, 34 } }, 1):clip(dome), PLUM.shade) end
  local peak = c:ellipse(39.5, 35, 17, 3.5):clip(c:rect(0, 35, 79, 45))
  part(c, peak, PLUM, 1)
  peak:each(function(x, y) if not peak:has(x, y + 1) then c:put(x, y, PLUM.deep) end end)
  part(c, c:ellipse(39.5, 23.5, 2.5, 1.5), PLUM, 1)
end
V.prop = function(c)
  c:fillMask(c:line({ { 63, 80 }, { 63, 83 } }, 1), BRASS.deep)
  part(c, c:rrect(58, 83, 68, 86, 1), BRASS, 1, 59, 83)
  part(c, c:rect(59, 87, 67, 94), GLOW, 2, 60, 88)
  c:fillMask(c:rect(63, 87, 63, 94), BRASS.shade)
  c:put(61, 91, GLOW.deep) c:put(61, 90, GLOW.base)
  part(c, c:rrect(57, 95, 69, 98, 1), BRASS, 1, 58, 95)
  part(c, c:ellipse(63, 78, 4, 3.5), BODY, 1, 61, 76)
end

local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
local function antennae()
  for _, pts in ipairs(V.antP) do
    local m = c:line(pts, 2)
    part(c, m, BODY, 1)
    for i = 1, #pts - 1 do c:put(pts[i + 1][1], pts[i + 1][2], BODY.shade) end
  end
end
if V.back then V.back(c) end
for _, s in ipairs{ -1, 1 } do
  local function X(x) return s < 0 and x or 79 - x end
  part(c, c:line({ { X(12), 70 }, { X(8), 84 }, { X(7), 99 } }, 2), BODY, 1)
  for _, y in ipairs{ 80, 88, 95 } do c:put(X(y < 85 and 8 or 6), y, BODY.deep) end
  local hx, hy, kx, ky = X(17), 99, X(12), 69
  local fem = oval((hx + kx) / 2, (hy + ky) / 2 + 2, 16, 5.5, math.deg(math.atan(ky - hy, kx - hx)))
  part(c, fem, BODY, 2)
  ribs(c, fem, BODY, s, 3)
  part(c, c:ellipse(kx, ky, 3, 3), BODY, 1)
  c:put(kx, ky + 1, BODY.deep) c:put(kx + s, ky + 1, BODY.deep) c:put(kx - s, ky - 1, BODY.hi)
end
part(c, c:ellipse(39.5, 104, 27, 24):clip(c:rect(0, 0, 79, 99)), BODY, 3, 20, 88)
part(c, c:rrect(22, 68, 57, 84, 6), BODY, 2, 26, 70)
c:fillMask(c:line({ { 27, 72 }, { 29, 83 } }, 1), BODY.shade) c:fillMask(c:line({ { 52, 72 }, { 50, 83 } }, 1), BODY.shade)
if V.wear then V.wear(c) end
if not V.lateAnt then antennae() end
local head = c:ellipse(39.5, 44, 19.5, 17)
head:add(c:ellipse(39.5, 57, 14, 11))
part(c, head, BODY, 3, 28, 33)
for y = 44, 53 do c:put(33, y, BODY.shade) c:put(46, y, BODY.shade) end
for _, ex in ipairs{ 24, 55 } do
  local em = c:ellipse(ex, 42, 5.5, 7.5)
  part(c, em, EYE, 2, ex - 3, 37)
  for _, q in ipairs{ {-3,-5},{0,-6},{3,-4},{-4,4},{3,5},{0,6},{-4,-1},{4,1},{-2,6},{2,-6} } do
    if em:has(ex + q[1], 42 + q[2]) then c:put(ex + q[1], 42 + q[2], EYE.shade) end end
end
c:eyeLocked(22, 40) c:eyeLocked(53, 40)
part(c, c:poly{ { 35, 53 }, { 44, 53 }, { 43, 58 }, { 36, 58 } }, BODY, 1, 36, 54)
c:fillMask(c:ellipse(39.5, 60, 3, 1.5), BODY.shade) c:put(38, 59, BODY.base)
c:fillMask(c:poly{ { 31, 60 }, { 35, 61 }, { 34, 65 } }, EYE.deep)
c:fillMask(c:poly{ { 48, 60 }, { 44, 61 }, { 45, 65 } }, EYE.deep)
c:put(35, 62, INK) c:put(44, 62, INK)
for x = 36, 43 do c:put(x, 63, INK) end
for x = 37, 42 do c:put(x, 64, INK) end
c:put(38, 63, EYE.deep) c:put(39, 63, P.petal.base) c:put(40, 63, P.petal.base) c:put(41, 63, EYE.deep)
c:paint({ "PPP", "PPP" }, 26, 54, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 51, 54, { P = "petal.base" })
if V.hat then V.hat(c) end
if V.lateAnt then antennae() end
if V.prop then V.prop(c) end
c:finish{ outline = true }
backdrop(BG)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
