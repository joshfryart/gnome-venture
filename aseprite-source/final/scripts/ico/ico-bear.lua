local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local fur = "dusk"
local tan = GV.ramp("#8f7060")
local head = c:ellipse(32, 26, 12)
local ears = c:ellipse(21, 16, 5):add(c:ellipse(43, 16, 5))

c:build{
  { "tail",  c:ellipse(46.5, 44, 3.5),                          GV.ramp("#4a3048") },
  { "ears",  ears,                                              fur },
  { "feet",  c:ellipse(24, 47.5, 5.5, 3.5):add(c:ellipse(40, 47.5, 5.5, 3.5)), fur },
  { "body",  c:ellipse(32, 40, 15, 10),                         fur },
  { "belly", c:ellipse(32, 43, 8, 6),                           tan },
  { "head",  head,                                              fur },
  { "muzzle", c:ellipse(32, 31, 5.5, 4.5),                      tan },
}
-- inner ear discs (only where the head does not cover)
c:fill(c:ellipse(21, 15.5, 2.5):cut(head), "#8f7060")
c:fill(c:ellipse(43, 15.5, 2.5):cut(head), "#8f7060")
-- nose
c:fill(c:ellipse(32, 28.5, 2.5, 1.5), "#2a1a10")
c:px(31, 28, "#5e4a6a")
c:paint({ "u...u", ".uuu." }, 30, 32, { u = "#2a1a10" })
c:eye(23, 21); c:eye(36, 21)

local t = c:save(O .. "aseprite/ico/ico-bear.aseprite", O .. "png/ico/ico-bear.png")
print(GV.report(t))
