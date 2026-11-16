-- husk-hopper perch sprite (36x36), drawn from husk-hopper.def.lua. Run: aseprite -b --script-param out=<dir>/ --script husk-hopper-perch.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("husk-hopper-perch", 36)
dofile(dir .. "/husk-hopper.def.lua")(H)
H.done(app.params.out or "./", "husk-hopper-perch")
