-- usage: aseprite -b --script npc25/gen_draft.lua --script-param species=hedgehog
local root = app.params.root or "npc25"
local name = app.params.species or "hedgehog"
local N = dofile(root .. "/lib/npc25.lua")
local sp = dofile(root .. "/lib/species_" .. name .. ".lua")
local out = root .. "/" .. name
app.fs.makeDirectory(out)
N.build(sp, out, {"front", "back", "side"})
print("generated " .. name)
