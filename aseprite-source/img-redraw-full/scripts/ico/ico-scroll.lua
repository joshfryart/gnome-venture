local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
c:build{
  { "sheet", c:rect(17, 17, 46, 46), "#f8eed2" },
  { "top",   c:rrect(12, 12, 51, 21, 5), "#d9a660" },
  { "bot",   c:rrect(12, 42, 51, 51, 5), "#d9a660" },
  { "capTL", c:rrect(13, 14, 16, 19, 1), "#b07a45", { flat = true } },
  { "capTR", c:rrect(47, 14, 50, 19, 1), "#b07a45", { flat = true } },
  { "capBL", c:rrect(13, 44, 16, 49, 1), "#b07a45", { flat = true } },
  { "capBR", c:rrect(47, 44, 50, 49, 1), "#b07a45", { flat = true } },
}
c:fill(c:rect(22, 25, 41, 28), "#4a2c1a")
c:fill(c:rect(22, 33, 36, 36), "#4a2c1a")
local t = c:save(O .. "aseprite/ico/ico-scroll.aseprite", O .. "png/ico/ico-scroll.png")
print(GV.report(t))
