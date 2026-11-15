-- Tide Tuck (ss-tide-tuck), perch sprite 36x36. Haiku pass, c01. Hand-built at this size.
-- quirk: tucked into the sand, a wave foam line across the base.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("ss-tide-tuck-perch", 36)

local SAND = { "#5a3e2a", "#8f6b3e", "#c49a5c", "#e8c98a", "#f5e0b0", "#fff4d6" }
local SHEL = { "#8f3a3a", "#b5524a", "#d9735a", "#f08f7a", "#f8b8a0", "#ffd9c8" }
local SEA  = { "#2a4a7a", "#3a86b0", "#5fc4c8", "#b6f0e0", "#e4f6ff" }
local INK  = P.ink

local mound = c:ellipse(18, 21, 12, 7)
O.shade(c, mound, SAND, { R = 3 })

local shell = c:ellipse(18, 15, 6, 4)
shell:cut(c:rect(0, 18, 35, 35))
O.shade(c, shell, SHEL, { R = 2, sep = SHEL[1] })

c:eyeSmall(15, 19)
c:eyeSmall(20, 19)
O.dot(c, 18, 22, SAND[1])
O.dots(c, { {16,24},{17,24},{18,24},{19,24} }, SAND[1])

local wave = c:poly{ {0,25},{6,23},{12,25},{18,23},{24,25},{30,23},{36,25},{36,36},{0,36} }
O.shade(c, wave, SEA, { R = 2, sep = SEA[1] })
O.dots(c, { {3,25},{4,25},{11,26},{22,25},{23,25},{31,25},{32,25} }, SEA[5])

O.done(c, "ss-tide-tuck-perch")
