local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#c9a96e", { shade = "#9a6b3f" })
-- two pointed corner ears gathered above the knot
local earL = c:poly({ {24, 32}, {11, 13}, {16, 12}, {33, 28} })
local earR = c:poly({ {31, 28}, {48, 12}, {53, 13}, {40, 32} })
local body = c:ellipse(31.5, 42, 21, 14)
body:add(c:rrect(20, 28, 43, 34, 3))
local tie = c:rrect(21, 28, 42, 31, 1)
local hole = c:ellipse(31.5, 44, 11, 9)
local nut = c:ellipse(31.5, 45, 7.5, 7)
local p = c:build{
  { "earL", earL, cloth },
  { "earR", earR, cloth },
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "tie", tie, "gold", { flat = true } },
  { "hole", hole, GV.ramp("#7a4a1f"), { gloss = false } },
  { "nut", nut, GV.ramp("#8e5530"), { gloss = { 27, 40 } } },
}
-- walnut shell: centre ridge and crinkles
c:paint({
  "...d...",
  ".d.d.d.",
  "d..d..d",
  "...d...",
  ".d.d.d.",
  "...d...",
  "d..d..d",
  ".d.d.d.",
  "...d...",
}, 28, 41, { d = "#5e2f1e" })
-- green stem peeking from the top of the nut
c:fill(c:rect(31, 36, 32, 38), "#2e5a2c")
c:paint({ "lll", ".ll" }, 33, 35, { l = "#58a03e" })
-- crossed string ends dangling from the knot
c:seam({ {21, 30}, {42, 30} }, { gap = "#b8661a" })
c:button(30, 28)
c:seam({ {48, 36}, {48, 48} })
local t = c:save(O .. "aseprite/ph/walnut-seed.aseprite", O .. "png/ph/walnut-seed.png")
print(GV.report(t))
