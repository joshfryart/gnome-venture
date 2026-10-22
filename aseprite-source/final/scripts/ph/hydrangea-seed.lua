local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 38, 17, 14):cut(c:rect(0, 50, 63, 63))
local lid = c:ellipse(31.5, 22, 13, 7):cut(c:rect(0, 23, 63, 63))
local p = c:build{
  { "foot", c:rrect(23, 46, 40, 51, 2), "#2f6290" },
  { "body", body, "#8fcbd8" },
  { "neck", c:rrect(19, 21, 44, 26, 2), "#3f8fb0" },
  { "lid", lid, "#c8ecdc" },
  { "knob", c:ellipse(31.5, 13.5, 2.5, 2.5), "gold" },
  { "seed", c:ellipse(31.5, 40, 6, 7):cut(c:rect(0,33,63,34)):add(c:ellipse(31.5,37,4,4)), "#e46a9b", { gloss = { 29, 37 } } },
  { "stem", c:rect(31, 30, 32, 34), "moss", { flat = true } },
  { "leaf", c:ellipse(35, 31, 2, 1.5), "#7ab55c", { flat = true } },
}
c:seam({ { 20, 24 }, { 43, 24 } })
local t = c:save(O .. "aseprite/ph/hydrangea-seed.aseprite", O .. "png/ph/hydrangea-seed.png")
print(GV.report(t))
