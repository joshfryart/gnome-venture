-- sap-drip perch sprite (36x36), drawn from sap-drip.def.lua. Run: aseprite -b --script-param out=<dir>/ --script sap-drip-perch.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("sap-drip-perch", 36)
dofile(dir .. "/sap-drip.def.lua")(H)
H.done(app.params.out or "./", "sap-drip-perch")
