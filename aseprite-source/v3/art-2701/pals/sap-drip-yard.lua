-- sap-drip yard sprite (64x64), drawn from sap-drip.def.lua. Run: aseprite -b --script-param out=<dir>/ --script sap-drip-yard.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("sap-drip-yard", 64)
dofile(dir .. "/sap-drip.def.lua")(H)
H.done(app.params.out or "./", "sap-drip-yard")
