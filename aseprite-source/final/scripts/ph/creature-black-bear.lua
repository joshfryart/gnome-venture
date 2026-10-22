local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur = GV.ramp("#3d2a1c", { gloss = "#9a6b3f", rim = "#7a4a1f" })
local tan = GV.ramp("#8f7060")
local p = c:build{
  { "tail",  c:ellipse(50, 46, 3.5, 3.5), fur, { gloss = false } },
  { "earL",  c:ellipse(19.5, 15.5, 5.5, 5.5), fur, { gloss = false } },
  { "earR",  c:ellipse(44.5, 15.5, 5.5, 5.5), fur, { gloss = false } },
  { "footL", c:ellipse(21.5, 53, 6.5, 4), fur, { gloss = false } },
  { "footR", c:ellipse(42.5, 53, 6.5, 4), fur, { gloss = false } },
  { "body",  c:ellipse(32, 41, 19, 12), fur },
  { "belly", c:ellipse(32, 45, 11, 8), tan, { gloss = false } },
  { "head",  c:ellipse(32, 27, 14, 12.5), fur },
  { "muzzle",c:ellipse(32, 33.5, 6.5, 5.5), tan, { gloss = false } },
}
-- inner ears
c:fill(c:ellipse(19.5, 15.5, 2.5, 2.5), "#8f7060")
c:fill(c:ellipse(44.5, 15.5, 2.5, 2.5), "#8f7060")
c:px(18, 14, tan.rim); c:px(43, 14, tan.rim)
-- paw pads on feet
c:fill(c:rrect(19, 52, 24, 55, 1), "#8f7060")
c:fill(c:rrect(40, 52, 45, 55, 1), "#8f7060")
-- nose + mouth
c:paint({ ".nnnnn.", "nnnnnnn", ".nnnnn.", "...n..." }, 29, 29, { n = "#2a1a10" })
c:px(30, 29, "#5e2a3a")
c:paint({ "m.....m", ".mm.mm." }, 29, 33, { m = "#2a1a10" })
-- eyes
c:eye(22, 21); c:eye(37, 21)
c:ground(32, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-black-bear.aseprite", O .. "png/ph/creature-black-bear.png")
print(GV.report(t))
