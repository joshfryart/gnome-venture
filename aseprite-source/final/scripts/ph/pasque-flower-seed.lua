local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local glass = GV.ramp("#c8ecdc")
local jar = c:rrect(16, 24, 47, 54, 7)
jar:add(c:poly({ {22, 18}, {42, 18}, {48, 28}, {16, 28} }))
local neck = c:rrect(21, 17, 42, 20, 1)
local cork = c:rrect(23, 7, 40, 17, 2)

local p = c:build{
  { "jar",  jar,  glass },
  { "neck", neck, "#8fcbd8", { flat = true } },
  { "cork", cork, "wood" },
  { "ball", c:ellipse(32, 42, 8, 8), GV.ramp("#f08a24", { shade = "#e0501f" }) },
}
-- cork grain
c:px(28, 11, "#8a4f2a"); c:px(29, 11, "#8a4f2a"); c:px(34, 13, "#8a4f2a"); c:px(35, 13, "#8a4f2a")
-- stem and leaf on the fruit
c:part(c:rect(31, 30, 32, 34), "#2e5a2c", { flat = true })
c:part(c:poly({ {33, 31}, {37, 28}, {40, 29}, {37, 32} }), GV.ramp("#58a03e"), { flat = true })
-- glass shine stripe
c:fill(c:rect(19, 30, 20, 44), "#fff3c8")
c:fill(c:rect(19, 47, 20, 49), "#fff3c8")
c:ground(31.5, 55, 15, 1.5)
local t = c:save(O .. "aseprite/ph/pasque-flower-seed.aseprite", O .. "png/ph/pasque-flower-seed.png")
print(GV.report(t))
