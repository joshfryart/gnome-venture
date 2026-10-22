local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "post", c:rect(29, 32, 34, 52), GV.ramp("#6a6070") },
  { "plinth", c:rrect(24, 50, 39, 54, 2), GV.ramp("#5b6470") },
  { "lantern", c:rrect(20, 16, 43, 35, 4), GV.ramp("#f5cf6a") },
  { "glow", c:ellipse(31.5, 25.5, 6, 6), "gold", { gloss = { 28, 22 } } },
  { "roof", c:poly({ {16, 18}, {32, 9}, {48, 18} }), GV.ramp("#6a6070") },
  { "finial", c:rect(31, 7, 32, 9), "#8b8f96", { flat = true } },
}
-- lantern panes: vertical frame bars
c:fill(c:rect(22, 19, 22, 33), "#b8661a"); c:fill(c:rect(41, 19, 41, 33), "#b8661a")
c:seam({ {18, 17}, {46, 17} }, { free = true })
c:button(30, 36)
c:ground(31.5, 55, 10, 1.5)
local t = c:save(O .. "aseprite/ph/amber-lamppost.aseprite", O .. "png/ph/amber-lamppost.png")
print(GV.report(t))
