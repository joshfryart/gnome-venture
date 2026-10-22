local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stem = c:line({ {31, 27}, {31, 15} }, 2)
local leafL = c:poly({ {32, 21}, {27, 20}, {23, 16}, {22, 11}, {27, 12}, {31, 16} }):closed(2)
local leafR = c:poly({ {32, 19}, {37, 18}, {41, 14}, {42, 8}, {37, 9}, {33, 13} }):closed(2)
local pot  = c:poly({ {17, 32}, {48, 32}, {44, 55}, {21, 55} })
local rim  = c:rrect(14, 26, 49, 34, 2)
c:build{
  { "stem",  stem,  "#2e5a2c", { flat = true } },
  { "leafL", leafL, GV.ramp("#58a03e"), { gloss = { 24, 13 } } },
  { "leafR", leafR, GV.ramp("#58a03e"), { gloss = { 36, 11 } } },
  { "pot",   pot,   GV.ramp("#e0501f", { shade = "#ae2a2a", deep = "#6b1b2c" }), { gloss = { 23, 37 } } },
  { "rim",   rim,   GV.ramp("#d6322b", { shade = "#ae2a2a", deep = "#6b1b2c" }), { gloss = { 18, 28 } } },
}
-- leaf veins
c:fill(c:line({ {31, 18}, {26, 15}, {24, 13} }, 1):clip(leafL), "#3e7a32")
c:fill(c:line({ {33, 16}, {37, 13}, {39, 11} }, 1):clip(leafR), "#3e7a32")
-- clay grain
c:fill(c:line({ {22, 38}, {40, 38} }, 1), "#8a4f2a")
c:fill(c:line({ {26, 44}, {41, 44} }, 1), "#8a4f2a")
-- rim seam
c:seam({ {16, 33}, {47, 33} })
c:ground(32, 57, 17, 3.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/flower-pot.aseprite", D .. "img-redraw-full/png/ph/flower-pot.png")
print(GV.report(t))
