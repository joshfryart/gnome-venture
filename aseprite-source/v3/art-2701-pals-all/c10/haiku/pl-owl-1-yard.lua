-- Pinfeather Hush (pl-owl-1), yard sprite 64x64. Seedkeeper, common. A soft brown feather with a face.
-- quirk: a cream hush line drifts up from its tip (it hushes anything trying to hoot).
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-1-yard", 64)

local BRN = { "#2e2030", "#4e3848", "#7a5a52", "#9c7860", "#bc9a78", "#d8b898" }
local OCH = "#f5b82e"
local SHH = "#f6ead0"

local body = c:ellipse(30, 30, 15, 19)
body:add(c:poly{ { 36, 42 }, { 44, 52 }, { 48, 60 }, { 40, 56 }, { 30, 50 } })
O.shade(c, body, BRN, { R = 4, amb = .2, wrap = .35, sep = BRN[1] })
local tufts = {}
body:each(function(x, y) if O.H(x, y, 5) > .8 then tufts[#tufts + 1] = { x, y } end end)
O.mark(c, tufts, BRN[5])

c:eyeLocked(21, 26)
c:eyeLocked(33, 26)
O.dots(c, { { 27, 33 }, { 28, 34 }, { 29, 34 }, { 30, 33 } }, OCH)

-- quirk: hush line rising from the tip
O.dots(c, { { 46, 16 }, { 47, 15 }, { 48, 14 }, { 50, 12 }, { 51, 11 }, { 52, 10 }, { 54, 9 }, { 55, 8 } }, SHH)

O.done(c, "pl-owl-1-yard")
