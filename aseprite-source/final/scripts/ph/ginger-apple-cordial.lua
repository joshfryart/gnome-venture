local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- fat ear handle on the right
local ear = c:ellipse(44, 40, 8, 8):cut(c:ellipse(44, 40, 4, 4))
ear:cut(c:rect(0, 0, 41, 63))

local belly = c:ellipse(30.5, 41, 15.5, 14)
local neck = c:rrect(23, 19, 38, 29, 2)
local apple = c:ellipse(30.5, 15, 6.5, 5.5)
local stalk = c:rect(30, 6, 31, 10)
local leaf = c:poly({ {32, 9}, {36, 5}, {40, 6}, {37, 10} })

local p = c:build{
  { "handle", ear, GV.ramp("#d9a660", { shade = "#a8582f" }), { gloss = false } },
  { "belly", belly, "gold", { gloss = { 20, 34 } } },
  { "neck", neck, "gold", { gloss = false } },
  { "apple", apple, "red", { gloss = { 26, 12 } } },
  { "stalk", stalk, "#5e2f1e", { flat = true } },
  { "leaf", leaf, "leaf", { flat = true } },
}
-- inner highlight arc on the glass
c:paint({ "...hhhh", ".hh....", "h......" }, 19, 31, { h = "#fff1c8" })
-- bubbles
c:paint({ "bb", "bb" }, 26, 44, { b = "#fff1c8" })
c:paint({ "b" }, 30, 48, { b = "#fff1c8" })
c:paint({ "b" }, 23, 49, { b = "#fff1c8" })
-- twine band round the neck
c:seam({ {23, 27}, {38, 27} })

c:ground(31, 56, 13, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/ginger-apple-cordial.aseprite", D .. "img-redraw-full/png/ph/ginger-apple-cordial.png")
print(GV.report(t))
