local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local glass = GV.ramp("#c8ecdc")
local jar = c:rrect(17, 21, 47, 55, 6)
jar:add(c:rect(23, 15, 41, 22))
local p = c:build{
  { "jar", jar, glass, { gloss = false } },
  { "cork", c:rrect(21, 7, 43, 17, 2), "wood" },
  { "seed", c:ellipse(32.5, 41, 8.5, 8), "moss", { gloss = { 27, 36 } } },
  { "leaf", c:ellipse(36.5, 30, 3.5, 2), GV.ramp("#58a03e"), { flat = true } },
}
c:fill(c:rect(32, 29, 33, 33), "#2e5a2c")
-- glass shine streaks
c:fill(c:rect(21, 26, 22, 44), "#f4f0e0")
c:fill(c:rect(21, 47, 22, 49), "#f4f0e0")
c:px(21, 26, "#ffffff")
c:fill(c:rect(42, 28, 42, 34), "#f4f0e0")
-- cork grain
c:paint({ "w..w...w", "..w...w." }, 26, 11, { w = "#8a4f2a" })
c:seam({ {22, 17}, {42, 17} })
local t = c:save(D .. "img-redraw-full/aseprite/ph/senegal-coral-tree-seed.aseprite", D .. "img-redraw-full/png/ph/senegal-coral-tree-seed.png")
print(GV.report(t))
