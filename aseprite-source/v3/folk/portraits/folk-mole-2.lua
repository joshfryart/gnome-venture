-- folk-mole-2 portrait (folk F1_5) variant: 2
-- mole villager traveller: teal cap, rust scarf, backpack+bedroll, lantern
local NAME, V = "folk-mole-2", 2
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local INK = P.ink
local function R(a, b, c, d) return { hi = a, base = b, shade = c, deep = d } end
local FUR = ({ R("#8e7480", "#6b5462", "#4c3a4f", "#35283d"), R("#80849a", "#5e617a", "#44445e", "#302f46"), R("#b9aaa6", "#958589", "#6d5e6d", "#4a3e51") })[V]
local PINK = R("#ffc4c0", "#f2949a", "#c96878", "#8f4660")
local CLAW = R("#f6ead2", "#e2d1b6", "#b9a28f", "#8a7480")
local STRAW = R("#fbe39a", "#e9bf5c", "#b98a3e", "#7d5934")
local GREEN = R("#b6d68a", "#7fae5a", "#4f7f4a", "#33533f")
local STEEL = R("#dfe7ea", "#a9b6c2", "#75809a", "#4b5270")
local WOOD = R("#d39a5e", "#a56c3d", "#74472e", "#4e2f2a")
local SOIL = "#5a3b33"
local RUST = R("#ff9a6e", "#e0603f", "#a83d3e", "#6e2a3a")
local PACK = R("#c9b07a", "#a08655", "#73603f", "#4c3d2f")
local CAP = R("#6fc3c0", "#3f9298", "#2d6475", "#22435a")
local LEATH = R("#a8735a", "#7e5040", "#5a3536", "#3e2530")
local BRASS = R("#ffe08a", "#e2a93a", "#a8702c", "#6e4a28")
local GLOW = R("#fff2b8", "#ffd96a", "#f2a93f", "#c4703a")
local LAV = R("#d9b8ef", "#b18ad6", "#7f62ac", "#563f80")
local CRM = R("#fff1d6", "#f2dfbd", "#d0b9a0", "#9c8590")
local COP = R("#ffb98a", "#e07e4c", "#a8523e", "#6f3437")
local SOUP = R("#ffd98a", "#f2a83e", "#c9742f", "#8a4a2e")
local BG = ({ R("#cfe6a6", "#a9cf7e", "#84ad62", "#5f8a4f"), R("#ffc4a0", "#f0a07a", "#d07a5e", "#a65a4e"), R("#e6d2f4", "#c9aee6", "#a68bc9", "#7f68a8") })[V]
local function on(c, m, from, to) local l = {} m:each(function(x, y) if c:get(x, y) == from then l[#l + 1] = { x, y } end end) for _, q in ipairs(l) do c:put(q[1], q[2], to) end end
local function pp(c, list, hex) for _, q in ipairs(list) do c:put(q[1], q[2], hex) end end
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
if V == 2 then
  c:part(c:rrect(50, 52, 76, 99, 5), PACK, { band = 2, nopop = true })
  c:part(c:ellipse(64, 50, 11, 5), CAP, { band = 2, nopop = true })
  for _, x in ipairs{ 57, 64, 71 } do for y = 45, 55 do if c:get(x, y) then c:put(x, y, RUST.base) end end end
  pp(c, { { 56, 47 }, { 57, 46 }, { 58, 46 } }, CAP.hi)
end
local body = c:ellipse(39.5, 102, 33, 36):clip(c:rect(0, 0, 79, 99))
c:part(body, FUR, { band = 3, nopop = true })
if V == 1 then
  local ov = body:copy():clip(c:rect(0, 90, 79, 99))
  ov:add(c:rrect(27, 76, 52, 99, 2))
  ov:add(c:line({ { 29, 77 }, { 22, 68 } }, 3)) ov:add(c:line({ { 50, 77 }, { 57, 68 } }, 3))
  c:part(ov, GREEN, { band = 2, nopop = true })
  c:part(c:rrect(34, 82, 45, 90, 1), GREEN, { band = 1, nopop = true })
  for x = 35, 44, 2 do c:put(x, 83, GREEN.hi) end
  for _, q in ipairs{ { 28, 77 }, { 49, 77 } } do c:part(c:rect(q[1], q[2], q[1] + 2, q[2] + 2), STRAW, { band = 1, nopop = true }) c:put(q[1], q[2], STRAW.hi) end
elseif V == 2 then
  c:part(c:line({ { 57, 74 }, { 59, 99 } }, 3), LEATH, { band = 1, nopop = true })
  c:part(c:rect(57, 84, 61, 87), BRASS, { band = 1, nopop = true })
  c:part(c:rrect(16, 64, 63, 73, 4), RUST, { band = 2, nopop = true })
  for x = 18, 61, 3 do for y = 70, 72 do if c:get(x, y) == RUST.base then c:put(x, y, RUST.shade) end end end
else
  c:part(body:copy(), LAV, { band = 3, nopop = true })
  local ap = c:rrect(24, 78, 55, 99, 3)
  ap:add(c:line({ { 27, 79 }, { 31, 69 } }, 2)) ap:add(c:line({ { 52, 79 }, { 48, 69 } }, 2))
  c:part(ap, CRM, { band = 2, nopop = true })
  c:part(c:rrect(33, 86, 46, 95, 1), CRM, { band = 1, nopop = true })
  for x = 33, 46 do c:put(x, 87, LAV.base) end
  local col = c:ellipse(39.5, 69, 15, 2.5)
  c:part(col, LAV, { band = 1, nopop = true })
end
local head = c:ellipse(39.5, 50, 21, 17.5)
c:part(head, FUR, { band = 3, nopop = true })
c:fillMask(c:ellipse(33, 38, 10, 3.5):clip(head), FUR.hi)
for y = 40, 66, 3 do for x = 21 + (y % 2) * 3, 58, 6 do
  if c:get(x, y) == FUR.base then c:put(x, y, FUR.shade) c:put(x + 1, y - 1, FUR.shade) end
end end
if V == 2 then
  local tail = c:poly{ { 20, 70 }, { 30, 70 }, { 28, 89 }, { 18, 88 } }
  c:part(tail, RUST, { band = 1, nopop = true })
  for x = 18, 29, 2 do c:put(x, 88, RUST.deep) end
  for y = 74, 86, 4 do for x = 20, 28 do if tail:has(x, y) then c:put(x, y, RUST.shade) end end end
end
-- props behind paws
if V == 1 then
  c:part(c:rect(55, 92, 59, 99), WOOD, { band = 1, nopop = true })
  c:part(c:rect(55, 79, 59, 83), STEEL, { band = 1, nopop = true })
  local bl = c:poly{ { 52, 79 }, { 62, 79 }, { 61, 70 }, { 57, 63 }, { 53, 70 } }
  c:part(bl, STEEL, { band = 2, nopop = true })
  for y = 66, 78 do c:put(57, y, STEEL.hi) end
  pp(c, { { 56, 64 }, { 57, 64 }, { 58, 65 }, { 56, 65 }, { 55, 67 } }, SOIL)
elseif V == 2 then
  c:fillMask(c:line({ { 16, 66 }, { 21, 61 }, { 26, 66 } }, 1), BRASS.deep)
  c:part(c:poly{ { 15, 68 }, { 27, 68 }, { 25, 65 }, { 17, 65 } }, BRASS, { band = 1, nopop = true })
  c:part(c:rect(16, 69, 26, 80), GLOW, { band = 2, nopop = true })
  for y = 69, 80 do c:put(21, y, BRASS.shade) end
  c:part(c:ellipse(21, 75, 1.5, 2.5), RUST, { band = 0, nopop = true })
  pp(c, { { 21, 74 }, { 21, 75 } }, GLOW.hi)
  pp(c, { { 17, 70 }, { 17, 71 }, { 18, 70 } }, GLOW.hi)
  c:part(c:rect(15, 81, 27, 84), BRASS, { band = 1, nopop = true })
else
  c:part(c:line({ { 57, 92 }, { 60, 76 }, { 62, 66 } }, 3), COP, { band = 1, nopop = true })
  c:part(c:ellipse(63, 62, 6, 4.5), COP, { band = 2, nopop = true })
  c:part(c:ellipse(63, 61, 4, 2.5), SOUP, { band = 1, nopop = true })
  pp(c, { { 61, 60 }, { 62, 59 } }, SOUP.hi)
  pp(c, { { 64, 61 }, { 65, 61 } }, GREEN.base)
end
for _, cx in ipairs{ 22, 57 } do
  local pw = c:ellipse(cx, 88, 7, 5.5)
  c:part(pw, PINK, { band = 2, nopop = true })
  for _, dx in ipairs{ -4, 0, 4 } do c:part(c:ellipse(cx + dx, 82, 1, 2), CLAW, { band = 1, nopop = true }) end
  pp(c, { { cx - 4, 86 }, { cx - 3, 85 } }, PINK.hi)
  pp(c, { { cx - 2, 90 }, { cx + 2, 90 }, { cx, 91 } }, PINK.shade)
end
-- face
local sn = c:ellipse(39.5, 59, 6, 4.5) sn:add(c:rrect(36, 50, 43, 57, 2))
c:part(sn, PINK, { band = 2, nopop = true })
for y = 51, 55 do c:put(37, y, PINK.hi) end
pp(c, { { 35, 57 }, { 36, 57 } }, PINK.hi)
pp(c, { { 36, 59 }, { 37, 59 }, { 36, 60 }, { 37, 60 }, { 42, 59 }, { 43, 59 }, { 42, 60 }, { 43, 60 } }, PINK.deep)
pp(c, { { 36, 64 }, { 37, 65 }, { 38, 65 }, { 39, 64 }, { 40, 64 }, { 41, 65 }, { 42, 65 }, { 43, 64 } }, INK)
c:fillMask(c:rect(23, 56, 25, 57), PINK.base) c:fillMask(c:rect(54, 56, 56, 57), PINK.base)
for _, l in ipairs{ { { 32, 58 }, { 27, 57 } }, { { 32, 60 }, { 27, 61 } }, { { 47, 58 }, { 52, 57 } }, { { 47, 60 }, { 52, 61 } } } do c:fillMask(c:line(l, 1), FUR.hi) end
c:eyeLocked(28, 46) c:eyeLocked(47, 46)
pp(c, { { 28, 44 }, { 29, 43 }, { 30, 43 }, { 31, 44 }, { 48, 44 }, { 49, 43 }, { 50, 43 }, { 51, 44 } }, FUR.hi)
-- headwear
if V == 1 then
  local brim = c:ellipse(39.5, 36, 27, 6)
  c:part(brim, STRAW, { band = 2, nopop = true })
  brim:each(function(x, y) if (x * 2 + y) % 5 == 0 and c:get(x, y) == STRAW.base then c:put(x, y, STRAW.shade) end end)
  local cr = c:rrect(26, 20, 53, 36, 6)
  c:part(cr, STRAW, { band = 2, nopop = true })
  cr:each(function(x, y) if (x + y * 2) % 6 == 0 and c:get(x, y) == STRAW.base then c:put(x, y, STRAW.shade) end end)
  c:part(c:rect(26, 31, 53, 34):clip(cr), GREEN, { band = 1, nopop = true })
  pp(c, { { 30, 23 }, { 31, 22 }, { 32, 22 }, { 18, 33 }, { 19, 33 }, { 20, 32 } }, STRAW.hi)
elseif V == 2 then
  c:part(c:ellipse(38.5, 36, 21, 9):clip(c:rect(0, 0, 79, 38)), CAP, { band = 2, nopop = true })
  for y = 28, 37 do c:put(39, y, CAP.shade) end
  c:part(c:ellipse(39.5, 39, 18, 3.5), CAP, { band = 1, nopop = true })
  for x = 23, 56 do if c:get(x, 41) == CAP.base or c:get(x, 41) == CAP.shade then c:put(x, 41, CAP.deep) end end
  c:part(c:ellipse(39, 27, 2.5, 1.5), RUST, { band = 1, nopop = true })
  pp(c, { { 25, 32 }, { 26, 31 }, { 27, 30 }, { 28, 30 } }, CAP.hi)
else
  local pf = c:ellipse(28, 24, 8, 7) pf:add(c:ellipse(39.5, 19, 10, 9)) pf:add(c:ellipse(51, 24, 8, 7))
  pf:add(c:rect(22, 24, 57, 32))
  c:part(pf, CRM, { band = 2, nopop = true })
  for _, x in ipairs{ 29, 35, 44, 50 } do for y = 20, 31 do if pf:has(x, y) and y % 4 ~= 0 then c:put(x, y, CRM.shade) end end end
  c:part(c:rrect(22, 31, 57, 38, 2), CRM, { band = 1, nopop = true })
  for x = 23, 56 do c:put(x, 34, LAV.base) c:put(x, 35, LAV.shade) end
  pp(c, { { 34, 13 }, { 35, 12 }, { 36, 12 }, { 23, 21 }, { 23, 22 } }, CRM.hi)
end
c:finish{ outline = true }
local disc = HP.ellipse(39.5, 44.5, 31, 31)
disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and BG.base or BG.shade, "bg") end end)
local ring = disc:grow(1):cut(disc)
ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, BG.deep, "bg") end end)
HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " ok")
