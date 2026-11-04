-- npc-pomeroy-crumbworth portrait (npc2 P1_30) species: field mouse
-- 80x100 head+shoulders: round-eared field mouse, whiskers, mustard frock coat, cream cravat; silver pocket watch in frame.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../lib/hp.lua")
local P = HP.P
local out = app.params.out or (DIR .. "/")
local NAME = "npc-pomeroy-crumbworth"
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
local FUR = P.wood
local CR = { hi = P.cream, base = "#f3e2bf", shade = "#d9b99a", deep = "#9a6f63" }
local coat = c:ellipse(39.5, 106, 33, 32):clip(c:rect(0, 72, 79, 99))
c:part(coat, "gold", { band = 3 })
c:fillMask(c:line({ {27,74},{36,96} }, 1):clip(coat), P.gold.shade)
c:fillMask(c:line({ {52,74},{43,96} }, 1):clip(coat), P.gold.shade)
c:fillMask(c:line({ {26,75},{34,95} }, 1):clip(coat), P.gold.hi)
c:part(c:poly{ {28,71},{51,71},{39.5,95} }, CR, { band = 2 })
c:fillMask(c:line({ {39,76},{39,88} }, 1), CR.shade)
c:part(c:rect(24, 90, 25, 91), "wood", { nopop = true, noshade = true }) c:part(c:rect(25, 96, 26, 97), "wood", { nopop = true, noshade = true })
c:fillMask(c:line({ {44,84},{50,87},{55,86} }, 1), P.stone.hi)
c:part(c:ellipse(59, 88, 4, 4), "stone", { band = 1, pop = { x = 57, y = 85 } })
c:fillMask(c:ellipse(59, 88, 2.5, 2.5), P.cream)
c:put(59, 88, P.ink) c:put(59, 87, P.ink) c:put(60, 88, P.ink)
c:part(c:rect(58, 82, 60, 83), "stone", { band = 1, nopop = true })
for _, x in ipairs{ 20, 59 } do
  c:part(c:ellipse(x, 32, 9, 9), FUR, { band = 2 })
  c:part(c:ellipse(x + (x < 40 and 1 or -1), 33, 5.5, 5.5), "petal", { band = 2, pop = { x = x - 3, y = 30 } })
end
c:part(c:ellipse(39.5, 52, 20, 17), FUR, { band = 3, pop = { x = 27, y = 40 } })
c:part(c:poly{ {35,37},{37,31},{39.5,35},{42,30},{45,37} }, FUR, { band = 1, inner = false, nopop = true })
c:part(c:ellipse(39.5, 61, 10, 6.5), CR, { band = 2 })
c:part(c:ellipse(39.5, 56, 2.5, 1.5), "petal", { band = 1, pop = { x = 38, y = 55 } })
c:paint({ "i.......i", ".iii.iii.", "....i...." }, 35, 60, { i = "ink" })
for _, l in ipairs{ { {29,59},{20,57} }, { {29,62},{20,63} }, { {50,59},{59,57} }, { {50,62},{59,63} } } do c:fillMask(c:line(l, 1), P.wood.deep) end
c:eyeLocked(29, 46) c:eyeLocked(46, 46)
c:fillMask(c:line({ {28,43},{30,42},{33,42} }, 1), P.wood.deep) c:fillMask(c:line({ {46,42},{49,42},{51,43} }, 1), P.wood.deep)
c:cheek(25, 55) c:cheek(53, 55)
c:finish{ outline = true }
backdrop(P.dusk)
HP.report(c) HP.assertClean(c)
c:save{ aseprite = out .. NAME .. ".aseprite", png = out .. NAME .. ".png", scale = 1 }
