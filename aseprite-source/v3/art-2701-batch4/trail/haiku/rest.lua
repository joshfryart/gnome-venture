-- rest (32x32 trail map marker, Haiku pass). A plank bench with a back rail and posts that double as
-- legs, a rolled moss bedroll tied with a gold cord on the seat, and a tall iron-framed lantern on its
-- own wooden post at the right, glowing gold.
-- quirk: a little cream moth circles the lantern.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = "rest" }

local W = { hi = "#e8b982", base = "#b97a4a", shade = "#864c33", deep = "#51302b" }
local M = { hi = "#c4e07a", base = "#7cc35a", shade = "#3f9150", deep = "#24544a" }
local G = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }
local I = { hi = "#e2e0e6", base = "#aaa9b8", shade = "#74758c", deep = "#444663" }
local CREAM = "#fff4d6"

local function R(x0, y0, x1, y1, hex)
  for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end
end

-- bench: back rail (hi top, shade bottom), posts (also legs), seat (hi lip, base, shade underside)
R(3, 8, 20, 8, W.hi); R(3, 9, 20, 9, W.shade)
R(3, 10, 3, 25, W.hi); R(4, 10, 4, 25, W.base)
R(18, 10, 18, 25, W.base); R(19, 10, 19, 25, W.shade)
R(3, 25, 4, 25, W.deep); R(18, 25, 19, 25, W.deep)
R(3, 14, 20, 14, W.hi); R(3, 15, 20, 15, W.base); R(3, 16, 20, 16, W.shade)
R(7, 15, 11, 15, W.shade); R(14, 15, 17, 15, W.shade) -- seat grain

-- rolled bedroll on the left of the seat, tied with a gold cord
R(5, 10, 13, 13, M.base)
R(6, 10, 12, 10, M.hi)
R(6, 13, 12, 13, M.shade)
R(5, 11, 5, 12, M.shade)
R(13, 10, 13, 13, M.deep)
c:put(12, 11, M.hi)
R(9, 10, 9, 13, G.base); c:put(9, 10, G.hi); c:put(9, 13, G.shade)

-- lantern: iron cap and frame, gold glass with a cream core, on a short wooden post
c:put(22, 1, I.base); c:put(23, 1, I.base)
R(21, 2, 24, 2, I.deep)
R(20, 3, 25, 3, I.shade)
R(21, 4, 24, 9, G.base)
R(21, 4, 21, 9, G.hi)
R(24, 4, 24, 9, G.shade)
R(22, 5, 23, 8, CREAM)
R(20, 4, 20, 10, I.shade)
R(25, 4, 25, 10, I.deep)
R(20, 10, 25, 10, I.deep)
R(22, 11, 22, 23, W.base); R(23, 11, 23, 23, W.shade)
R(21, 24, 24, 24, W.shade); R(20, 25, 25, 25, W.deep)

-- quirk: a moth circling the lantern
c:put(15, 2, CREAM); c:put(17, 2, CREAM)
c:put(16, 3, CREAM)

c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
local out = app.params.out or (DIR .. "/")
c:save{ aseprite = out .. c.name .. ".aseprite", png = out .. c.name .. ".png", scale = 1 }
