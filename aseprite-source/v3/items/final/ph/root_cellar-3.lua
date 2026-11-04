-- root_cellar-3 (Opus-style single pass, artist D13_1). Tier 3: the full cellar. A broad turf mound (crown leaning left)
-- with a mortared stone arch, a squared timber lintel (end grain showing) above it, two stone steps, an iron-hooped
-- barrel hard against the mound, and a small flag on the crown.
-- quirk: a crooked wooden sign swings from the lintel on two unequal chains, a tiny carrot painted on it.
local NAME = "root_cellar-3"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aD13_1.lua")
local G, HP, X, K = A.G, A.HP, A.X, A.K
local c = A.new(NAME)
local floor, abs, sin, cos, pi, max, min, sqrt = math.floor, math.abs, math.sin, math.cos, math.pi, math.max, math.min, math.sqrt
local GR, SO, ST, WD, IR = A.GRASS, A.SOIL, A.STONE, A.WOOD, A.IRON

local CX, YB = 32, 49
local DX = 34                     -- door centre (barrel takes the left)
c:groundShadow(CX + 1, YB + 8, 25, 2)
local m = A.dome(CX, YB, 24, 28, 2.4, -2)
local W, H, TH = 7, 19, 3
local outer = A.arch(DX, YB, W + TH, H + TH)
local beam = c:rect(DX - 14, YB - 26, DX + 13, YB - 23)
-- tilted sign mask
local sx, sy = DX + 8, YB - 19
local sign = HP.mask()
for x = 0, 9 do for y = 0, 6 do sign:set(sx + x, sy + y + floor(x * 0.3)) end end
local barrelM = HP.mask()
for y = YB - 12, YB do for x = 6, 17 do barrelM:set(x, y) end end

local bias = {}
for _, p in ipairs{ outer, beam, sign } do
  X.ao(bias, m, p, 1, -1)
  G.cast(bias, m, p, 1, 1, -1)
end
G.cast(bias, m, sign, 2, 3, -1)
G.cast(bias, m, outer, 2, 2, -1)
X.ao(bias, m, barrelM, 1, -1)
local gtok = { r = { name = "grass" } }
local idx = A.pill(c, m, GR, 15, { bias = bias, tok = gtok, amb = .1, wrap = .3, cuts = { .22, .4, .56, .72, .88 } })
A.flecks(c, m, idx, GR, 51, .06, gtok)
m:edge():each(function(x, y)
  local k = K(x, y)
  if x > CX + 8 and y > 36 and y < YB - 3 and idx[k] and idx[k] <= 3 then c:put(x, y, "#2f7a72", gtok) end
end)
local function tuft(x, y, h)
  for i = 0, h - 1 do c:put(x, y - i, (i == h - 1) and GR[6] or GR[4], gtok) end
  c:put(x - 1, y - 1, GR[3], gtok) c:put(x + 1, y - 1, GR[5], gtok)
end
tuft(CX + 6, 23, 3) tuft(CX - 14, 27, 2) tuft(CX + 17, 33, 2)
for _, p in ipairs{ { 20, 31 }, { 49, 40 }, { 41, 21 } } do
  c:put(p[1], p[2], "#fff4d6", gtok) c:put(p[1] + 1, p[2], "#ffd678", gtok) c:put(p[1], p[2] + 1, GR[2], gtok)
end

-- soil lip
local soil = A.soil(c, CX, YB, 25, 4)
A.soilPaint(c, soil, 2)
for x = CX - 24, CX + 24, 3 do
  local d = (X.hash(x, 1, 15) > .5) and 2 or 1
  for y = YB - 4, YB - 4 + d do c:put(x, y, GR[3], gtok) c:put(x + 1, y, GR[2], gtok) end
end

-- stone arch + door
A.stoneFrame(c, DX, YB, W, H, TH, 9)
A.door(c, DX, YB, W, H, { pw = 4 })
A.ironwork(c, DX, YB, W, H)
for x = DX - 2, DX + 1 do c:put(x, YB - H - TH, ST[5]) c:put(x, YB - H - TH + 1, ST[4]) end
c:put(DX - 2, YB - H - TH, ST[6]) c:put(DX - 1, YB - H - TH, ST[6])
c:put(DX - 3, YB - H - TH + 1, ST[2]) c:put(DX + 2, YB - H - TH + 1, ST[2])

-- timber lintel
local btok = { r = { name = "beam" } }
local bb = {}
A.pill(c, beam, WD, 1.8, { tok = btok, amb = .12 })
for x = DX - 12, DX + 11 do
  if X.hash(x, 3, 5) > .45 then c:put(x, YB - 25, WD[3], btok) end
  if X.hash(x, 4, 6) > .6 then c:put(x, YB - 24, WD[2], btok) end
end
-- end grain squares with growth rings
for _, ex in ipairs{ DX - 14, DX + 12 } do
  for y = YB - 26, YB - 23 do c:put(ex, y, WD[6], btok) c:put(ex + 1, y, WD[5], btok) end
  c:put(ex, YB - 25, WD[4], btok) c:put(ex + 1, YB - 24, WD[3], btok)
end
c:put(DX - 11, YB - 26, WD[6], btok) c:put(DX - 10, YB - 26, WD[6], btok)
-- shadow under the lintel on the stone/turf
for x = DX - 12, DX + 11 do
  if not beam:has(x, YB - 22) and not outer:has(x, YB - 22) then c:put(x, YB - 22, GR[2]) end
end
-- two nails
c:put(DX - 6, YB - 24, IR[5], btok) c:put(DX + 6, YB - 24, IR[5], btok)

-- quirk: crooked sign on two chains of different lengths
local stok = { r = { name = "sign" } }
local sidx = A.pill(c, sign, WD, 1.6, { tok = stok, amb = .14 })
sign:each(function(x, y)
  local lx = x - sx
  if (lx == 0 or lx == 9) then c:put(x, y, WD[2], stok) end
  if X.hash(x, y, 14) > .86 then c:put(x, y, WD[3], stok) end
end)
-- chains (hooks at the beam, links alternate)
local function chain(x, y0, y1)
  for y = y0, y1 do c:put(x, y, ((y - y0) % 2 == 0) and IR[5] or IR[2]) end
end
chain(sx + 1, YB - 22, sy)
chain(sx + 8, YB - 22, sy + floor(8 * 0.3) - 1)
c:put(sx + 1, YB - 23, IR[6]) c:put(sx + 8, YB - 23, IR[6])
-- tiny painted carrot (orange wedge + green top)
local O = A.CARROT
c:put(sx + 2, sy + 3, O[5]) c:put(sx + 3, sy + 3, O[4]) c:put(sx + 4, sy + 3, O[3]) c:put(sx + 5, sy + 4, O[2])
c:put(sx + 3, sy + 4, O[4]) c:put(sx + 4, sy + 4, O[3])
c:put(sx + 6, sy + 4, O[2]) c:put(sx + 6, sy + 5, O[1]) c:put(sx + 7, sy + 5, O[1])
c:put(sx + 1, sy + 2, "#68b956") c:put(sx + 2, sy + 2, "#94d166") c:put(sx + 1, sy + 3, "#43944e")
c:put(sx + 3, sy + 1, "#2a6845")

-- stone steps: lit top faces, shaded fronts, a chip
local function slab(x0, x1, y0, ytop)
  local top = c:rect(x0, y0, x1, y0 + 1)
  local fr = c:rect(x0, y0 + 2, x1, y0 + 3)
  A.pill(c, top, ST, 1.4, { amb = .3, wrap = .4 })
  for x = x0, x1 do c:put(x, y0, ST[6]) c:put(x, y0 + 1, ST[5]) c:put(x, y0 + 2, ST[3]) c:put(x, y0 + 3, ST[2]) end
  c:put(x1, y0 + 1, ST[4]) c:put(x1, y0 + 2, ST[2]) c:put(x0, y0 + 2, ST[4])
  for x = x0 + 3, x1 - 3, 5 do c:put(x, y0 + 2, ST[2]) end
end
slab(DX - 11, DX + 10, YB + 1, 0)
slab(DX - 13, DX + 12, YB + 4, 0)
c:put(DX + 3, YB + 5, ST[6]) c:put(DX + 4, YB + 5, ST[6])

-- barrel by the wall
local bm = A.barrel(c, 11, YB - 11, 12, 6)
-- contact: turf darkened under its left lip, shadow on the soil to its right
for y = YB - 8, YB do c:put(18, y, GR[1]) end
c:put(17, YB + 1, SO[1]) c:put(16, YB + 1, SO[1])
-- a bung and a drip
c:put(11, YB - 5, WD[1]) c:put(12, YB - 5, WD[2]) c:put(11, YB - 4, WD[3])

-- small flag on the crown (pole leans a touch)
local px, top = CX - 7, 8
A.flag(c, px, 24, top, { len = 11, hgt = 7, taper = .15 })
c:put(px - 1, 24, SO[4]) c:put(px + 2, 24, SO[4])
c:put(px - 1, top + 2, "#fff0c8") c:put(px, top + 2, "#fff0c8") c:put(px + 1, top + 2, "#fff0c8") c:put(px + 2, top + 2, "#d8b878")
c:put(px - 1, top + 6, "#fff0c8") c:put(px, top + 6, "#fff0c8") c:put(px + 1, top + 6, "#fff0c8") c:put(px + 2, top + 6, "#d8b878")
A.save(c)
