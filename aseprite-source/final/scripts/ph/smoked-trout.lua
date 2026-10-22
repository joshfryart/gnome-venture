local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- arched fish back with a tail flick at right
local fish = c:ellipse(31.5, 30, 20, 15):cut(c:rect(0, 30, 63, 63))
fish:add(c:poly({ {46, 24}, {56, 15}, {58, 17}, {55, 23}, {58, 29}, {50, 29} }))
-- smoke wisp
local smoke = c:line({ {30, 14}, {28, 12}, {29, 10}, {32, 10}, {34, 11} }, 2)
local bowl = c:ellipse(32, 30, 24, 23):cut(c:rect(0, 0, 63, 30))
local rim = c:rrect(6, 27, 57, 32, 2)
local p = c:build{
  { "smoke", smoke, GV.ramp("#8fcbd8"), { flat = true } },
  { "fish", fish, GV.ramp("#3f93b2"), { gloss = { 20, 21 } } },
  { "bowl", bowl, GV.ramp("#f4f0e0") },
  { "rim", rim, GV.ramp("#d6c9b6"), { gloss = false } },
}
-- spots on the fish back
c:fill(c:ellipse(23.5, 23.5, 2.5, 2.5), "#256a80")
c:fill(c:ellipse(33.5, 20.5, 2.5, 2.5), "#7ab55c"); c:px(33, 19, "#c8d77a")
c:fill(c:ellipse(42, 25, 2, 2), "#e8a317"); c:px(41, 24, "#fff1c8")
-- fish eye near the head end
c:fill(c:rect(15, 25, 16, 26), "#2a1a10")
c:seam({ {9, 29}, {55, 29} })
local t = c:save(O .. "aseprite/ph/smoked-trout.aseprite", O .. "png/ph/smoked-trout.png")
print(GV.report(t))
