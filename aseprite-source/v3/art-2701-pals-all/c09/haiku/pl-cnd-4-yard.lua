-- Talon Clutch (pl-cnd-4), yard sprite 64x64. Four curled talons that grip the crag and never let go.
-- quirk: the four talons hook over the lip of the crag.
local dir = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local H = dofile(dir .. "/_h.lua")
local P = H.P
local c = H.canvas("pl-cnd-4-yard", 64)

c:part(c:rrect(6, 52, 58, 60, 3), "stone")
c:part(c:ellipse(32, 30, 13, 12), "dusk")
for _, x in ipairs({ 20, 28, 36, 44 }) do
  c:part(c:rect(x - 1, 40, x, 50), "gold")
  c:part(c:rect(x, 50, x + 2, 51), "gold")
end
c:eyeLocked(25, 27)
c:eyeLocked(34, 27)
H.save(c, "pl-cnd-4-yard")
