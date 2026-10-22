local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:ellipse(49, 32, 9, 16):cut(c:ellipse(60, 32, 8, 12)):cut(c:rect(0, 0, 40, 63))
local body = c:ellipse(26, 32, 19, 15)
local belly = c:ellipse(26, 31, 16, 14):cut(c:ellipse(26, 26, 18, 14)):clip(body:shrink(2))
local fin = c:poly({ {24,44},{34,44},{32,52},{26,50} })
local dorsal = c:poly({ {18,20},{27,11},{34,19} })
c:build{
  { "tail", tail, GV.ramp("#e0501f") },
  { "fin", fin, GV.ramp("#e0501f") },
  { "dorsal", dorsal, GV.ramp("#e0501f") },
  { "body", body, GV.ramp("#f08a24") },
  { "belly", belly, GV.ramp("#f4f0e0"), { light = body, gloss = false, rim = false } },
}
local bar = GV.ramp("#e0501f")
for _, x in ipairs({ 27, 33 }) do
  c:fill(c:rect(x, 21, x + 1, 40):clip(body:shrink(2)):cut(belly), bar.base)
end
c:eye(12, 28, true)
c:paint({ "u..", ".uu" }, 9, 36, { u = "umber" })
local t = c:save(O .. "aseprite/ph/moonfish.aseprite", O .. "png/ph/moonfish.png")
print(GV.report(t))
