local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- squat sack: wide rounded bottom, narrowing shoulders into the neck
local body = c:ellipse(31.5, 41, 18, 15)
body:add(c:poly({ {20, 30}, {44, 30}, {48, 40}, {16, 40} }))
-- gathered neck: flares out at the top (ruffle) and pinches at the tie
local neck = c:poly({ {27, 21}, {37, 21}, {39, 28}, {25, 28} })
local ruffle = c:poly({ {22, 11}, {42, 11}, {38, 21}, {26, 21} })
ruffle:add(c:ellipse(25, 12, 3, 2)); ruffle:add(c:ellipse(31.5, 11, 3, 2)); ruffle:add(c:ellipse(38, 12, 3, 2))
local cord = c:rect(24, 20, 40, 22)
local badge = c:ellipse(31.5, 41, 7, 7)

local p = c:build{
  { "body",   body,   "#f1ece0", { stitch = true } },
  { "neck",   neck,   "#f1ece0", { gloss = false } },
  { "ruffle", ruffle, "#f1ece0" },
  { "cord",   cord,   "#8c4a1a", { flat = true } },
  { "badge",  badge,  GV.ramp("#3f93b2", { shade = "#256a80" }) },
}
-- tails
c:part(c:line({ {25, 22}, {22, 26}, {21, 30} }, 2), "#8c4a1a", { flat = true })
c:part(c:line({ {38, 22}, {41, 26}, {42, 30} }, 2), "#8c4a1a", { flat = true })
-- fold lines on the ruffle
c:paint({ "f", "f", "f", "f" }, 28, 14, { f = "#dcb06a" })
c:paint({ "f", "f", "f", "f" }, 35, 14, { f = "#dcb06a" })
c:px(29, 24, "#dcb06a"); c:px(29, 25, "#dcb06a"); c:px(34, 24, "#dcb06a"); c:px(34, 25, "#dcb06a")
-- sprout on the badge
c:paint({
  "..ll.",
  ".llll",
  "ll.s.",
  "...s.",
  "...s.",
}, 29, 36, { l = "#58a03e", s = "#2f5a2a" })
c:paint({ "sssss" }, 29, 41, { s = "#256a80" })
c:button(30, 19)

local t = c:save(O .. "aseprite/ph/acanthus-seed.aseprite", O .. "png/ph/acanthus-seed.png")
print(GV.report(t))
