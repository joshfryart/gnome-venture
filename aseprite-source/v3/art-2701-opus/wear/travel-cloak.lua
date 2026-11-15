-- travel-cloak: Travel Cloak icon (Opus pass, art-2701). 64x64.
-- "Wool against the wind, moss green with a wooden toggle." The cloak hangs on a wooden wall peg by a cord loop:
-- the hood lies bunched behind the neck, an empty neck hole (dark inside, tan wool lining rim), a wooden toggle on
-- cord loops closing the throat, sloped shoulders flaring to a wide hem. Below the toggle the two fronts part in a
-- narrow V that shows the dark inside back and a tan lining edge. Deep drape folds radiate from the neck and scallop
-- the hem; soft wool speckle. quirk: an orange autumn leaf caught on the hem.
-- Reuses (read-only) v3/gnome-wear/_gw.lua: pillow lighting, 6-tone ramps (cloak, lining, wood, autumn).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(DIR .. "/_o.lua")
local W = dofile(DIR .. "/../../gnome-wear/_gw.lua")
local HP, X, K, R, G = W.HP, W.X, W.K, W.R, W.G
local sin, cos, abs, sqrt, floor, max, min, pi = math.sin, math.cos, math.abs, math.sqrt, math.floor, math.max, math.min, math.pi
local c = HP.canvas{ w = 64, h = 64, scale = 1, name = "travel-cloak" }
local CX = 31.5

-- silhouette: half-width per row, scalloped hem
local function hw(y)
  if y < 30 then local t = (y - 21) / 9 return 6 + 11 * sqrt(max(0, 1 - (1 - t) ^ 2)) end
  return 17 + (y - 30) * 7 / 26
end
local FOLDS = 6   -- fold ridges across the cloak
local function phase(x, y) return (x - CX) / (y - 12) * FOLDS * 1.15 end
local function hem(x) return 56 + floor(1.2 * cos(phase(x, 56) * pi) + 0.5) end
local body = HP.mask()
for y = 21, 58 do
  local h = hw(min(y, 56))
  for x = floor(CX - h + 0.5), floor(CX + h + 0.5) do if y <= hem(x) then body:set(x, y) end end
end
-- front opening below the toggle (inverted V)
local function op(y) return (y - 27) / 29 * 3.6 end
local inside, lining, front = HP.mask(), HP.mask(), HP.mask()
body:each(function(x, y)
  local d = abs(x + 0.5 - (CX + 0.5))
  if y >= 29 and d < op(y) then inside:set(x, y)
  elseif y >= 28 and d < op(y) + 1 then lining:set(x, y)
  else front:set(x, y) end
end)

-- hood bunched behind the neck
local hood = c:ellipse(CX, 17, 10.5, 5.5)
-- peg and hanging loop
local peg = c:ellipse(CX, 5.5, 3, 2.5)
local cord = c:line({ { 28, 13 }, { 29, 8 }, { 31.5, 7.5 }, { 34, 8 }, { 35, 13 } }, 1)

-- ---------------------------------------------------------------- paint, back to front
-- cord loop (behind the peg's front face)
cord:each(function(x, y) c:put(x, y, R.lining[(x < 32) and 4 or 3]) end)
-- hood
local hn = X.pillow(hood, 4)
local hidx = W.toneN(c, hood, hn, R.cloak, { cuts = { .22, .4, .56, .72, .9 } })
W.speckle(c, hood, hidx, R.cloak, 0.06, 3)
-- hood seam (centre back of the hood folded over)
for y = 12, 15 do c:put(32, y, R.cloak[2]) end
-- body: normals = pillow + drape folds that deepen toward the hem
local pn = X.pillow(body, 5)
local n = {}
front:each(function(x, y)
  local p = pn[K(x, y)]
  local depth = min(1, max(0, (y - 24) / 24)) * 1.15
  local fx = sin(phase(x, y) * pi) * depth
  local round = (x + 0.5 - CX - 0.5) / hw(min(y, 56)) * 0.55   -- the whole cloak rounds away to the right
  local nx, ny, nz = p[1] + fx + round, p[2] - 0.05, p[3]
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[K(x, y)] = { nx / l, ny / l, nz / l }
end)
local bias = {}
-- shoulders a touch brighter, under the hood a contact shadow
X.ao(bias, front, hood, 2, -1)
local fidx = W.toneN(c, front, n, R.cloak, { bias = bias, cuts = { .2, .36, .52, .7, .88 } })
W.speckle(c, front, fidx, R.cloak, 0.05, 7)
-- inside back of the cloak (dark) and the lining edges
inside:each(function(x, y) c:put(x, y, (y > 50) and R.cloak[2] or R.cloak[1]) end)
lining:each(function(x, y) c:put(x, y, (x < CX) and R.lining[5] or R.lining[3]) end)
-- hem: a deep row on the bottom edge of each fold, lit tip at the ridge fronts
body:each(function(x, y) if not body:has(x, y + 1) and front:has(x, y) then c:put(x, y, R.cloak[(fidx[K(x, y)] or 3) >= 4 and 3 or 1]) end end)
-- separation between hood and shoulders
hood:grow(1):cut(hood):clip(front):each(function(x, y) if y >= 18 and abs(x + 0.5 - CX - 0.5) > 6 then c:put(x, y, R.cloak[(x < CX) and 2 or 1]) end end)
-- neck hole: dark empty inside, tan lining rim (lit left, shade right)
local neck = c:ellipse(CX, 19.5, 4, 1.5)
neck:grow(1):cut(neck):each(function(x, y)
  if y >= 20 then c:put(x, y, (x < CX - 1) and R.lining[5] or R.lining[3])   -- the collar's lining rolls out at the front
  else c:put(x, y, R.cloak[2]) end
end)
neck:each(function(x, y) c:put(x, y, R.cloak[1]) end)
-- peg: end grain disc with growth ring
local pidx = W.lit(c, peg, R.wood, { R = 2 })
c:put(31, 5, R.wood[3]) c:put(32, 5, R.wood[3]) c:put(30, 4, R.wood[6])
-- toggle: cord loops on both fronts and a wooden bar across the throat
for _, q in ipairs{ { 26, 25 }, { 27, 26 }, { 26, 26 }, { 37, 25 }, { 36, 26 }, { 37, 26 } } do c:put(q[1], q[2], R.lining[4]) end
c:put(27, 25, R.lining[6]) c:put(36, 25, R.lining[3])
local bar = c:rrect(28, 24, 35, 26, 1)
W.lit(c, bar, R.wood, { R = 1 })
for x = 29, 34 do c:put(x, 24, R.wood[5]) end
c:put(29, 24, R.wood[6]) c:put(30, 24, R.wood[6])
for x = 29, 34 do c:put(x, 26, R.wood[2]) end
c:put(28, 25, R.wood[3]) c:put(35, 25, R.wood[2])
for x = 29, 34 do if front:has(x, 27) then c:put(x, 27, R.cloak[2]) end end   -- contact shadow under the toggle
-- fold valleys: a dark crease line where each fold turns away, from mid cloak to the hem
front:each(function(x, y)
  if y >= 31 and not lining:has(x, y) then
    local a, b = sin(phase(x, y) * pi), sin(phase(x + 1, y) * pi)
    if a > 0 and b <= 0 and y < hem(x) then c:put(x, y, R.cloak[(y > 44) and 1 or 2]) end
  end
end)
-- quirk: autumn leaf caught on the hem, lower left, its tip hanging past the edge
local leaf = c:poly{ { 10, 51 }, { 13, 49 }, { 17, 49 }, { 20, 51 }, { 18, 54 }, { 15, 57 }, { 12, 58 }, { 11, 55 } }
W.lit(c, leaf, R.autumn, { R = 2, cuts = { .2, .34, .5, .68, .86 } })
for _, q in ipairs{ { 19, 51 }, { 18, 52 }, { 17, 53 }, { 16, 54 }, { 15, 55 }, { 14, 56 }, { 13, 57 } } do c:put(q[1], q[2], R.autumn[2]) end   -- midrib
c:put(15, 52, R.autumn[3]) c:put(14, 53, R.autumn[3]) c:put(18, 55, R.autumn[3])   -- veins
c:put(20, 50, R.wood[2]) c:put(21, 49, R.wood[2])   -- stalk
c:put(12, 51, R.autumn[6]) c:put(13, 51, R.autumn[6])

c:finish{ outline = true }
G.centre(c)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = O.OUT .. "travel-cloak.aseprite", png = O.OUT .. "travel-cloak.png", scale = 1 }
