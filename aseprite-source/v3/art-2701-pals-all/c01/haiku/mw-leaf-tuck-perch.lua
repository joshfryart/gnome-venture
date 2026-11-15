-- Leaf Tuck (mw-leaf-tuck), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: folded into a small red leaf pile at its base.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("mw-leaf-tuck-perch", 36)

local RED  = { "#5e1f2c", "#8c2c35", "#c4413a", "#e8603c", "#f58a5a", "#ffb98a" }
local REDB = { "#4a1a2e", "#6e2440", "#973550", "#bf4f5a", "#d9707a", "#f2a8a6" }
local PILE = { "#4a1a2e", "#7a2a3a", "#a83a3c", "#d05a3c", "#ef7f50", "#ffab7c" }

c:groundShadow(18, 32, 11, 2)

local leaf = c:poly{ {18,3},{24,7},{26,13},{24,20},{18,24},{12,20},{10,13},{12,7} }
O.shade(c, leaf:copy():clip(c:rect(0, 0, 17, 35)), RED, { R = 3 })
O.shade(c, leaf:copy():clip(c:rect(18, 0, 35, 35)), REDB, { R = 3 })
local mid = {}
for y = 5, 22 do mid[#mid + 1] = { 18, y } end
O.dots(c, mid, RED[6])

c:eyeSmall(15, 12)
c:eyeSmall(20, 12)
O.dot(c, 18, 16, RED[1])
O.dots(c, { {16,19},{17,20},{18,20},{19,20} }, RED[1])

local p1 = c:ellipse(9, 27, 5, 3)
local p2 = c:ellipse(18, 28, 6, 3)
local p3 = c:ellipse(27, 27, 4, 3)
O.shade(c, p1, PILE, { R = 2 })
O.shade(c, p2, PILE, { R = 2, sep = PILE[1] })
O.shade(c, p3, PILE, { R = 2, sep = PILE[1] })

O.done(c, "mw-leaf-tuck-perch")
