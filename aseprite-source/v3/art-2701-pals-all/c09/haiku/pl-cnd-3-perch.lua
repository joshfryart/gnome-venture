-- Updraft Fluff (pl-cnd-3), perch sprite 36x36, hand-built at this size. Quirk: one wind dash trails it.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-cnd-3-perch", 36)

local body = c:ellipse(18, 20, 9, 7)
body:add(c:ellipse(12, 15, 3, 3))
body:add(c:ellipse(22, 14, 4, 4))
c:part(body, "skinA")
c:eyeSmall(14, 20)
c:eyeSmall(20, 20)
c:fillMask(c:line({ { 3, 15 }, { 7, 13 }, { 10, 15 } }, 1), P.sky.base)
H.save(c, "pl-cnd-3-perch")
