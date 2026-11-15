-- Cocopaddle (ss-cocopaddle), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the ember flag at the mast top, here a 3x2 flag.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("cocopaddle-perch", 36)

local SHELL = { "#51302b", "#864c33", "#b97a4a", "#d9a070" }
local FLESH = { "#c9b89a", "#dccbb0", "#ecdcc4", "#fff4d6" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5" }
local EMBER = { "#b52e3f", "#e8493b", "#ff8a5c" }
local SEA   = { "#3a86b0", "#5fc4c8", "#b6f0e0" }

O.shade(c, c:line({ { 18, 19 }, { 18, 4 } }, 1.2), SHELL, { R = 1, amb = .3 })
O.shade(c, c:poly{ { 19, 5 }, { 19, 18 }, { 28, 16 } }, SKY, { R = 1, amb = .2, sep = SKY[1] })
O.flat(c, c:poly{ { 18, 3 }, { 18, 6 }, { 22, 5 } }, EMBER[2]) -- quirk flag

local hull = c:ellipse(18, 20, 10, 7)
hull:cut(c:rect(0, 0, 35, 19))
O.shade(c, hull, SHELL, { sphere = { 16, 22, 9 }, amb = .2, wrap = .3, sep = SHELL[1] })
local rim = c:ellipse(18, 19, 9, 2)
O.shade(c, rim, FLESH, { R = 1, amb = .4, sep = FLESH[1] })

c:eyeSmall(13, 22)
c:eyeSmall(21, 22)
O.dots(c, { { 16, 25 }, { 17, 25 }, { 18, 25 }, { 19, 25 } }, P.ink)
O.dots(c, { { 9, 24 }, { 27, 24 } }, "#f5809f")

for x = 2, 33 do
  if x % 4 < 2 then O.dot(c, x, 30, SEA[2]) else O.dot(c, x, 31, SEA[3]) end
end

O.done(c, "cocopaddle-perch")
