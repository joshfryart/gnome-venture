local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local skin = GV.ramp("#7a5cc0", { gloss = "#a894dc", dot = "#fff3c8", shade = "#3e2f66", deep = "#291d4a" })
local tabs = c:poly({ {11,25}, {18,20}, {19,31} }):add(c:poly({ {53,25}, {46,20}, {45,31} }))
local sheet = c:poly({ {14,18}, {17,13}, {22,11}, {27,12}, {32,17}, {37,12}, {42,11}, {47,13}, {50,18},
  {48,25}, {45,32}, {51,43}, {45,53}, {39,45}, {32,53}, {25,45}, {19,53}, {13,43}, {19,32}, {16,25} })
c:build{
  { "tabs", tabs, skin, { gloss = false } },
  { "sheet", sheet, skin, { gloss = { 21, 17 } } },
}
local crease = "#4e3a8a"
c:fill(c:line({ {24,20}, {22,24}, {22,28}, {24,32} }, 2):clip(sheet), crease)
c:fill(c:line({ {35,24}, {33,28}, {33,32}, {35,36} }, 2):clip(sheet), crease)
c:fill(c:line({ {25,40}, {29,42}, {34,42}, {38,40} }, 2):clip(sheet), crease)
local t = c:save(O .. "aseprite/ph/shed-skin.aseprite", O .. "png/ph/shed-skin.png")
print(GV.report(t))
