local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pod = c:poly({ {9,41},{14,32},{22,25},{32,20},{43,17},{55,16},{56,19},{50,25},{42,31},{33,37},{23,42},{14,45} })
local stem = c:line({ {11,41},{6,46} }, 3)
local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "pod", pod, "moss" },
  { "pea1", c:ellipse(22, 29, 6), GV.ramp("#b9cf62") },
  { "pea2", c:ellipse(32, 24, 6), GV.ramp("#b9cf62") },
  { "pea3", c:ellipse(42, 20, 5.5), GV.ramp("#b9cf62") },
}
local ridge = c:line({ {15,41},{24,38},{33,33},{42,27},{50,22} }, 2)
ridge:cut(p.pea1.m:grow(1)); ridge:cut(p.pea2.m:grow(1)); ridge:cut(p.pea3.m:grow(1))
ridge:clip(p.pod.m:shrink(2))
c:fill(ridge, "#4a8a3e")
local t = c:save(O .. "aseprite/ph/pigeon-pea.aseprite", O .. "png/ph/pigeon-pea.png")
print(GV.report(t))
