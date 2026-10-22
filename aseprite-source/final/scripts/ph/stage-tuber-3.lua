local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leftLeaf  = c:poly({ {25, 47}, {16, 44}, {10, 37}, {8, 27}, {15, 28}, {22, 33}, {27, 40}, {29, 47} })
local midLeaf   = c:poly({ {28, 47}, {23, 38}, {22, 26}, {26, 13}, {31, 21}, {33, 33}, {32, 47} })
local rightLeaf = c:poly({ {32, 47}, {33, 37}, {37, 27}, {45, 17}, {49, 22}, {47, 33}, {41, 41}, {36, 47} })
local p = c:build{
  { "mound", c:ellipse(32, 49, 21, 7), GV.ramp("#8c4a1a") },
  { "top",   c:ellipse(32, 47, 17, 4), GV.ramp("#a5663a"), { gloss = false } },
  { "right", rightLeaf, GV.ramp("#8fc068") },
  { "mid",   midLeaf, GV.ramp("#58a03e") },
  { "left",  leftLeaf, "moss" },
}
c:fill(c:line({ {26, 45}, {19, 38}, {12, 30} }, 1), GV.R.moss.shade)
c:fill(c:line({ {30, 45}, {27, 33}, {26, 19} }, 1), "#2f5a2a")
c:fill(c:line({ {34, 45}, {38, 34}, {45, 22} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/stage-tuber-3.aseprite", O .. "png/ph/stage-tuber-3.png")
print(GV.report(t))
