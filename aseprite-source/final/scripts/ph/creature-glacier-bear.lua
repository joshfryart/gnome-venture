local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local frost = GV.ramp("#b8d8d2")
local cream = GV.ramp("#f8eed2")
local blue = "water"
c:build{
  { "tail",  c:ellipse(49.5, 46.5, 3.5, 3.5), blue },
  { "earL",  c:ellipse(19.5, 17.5, 5.5, 5.5), frost },
  { "earR",  c:ellipse(44.5, 17.5, 5.5, 5.5), frost },
}
c:part(c:ellipse(19.5, 17.5, 2.5, 2.5), cream, { flat = true, contour = false })
c:part(c:ellipse(44.5, 17.5, 2.5, 2.5), cream, { flat = true, contour = false })
local p = c:build{
  { "body",  c:ellipse(32, 41.5, 19, 13), frost, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 46, 10.5, 8.5), cream, { gloss = false } },
  { "footL", c:ellipse(21.5, 53, 6.5, 4), blue },
  { "footR", c:ellipse(42.5, 53, 6.5, 4), blue },
  { "head",  c:ellipse(32, 27, 13.5, 12.5), frost },
  { "muzzle", c:ellipse(32, 33, 6.5, 5.5), cream, { gloss = false } },
}
-- nose
c:paint({ ".nnnn.", "nnnnnn", ".nnnn.", "..nn.." }, 29, 29, { n = "#2a1a10" })
c:px(30, 29, "#5e2a3a")
-- mouth
c:paint({ "m....m", ".mmmm." }, 29, 34, { m = "#4a2c1a" })
c:eye(23, 21); c:eye(37, 21)
c:ground(32, 57, 17, 1)
local t = c:save(O .. "aseprite/ph/creature-glacier-bear.aseprite", O .. "png/ph/creature-glacier-bear.png")
print(GV.report(t))
