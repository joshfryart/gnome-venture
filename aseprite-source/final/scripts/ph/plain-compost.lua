local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sack = c:poly({ { 15, 19 }, { 21, 14 }, { 43, 14 }, { 49, 19 }, { 52, 46 }, { 12, 46 } })
sack:add(c:rrect(11, 36, 52, 55, 8))
c:build{
  { "soil", c:ellipse(31.5, 13, 9, 3.5), "soil", { gloss = false } },
  { "sack", sack, GV.ramp("#a5663a"), { stitch = { side = "lit" } } },
  { "fold", c:poly({ { 20, 13 }, { 44, 13 }, { 47, 22 }, { 17, 22 } }), GV.ramp("#dcb06a"), { cres = 2 } },
  { "patch", c:ellipse(31.5, 37, 11, 9), GV.ramp("#8a4f2a"), { gloss = false, contact = false, cres = 2 } },
}
c:fill(c:line({ { 26, 34 }, { 31, 40 }, { 32, 40 }, { 37, 34 } }, 2), "#5e2f1e")
c:seam({ { 19, 20 }, { 45, 20 } })
c:button(22, 15)
c:ground(31.5, 56, 17, 1.5)
local t = c:save(O .. "aseprite/ph/plain-compost.aseprite", O .. "png/ph/plain-compost.png")
print(GV.report(t))
