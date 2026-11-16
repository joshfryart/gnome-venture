-- Pinfeather Hush (pl-owl-1), perch sprite 36x36. Hand-built at this size.
-- quirk: a cream hush line rises from its tip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-1-perch", 36)

local BRN = { "#2e2030", "#4e3848", "#7a5a52", "#9c7860", "#bc9a78", "#d8b898" }
local OCH = "#f5b82e"
local SHH = "#f6ead0"

local body = c:ellipse(17, 18, 9, 11)
body:add(c:poly{ { 20, 26 }, { 25, 31 }, { 22, 33 }, { 18, 29 } })
O.shade(c, body, BRN, { R = 2, amb = .2, wrap = .35, sep = BRN[1] })

c:eyeSmall(14, 15) c:eyeSmall(19, 15)
O.dots(c, { { 16, 20 }, { 17, 20 } }, OCH)

O.dots(c, { { 27, 5 }, { 28, 6 }, { 30, 4 }, { 31, 3 } }, SHH)

O.done(c, "pl-owl-1-perch")
