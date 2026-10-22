local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- cone: wide top rolled edge, point at bottom
local cone = c:poly({ {14, 22}, {50, 22}, {33, 56}, {31, 56} })
cone:add(c:ellipse(32, 22, 18, 3))
-- gathered twist: neck narrowing above cone mouth, then a small flared tip
local twist = c:poly({ {19, 21}, {45, 21}, {37, 13}, {27, 13} })
local tip = c:ellipse(32, 10, 5, 3.5)
local leaf = c:poly({ {32, 25}, {38, 33}, {38, 39}, {32, 45}, {26, 39}, {26, 33} })
leaf:add(c:ellipse(32, 36, 6, 7))
local p = c:build{
  { "cone",  cone,  GV.ramp("#f1ece0") },
  { "twist", twist, GV.ramp("#dcb06a") },
  { "tip",   tip,   GV.ramp("#dcb06a") },
  { "leaf",  leaf,  GV.ramp("#7ab55c") },
}
-- twist pleats
c:fill(c:line({ {29, 14}, {27, 20} }, 1), "#a8782f")
c:fill(c:line({ {35, 14}, {37, 20} }, 1), "#a8782f")
c:fill(c:line({ {32, 8}, {32, 12} }, 1), "#a8782f")
-- fold line on the paper
c:fill(c:line({ {33, 53}, {42, 26} }, 1), "#dcb06a")
c:fill(c:line({ {34, 53}, {43, 26} }, 1), "#c9a96e")
-- leaf midrib and veins
local v = "#2f5a2a"
c:fill(c:line({ {32, 28}, {32, 43} }, 1), v)
c:fill(c:line({ {32, 32}, {29, 30} }, 1), v); c:fill(c:line({ {32, 32}, {35, 30} }, 1), v)
c:fill(c:line({ {32, 36}, {28, 34} }, 1), v); c:fill(c:line({ {32, 36}, {36, 34} }, 1), v)
c:fill(c:line({ {32, 40}, {29, 38} }, 1), v); c:fill(c:line({ {32, 40}, {35, 38} }, 1), v)
-- seeds on the lower belly
c:fill(c:rect(29, 48, 30, 49), "#8c4a1a"); c:fill(c:rect(33, 48, 34, 49), "#8c4a1a")
c:fill(c:rect(31, 51, 32, 52), "#8c4a1a")
c:seam({ {18, 21}, {46, 21} })
local t = c:save(O .. "aseprite/ph/oregano-seed.aseprite", O .. "png/ph/oregano-seed.png")
print(GV.report(t))
