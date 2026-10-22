local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur  = GV.ramp("#8f7060")
local pale = GV.ramp("#a38f80")
local feetR = GV.ramp("#35161f")
local nose = GV.ramp("#e46a9b")
local feet = c:ellipse(22.5, 54, 6, 3.5):add(c:ellipse(41.5, 54, 6, 3.5))
local body = c:ellipse(32, 44, 15, 12)
local head = c:ellipse(32, 29, 12, 11.5)
local star = c:ascii({
  "......xx......",
  "......xx......",
  ".....xxxx.....",
  "..xxxxxxxxxx..",
  "xxxxxxxxxxxxxx",
  "xxxxxxxxxxxxxx",
  "..xxxxxxxxxx..",
  ".....xxxx.....",
  "......xx......",
  "......xx......",
}, 25, 26)
c:build{
  { "feet",  feet, feetR, { gloss = false } },
  { "body",  body, fur, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 47.5, 8.5, 7.5), pale, { gloss = false } },
  { "head",  head, fur, { light = head:copy():add(body) } },
  { "muzzle", c:ellipse(31.5, 33.5, 8, 5), pale, { gloss = false } },
  { "nose",  star, nose, { flat = true, contour = false } },
}
-- nostril
c:px(31, 31, "#2a1a10"); c:px(32, 31, "#2a1a10")
c:px(36, 32, nose.shade); c:px(37, 31, nose.shade); c:px(32, 34, nose.shade); c:px(33, 33, nose.shade)
c:px(28, 30, nose.gloss); c:px(29, 30, nose.gloss); c:px(31, 28, nose.dot)
-- smile
c:paint({ "m.....m", ".mmmmm." }, 28, 37, { m = "#2a1a10" })
-- claws
c:paint({ "c.c.c" }, 18, 56, { c = "#c9a96e" })
c:paint({ "c.c.c" }, 41, 56, { c = "#c9a96e" })
c:eye(22, 23); c:eye(37, 23)
c:ground(32, 58, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-tunnel-mole.aseprite", O .. "png/ph/creature-tunnel-mole.png")
print(GV.report(t))
