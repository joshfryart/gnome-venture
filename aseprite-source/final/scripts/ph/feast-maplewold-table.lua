-- ph/feast-maplewold-table : small wooden harvest table, three-quarter view (REDO, unique layout)
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local R = GV.R

-- tabletop parallelogram: A left, B back, C right, D front
local A, B, Cc, D = {11,35}, {33,28}, {53,35}, {31,42}
local T = 4 -- top thickness
local darkWood = GV.ramp("#8a4f2a")
local roast = GV.ramp("#a8582f")
local cloth = GV.ramp("#f1ece0")

c:build{
  { "legL",  c:rect(12, 36, 14, 52), darkWood, { gloss = false } },
  { "legR",  c:rect(50, 36, 52, 52), darkWood, { gloss = false } },
  { "sideL", c:poly({ A, D, {D[1], D[2]+T}, {A[1], A[2]+T} }), darkWood, { gloss = false } },
  { "sideR", c:poly({ D, Cc, {Cc[1], Cc[2]+T}, {D[1], D[2]+T} }), "wood", { gloss = false } },
  { "legF",  c:rect(29, 45, 32, 55), "wood", { gloss = false } },
  { "top",   c:poly({ A, B, Cc, D }), "wood", { gloss = { 22, 32 } } },
}
-- plank seams on the top (parallel to A-D)
c:fill(c:line({ {19, 32}, {39, 40} }, 1), R.wood.shade)
c:fill(c:line({ {26, 30}, {46, 38} }, 1), R.wood.shade)

-- runner: across the top (parallel to A-B), hanging over the front-left face
local run = c:poly({ {17, 37}, {25, 40}, {46, 33}, {38, 30} })
run:add(c:poly({ {17, 37}, {25, 40}, {25, 45}, {17, 42} }))
local p = c:build{
  { "runner", run, "red", { gloss = { 20, 39 } } },
}
-- cream stripes near the hanging end and the far end
c:fill(c:line({ {18, 41}, {24, 44} }, 1), cloth.base)
c:fill(c:line({ {37, 31}, {44, 34} }, 1), cloth.base)
-- cream fringe below the drape
c:paint({ "c.c.c", ".c.c.c" }, 18, 43, { c = cloth.base })
-- stitched seam down the runner
c:seam({ {20, 38}, {41, 31} })

-- candle at back left
c:build{
  { "holder", c:ellipse(21.5, 31, 3.5, 1.5), "gold", { gloss = false } },
  { "candle", c:rect(20, 19, 23, 30), "cream", { gloss = { 21, 21 } } },
  { "flame",  c:ellipse(21.5, 14, 1.5, 3):add(c:rect(21, 11, 22, 12)), "flame", { flat = true, rim = false } },
}
c:px(21, 18, "umber"); c:px(22, 18, "umber")
c:px(21, 15, "#fff1c8"); c:px(21, 16, "#fff1c8")

-- bowl of fruit at back right
local bowl = c:ellipse(43, 31, 6.5, 4):cut(c:rect(0, 0, 63, 29))
bowl:add(c:rect(37, 29, 49, 30))
c:build{
  { "fruitG", c:ellipse(43, 23.5, 2.5), "moss", { gloss = false } },
  { "fruitY", c:ellipse(46.5, 26.5, 3), "gold" },
  { "fruitR", c:ellipse(39.5, 26.5, 3), "red" },
  { "bowl",   bowl, "wood" },
}
c:px(43, 20, "umber"); c:px(40, 23, "umber"); c:px(41, 22, "#7ab55c")

-- roast on an oval platter, front centre
c:build{
  { "platter", c:ellipse(35, 38, 7.5, 2.5), "cream", { gloss = false } },
  { "roast",   c:ellipse(34, 34, 5, 3.5):add(c:ellipse(34, 36, 5.5, 2)), roast, { gloss = { 31, 32 } } },
  { "bone",    c:rect(39, 31, 40, 33):add(c:rect(40, 29, 42, 31)), "cream", { flat = true } },
}
-- crisp score lines on the roast
c:px(32, 35, roast.shade); c:px(33, 34, roast.shade); c:px(35, 35, roast.shade); c:px(36, 34, roast.shade)
-- sprig of herb on the platter
c:paint({ ".g", "gg" }, 28, 37, { g = "#4a8a3e" })

-- fallen maple leaves: on the table and on the ground
local leaf = { "..a..", "aaaaa", ".aba.", "..b.." }
local function mleaf(x, y, a, b) c:paint(leaf, x, y, { a = a, b = b }) end
mleaf(44, 37, "#f08a24", "#b8661a")
mleaf(12, 47, "#dd3a2a", "#6b1b2c")
mleaf(35, 51, "#e8a317", "#b8661a")
mleaf(43, 46, "#dd3a2a", "#6b1b2c")
mleaf(19, 51, "#f08a24", "#b8661a")

c:ground(32, 55, 22, 1.5)
local t = c:save(O .. "aseprite/ph/feast-maplewold-table.aseprite", O .. "png/ph/feast-maplewold-table.png")
print(GV.report(t))
