local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 28, 10, 8)
body:add(c:ellipse(31.5, 42, 17, 13))
body:add(c:poly({ {22, 28}, {42, 28}, {48, 38}, {15, 38} }))
body:add(c:ellipse(35, 22, 4, 3))  -- lumpy shoulder
local leaf = c:poly({ {34, 20}, {36, 14}, {40, 10}, {45, 8}, {44, 13}, {40, 18}, {35, 21} })
local p = c:build{
  { "stem", c:poly({ {30, 13}, {34, 13}, {34, 23}, {30, 23} }), GV.ramp("#35602c"), { gloss = false } },
  { "leaf", leaf, "leaf", { gloss = false } },
  { "body", body, GV.ramp("#7b66b4", { shade = "#3e2f66", deep = "#291d4a" }), { gloss = { 24, 29 } } },
}
c:fill(c:line({ {20, 41}, {23, 39}, {26, 41}, {29, 39}, {32, 41}, {35, 39}, {38, 41}, {41, 39}, {44, 41} }, 1):clip(p.body.m), "#a894dc")
local t = c:save(O .. "aseprite/ph/quince.aseprite", O .. "png/ph/quince.png")
print(GV.report(t))
