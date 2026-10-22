local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local shaft = c:rrect(11, 24, 32, 40, 3)
local head = c:poly({ {30, 13}, {51, 32}, {30, 52} })
local all = shaft:copy():add(head)
local p = c:build{
  { "shaft", shaft, "water", { light = all } },
  { "head",  head,  "water", { light = all, stitch = true } },
}
c:seam({ {30, 25}, {30, 39} })
c:button(14, 30)

local t = c:save(O .. "aseprite/ico/ico-arrow-right.aseprite", O .. "png/ico/ico-arrow-right.png")
print(GV.report(t))
