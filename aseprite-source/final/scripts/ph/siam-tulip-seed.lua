local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bulb = c:ellipse(32, 17, 7, 7)
bulb:add(c:poly({ {28, 12}, {36, 12}, {32, 8} }))
local p = c:build{
  { "stem", c:line({ {31, 10}, {31, 7} }, 3), "#2e5a2c", { flat = true } },
  { "leaf", c:ellipse(37, 8, 4, 2), "#58a03e", { flat = true } },
  { "bulb", bulb, "#e8a317" },
  { "env", c:rrect(19, 18, 45, 56, 3), "#f1ece0", { pale = true } },
  { "flap", c:poly({ {19, 18}, {46, 18}, {32.5, 35} }), "#dcb06a", { flat = true } },
}
c:fill(c:rect(24, 43, 40, 44), "#dcb06a")
c:fill(c:rect(24, 49, 36, 50), "#dcb06a")
c:button(31, 32)
c:seam({ {42, 37}, {42, 53} }, { free = true })
local t = c:save(O .. "aseprite/ph/siam-tulip-seed.aseprite", O .. "png/ph/siam-tulip-seed.png")
print(GV.report(t))
