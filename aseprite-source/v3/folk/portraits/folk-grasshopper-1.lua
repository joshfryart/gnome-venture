-- folk-grasshopper-1 portrait (folk F2_0) variant: 1
-- Generic rest-stop grasshopper villager, gardener: leaf-green grasshopper, straw hat with tomato band + sprig, denim bib, trowel.
local NAME = "folk-grasshopper-1"
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
local BODY = R("#2e5a5a", "#3f8a52", "#78bf48", "#c4e46a")
local EYE = R("#5a3448", "#8a5a46", "#c08a4a", "#eac27a")
local STRAW = R("#7a5240", "#b98a48", "#e4bc62", "#f8e4a0")
local TOM = R("#7a3448", "#b04848", "#de6648", "#f6a070")
local DEN = R("#3a3e6e", "#4e62a0", "#6e8cc8", "#a8c4e8")
local LEAF = R("#2e5a4a", "#3e8a4a", "#62b04a", "#a8dc6a")
local METAL = R("#4e4a6a", "#7e7c9a", "#b4b4c8", "#e8e6f0")
local WOOD = R("#5a3444", "#8a5440", "#b87a4a", "#e0a868")
local BG = R("#8a4462", "#c0606a", "#e98a6c", "#f6b08a")
V.wear = function(c)
  part(c, c:rrect(28, 82, 51, 99, 3), DEN, 2, 30, 84)
  part(c, c:line({ { 30, 83 }, { 28, 72 } }, 3), DEN, 1)
  part(c, c:line({ { 49, 83 }, { 51, 72 } }, 3), DEN, 1)
  part(c, c:rect(29, 83, 31, 85), STRAW, 1, 29, 83) part(c, c:rect(48, 83, 50, 85), STRAW, 1, 48, 83)
  c:fillMask(c:rrect(34, 89, 45, 96, 1):edge(), DEN.shade)
end
V.lateAnt = true
V.antP = { { { 34, 18 }, { 29, 9 }, { 25, 3 } }, { { 45, 18 }, { 50, 9 }, { 54, 3 } } }
V.hat = function(c)
  local brim = c:ellipse(39.5, 33, 25, 5.5)
  part(c, brim, STRAW, 2, 18, 32)
  local crown = c:rrect(27, 13, 52, 31, 7)
  part(c, crown, STRAW, 2, 31, 16)
  part(c, c:rect(27, 26, 52, 30):clip(crown), TOM, 1, 29, 27)
  for y = 15, 24, 3 do for x = 29 + (y % 2) * 2, 50, 4 do if crown:has(x, y) then c:put(x, y, STRAW.shade) end end end
  for x = 16, 63, 3 do if brim:has(x, 35) then c:put(x, 35, STRAW.shade) end end
  c:fillMask(c:line({ { 51, 28 }, { 57, 20 } }, 1), LEAF.shade)
  part(c, oval(58, 18, 4, 2, -50), LEAF, 1)
  part(c, oval(55, 24, 3.5, 1.5, -10), LEAF, 1)
end
V.prop = function(c)
  local bl = c:poly{ { 56, 56 }, { 68, 56 }, { 66, 66 }, { 62, 74 }, { 58, 66 } }
  part(c, bl, METAL, 2, 58, 57)
  c:fillMask(c:line({ { 62, 58 }, { 62, 70 } }, 1), METAL.shade)
  c:put(61, 71, WOOD.deep) c:put(63, 69, WOOD.deep) c:put(60, 67, WOOD.deep)
  part(c, c:rect(61, 74, 63, 77), METAL, 1)
  part(c, c:rrect(60, 77, 64, 92, 2), WOOD, 1, 61, 78)
  part(c, c:ellipse(62, 86, 4, 3.5), BODY, 1, 60, 84)
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
