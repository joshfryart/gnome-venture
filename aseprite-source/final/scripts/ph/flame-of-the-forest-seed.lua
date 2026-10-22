local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin  = GV.ramp("#b9b4b9")
local tinL = GV.ramp("#cfc9cf")
local p = c:build{
  { "hingeL", c:rect(16, 11, 19, 15), "#968f96", { flat = true } },
  { "hingeR", c:rect(44, 11, 47, 15), "#968f96", { flat = true } },
  { "body",  c:rrect(13, 25, 50, 53, 3), tin },
  { "lid",   c:rrect(11, 15, 52, 26, 3), tinL, { gloss = { 15, 18 } } },
  { "label", c:rrect(20, 31, 43, 49, 3), GV.ramp("#f4f0e0"), { gloss = false } },
  { "seed",  c:ellipse(31.5, 41.5, 6, 6), GV.ramp("#e8a317", { shade = "#d0862a", deep = "#a5663a" }) },
}
-- label border
c:fill(c:rrect(20, 31, 43, 49, 3):edge(), "#dcb06a")
-- sprout on top of seed
c:fill(c:rect(31, 32, 32, 36), "#2e5a2c")
c:paint({ ".ll.", "llll", ".ll." }, 33, 31, { l = "#58a03e" })
c:paint({ "ll.", "lll" }, 28, 33, { l = "#58a03e" })
-- seed gloss dot
c:px(28, 39, "#fff1c8"); c:px(29, 38, "#fff1c8")
-- lid / body seam
c:seam({ { 14, 27 }, { 49, 27 } })
-- clasp button
c:button(30, 25)
c:ground(31.5, 55, 17, 2)
local t = c:save(O .. "aseprite/ph/flame-of-the-forest-seed.aseprite", O .. "png/ph/flame-of-the-forest-seed.png")
print(GV.report(t))
