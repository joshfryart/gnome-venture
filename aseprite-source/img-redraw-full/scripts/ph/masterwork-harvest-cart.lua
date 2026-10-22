local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bin = c:poly({ {6,20}, {42,20}, {34,42}, {16,42} })
local p = c:build{
  { "handleB", c:line({ {36,24}, {52,15} }, 4), "wood" },
  { "leg",     c:line({ {33,38}, {40,52} }, 3), "wood", { flat = true } },
  { "handleF", c:line({ {28,38}, {51,48} }, 4), "wood" },
  { "bin",     bin, "gold" },
  { "rim",     c:rrect(5, 18, 43, 23, 1), GV.ramp("#f5cf6a") },
  { "wheel",   c:ellipse(19, 47, 8, 8), GV.ramp("#4a2c1a") },
  { "hub",     c:ellipse(19, 47, 2.5, 2.5), "gold", { gloss = false } },
}
-- wheel spokes
c:paint({ "s...s", ".....", ".....", ".....", "s...s" }, 17 - 2, 45 - 2, { s = "#74462a" })
c:seam({ {9, 21}, {40, 21} })
c:seam({ {14, 31}, {38, 31} })
c:ground(30, 56, 18, 2)
local t = c:save(D .. "img-redraw-full/aseprite/ph/masterwork-harvest-cart.aseprite", D .. "img-redraw-full/png/ph/masterwork-harvest-cart.png")
print(GV.report(t))
