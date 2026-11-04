-- npc-ginger-thornwhistle portrait (npc2 P1_11) species: common carder bee
-- Same design as the sprite: ginger fuzz, cowlick, cream muzzle, button nose, leaf neckerchief, frosted wings, bramble whistle-staff with pink flower. Rose disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local out = app.params.out or (DIR .. "/")
local INK, CREAM = "#2b1c26", "#fbf1d4"
local function F(c, m, r, band, pop)
  c:part(m, r, { band = band or 2, nopop = not pop, pop = pop and { x = math.floor(pop[1]), y = math.floor(pop[2]) } or nil })
  return m
end
local function under(c, m, hex)
  local l = {} m:each(function(x, y) if not m:has(x, y + 1) then l[#l + 1] = { x, y } end end)
  for _, q in ipairs(l) do c:put(q[1], q[2], hex) end
end
local function fuzz(m, list) for _, b in ipairs(list) do m:add(HP.ellipse(b[1], b[2], b[3] or 1.5, b[3] or 1.5)) end return m end
local function ring(cx, cy, rx, ry, a0, a1, st, r) local t = {} for a = a0, a1, st do local q = math.rad(a) t[#t + 1] = { cx + math.cos(q) * rx, cy + math.sin(q) * ry, r } end return t end
local function overlay(c, mask, r, from)
  local L = {}
  mask:each(function(x, y) local v = c:get(x, y)
    if v == from.base or v == from.hi then L[#L + 1] = { x, y, r.base } elseif v == from.shade then L[#L + 1] = { x, y, r.shade } elseif v == from.deep then L[#L + 1] = { x, y, r.deep } end end)
  for _, q in ipairs(L) do c:put(q[1], q[2], q[3]) end
end
local function lineOn(c, pts, hex, clipm) c:line(pts, 1):clip(clipm):each(function(x, y) c:put(x, y, hex) end) end
local NAME = "npc-ginger-thornwhistle"
local GING = { hi = "#ffd08a", base = "#f2a24a", shade = "#c4693e", deep = "#7e3f48" }
local BAND = { hi = "#c4693e", base = "#9a4e3e", shade = "#6e3646", deep = "#4a2a3e" }
local MUZ  = { hi = "#fff0c8", base = "#ffdca0", shade = "#e8b070", deep = "#c4693e" }
local LEGS = { hi = "#7a5a78", base = "#54405e", shade = "#3c2c48", deep = "#31222f" }
local WING = { hi = "#f6f0dc", base = "#d3e6ee", shade = "#a3bcd8", deep = "#7480aa" }
local WOOD = { hi = "#c99a6a", base = "#8f6045", shade = "#5e3d45", deep = "#3e2a38" }
local LEAF = { hi = "#a6d36a", base = "#5f9e48", shade = "#3a6e4c", deep = "#274a44" }
local ROSE = { hi = "#ffd6dc", base = "#f096a8", shade = "#c0607e", deep = "#80406a" }
local DISC = { base = "#f4c4cc", shade = "#e49aac", deep = "#c0708a" }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local rg = disc:grow(1):cut(disc)
  rg:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- wings
for _, s in ipairs{ -1, 1 } do
  local m = c:ellipse(39.5 + s * 27, 70, 9, 5.5) F(c, m, WING, 2, { 39.5 + s * 27 - 6, 67 })
  lineOn(c, { { 39.5 + s * 20, 72 }, { 39.5 + s * 33, 68 } }, WING.shade, m)
end
-- fuzzy shoulders with a dark band
local bm = c:ellipse(39.5, 106, 31, 27):clip(c:rect(0, 76, 79, 99))
fuzz(bm, ring(39.5, 106, 30.5, 26.5, 200, 340, 12, 2))
F(c, bm, GING, 3, { 16, 86 })
local band = HP.mask() for x = 0, 79 do for y = 91 + (x % 2), 95 do band:set(x, y) end end
overlay(c, band:clip(bm), BAND, GING)
for y = 82, 99, 3 do for x = 12 + (y % 2) * 2, 68, 5 do if bm:has(x, y) and c:get(x, y) == GING.base then c:px(x, y, GING.shade) end end end
-- leaf neckerchief
local nk = c:ellipse(39.5, 77, 16, 3.5) nk:add(c:poly{ { 34, 78 }, { 45, 78 }, { 39.5, 88 } })
F(c, nk, LEAF, 2, { 27, 75 })
lineOn(c, { { 39, 79 }, { 39, 86 } }, LEAF.shade, nk) lineOn(c, { { 39, 82 }, { 36, 80 } }, LEAF.shade, nk) lineOn(c, { { 40, 82 }, { 43, 80 } }, LEAF.shade, nk)
-- bramble whistle-staff on the left, with thorns, whistle holes, leaf and flower
local st = c:line({ { 13, 99 }, { 15, 72 }, { 12, 40 } }, 3)
for _, q in ipairs{ { 10, 90 }, { 18, 82 }, { 10, 62 }, { 16, 54 }, { 9, 47 } } do st:set(q[1], q[2]) end
F(c, st, WOOD, 1, { 12, 44 })
for _, y in ipairs{ 58, 62 } do c:px(13, y, WOOD.deep) end
F(c, c:poly{ { 13, 42 }, { 5, 36 }, { 2, 40 }, { 9, 44 } }, LEAF, 1, { 6, 38 })
local fl = HP.mask()
for i = 0, 4 do local a = math.rad(-90 + i * 72) fl:add(c:ellipse(14 + math.cos(a) * 3.5, 35 + math.sin(a) * 3.5, 2.2, 2.2)) end
F(c, fl, ROSE, 1, { 12, 31 })
F(c, c:ellipse(14, 35, 1.5, 1.5), { hi = "#ffeaa0", base = "#f5c64a", shade = "#cd8a3a", deep = "#8a563a" }, 1)
F(c, c:ellipse(15, 80, 4.5, 3.5), LEGS, 2, { 13, 78 })
-- head
local head = c:ellipse(39.5, 50, 20, 17)
fuzz(head, ring(39.5, 50, 19.5, 16.5, 170, 370, 15, 2))
head:add(c:poly{ { 35, 35 }, { 37, 27 }, { 40, 32 }, { 44, 28 }, { 44, 36 } })
F(c, head, GING, 3, { 25, 39 })
for _, s in ipairs{ { 28, 37, 29, 34 }, { 33, 35, 34, 32 }, { 46, 35, 47, 33 }, { 51, 38, 52, 36 }, { 23, 42, 24, 40 } } do
  lineOn(c, { { s[1], s[2] }, { s[3], s[4] } }, GING.hi, head)
end
F(c, c:ellipse(39.5, 57, 9.5, 6.5), MUZ, 2, { 33, 53 })
c:eyeLocked(29, 45) c:eyeLocked(46, 45)
F(c, c:ellipse(39.5, 53.5, 2.5, 2), BAND, 1, { 38, 52 })
c:paint({ "i.....i", ".iDDDi.", "..iii.." }, 36, 58, { i = "ink", D = "ember.deep" })
c:paint({ "PPP", "PPP" }, 25, 55, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 52, 55, { P = "petal.base" })
F(c, c:ellipse(28, 15, 2.5, 2.5), BAND, 1, { 27, 14 })
F(c, c:ellipse(53, 16, 2.5, 2.5), BAND, 1, { 52, 15 })
c:finish{ outline = true }
c:fillMask(c:line({ { 33, 35 }, { 30, 24 }, { 28, 18 } }, 1), INK)
c:fillMask(c:line({ { 46, 35 }, { 50, 25 }, { 53, 19 } }, 1), INK)
backdrop(DISC)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
