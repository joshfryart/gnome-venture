local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local blade = c:ellipse(31.5, 35, 12.5, 18):clip(c:rect(19, 35, 44, 63))
c:build{
  { "shaft",  c:rect(29, 14, 34, 33), "#b6814d" },
  { "grip",   c:rrect(22, 11, 41, 16, 2), "#b6814d" },
  { "blade",  blade, "#d6c9b6", { gloss = { 23, 39 } } },
  { "ledge",  c:rrect(19, 33, 44, 36, 1), "#8b8f96", { gloss = false } },
  { "socket", c:rrect(28, 29, 35, 40, 1), "#8b8f96", { gloss = false } },
}
c:paint({ "ss", "s." }, 23, 38, { s = "#fff3c8" })
local t = c:save(O .. "aseprite/ico/ico-spade.aseprite", O .. "png/ico/ico-spade.png")
print(GV.report(t))
