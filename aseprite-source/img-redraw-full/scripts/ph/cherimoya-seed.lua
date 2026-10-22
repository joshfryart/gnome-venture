local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- open gap sliver behind the lid (lid tilted up at the back)
local gap = c:rrect(14, 10, 50, 15, 2)
local p = c:build{
  { "gap",  gap, GV.ramp("#5b6470"), { flat = true } },
  { "body", c:rrect(11, 24, 53, 54, 4), GV.ramp("#c9c5bc") },
  { "lid",  c:rrect(9, 14, 55, 26, 4), GV.ramp("#8b8f96") },
  { "rim",  c:rrect(19, 29, 45, 50, 5), GV.ramp("#f08a24"), { flat = true } },
  { "label",c:rrect(21, 31, 43, 48, 4), GV.ramp("#f1ece0"), { gloss = false } },
  { "fruit",c:ellipse(32, 40, 7.5, 7), GV.ramp("#f08a24"), { gloss = { 28, 36 } } },
  { "stem", c:rect(31, 30, 32, 34), GV.ramp("#2e5a2c"), { flat = true } },
  { "leaf", c:ellipse(36.5, 32, 3, 2), GV.ramp("#58a03e"), { flat = true } },
}
c:seam({ {14, 25}, {50, 25} }, { free = true })
c:button(48, 17)
c:paint({ "r.....r.....r" }, 26, 52, { r = "#8c4a1a" })
c:paint({ "r", "r" }, 15, 52, { r = "#8c4a1a" })
local t = c:save(O .. "aseprite/ph/cherimoya-seed.aseprite", O .. "png/ph/cherimoya-seed.png")
print(GV.report(t))
