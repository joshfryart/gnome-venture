-- kitchen-2 (final, Opus single pass). Second kitchen tier: the plank cottage grows wider and gains a domed clay
-- bread oven on a stone plinth (glowing arched mouth with embers), a brick chimney with stone cap, a front window
-- with a flower box, and a small shuttered window on the shaded side wall.
-- Material: sphere-lit clay dome with firing cracks and soot over the mouth, staggered bricks with mortar, plank
-- grain, tile courses, glass rim + pale core, AO where oven meets wall and chimney meets roof.
-- quirk: a lattice pie cools on top of the oven, one steam curl rising.
local NAME = "kitchen-2"
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$") .. "/../_helpers/_aC14_2.lua")
local X, K, HP = A.X, A.K, A.HP
local c = A.new(NAME)
local T = A.TRIM
local CLAY = { "#5a2a22", "#8a4430", "#b4643c", "#d48a52", "#ecb070", "#fad59a" }
local PET = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }
local LEAF = { "#24544a", "#3f9150", "#7cc35a" }

local H = A.house(c, { x0 = 21, x1 = 39, yt = 37, yb = 55, ya = 24, d = 10, ov = 2, found = 3 })
-- door + step
A.door(c, 23, 28, 42, 54)
for x = 22, 29 do c:px(x, 55, A.STONE[x < 24 and 5 or (x > 27 and 3 or 4)]) end
-- front window + flower box
A.window(c, 31, 40, 7, 7, { sill = false })
for x = 30, 38 do
  c:px(x, 47, T[x == 30 and 6 or (x == 38 and 3 or 5)])
  c:px(x, 48, T[x == 30 and 4 or (x == 38 and 2 or 3)])
  c:px(x, 49, A.WALL[2])
end
for _, f in ipairs{ {31, 0}, {33, 1}, {35, 0}, {37, 1} } do
  local x = f[1]
  c:px(x, 46, f[2] == 0 and PET[3] or PET[2]) c:px(x + 1, 46, LEAF[2])
  if f[2] == 0 then c:px(x, 45, PET[4]) end
end
-- small shuttered side window (follows the wall skew)
for i = 3, 6 do
  local x = 40 + i local s = math.floor((i + 1) / 2)
  for y = 41 - s, 46 - s do
    local top, bot = (y == 41 - s), (y == 46 - s)
    local col
    if i == 3 or i == 6 or top or bot then col = T[(i == 3 or top) and 3 or 2]
    else col = A.GLASS[(y - (41 - s) < 3) and 4 or 3] end
    c:px(x, y, col)
  end
end
for y = 38, 43 do c:px(40 + 2, y - 1, T[4]) end                      -- open shutter on the near side

-- brick chimney through the roof
local cb = H.roofTop(42) + 2
A.chimney(c, 41, 43, 13, cb)
A.puff(c, 45.5, 9, 1.6)
A.puff(c, 48.5, 7, 1.0)

-- bread oven: stone plinth + clay dome against the left wall
local plinth = c:rect(9, 52, 21, 55)
A.stones(c, plinth, 9, 52, 0, 0, 8)
for x = 9, 21 do c:px(x, 52, A.STONE[x < 12 and 6 or 5]) end
local dome = c:ellipse(15, 51, 6, 7.5):clip(c:rect(0, 0, 63, 51))
local n = X.sphere(14.2, 49.2, 7.6, dome)
local bias = {}
dome:each(function(x, y) if x >= 20 then bias[K(x, y)] = -1 end end)
X.tone(c, dome, X.light(n, { amb = 0.1, wrap = 0.3 }), CLAY, { cuts = { 0.18, 0.34, 0.5, 0.66, 0.82 }, bias = bias, tok = { r = { name = "oven" } } })
-- firing cracks + a cool bounce on the shade side
for _, p in ipairs{ {11, 46}, {12, 47}, {12, 48}, {18, 45}, {19, 46} } do c:px(p[1], p[2], CLAY[2]) end
for _, p in ipairs{ {20, 48}, {20, 49}, {21, 50} } do c:px(p[1], p[2], "#8f6a7a") end
-- arched mouth: soot halo, glowing interior, embers
local mouth = c:rrect(13, 47, 17, 52, 2)
c:ellipse(15, 46.5, 2.5, 1.2):each(function(x, y) if dome:has(x, y) then c:px(x, y, CLAY[2]) end end)
mouth:each(function(x, y)
  local i = 4
  if y == 47 or x == 13 then i = 2 elseif y <= 49 then i = 3 end
  if y >= 51 then i = 5 end
  c:px(x, y, A.GLASS[i])
end)
c:px(15, 51, A.GLASS[6]) c:px(16, 50, A.CREAM) c:px(14, 51, "#e8493b")
for x = 13, 17 do c:px(x, 52, A.STONE[3]) end
-- AO where the dome meets the wall
for y = 45, 51 do if not dome:has(21, y) then c:px(21, y, A.WALL[2]) end end
-- glint on the dome
c:px(12, 45, CLAY[6]) c:px(13, 44, CLAY[6])

-- quirk: lattice pie cooling on top of the oven + steam curl
for x = 12, 18 do c:px(x, 43, A.METAL[x < 14 and 4 or (x > 16 and 2 or 3)]) end         -- tin rim
for x = 13, 17 do c:px(x, 42, ((x % 2 == 0) and "#f5b82e" or "#d98322")) end             -- lattice
for x = 14, 16 do c:px(x, 41, ((x % 2 == 1) and "#ffe38a" or "#d98322")) end
c:px(14, 42, "#9e2a3a") c:px(16, 42, "#9e2a3a")                                         -- cherry filling peeks
c:px(15, 40, "#fff4d6") c:px(16, 39, "#f0ecf0") c:px(16, 38, "#d6d2de") c:px(15, 37, "#f0ecf0")

A.save2(c, NAME)
