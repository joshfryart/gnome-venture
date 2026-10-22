local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan, cream, brown = GV.ramp("#dcb06a"), GV.ramp("#f8eed2"), GV.ramp("#a5663a")
local p = c:build{
  { "tail",  c:ellipse(47, 50, 3.5, 3), brown },
  { "earL",  c:ellipse(21, 20, 5, 5), tan },
  { "earR",  c:ellipse(43, 20, 5, 5), tan },
  { "footL", c:ellipse(23, 54, 6, 3), brown },
  { "footR", c:ellipse(41, 54, 6, 3), brown },
  { "body",  c:ellipse(32, 43, 16, 12.5), tan, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 47, 9, 7), cream, { gloss = false } },
  { "head",  c:ellipse(32, 30, 12.5, 12), tan },
  { "stripe", c:rrect(30, 18, 34, 30, 1), cream, { gloss = false, contact = false } },
  { "muzzle", c:ellipse(32, 34.5, 6.5, 4.5), cream, { gloss = { 28, 32 } } },
}
-- inner ears
c:fill(c:ellipse(21, 20, 2.5, 2.5), "#f8eed2"); c:px(20, 19, "#fff3c8")
c:fill(c:ellipse(43, 20, 2.5, 2.5), "#f8eed2"); c:px(42, 19, "#fff3c8")
-- eyes (wide), heavy grumpy lids
c:eye(22, 25); c:eye(37, 25)
-- slanted brows sloping down toward centre, cover top of eyes
c:line({ {21, 23}, {27, 25} }, 2)
c:line({ {43, 23}, {37, 25} }, 2)
-- nose
c:paint({ ".nnn.", "nnnnn", ".nnn." }, 30, 31, { n = "#2a1a10" })
c:px(31, 31, "#5e2a3a")
-- frown
c:paint({ ".fffff.", "f.....f" }, 29, 36, { f = "#4a2c1a" })
c:ground(32, 57, 15, 1)
local t = c:save(O .. "aseprite/ph/creature-grumpy-lemming.aseprite", O .. "png/ph/creature-grumpy-lemming.png")
print(GV.report(t))
