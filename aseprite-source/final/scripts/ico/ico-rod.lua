local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R

local rod = c:line({ {11, 52}, {42, 12} }, 4)
local fishline = c:line({ {42, 12}, {48, 11}, {53, 13}, {55, 17}, {54, 22}, {51, 27}, {50, 30} }, 2)
local float = c:ellipse(49.5, 40, 6, 6)
local band = c:rect(44, 38, 55, 42):clip(float)

c:build{
  { "line",  fishline, "#4a2c1a", { flat = true, contour = false } },
  { "rod",   rod, GV.ramp("#b07a45", { rim = "#d9a660" }) },
  { "float", float, "red" },
  { "band",  band, "cream", { gloss = false, contact = false } },
}
-- handle wrap: thread gold bands near the butt
c:seam({ {14, 46}, {18, 49} }, { on = 1, off = 1 })
c:seam({ {16, 43}, {20, 46} }, { on = 1, off = 1 })

local t = c:save(O .. "aseprite/ico/ico-rod.aseprite", O .. "png/ico/ico-rod.png")
print(GV.report(t))
