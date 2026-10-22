local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local glass = c:poly({ {18,14}, {47,14}, {34,31}, {34,34}, {47,51}, {18,51}, {30,34}, {30,31} })
glass:add(c:rect(30, 29, 33, 35))
local topSand = c:poly({ {23,18}, {42,18}, {33,29}, {31,29} })
local botSand = c:poly({ {30,40}, {34,40}, {44,50}, {20,50} })
botSand:add(c:ellipse(32, 47, 7, 4))
botSand:clip(glass)
local fall = c:rect(31, 29, 32, 41)
c:build{
  { "glass", glass,   "#bcd8e0", { gloss = false } },
  { "sand",  topSand, "#dcb06a", { contact = false } },
  { "pile",  botSand, "#dcb06a", { gloss = { 29, 44 } } },
  { "fall",  fall,    "#dcb06a", { flat = true, contact = false } },
  { "top",   c:rrect(12, 7, 52, 14, 2),  "#c4925f" },
  { "bot",   c:rrect(12, 50, 52, 57, 2), "#c4925f" },
}
-- glass glints
c:fill(c:line({ {21,17}, {26,23} }, 1), "#eef8fa")
c:fill(c:line({ {22,48}, {25,44} }, 1), "#eef8fa")
-- wood grain on caps
c:fill(c:rect(20, 11, 27, 11), "#a8582f"); c:fill(c:rect(38, 10, 44, 10), "#a8582f")
c:fill(c:rect(22, 54, 30, 54), "#a8582f"); c:fill(c:rect(40, 53, 46, 53), "#a8582f")
local t = c:save(D .. "img-redraw-full/aseprite/ico/ico-hourglass.aseprite", D .. "img-redraw-full/png/ico/ico-hourglass.png")
print(GV.report(t))
