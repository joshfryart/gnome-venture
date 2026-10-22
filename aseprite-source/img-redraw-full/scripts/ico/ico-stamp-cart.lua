local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local p = c:build{
  { "handle", c:line({ {43, 27}, {50, 16} }, 4), "#b6814d" },
  { "stampA", c:ellipse(22.5, 22, 6), "#58a03e" },
  { "stampB", c:ellipse(34.5, 20, 6), "#7fbf5a" },
  { "basket", c:poly({ {12, 26}, {48, 26}, {42, 43}, {18, 43} }), GV.ramp("#a5663a") },
  { "wheelA", c:ellipse(21.5, 46, 4.5), "#3a2e2a" },
  { "wheelB", c:ellipse(38.5, 46, 4.5), "#3a2e2a" },
}
c:fill(c:rect(15, 32, 44, 33):clip(p.basket.m:shrink(2)), "#8a4f2a")
c:fill(c:rect(17, 37, 42, 38):clip(p.basket.m:shrink(2)), "#8a4f2a")
c:seam({ {14, 28}, {46, 28} })
c:fill(c:rect(21, 45, 22, 46), "#5e2a3a"); c:fill(c:rect(38, 45, 39, 46), "#5e2a3a")
local t = c:save(O .. "aseprite/ico/ico-stamp-cart.aseprite", O .. "png/ico/ico-stamp-cart.png")
print(GV.report(t))
