local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local brim = c:ellipse(32, 48, 24, 5.5)
local cone = c:poly({ {12, 48}, {16, 30}, {23, 18}, {30, 11}, {38, 7}, {47, 8}, {48, 13}, {41, 13}, {39, 19}, {44, 30}, {52, 48} })
local band = c:rrect(13, 40, 51, 48, 3)
local lip = brim:copy():clip(c:rect(0, 49, 63, 63))
local flask = c:poly({ {29, 22}, {35, 22}, {35, 28}, {41, 38}, {23, 38}, {29, 28} })
local p = c:build{
  { "brim", brim, GV.ramp("#4e3a8a", { rim = "#7b66b4" }) },
  { "cone", cone, GV.ramp("#7a5cc0") },
  { "band", band, GV.ramp("#4e3a8a", { rim = "#7b66b4" }) },
  { "lip", lip, GV.ramp("#4e3a8a", { rim = "#7b66b4" }), { rim = false, gloss = false } },
  { "flask", flask, GV.ramp("#a9d6ea"), { gloss = { 30, 24 } } },
  { "bub1", c:ellipse(31.5, 18.5, 1.5, 1.5), GV.ramp("#f4f0e0"), { flat = true } },
  { "bub2", c:ellipse(35.5, 15.5, 1, 1), GV.ramp("#f4f0e0"), { flat = true } },
  { "bob", c:ellipse(49.5, 10.5, 3.5, 3.5), "gold" },
}
c:fill(c:rect(0, 33, 63, 37):clip(flask:shrink(1)), "#7ab55c")
c:fill(c:rect(0, 33, 63, 33):clip(flask:shrink(1)), "#a4b86a")
c:fill(c:rect(28, 22, 36, 23), "#968f96")
c:seam({ {16, 44}, {49, 44} })
c:ground(32, 54, 23, 2.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/hat-brewroot.aseprite", O .. "png/ph/hat-brewroot.png")
print(GV.report(t))
