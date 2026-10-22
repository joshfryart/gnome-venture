local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local rim = c:ellipse(31.5, 31.5, 24, 24)
local face = c:ellipse(31.5, 31.5, 17, 17)
local p = c:build{
  { "rim", rim, GV.ramp("#a5663a") },
  { "face", face, GV.ramp("#f8eed2") },
}
-- hour ticks (chunky 3x3)
local tick = "#8c4a1a"
c:fill(c:rect(30, 16, 32, 18), tick)
c:fill(c:rect(45, 30, 47, 32), tick)
c:fill(c:rect(30, 44, 32, 46), tick)
c:fill(c:rect(16, 30, 18, 32), tick)
-- hands: L from centre, up to 12 and right to 3
local hand = "#4a2c1a"
c:fill(c:rect(30, 20, 33, 33), hand)
c:fill(c:rect(30, 30, 42, 33), hand)
-- gold hub
c:part(c:ellipse(31.5, 31.5, 3, 3), "gold", { flat = true })
local t = c:save(O .. "aseprite/ico/ico-clock.aseprite", O .. "png/ico/ico-clock.png")
print(GV.report(t))
