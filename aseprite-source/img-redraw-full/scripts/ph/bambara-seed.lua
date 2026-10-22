local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local paper = GV.ramp("#f1ece0")
local p = c:build{
  { "body",   c:rrect(14, 19, 49, 55, 2), paper },
  { "flap",   c:poly({ { 17, 11 }, { 47, 11 }, { 51, 20 }, { 13, 20 } }), GV.ramp("#f4f0e0"), { gloss = { 20, 13 } } },
  { "border", c:rrect(19, 24, 44, 49, 6), "petal", { gloss = false, contact = false } },
  { "window", c:rrect(21, 26, 42, 47, 5), GV.ramp("#f4f0e0"), { gloss = false } },
}
-- pod: a tilted bean
local pod = c:poly({ { 23, 41 }, { 26, 35 }, { 32, 32 }, { 38, 29 }, { 41, 30 }, { 40, 34 }, { 35, 38 }, { 29, 41 }, { 25, 43 } })
pod = pod:closed(2)
c:part(pod, "petal", { gloss = { 28, 36 } })
local nut = GV.ramp("#a8241f")
for _, q in ipairs({ { 29, 38 }, { 33, 36 }, { 37, 33 } }) do
  c:part(c:ellipse(q[1], q[2], 1.5, 1.5), nut, { flat = true, gloss = false, rim = false })
  c:px(q[1] - 1, q[2] - 1, nut.gloss)
end
-- fold line and seam
c:fill(c:rect(14, 20, 49, 20), "#dcb06a")
c:seam({ { 16, 21 }, { 48, 21 } })
for _, x in ipairs({ 26, 31, 37 }) do c:fill(c:rect(x, 51, x + 1, 52), "#8c4a1a") end
local t = c:save(O .. "aseprite/ph/bambara-seed.aseprite", O .. "png/ph/bambara-seed.png")
print(GV.report(t))
