-- Canyon Crown (dw-canyon-crown), perch sprite 36x36. Haiku pass, c03. Hand-built at this size.
-- quirk: the middle peak of the crown has a small natural arch.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("canyon-crown-perch", 36)
local STONE = { "#444663", "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6", "#f4f2f6" }
local ROSE = { "#5a1f40", "#7d2c5e", "#c94f84", "#e0689a", "#f5809f", "#ffc4d8" }
c:groundShadow(17, 33, 9, 2)
O.flat(c, c:rect(11, 29, 13, 31), STONE[2], "foot")
O.flat(c, c:rect(21, 29, 23, 31), STONE[2], "foot")
local body = c:ellipse(17, 22, 9, 8)
O.shade(c, body, STONE, { sphere = { 14, 18, 9 }, amb = .2, wrap = .35, sep = STONE[1], rim = true })
local crown = c:rrect(8, 13, 26, 16, 1)
crown:add(c:poly({ { 9, 14 }, { 11, 6 }, { 14, 14 } }))
crown:add(c:poly({ { 14, 14 }, { 17, 3 }, { 20, 14 } }))
crown:add(c:poly({ { 20, 14 }, { 23, 6 }, { 25, 14 } }))
O.shade(c, crown, ROSE, { R = 1, sep = ROSE[1] })
for _, p in ipairs({ { 16, 7 }, { 17, 7 }, { 18, 7 }, { 16, 8 }, { 17, 8 }, { 18, 8 } }) do
  c.pix[p[2] * c.w + p[1]] = nil
  c.own[p[2] * c.w + p[1]] = nil
end
c:eyeSmall(13, 21)
c:eyeSmall(20, 21)
O.dots(c, { { 15, 25 }, { 16, 26 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)
O.done(c, "canyon-crown-perch")
