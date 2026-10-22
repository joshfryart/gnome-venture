local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:rrect(19, 10, 46, 52, 2)
local flap = c:poly({ {19, 10}, {47, 10}, {33, 27} })
-- hop leaf: three pointed lobes
local leaf = c:ellipse(32.5, 41, 6.5, 5)
leaf:add(c:poly({ {28, 38}, {33, 29}, {38, 38} }))
leaf:add(c:poly({ {26, 37}, {24, 41}, {27, 46}, {31, 42} }))
leaf:add(c:poly({ {39, 37}, {42, 41}, {39, 46}, {34, 42} }))
leaf:add(c:poly({ {28, 36}, {22, 36}, {26, 44} }))
leaf:add(c:poly({ {37, 36}, {44, 36}, {40, 44} }))
leaf:add(c:rect(32, 45, 33, 48))
local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { stitch = false } },
  { "flap", flap, GV.ramp("#dcb06a"), { cres = 3, deep = 1 } },
  { "leaf", leaf, "moss", { cres = 3, deep = 1 } },
}
local dk = "#2f5a2a"
c:fill(c:line({ {32, 45}, {32, 33} }, 2), dk)
c:fill(c:line({ {32, 42}, {27, 38} }, 1), dk)
c:fill(c:line({ {33, 42}, {38, 38} }, 1), dk)
-- bottom fold line
c:fill(c:rect(21, 50, 44, 50), "#dcb06a")
c:seam({ {21, 12}, {31, 24} })
c:seam({ {44, 12}, {35, 24} })
c:button(31, 24)
local t = c:save(O .. "aseprite/ph/hops-seed.aseprite", O .. "png/ph/hops-seed.png")
print(GV.report(t))
