-- npc-tobias-trundle portrait (npc2 P1_36) species: tortoise
-- Same design as the sprite: green head with crown scales, heavy lids, hooked beak, grey whisker moustache,
-- mustard knit scarf, cream plastron, brown shell rising behind the shoulders; hooked cane in frame. 80x100.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-tobias-trundle"
local SKIN  = { hi = "#c4e07a", base = "#8fbf5c", shade = "#4f8a5a", deep = "#2c4d4c" }
local SNOUT = { hi = "#e6f2a8", base = "#c4e07a", shade = "#8fbf5c", deep = "#4f8a5a" }
local SHELL = { hi = "#d9a066", base = "#a86a3e", shade = "#74463a", deep = "#46293a" }
local PLAS  = { hi = "#fff0b8", base = "#ecc87a", shade = "#c0915c", deep = "#7a5040" }
local WHISK = { hi = P.cream, base = P.stone.hi, shade = P.stone.base, deep = P.stone.shade }
local SCARF, CANE = P.gold, P.wood
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function keep(x, y, hex) if x >= 0 and y >= 0 and x < c.w and y < c.h then local o = c.own[y * c.w + x] if o then c:put(x, y, hex, o) end end end
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then
    local dk = false
    for _, d in ipairs{ { 1, 0 }, { -1, 0 }, { 0, 1 }, { 0, -1 } } do if c:get(x + d[1], y + d[2]) == r.shade then dk = true end end
    c:put(x, y, dk and r.deep or r.shade, "bg") end end)
end
-- shell dome behind the shoulders
local shell = c:ellipse(39.5, 94, 37, 26)
c:part(shell, SHELL, { band = 3, nopop = true })
local inner = shell:shrink(4)
shell:each(function(x, y)
  local a = math.deg(math.atan(y + .5 - 94, x + .5 - 39.5)) % 360
  if not inner:has(x, y) then
    if a % 14 < 1.6 then keep(x, y, SHELL.deep) elseif c:get(x, y) == SHELL.base and a > 180 and a < 260 then keep(x, y, SHELL.hi) end
  end
end)
for _, s in ipairs{ { 14, 84 }, { 65, 84 } } do c:ellipse(s[1], s[2], 6, 4.5):edge():each(function(x, y) if inner:has(x, y) then keep(x, y, SHELL.deep) end end) end
-- neck with wrinkles
c:part(c:rect(30, 56, 49, 72), SKIN, { band = 2, nopop = true })
for _, y in ipairs{ 62, 66 } do for x = 32, 47 do if x % 5 ~= 0 then keep(x, y, SKIN.shade) end end end
-- plastron
local pl = c:ellipse(39.5, 106, 23, 28):clip(c:rect(0, 70, 79, 99))
c:part(pl, PLAS, { band = 3 })
for _, y in ipairs{ 85, 94 } do for x = 18, 61 do if pl:shrink(1):has(x, y) then keep(x, y, PLAS.shade) end end end
for y = 76, 99 do if pl:shrink(1):has(39, y) then keep(39, y, PLAS.shade) end end
-- knit scarf + tail
local sc = c:rrect(17, 66, 62, 75, 4)
c:part(sc, SCARF, { band = 2 })
for x = 19, 60, 3 do for y = 68, 73 do if y % 2 == 0 then keep(x, y, SCARF.shade) end end end
c:part(c:poly{ { 22, 73 }, { 30, 73 }, { 31, 93 }, { 23, 93 } }, SCARF, { band = 2, sep = true })
for y = 77, 91, 4 do for x = 24, 30 do keep(x, y, SCARF.shade) end end
for x = 23, 31, 2 do keep(x, 93, SCARF.deep) end
-- hooked cane (prop) + paw
local cane = c:line({ { 8, 99 }, { 9, 80 }, { 10, 66 } }, 3)
cane:add(c:line({ { 10, 66 }, { 11, 61 }, { 15, 58 }, { 19, 59 }, { 20, 63 } }, 3))
c:part(cane, CANE, { band = 1, inner = false, pop = { x = 12, y = 59 } })
for _, q in ipairs{ { 9, 90 }, { 9, 84 }, { 10, 76 } } do keep(q[1], q[2], CANE.shade) end
c:part(c:ellipse(11, 72, 4.5, 4), SKIN, { band = 2 })
for _, q in ipairs{ { 9, 75 }, { 12, 75 }, { 14, 74 } } do keep(q[1], q[2], P.stone.hi) end
-- head
local head = c:ellipse(39.5, 42, 20.5, 18)
c:part(head, SKIN, { band = 3, pop = { x = 26, y = 31 } })
local hin = head:shrink(1)
for _, s in ipairs{ { 31, 29 }, { 39.5, 27 }, { 48, 29 }, { 26, 35 }, { 35, 33 }, { 44, 33 }, { 53, 35 } } do
  c:ellipse(s[1], s[2], 3.5, 2.2):edge():each(function(x, y) if hin:has(x, y) then keep(x, y, SKIN.shade) end end)
end
c:part(c:ellipse(39.5, 50, 8, 4.5), SNOUT, { band = 1, pop = { x = 35, y = 47 } })
c:put(37, 48, P.ink) c:put(42, 48, P.ink)
c:fillMask(c:line({ { 29, 54 }, { 34, 55 }, { 38, 57 }, { 41, 57 }, { 45, 55 }, { 50, 54 } }, 1), P.ink)
for _, ex in ipairs{ 29, 46 } do
  c:eyeLocked(ex, 40)
  for i = -1, 5 do c:put(ex + i, 39, SKIN.deep) end
  for i = 0, 4 do keep(ex + i, 38, SKIN.shade) end
end
c:paint({ "PPP", "PPP" }, 23, 49, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 54, 49, { P = "petal.base" })
c:put(23, 49, P.petal.hi) c:put(54, 49, P.petal.hi)
local m = c:ellipse(33.5, 59, 5, 2)
m:add(c:ellipse(45.5, 59, 5, 2)) m:add(c:ellipse(28, 61, 2, 2.5)) m:add(c:ellipse(51, 61, 2, 2.5))
c:part(m, WHISK, { band = 1, pop = { x = 30, y = 58 } })
for _, q in ipairs{ { 32, 60 }, { 35, 60 }, { 44, 60 }, { 47, 60 } } do keep(q[1], q[2], WHISK.shade) end
c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
