-- hazard (32x32 trail map marker, Haiku pass). A red cloth warning flag on a dark wooden pole, a cream
-- exclamation mark on the flag, and crossed planks at the foot like a little barrier.
-- quirk: a small gold bell hangs from the flag's hem and sits right where a gnome would notice it.
local DIR = debug.getinfo(1, "S").source:match("^@(.*)[/\\][^/\\]*$")
local HP = dofile(DIR .. "/../../../lib/hp.lua")
local c = HP.canvas{ w = 32, h = 32, scale = 1, name = "hazard" }

local W = { hi = "#e8b982", base = "#b97a4a", shade = "#864c33", deep = "#51302b" }
local E = { hi = "#ff8a5c", base = "#e8493b", shade = "#b52e3f", deep = "#6e2038" }
local G = { hi = "#ffe38a", base = "#f5b82e", shade = "#d98322", deep = "#8f4a1f" }
local I = { hi = "#e2e0e6", base = "#aaa9b8", shade = "#74758c", deep = "#444663" }
local CREAM = "#fff4d6"

local function R(x0, y0, x1, y1, hex)
  for y = y0, y1 do for x = x0, x1 do c:put(x, y, hex) end end
end

-- crossed planks at the foot (drawn first, the pole crosses over them)
c:line({ { 6, 19 }, { 22, 28 } }, 2):each(function(x, y) c:put(x, y, W.base) end)
c:line({ { 22, 19 }, { 6, 28 } }, 2):each(function(x, y) c:put(x, y, W.shade) end)
c:put(21, 19, W.hi); c:put(7, 19, W.hi)

-- pole: lit left, shaded right, iron tip
c:put(9, 2, I.hi); c:put(10, 2, I.base)
R(9, 3, 9, 27, W.hi); R(10, 3, 10, 27, W.base)

-- flag, swallowtail on the right, red cloth with a lit top edge and a shaded underside
R(11, 4, 22, 4, E.hi)
R(11, 5, 23, 5, E.base); R(11, 6, 23, 6, E.base)
R(11, 7, 22, 7, E.base)
R(11, 8, 20, 8, E.base)
R(11, 9, 18, 9, E.base)
R(11, 10, 20, 10, E.base)
R(11, 11, 22, 11, E.base)
R(11, 12, 23, 12, E.base)
R(11, 13, 23, 13, E.shade)
R(11, 14, 22, 14, E.shade)
R(23, 5, 23, 6, E.shade); R(22, 12, 23, 12, E.shade)
R(18, 9, 18, 9, E.deep); R(20, 8, 20, 8, E.deep); R(20, 10, 20, 10, E.deep)
R(11, 14, 11, 14, E.deep)

-- cream exclamation mark
R(15, 6, 16, 10, CREAM)
R(15, 12, 16, 13, CREAM)

-- quirk: bell on a short iron string under the flag
c:put(18, 15, I.shade)
c:put(18, 16, G.hi); c:put(19, 16, G.base)
R(17, 17, 19, 17, G.base); c:put(17, 17, G.shade); c:put(19, 17, G.shade)
c:put(18, 18, G.deep)

c:finish{ outline = true }
HP.report(c)
HP.assertClean(c)
local out = app.params.out or (DIR .. "/")
c:save{ aseprite = out .. c.name .. ".aseprite", png = out .. c.name .. ".png", scale = 1 }
