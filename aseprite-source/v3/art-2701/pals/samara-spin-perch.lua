-- samara-spin perch sprite (36x36), drawn from samara-spin.def.lua. Run: aseprite -b --script-param out=<dir>/ --script samara-spin-perch.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("samara-spin-perch", 36)
dofile(dir .. "/samara-spin.def.lua")(H)
H.done(app.params.out or "./", "samara-spin-perch")
