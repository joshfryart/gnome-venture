-- Barrow Peephole (pl-frt-5), perch sprite 36x36. Opus second pass (c09/opus2), hand-built at this size.
-- Arched plank door in a stone frame with snow on the arch, iron strap; frosty iron-rimmed peephole up top.
-- quirk: two yellow eyes peek out of the peephole.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("pl-frt-5-perch", 36)
local WOOD = { "#3e2526", "#5e3a2e", "#86583a", "#a87a52", "#c89c6e", "#e2c094" }
local STONE = { "#35314a", "#4f4c68", "#74758c", "#9a9aae", "#c4c4d0", "#e2e0e6" }
local IRON = { "#2e2a3e", "#4a4660", "#6e6a86", "#9a96b0", "#c4c2d6" }
local SNOW = { "#8bc4ea", "#b9e2f5", "#dff2fb", "#f4fcff" }
c:groundShadow(18, 31, 12, 1.5)
local function inA(x, y, g) if y >= 14 then return x >= 11 - g and x <= 24 + g and y <= 30 end return (x + .5 - 18) ^ 2 + (y + .5 - 14) ^ 2 <= (7 + g) ^ 2 end
local fr, door = HP.mask(), HP.mask()
for y = 0, 35 do for x = 0, 35 do if inA(x, y, 2) and not inA(x, y, 0) then fr:set(x, y) elseif inA(x, y, 0) then door:set(x, y) end end end
local fI, fT = O.shade(c, fr, STONE, { R = 1, amb = .35, wrap = .45, rim = true })
O.tex(c, fI, fT, STONE, function(x, y, i) if y >= 14 and y % 4 == 0 then return -2 end end)
local dI, dT = O.shade(c, door, WOOD, { R = 2, amb = .3, wrap = .4, sep = WOOD[1] })
O.tex(c, dI, dT, WOOD, function(x, y, i) if x == 14 or x == 21 then return -2 end if x == 15 or x == 22 then return 1 end end)
O.shade(c, c:rect(11, 25, 24, 26), IRON, { R = 1, amb = .35, cuts = { .3, .5, .7, .85 }, sep = IRON[1] })
O.dots(c, { { 12, 25 }, { 18, 25 }, { 23, 25 } }, IRON[5])
O.flat(c, c:ellipse(18, 12, 3.5, 3.5), IRON[3], "rim") O.dots(c, { { 16, 9 }, { 15, 10 } }, IRON[5])
O.flat(c, c:ellipse(18, 12, 2, 2), "#221a30", "hole")
O.dots(c, { { 17, 12 }, { 19, 12 } }, "#ffd75a")
O.dots(c, { { 14, 8 }, { 22, 8 }, { 13, 13 }, { 23, 14 }, { 18, 7 } }, SNOW[3])
local snow = HP.mask()
for y = 0, 35 do for x = 0, 35 do if inA(x, y, 3) and not inA(x, y, 1) and y <= 6 + math.floor(math.abs(x - 18) * .7) and y < 14 then snow:set(x, y) end end end
O.shade(c, snow, SNOW, { R = 1, amb = .45, wrap = .5, cuts = { .35, .6, .82 } })
c:eyeSmall(14, 18) c:eyeSmall(20, 18)
O.dot(c, 12, 22, P.petal.base) O.dot(c, 23, 22, P.petal.base)
O.dots(c, { { 16, 22 }, { 17, 23 }, { 18, 23 }, { 19, 22 } }, P.ink)
O.done(c, "pl-frt-5-perch")
