-- ico-flag-red (final, Opus single pass). A red swallowtail pennant rippling off a slim wooden pole that is
-- planted in a little grassy soil mound; gold ball finial; two rope lashings tie the flag to the pole.
-- Material: cloth = per-pixel light from a ripple height field (6-tone red, vertical fold ridges and troughs),
-- one gold stitched hem along the top; pole = 6-tone cylinder with grain streaks and a specular edge, AO where
-- the flag and lashings meet it; rope = twisted gold strands; finial = glossy sphere with a glint; mound = soil
-- with grass blades and a contact shadow at the pole foot.
-- quirk: one loose thread is unravelling from the lower swallowtail point.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local A = dofile(DIR .. "/../_helpers/_aA4_2.lua")
local HP, X, K = A.HP, A.X, A.K
local floor, max, min, abs, sqrt, sin, cos = math.floor, math.max, math.min, math.abs, math.sqrt, math.sin, math.cos
local c = A.new("ico-flag-red")

local RED  = { "#4e1530", "#7e1f37", "#b22a3a", "#dc3c3a", "#f2643f", "#ff9a66" }
local WOOD = { "#3a2226", "#5a3328", "#7f4a31", "#a5683f", "#c98d58", "#e8b982" }
local GOLD = { "#6e3a1c", "#a8601e", "#d98322", "#f5b82e", "#ffe38a", "#fff4d6" }
local SOIL = { "#3a2226", "#5a3328", "#7f4a31", "#a5683f", "#c98d58" }
local GRASS = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }
local CUTS = { 0.22, 0.4, 0.56, 0.72, 0.87 }

local PX0, PX1 = 14, 17          -- pole columns
local FX0, FX1 = 18, 53          -- flag span
local function off(x) return 2.0 * sin((x - FX0) / 4.6) end
local function hgt(x) return 1.9 * sin((x - FX0) / 4.6 + 1.2) end

-- mound (draw first, pole sits in it)
local mound = A.ell(16, 51, 8.5, 3.2)
do
  local b = {}
  mound:each(function(x, y) local k = K(x, y) if abs(x - 15.5) < 3 and y <= 50 then b[k] = -1 end end)
  A.shade(c, mound, X.pillow(mound, 2.5), SOIL, { cuts = { 0.25, 0.45, 0.62, 0.8 }, bias = b, tok = A.tok("soil") })
  -- crumbs
  c:put(11, 51, SOIL[2]) c:put(20, 52, SOIL[2]) c:put(13, 49, SOIL[5])
end

-- flag cloth
local fm = HP.mask()
for x = FX0, FX1 do
  local u = (x - FX0) / (FX1 - FX0)
  local top = floor(12 + off(x) + u * 2.5 + .5)
  local bot = floor(34 + off(x) - u * 3.0 + .5)
  local mid = (top + bot) / 2
  local notch = x > 44 and (x - 44) * 1.25 or 0
  for y = top, bot do
    if not (abs(y - mid) < notch) then fm:set(x, y) end
  end
end
local pn = X.pillow(fm, 1.5)
local n = {}
fm:each(function(x, y) local k = K(x, y)
  local gx = (hgt(x + 1) - hgt(x - 1)) / 2
  local p = pn[k]
  local nx, ny, nz = p[1] - gx, p[2], p[3]
  local l = sqrt(nx * nx + ny * ny + nz * nz)
  n[k] = { nx / l, ny / l, nz / l }
end)
local ftok = A.tok("flag")
local fb = {}
fm:each(function(x, y) if x <= FX0 + 1 then fb[K(x, y)] = -1 end end)
local fidx = A.shade(c, fm, n, RED, { cuts = CUTS, bias = fb, tok = ftok, amb = 0.1 })
-- gold stitched hem along the top (2 on, 1 off), following the ripple
do
  local i = 0
  for x = FX0 + 3, 44 do
    local u = (x - FX0) / (FX1 - FX0)
    local y = floor(12 + off(x) + u * 2.5 + .5) + 2
    if i % 3 < 2 and fm:has(x, y) then c:put(x, y, (fidx[K(x, y)] or 3) >= 4 and GOLD[5] or GOLD[4], ftok) end
    i = i + 1
  end
end

-- pole
local pole = c:rect(PX0, 10, PX1, 51)
do
  local b = {}
  X.ao(b, pole, fm, 1, -1)
  pole:each(function(x, y) local k = K(x, y) if y >= 49 then b[k] = (b[k] or 0) - 1 end end)
  local m, pn2 = X.cyl(PX0 + 1.5, 5, PX0 + 1.5, 60, function() return 1.6 end, pole)
  local tok = A.tok("pole")
  local idx = A.shade(c, pole, pn2, WOOD, { cuts = { 0.18, 0.36, 0.52, 0.68, 0.84 }, bias = b, tok = tok })
  -- grain streaks and a specular edge
  for y = 11, 48 do
    if X.hash(1, floor(y / 3), 7) > 0.55 then A.step(c, idx, WOOD, PX0 + 2, y, -1, tok) end
    if y % 7 == 3 then A.step(c, idx, WOOD, PX0 + 1, y, -1, tok) end
  end
  for y = 37, 44 do c:put(PX0, y, WOOD[6], tok) end
end
-- finial
do
  local m = A.ell(15.5, 8, 3, 3)
  A.shade(c, m, X.sphere(15.5, 8, 3, m), GOLD, { cuts = { 0.2, 0.38, 0.55, 0.72, 0.9 }, tok = A.tok("finial") })
  c:put(14, 7, GOLD[6])
end
-- rope lashings: 3 rows wrapping the pole, twisted strands
local function lash(y0)
  local tok = A.tok("rope")
  for y = y0, y0 + 2 do for x = PX0 - 1, PX1 + 2 do
    local t = (x + y) % 3
    local col = t == 0 and GOLD[5] or (t == 1 and GOLD[4] or GOLD[2])
    if x == PX1 + 2 or y == y0 + 2 then col = (t == 0) and GOLD[3] or GOLD[2] end
    c:put(x, y, col, tok)
  end end
end
lash(14) lash(29)

-- grass blades round the foot
A.map(c, {
  "g.....g..",
  "gG...Gg.G",
  ".gG.gG.gG",
}, 9, 47, { g = GRASS[2], G = GRASS[3] }, A.tok("grass"))

-- quirk: a loose thread unravelling from the lower swallowtail point
do
  local lo
  for y = 50, 0, -1 do if fm:has(FX1, y) then lo = y break end end
  lo = lo or 30
  local t = A.tok("thread")
  for i, p in ipairs{ { 1, 1 }, { 2, 2 }, { 2, 3 }, { 1, 4 }, { 1, 5 }, { 2, 6 } } do
    c:put(FX1 + p[1] - 1, lo + p[2], RED[3], t)
  end
end

A.save(c, "ico-flag-red")
