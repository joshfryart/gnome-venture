-- husk-hopper yard sprite (64x64), drawn from husk-hopper.def.lua. Run: aseprite -b --script-param out=<dir>/ --script husk-hopper-yard.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("husk-hopper-yard", 64)
dofile(dir .. "/husk-hopper.def.lua")(H)
H.done(app.params.out or "./", "husk-hopper-yard")
