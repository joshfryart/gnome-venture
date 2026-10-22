local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local post = GV.ramp("#8a4f2a")

c:build{
  { "post",  c:rrect(15, 8, 23, 56, 3), post },
  { "leg",   c:rrect(42, 40, 50, 56, 3), post },
  { "panel", c:rrect(19, 10, 42, 29, 2), "wood", { gloss = {23,13} } },
  { "seat",  c:rrect(13, 31, 51, 40, 4), "wood", { gloss = {18,33} } },
}

-- top finial cap on post
c:part(c:rrect(14, 6, 24, 10, 2), post, { gloss = false })

local t = c:save(O .. "aseprite/ico/ico-chair.aseprite", O .. "png/ico/ico-chair.png")
print(GV.report(t))
