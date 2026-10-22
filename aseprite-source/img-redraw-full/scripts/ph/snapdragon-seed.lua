local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "stem", c:line({ {31, 15}, {31, 9} }, 3), "#2e5a2c", { flat = true } },
  { "leaf", c:ellipse(38, 8, 4.5, 2.5), "#58a03e", { flat = true } },
  { "seed", c:ellipse(32, 27, 12, 12), "#e46a9b" },
  { "rim", c:rect(11, 35, 53, 38), "#8a4f2a", { flat = true } },
  { "crate", c:rect(12, 38, 52, 56), "#b07a45" },
}
c:fill(c:rect(18, 44, 46, 45), "#5e2f1e")
c:fill(c:rect(18, 50, 46, 51), "#5e2f1e")
c:part(c:rect(12, 38, 17, 56), "#a8582f", { flat = true })
c:part(c:rect(47, 38, 52, 56), GV.ramp("#a8582f"), { flat = true, gloss = false })
for _, q in ipairs({ {14, 41}, {49, 41}, {14, 53}, {49, 53} }) do c:px(q[1], q[2], "#ecc58a") end
local t = c:save(O .. "aseprite/ph/snapdragon-seed.aseprite", O .. "png/ph/snapdragon-seed.png")
print(GV.report(t))
