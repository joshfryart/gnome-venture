local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lopsided slumped sack: wider bottom, leaning right
local sack = c:poly({ {22,24}, {42,24}, {50,36}, {54,50}, {52,57}, {11,57}, {10,48}, {14,34} })
sack:add(c:ellipse(32, 50, 21, 7))
sack:add(c:ellipse(40, 49, 14, 8))
local neck = c:poly({ {24,13}, {40,13}, {38,25}, {26,25} })
local frill = c:poly({ {19,8}, {26,11}, {32,7}, {38,11}, {45,7}, {43,15}, {21,15} })
local twine = c:rect(23, 22, 41, 24)
local knot = c:rrect(29, 20, 34, 26, 2)
local patch = c:rrect(20, 31, 43, 52, 6)
c:build{
  { "sack",  sack,  "#c9a96e" },
  { "neck",  neck,  "#c9a96e", { gloss = false } },
  { "frill", frill, "#c9a96e", { gloss = false } },
  { "twine", twine, "#7a4a1f", { flat = true } },
  { "knot",  knot,  "#7a4a1f", { gloss = false } },
  { "patch", patch, "#f4f0e0", { gloss = false } },
}
-- twine tails
c:line({ {30,26}, {28,30} }, 2); c:fill(c:line({ {30,26}, {28,30} }, 2), "#7a4a1f")
c:fill(c:line({ {34,26}, {37,29} }, 2), "#7a4a1f")
-- patch ring
c:fill(patch:copy():cut(patch:shrink(1)), "#dcb06a")
-- dill leaf emblem
local leaf = c:poly({ {31,33}, {33,33}, {39,42}, {37,49}, {32,51}, {27,49}, {25,42} })
c:part(leaf, "moss", { gloss = { 28, 40 }, contact = false })
c:fill(c:line({ {32,35}, {32,49} }, 1), "#2e5a2c")
c:fill(c:line({ {32,42}, {28,39} }, 1), "#2e5a2c")
c:fill(c:line({ {32,42}, {36,39} }, 1), "#2e5a2c")
c:fill(c:line({ {32,46}, {29,44} }, 1), "#2e5a2c")
c:fill(c:line({ {32,46}, {35,44} }, 1), "#2e5a2c")
-- weave marks
c:fill(c:rect(14, 40, 15, 40), "#9a6b3f"); c:fill(c:rect(15, 46, 16, 46), "#9a6b3f")
c:fill(c:rect(47, 40, 48, 40), "#9a6b3f"); c:fill(c:rect(16, 34, 17, 34), "#9a6b3f")
c:fill(c:rect(48, 47, 49, 47), "#9a6b3f")
-- frill folds
c:px(26, 13, "#9a6b3f"); c:px(32, 12, "#9a6b3f"); c:px(38, 13, "#9a6b3f")
c:ground(32, 58, 20, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/dill-seed.aseprite", D .. "img-redraw-full/png/ph/dill-seed.png")
print(GV.report(t))
