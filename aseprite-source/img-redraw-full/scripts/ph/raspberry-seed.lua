local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local paper = GV.ramp("#f4f0e0", { shade = "#dcb06a" })
local flapR = GV.ramp("#f1ece0", { shade = "#dcb06a" })
local pink  = GV.ramp("#e46a9b")
local dark  = GV.ramp("#a8241f")
local leaf  = GV.ramp("#58a03e")

-- packet body
local body = c:rrect(14, 15, 50, 52, 2)
-- folded flap: wide strip with a V notch point hanging down
local flap = c:poly({ {13, 10}, {52, 10}, {52, 19}, {33, 26}, {31, 26}, {13, 19} })

local p = c:build{
  { "body", body, paper },
  { "flap", flap, flapR, { gloss = { 17, 12 } } },
}
-- print border on the face
c:fill(c:rect(18, 27, 46, 49):cut(c:rect(19, 28, 45, 48)), "#e46a9b")
-- berry cluster (back to front)
c:part(c:ellipse(32, 31, 5), pink)
c:part(c:ellipse(26.5, 38, 5), dark)
c:part(c:ellipse(37.5, 38, 5), pink)
c:part(c:ellipse(27, 44, 4.5), pink)
c:part(c:ellipse(37, 44, 4.5), dark)
-- leaf cap on the top berry
c:part(c:poly({ {28, 24}, {37, 24}, {35, 28}, {30, 28} }), leaf, { flat = true })
c:px(32, 23, leaf.shade); c:px(32, 22, leaf.shade)
-- fold crease and hem stitch along the flap
c:seam({ {15, 18}, {31, 24} })
c:seam({ {34, 24}, {50, 18} })
c:ground(32, 54, 16, 2)
local t = c:save(O .. "aseprite/ph/raspberry-seed.aseprite", O .. "png/ph/raspberry-seed.png")
print(GV.report(t))
