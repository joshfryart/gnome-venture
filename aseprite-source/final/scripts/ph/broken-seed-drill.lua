local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local box = c:rrect(10, 17, 47, 35, 4)
box:cut(c:poly({ {9,30}, {15,36}, {9,36} }))  -- chipped corner
local p = c:build{
  { "crank",  c:line({ {44,25}, {51,19} }, 5), GV.ramp("#d9a660") },
  { "knob",   c:ellipse(52, 17.5, 2.5), "wood" },
  { "legL",   c:rrect(15, 32, 20, 49, 2), "wood" },
  { "legR",   c:rrect(37, 32, 42, 49, 2), "wood" },
  { "box",    box, GV.ramp("#8a4f2a") },
  { "dial",   c:ellipse(29, 25, 5), "wood" },
  { "splint", c:poly({ {44,48}, {50,46}, {51,49}, {45,51} }), "wood", { flat = true } },
  { "chip",   c:poly({ {9,50}, {13,48}, {14,51} }), "wood", { flat = true } },
}
c:px(29, 25, "#5e2f1e"); c:px(29, 22, "#5e2f1e")
-- crack across the hopper
c:fill(c:line({ {31,17}, {33,21}, {35,25}, {33,30}, {35,35} }, 2):clip(p.box.m), "#2a1a10")
-- cracked leg
c:fill(c:line({ {18,38}, {17,41}, {18,44} }, 1):clip(p.legL.m), "#2a1a10")
c:seam({ {13, 19}, {44, 19} })
c:ground(29, 50, 17, 1.5)
local t = c:save(O .. "aseprite/ph/broken-seed-drill.aseprite", O .. "png/ph/broken-seed-drill.png")
print(GV.report(t))
