local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local kern = c:ellipse(31.5, 35, 14, 17)
local crown = c:ellipse(31.5, 35, 15, 18):clip(c:rect(0, 0, 63, 29))
crown:cut(c:ellipse(31.5, 33, 7, 5))
local p = c:build{
  { "stem",   c:rrect(30, 11, 33, 20, 1), "#2f5a2a", { flat = true } },
  { "kernel", kern, GV.ramp("#b0bc66") },
  { "crown",  crown, GV.ramp("#dcb06a"), { stitch = false } },
}
-- shell lip ridge
c:seam({ {19, 26}, {44, 26} })
-- centre seam
c:fill(c:rect(31, 34, 32, 48), "#4a8a3e")
-- shell smile
c:fill(c:line({ {25, 42}, {28, 45}, {31, 46}, {32, 46}, {35, 45}, {38, 42} }, 2), "#d9a660")
local t = c:save(O .. "aseprite/ph/pistachio.aseprite", O .. "png/ph/pistachio.png")
print(GV.report(t))
