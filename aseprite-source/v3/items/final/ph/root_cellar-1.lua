-- root_cellar-1 (first draft, Sonnet). Tier 1: a small grassy mound with a plain round-top plank door and a dirt lip.
-- Series rule: tier 2 adds a stone frame and flag, tier 3 adds steps, beam, barrel.
-- quirk: a carrot top is poking out of the grass beside the door.
local A = dofile(debug.getinfo(1, "S").source:match("^@(.*)[/\\\\][^/\\\\]*$") .. "/../_helpers/_dD13.lua")
local c = A.new("root_cellar-1")
c:groundShadow(32, 58, 22, 3)
local m = A.mound(c, { cx = 32, yb = 54, rx = 23, ry = 25, ramp = "moss" })
A.speck(c, m, { "#c4e07a", "#3f9150" }, .1, 3)
A.lit(c, c:rect(8, 54, 55, 56), "wood", 1.6)
A.door(c, 32, 54, 7, 15, "wood")
-- tufts
for _, x in ipairs{ 22, 30, 40 } do c:px(x, 30 + (x % 3), "#c4e07a") c:px(x + 1, 29 + (x % 3), "#c4e07a") end
-- carrot top
A.sph(c, 15, 45, 2.6, "#f08a2a", { spec = "#ffe38a" })
A.needle(c, 15, 43, -1.9, 5, "#3f9150", "#7cc35a") A.needle(c, 15, 43, -1.2, 5, "#5ab050", "#c4e07a") A.needle(c, 15, 43, -1.57, 6, "#3f9150", "#7cc35a")
A.fin()
