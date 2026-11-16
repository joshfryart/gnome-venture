-- Toadstool Tuck (mm-toadstool-tuck), perch sprite 36x36. Haiku pass, hand-built at this size.
-- quirk: the fairy ring, here four moss dots either side of the stem.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("toadstool-tuck-perch", 36)

local EMBER = { "#6e2038", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }
local STEM  = { "#7a6a72", "#a9978a", "#cdb9a2", "#e6d6bf", "#fff4d6" }
local MOSS  = { "#24544a", "#3f9150", "#7cc35a" }

c:groundShadow(18, 31, 9, 2)

local stem = c:ellipse(18, 23, 5, 7)
stem:cut(c:rect(0, 0, 35, 14))
O.shade(c, stem, STEM, { R = 3, amb = .2, sep = STEM[1] })

local cap = c:ellipse(18, 12, 11, 8)
cap:cut(c:rect(0, 15, 35, 35))
O.shade(c, cap, EMBER, { R = 3, amb = .2, sep = EMBER[1] })
O.dots(c, { { 12, 9 }, { 13, 9 } }, STEM[5])
O.dots(c, { { 21, 6 }, { 23, 8 } }, STEM[5])
O.dot(c, 16, 5, EMBER[5])

c:eyeSmall(14, 20)
c:eyeSmall(20, 20)
O.dot(c, 18, 22, STEM[1])
O.dots(c, { { 16, 25 }, { 17, 26 }, { 18, 26 }, { 19, 25 } }, P.ink)

O.dots(c, { { 6, 30 }, { 8, 31 }, { 27, 31 }, { 29, 30 } }, MOSS[3])

O.done(c, "toadstool-tuck-perch")
