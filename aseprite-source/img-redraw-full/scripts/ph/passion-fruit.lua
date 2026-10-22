local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local dk = "#2e5a2c"
c:build{
  { "curl", c:line({ {30, 19}, {27, 17}, {25, 14}, {26, 11}, {29, 10} }, 2), GV.ramp("#4a8a3e"), { flat = true } },
  { "stem", c:rect(31, 13, 33, 21), GV.ramp(dk), { flat = true } },
  { "fruit", c:ellipse(32, 37, 17, 17), GV.ramp("#b0bc66"), { gloss = {23, 27} } },
  { "leaf", c:poly({ {33, 19}, {34, 14}, {38, 10}, {47, 6}, {45, 12}, {41, 17} }), GV.ramp("#58a03e") },
}
c:px(37, 41, "#4a8a3e"); c:px(42, 35, "#4a8a3e"); c:px(31, 46, "#4a8a3e")
local t = c:save(O .. "aseprite/ph/passion-fruit.aseprite", O .. "png/ph/passion-fruit.png")
print(GV.report(t))
