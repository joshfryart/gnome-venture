-- acorn-nip perch sprite (36x36), drawn from acorn-nip.def.lua. Run: aseprite -b --script-param out=<dir>/ --script acorn-nip-perch.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("acorn-nip-perch", 36)
dofile(dir .. "/acorn-nip.def.lua")(H)
H.done(app.params.out or "./", "acorn-nip-perch")
