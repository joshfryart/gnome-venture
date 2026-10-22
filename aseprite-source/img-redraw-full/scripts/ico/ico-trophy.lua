local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local hL = c:line({ {20,15}, {15,15}, {13,18}, {13,23}, {16,28}, {21,31} }, 3)
local hR = c:line({ {43,15}, {48,15}, {50,18}, {50,23}, {47,28}, {42,31} }, 3)
local bowl = c:rect(17, 11, 46, 20):add(c:ellipse(31.5, 20, 14.5, 16):cut(c:rect(0, 0, 63, 19)))
local stem = c:rect(28, 35, 35, 44):add(c:rect(26, 41, 37, 44))
local plinth = c:rrect(19, 44, 44, 51, 2)
c:build{
  { "handles", hL:add(hR), GV.ramp("#d0862a"), { gloss = false } },
  { "bowl", bowl, "gold", { gloss = { 21, 16 } } },
  { "stem", stem, "gold", { gloss = false } },
  { "plinth", plinth, "wood", { gloss = false } },
}
c:fill(c:rect(20, 13, 43, 13), "#f5cf6a")
c:fill(c:rect(19, 15, 44, 15), "#d0862a")
c:px(25, 13, "#fff1c8")
c:paint({ ".g.", "ggg", ".g." }, 30, 22, { g = "#b8661a" })
local t = c:save(O .. "aseprite/ico/ico-trophy.aseprite", O .. "png/ico/ico-trophy.png")
print(GV.report(t))
