-- Bell Bead (pl-bjq-3), perch sprite 36x36. Opus second pass (c15/opus2), hand-built at this size.
-- Blue sea-glass bell (round crown, flared waist, rolled lip band, pale streak down the left), a gold ring on top
-- with a pink bow, gold bead clapper swung to one side, 2x3 pill eyes.
-- quirk: mid-ding (the queen is near): clapper swung, ring arcs on that side only.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-bjq-3-perch", 36)

local GLS  = { "#22346e", "#2f58a0", "#4a86cc", "#78b6e8", "#b0dcf6", "#e6f6ff" }
local GOLD = { "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a", "#fff4c0" }
local RIB  = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

c:groundShadow(17, 33, 7, 1)
local ring = c:rect(16, 3, 18, 5) ring:cut(c:rect(17, 4, 17, 4))
O.flat(c, ring, GOLD[3], "ring") O.dots(c, { { 16, 3 }, { 17, 3 } }, GOLD[4]) O.dots(c, { { 18, 5 } }, GOLD[2])
local bell = c:ellipse(17, 13, 6, 5.5)
bell:add(c:poly{ { 11, 13 }, { 23, 13 }, { 24, 20 }, { 27, 24 }, { 7, 24 }, { 10, 20 } })
local bI, bT = O.shade(c, bell, GLS, { R = 4, amb = .26, wrap = .45, rim = true, bounce = "#9a7ad0", bmax = 2, sep = GLS[2] })
for y = 9, 21 do O.mark(c, { { 13 - math.floor(math.max(0, y - 14) * .45), y } }, GLS[6]) end
O.shade(c, c:rrect(6, 23, 28, 25, 1), GLS, { R = 1, amb = .3, wrap = .45, rim = true, sep = GLS[1] })
O.flat(c, c:rect(10, 26, 24, 26), GLS[1], "mouth")
O.shade(c, c:ellipse(21, 28.5, 2, 2), GOLD, { sphere = { 20, 27, 3 }, amb = .35, cuts = { .25, .45, .65, .85 }, sep = GLS[1] })
O.flat(c, c:poly{ { 17, 7 }, { 13, 5 }, { 13, 9 } }, RIB[3], "bow") O.flat(c, c:poly{ { 17, 7 }, { 21, 5 }, { 21, 9 } }, RIB[3], "bow")
O.dots(c, { { 13, 8 }, { 14, 8 }, { 21, 8 }, { 20, 8 } }, RIB[2]) O.dots(c, { { 13, 6 }, { 21, 6 } }, RIB[4]) O.flat(c, c:rect(16, 6, 18, 8), RIB[2], "knot") O.dot(c, 17, 6, RIB[4])

c:eyeSmall(13, 14)
c:eyeSmall(19, 14)
O.dot(c, 11, 18, P.petal.base) O.dot(c, 23, 18, P.petal.base)
O.mark(c, { { 16, 19 }, { 17, 19 } }, P.ink)

O.done(c, "pl-bjq-3-perch", function(c)
  for _, p in ipairs({ { 30, 14 }, { 31, 15 }, { 31, 16 }, { 31, 17 }, { 30, 18 }, { 33, 12 }, { 34, 13 }, { 34, 14 }, { 34, 15 }, { 34, 16 }, { 34, 17 }, { 34, 18 }, { 34, 19 }, { 33, 20 } }) do
    if not c:get(p[1], p[2]) then c:put(p[1], p[2], P.ink) end
  end
end)
