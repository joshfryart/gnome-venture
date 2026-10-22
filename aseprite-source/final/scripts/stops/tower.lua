local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 48, h = 48, mode = "icon" }
local flame = c:ellipse(24, 14.5, 3.5, 2.5):add(c:poly({ {21,13}, {24,9}, {28,13} }))
local shaft = c:poly({ {19,22}, {29,22}, {31,34}, {17,34} })
local crens = c:rect(15, 17, 18, 19):add(c:rect(22, 17, 26, 19)):add(c:rect(30, 17, 33, 19))
c:build{
  { "flame", flame, GV.ramp("#f08a24", { gloss = "#ffc27a" }), { gloss = false } },
  { "shaft", shaft, "stone" },
  { "crens", crens, "stone", { flat = true } },
  { "band",  c:rect(15, 19, 33, 22), GV.ramp("#5b6470"), { gloss = false } },
  { "door",  c:rrect(22, 26, 26, 33, 2), GV.ramp("#3d2a1c"), { gloss = false, flat = true } },
  { "plinth",c:rect(13, 33, 35, 36), GV.ramp("#c9c5bc"), { gloss = false } },
}
c:paint({ "y", "o" }, 23, 13, { y = "#ffc27a", o = "#ffe2a8" })
c:seam({ {17, 22}, {31, 22} }, { free = true })
local t = c:save(O .. "aseprite/stops/tower.aseprite", O .. "png/stops/tower.png")
print(GV.report(t))
