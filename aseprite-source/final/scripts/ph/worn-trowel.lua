local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local handle = c:line({ {40,38}, {50,52} }, 6):add(c:ellipse(50.5,52.5,3.5))
local blade = c:poly({ {11,9}, {20,13}, {30,18}, {38,26}, {40,33}, {36,37}, {29,36}, {21,30}, {15,21} })
blade:cut(c:poly({ {11,9}, {15,10}, {13,13} }))   -- chipped notch at the tip
local ferrule = c:poly({ {35,34}, {40,29}, {45,34}, {40,39} })
local p = c:build{
  { "handle", handle, GV.ramp("#a8582f") },
  { "blade", blade, "stone" },
  { "ferrule", ferrule, GV.ramp("#c9c5bc"), { gloss = false } },
}
-- scoop: lighter inner leaf
local scoop = c:poly({ {17,16}, {25,19}, {32,25}, {35,31}, {31,32}, {24,27}, {19,21} })
c:fill(scoop, "#c9c5bc")
c:fill(c:line({ {18,17}, {33,31} }, 1), "#a9aab0")
c:spot(c:ellipse(23,25,1.5,1), "#a8582f", "#d9885a")
c:spot(c:ellipse(31,34,1,1), "#a8582f", "#d9885a")
c:spot(c:ellipse(28,20,1,1), "#a8582f", "#d9885a")
c:gloss(blade, GV.R.stone, { 16, 15 })
c:seam({ {42,43}, {47,39} }, { on = 2, off = 1 })
c:seam({ {44,46}, {49,42} }, { on = 2, off = 1 })
local t = c:save(O .. "aseprite/ph/worn-trowel.aseprite", O .. "png/ph/worn-trowel.png")
print(GV.report(t))
