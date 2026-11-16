-- bark-badger perch sprite (36x36), drawn from bark-badger.def.lua. Run: aseprite -b --script-param out=<dir>/ --script bark-badger-perch.lua
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local C = dofile(dir .. "/_common.lua")
local H = C.new("bark-badger-perch", 36)
dofile(dir .. "/bark-badger.def.lua")(H)
H.done(app.params.out or "./", "bark-badger-perch")
