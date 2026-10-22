local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cone = c:poly({ {15, 26}, {50, 26}, {33, 50} })
local twist = c:rrect(29, 47, 35, 52, 2)
local rim = c:ellipse(32, 26, 17, 3)
local leaf = c:ellipse(32, 22, 12, 8)
leaf:add(c:poly({ {22, 19}, {43, 19}, {32, 10} }))
leaf:add(c:ellipse(22, 24, 5, 5)); leaf:add(c:ellipse(42, 24, 5, 5))
leaf:add(c:ellipse(25, 17, 4, 4)); leaf:add(c:ellipse(39, 17, 4, 4))
local p = c:build{
  { "twist", twist, "cream" },
  { "cone", cone, "cream", { light = cone:copy():add(twist) } },
  { "rim", rim, GV.ramp("#e46a9b"), { gloss = false } },
  { "leaf", leaf, GV.ramp("#58a03e") },
}
-- inner opening of the rim, cream
c:fill(c:ellipse(32, 26, 14, 1):cut(leaf), "#f4f0e0")
-- spiral band on the cone
local band = c:line({ {19, 30}, {36, 48} }, 2):clip(cone):cut(rim):cut(leaf)
c:fill(band, "#dcb06a")
c:seam({ {21, 30}, {37, 46} })
-- twist ring
c:fill(c:line({ {30, 49}, {34, 49} }, 1), "#dcb06a")
-- veins
c:fill(c:line({ {32, 29}, {32, 13} }, 2), "#2e5a2c")
c:fill(c:line({ {31, 23}, {24, 17} }, 1), "#2e5a2c")
c:fill(c:line({ {33, 18}, {40, 14} }, 1), "#2e5a2c")
c:fill(c:line({ {33, 25}, {40, 21} }, 1), "#2e5a2c")
local t = c:save(O .. "aseprite/ph/collard-seed.aseprite", O .. "png/ph/collard-seed.png")
print(GV.report(t))
