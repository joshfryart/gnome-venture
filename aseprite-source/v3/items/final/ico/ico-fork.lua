local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local D = dofile(DIR .. "/../_helpers/_dA4.lua")
local HP, X, INK, CR = D.HP, D.X, D.INK, D.CR
local floor, sin, cos, sqrt, max, min, abs, pi = math.floor, math.sin, math.cos, math.sqrt, math.max, math.min, math.abs, math.pi
-- ico-fork: upright silver table fork, four fat tines and a slim neck.
-- quirk: a green pea is stuck on the left tine.
local c = D.new("ico-fork")
local head = c:rrect(22, 20, 42, 31, 3)
local tines = HP.mask()
for _, x in ipairs{ 22, 28, 34, 40 } do tines:add(c:rect(x, 6, x + 2, 24)) end
head:add(tines)
D.lit(head, D.STEEL, 8, { amb = 0.1 })
for _, x in ipairs{ 22, 28, 34, 40 } do c:px(x + 1, 8, "#f0f1fa") end
local neck = c:poly{ {22,30},{42,30},{35,40},{29,40} }
D.lit(neck, D.STEEL, 6, { amb = 0.1 })
local hand = D.H.sweep({ {32,38},{32,46},{32,50},{32,58} }, function(t) return 2.4 + 1.8 * t end)
D.lit(hand, D.STEEL, 4, { amb = 0.1 })
for y = 44, 54, 5 do D.fill(c:rect(31, y, 33, y), D.STEEL[2]) end
D.lit(D.disc(25, 9, 4), D.GREEN, 3, { amb = 0.05 }) c:px(23, 7, "#e8ffd0") c:px(24, 7, "#e8ffd0")
D.fin()
