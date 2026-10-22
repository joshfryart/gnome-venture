local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 40, 17, 14)
body:add(c:rrect(24, 48, 39, 56, 2))
local lid = c:ellipse(31.5, 24, 15, 8):cut(c:rect(0, 24, 63, 63))
local p = c:build{
  { "body", body, GV.ramp("#b0bc66") },
  { "neck", c:rect(21, 24, 42, 29), GV.ramp("#c8d77a") },
  { "lid",  lid, GV.ramp("#f4f0e0") },
  { "knob", c:ellipse(31.5, 13.5, 3, 3), "gold" },
  { "win",  c:ellipse(31.5, 43, 8, 7), GV.ramp("#7ab55c"), { gloss = false } },
  { "seed", c:ellipse(31.5, 45, 4.5, 3.5), GV.ramp("#dfe38a") },
}
c:fill(c:ellipse(31.5, 43, 8, 7):edge(), "#2f5a2a")
c:part(c:rect(31, 38, 32, 41), GV.ramp("#58a03e"), { flat = true })
c:part(c:poly({ {33, 38}, {36, 35}, {40, 35}, {38, 38}, {34, 40} }), GV.ramp("#58a03e"), { flat = true })
c:seam({ {22, 26}, {41, 26} })
c:button(30, 21)
local t = c:save(O .. "aseprite/ph/columbine-seed.aseprite", O .. "png/ph/columbine-seed.png")
print(GV.report(t))
