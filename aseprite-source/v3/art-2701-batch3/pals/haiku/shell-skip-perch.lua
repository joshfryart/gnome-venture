-- Shell Skip (ss-shell-skip), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the pearl on top of the shell, here a 2x2 cream dot.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("shell-skip-perch", 36)

local SHELL = { "#51302b", "#8f4a1f", "#d98322", "#f5b82e", "#ffe38a" }
local PET   = { "#7d2c5e", "#c94f84", "#f5809f", "#ffc4d8" }

c:groundShadow(18, 31, 10, 2)

local legs = c:line({ { 12, 23 }, { 8, 28 } }, 1.2)
legs:add(c:line({ { 24, 23 }, { 28, 28 } }, 1.2))
O.shade(c, legs, PET, { R = 1, amb = .3, sep = PET[1] })

local shell = c:ellipse(18, 14, 11, 9)
shell:cut(c:rect(0, 19, 35, 35))
O.shade(c, shell, SHELL, { sphere = { 15, 11, 10 }, amb = .2, wrap = .3, sep = SHELL[1] })
O.mark(c, { { 18, 9 }, { 18, 10 }, { 13, 12 }, { 23, 12 }, { 14, 7 }, { 22, 7 } }, SHELL[2])
O.dots(c, { { 20, 14 }, { 21, 14 } }, SHELL[2])
O.dots(c, { { 24, 4 }, { 25, 4 }, { 24, 5 }, { 25, 5 } }, "#fff4d6") -- quirk: pearl

local body = c:ellipse(18, 21, 6, 3)
O.shade(c, body, PET, { R = 1, amb = .3, sep = PET[1] })
c:eyeSmall(13, 20)
c:eyeSmall(21, 20)
O.dot(c, 17, 22, PET[1])
O.dots(c, { { 16, 24 }, { 17, 24 }, { 18, 24 } }, P.ink)

O.done(c, "shell-skip-perch")
