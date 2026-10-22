local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 37, 16, 15)
local blush = body:copy():cut(c:ellipse(29, 31, 17, 15))
local leaf = c:poly({ { 33, 19 }, { 37, 11 }, { 44, 6 }, { 49, 6 }, { 47, 12 }, { 41, 18 } })
local p = c:build{
  { "stalk", c:rect(30, 15, 32, 23), GV.ramp("#2e5a2c"), { flat = true } },
  { "body", body, "gold", { gloss = { 22, 28 } } },
  { "blush", blush, GV.ramp("#f08a24"), { light = body, rim = false, gloss = false, contour = false } },
  { "leaf", leaf, GV.ramp("#58a03e"), { gloss = false } },
}
c:line({ { 35, 17 }, { 39, 12 }, { 44, 9 } }, 1)
for _, q in ipairs({ { 35, 17 }, { 36, 16 }, { 37, 15 }, { 38, 14 }, { 39, 13 }, { 40, 12 }, { 41, 11 }, { 42, 10 }, { 43, 10 }, { 44, 9 } }) do c:px(q[1], q[2], "#2f5a2a") end
local t = c:save(O .. "aseprite/ph/mango.aseprite", O .. "png/ph/mango.png")
print(GV.report(t))
