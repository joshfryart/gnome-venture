-- Talon Clutch (pl-cnd-4), perch sprite 36x36, hand-built at this size. Quirk: four talons on a crag lip.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local c = H.canvas("pl-cnd-4-perch", 36)

c:part(c:rrect(3, 28, 33, 32, 1), "stone")
c:part(c:ellipse(18, 15, 8, 7), "dusk")
for _, x in ipairs({ 12, 16, 20, 24 }) do
  c:part(c:rect(x, 20, x + 1, 27), "gold")
end
c:eyeSmall(14, 13)
c:eyeSmall(20, 13)
H.save(c, "pl-cnd-4-perch")
