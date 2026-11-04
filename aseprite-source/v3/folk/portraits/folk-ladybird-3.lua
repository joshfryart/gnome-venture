-- folk-ladybird-3 portrait (folk F2_1) variant: 3
-- 80x100 head-and-shoulders portrait of the generic ladybird villager (same design/colours as the sprite).
-- Spotted elytra over the shoulders, dark head with cream pronotum cheek patches, muzzle + button nose,
-- clubbed antennae; prop in frame (v1 trowel, v2 lantern, v3 ladle). Backdrop disc in the villager colour.
local HP = dofile("/home/user/gnome-venture/aseprite-source/v3/lib/hp.lua")
local P = HP.P
local V = 3
local NAME = "folk-ladybird-" .. V
local INK = "#2b1c26"
local function R(a, b, c2, d) return { hi = a, base = b, shade = c2, deep = d } end
local HEAD  = R("#6e5d84", "#4f4164", "#3d3150", "#342a44")
local MUZ   = R("#a896be", "#86749e", "#66567e", "#4f4164")
local CREAM = R("#fff3d6", "#f4e2bc", "#d6bfa0", "#a8917c")
local CREAMD = R("#f4e2bc", "#d6bfa0", "#a8917c", "#a8917c")
local STRAW = R("#fff0a0", "#f0cc6a", "#c99a48", "#8e6838")
local WOOD  = R("#d8a070", "#a86e48", "#7a4a3a", "#53322f")
local WOODD = R("#a86e48", "#7a4a3a", "#53322f", "#53322f")
local METAL = R("#eef2f6", "#b8c4d0", "#7f8ca8", "#56607e")
local BRASS = R("#ffe08a", "#e0a838", "#a8702c", "#6e4628")
local GLOW  = R("#fff8c8", "#ffe070", "#f0b040", "#c07a30")
local ROLL  = R("#f0a0aa", "#c8566e", "#8e3a5a", "#5e2846")
local TEAL  = R("#8ae6d6", "#36b0a4", "#24788a", "#1d4f66")
local CAP   = R("#9ab8f4", "#5a78d0", "#3e4ea0", "#2e3470")
local CAPD  = R("#5a78d0", "#3e4ea0", "#2e3470", "#2e3470")
local SOUP  = R("#ffd27a", "#e89a40", "#b86a30", "#7a4430")
local BLUSH = "#f2a0a8"
local SHELL = ({ R("#f7735a", "#d93a30", "#a52638", "#6e1d36"),
                 R("#fff08a", "#f2cf38", "#c99a2c", "#8a5f2e"),
                 R("#ffb066", "#ec7a30", "#b8522e", "#7a3430") })[V]
local SPOT = V == 3 and CREAM or R("#5a4868", "#3a2c48", "#33263f", "#33263f")
local CLOTH = ({ R("#a6d36a", "#6aa84a", "#447a3e", "#2f5236"),
                 R("#e8c99a", "#c49a68", "#8e6a4e", "#5e4440"),
                 R("#d6b8f0", "#a87cd8", "#7656a8", "#4e3a78") })[V]
local CLOTHD = R(CLOTH.base, CLOTH.shade, CLOTH.deep, CLOTH.deep)
local function part(c, m, r, band, pop)
  c:part(m, r, { band = band or 1, nopop = pop == nil, pop = pop, inner = false })
  return m
end
local function under(c, m, hex)
  local l = {}
  m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local out = app.params.out or "/home/user/gnome-venture/aseprite-source/v3/folk/portraits/"
local DISC = ({ R("#d8eeb8", "#bfe09a", "#9cc47e", "#78a062"), R("#c8f0ea", "#a8e0d8", "#84c4c0", "#5e9ea4"),
                R("#e6d8f6", "#d2bcee", "#b49cd8", "#8e76b8") })[V]
local SPOTS = ({ { {14,84,3.5}, {65,84,3.5}, {19,95,2.5}, {60,95,2.5}, {8,93,2}, {71,93,2} },
                 { {10,82,2}, {17,79,2}, {13,90,2}, {21,88,2}, {9,97,2}, {18,97,2}, {69,82,2}, {62,79,2}, {66,90,2}, {58,88,2}, {70,97,2}, {61,97,2} },
                 { {13,86,3}, {66,86,3}, {18,96,2.5}, {61,96,2.5} } })[V]
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ {1,0},{-1,0},{0,1},{0,-1} } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
if V == 2 then -- pack + bedroll behind the left shoulder
  part(c, c:rrect(4, 70, 26, 99, 4), WOOD, 2)
  part(c, c:rrect(4, 70, 26, 78, 3), WOODD, 1)
  part(c, c:ellipse(15, 69, 11, 3.5), ROLL, 1, { x = 8, y = 67 })
  c:put(10, 68, ROLL.deep) c:put(10, 69, ROLL.deep) c:put(20, 68, ROLL.deep) c:put(20, 69, ROLL.deep)
end
local sh = c:ellipse(39.5, 101, 34, 29):clip(c:rect(0, 0, 79, 99))
part(c, sh, SHELL, 3, { x = 12, y = 84 })
for _, q in ipairs(SPOTS) do part(c, c:ellipse(q[1], q[2], q[3], q[3]):clip(sh:copy()), SPOT, 1) end
for i = 0, 4 do local x, y = 9 + i, 84 - i if sh:has(x, y) and c:get(x, y) == SHELL.base:lower() then c:put(x, y, SHELL.hi) end end
local to = c:ellipse(39.5, 101, 16, 25):clip(c:rect(0, 0, 79, 99))
if V == 1 then
  part(c, to, CREAM, 2)
  part(c, c:line({ { 31, 85 }, { 28, 74 } }, 3), CLOTH, 1) part(c, c:line({ { 48, 85 }, { 51, 74 } }, 3), CLOTH, 1)
  part(c, c:rect(30, 84, 49, 99):clip(to:copy()), CLOTH, 2)
  part(c, c:rrect(35, 89, 44, 95, 1), CLOTHD, 1)
  for x = 36, 43, 2 do c:put(x, 90, CLOTH.hi) end
  part(c, c:rect(30, 84, 32, 86), STRAW, 1, { x = 30, y = 84 }) part(c, c:rect(47, 84, 49, 86), STRAW, 1, { x = 47, y = 84 })
elseif V == 2 then
  part(c, to, CLOTH, 2)
  part(c, c:line({ { 29, 76 }, { 36, 99 } }, 3), WOOD, 1)
  part(c, c:rect(31, 86, 34, 88), BRASS, 1, { x = 31, y = 86 })
  part(c, c:ellipse(39.5, 73, 18, 5), TEAL, 2, { x = 26, y = 70 })
  local tl = c:rrect(44, 74, 50, 92, 2)
  for x = 44, 50, 2 do tl:add(c:rect(x, 93, x, 94)) end
  part(c, tl, TEAL, 1)
  for x = 44, 50 do if tl:has(x, 86) then c:put(x, 86, ROLL.base) c:put(x, 87, ROLL.shade) end end
else
  part(c, to, CLOTH, 2)
  part(c, c:line({ { 31, 81 }, { 34, 72 } }, 2), CREAM, 1) part(c, c:line({ { 48, 81 }, { 45, 72 } }, 2), CREAM, 1)
  part(c, c:rrect(28, 80, 51, 99, 3), CREAM, 2)
  part(c, c:rrect(34, 89, 45, 95, 2), CREAMD, 1)
  c:stitch{ { 35, 89 }, { 44, 89 } }
end
-- head
local hd = c:ellipse(39.5, 54, 20.5, 17.5)
part(c, hd, HEAD, 3, { x = 27, y = 43 })
part(c, c:ellipse(24, 64, 5, 3.5):clip(hd:copy()), CREAM, 1)
part(c, c:ellipse(55, 64, 5, 3.5):clip(hd:copy()), CREAM, 1)
for x = 22, 24 do c:put(x, 64, BLUSH) end for x = 55, 57 do c:put(x, 64, BLUSH) end
part(c, c:ellipse(39.5, 63, 6.5, 4.5), MUZ, 2, { x = 35, y = 60 })
for x = 38, 41 do c:put(x, 60, HEAD.deep) end c:put(39, 61, HEAD.deep) c:put(40, 61, HEAD.deep) c:put(38, 60, MUZ.hi)
c:put(35, 64, INK) c:put(44, 64, INK)
for x = 36, 43 do c:put(x, 65, INK) end
c:put(37, 66, INK) c:put(42, 66, INK) for x = 38, 41 do c:put(x, 66, "#e07890") end
c:put(38, 67, INK) c:put(39, 67, INK) c:put(40, 67, INK) c:put(41, 67, INK)
c:eyeLocked(30, 48) c:eyeLocked(45, 48)
-- hats
local AN
if V == 1 then
  local brim = c:ellipse(39.5, 42, 27, 5.5) brim:add(c:rect(67, 43, 68, 43))
  part(c, brim, STRAW, 2) under(c, brim, STRAW.deep)
  for _, y in ipairs({ 41, 44 }) do for x = 14, 65 do if x % 3 ~= 0 and brim:has(x, y) and brim:has(x, y + 1) then c:put(x, y, STRAW.shade) end end end
  local cr = c:ellipse(39.5, 33, 13, 8) cr:add(c:rect(27, 33, 52, 40))
  part(c, cr, STRAW, 2, { x = 31, y = 28 })
  for _, y in ipairs({ 29, 32 }) do for x = 29, 50 do if x % 4 ~= 1 and cr:has(x, y) then c:put(x, y, STRAW.shade) end end end
  for x = 27, 52 do c:put(x, 37, CLOTH.base) c:put(x, 38, CLOTH.base) c:put(x, 39, CLOTH.shade) end
  AN = { { 33, 30, 27, 19 }, { 46, 30, 52, 19 } }
elseif V == 2 then
  local cr = c:ellipse(39.5, 43, 21.5, 12):clip(c:rect(0, 0, 79, 44))
  part(c, cr, CAP, 3, { x = 29, y = 35 })
  c:fillMask(c:line({ { 33, 33 }, { 30, 44 } }, 1):clip(cr:copy()), CAP.shade)
  c:fillMask(c:line({ { 46, 33 }, { 49, 44 } }, 1):clip(cr:copy()), CAP.shade)
  local pk = c:ellipse(39.5, 44.5, 17, 3):clip(c:rect(0, 45, 79, 99))
  part(c, pk, CAPD, 1) under(c, pk, CAP.deep)
  part(c, c:ellipse(39.5, 31, 2.5, 1.5), BRASS, 1, { x = 38, y = 30 })
  AN = { { 34, 34, 27, 22 }, { 45, 34, 52, 22 } }
else
  local tq = c:ellipse(40.5, 25, 16, 10)
  tq:add(c:ellipse(26, 31, 7, 6)) tq:add(c:ellipse(54, 31, 7, 6))
  part(c, tq, CREAM, 3, { x = 30, y = 19 })
  for _, x in ipairs({ 32, 40, 48 }) do for y = 30, 35 do c:put(x, y, CREAM.shade) end end
  local bd = c:rrect(21, 36, 58, 45, 2)
  part(c, bd, CREAM, 2) under(c, bd, CREAM.deep)
  AN = { { 23, 42, 14, 32 }, { 56, 42, 65, 32 } }
end
for _, a in ipairs(AN) do part(c, c:ellipse(a[3], a[4], 2, 2), HEAD, 1, { x = a[3] - 1, y = a[4] - 1 }) end
-- props
if V == 1 then
  part(c, c:line({ { 26, 93 }, { 14, 88 } }, 5), CREAM, 1)
  part(c, c:rrect(10, 75, 14, 87, 1), WOOD, 1, { x = 10, y = 76 })
  part(c, c:rect(11, 72, 13, 74), METAL, 1)
  local bl = c:poly{ { 6, 72 }, { 18, 72 }, { 12, 56 } }
  part(c, bl, METAL, 2, { x = 9, y = 66 })
  c:fillMask(c:line({ { 12, 60 }, { 12, 70 } }, 1):clip(bl:copy()), METAL.hi)
  c:put(13, 63, WOOD.shade) c:put(14, 64, WOOD.base) c:put(11, 67, WOOD.shade)
  part(c, c:ellipse(12, 86, 4, 3.5), HEAD, 1, { x = 10, y = 84 })
elseif V == 2 then
  part(c, c:line({ { 54, 95 }, { 63, 87 } }, 5), CLOTH, 1)
  part(c, c:rect(64, 86, 66, 87), BRASS, 1)
  part(c, c:rrect(60, 88, 70, 90, 1), BRASS, 1, { x = 61, y = 88 })
  part(c, c:rect(61, 91, 69, 97), GLOW, 1, { x = 62, y = 92 })
  for y = 91, 97 do c:put(65, y, BRASS.shade) end
  part(c, c:rect(60, 98, 70, 99), BRASS, 1)
  part(c, c:ellipse(65, 84, 3.5, 3), HEAD, 1, { x = 63, y = 82 })
else
  part(c, c:line({ { 54, 95 }, { 62, 89 } }, 5), CLOTH, 1)
  part(c, c:line({ { 63, 88 }, { 66, 63 } }, 2), METAL, 1)
  local bw = c:ellipse(67, 59, 6, 4)
  bw:add(c:rect(70, 63, 70, 65))
  part(c, bw, METAL, 2, { x = 63, y = 57 }) under(c, bw, METAL.deep)
  part(c, c:ellipse(67, 58, 4, 1.8), SOUP, 1, { x = 65, y = 57 })
  c:put(70, 64, SOUP.base) c:put(70, 65, SOUP.shade)
  part(c, c:ellipse(63, 88, 3.5, 3), HEAD, 1, { x = 61, y = 86 })
end
c:finish{ outline = true }
for _, a in ipairs(AN) do
  c:fillMask(c:line({ { a[1], a[2] }, { a[3] + (a[1] > a[3] and 2 or -2), a[4] + 2 } }, 1), INK)
end
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
print(NAME .. " portrait ok")
