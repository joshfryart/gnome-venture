-- Flamingo Flick (th-flamingo-flick), perch sprite 36x36. Opus second pass (c05/opus2), hand-built at this size.
-- Bold and few: big round head facing you (pill eyes 5 px apart, cocky brows), a short bent beak with a plum tip,
-- 2 px S-neck, pink teardrop body, one leg down into a small waterhole, the other folded under.
-- Fix vs Haiku: the wing no longer reads as a fin: it is flung up with three dark primaries as fingers.
-- quirk (the dare): the raised, beckoning wing.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("th-flamingo-flick-perch", 36)

local FLM  = { "#5e1f3a", "#8f2f55", "#c44a73", "#e8789a", "#f7a3b8", "#fdd3d8" }
local LEG  = { "#6e2440", "#a83a5e", "#d9607f", "#f08ea6" }
local BEAK = { "#3a2233", "#5b3047", "#d68e9e", "#f3c4c2" }
local PRIM = { "#2f1f33", "#4a2f4c", "#6e4668" }
local WAT  = { "#1d4866", "#2c6f8f", "#4598b0", "#6fc2c8", "#a8e2d8", "#d4f4e8" }
local BNC  = "#7a5a8a"

local pool = c:ellipse(17, 31, 12, 1.5)
local wb = {} pool:each(function(x, y) if y <= 30 then wb[K(x, y)] = 2 end end)
O.shade(c, pool, WAT, { R = 1, bias = wb, amb = .3, wrap = .4 })
O.mark(c, { { 13, 31 }, { 14, 31 }, { 19, 31 }, { 20, 31 } }, WAT[6])

O.flat(c, c:rect(16, 24, 16, 30), LEG[3], "leg") O.flat(c, c:rect(17, 24, 17, 30), LEG[2], "leg")
O.dot(c, 16, 27, LEG[4]) O.dot(c, 17, 27, LEG[3])
-- folded leg
O.flat(c, c:line({ { 19, 23 }, { 21, 26 } }, 1), LEG[3], "leg2") O.flat(c, c:line({ { 21, 26 }, { 18, 27 } }, 1), LEG[2], "leg2")

local body = c:ellipse(15, 20.5, 7, 4.5)
body:add(c:poly{ { 9, 18 }, { 4, 19 }, { 6, 21 }, { 10, 23 } })
O.shade(c, body, FLM, { R = 3, amb = .25, wrap = .4, rim = true, bounce = BNC, bmax = 2 })

local nk, nkn = O.tube({ { 20, 19 }, { 26, 16 }, { 19, 12 }, { 23, 9 } }, function() return 1.3 end)
O.shadeN(c, nk, nkn, FLM, { amb = .28, wrap = .4, sep = FLM[2], rim = true })

local head = c:ellipse(23.5, 7, 6, 5)
O.shade(c, head, FLM, { sphere = { 22, 5, 6 }, amb = .3, wrap = .4, rim = true, bounce = BNC, bmax = 2 })
c:eyeSmall(20, 5) c:eyeSmall(26, 5)
O.dots(c, { { 19, 4 }, { 20, 3 }, { 21, 3 }, { 26, 3 }, { 27, 3 }, { 28, 4 } }, FLM[2])
O.dot(c, 19, 9, "#f5809f") O.dot(c, 28, 9, "#f5809f")
local bk = c:poly{ { 22, 8 }, { 25, 8 }, { 26, 11 }, { 27, 13 }, { 26, 14 }, { 24, 11 }, { 22, 9 } }
local kb = {} bk:each(function(x, y) if y >= 12 then kb[K(x, y)] = -9 end end)
O.shade(c, bk, BEAK, { R = 1, bias = kb, amb = .5, wrap = .5, cuts = { .25, .5, .75 }, sep = FLM[1] })
O.mark(c, { { 23, 8 }, { 23, 9 } }, BEAK[4])

-- quirk: wing flung up, three dark primaries as fingers
local wing = c:poly{ { 11, 20 }, { 16, 19 }, { 13, 13 }, { 9, 11 }, { 8, 13 } }
O.shade(c, wing, FLM, { R = 1, amb = .35, wrap = .45, sep = FLM[2], rim = true })
for _, f in ipairs({ { 9, 11, 7, 8 }, { 11, 12, 10, 8 }, { 13, 13, 14, 9 } }) do
  O.flat(c, c:line({ { f[1], f[2] }, { f[3], f[4] } }, 1), PRIM[2], "prim")
  O.dot(c, f[3], f[4], PRIM[3])
end

O.shift(c, 1, 0)
O.done(c, "th-flamingo-flick-perch")
