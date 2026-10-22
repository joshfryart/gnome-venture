local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local skin = c:ellipse(31.5, 39, 17, 16)
skin:add(c:ellipse(31.5, 24, 10.5, 11))
skin:add(c:poly({ {21,26}, {42,26}, {48,36}, {15,36} }))
skin = skin:closed(3)
local flesh = skin:shrink(3)
local pit = c:ellipse(31.5, 40, 7, 7)
c:build{
  { "skin", skin, GV.ramp("#2e5a2c") },
  { "flesh", flesh, GV.ramp("#c8d77a", { shade = "#a4b86a" }), { light = skin } },
  { "pit", pit, "wood", { gloss = { 28, 36 } } },
}
c:px(28, 36, "#d9a660"); c:px(29, 36, "#d9a660"); c:px(28, 37, "#d9a660")
local t = c:save(O .. "aseprite/ph/avocado.aseprite", O .. "png/ph/avocado.png")
print(GV.report(t))
