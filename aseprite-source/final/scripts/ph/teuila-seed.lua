local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- lid tipped back: a skewed slab, lower front edge sits above the box, top leans back/up
local lid = c:poly({ {16, 10}, {50, 14}, {51, 26}, {13, 26} })
lid:add(c:rrect(13, 22, 51, 26, 1))
local p = c:build{
  { "gap",   c:rect(14, 25, 50, 29), "#5b6470", { flat = true } },
  { "lid",   lid, "#c9c5bc", { gloss = { 19, 15 } } },
  { "tin",   c:rrect(11, 29, 52, 54, 3), "#8b8f96", { gloss = { 15, 33 } } },
  { "hinge", c:rect(14, 25, 22, 31), "#5b6470", { gloss = false } },
}
-- lid lip band
c:seam({ {23, 24}, {50, 24} })
-- front clasp
c:part(c:rrect(29, 28, 34, 33, 1), "#e8a317", { gloss = false })
c:px(31, 30, "#8a4a1c"); c:px(32, 31, "#8a4a1c")
-- bud stem and leaf
c:part(c:rect(31, 34, 32, 37), "#2f5a2a", { flat = true })
c:part(c:ellipse(37.5, 35.5, 3, 2), "#7ab55c", { flat = true })
-- purple bud
c:part(c:ellipse(31.5, 44, 7, 7), GV.ramp("#7a5cc0", { shade = "#4e3a8a" }))
-- petal tip notches
c:px(31, 37, "#4e3a8a"); c:px(32, 37, "#4e3a8a"); c:px(31, 38, "#4e3a8a")

c:ground(31.5, 56, 18, 1.5)
local t = c:save(O .. "aseprite/ph/teuila-seed.aseprite", O .. "png/ph/teuila-seed.png")
print(GV.report(t))
