local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local roots = c:line({ {12, 48}, {6, 46} }, 2)
roots:add(c:line({ {12, 50}, {6, 54} }, 2))
roots:add(c:line({ {13, 51}, {10, 57} }, 2))
roots:add(c:line({ {11, 46}, {7, 41} }, 2))
local stalk = c:line({ {16, 46}, {40, 26} }, 11)
local blade = c:line({ {38, 28}, {52, 15} }, 11)
blade:add(c:line({ {48, 16}, {55, 10} }, 7))
local p = c:build{
  { "roots", roots, "cream", { flat = true } },
  { "stalk", stalk, GV.ramp("#d8e4a8"), { gloss = { 20, 41 } } },
  { "blade", blade, GV.ramp("#4a8a3e"), { gloss = false } },
}
c:seam({ {33, 25}, {44, 37} }, { free = false })
local t = c:save(O .. "aseprite/ph/leek.aseprite", O .. "png/ph/leek.png")
print(GV.report(t))
