local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local outer = c:poly({ { 32, 7 }, { 54, 19 }, { 51, 46 }, { 32, 57 }, { 13, 46 }, { 10, 19 } })
local inner = c:poly({ { 32, 14 }, { 46, 22 }, { 43, 40 }, { 32, 48 }, { 21, 40 }, { 18, 22 } })
local all = outer:copy()

c:build{
  { "shell", outer, "gold" },
  { "inner", inner, GV.ramp("#b07a10"), { light = all, gloss = false } },
}
-- lit left facets of the outer band, shaded right band
local G = GV.R.gold
c:fill(c:poly({ { 32, 9 }, { 18, 21 }, { 13, 21 }, { 13, 25 } }):clip(outer):cut(inner):cut(c:rect(0, 0, 13, 63)), G.rim)
c:fill(c:poly({ { 44, 41 }, { 50, 44 }, { 32, 55 }, { 32, 49 } }):clip(outer):cut(inner), G.shade)
-- facet lines from inner corners to outer corners
local fl = c:mask()
fl:add(c:line({ { 18, 22 }, { 12, 20 } }, 1)); fl:add(c:line({ { 46, 22 }, { 52, 20 } }, 1))
fl:add(c:line({ { 21, 40 }, { 15, 45 } }, 1)); fl:add(c:line({ { 43, 40 }, { 49, 45 } }, 1))
c:fill(fl:clip(outer:shrink(2)), G.shade)
-- centre ridge, lit left column
c:fill(c:rect(31, 9, 32, 54):clip(outer:shrink(2)), "#b8661a")
c:fill(c:rect(31, 15, 31, 46), "#d0862a")
-- core glow
c:fill(c:rrect(29, 27, 34, 32, 1), "#f5cf6a")
c:fill(c:rect(30, 28, 33, 31), "#fff1c8")
-- ember cracks
local E = "#d6322b"
c:fill(c:line({ { 22, 24 }, { 24, 27 }, { 22, 30 }, { 25, 33 } }, 2), E)
c:fill(c:line({ { 41, 29 }, { 38, 32 }, { 41, 35 }, { 38, 38 } }, 2), E)
c:fill(c:line({ { 26, 38 }, { 29, 41 }, { 26, 44 } }, 2), E)
c:px(22, 24, "#f08a24"); c:px(41, 29, "#f08a24"); c:px(26, 38, "#f08a24")
local t = c:save(D .. "img-redraw-full/aseprite/ph/ember-shell.aseprite", D .. "img-redraw-full/png/ph/ember-shell.png")
print(GV.report(t))
