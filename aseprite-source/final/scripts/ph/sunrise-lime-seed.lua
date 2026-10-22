local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tin = GV.ramp("#8b8f96")
local lidR = GV.ramp("#c9c5bc")
local lid = c:poly({ {13, 27}, {51, 27}, {46, 6}, {18, 6} })
local hinge = c:rect(15, 26, 48, 28)
local back = c:rect(14, 29, 49, 36)
local lime = c:ellipse(31.5, 31, 10.5, 10)
local leaf = c:ellipse(40.5, 20, 3, 2)
local box = c:rrect(11, 36, 52, 55, 3)
local rimbar = c:rect(11, 36, 52, 40)
local p = c:build{
  { "lid",   lid,   lidR, { gloss = { 20, 9 } } },
  { "hinge", hinge, GV.ramp("#5b6470"), { flat = true } },
  { "back",  back,  GV.ramp("#5b6470"), { gloss = false, rim = false } },
  { "lime",  lime,  GV.ramp("#7ab55c"), { gloss = { 26, 26 } } },
  { "leaf",  leaf,  "leaf", { flat = true } },
  { "box",   box,   tin },
  { "rim",   rimbar, lidR, { gloss = false } },
}
-- stem
c:fill(c:rect(35, 19, 36, 22), "#2f5a2a")
-- sun on lid: half disc + rays
local sun = c:ellipse(31.5, 18, 7, 7):clip(c:rect(0, 0, 63, 18))
sun:cut(lime:grow(1)); sun:cut(leaf:grow(1)); c:fill(sun, "#f08a24")
c:fill(sun:copy():cut(c:ellipse(31.5, 18, 5, 5)):clip(c:rect(32, 0, 63, 18)), "#e0501f")
c:px(28, 13, "#f5cf6a"); c:px(29, 13, "#f5cf6a")
c:fill(c:rect(31, 7, 32, 9), "#f5cf6a")
c:fill(c:line({ {22, 9}, {23, 10} }, 2), "#f5cf6a")
c:fill(c:line({ {41, 9}, {40, 10} }, 2), "#f5cf6a")
c:fill(c:rect(22, 19, 41, 19):cut(lime:grow(1)):cut(leaf:grow(1)), "#8b8f96")
-- lid inner frame
c:fill(c:poly({ {16, 26}, {48, 26}, {47, 24}, {16, 24} }):cut(lime:grow(1)):cut(leaf:grow(1)), "#8b8f96")
-- hinge rivet row
for x = 18, 46, 4 do c:px(x, 27, "#c9c5bc") end
-- rivets on the box
for _, x in ipairs({ 17, 45 }) do
  c:fill(c:rect(x, 45, x + 1, 46), "#c9c5bc"); c:px(x + 1, 46, "#5b6470")
end
-- lime peel dots
c:px(28, 36, "#4a8a3e"); c:px(35, 30, "#4a8a3e"); c:px(25, 31, "#a4b86a")
c:ground(32, 57, 18, 2.5, "#6a4528")
local t = c:save(O .. "aseprite/ph/sunrise-lime-seed.aseprite", O .. "png/ph/sunrise-lime-seed.png")
print(GV.report(t))
