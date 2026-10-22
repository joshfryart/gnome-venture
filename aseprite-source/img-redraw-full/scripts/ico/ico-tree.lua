local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local trunk = c:poly({ {24,52}, {40,52}, {37,47}, {36,36}, {28,36}, {27,47} })
local lobes = c:ellipse(19.5, 33, 8, 7.5):add(c:ellipse(43.5, 33, 8, 7.5))
local crown = c:ellipse(31.5, 25, 15, 14)
local all = lobes:copy():add(crown)
local leaf = GV.ramp("#7ab55c", { rim = "#a4b86a", shade = "#4a8a3e", deep = "#2f5a2a", gloss = "#c8d77a" })
c:build{
  { "trunk", trunk, "wood" },
  { "lobes", lobes, leaf, { light = all, gloss = false } },
  { "crown", crown, leaf, { light = all, gloss = { 22, 16 } } },
}
local dia = { ".t.", "ttt", ".t." }
c:paint(dia, 25, 22, { t = "#6a9a3a" })
c:paint(dia, 36, 29, { t = "#6a9a3a" })
c:paint(dia, 16, 32, { t = "#6a9a3a" })
c:paint(dia, 43, 18, { t = "#6a9a3a" })
local t = c:save(O .. "aseprite/ico/ico-tree.aseprite", O .. "png/ico/ico-tree.png")
print(GV.report(t))
