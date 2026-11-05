-- gather satchel-front.png: transparent 480x270 overlay. Shared geometry in satchel.lua.
local d = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(d .. "/../lib/hp.lua")
local S = dofile(d .. "/satchel.lua")
local c = HP.canvas{ w = 480, h = 270, scale = 1, name = "satchel-front" }
S.front(c)
c:save{ aseprite = d .. "/out/satchel-front.aseprite", png = d .. "/out/satchel-front.png", scale = 1 }
