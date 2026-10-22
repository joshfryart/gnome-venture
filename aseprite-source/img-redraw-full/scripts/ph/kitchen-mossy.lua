local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local roof = c:poly({ {7,36},{32,17},{58,36} })
local moss = c:ellipse(15, 30, 5, 2.5):add(c:ellipse(31.5, 19, 4, 2.5)):add(c:ellipse(52, 31.5, 4, 2))
moss:add(c:rect(10, 36, 11, 39)):add(c:rect(53, 36, 54, 40))
moss:add(c:ellipse(14, 53, 4, 2.5)):add(c:ellipse(42, 53.5, 7, 2.5))
local p = c:build{
  { "smoke",   c:ellipse(46, 8, 3.5, 3):add(c:ellipse(42.5, 10, 2, 2)), GV.ramp("#c9c5bc") },
  { "chimney", c:rect(40, 14, 46, 28), "stone" },
  { "cap",     c:rect(39, 12, 47, 15), GV.ramp("#5b6470") },
  { "wall",    c:rrect(11, 33, 52, 54, 2), GV.ramp("#d9a660") },
  { "roof",    roof, "red" },
  { "eave",    c:rrect(7, 34, 57, 37, 1), GV.ramp("#b8452f", { rim = "#ecc58a" }) },
  { "door",    c:rect(17, 44, 25, 54):add(c:ellipse(21, 44, 4, 4)), GV.ramp("#44281c") },
  { "window",  c:rrect(33, 40, 45, 48, 1), GV.ramp("#f5cf6a") },
  { "moss",    moss, "moss" },
}
c:fill(c:rect(29, 42, 31, 42), "#8a4f2a"); c:fill(c:rect(47, 42, 50, 42), "#8a4f2a")
c:fill(c:rect(27, 49, 31, 49), "#8a4f2a"); c:fill(c:rect(47, 49, 50, 49), "#8a4f2a")
c:fill(c:rect(38, 40, 39, 48), "#2a1a10"); c:fill(c:rect(33, 43, 45, 44), "#2a1a10")
c:fill(c:rect(23, 49, 24, 50), "#e8a317")
c:seam({ {9,35}, {55,35} })
c:ground(32, 57, 24, 1.5)
local t = c:save(D .. "img-redraw-full/aseprite/ph/kitchen-mossy.aseprite", D .. "img-redraw-full/png/ph/kitchen-mossy.png")
print(GV.report(t))
