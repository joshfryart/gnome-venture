local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body = c:rrect(21, 11, 43, 53, 2)
local flap = c:poly({ { 21, 11 }, { 44, 11 }, { 32, 27 } }):clip(body)
local p = c:build{
  { "body", body, GV.ramp("#f1ece0"), { stitch = true } },
  { "flap", flap, GV.ramp("#dcb06a"), { contour = "#4a2c1a" } },
  { "bulb", c:ellipse(32, 41, 7, 7), GV.ramp("#dcb06a", { shade = "#a5663a" }) },
  { "leaf", c:ellipse(37.5, 32.5, 3.5, 2.5), GV.ramp("#58a03e"), { flat = true } },
  { "wax",  c:ellipse(32, 24, 2.5, 2.5), "red", { flat = true } },
}
c:fill(c:rect(31, 31, 32, 34), "#2e5a2c")
c:seam({ { 23, 13 }, { 32, 25 } })
c:seam({ { 41, 13 }, { 33, 24 } })
for _, x in ipairs({ 28, 32, 36 }) do c:px(x, 50, "#8c4a1a") end
c:ground(32, 56, 13, 1.5)

local t = c:save(O .. "aseprite/ph/cyclamen-seed.aseprite", O .. "png/ph/cyclamen-seed.png")
print(GV.report(t))
