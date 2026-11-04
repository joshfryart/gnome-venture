-- npc-clementine-moss portrait (npc2 P1_6) species: garden snail
-- Same design as the sprite: tan snail, clementine spiral shell with moss tuft + sprout, blue polka-dot
-- scarf hood knotted left, cream apron, locked eyes on stalk tips, soft muzzle + pink button nose. Moss disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-clementine-moss"
local SHELL = { hi = "#ffc37a", base = "#f28a3a", shade = "#c45a34", deep = "#6e2c38" }
local SKIN = { hi = "#f6e6b0", base = "#dcc084", shade = "#a98563", deep = "#5e4048" }
local SCARF = P.sea
local APRON = { hi = P.cream, base = "#f3e6c8", shade = P.stone.hi, deep = P.stone.base }
local MOSS = P.moss
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
local function spiral(cx, cy, r0, turns, rot)
  local pts, T = {}, turns * 2 * math.pi
  for i = 0, 90 do local t = i / 90 * T local r = r0 * (1 - t / T * 0.9)
    pts[#pts + 1] = { cx + math.cos(t + rot) * r, cy + math.sin(t + rot) * r } end
  return pts
end
-- shell behind right shoulder
local scx, scy = 60, 66
local shell = c:ellipse(scx, scy, 17, 17)
c:part(shell, SHELL, { band = 3, pop = { x = 49, y = 55 } })
local groove = c:line(spiral(scx + 0.5, scy + 0.5, 14.5, 2.3, 3.6), 1):clip(shell:shrink(2))
groove:each(function(x, y) c:put(x, y, SHELL.deep, "g") end)
groove:each(function(x, y) if c:get(x - 1, y - 1) == SHELL.base and not groove:has(x - 1, y - 1) and (x + y) % 2 == 0 then c:put(x - 1, y - 1, SHELL.hi, "g") end end)
-- moss tuft + sprout on top of the shell
local tuft = c:ellipse(62, 50, 7, 2.5)
for _, l in ipairs{ { {57, 50}, {55, 45} }, { {61, 49}, {61, 43} }, { {66, 50}, {69, 46} } } do tuft:add(c:line(l, 1)) end
c:part(tuft, MOSS, { band = 1, pop = { x = 57, y = 49 } })
c:part(c:line({ {63, 48}, {64, 41} }, 1), MOSS, { noshade = true, nopop = true })
c:part(c:ellipse(61.5, 40.5, 2, 1.2), MOSS, { band = 1, nopop = true, sep = true })
c:part(c:ellipse(66.5, 40, 2, 1.2), MOSS, { band = 1, nopop = true, sep = true })
-- body + apron
local body = c:ellipse(38, 106, 29, 28):clip(c:rect(0, 0, 79, 99))
c:part(body, SKIN, { band = 3, pop = { x = 16, y = 86 } })
local ap = c:rrect(26, 84, 50, 99, 4)
ap:add(c:line({ {28, 85}, {27, 78} }, 3)):add(c:line({ {48, 85}, {49, 78} }, 3))
c:part(ap, APRON, { band = 2, nopop = true })
c:part(c:rrect(32, 90, 44, 97, 2), APRON, { band = 1, nopop = true, sep = true })
c:stitch{ {33, 91}, {43, 91} }
c:button(28, 86) c:button(48, 86)
-- eye stalks
local st = c:line({ {33, 44}, {30, 30}, {27, 18} }, 3):add(c:line({ {44, 44}, {47, 30}, {51, 18} }, 3))
c:part(st, SKIN, { band = 1, nopop = true })
-- head
local head = c:ellipse(38.5, 57, 20, 16.5)
c:part(head, SKIN, { band = 3, pop = { x = 23, y = 58 } })
-- muzzle + nose
local muz = c:ellipse(38.5, 66, 8, 4.5)
c:part(muz, { hi = P.cream, base = SKIN.hi, shade = SKIN.base, deep = SKIN.shade }, { band = 1, nopop = true })
c:part(c:ellipse(38.5, 62.5, 3, 2), P.petal, { band = 1, pop = { x = 37, y = 61 }, sep = true })
c:paint({ "i.......i", ".iiDDDii.", "...iPi..." }, 34, 66, { i = "ink", D = "ember.deep", P = "petal.base" })
c:paint({ "PPP", "PPP" }, 23, 64, { P = "petal.base" }) c:paint({ "PPP", "PPP" }, 51, 64, { P = "petal.base" })
c:px(23, 64, P.petal.hi) c:px(51, 64, P.petal.hi)
-- scarf hood
local scarf = c:ellipse(38.5, 51, 22, 13):cut(c:ellipse(38.5, 64, 16, 11.5))
c:part(scarf, SCARF, { band = 3, pop = { x = 25, y = 42 } })
scarf:each(function(x, y) if (x + 2 * y) % 8 == 0 and x % 2 == 0 and c:get(x, y) == SCARF.base and scarf:has(x + 1, y) and scarf:has(x, y + 1) then
  c:put(x, y, P.cream, "d") c:put(x + 1, y, P.cream, "d") end end)
local knot = c:ellipse(17, 62, 3.5, 3)
knot:add(c:poly{ {15, 63}, {18, 64}, {13, 76}, {9, 73} }):add(c:poly{ {18, 64}, {21, 64}, {21, 78}, {17, 77} })
c:part(knot, SCARF, { band = 1, sep = true, pop = { x = 15, y = 60 } })
-- eyeballs + locked eyes
for _, e in ipairs{ {26.5, 13.5}, {51.5, 13.5} } do
  c:part(c:ellipse(e[1], e[2], 5.5, 5.5), SKIN, { band = 1, sep = true, nopop = true })
end
c:eyeLocked(24, 11) c:eyeLocked(49, 11)
c:finish{ outline = true }
backdrop(P.moss)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
