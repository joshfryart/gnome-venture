local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 51, 20, 7):cut(c:rect(0, 56, 63, 63))
mound:add(c:rrect(12, 50, 51, 56, 3))
local top = c:ellipse(31.5, 49, 15, 3.5)
-- seed leaves: bulging teardrops in a V
local lleaf = c:poly({ { 31, 48 }, { 25, 46 }, { 20, 42 }, { 18, 36 }, { 20, 34 }, { 26, 35 }, { 30, 40 }, { 32, 46 } })
local rleaf = c:poly({ { 32, 48 }, { 38, 46 }, { 43, 42 }, { 45, 36 }, { 43, 34 }, { 37, 35 }, { 33, 40 }, { 31, 46 } })
local p = c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false, light = mound } },
  { "rleaf", rleaf, GV.ramp("#58a03e"), { gloss = { 38, 37 } } },
  { "lleaf", lleaf, "moss", { gloss = { 22, 37 } } },
}
c:fill(c:line({ { 30, 45 }, { 26, 41 }, { 22, 37 } }, 1), "#4a8a3e")
c:fill(c:line({ { 34, 45 }, { 38, 41 }, { 41, 38 } }, 1), "#3f7a30")
local t = c:save(O .. "aseprite/ph/stage-spice-1.aseprite", O .. "png/ph/stage-spice-1.png")
print(GV.report(t))
