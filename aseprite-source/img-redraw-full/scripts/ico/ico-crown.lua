local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local body = c:poly({ {9, 47}, {9, 17}, {21, 31}, {32, 11}, {43, 31}, {55, 17}, {55, 47} })
local p = c:build{
  { "body",  body, "gold" },
  { "band",  c:rrect(8, 44, 56, 54, 2), "#c8902f" },
  { "jewel", c:ellipse(32, 34, 5, 5), "red" },
  { "tl",    c:ellipse(10, 15, 2.5, 2.5), "#f5cf6a", { flat = true } },
  { "tm",    c:ellipse(32, 9, 3, 3), "#f5cf6a" },
  { "tr",    c:ellipse(54, 15, 2.5, 2.5), "#f5cf6a", { flat = true } },
  { "gl",    c:ellipse(17, 49, 2, 2), "water", { flat = true } },
  { "gr",    c:ellipse(47, 49, 2, 2), "water", { flat = true } },
}
c:seam({ {11, 44}, {53, 44} }, { free = true })
local t = c:save(O .. "aseprite/ico/ico-crown.aseprite", O .. "png/ico/ico-crown.png")
print(GV.report(t))
