local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
c:build{
  { "bl", c:rrect(8, 31, 29, 45, 2), GV.ramp("#968f96") },
  { "br", c:rrect(32, 31, 55, 45, 2), GV.ramp("#d6c9b6") },
  { "top", c:rrect(18, 14, 44, 28, 2), GV.ramp("#6a6070"), { gloss = { 22, 17 } } },
}
-- mortar fill between blocks
c:fill(c:rect(30, 33, 31, 44), "#4a2c1a")
c:fill(c:rect(20, 29, 42, 30), "#4a2c1a")
-- chip lines
c:paint({ "u.", ".u", ".u" }, 14, 38, { u = "#5b5560" })
c:paint({ ".u", "u.", "u." }, 47, 36, { u = "#a8957e" })
c:paint({ "uu" }, 37, 22, { u = "#4e4656" })
c:ground(32, 50, 18, 2.5)
local t = c:save(O .. "aseprite/ph/building-stone.aseprite", O .. "png/ph/building-stone.png")
print(GV.report(t))
