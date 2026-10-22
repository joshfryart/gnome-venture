local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dark = GV.ramp("#58a03e")
local lite = GV.ramp("#b0bc66")
local cream = GV.ramp("#f8eed2")
local tail = c:poly({ {10, 36}, {18, 30}, {21, 32}, {21, 39}, {17, 39} })
local legs = c:ellipse(19.5, 40, 3, 2.5):add(c:ellipse(30.5, 40, 3, 2.5))
local body = c:ellipse(25, 33, 11, 6.5)
local spikes = c:mask()
for _, x in ipairs({ 16, 21, 26 }) do
  spikes:add(c:poly({ { x, 28 }, { x + 2, 24 }, { x + 4, 28 } }))
end
local head = c:rrect(33, 27, 41, 37, 3)
local snout = c:rrect(39, 30, 53, 33, 1)
local jaw = c:rrect(37, 34, 53, 36, 1)
local bump = c:ellipse(36, 27, 3, 2.5)
c:build{
  { "tail", tail, dark, { flat = false } },
  { "legs", legs, dark },
  { "spikes", spikes, dark, { flat = true } },
  { "body", body, lite, { gloss = { 17, 29 } } },
  { "head", head, lite, { gloss = false } },
  { "snout", snout, lite, { gloss = false } },
  { "jaw", jaw, cream, { gloss = false } },
  { "bump", bump, lite, { gloss = false } },
}
c:seam({ { 17, 31 }, { 32, 31 } })
for _, x in ipairs({ 42, 45, 48, 51 }) do c:px(x, 33, "#fff3c8") end
c:eye(35, 25, true)
c:ground(27, 43, 13, 1.5)
local t = c:save(O .. "aseprite/ph/creature-delta-gharial.aseprite", O .. "png/ph/creature-delta-gharial.png")
print(GV.report(t))
