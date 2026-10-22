local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fur  = GV.ramp("#a5663a")   -- wood family
local tan  = GV.ramp("#dcb06a")   -- soil/wood family
local tail = GV.ramp("#b6814d")   -- wood
local foot = GV.ramp("#8c4a1a")   -- wood

-- tail: out right from the hip, up, then curling back in a loop
local tl = c:line({ {42,46}, {47,46}, {50,44}, {52,41}, {52,36}, {51,33}, {48,31}, {45,32}, {44,35}, {46,37} }, 3)
local ears = c:ellipse(15, 24, 5.5, 5.5):add(c:ellipse(41, 24, 5.5, 5.5))
local feet = c:ellipse(20, 52, 6, 3.5):add(c:ellipse(36, 52, 6, 3.5))
local body = c:ellipse(28, 41, 15, 12)
local head = c:ellipse(28, 25, 13, 12.5)
local mask = c:ellipse(23.5, 25, 5.5, 4.5):add(c:ellipse(32.5, 25, 5.5, 4.5)):add(c:ellipse(28, 30, 8.5, 5.5))

local p = c:build{
  { "tail", tl, tail, { flat = true } },
  { "ears", ears, fur },
  { "feet", feet, foot },
  { "body", body, fur, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(28, 44, 9, 7.5), tan, { gloss = false } },
  { "head", head, fur, { gloss = { 19, 15 } } },
  { "mask", mask, tan, { gloss = false, contour = false } },
}
-- inner ear discs
c:fill(c:ellipse(14, 24, 2.5, 2.5), tan.base)
c:fill(c:ellipse(42, 24, 2.5, 2.5), tan.base)
c:px(13, 23, tan.gloss); c:px(41, 23, tan.gloss)
c:fill(c:ellipse(15, 25, 2.5, 2.5):cut(c:ellipse(14, 24, 2.5, 2.5)), tan.shade)
c:fill(c:ellipse(43, 25, 2.5, 2.5):cut(c:ellipse(42, 24, 2.5, 2.5)), tan.shade)
c:fill(c:ellipse(15, 25, 2.5, 2.5):cut(c:ellipse(14, 24, 2.5, 2.5)):cut(c:ellipse(15, 24, 3.5, 3.5):edge()), tan.shade)

c:eye(21, 22); c:eye(31, 22)
-- nose and sly grin
c:paint({ ".nnnnn.", "nnnnnnn", ".nnnnn." }, 25, 28, { n = "#2a1a10" })
c:px(26, 28, "#5e2a3a")
c:paint({ "g.......g", ".g.....g.", "..ggggg.." }, 24, 31, { g = "#4a2c1a" })
c:px(32, 31, "#4a2c1a")
local t = c:save(O .. "aseprite/ph/creature-mischief-monkey.aseprite", O .. "png/ph/creature-mischief-monkey.png")
print(GV.report(t))
