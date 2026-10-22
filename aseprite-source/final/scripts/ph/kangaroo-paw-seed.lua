local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- gathered cloth ears / tuft above the tie
local ears = c:poly({ {22, 27}, {17, 13}, {26, 19}, {31, 9}, {36, 19}, {46, 13}, {42, 27} })
-- round sack
local sack = c:ellipse(31.5, 41, 20, 15):add(c:poly({ {22, 28}, {42, 28}, {46, 32}, {18, 32} }))
-- string tie
local tie = c:rrect(21, 25, 42, 29, 1)

local p = c:build{
  { "ears", ears, GV.ramp("#f4f0e0") },
  { "sack", sack, "cream", { stitch = { side = "lit" } } },
  { "tie",  tie,  "gold" },
}

-- bow loops
-- bow: two loops sideways off the knot plus two hanging tails
c:part(c:poly({ {32, 27}, {24, 23}, {24, 31} }), "gold", { gloss = false, contact = false })
c:part(c:poly({ {32, 27}, {40, 23}, {40, 31} }), "gold", { gloss = false, contact = false })
c:part(c:line({ {30, 29}, {27, 34} }, 2), "gold", { flat = true })
c:part(c:line({ {33, 29}, {36, 34} }, 2), "gold", { flat = true })
c:button(30, 25)

-- stitched seed emblem
c:part(c:ellipse(31.5, 43, 7.5, 7.5), GV.ramp("#7a5cc0", { shade = "#4e3a8a" }), { contact = false })
-- sprout
c:fill(c:line({ {32, 35}, {32, 33} }, 2), "#2e5a2c")
local leaf = c:poly({ {34, 33}, {37, 30}, {41, 30}, {39, 33}, {35, 35} })
c:fill(leaf, "#58a03e")
c:px(36, 32, "#7ab55c"); c:px(37, 31, "#7ab55c")

local t = c:save(O .. "aseprite/ph/kangaroo-paw-seed.aseprite", O .. "png/ph/kangaroo-paw-seed.png")
print(GV.report(t))
