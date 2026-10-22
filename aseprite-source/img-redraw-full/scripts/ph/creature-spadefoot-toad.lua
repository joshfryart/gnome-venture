local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- spade feet splayed to the sides (behind body)
local footL = c:poly({ {16,44}, {20,50}, {14,55}, {7,56}, {7,52}, {11,48} })
local footR = c:poly({ {48,44}, {44,50}, {50,55}, {57,56}, {57,52}, {53,48} })
local body = c:ellipse(31.5, 40.5, 20, 11.5)
local bumpL = c:ellipse(22, 30, 5.5, 5)
local bumpR = c:ellipse(41, 30, 5.5, 5)
local belly = c:ellipse(31.5, 47, 12, 4.5)
c:build{
  { "footL", footL, "#d9a660" },
  { "footR", footR, "#d9a660" },
  { "body",  body,  "#a8582f", { stitch = { side = "lit" } } },
  { "bumpL", bumpL, "#b07a45", { light = body } },
  { "bumpR", bumpR, "#b07a45", { light = body } },
  { "belly", belly, "#ecc58a", { light = body, gloss = false } },
}
-- toe nicks on spade feet
c:px(9, 54, "#8a4f2a"); c:px(11, 54, "#8a4f2a")
c:px(54, 54, "#8a4f2a"); c:px(52, 54, "#8a4f2a")
-- warts (diamonds)
c:paint({ ".w.", "www", ".w." }, 14, 39, { w = "#8a4f2a" })
c:paint({ ".w.", "www", ".w." }, 47, 39, { w = "#8a4f2a" })
c:paint({ ".w.", "www", ".w." }, 30, 33, { w = "#8a4f2a" })
-- wide smile
c:paint({
  "m..................m",
  ".m................m.",
  "..mmm..........mmm..",
  ".....mmmmmmmmmm.....",
}, 22, 38, { m = "#4a2c1a" })
c:eye(20, 28); c:eye(39, 28)
local t = c:save(O .. "aseprite/ph/creature-spadefoot-toad.aseprite", O .. "png/ph/creature-spadefoot-toad.png")
print(GV.report(t))
