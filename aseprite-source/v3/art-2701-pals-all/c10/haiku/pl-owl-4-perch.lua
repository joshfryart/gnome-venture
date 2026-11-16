-- Owlet Peep (pl-owl-4), perch sprite 36x36. Hand-built at this size.
-- quirk: a peep mark rises from the beak.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-4-perch", 36)

local TAN = { "#4a3530", "#6e5040", "#9a7656", "#c4a078", "#e0c8a0", "#f2e4c8" }
local CRM = { "#8a6a4a", "#b08c66", "#d4b08a", "#e6cca8", "#f2e2c8", "#f8f0e0" }
local OCH = "#f5b82e"

local body = c:ellipse(18, 21, 10, 11)
O.shade(c, body, TAN, { sphere = { 16, 19, 10 }, amb = .2, wrap = .3, sep = TAN[1] })
local tufts = c:poly{ { 10, 13 }, { 8, 5 }, { 14, 11 } }
tufts:add(c:poly{ { 26, 13 }, { 28, 5 }, { 22, 11 } })
O.shade(c, tufts, TAN, { R = 1, amb = .25, sep = TAN[1] })

local face = c:ellipse(18, 15, 7, 6)
O.shade(c, face, CRM, { R = 2, amb = .3, sep = CRM[1] })

c:eyeSmall(14, 14) c:eyeSmall(20, 14)
O.dots(c, { { 14, 13 }, { 15, 13 }, { 20, 13 }, { 21, 13 } }, TAN[1])
O.dots(c, { { 17, 18 }, { 18, 19 } }, OCH)

O.dots(c, { { 24, 19 }, { 26, 17 } }, P.cream)

O.done(c, "pl-owl-4-perch")
