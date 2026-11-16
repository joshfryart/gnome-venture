-- Slag Drip (pl-cwy-2), perch sprite 36x36. Opus second pass (c11/opus2), hand-built at this size.
-- Molten slag poured over a dark riveted iron beam, its neck stretching into a heavy glowing bulb (hot core upper-
-- left, red base). 2x3 pill eyes, a calm smile. quirk: a little molten hand still holding the beam, and one droplet
-- that has only just let go above a glowing floor puddle.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-cwy-2-perch", 36)

local SLAG = { "#6a1a1e", "#a82c1c", "#e05a1e", "#f8962e", "#ffcc56", "#fff0a0" }
local IRON = { "#1a1822", "#2a2632", "#3e3848", "#585060", "#7c7484", "#a49caa" }

O.flat(c, c:rect(13, 33, 23, 33), SLAG[3], "puddle") O.dots(c, { { 15, 33 }, { 16, 33 }, { 17, 33 } }, SLAG[5]) O.dots(c, { { 22, 33 }, { 23, 33 } }, SLAG[2])
local beam = c:rect(2, 3, 33, 7)
O.shade(c, beam, IRON, { R = 2, amb = .3, wrap = .4, rim = true })
for x = 2, 33 do O.mark(c, { { x, 7 } }, IRON[1]) end
for _, rx in ipairs({ 5, 29 }) do O.dot(c, rx, 5, IRON[6]) O.dot(c, rx + 1, 6, IRON[2]) end
local drip, dn = O.tube({ { 18, 4 }, { 16, 10 }, { 20, 12 }, { 18, 16 } }, function(t) return 2 + 2.5 * t * t end)
drip:add(c:ellipse(18, 19.5, 8, 6.5))
drip:add(c:ellipse(18, 2.5, 5, 1))
drip:add(c:ellipse(18, 8, 3.5, 1))
drip:clip(c:rect(0, 2, 35, 35))
local dI, dT = O.shade(c, drip, SLAG, { sphere = { 15, 15, 12 }, amb = .2, wrap = .34, rim = true })
O.flat(c, c:rect(14, 15, 15, 15), SLAG[6], "core")
drip:each(function(x, y) local q = y * c.w + x if c.own[q] == dT and y >= 25 and (x + y) % 2 == 0 then c.pix[q] = SLAG[2] end end)
local arm, an = O.tube({ { 11, 16 }, { 8, 13 }, { 7, 11 }, { 8, 8 } }, function(t) return 1.2 end)
O.shadeN(c, arm, an, SLAG, { amb = .4, wrap = .45, sep = SLAG[1] })
O.flat(c, c:rect(7, 8, 9, 8), SLAG[4], "fingers")
c:eyeSmall(14, 17)
c:eyeSmall(20, 17)
O.dot(c, 12, 21, P.petal.base) O.dot(c, 24, 21, P.petal.base)
O.dots(c, { { 16, 22 }, { 17, 23 }, { 18, 23 }, { 19, 23 }, { 20, 22 } }, P.ink)
O.flat(c, c:rect(18, 30, 18, 30), SLAG[5], "drop")

O.done(c, "pl-cwy-2-perch", function(c)
  c:put(11, 32, SLAG[5]) c:put(25, 32, SLAG[5])
end)
