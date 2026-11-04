-- folk-grasshopper-3 portrait (folk F2_0) variant: 3
-- Generic rest-stop grasshopper villager, cook: rose-pink grasshopper, polka-dot mustard kerchief with knot, cream apron, copper ladle of soup.
local NAME = "folk-grasshopper-3"
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
local BODY = R("#6a3a6a", "#ac5a88", "#e888a6", "#fcc0c8")
local EYE = R("#3a3060", "#5a4c8a", "#8a7cba", "#c0b4e0")
local MUST = R("#7a4a3e", "#c08032", "#ecb440", "#fae08a")
local APRON = R("#6e6a88", "#a8a4bc", "#e6dcc8", "#faf2e0")
local COPPER = R("#5a3444", "#94504a", "#cc7a4a", "#f4b882")
local SOUP = R("#7a4a3e", "#b06a3a", "#e09a3a", "#f8cc6a")
local BG = R("#466e94", "#5e98b4", "#8cc8d4", "#c0e4e8")
V.wear = function(c)
  c:fillMask(c:line({ { 31, 81 }, { 35, 71 } }, 2), APRON.shade)
  c:fillMask(c:line({ { 48, 81 }, { 44, 71 } }, 2), APRON.shade)
  local bib = c:rrect(27, 80, 52, 99, 3)
  part(c, bib, APRON, 2, 29, 82)
  for x = 27, 52 do if bib:has(x, 84) then c:put(x, 84, MUST.base) end end
  c:fillMask(c:rrect(33, 89, 46, 97, 2):edge(), APRON.shade)
end
V.lateAnt = true
V.antP = { { { 34, 28 }, { 31, 15 }, { 28, 7 } }, { { 45, 28 }, { 48, 15 }, { 51, 7 } } }
V.hat = function(c)
  local k = c:ellipse(39.5, 44, 20.5, 18):clip(c:rect(0, 0, 79, 35))
  part(c, k, MUST, 2, 27, 30)
  for _, q in ipairs{ { 30, 29 }, { 38, 27 }, { 46, 29 }, { 34, 33 }, { 42, 33 }, { 25, 33 }, { 52, 33 }, { 51, 29 } } do
    if k:has(q[1], q[2]) and k:has(q[1] + 1, q[2]) then c:put(q[1], q[2], APRON.hi) c:put(q[1] + 1, q[2], APRON.hi) end end
  part(c, c:poly{ { 61, 31 }, { 69, 25 }, { 68, 33 } }, MUST, 1)
  part(c, c:poly{ { 61, 34 }, { 68, 39 }, { 63, 40 } }, MUST, 1)
  part(c, c:ellipse(59, 33, 3.5, 3), MUST, 1, 58, 32)
end
V.prop = function(c)
  part(c, c:line({ { 61, 68 }, { 64, 92 } }, 3), COPPER, 1)
  part(c, c:ellipse(61, 63, 7, 4.5), COPPER, 2, 57, 61)
  part(c, c:ellipse(61, 62.5, 5, 2.5), SOUP, 1, 59, 62)
  c:fillMask(c:rect(66, 67, 66, 69), SOUP.base)
  part(c, c:ellipse(63, 86, 4, 3.5), BODY, 1, 61, 84)
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
