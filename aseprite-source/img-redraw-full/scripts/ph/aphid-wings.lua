local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local L = c:ellipse(21, 37, 12, 11):add(c:poly({ {14,30},{32,26},{33,48},{20,47} }))
local R = c:ellipse(42, 37, 12, 11):add(c:poly({ {32,26},{49,30},{43,47},{31,48} }))
local notch = c:poly({ {28,24},{36,24},{32,30} }):add(c:poly({ {29,51},{35,51},{32,46} }))
L:cut(notch); R:cut(notch)
local all = L:copy():add(R)
local ramp = GV.ramp("#7ab55c", { rim = "#c8d77a" })
local p = c:build{
  { "left",  L, ramp, { light = all } },
  { "right", R:copy():cut(L:copy():shrink(0)), ramp, { light = all, gloss = false } },
}
-- small veins
c:fill(c:line({ {14,36},{21,41},{25,46} }, 1):clip(L:shrink(2)), "#2f5a2a")
c:fill(c:line({ {13,41},{18,44} }, 1):clip(L:shrink(2)), "#2f5a2a")
c:fill(c:line({ {50,36},{43,41},{39,46} }, 1):clip(R:shrink(2)), "#2f5a2a")
c:fill(c:line({ {50,41},{45,44} }, 1):clip(R:shrink(2)), "#2f5a2a")
-- mid vein arc
c:fill(c:line({ {13,35},{20,33},{26,31},{31,30},{36,31},{42,33},{49,35} }, 3):clip(all:shrink(2)), "#c8d77a")
-- centre fold
c:fill(c:line({ {31.5,27},{31.5,48} }, 2):clip(all:shrink(1)), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/aphid-wings.aseprite", O .. "png/ph/aphid-wings.png")
print(GV.report(t))
