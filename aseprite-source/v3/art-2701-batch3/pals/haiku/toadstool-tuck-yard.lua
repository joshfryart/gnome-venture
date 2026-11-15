-- Toadstool Tuck (mm-toadstool-tuck), yard sprite 64x64. Haiku pass, art-2701-batch3.
-- Bloomcaller, common. Red-capped toadstool with cream spots and a stubby stem that has a face.
-- quirk: a little fairy ring of moss dots pressed into the ground around the stem.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("toadstool-tuck-yard", 64)

local EMBER = { "#6e2038", "#8f2a3d", "#b52e3f", "#e8493b", "#ff8a5c", "#ffb08a" }
local STEM  = { "#7a6a72", "#a9978a", "#cdb9a2", "#e6d6bf", "#f6ecd9", "#fff4d6" }
local MOSS  = { "#24544a", "#3f9150", "#7cc35a", "#c4e07a" }

c:groundShadow(32, 58, 16, 3)

-- stem
local stem = c:ellipse(32, 44, 9, 12)
stem:cut(c:rect(0, 0, 63, 33))
O.shade(c, stem, STEM, { R = 5, amb = .2, wrap = .3, sep = STEM[1] })

-- cap: dome with cream spots
local cap = c:ellipse(32, 26, 21, 15)
cap:cut(c:rect(0, 33, 63, 63))
O.shade(c, cap, EMBER, { R = 6, amb = .2, wrap = .35, sep = EMBER[1] })
for _, s in ipairs({ { 24, 19, 2.5, 2 }, { 35, 14, 2, 1.6 }, { 43, 25, 2.5, 2 }, { 15, 28, 2, 1.6 }, { 32, 26, 1.8, 1.5 } }) do
  O.shade(c, c:ellipse(s[1], s[2], s[3], s[4]), STEM, { R = 1, amb = .3, sep = STEM[2] })
end

-- face on the stem
c:eyeLocked(25, 39)
c:eyeLocked(35, 39)
c:cheek(24, 46) c:cheek(38, 46)
O.dots(c, { { 31, 43 }, { 32, 43 } }, STEM[1])
O.dots(c, { { 30, 46 }, { 31, 47 }, { 32, 47 }, { 33, 46 } }, P.ink)

-- quirk: fairy ring of moss dots on the ground
O.dots(c, { { 9, 57 }, { 12, 60 }, { 20, 61 }, { 44, 61 }, { 52, 60 }, { 55, 57 } }, MOSS[3])
O.dots(c, { { 12, 59 }, { 52, 58 } }, MOSS[2])

O.done(c, "toadstool-tuck-yard")
