local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 39, 14, 13.5)
body:add(c:poly({ {26,17}, {37,17}, {41,27}, {44,33}, {19,33}, {22,27} }))
body:add(c:ellipse(31.5, 18.5, 5.5, 3.5))
body = body:closed(3)
c:build{
  { "stem", c:line({ {31,19}, {31,15}, {32,13}, {34,11} }, 3), GV.ramp("#8a4f2a"), { flat = true } },
  { "body", body, "moss", { gloss = { 24, 36 } } },
  { "leaf", c:poly({ {35,13}, {37,10}, {41,8}, {46,8}, {43,11}, {39,13} }), GV.ramp("#58a03e"), { flat = true } },
}
c:paint({ ".d.", "ddd", ".d." }, 30, 48, { d = "#2f5a2a" })
local t = c:save(O .. "aseprite/ph/pear.aseprite", O .. "png/ph/pear.png")
print(GV.report(t))
