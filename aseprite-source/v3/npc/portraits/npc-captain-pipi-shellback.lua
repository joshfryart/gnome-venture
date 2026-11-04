-- npc-captain-pipi-shellback portrait (npc2 P1_5) species: turtle
-- Same design as the sprite: green turtle head, pale muzzle with beak ridge + nostrils, white peaked cap with navy
-- band, gold anchor badge, brown visor; navy coat, cream lapels, gold buttons; shell rim behind; grey ship's cat. Sea disc.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-captain-pipi-shellback"
local NAVY = { hi = "#6f8fd6", base = "#3f5aa8", shade = "#2e4180", deep = "#222c5c" }
local CR = { hi = P.cream, base = "#efe3c2", shade = "#c9c3d6", deep = P.stone.shade }
local MUZ = { hi = "#e4f2a8", base = P.moss.hi, shade = "#9cc867", deep = P.moss.shade }
local c = HP.canvas{ w = 80, h = 100, scale = 1, name = NAME }
local function backdrop(r)
  local disc = HP.ellipse(39.5, 44.5, 30.5, 30.5)
  disc:each(function(x, y) if not c:get(x, y) then c:put(x, y, disc:has(x + 2, y + 2) and r.base or r.shade, "bg") end end)
  local ring = disc:grow(1):cut(disc)
  ring:each(function(x, y) if not c:get(x, y) then c:put(x, y, r.deep, "bg") end end)
end
-- shell behind shoulders
local shell = c:ellipse(39.5, 98, 37, 28):clip(c:rect(0, 66, 79, 99))
c:part(shell, P.wood, { band = 2, pop = { x = 12, y = 80 } })
for _, l in ipairs{ { { 14, 74 }, { 20, 84 } }, { { 24, 69 }, { 27, 78 } }, { { 65, 74 }, { 59, 84 } }, { { 55, 69 }, { 52, 78 } }, { { 6, 86 }, { 13, 92 } }, { { 73, 86 }, { 66, 92 } } } do
  c:fillMask(c:line(l, 1):clip(shell:shrink(1)), P.wood.deep)
end
-- navy coat + lapels + buttons
local coat = c:ellipse(39.5, 106, 28, 30):clip(c:rect(0, 74, 79, 99))
c:part(coat, NAVY, { band = 3, pop = { x = 20, y = 84 } })
c:part(c:poly{ { 31, 75 }, { 48, 75 }, { 39.5, 93 } }, CR, { band = 1, nopop = true })
c:part(c:rect(32, 64, 47, 77), P.moss, { band = 1, nopop = true })
for _, q in ipairs{ { 26, 85 }, { 26, 93 }, { 53, 85 }, { 53, 93 } } do c:button(q[1], q[2]) c:put(q[1] - 1, q[2] - 1, P.gold.hi) end
-- head
local head = c:ellipse(39.5, 49, 20, 16)
c:part(head, P.moss, { band = 3, pop = { x = 26, y = 44 } })
for _, q in ipairs{ { 24, 54 }, { 27, 58 }, { 54, 53 }, { 51, 59 }, { 22, 49 } } do c:put(q[1], q[2], P.moss.shade) end
-- muzzle + beak ridge + nostrils + mouth
c:part(c:ellipse(39.5, 56, 10, 6), MUZ, { band = 1, pop = { x = 33, y = 52 } })
c:paint({ "hh", "hh", ".h" }, 39, 50, { h = MUZ.hi })
c:put(37, 53, P.moss.deep) c:put(42, 53, P.moss.deep)
c:paint({ "i..........i", ".iiiiiiiiii.", "...iEEEEi..." }, 34, 57, { i = "ink", E = "ember.base" })
c:put(38, 59, P.ember.hi)
c:eyeLocked(28, 44) c:eyeLocked(47, 44)
for i = 0, 4 do c:put(28 + i, 43, P.moss.shade) c:put(47 + i, 43, P.moss.shade) end
c:paint({ "PP", "PP" }, 24, 56, { P = "petal.base" }) c:paint({ "PP", "PP" }, 54, 56, { P = "petal.base" })
-- peaked cap
local crown = c:ellipse(39.5, 26, 23, 8.5)
c:part(crown, CR, { band = 2, pop = { x = 24, y = 22 } })
local band = c:poly{ { 18, 30 }, { 61, 30 }, { 60, 36 }, { 19, 36 } }
c:part(band, NAVY, { band = 1, nopop = true })
c:part(c:ellipse(39.5, 38, 16, 2.5), P.wood, { band = 1, pop = { x = 30, y = 37 } })
c:paint({ ".G.", "GGG", ".G.", "G.G", ".G." }, 38, 31, { G = "gold.base" })
c:put(38, 33, P.gold.hi)
c:stitch{ { 20, 30 }, { 59, 30 } }
for _, q in ipairs{ { 22, 20 }, { 23, 19 }, { 24, 19 } } do c:put(q[1], q[2], P.cream) end
-- ship's cat lower-left
local cb = c:ellipse(22, 100, 11, 8)
c:part(cb, P.stone, { band = 2, nopop = true })
local ch = c:ellipse(22, 84, 9, 7)
ch:add(c:poly{ { 13, 82 }, { 14, 73 }, { 20, 78 } })
ch:add(c:poly{ { 24, 78 }, { 30, 73 }, { 31, 82 } })
c:part(ch, P.stone, { band = 2, pop = { x = 16, y = 80 } })
c:put(15, 77, P.petal.base) c:put(15, 78, P.petal.base) c:put(29, 77, P.petal.base) c:put(29, 78, P.petal.base)
c:paint({ "YYY", "YiY", "YiY" }, 16, 82, { Y = "gold.base", i = "ink" })
c:paint({ "YYY", "YiY", "YiY" }, 25, 82, { Y = "gold.base", i = "ink" })
c:put(16, 82, P.gold.hi) c:put(25, 82, P.gold.hi)
c:paint({ "PPP", ".P." }, 21, 86, { P = "petal.base" })
c:paint({ "i.i.i", ".i.i." }, 20, 88, { i = "ink" })
for _, w in ipairs{ { 12, 87 }, { 11, 89 }, { 32, 87 }, { 33, 89 } } do c:put(w[1], w[2], P.stone.hi) end
c:part(c:ellipse(33, 93, 4.5, 3), P.moss, { band = 1, pop = { x = 31, y = 92 } })
c:put(30, 95, P.moss.deep) c:put(33, 96, P.moss.deep)
c:finish{ outline = true }
backdrop(P.sea)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
