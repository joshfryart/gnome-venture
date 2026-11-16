-- acorn-nip yard sprite (64x64), drawn from acorn-nip.def.lua. Run: aseprite -b --script-param out=<dir>/ --script acorn-nip-yard.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("acorn-nip-yard", 64)
dofile(dir .. "/acorn-nip.def.lua")(H)
H.done(app.params.out or "./", "acorn-nip-yard")
