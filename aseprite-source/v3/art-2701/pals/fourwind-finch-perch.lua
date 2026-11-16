-- fourwind-finch perch sprite (36x36), drawn from fourwind-finch.def.lua. Run: aseprite -b --script-param out=<dir>/ --script fourwind-finch-perch.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("fourwind-finch-perch", 36)
dofile(dir .. "/fourwind-finch.def.lua")(H)
H.done(app.params.out or "./", "fourwind-finch-perch")
