local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tray = c:ellipse(31.5, 29, 21, 18):cut(c:rect(0, 0, 63, 29))
local dome = c:ellipse(31.5, 30, 17, 14):cut(c:rect(0, 31, 63, 63))
local rim = c:rrect(10, 28, 53, 32, 2)
c:build{
  { "tray", tray, GV.ramp("#f4f0e0") },
  { "dome", dome, GV.ramp("#f6dc94"), { gloss = { 20, 21 } } },
  { "rim", rim, GV.ramp("#d6c9b6"), { gloss = false } },
}
c:part(c:ellipse(24, 23, 2.5, 2), GV.ramp("#dd3a2a"), { flat = true })
c:part(c:ellipse(33, 19, 2.5, 2), "moss", { flat = true })
c:part(c:ellipse(41, 25, 2, 2), GV.ramp("#e46a9b"), { flat = true })
c:seam({ {12, 30}, {51, 30} })
c:gloss(tray, GV.ramp("#f4f0e0"), { 18, 35 })
local t = c:save(O .. "aseprite/ph/devilled-eggs.aseprite", O .. "png/ph/devilled-eggs.png")
print(GV.report(t))
