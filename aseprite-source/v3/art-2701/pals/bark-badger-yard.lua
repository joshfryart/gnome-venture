-- bark-badger yard sprite (64x64), drawn from bark-badger.def.lua. Run: aseprite -b --script-param out=<dir>/ --script bark-badger-yard.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("bark-badger-yard", 64)
dofile(dir .. "/bark-badger.def.lua")(H)
H.done(app.params.out or "./", "bark-badger-yard")
