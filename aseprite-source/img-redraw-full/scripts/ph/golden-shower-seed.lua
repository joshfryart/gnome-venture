local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
local kraft = GV.ramp("#dcb06a")

local cone = c:poly({ {14, 25}, {51, 25}, {35, 56}, {30, 56} })
cone:add(c:rrect(29, 51, 34, 57, 2))
local tab = c:poly({ {41, 25}, {49, 25}, {50, 20}, {47, 17}, {51, 13}, {48, 9}, {44, 12}, {46, 16}, {42, 20} })
local p = c:build{
  { "tab", tab, kraft, { gloss = false } },
  { "cone", cone, paper, { light = cone:copy():add(tab) } },
  { "lip", c:ellipse(32.5, 25, 18, 3.5), GV.ramp("#f4f0e0"), { gloss = false } },
  { "inside", c:ellipse(32.5, 24.5, 15, 2), GV.ramp("#c9a96e"), { flat = true, contour = false, contact = false } },
  { "seed", c:ellipse(29.5, 19.5, 7.5, 7.5), "dusk", { gloss = { 25, 15 } } },
}
-- twist line across the tab
c:fill(c:line({ {43, 21}, {48, 18} }, 2), "#8c4a1a")
c:fill(c:line({ {45, 13}, {49, 12} }, 1), "#8c4a1a")
-- diagonal wrap band with thread seam
local band = c:line({ {18, 30}, {35, 53} }, 2):clip(cone:shrink(2))
c:fill(band, "#dcb06a")
c:seam({ {20, 30}, {36, 51} })
-- leaf on the seed
c:fill(c:rect(29, 9, 30, 12), "#4a8a3e")
c:paint({ ".lll.", "lllll", ".lll." }, 31, 7, { l = "#58a03e" })
c:px(32, 7, "#c8d77a")
local t = c:save(O .. "aseprite/ph/golden-shower-seed.aseprite", O .. "png/ph/golden-shower-seed.png")
print(GV.report(t))
