local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lid raised at the back, slightly tilted
local lid = c:poly({ {15, 12}, {49, 10}, {51, 25}, {13, 25} }):add(c:rrect(14, 11, 50, 16, 3))
local p = c:build{
  { "lid", lid, "#5b6470" },
  { "body", c:rrect(11, 30, 52, 54, 3), "#8b8f96" },
}
-- dark hinged gap under the lid
c:fill(c:rect(15, 26, 48, 27), "#2a1a10")
c:build{
  { "pinL", c:rrect(14, 25, 17, 28, 1), "#5b6470", { flat = true, rim = true } },
  { "pinR", c:rrect(46, 25, 49, 28, 1), "#5b6470", { flat = true } },
  { "front", c:rrect(10, 28, 53, 34, 3), "#8b8f96" },
  { "label", c:rrect(21, 37, 42, 52, 3), GV.ramp("#f1ece0"), { gloss = false } },
}
c:px(14, 25, "#f5cf6a"); c:px(46, 25, "#f5cf6a")
c:part(c:ellipse(31.5, 45.5, 5, 5), GV.ramp("#7b66b4"), { gloss = { 29, 43 } })
c:fill(c:rect(31, 38, 32, 40), "#5e2f1e")
c:paint({ ".ll", "lll", "ll." }, 33, 38, { l = "#6a9a3a" })
c:px(34, 38, "#c8d77a")
c:seam({ {13, 33}, {50, 33} })
c:button(30, 27)
local t = c:save(O .. "aseprite/ph/plum-seed.aseprite", O .. "png/ph/plum-seed.png")
print(GV.report(t))
