-- ph/meyer-lemon-seed : cream cloth bundle, cinched string neck with bow, flared gathered top, lemon stamp
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local cloth = GV.ramp("#f1ece0")

-- lumpy body: main ellipse plus two side lumps
local body = c:ellipse(31.5, 41, 16, 13):add(c:ellipse(22, 44, 8, 8)):add(c:ellipse(41, 44, 8, 8))
-- gathered top: flares out above the neck, frilled top edge
local top = c:poly({ {27, 27}, {37, 27}, {45, 15}, {19, 15} })
top:add(c:ellipse(21.5, 15.5, 3, 2)):add(c:ellipse(28, 14.5, 3, 2)):add(c:ellipse(35, 14.5, 3, 2)):add(c:ellipse(42, 15.5, 3, 2))

local p = c:build{
  { "body", body, cloth, { stitch = { side = "lit" } } },
  { "top",  top, cloth, { gloss = { 23, 17 } } },
  { "tie",  c:rrect(25, 25, 38, 29, 1), "wood", { gloss = false } },
  { "bowL", c:ellipse(21, 27, 3, 2.5), "wood", { flat = true } },
  { "bowR", c:ellipse(42, 27, 3, 2.5), "wood", { flat = true } },
}

-- fold lines on the gathered top
local fold = "#dcb06a"
c:fill(c:line({ {28, 18}, {29, 24} }, 1), fold)
c:fill(c:line({ {35, 18}, {34, 24} }, 1), fold)
c:fill(c:line({ {23, 18}, {26, 23} }, 1), fold)
c:fill(c:line({ {40, 18}, {37, 23} }, 1), fold)
-- string tails hanging from the knot
c:fill(c:line({ {30, 30}, {28, 34} }, 2), GV.R.wood.shade)
c:fill(c:line({ {33, 30}, {35, 34} }, 2), GV.R.wood.shade)

-- lemon stamp
c:paint({
  "......gg..",
  "..yyyygg..",
  ".yyyyyyy..",
  "yLyyyyyyyo",
  "yyyyyyyyoo",
  ".yyyyyyoo.",
  "..yyoooo..",
}, 27, 39, { y = "#f5cf6a", o = "#e8a317", L = "#fff1c8", g = "#7ab55c" })

local t = c:save(O .. "aseprite/ph/meyer-lemon-seed.aseprite", O .. "png/ph/meyer-lemon-seed.png")
print(GV.report(t))
