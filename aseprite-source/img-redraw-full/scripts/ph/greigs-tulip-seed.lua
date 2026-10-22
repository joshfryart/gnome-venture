local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bud = c:ellipse(31.5, 41, 6, 6)
bud:add(c:poly({ {26,42},{26,33},{29,36},{32,32},{35,36},{38,33},{38,42} }))
local p = c:build{
  { "envelope", c:rect(20, 11, 43, 52), "#f1ece0", { pale = true } },
  { "flap", c:poly({ {20,11},{44,11},{32,28} }), "#e6dcc4", { pale = true, contour = "#c9a96e", gloss = false } },
  { "stem", c:rect(31, 46, 33, 50), "#6a9a3a", { flat = true } },
  { "leaf", c:line({ {33, 50}, {36, 47}, {39, 45} }, 3), "moss", { flat = true } },
  { "bud", bud, "petal" },
}
c:paint({ "s", "s", "s" }, 31, 37, { s = "#ae2a2a" })
c:seam({ {21, 12}, {32, 27}, {43, 12} })
c:button(30, 25)
c:ground(31.5, 53, 13, 1.5)
local t = c:save(O .. "aseprite/ph/greigs-tulip-seed.aseprite", O .. "png/ph/greigs-tulip-seed.png")
print(GV.report(t))
