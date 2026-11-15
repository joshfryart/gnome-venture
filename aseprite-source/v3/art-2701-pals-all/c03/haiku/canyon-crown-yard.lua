-- Canyon Crown (dw-canyon-crown), yard sprite 64x64. Haiku pass, c03.
-- Rootwarden, uncommon. Grey stone blob wearing a rose-red crown of three cliff peaks.
-- quirk: the middle peak has a small natural arch through it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("canyon-crown-yard", 64)

local STONE = { "#444663", "#74758c", "#aaa9b8", "#c8c6d2", "#e2e0e6", "#f4f2f6" }
local ROSE  = { "#5a1f40", "#7d2c5e", "#c94f84", "#e0689a", "#f5809f", "#ffc4d8" }

c:groundShadow(32, 58, 17, 3)

-- stubby feet
O.flat(c, c:rect(21, 53, 26, 56), STONE[2], "foot")
O.flat(c, c:rect(38, 53, 43, 56), STONE[2], "foot")

-- rock body
local body = c:ellipse(32, 40, 16, 13)
O.shade(c, body, STONE, { sphere = { 27, 34, 15 }, amb = .2, wrap = .35, sep = STONE[1], rim = true, bounce = "#5f9ad0", bmax = 2 })
-- strata lines across the body
O.mark(c, { { 20, 44 }, { 21, 44 }, { 22, 44 }, { 42, 46 }, { 43, 46 }, { 44, 46 } }, STONE[1])

-- crown: a rose-red band with three peaks
local peakL = c:poly({ { 19, 27 }, { 22, 14 }, { 26, 27 } })
local peakM = c:poly({ { 27, 27 }, { 32, 9 }, { 37, 27 } })
local peakR = c:poly({ { 38, 27 }, { 42, 14 }, { 45, 27 } })
local crown = c:rrect(18, 24, 46, 29, 1)
crown:add(peakL):add(peakM):add(peakR)
O.shade(c, crown, ROSE, { R = 1, sep = ROSE[1] })

-- quirk: natural arch cut through the middle peak
local arch = c:rect(31, 15, 33, 17)
arch:cut(c:rect(30, 0, 34, 14))
for _, p in ipairs({ { 30, 15 }, { 31, 15 }, { 32, 15 }, { 33, 15 }, { 30, 16 }, { 31, 16 }, { 32, 16 }, { 33, 16 } }) do
  c.pix[p[2] * c.w + p[1]] = nil
  c.own[p[2] * c.w + p[1]] = nil
end

-- face: locked eyes, cheeks, smile
c:eyeLocked(23, 36)
c:eyeLocked(36, 36)
c:cheek(20, 42)
c:cheek(39, 42)
O.dots(c, { { 28, 44 }, { 29, 45 }, { 30, 45 }, { 31, 45 }, { 32, 45 }, { 33, 45 }, { 34, 44 } }, P.ink)

O.done(c, "canyon-crown-yard")
