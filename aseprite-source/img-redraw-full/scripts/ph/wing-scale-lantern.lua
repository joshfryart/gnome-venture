local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local post = c:rect(29, 34, 34, 54)
local foot = c:rrect(23, 52, 40, 57, 2)
local box = c:rrect(19, 15, 44, 36, 5)
local roof = c:poly({ {14,17},{32,4},{50,17} })
local lip = c:rect(16, 15, 47, 18)
local p = c:build{
  { "post", post, GV.ramp("#6a6070") },
  { "foot", foot, GV.ramp("#6a6070") },
  { "box", box, "gold", { cres = 4 } },
  { "flame", c:ellipse(31.5, 26, 6, 6), GV.ramp("#f08a24"), { gloss = false } },
  { "roof", roof, GV.ramp("#6a6070") },
  { "lip", lip, "leg", { flat = true } },
}
c:px(29, 23, "#fff1c8"); c:px(30, 23, "#ffc27a"); c:px(29, 24, "#ffc27a")
c:seam({ {17,16},{46,16} })
c:ground(31.5, 58, 11, 1)
local t = c:save(O .. "aseprite/ph/wing-scale-lantern.aseprite", O .. "png/ph/wing-scale-lantern.png")
print(GV.report(t))
