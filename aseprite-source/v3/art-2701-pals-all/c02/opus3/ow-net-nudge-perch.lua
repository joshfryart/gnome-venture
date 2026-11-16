-- Net Nudge (ow-net-nudge), perch sprite 36x36. Opus richness pass (c02/opus3), built on opus2, hand-built at this size.
-- Richness (opus3): mesh casts a 1 px shadow on the skin (net sits on the head), lit knots, banded floats,
-- cork band on the knob, a few skin freckles below the face, fish fin rays; the face stays clean and bold.
-- Round sea-teal pal under a net hood gathered into a round cork float, hem of two red floats.
-- Fix vs Haiku: the perch net was near noise; now a 5 px open mesh only on the crown, with clean skin
-- for the pill eyes and smile; the fish is a real shape (eye, fin, forked tail) instead of a blob.
-- quirk: the little red fish being nudged towards the quay by its flipper.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("ow-net-nudge-perch", 36)

local SEA  = { "#1d3f55", "#245e74", "#2f8592", "#48aaa6", "#7ccbb8", "#b9e8d4" }
local ROPE = { "#5a3a2c", "#7e5636", "#a87d4c", "#cba468", "#e6c88c", "#f4e2b0" }
local CORK = { "#6a2430", "#a3343a", "#d4553f", "#ef8a5a", "#f8bf8a" }
local FISH = { "#7a2c34", "#b8433a", "#e3703f", "#f6a456", "#fbd58a" }

c:groundShadow(20, 31, 11, 1.5)

local body = c:ellipse(21, 20, 9.5, 9.5)
local bI, bT = O.shade(c, body, SEA, { sphere = { 17, 16, 12 }, amb = .2, wrap = .35, rim = true, bounce = "#5b6a9a", bmax = 2 })
local function hem(x) return 15 + ((x - 21) / 10) ^ 2 * 4 end
O.retone(c, bI, bT, { ROPE[2], ROPE[3], ROPE[4], ROPE[5], ROPE[6], ROPE[6] }, function(x, y, i)
  if y >= hem(x) then return false end
  return (x + y) % 5 == 0 or (x - y) % 5 == 0
end)
local function isNet(x, y) return y < hem(x) and ((x + y) % 5 == 0 or (x - y) % 5 == 0) end
O.tex(c, bI, bT, SEA, function(x, y, i)
  if isNet(x, y) then return end
  if y < hem(x) + 1 and isNet(x, y - 1) then return -1 end
  if y > 26 and H(x, y, 5) > .88 and i >= 2 and i <= 5 then return -1 end
end)
O.tex(c, bI, bT, ROPE, function(x, y, i) if isNet(x, y) and (x + y) % 5 == 0 and (x - y) % 5 == 0 then return 1 end end)
local hm = HP.mask()
for x = 11, 31 do local y = math.floor(hem(x) + .5) if body:has(x, y) then hm:set(x, y) end end
O.shade(c, hm, ROPE, { R = 1, amb = .4 })
for _, fx in ipairs({ 15, 27 }) do
  local fy = math.floor(hem(fx) + .5)
  O.flat(c, c:rect(fx - 1, fy, fx, fy), CORK[3], "float")
  O.dot(c, fx - 1, fy, CORK[4])
  O.dot(c, fx, fy + 1, CORK[2]) O.dot(c, fx - 1, fy + 1, CORK[3])
end
-- round knob: cork float on top
O.flat(c, c:rect(21, 8, 21, 10), ROPE[3], "tie")
O.shade(c, c:ellipse(21, 6, 2.5, 2.5), CORK, { sphere = { 20, 5, 3 }, amb = .25, cuts = { .25, .45, .65, .84 } })
O.dot(c, 20, 5, CORK[5])
O.dots(c, { { 20, 7 }, { 21, 7 }, { 22, 7 } }, CORK[2]) -- cork band

-- face
c:eyeSmall(17, 19)
c:eyeSmall(24, 19)
O.dot(c, 15, 23, "#f5809f") O.dot(c, 28, 23, "#f5809f")
O.dots(c, { { 19, 24 }, { 20, 25 }, { 21, 25 }, { 22, 25 }, { 23, 24 } }, P.ink)

-- flippers: right resting, left reaching to the fish
O.shade(c, c:ellipse(30.5, 23, 1.5, 2.5), SEA, { R = 1, amb = .3, sep = SEA[1] })
O.shade(c, c:poly{ { 13, 22 }, { 12, 24 }, { 12, 26 }, { 13, 26 } }, SEA, { R = 1, amb = .3, sep = SEA[1] })

-- quirk: the fish, nose left, forked tail touching the flipper
O.shade(c, c:ellipse(5.5, 28, 3.5, 2), FISH, { R = 1, amb = .2, cuts = { .3, .5, .7, .88 } })
O.flat(c, c:rect(9, 28, 10, 28), FISH[3], "tail") O.dots(c, { { 11, 27 }, { 11, 26 }, { 11, 29 }, { 11, 30 }, { 10, 27 }, { 10, 29 } }, FISH[2])
O.dots(c, { { 5, 25 }, { 6, 25 }, { 6, 26 } }, FISH[2]) -- dorsal fin
O.dot(c, 4, 27, P.ink)
O.dots(c, { { 4, 29 }, { 5, 29 }, { 6, 29 }, { 7, 29 } }, FISH[5])
O.dot(c, 7, 27, FISH[2]) O.dot(c, 7, 28, FISH[2]) -- gill
O.dot(c, 5, 27, FISH[5]) -- eye glint side

O.done(c, "ow-net-nudge-perch")
