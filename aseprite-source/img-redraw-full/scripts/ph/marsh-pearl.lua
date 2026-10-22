local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local pearl = GV.ramp("#f4f0e0", { shade = "#c9d39c", deep = "#a4b86a", bounce = "#d8dfae" })
c:part(c:ellipse(31.5, 33.5, 16, 16), pearl, { gloss = { 23, 25 } })
-- lustre arc inside the upper-left edge
for _, p in ipairs({ {19, 36}, {18, 33}, {18, 32}, {19, 29}, {20, 27}, {21, 25}, {22, 24}, {24, 22}, {26, 21}, {28, 20} }) do
  c:px(p[1], p[2], "#fff3c8")
end
c:ground(31.5, 50.5, 11, 1.5)
local t = c:save(O .. "aseprite/ph/marsh-pearl.aseprite", O .. "png/ph/marsh-pearl.png")
print(GV.report(t))
