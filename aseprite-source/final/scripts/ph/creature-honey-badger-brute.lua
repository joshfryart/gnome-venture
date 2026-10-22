local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur  = GV.ramp("#8f7060")
local pale = GV.ramp("#a38f80")
local dark = GV.ramp("#3d2a1c", { shade = "#2a1a10", deep = "#2a1a10" })
-- dark hood: thick arch over the crown, legs down to the cheeks
local cape = c:ellipse(32, 26, 14, 10):cut(c:ellipse(32, 29, 9.5, 6.5)):cut(c:rect(0, 27, 63, 63)):clip(c:ellipse(32, 28, 13, 11))
local p = c:build{
  { "tail",  c:ellipse(51, 45, 4.5, 4.5), dark },
  { "earL",  c:ellipse(19, 15, 5, 5), fur },
  { "earR",  c:ellipse(45, 15, 5, 5), fur },
  { "feet",  c:ellipse(21.5, 54, 6.5, 3.5):add(c:ellipse(42.5, 54, 6.5, 3.5)), dark, { gloss = false } },
  { "body",  c:ellipse(32, 42, 18, 13), fur, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 46, 10, 7), pale, { flat = true } },
  { "head",  c:ellipse(32, 28, 13, 11), fur },
  { "cape",  cape, dark },
  { "snout", c:ellipse(32, 33, 6.5, 4), pale },
}
c:fill(c:ellipse(19, 16, 2, 2), pale.base); c:fill(c:ellipse(45, 16, 2, 2), pale.base)
c:fill(c:ellipse(32, 31, 2.5, 1.5), "#2a1a10"); c:px(31, 30, "#5e2a3a")
c:paint({ "u.....u", ".uuuuu." }, 29, 35, { u = "#2a1a10" })
c:eye(23, 25); c:eye(37, 25)

c:ground(32, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/creature-honey-badger-brute.aseprite", O .. "png/ph/creature-honey-badger-brute.png")
print(GV.report(t))
