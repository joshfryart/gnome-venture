-- Canyon Crown (dw-canyon-crown), perch sprite 36x36. Opus second pass, hand-built at this size.
-- Sandstone boulder with pill eyes and a smile; rose-red cliff-band crown with a mesa, a butte with a clear
-- 3x4 arch hole and a spire, thick enough to hold at 36 px. quirk: the tiny cactus on the mesa.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_opus.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local H = O.H
local c = O.canvas("dw-canyon-crown-perch", 36)

local SND  = { "#5a3e2e", "#8a6040", "#b68a5a", "#d4ac78", "#ead0a0", "#f8e8c8" }
local ROSE = { "#5a1e2a", "#8a2e38", "#b8464a", "#d86a62", "#ec9a86", "#f8c8b4" }
local CAC  = { "#1f4a3c", "#3a7a48", "#6aae58", "#a8d878" }

c:groundShadow(18, 32, 11, 1.5)
for _, fx in ipairs({ 13, 23 }) do O.shade(c, c:ellipse(fx, 31, 2.5, 1.2), SND, { R = 1, amb = .25, sep = SND[1] }) end
local body = c:ellipse(18, 24.5, 10, 6.5)
local bI, bT = O.shade(c, body, SND, { sphere = { 15, 21, 11 }, amb = .2, wrap = .4, sep = SND[1], rim = true, bounce = "#8a7ab0", bmax = 2 })
O.tex(c, bI, bT, SND, function(x, y, i) if (x < 12 or x > 24) and y % 3 == 0 and i >= 2 then return -1 end end)

local crown = c:poly{ { 7, 20 }, { 8, 13 }, { 12, 13 }, { 13, 16 } }
crown:add(c:poly{ { 12, 20 }, { 14, 9 }, { 15, 8 }, { 21, 8 }, { 22, 9 }, { 24, 20 } })
crown:add(c:poly{ { 23, 20 }, { 25, 12 }, { 26, 9 }, { 27, 9 }, { 29, 14 }, { 30, 20 } })
crown:add(c:rect(7, 17, 30, 20))
crown:cut(c:rect(17, 12, 19, 15))
local cI, cT = O.shade(c, crown, ROSE, { R = 2, amb = .22, wrap = .4, sep = ROSE[1], rim = true })
O.tex(c, cI, cT, ROSE, function(x, y, i) if y % 3 == 0 and y < 17 and i >= 2 then return -1 end end)
for x = 7, 30 do if crown:has(x, 17) then c:put(x, 17, ROSE[2], cT) end end
O.dots(c, { { 10, 19 }, { 15, 19 }, { 20, 19 }, { 25, 19 } }, ROSE[5])
local cac = c:rect(9, 8, 10, 12) cac:add(c:rect(7, 9, 7, 10)) cac:add(c:rect(8, 10, 8, 10))
O.flat(c, cac, CAC[3], "cactus") O.dots(c, { { 9, 8 }, { 9, 9 }, { 7, 9 } }, CAC[4]) O.dots(c, { { 10, 11 }, { 10, 12 } }, CAC[2])

c:eyeSmall(14, 23) c:eyeSmall(21, 23)
O.dot(c, 12, 27, "#f5809f") O.dot(c, 24, 27, "#f5809f")
O.dots(c, { { 16, 27 }, { 17, 28 }, { 18, 28 }, { 19, 28 }, { 20, 27 } }, P.ink)
O.done(c, "dw-canyon-crown-perch")
