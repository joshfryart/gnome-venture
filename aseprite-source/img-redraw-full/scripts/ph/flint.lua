local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy flat-bottomed stone, peak at upper left, chipped notch on top right
local stone = c:poly({
  {9, 54}, {8, 46}, {10, 38}, {15, 30}, {21, 25}, {28, 22}, {33, 23},
  {37, 27}, {41, 29}, {46, 31}, {50, 35}, {54, 41}, {55, 48}, {55, 55},
})
stone = stone:closed(3)
stone:cut(c:poly({ {37, 26}, {41, 26}, {39, 30} }))
c:build{
  { "stone", stone, GV.ramp("#968f96", { shade = "#5b6470" }), { gloss = { 20, 30 } } },
}
-- dark underside band
c:fill(c:line({ {11, 47}, {20, 49}, {32, 50}, {44, 49}, {53, 47} }, 3):clip(stone:shrink(2)), "#6a6070")
-- chip facets
c:fill(c:line({ {17, 28}, {31, 28} }, 1):clip(stone:shrink(2)), "#c9c5bc")
c:fill(c:line({ {15, 34}, {21, 34} }, 1):clip(stone:shrink(2)), "#c9c5bc")
c:px(32, 29, "#c9c5bc"); c:px(22, 35, "#c9c5bc")
-- spark nick
c:fill(c:rect(46, 40, 47, 41), "#f08a24"); c:px(46, 40, "#ffc27a")
c:ground(32, 57, 17, 3.5, "#6a4528")
local t = c:save(D .. "img-redraw-full/aseprite/ph/flint.aseprite", D .. "img-redraw-full/png/ph/flint.png")
print(GV.report(t))
