-- signpost (32x32 trail map marker, Haiku pass). A tall wooden post on a two-plank foot, carrying two
-- arrow boards: the upper one points right, the lower one points left, each with a gold nail.
-- quirk: a red ribbon is knotted at the top of the post and flutters off to one side.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = "signpost" }

local W = { hi = "#e8b982", base = "#b97a4a", shade = "#864c33", deep = "#51302b" }
local G = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }
local E = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }

local function R(x0, y0, x1, y1, hex)
  for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end
end

-- post: lit left, shaded right, pointed top
c:put(15, 6, W.hi)
R(14, 7, 16, 7, W.base)
R(14, 8, 14, 26, W.hi); R(15, 8, 15, 26, W.base); R(16, 8, 16, 26, W.shade)
c:put(15, 15, W.shade); c:put(15, 21, W.shade)

-- two-plank foot
R(11, 27, 19, 27, W.hi); R(11, 28, 19, 28, W.shade)

-- upper board, arrow pointing right
R(13, 9, 21, 9, W.hi)
R(13, 10, 23, 10, W.base)
R(13, 11, 25, 11, W.base); c:put(25, 11, W.shade)
R(13, 12, 23, 12, W.base)
R(13, 13, 21, 13, W.shade)
R(15, 11, 19, 11, W.shade) -- board grain
c:put(14, 10, G.base); c:put(14, 10, G.hi)

-- lower board, arrow pointing left
R(9, 16, 16, 16, W.hi)
R(7, 17, 16, 17, W.base)
R(5, 18, 16, 18, W.base); c:put(5, 18, W.shade)
R(7, 19, 16, 19, W.base)
R(9, 20, 16, 20, W.shade)
R(10, 18, 13, 18, W.shade) -- board grain
c:put(15, 18, G.hi)

-- quirk: ribbon knotted at the top of the post, fluttering up and right
c:put(16, 7, E.base)
c:put(17, 6, E.hi); c:put(18, 5, E.hi); c:put(19, 5, E.base); c:put(19, 4, E.shade)
c:put(17, 8, E.shade); c:put(18, 7, E.base)

c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
local out = app.params.out or (DIR .. "/")
c:save{ aseprite = out .. c.name .. ".aseprite", png = out .. c.name .. ".png", scale = 1 }
