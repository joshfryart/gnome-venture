-- Cocopaddle (ss-cocopaddle), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Thornblade, rare. A half coconut shell with cream flesh showing, a mast and a sky-blue sail.
-- quirk: a little ember flag fluttering at the top of the mast.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("cocopaddle-yard", 64)

local SHELL = { "#51302b", "#864c33", "#b97a4a", "#d9a070", "#e8b982" }
local FLESH = { "#c9b89a", "#dccbb0", "#ecdcc4", "#f6ead8", "#fff4d6" }
local SKY   = { "#5f9ad0", "#8bc4ea", "#b9e2f5", "#e4f6ff" }
local EMBER = { "#b52e3f", "#e8493b", "#ff8a5c" }
local SEA   = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0" }

-- mast and sail
O.shade(c, c:line({ { 32, 37 }, { 32, 6 } }, 1.4), SHELL, { R = 1, amb = .3 })
O.shade(c, c:poly{ { 34, 8 }, { 34, 34 }, { 47, 31 } }, SKY, { R = 2, amb = .2, sep = SKY[1] })
O.mark(c, { { 38, 26 }, { 40, 24 }, { 42, 28 } }, SKY[2])
O.flat(c, c:poly{ { 32, 6 }, { 32, 10 }, { 37, 8 } }, EMBER[2]) -- quirk flag
O.dot(c, 34, 8, EMBER[3])

-- coconut half: outer shell (lower half) with the flesh rim on top
local hull = c:ellipse(32, 40, 16, 11)
hull:cut(c:rect(0, 0, 63, 37))
O.shade(c, hull, SHELL, { sphere = { 30, 38, 14 }, amb = .2, wrap = .3, sep = SHELL[1] })
local rim = c:ellipse(32, 38, 14, 3.5)
O.shade(c, rim, FLESH, { R = 2, amb = .4, sep = FLESH[2] })

-- face on the shell
c:eyeLocked(24, 42)
c:eyeLocked(36, 42)
c:cheek(21, 47) c:cheek(41, 47)
O.dots(c, { { 31, 44 }, { 32, 44 } }, SHELL[2])
O.dots(c, { { 30, 48 }, { 31, 49 }, { 32, 49 }, { 33, 48 } }, P.ink)

-- waves under the hull
for x = 4, 58 do
  if x % 4 < 2 then O.dot(c, x, 53, SEA[3]) else O.dot(c, x, 54, SEA[2]) end
end

O.done(c, "cocopaddle-yard")
