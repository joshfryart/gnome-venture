local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tail = c:poly({ { 40, 30 }, { 56, 18 }, { 52, 32 }, { 56, 46 }, { 40, 35 } })
local body = c:ellipse(26, 33, 19, 10):add(c:poly({ { 30, 26 }, { 44, 30 }, { 44, 36 }, { 30, 41 } }))
local fin = c:poly({ { 26, 25 }, { 30, 17 }, { 37, 25 } })
local belly = c:ellipse(26, 33, 17, 8):clip(c:rect(0, 35, 63, 63)):cut(c:rect(0, 0, 13, 63))
local p = c:build{
  { "fin", fin, GV.ramp("#d6322b") },
  { "tail", tail, GV.ramp("#e0501f") },
  { "body", body, "flame", { gloss = { 16, 27 } } },
  { "belly", belly, GV.ramp("#f1ece0"), { light = body, rim = false } },
}
-- tiger stripes (stop above the belly)
for _, s in ipairs({ { 24, 25, 33 }, { 30, 25, 34 }, { 36, 27, 34 } }) do
  for y = s[2], s[3] do c:px(s[1], y, "#b8452f"); c:px(s[1] + 1, y + 1, "#b8452f") end
end
-- gill arc
for _, q in ipairs({ { 20, 28 }, { 21, 29 }, { 21, 30 }, { 21, 31 }, { 21, 32 }, { 21, 33 }, { 20, 34 } }) do c:px(q[1], q[2], "#8a3a1e") end
-- mouth notch
c:px(8, 34, "#4a2c1a"); c:px(9, 34, "#4a2c1a")
c:eye(12, 29, true)
local t = c:save(O .. "aseprite/ph/mackerel.aseprite", O .. "png/ph/mackerel.png")
print(GV.report(t))
