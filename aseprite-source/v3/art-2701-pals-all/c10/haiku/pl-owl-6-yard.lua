-- Great White Plumelet (pl-owl-6), yard sprite 64x64. Wayfinder, rare. The great white owl's finest feather, dipped in aurora light.
-- Fancier than a common pal: a fluffy white plume with green and violet aurora tips and sparkles.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-6-yard", 64)

local WHT = { "#7a8aa6", "#9aaac4", "#bccade", "#d8e2f0", "#ecf2fa", "#fafcff" }
local AURG = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }
local VIO  = { "#3a2360", "#5b3a8c", "#7e58b8", "#a486d8", "#c9b3ea", "#e4d8f4" }

-- quill
local quill = c:line({ { 32, 46 }, { 32, 62 } }, 1.2)
O.shade(c, quill, WHT, { R = 1, amb = .3, sep = WHT[1] })

-- fluffy plume
local plume = c:ellipse(32, 30, 17, 18)
plume:add(c:ellipse(20, 38, 6, 6))
plume:add(c:ellipse(44, 38, 6, 6))
plume:add(c:ellipse(32, 46, 8, 6))
O.shade(c, plume, WHT, { R = 4, amb = .2, wrap = .3, sep = WHT[1] })

-- aurora tips over the lower plume
local tip = plume:copy()
tip:cut(c:rect(0, 0, 63, 43))
O.shade(c, tip, AURG, { R = 3, amb = .2, sep = AURG[1] })
local vtip = plume:copy()
vtip:cut(c:rect(0, 0, 63, 53))
O.shade(c, vtip, VIO, { R = 2, amb = .2, sep = VIO[1] })

-- hook knob: a curled quill tip on top
local hook = c:line({ { 32, 12 }, { 32, 6 }, { 38, 5 } }, 1.2)
O.shade(c, hook, WHT, { R = 1, amb = .3, sep = WHT[1] })

c:eyeLocked(24, 25)
c:eyeLocked(36, 25)
O.dots(c, { { 30, 33 }, { 31, 34 }, { 32, 34 }, { 33, 33 } }, WHT[1])

c:sparkle(52, 14)
c:sparkle(10, 46)

O.done(c, "pl-owl-6-yard")
