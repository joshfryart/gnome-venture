local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:ellipse(31.5, 40, 20, 15):cut(c:rect(0, 0, 63, 26))
body:add(c:rrect(15, 27, 48, 34, 3))
local lid = c:ellipse(31.5, 28, 17, 12):cut(c:rect(0, 29, 63, 63))
lid:add(c:rrect(13, 25, 50, 30, 2))

local p = c:build{
  { "foot",  c:rrect(19, 51, 44, 57, 2), "#3e2f66" },
  { "body",  body, "#7a5cc0" },
  { "lid",   lid, "#a894dc" },
  { "knob",  c:ellipse(31.5, 13, 4, 3.5), "#f5cf6a" },
  { "label", c:ellipse(31.5, 42, 10, 8), "#f4f0e0", { pale = true, gloss = false } },
}
-- corm
c:fill(c:ellipse(31.5, 44, 5, 4), "#7a5cc0")
c:fill(c:ellipse(31.5, 46, 4, 2):cut(c:rect(0, 0, 63, 45)), "#4e3a8a")
c:px(29, 42, "#a894dc"); c:px(30, 42, "#a894dc")
-- sprout
c:fill(c:line({ {31,40}, {31,37} }, 2), "#58a03e")
c:fill(c:poly({ {32,38}, {37,35}, {36,37} }):add(c:rect(32, 37, 34, 38)), "#58a03e")

c:seam({ {15,30}, {48,30} })
c:button(30, 19)

local t = c:save(O .. "aseprite/ph/field-gladiolus-seed.aseprite", O .. "png/ph/field-gladiolus-seed.png")
print(GV.report(t))
