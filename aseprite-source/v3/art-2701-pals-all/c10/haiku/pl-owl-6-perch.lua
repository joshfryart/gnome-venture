-- Great White Plumelet (pl-owl-6), perch sprite 36x36. Hand-built at this size.
-- quirk: aurora-dipped tips at the bottom of the plume.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local O = dofile(dir .. "/_haiku.lua")
local HP, X, P, K = O.HP, O.X, O.P, O.K
local c = O.canvas("pl-owl-6-perch", 36)

local WHT = { "#7a8aa6", "#9aaac4", "#bccade", "#d8e2f0", "#ecf2fa", "#fafcff" }
local AURG = { "#1f4a3c", "#2f6b46", "#3f9150", "#62b05a", "#93cc6a", "#c4e07a" }

local quill = c:line({ { 18, 28 }, { 18, 34 } }, 1)
O.shade(c, quill, WHT, { R = 1, amb = .3, sep = WHT[1] })

local plume = c:ellipse(18, 15, 11, 11)
plume:add(c:ellipse(10, 22, 3, 3))
plume:add(c:ellipse(26, 22, 3, 3))
plume:add(c:ellipse(18, 25, 4, 3))
O.shade(c, plume, WHT, { R = 2, amb = .2, wrap = .3, sep = WHT[1] })

local tip = plume:copy()
tip:cut(c:rect(0, 0, 35, 20))
O.shade(c, tip, AURG, { R = 1, amb = .2, sep = AURG[1] })

c:eyeSmall(14, 12) c:eyeSmall(20, 12)
O.dots(c, { { 17, 17 }, { 18, 17 } }, WHT[1])

c:sparkle(31, 5)

O.done(c, "pl-owl-6-perch")
