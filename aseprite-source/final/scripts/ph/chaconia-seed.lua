local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local corners = c:poly({ {19, 20}, {22, 8}, {29, 20} })
corners:add(c:poly({ {35, 20}, {42, 8}, {46, 20} }))
local belly = c:ellipse(32, 39, 19, 16)
local neck = c:poly({ {25, 17}, {39, 17}, {42, 28}, {22, 28} })
local str = c:rrect(23, 23, 41, 27, 1)
local p = c:build{
  { "corners", corners, "cream" },
  { "belly", belly, "cream" },
  { "neck", neck, GV.ramp("#e6d9b0") },
  { "lump", c:ellipse(32, 44, 5, 5), "moss", { contour = false } },
  { "string", str, "wood", { gloss = false } },
  { "knot", c:ellipse(32, 25, 3, 3), "wood", { gloss = false } },
}
c:stitch(p.belly.m:copy():cut(c:rect(0, 0, 63, 30)))
c:line({ {29, 27}, {24, 33} }, 2)
c:line({ {35, 27}, {40, 32} }, 2)
c:fill(c:line({ {29, 27}, {24, 33} }, 2), GV.R.wood.base)
c:fill(c:line({ {35, 27}, {40, 32} }, 2), GV.R.wood.shade)
c:fill(c:line({ {25, 31}, {23, 37}, {23, 43} }, 1), "#dcb06a")
c:fill(c:line({ {39, 31}, {41, 37}, {41, 43} }, 1), "#dcb06a")
c:seam({ {24, 25}, {28, 25} }); c:seam({ {36, 25}, {40, 25} })
local t = c:save(O .. "aseprite/ph/chaconia-seed.aseprite", O .. "png/ph/chaconia-seed.png")
print(GV.report(t))
