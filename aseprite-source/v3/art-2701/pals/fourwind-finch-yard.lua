-- fourwind-finch yard sprite (64x64), drawn from fourwind-finch.def.lua. Run: aseprite -b --script-param out=<dir>/ --script fourwind-finch-yard.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("fourwind-finch-yard", 64)
dofile(dir .. "/fourwind-finch.def.lua")(H)
H.done(app.params.out or "./", "fourwind-finch-yard")
