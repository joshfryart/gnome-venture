local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local stone = GV.ramp("#6a6070", { rim = "#8b8f96" })
local p = c:build{
  { "post", c:rrect(28, 32, 35, 53, 2), stone },
  { "slab", c:rrect(22, 50, 41, 54, 2), GV.ramp("#5b6470") },
  { "lamp", c:rrect(19, 15, 44, 35, 4), "gold", { gloss = { 23, 19 } } },
  { "glow", c:ellipse(32, 25, 6, 6), GV.ramp("#e8a317"), { gloss = false, rim = false } },
  { "roof", c:poly({ {14, 17}, {32, 8}, {50, 17} }):add(c:rect(16, 15, 47, 18)), stone },
  { "cap",  c:rrect(29, 6, 34, 10, 1), stone, { flat = true } },
}
c:paint({ ".s.", "sss", ".s." }, 29, 21, { s = "#fff1c8" })
-- lamp frame bars
c:fill(c:rect(19, 25, 23, 26), "#b8661a")
c:fill(c:rect(41, 25, 44, 26), "#b8661a")
local t = c:save(O .. "aseprite/ph/glowstone-lantern.aseprite", O .. "png/ph/glowstone-lantern.png")
print(GV.report(t))
