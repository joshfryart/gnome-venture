local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local grey  = GV.ramp("#a38f80")
local dgrey = GV.ramp("#8f7060")
local cream = GV.ramp("#f8eed2")
-- tail curling up at right
local tail = c:ellipse(47, 46, 6, 5)
tail:add(c:ellipse(51, 38, 5, 6)):add(c:ellipse(52, 30.5, 4, 4.5))
local p = c:build{
  { "tail",  tail, dgrey },
  { "earL",  c:ellipse(20, 17, 4.5, 4.5), grey },
  { "earR",  c:ellipse(44, 17, 4.5, 4.5), grey },
  { "footL", c:ellipse(21.5, 52.5, 6, 3.5), dgrey },
  { "footR", c:ellipse(42.5, 52.5, 6, 3.5), dgrey },
  { "body",  c:ellipse(32, 42, 16, 13), grey, { stitch = { side = "lit" } } },
  { "belly", c:ellipse(32, 46, 9, 7.5), cream, { gloss = false } },
}
-- tail rings and cream tip
local tm = p.tail.m
c:fill(c:ellipse(52, 28.5, 4, 3):clip(tm), "#f8eed2")
c:fill(c:poly({ {44, 37}, {58, 31}, {58, 34}, {44, 40} }):clip(tm), "#3a2a2a")
c:fill(c:poly({ {43, 45}, {58, 39}, {58, 42}, {43, 48} }):clip(tm), "#3a2a2a")
-- inner ears
c:fill(c:ellipse(20, 17, 2, 2), "#f8eed2")
c:fill(c:ellipse(44, 17, 2, 2), "#f8eed2")
-- head
local head = c:ellipse(32, 27, 13.5, 12.5)
local h = c:part(head, grey)
-- bandit mask
local mask = c:ellipse(25, 23.5, 7.5, 4.5):add(c:ellipse(39, 23.5, 7.5, 4.5)):add(c:rect(28, 20, 36, 24))
mask:clip(head)
c:fill(mask, "#2a1a10")
-- muzzle
c:part(c:ellipse(32, 31.5, 6.5, 4.5), cream, { gloss = false })
c:fill(c:ellipse(32, 29, 2.5, 1.5), "#2a1a10")
c:px(31, 28, "#7b66b4")
c:paint({ "u.....u", ".uu.uu.", "...u..." }, 29, 32, { u = "umber" })
c:eye(23, 21); c:eye(36, 21)
c:ground(32, 56, 19, 1.5)
local t = c:save(O .. "aseprite/ph/creature-raccoon.aseprite", O .. "png/ph/creature-raccoon.png")
print(GV.report(t))
