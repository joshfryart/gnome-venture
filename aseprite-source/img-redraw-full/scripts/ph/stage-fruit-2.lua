local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(31.5, 48, 21, 7)
local top = c:ellipse(31.5, 46, 16, 4)
local lleaf = c:poly({ {31,46}, {23,44}, {17,38}, {15,29}, {22,31}, {28,36}, {32,43} })
local rleaf = c:poly({ {33,46}, {41,44}, {47,38}, {49,29}, {42,31}, {36,36}, {32,43} })
local cleaf = c:poly({ {29,46}, {26,37}, {27,29}, {32,20}, {37,29}, {38,37}, {35,46} })
c:build{
  { "mound", mound, GV.ramp("#8c4a1a") },
  { "top", top, GV.ramp("#a5663a"), { gloss = false } },
  { "lleaf", lleaf, "moss" },
  { "rleaf", rleaf, "moss", { gloss = false } },
  { "cleaf", cleaf, GV.ramp("#58a03e") },
}
c:fill(c:line({ {32, 43}, {32, 26} }, 1), "#3e7a2e")
c:fill(c:line({ {29, 42}, {24, 37}, {19, 32} }, 1), "#4a8a3e")
c:fill(c:line({ {35, 42}, {40, 37}, {45, 32} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/stage-fruit-2.aseprite", O .. "png/ph/stage-fruit-2.png")
print(GV.report(t))
