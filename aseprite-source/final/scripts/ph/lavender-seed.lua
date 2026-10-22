local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- plump sack, narrower at the neck, leaning slightly
local sack = c:ellipse(32.5, 42, 18, 14)
sack:add(c:poly({ {23,24}, {42,24}, {48,36}, {17,36} }))
-- gathered ruffle with wavy top
local ruff = c:poly({ {21,24}, {44,24}, {41,17}, {24,17} })
ruff:add(c:ellipse(24, 16, 3, 2.5)):add(c:ellipse(30, 14, 3, 2.5)):add(c:ellipse(36, 14, 3, 2.5)):add(c:ellipse(41, 16, 3, 2.5))
local p = c:build{
  { "sack", sack, GV.ramp("#b0bc66"), { stitch = { side = "lit" } } },
  { "ruff", ruff, GV.ramp("#c8d77a") },
  { "cord", c:rrect(21, 23, 44, 26, 1), GV.ramp("#c9a96e") },
}
-- seed patch: cream ring, sage seed
c:part(c:ellipse(32, 44, 8, 8), GV.ramp("#f4f0e0"), { gloss = false })
c:part(c:ellipse(32, 44, 4.5, 4.5), GV.ramp("#b0bc66"), { gloss = { 30, 42 } })
c:part(c:poly({ {38,40}, {41,35}, {46,34}, {44,38}, {39,41} }), GV.ramp("#58a03e"), { flat = true })
-- cord tails with beads
c:part(c:line({ {29,26}, {23,35} }, 2), GV.ramp("#c9a96e"), { flat = true })
c:part(c:line({ {36,26}, {41,33} }, 2), GV.ramp("#c9a96e"), { flat = true })
c:part(c:rrect(21, 34, 24, 37, 1), GV.ramp("#c9a96e"), { flat = true })
c:part(c:rrect(40, 33, 43, 36, 1), GV.ramp("#c9a96e"), { flat = true })
-- side seam
c:seam({ {47,30}, {50,40}, {48,50} })
local t = c:save(R .. "img-redraw-full/aseprite/ph/lavender-seed.aseprite", R .. "img-redraw-full/png/ph/lavender-seed.png")
print(GV.report(t))
