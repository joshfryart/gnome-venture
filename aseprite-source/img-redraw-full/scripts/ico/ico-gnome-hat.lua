-- ico/ico-gnome-hat : tall leaning hat with pom
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local beard = c:poly({ {21,38}, {43,38}, {41,46}, {36,52}, {33,55}, {31,55}, {28,52}, {23,46} })
local hat = c:poly({ {19,31}, {30,17}, {36,11}, {39,10}, {38,14}, {45,31} })

c:build{
  { "face",  c:ellipse(32, 37, 10, 9), GV.ramp("#e2b07a") },
  { "beard", beard, GV.ramp("#f1ece0") },
  { "nose",  c:ellipse(32, 39, 2.5, 2), "petal", { gloss = false } },
  { "hat",   hat, "red" },
  { "band",  c:rrect(17, 27, 47, 31, 1), GV.ramp("#c66b50") },
  { "pom",   c:ellipse(39.5, 10, 3, 3), GV.ramp("#f4f0e0") },
}
c:seam({ {18, 29}, {46, 29} })
c:eye(25, 33, true); c:eye(37, 33, true)
-- beard tufts
c:paint({ "s...s", "..s.." }, 30, 45, { s = GV.ramp("#f1ece0").shade })

local t = c:save(O .. "aseprite/ico/ico-gnome-hat.aseprite", O .. "png/ico/ico-gnome-hat.png")
print(GV.report(t))
