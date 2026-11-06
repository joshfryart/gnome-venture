-- here-town-maizehollow.lua : Maizehollow gate view (Central America & Mexico region), 480x270 native.
-- Hero-scale gate view: adobe gate frame, papel-picado bunting, tin lanterns, VP (240,112).
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local OUT = app.params.out or (DIR .. "/")
local NAME = "here-town-maizehollow"
local W, H = 480, 270
local VX, VY = 240, 112
local floor, max, min, abs = math.floor, math.max, math.min, math.abs
local c = HP.canvas{ w = W, h = H, scale = 1, name = NAME }

local function hh(x, y, s) local n = math.sin(x * 12.9898 + y * 78.233 + (s or 0) * 37.719) * 43758.5453 return n - floor(n) end
local function P(x, y, col) x = floor(x) y = floor(y) if x >= 0 and y >= 0 and x < W and y < H then c:put(x, y, col) end end
local function R(x0, y0, x1, y1, col) for y = y0, y1 do for x = x0, x1 do P(x, y, col) end end end
local function fill(m, col) c:fillMask(m, col) end
local function poly(p) return c:poly(p) end

-- ramps
local TERRA = { hi = "#f59a6a", base = "#d9653f", shade = "#a8463a", deep = "#64283a" }
local LIB   = { hi = "#9db8f4", base = "#5f84dc", shade = "#4859a8", deep = "#2b2d66" }
local TEA   = { hi = "#ffe39a", base = "#f6b942", shade = "#cf8346", deep = "#7c3f30" }
local SHOP  = { hi = "#ffb9a8", base = "#f27d72", shade = "#c4546e", deep = "#74294a" }
local MINT  = { hi = "#c8f2d2", base = "#7fd6a8", shade = "#4ea08e", deep = "#2a5a5a" }
local LILAC = { hi = "#e6cdf6", base = "#c09ae6", shade = "#8a6cc0", deep = "#4a3a78" }
local PEACH = { hi = "#ffe2c4", base = "#f7c49a", shade = "#d3907e", deep = "#7a4a4a" }
local CREAM = { hi = "#fff4d6", base = "#f4dca6", shade = "#c9a58e", deep = "#6e4f4e" }
local TURQ  = { hi = "#a8f0e6", base = "#36c2c0", shade = "#2a8a9e", deep = "#1f4a66" }
local WOOD  = { hi = "#e8b982", base = "#b97a4a", shade = "#864c33", deep = "#51302b" }
local MOSS  = { hi = "#c4e07a", base = "#7cc35a", shade = "#3f9150", deep = "#24544a" }
local GOLD  = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }
local PINK  = { hi = "#ffc4d8", base = "#f5809f", shade = "#c94f84", deep = "#7d2c5e" }
local GATE  = { hi = "#fbe8c4", base = "#ecc890", shade = "#c39278", deep = "#6a4448" }
local SILV  = { hi = "#eef0f6", base = "#c4c8d8", shade = "#8e92ac", deep = "#4c4e6a" }
local CACAO = { hi = "#c08a62", base = "#8a5236", shade = "#62362a", deep = "#3a2020" }
local GLASS, GLASS2, GLINT = "#3b3361", "#56578f", "#ffd98a"
local G_BASE, G_LT, G_SH, G_LINE, G_SHAD, G_SHAD2 = "#e9c48e", "#f3d6a4", "#d8ad80", "#c49272", "#b08a82", "#94707a"

local function bbox(m) return m:bbox() end

-- textured stucco wall, lit upper-left, shade lower-right, own dark edge
local function wall(m, Rm, seed, shadeAt)
  local x0, y0, x1, y1 = bbox(m)
  local w, h = max(1, x1 - x0), max(1, y1 - y0)
  shadeAt = shadeAt or 0.92
  m:each(function(x, y)
    local t = (x - x0) / w * 0.8 + (y - y0) / h * 0.35
    local col = Rm.base
    if t > shadeAt then col = Rm.shade end
    local blot = hh(floor(x / 6), floor(y / 5), seed + 3)
    local r = hh(x, y, seed)
    if blot < 0.18 and r < 0.5 and col == Rm.base then col = Rm.hi end
    if r < 0.05 then col = (col == Rm.shade) and Rm.base or Rm.hi
    elseif r > 0.955 then col = (col == Rm.shade) and Rm.deep or Rm.shade end
    P(x, y, col)
  end)
  for x = x0, x1 do if m:has(x, y0 + 1) and (x - x0) / w < 0.7 then P(x, y0 + 1, Rm.hi) end end
  c:edgeIn(m, Rm.deep)
end
-- receding side wall (in shade, cool violet)
local function side(m, Rm, seed)
  m:each(function(x, y)
    local r = hh(x, y, seed)
    local col = Rm.shade
    if r < 0.07 then col = Rm.base elseif r > 0.93 then col = Rm.deep end
    P(x, y, col)
  end)
  c:edgeIn(m, Rm.deep)
end
-- terracotta tile roof
local function tiles(m, Rm, seed)
  Rm = Rm or TERRA
  local x0, y0, x1, y1 = bbox(m)
  m:each(function(x, y)
    local ry, row = (y - y0) % 4, floor((y - y0) / 4)
    local col = Rm.base
    if ry == 3 then col = Rm.deep
    elseif (x + row * 3) % 6 == 0 then col = Rm.shade
    elseif ry == 0 then col = Rm.hi end
    if x > x0 + (x1 - x0) * 0.78 and col ~= Rm.deep then col = (col == Rm.hi) and Rm.base or Rm.shade end
    if hh(x, y, seed) > 0.97 then col = Rm.shade end
    P(x, y, col)
  end)
  c:edgeIn(m, Rm.deep)
end
local function edgeBox(x0, y0, x1, y1, col)
  for x = x0, x1 do P(x, y0, col) P(x, y1, col) end
  for y = y0, y1 do P(x0, y, col) P(x1, y, col) end
end
-- arched/flat window with shutters
local function window(x0, y0, x1, y1, shut, trim, arch)
  local fr = arch and c:rrect(x0 - 1, y0 - 1, x1 + 1, y1 + 1, 4) or c:rect(x0 - 1, y0 - 1, x1 + 1, y1 + 1)
  fill(fr, trim.hi)
  local gl = arch and c:rrect(x0, y0, x1, y1, 3) or c:rect(x0, y0, x1, y1)
  fill(gl, GLASS)
  gl:each(function(x, y) if (x - x0) + (y - y0) < 4 and (x - x0) + (y - y0) > 1 then P(x, y, GLASS2) end end)
  for y = y0 + 2, y1 do P(floor((x0 + x1) / 2), y, trim.base) end
  P(x1 - 1, y0 + 3, GLINT)
  c:edgeIn(fr, trim.deep)
  R(x0 - 2, y1 + 2, x1 + 2, y1 + 3, trim.base) for x = x0 - 2, x1 + 2 do P(x, y1 + 4, trim.deep) end
  if shut then
    local sw = max(3, floor((x1 - x0) / 2))
    for _, sx in ipairs({ x0 - 2 - sw, x1 + 2 }) do
      local m = c:rect(sx, y0, sx + sw - 1, y1)
      fill(m, shut.base)
      for y = y0 + 2, y1 - 1, 3 do for x = sx + 1, sx + sw - 2 do P(x, y, shut.shade) end end
      for y = y0 + 1, y1 - 1 do P(sx + 1, y, shut.hi) end
      c:edgeIn(m, shut.deep)
    end
  end
end
local function door(x0, y0, x1, y1, Rm, arch)
  local m = arch and c:rrect(x0, y0, x1, y1, floor((x1 - x0) / 2)) or c:rect(x0, y0, x1, y1)
  fill(m, Rm.base)
  m:each(function(x, y)
    if (x - x0) % 4 == 3 then P(x, y, Rm.shade) end
    if x == x0 + 1 then P(x, y, Rm.hi) end
    if x > x0 + (x1 - x0) * 0.7 and (x - x0) % 4 ~= 3 and hh(x, y, 9) < 0.5 then P(x, y, Rm.shade) end
  end)
  c:edgeIn(m, Rm.deep)
  P(x1 - 3, floor((y0 + y1) / 2) + 3, GOLD.hi) P(x1 - 3, floor((y0 + y1) / 2) + 4, GOLD.deep)
end
-- cast shadow lower-right on the ground
local function shadow(x0, x1, y, d)
  d = d or 6
  local m = poly{ { x0 + 2, y }, { x1, y }, { x1 + d + 3, y + d }, { x0 + d, y + d } }
  m:each(function(x, yy) P(x, yy, (yy - y) < 2 and G_SHAD2 or G_SHAD) end)
end
local function tileBand(x0, x1, y0, Rm1, Rm2)
  for x = x0, x1 do for y = y0, y0 + 3 do
    local q = floor((x - x0) / 4) % 2
    local Rm = q == 0 and Rm1 or Rm2
    local lx, ly = (x - x0) % 4, y - y0
    local col = Rm.base
    if (lx == 1 or lx == 2) and (ly == 1 or ly == 2) then col = Rm.hi end
    if ly == 3 then col = Rm.deep end
    P(x, y, col)
  end end
end

-- ===================== SKY =====================
c:stripes(0, 111, { "#2aaec4", "#36bccb", "#46c8d0", "#5ed2d2", "#7edcd2", "#a6e6cc", "#d4ecb8", "#f6e2a2" },
  { 3, 3, 3, 3, 2, 2, 1.5, 1.2 })
c:cloud(28, 58, 54, "#fff4e2", "#f6c8a4")
c:cloud(118, 44, 40, "#fff4e2", "#f6c8a4")
c:cloud(292, 52, 46, "#fff4e2", "#f6c8a4")
c:cloud(372, 40, 62, "#fff4e2", "#f6c8a4")
c:cloud(196, 70, 30, "#fdeedc", "#f6c8a4")
-- far violet mountains + a soft volcano
c:terrain(function(x) return 86 - 10 * math.sin(x / 37) - 6 * math.sin(x / 13 + 1) end, "#9a9ccc", 111)
c:terrain(function(x)
  local d = abs(x - 352) return d < 14 and 58 + d * 0.25 or 58 + 3.5 + (d - 14) * 0.62 end, "#8a88c0", 111, 290, 420)
for x = 340, 364 do P(x, 58 + floor(abs(x - 352) * 0.25), "#e8e2f4") P(x, 59 + floor(abs(x - 352) * 0.25), "#b8b4dc") end
for x = 0, W - 1 do for y = 60, 100 do
  local cc = c:get(x, y)
  if cc == "#8a88c0" and x < 352 and hh(x, y, 2) < 0.2 then P(x, y, "#a8a6d6") end
end end
-- cornfield hills behind the town
local function hill1(x) return 94 - 6 * math.sin(x / 41 + 0.7) end
local function hill2(x) return 101 - 4 * math.sin(x / 29 + 2.1) end
c:terrain(hill1, "#b8b85a", 111)
c:terrain(hill2, "#a2ac4e", 111)
for x = 0, W - 1, 3 do
  local y1 = floor(hill1(x) + .5)
  for k = 0, 2 do P(x, y1 + k, "#7f9a46") end P(x, y1 - 1, "#e8d070")
  local y2 = floor(hill2(x) + .5)
  if x % 2 == 0 then for k = 0, 3 do P(x + 1, y2 + k, "#5e8a44") end P(x + 1, y2 - 1, "#f2dc76") P(x, y2 + 1, "#8eb058") end
end
for x = 0, W - 1 do if (x + 1) % 6 == 0 then for y = 104, 111 do if hh(x, y, 5) < 0.6 then P(x, y, "#869c48") end end end end

-- ===================== GROUND =====================
for y = 112, H - 1 do for x = 0, W - 1 do
  local col = G_BASE
  local r = hh(x, y, 11)
  if r < 0.06 then col = G_LT elseif r > 0.94 then col = G_SH end
  if y < 120 then col = (r < 0.5) and "#e2c08e" or G_BASE end
  P(x, y, col)
end end
-- perspective paver rows / radials
local rows = {}
for k = 1, 16 do rows[#rows + 1] = floor(112 + 158 * (k / 16) ^ 1.7 + .5) end
for _, y in ipairs(rows) do for x = 0, W - 1 do P(x, y, G_LINE) if hh(x, y, 1) < 0.5 then P(x, y - 1, G_SH) end end end
for i = -12, 28 do
  local bx = -120 + i * 26
  for y = 113, H - 1 do
    local t = (y - VY) / (H - 1 - VY)
    local x = VX + (bx - VX) * t
    -- stagger joints between rows
    P(x, y, G_LINE)
  end
end
-- street: lighter stone pavers in a trapezoid to the VP
local street = poly{ { 228, 112 }, { 252, 112 }, { 394, 269 }, { 86, 269 } }
street:each(function(x, y)
  local col = "#f2dab0"
  local r = hh(x, y, 21)
  if r < 0.07 then col = "#fbe8c8" elseif r > 0.93 then col = "#dcbf98" end
  for _, ry in ipairs(rows) do if y == ry then col = "#c9a585" end if y == ry - 1 then col = "#fbe8c8" end end
  P(x, y, col)
end)
c:edgeIn(street, "#c49272")

-- ===================== BELL TOWER (far centre) + far houses =====================
local function farHouse(x0, x1, yt, Rm, seed, flatTop)
  local m = c:rect(x0, yt, x1, 113)
  wall(m, Rm, seed)
  for x = x0 + 3, x1 - 3, 6 do R(x, yt + 3, x + 1, yt + 4, WOOD.shade) P(x, yt + 5, Rm.deep) end
  window(x0 + 4, yt + 8, x0 + 7, yt + 13, nil, CREAM)
  if x1 - x0 > 18 then door(x1 - 10, yt + 10, x1 - 5, 113, TURQ, true) end
end
farHouse(170, 194, 90, MINT, 31)
farHouse(196, 221, 84, LILAC, 32)
farHouse(259, 286, 86, PEACH, 33)
farHouse(288, 312, 92, MINT, 34)
local tw = c:rect(224, 46, 256, 113)
wall(tw, CREAM, 40, 0.85)
-- belfry with the big bell
local bf = c:rrect(231, 52, 249, 72, 8)
fill(bf, "#5a3e5e")
c:edgeIn(bf, CREAM.deep)
local bell = poly{ { 237, 58 }, { 243, 58 }, { 245, 68 }, { 235, 68 } }
fill(bell, GOLD.base) R(236, 66, 238, 67, GOLD.hi) for y = 58, 68 do P(244, y, GOLD.shade) end
c:edgeIn(bell, GOLD.deep) R(239, 69, 240, 70, GOLD.deep) R(239, 55, 240, 57, WOOD.deep)
-- cupola: stepped tiled cap with a golden corn-cob finial
local cap = poly{ { 220, 46 }, { 260, 46 }, { 254, 38 }, { 248, 33 }, { 232, 33 }, { 226, 38 } }
tiles(cap, TERRA, 41)
R(222, 45, 258, 46, CREAM.hi) for x = 222, 258 do P(x, 47, CREAM.deep) end
local fin = c:rrect(237, 20, 243, 32, 3)
fill(fin, GOLD.base) fin:each(function(x, y) if (x + y) % 2 == 0 then P(x, y, GOLD.hi) end end)
c:edgeIn(fin, GOLD.deep)
for k = 0, 3 do P(236 - k, 30 - k, MOSS.base) P(244 + k, 30 - k, MOSS.base) P(236 - k, 31 - k, MOSS.deep) P(244 + k, 31 - k, MOSS.deep) end
-- quirk: a hundred thimble bells
local function thimble(x, y)
  P(x, y - 1, SILV.deep)
  P(x - 1, y, SILV.hi) P(x, y, SILV.base) P(x + 1, y, SILV.shade)
  P(x - 1, y + 1, SILV.base) P(x, y + 1, SILV.base) P(x + 1, y + 1, SILV.deep)
end
for r = 0, 4 do
  local y = 78 + r * 7
  for x = 226, 254 do P(x, y - 2, WOOD.deep) end
  for x = 228 + (r % 2) * 2, 253, 4 do thimble(x, y) end
end
local function bellString(ax, ay, bx, by, sag)
  local n = floor(abs(bx - ax))
  for i = 0, n do
    local t = i / n
    local x = ax + (bx - ax) * t
    local y = ay + (by - ay) * t + sag * 4 * t * (1 - t)
    P(x, y, WOOD.deep)
    if i % 5 == 2 then thimble(x, y + 2) end
  end
end
bellString(224, 50, 170, 90, 8)
bellString(224, 62, 196, 84, 5)
bellString(256, 50, 312, 92, 8)
bellString(256, 62, 286, 86, 5)

-- ===================== LIBRARY (far left) =====================
shadow(22, 106, 138, 7)
local libSide = poly{ { 88, 64 }, { 106, 70 }, { 106, 134 }, { 88, 138 } }
side(libSide, LIB, 50)
for y = 76, 132, 8 do for x = 90, 104 do if hh(x, y, 3) < 0.7 then P(x, y + floor((x - 88) * 0.1), LIB.deep) end end end
local lib = poly{ { 22, 138 }, { 22, 70 }, { 34, 70 }, { 34, 64 }, { 88, 64 }, { 88, 138 } }
wall(lib, LIB, 51)
for x = 24, 86, 7 do R(x, 78, x + 2, 79, WOOD.base) P(x, 80, WOOD.deep) P(x + 1, 80, LIB.deep) P(x + 2, 80, LIB.deep) end
tileBand(23, 87, 84, GOLD, TURQ)
window(28, 94, 40, 114, nil, CREAM, true)
window(70, 94, 82, 114, nil, CREAM, true)
-- books on the window shelves
for _, wx in ipairs({ 28, 70 }) do
  local cols = { TERRA.base, GOLD.base, MOSS.base, PINK.base, TURQ.base, LILAC.base }
  for i = 0, 5 do local x = wx + i * 2 + (i > 2 and 1 or 0) R(x, 107 - (i % 2), x, 112, cols[i + 1]) R(x + 1, 108, x + 1, 112, CREAM.deep) end
  for x = wx, wx + 12 do P(x, 113, WOOD.base) end
end
door(48, 106, 62, 138, TURQ, true)
R(46, 136, 64, 137, CREAM.base)
-- big open book sign on the parapet
local cover = poly{ { 34, 51 }, { 55, 55 }, { 76, 51 }, { 76, 64 }, { 55, 68 }, { 34, 64 } }
fill(cover, TERRA.base) c:edgeIn(cover, TERRA.deep)
local pgL = poly{ { 36, 50 }, { 55, 54 }, { 55, 65 }, { 36, 61 } }
local pgR = poly{ { 55, 54 }, { 74, 50 }, { 74, 61 }, { 55, 65 } }
fill(pgL, CREAM.hi) fill(pgR, CREAM.base)
for k = 0, 3 do
  for x = 39, 52 do P(x, 54 + k * 2 + floor((x - 36) * 4 / 19), CREAM.shade) end
  for x = 58, 71 do P(x, 54 + k * 2 + floor((74 - x) * 4 / 19), CREAM.shade) end
end
c:edgeIn(pgL, CREAM.deep) c:edgeIn(pgR, CREAM.deep)
for y = 54, 66 do P(55, y, TERRA.deep) end
R(53, 62, 54, 70, PINK.base) P(53, 71, PINK.deep) -- ribbon bookmark
-- quirk: a squash-shaped water tank on the library roof
local sq = c:rrect(92, 54, 104, 66, 5)
fill(sq, GOLD.shade) sq:each(function(x, y) if (x - 92) % 4 == 1 then P(x, y, GOLD.base) end if x > 101 then P(x, y, TERRA.shade) end end)
c:edgeIn(sq, GOLD.deep) R(97, 50, 98, 54, MOSS.shade) P(99, 50, MOSS.base) P(100, 50, MOSS.base)
R(94, 66, 95, 69, WOOD.deep) R(101, 66, 102, 69, WOOD.deep)

-- ===================== PINATA TREE + party stall =====================
shadow(124, 178, 139, 5)
local trunk = poly{ { 146, 139 }, { 156, 139 }, { 154, 112 }, { 158, 100 }, { 154, 99 }, { 150, 108 }, { 140, 100 }, { 136, 102 }, { 148, 114 } }
fill(trunk, WOOD.base) trunk:each(function(x, y) if x >= 152 then P(x, y, WOOD.shade) end if hh(x, y, 4) < 0.15 then P(x, y, WOOD.hi) end end)
c:edgeIn(trunk, WOOD.deep)
local canopy = c:rrect(118, 84, 160, 104, 8):add(c:rrect(132, 80, 176, 100, 8)):add(c:rrect(122, 92, 150, 108, 6))
canopy:each(function(x, y)
  local blob = hh(floor(x / 4), floor(y / 3), 7)
  local col = MOSS.base
  if (x - 118) / 58 + (y - 80) / 28 * 0.6 > 0.95 then col = MOSS.shade end
  if blob < 0.25 then col = (col == MOSS.base) and MOSS.hi or MOSS.base end
  if hh(x, y, 8) > 0.93 then col = MOSS.deep end
  P(x, y, col)
end)
c:edgeIn(canopy, MOSS.deep)
for _, f in ipairs({ { 126, 90 }, { 140, 86 }, { 164, 88 }, { 132, 100 }, { 170, 94 } }) do P(f[1], f[2], PINK.hi) P(f[1] + 1, f[2], PINK.base) end
-- quirk: a corn-cob pinata
for y = 104, 112 do P(130, y, WOOD.deep) end
local cob = c:rrect(125, 112, 135, 128, 4)
fill(cob, GOLD.base)
cob:each(function(x, y) if (x + y) % 3 == 0 then P(x, y, GOLD.hi) elseif (x - y) % 3 == 0 then P(x, y, GOLD.shade) end end)
c:edgeIn(cob, GOLD.deep)
local husk = poly{ { 121, 132 }, { 125, 122 }, { 130, 128 }, { 135, 122 }, { 139, 132 }, { 130, 130 } }
fill(husk, MOSS.base) husk:each(function(x, y) if x > 131 then P(x, y, MOSS.shade) end end) c:edgeIn(husk, MOSS.deep)
local fr = { PINK.base, TURQ.base, TERRA.hi, LILAC.base, GOLD.hi }
for i = 0, 8 do local x = 122 + i * 2 for y = 132, 136 + (i % 3) do P(x, y, fr[i % 5 + 1]) end end
-- swinging stick leaning on trunk
for k = 0, 16 do P(142 + floor(k * 0.25), 122 + k, WOOD.shade) P(143 + floor(k * 0.25), 122 + k, WOOD.hi) end
-- party stall
R(160, 112, 160, 139, WOOD.shade) R(176, 112, 176, 139, WOOD.shade)
local awn = poly{ { 157, 110 }, { 179, 110 }, { 178, 117 }, { 158, 117 } }
awn:each(function(x, y) P(x, y, (floor((x - 157) / 3) % 2 == 0) and PINK.base or CREAM.hi) end)
for x = 158, 178 do if x % 3 == 0 then P(x, 118, PINK.shade) end end
c:edgeIn(awn, PINK.deep)
local ctr = c:rect(158, 126, 178, 139)
wall(ctr, PINK, 60)
R(161, 122, 164, 125, TURQ.base) edgeBox(161, 122, 164, 125, TURQ.deep)
R(167, 121, 170, 125, GOLD.base) edgeBox(167, 121, 170, 125, GOLD.deep)
R(173, 123, 175, 125, LILAC.base) edgeBox(173, 123, 175, 125, LILAC.deep)
-- star icon on the counter front
local star = poly{ { 168, 128 }, { 170, 131 }, { 173, 132 }, { 170, 134 }, { 168, 137 }, { 166, 134 }, { 163, 132 }, { 166, 131 } }
fill(star, GOLD.hi) c:edgeIn(star, GOLD.shade)

-- ===================== NOTICE BOARD (mid right far) =====================
shadow(320, 358, 139, 5)
R(322, 84, 325, 139, WOOD.base) R(351, 84, 354, 139, WOOD.shade)
for y = 84, 139 do P(322, y, WOOD.deep) P(325, y, WOOD.deep) P(351, y, WOOD.deep) P(354, y, WOOD.deep) P(323, y, WOOD.hi) end
local brd = c:rect(318, 90, 358, 126)
fill(brd, WOOD.shade) brd:each(function(x, y) if (y - 90) % 5 == 0 then P(x, y, WOOD.deep) elseif hh(x, y, 70) < 0.12 then P(x, y, WOOD.base) end end)
R(320, 92, 356, 124, "#c88a5a") brd:each(function(x, y) if x > 319 and x < 357 and y > 91 and y < 125 and hh(x, y, 71) < 0.15 then P(x, y, WOOD.base) end end)
c:edgeIn(brd, WOOD.deep)
local roofB = poly{ { 314, 90 }, { 320, 80 }, { 356, 80 }, { 362, 90 } }
tiles(roofB, TERRA, 72)
local papers = { { 322, 94, 332, 106, CREAM }, { 335, 95, 344, 103, PINK }, { 346, 93, 354, 104, TURQ }, { 323, 109, 331, 121, GOLD },
  { 334, 106, 343, 120, CREAM }, { 345, 108, 354, 118, MINT } }
for i, p in ipairs(papers) do
  local m = c:rect(p[1], p[2], p[3], p[4])
  fill(m, p[5].hi)
  for y = p[2] + 3, p[4] - 2, 2 do for x = p[1] + 2, p[3] - 2 do if hh(x, y, i) < 0.75 then P(x, y, p[5].shade) end end end
  for y = p[2] + 1, p[4] do P(p[3], y, p[5].base) end
  c:edgeIn(m, p[5].deep)
  P(floor((p[1] + p[3]) / 2), p[2] + 1, TERRA.base)
end
-- quirk: three-sisters bean vine climbing the left post
for y = 86, 138 do
  local x = 322 + floor(2.5 * math.sin(y / 3)) - 1
  P(x, y, MOSS.deep)
  if y % 7 == 0 then P(x - 2, y, MOSS.base) P(x - 1, y, MOSS.base) P(x - 2, y - 1, MOSS.hi) P(x - 1, y + 1, MOSS.shade) end
  if y % 11 == 3 then P(x + 1, y, LILAC.base) P(x + 1, y + 1, LILAC.deep) end
end

-- ===================== SEED SHOP (far right) =====================
shadow(368, 464, 136, 6)
local shSide = poly{ { 384, 74 }, { 368, 79 }, { 368, 132 }, { 384, 136 } }
side(shSide, SHOP, 80)
local shop = c:rect(384, 74, 460, 136)
wall(shop, SHOP, 81)
local roofS = poly{ { 378, 75 }, { 392, 50 }, { 452, 50 }, { 466, 75 } }
tiles(roofS, TERRA, 82)
window(394, 80, 404, 92, MOSS, CREAM, false)
window(438, 80, 448, 92, MOSS, CREAM, false)
-- big seed-packet sign in the gable: packet with a sprout
local pk = c:rect(414, 54, 430, 72)
fill(pk, CREAM.hi) pk:each(function(x, y) if y > 66 then P(x, y, GOLD.base) end if x > 427 then P(x, y, CREAM.shade) end end)
for x = 414, 430, 2 do P(x, 54, CREAM.shade) end
c:edgeIn(pk, CREAM.deep)
for y = 58, 66 do P(422, y, MOSS.shade) end
R(418, 58, 421, 60, MOSS.base) P(418, 58, MOSS.hi) R(423, 57, 426, 59, MOSS.base) P(426, 57, MOSS.hi)
R(420, 67, 424, 69, WOOD.shade)
-- striped awning
local aw = poly{ { 380, 96 }, { 462, 96 }, { 466, 108 }, { 376, 108 } }
aw:each(function(x, y)
  local s = floor((x - 376) / 6) % 2 == 0
  local col = s and TURQ.base or CREAM.hi
  if y > 104 then col = s and TURQ.shade or CREAM.base end
  P(x, y, col)
end)
c:edgeIn(aw, TURQ.deep)
for x = 376, 466 do if (x - 376) % 6 < 3 then P(x, 109, (floor((x - 376) / 6) % 2 == 0) and TURQ.shade or CREAM.shade) end end
R(388, 110, 456, 117, "#7a4a5a")
-- counter + seed crates
local cnt = c:rect(386, 118, 458, 136)
fill(cnt, WOOD.base) cnt:each(function(x, y) if (y - 118) % 4 == 3 then P(x, y, WOOD.shade) elseif hh(x, y, 83) < 0.1 then P(x, y, WOOD.hi) end end)
c:edgeIn(cnt, WOOD.deep)
local seeds = { { GOLD, 389 }, { TERRA, 403 }, { CACAO, 417 }, { CREAM, 445 } }
for _, s in ipairs(seeds) do
  local x0 = s[2]
  local heap = poly{ { x0, 118 }, { x0 + 3, 113 }, { x0 + 8, 112 }, { x0 + 11, 118 } }
  heap:each(function(x, y) P(x, y, ((x + y) % 2 == 0) and s[1].hi or s[1].base) end)
  c:edgeIn(heap, s[1].deep)
  R(x0, 119, x0 + 11, 123, WOOD.shade) edgeBox(x0, 119, x0 + 11, 123, WOOD.deep)
end
-- quirk: cacao beans as coins on a balance scale
R(437, 106, 437, 117, SILV.shade) for x = 430, 444 do P(x, 110, SILV.base) end
R(429, 113, 433, 114, SILV.base) R(441, 113, 445, 114, SILV.base)
P(430, 111, SILV.deep) P(444, 111, SILV.deep) P(432, 111, SILV.deep) P(442, 111, SILV.deep)
R(430, 112, 432, 112, CACAO.base) P(431, 111, CACAO.hi) R(442, 112, 444, 112, GOLD.base)
-- giant cacao pod hanging by the door
local pod = c:rrect(372, 100, 378, 114, 3)
fill(pod, TERRA.shade) pod:each(function(x, y) if x == 374 then P(x, y, TERRA.base) end if x == 377 then P(x, y, TERRA.deep) end end)
c:edgeIn(pod, CACAO.deep) R(375, 96, 375, 99, WOOD.deep)

-- ===================== CORNFIELD GREEN (centre, hero) =====================
shadow(166, 316, 207, 5)
local bedTop = poly{ { 186, 150 }, { 294, 150 }, { 314, 200 }, { 166, 200 } }
bedTop:each(function(x, y)
  local col = MOSS.base
  local r = hh(x, y, 90)
  if (y - 150) % 7 == 0 then col = "#9a7a4a" elseif (y - 150) % 7 == 1 then col = "#b88e5a" end
  if col == MOSS.base and r < 0.2 then col = MOSS.hi elseif col == MOSS.base and r > 0.85 then col = MOSS.shade end
  P(x, y, col)
end)
c:edgeIn(bedTop, MOSS.deep)
local bedFront = c:rect(166, 201, 314, 209)
wall(bedFront, TERRA, 91, 0.75)
tileBand(168, 312, 203, TURQ, GOLD)
-- the three sisters: corn stalks with climbing beans and squash at their feet
local function corn(x, yb, h, seed)
  for y = yb - h, yb do P(x, y, MOSS.shade) P(x + 1, y, MOSS.deep) end
  for k = 1, 4 do
    local ly = yb - floor(h * k / 5)
    local dir = (k + seed) % 2 == 0 and -1 or 1
    local L = floor(h / 5) + 2
    for i = 1, L do
      local lx = x + (dir < 0 and 0 or 1) + dir * i
      local yy = ly - floor(i * 0.6) + floor(i * i / (L * 1.6))
      P(lx, yy, (i < L / 2) and MOSS.hi or MOSS.base) P(lx, yy + 1, MOSS.shade)
    end
  end
  P(x, yb - h - 1, GOLD.hi) P(x - 1, yb - h - 2, GOLD.base) P(x + 1, yb - h - 2, GOLD.base) P(x, yb - h - 3, GOLD.hi)
  P(x - 2, yb - h - 3, GOLD.shade) P(x + 2, yb - h - 3, GOLD.shade)
  if seed % 2 == 0 then local cy = yb - floor(h * 0.45) R(x + 2, cy, x + 3, cy + 4, GOLD.base) P(x + 2, cy, GOLD.hi) P(x + 3, cy + 4, GOLD.deep) P(x + 2, cy + 5, MOSS.base) end
  -- bean vine twining
  for y = yb - floor(h * 0.75), yb, 2 do
    local dx = ((y // 2) % 2 == 0) and -1 or 2
    P(x + dx, y, "#2f7a46")
    if hh(x, y, seed) < 0.12 then P(x + dx, y + 1, PINK.base) end
  end
end
local function squash(x, y, w, Rm)
  local m = c:rrect(x, y, x + w, y + floor(w * 0.6), 2)
  fill(m, Rm.base) m:each(function(xx, yy) if (xx - x) % 3 == 0 then P(xx, yy, Rm.shade) end if xx - x < 2 and yy - y < 3 then P(xx, yy, Rm.hi) end end)
  c:edgeIn(m, Rm.deep) P(x + floor(w / 2), y - 1, MOSS.deep)
end
local cornRows = { { y = 158, x0 = 196, x1 = 284, h = 22, step = 12 }, { y = 172, x0 = 186, x1 = 294, h = 28, step = 13 },
  { y = 187, x0 = 178, x1 = 302, h = 33, step = 14 } }
local si = 0
for ri, rw in ipairs(cornRows) do
  for x = rw.x0, rw.x1, rw.step do
    si = si + 1
    if not (ri == 3 and x > 226 and x < 254) then corn(x, rw.y, rw.h, si) end
  end
end
-- squash at the feet + big leaves
for i, s in ipairs({ { 182, 193, 8, GOLD }, { 204, 194, 9, TERRA }, { 262, 194, 9, GOLD }, { 288, 193, 8, TERRA }, { 214, 166, 6, GOLD }, { 270, 167, 6, TERRA } }) do
  local lf = c:rrect(s[1] - 4, s[2] - 3, s[1] + 2, s[2] + 1, 2) fill(lf, MOSS.shade) c:edgeIn(lf, MOSS.deep)
  squash(s[1], s[2], s[3], s[4])
end
-- centre: stepped stone planter with a giant golden squash (the green's heart)
local plinth = poly{ { 226, 196 }, { 254, 196 }, { 252, 188 }, { 228, 188 } }
wall(plinth, CREAM, 92)
local big = c:rrect(229, 174, 251, 189, 5)
fill(big, GOLD.base)
big:each(function(x, y) if (x - 229) % 5 == 0 then P(x, y, GOLD.shade) end if x > 246 or y > 186 then P(x, y, GOLD.shade) end end)
R(232, 177, 235, 178, GOLD.hi) P(236, 177, CREAM.hi)
c:edgeIn(big, GOLD.deep) R(239, 170, 240, 174, MOSS.deep) R(241, 170, 244, 171, MOSS.base)

-- ===================== BANDSTAND / DANCING PLAZA (mid right) =====================
shadow(322, 392, 212, 5)
local plat = poly{ { 324, 196 }, { 390, 196 }, { 392, 212 }, { 322, 212 } }
plat:each(function(x, y)
  local q = (floor((x - 322) / 6) + floor((y - 196) / 4)) % 3
  local Rm = q == 0 and PINK or (q == 1 and GOLD or TURQ)
  local col = Rm.base
  if (x - 322) % 6 == 0 or (y - 196) % 4 == 0 then col = Rm.shade end
  if y >= 205 then col = (q == 0) and CREAM.base or CREAM.shade end
  P(x, y, col)
end)
for x = 322, 392 do P(x, 205, CREAM.hi) end
c:edgeIn(plat, CREAM.deep)
for _, px in ipairs({ 328, 345, 369, 386 }) do
  R(px, 166, px + 1, 195, CREAM.hi) for y = 166, 195 do P(px + 2, y, SILV.shade) end
  for y = 166, 195, 6 do P(px, y, CREAM.deep) end
end
-- railing with scrolls
for x = 326, 388 do P(x, 190, CREAM.deep) if x % 4 == 0 then for y = 191, 195 do P(x, y, CREAM.shade) end end end
local broof = poly{ { 320, 168 }, { 394, 168 }, { 384, 158 }, { 366, 150 }, { 348, 150 }, { 330, 158 } }
broof:each(function(x, y)
  local col = TURQ.base
  if (x - 320) % 7 == 0 then col = TURQ.shade end
  if x < 345 and y < 162 then col = (col == TURQ.base) and TURQ.hi or col end
  if x > 372 then col = TURQ.shade end
  P(x, y, col)
end)
c:edgeIn(broof, TURQ.deep)
for x = 320, 394 do if (x % 4) < 2 then P(x, 169, TURQ.shade) P(x, 170, TURQ.deep) end end
R(355, 143, 358, 150, GOLD.base) P(355, 143, GOLD.hi) edgeBox(355, 143, 358, 150, GOLD.deep)
-- big drum + guitar on stage
local drum = c:rect(334, 182, 344, 195)
fill(drum, TERRA.base) drum:each(function(x, y) if (x + y) % 4 == 0 then P(x, y, GOLD.hi) end end) R(334, 182, 344, 183, CREAM.hi)
c:edgeIn(drum, TERRA.deep)
local gtr = poly{ { 372, 180 }, { 378, 180 }, { 380, 194 }, { 370, 194 } }
fill(gtr, WOOD.hi) gtr:each(function(x, y) if x > 377 then P(x, y, WOOD.base) end end)
R(374, 187, 376, 189, WOOD.deep) c:edgeIn(gtr, WOOD.deep)
for y = 168, 180 do P(375, y, WOOD.shade) end R(374, 166, 376, 168, WOOD.deep)
-- music-note icon flag on the roof edge
R(386, 140, 386, 152, WOOD.deep)
local flag = c:rect(387, 140, 396, 147) fill(flag, PINK.base) c:edgeIn(flag, PINK.deep)
R(390, 142, 390, 145, CREAM.hi) R(389, 145, 390, 146, CREAM.hi) R(391, 142, 392, 142, CREAM.hi)
-- small bunting off the bandstand roof
for i = 0, 8 do local x = 324 + i * 8 local y = 171 + (i % 2) R(x, y, x + 3, y + 3, fr[i % 5 + 1]) P(x + 1, y + 4, fr[i % 5 + 1]) end

-- ===================== WILD TRAIL (right edge) =====================
local path = poly{ { 380, 228 }, { 404, 226 }, { 440, 214 }, { 470, 206 }, { 470, 196 }, { 446, 198 }, { 412, 210 }, { 386, 214 } }
path:each(function(x, y) local r = hh(x, y, 100) P(x, y, r < 0.1 and "#c49a6e" or (r > 0.9 and "#f2d8ac" or "#ddb684")) end)
c:edgeIn(path, "#a87a5e")
-- wild greenery beyond: agaves, tall grass, marigolds
local function agave(x, yb, s)
  for k = -3, 3 do
    local L = s - abs(k) * 2
    for i = 0, L do
      local xx = x + floor(k * i * 0.5) local yy = yb - i + floor(abs(k) * i * 0.15)
      P(xx, yy, (k < 0) and "#8ccab8" or "#5a9a8e") if k == 0 then P(xx + 1, yy, "#3a6a6a") end
    end
  end
  for xx = x - 6, x + 6 do P(xx, yb + 1, "#3a6a6a") end
end
for x = 402, 464, 3 do
  local hgt = 8 + floor(hh(x, 0, 101) * 10)
  for i = 0, hgt do P(x + floor(i / 6), 198 - i, (i > hgt - 3) and GOLD.hi or MOSS.shade) end
end
agave(420, 196, 10) agave(452, 192, 12)
for _, f in ipairs({ { 406, 202 }, { 434, 196 }, { 458, 210 }, { 412, 216 }, { 446, 218 } }) do
  P(f[1], f[2], GOLD.shade) P(f[1] + 1, f[2], TERRA.hi) P(f[1], f[2] - 1, TERRA.hi) P(f[1] + 1, f[2] - 1, GOLD.hi) P(f[1], f[2] + 1, MOSS.deep)
end
-- arch: adobe posts with a leafy beam
shadow(404, 462, 226, 4)
local postL = c:rect(404, 158, 411, 226)
local postR = c:rect(452, 158, 459, 226)
wall(postL, PEACH, 102) wall(postR, PEACH, 103)
local beam = c:rrect(398, 146, 464, 162, 6)
beam:each(function(x, y)
  local col = MOSS.base
  local r = hh(floor(x / 3), floor(y / 3), 104)
  if r < 0.3 then col = MOSS.hi elseif r > 0.75 then col = MOSS.shade end
  if y > 158 then col = MOSS.shade end
  P(x, y, col)
end)
c:edgeIn(beam, MOSS.deep)
for _, f in ipairs({ { 404, 150 }, { 418, 148 }, { 432, 152 }, { 446, 149 }, { 458, 154 } }) do R(f[1], f[2], f[1] + 1, f[2] + 1, PINK.base) P(f[1], f[2], PINK.hi) end
for x = 412, 450, 6 do for y = 163, 165 + (x % 4) do P(x, y, MOSS.shade) end P(x, 166 + (x % 4), MOSS.base) end
-- signpost with arrow pointing out right
R(426, 184, 428, 226, WOOD.base) for y = 184, 226 do P(429, y, WOOD.deep) P(425, y, WOOD.deep) end
local arrow = poly{ { 416, 184 }, { 440, 184 }, { 446, 189 }, { 440, 194 }, { 416, 194 } }
fill(arrow, WOOD.hi) arrow:each(function(x, y) if y > 191 then P(x, y, WOOD.base) end end) c:edgeIn(arrow, WOOD.deep)
local lf = poly{ { 422, 189 }, { 428, 186 }, { 434, 189 }, { 428, 192 } } fill(lf, MOSS.base) c:edgeIn(lf, MOSS.deep)
for x = 423, 433 do P(x, 189, MOSS.hi) end

-- ===================== ABUELA BEE'S CAFE (near left) =====================
shadow(14, 112, 256, 8)
local cSide = poly{ { 94, 188 }, { 112, 182 }, { 112, 242 }, { 94, 256 } }
side(cSide, TEA, 110)
local cafe = c:rect(14, 186, 94, 256)
wall(cafe, TEA, 111)
local croof = poly{ { 10, 190 }, { 16, 170 }, { 96, 170 }, { 100, 190 } }
tiles(croof, TERRA, 112)
for x = 16, 92, 7 do R(x, 191, x + 2, 193, WOOD.base) P(x, 194, WOOD.deep) end
-- open counter window under a small awning
local cw = c:rrect(20, 204, 60, 236, 6)
fill(cw, "#4a3456")
cw:each(function(x, y) if y < 212 and (x + y) % 5 == 0 then P(x, y, "#5e4468") end end)
c:edgeIn(cw, TEA.deep)
for x = 22, 58, 4 do R(x, 209, x + 1, 211, GOLD.hi) end -- string lights inside
local sill = c:rect(18, 236, 62, 240) fill(sill, WOOD.base) for x = 18, 62 do P(x, 236, WOOD.hi) P(x, 240, WOOD.deep) end
-- mugs of spiced hot chocolate
for i, x in ipairs({ 24, 34, 50 }) do
  local mg = c:rect(x, 228, x + 5, 235) local Rm = (i == 2) and TURQ or PINK
  fill(mg, Rm.base) for y = 228, 235 do P(x + 5, y, Rm.shade) end P(x + 1, 229, Rm.hi) c:edgeIn(mg, Rm.deep)
  R(x + 1, 228, x + 4, 228, CACAO.shade) P(x + 6, 230, Rm.deep) P(x + 7, 231, Rm.deep) P(x + 6, 232, Rm.deep)
  P(x + 2, 225, CREAM.hi) P(x + 3, 223, CREAM.hi) P(x + 2, 221, CREAM.base)
end
-- clay chocolate pot (olla) with steam
local olla = c:rrect(40, 220, 48, 235, 3)
fill(olla, TERRA.base) olla:each(function(x, y) if x > 45 then P(x, y, TERRA.shade) end if y == 226 then P(x, y, CREAM.base) end end)
c:edgeIn(olla, TERRA.deep) R(43, 214, 44, 219, WOOD.hi) P(44, 213, WOOD.base)
-- quirk: jar of cacao beans used as coins
local jar = c:rect(54, 224, 59, 235) fill(jar, "#b8e4e4")
jar:each(function(x, y) if y > 227 and (x + y) % 2 == 0 then P(x, y, CACAO.base) elseif y > 227 then P(x, y, CACAO.hi) end end)
c:edgeIn(jar, TURQ.deep) R(54, 222, 59, 223, WOOD.shade)
door(68, 216, 86, 256, TURQ, true)
-- hanging sign: steaming mug icon
for x = 64, 92 do P(x, 197, WOOD.deep) end
R(68, 198, 68, 199, WOOD.deep) R(88, 198, 88, 199, WOOD.deep)
local sg = c:rect(64, 200, 92, 212)
fill(sg, CREAM.hi) sg:each(function(x, y) if x > 88 or y > 210 then P(x, y, CREAM.shade) end end) c:edgeIn(sg, WOOD.deep)
local smug = c:rect(72, 203, 80, 210) fill(smug, CACAO.base) for y = 203, 210 do P(80, y, CACAO.shade) end P(73, 204, CACAO.hi)
c:edgeIn(smug, CACAO.deep) R(81, 205, 83, 205, CACAO.deep) R(83, 206, 83, 207, CACAO.deep) R(81, 208, 83, 208, CACAO.deep)
-- honeycomb hex mark next to the mug (Abuela Bee)
local hex = poly{ { 85, 204 }, { 88, 203 }, { 90, 205 }, { 90, 208 }, { 88, 210 }, { 85, 208 } } fill(hex, GOLD.base) c:edgeIn(hex, GOLD.deep)
P(74, 201, CREAM.shade) P(76, 200, CREAM.shade) P(78, 201, CREAM.shade)
-- talavera tile skirting + marigold pots
tileBand(15, 93, 248, LIB, CREAM)
for _, x in ipairs({ 62, 88 }) do
  local pt = c:rect(x, 248, x + 5, 255) fill(pt, TERRA.base) c:edgeIn(pt, TERRA.deep)
  R(x, 244, x + 5, 247, MOSS.shade) P(x + 1, 244, GOLD.base) P(x + 3, 243, TERRA.hi) P(x + 4, 245, GOLD.hi)
end

-- ===================== GATE FRAME (adobe, talavera, viga beam) =====================
local function pillar(x0, x1)
  local m = c:rect(x0, 0, x1, H - 1)
  wall(m, GATE, 120 + x0, 0.6)
  for y = 40, 250, 18 do tileBand(x0 + 3, x1 - 3, y, LIB, CREAM) end
  for y = 0, H - 1 do P(x0 + 2, y, TURQ.base) P(x1 - 2, y, TURQ.shade) end
  R(x0, 258, x1, 269, GATE.shade) for x = x0, x1 do P(x, 258, GATE.deep) end
  c:edgeIn(m, GATE.deep)
end
pillar(0, 14) pillar(465, 479)
local beamT = c:rect(0, 0, 479, 14)
fill(beamT, WOOD.base)
beamT:each(function(x, y)
  if y <= 4 then P(x, y, ((x + floor(y / 2) * 3) % 6 == 0) and TERRA.shade or (y == 0 and TERRA.hi or TERRA.base))
  elseif y >= 12 then P(x, y, WOOD.shade)
  elseif hh(x, y, 130) < 0.12 then P(x, y, WOOD.hi)
  elseif (x % 37 == 0) then P(x, y, WOOD.deep) end
end)
for x = 0, 479 do P(x, 5, TERRA.deep) P(x, 6, WOOD.hi) P(x, 14, WOOD.deep) end
for x = 24, 456, 36 do R(x, 15, x + 5, 19, WOOD.base) R(x, 15, x + 5, 15, WOOD.shade) edgeBox(x, 15, x + 5, 19, WOOD.deep) P(x + 1, 16, WOOD.hi) end
-- papel picado bunting
local function picado(ax, bx, ay, sag, step, off)
  local colsP = { PINK, GOLD, TURQ, TERRA, LILAC, MOSS }
  for x = ax, bx do
    local t = (x - ax) / (bx - ax)
    P(x, ay + sag * 4 * t * (1 - t), WOOD.deep)
  end
  local k = off
  for x = ax + 4, bx - 10, step do
    k = k + 1
    local t = (x + 5 - ax) / (bx - ax)
    local y = floor(ay + sag * 4 * t * (1 - t)) + 1
    local Rm = colsP[k % 6 + 1]
    for yy = y, y + 11 do for xx = x, x + 9 do
      local lx, ly = xx - x, yy - y
      local col = Rm.base
      if ly == 11 and lx % 2 == 1 then col = nil end
      if col and ((lx == 4 or lx == 5) and (ly >= 3 and ly <= 7) or (ly == 5 and lx >= 2 and lx <= 7) or (ly == 9 and lx % 3 == 1)) then
        col = c:get(xx, yy + 13) or Rm.hi -- cut-out holes show the sky
        col = Rm.hi
      end
      if col and (lx == 0 or lx == 9) then col = Rm.shade end
      if col then P(xx, yy, col) end
    end end
    for xx = x, x + 9 do P(xx, y, Rm.deep) end
  end
end
picado(15, 465, 19, 26, 15, 0)
picado(15, 465, 22, 48, 19, 3)
-- tin star lanterns
local function lantern(x, y0)
  for y = 20, y0 - 1 do P(x, y, SILV.deep) end
  local body = poly{ { x, y0 }, { x + 4, y0 + 5 }, { x + 9, y0 + 8 }, { x + 4, y0 + 11 }, { x, y0 + 18 }, { x - 4, y0 + 11 }, { x - 9, y0 + 8 }, { x - 4, y0 + 5 } }
  fill(body, GOLD.base)
  body:each(function(xx, yy)
    local d = abs(xx - x) + abs(yy - (y0 + 8)) * 0.8
    if d < 3 then P(xx, yy, CREAM.hi) elseif d < 5 then P(xx, yy, GOLD.hi) end
    if xx > x + 3 then P(xx, yy, GOLD.shade) end
    if (xx + yy) % 4 == 0 and d >= 5 then P(xx, yy, "#ffd36a") end
  end)
  c:edgeIn(body, GOLD.deep)
  -- warm glow speckle on what is around
  for yy = y0 - 6, y0 + 24 do for xx = x - 14, x + 14 do
    local d = abs(xx - x) + abs(yy - (y0 + 8))
    if d > 11 and d < 16 and not body:has(xx, yy) and hh(xx, yy, 140) < 0.18 then P(xx, yy, "#fff0b0") end
  end end
end
lantern(36, 24) lantern(444, 24)

-- ===================== FINISH =====================
c:finish{ outline = false }
HP.assertClean(c)
c:save{ aseprite = OUT .. NAME .. ".aseprite", png = OUT .. NAME .. ".png", scale = 1 }
print("saved " .. OUT .. NAME)
