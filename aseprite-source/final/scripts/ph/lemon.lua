local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fruit = c:ellipse(31.5, 35, 17, 13.5)
fruit:add(c:poly({ {16,30}, {11,35}, {16,40} })); fruit:add(c:poly({ {47,30}, {53,35}, {47,40} }))
local lemon = GV.ramp("#f5cf6a", { shade = "#e8a317", deep = "#d0862a", gloss = "#fff1c8" })
local leaf = c:poly({ {33,21}, {37,15}, {43,11}, {51,10}, {48,16}, {40,21} })
c:build{
  { "stem", c:rect(30, 15, 33, 23), GV.ramp("#2f5a2a"), { flat = true } },
  { "fruit", fruit, lemon, { gloss = { 22, 28 } } },
  { "leaf", leaf, "moss" },
}
c:fill(c:line({ {37,19}, {41,15}, {46,12} }, 1), "#4a8a3e")
local t = c:save(O .. "aseprite/ph/lemon.aseprite", O .. "png/ph/lemon.png")
print(GV.report(t))
