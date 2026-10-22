local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 33, 13, 15)
local cap = c:ellipse(31.5, 33, 13.5, 15.5):clip(c:rect(0, 0, 63, 23))
cap:add(c:poly({ {18, 22}, {22, 26}, {27, 23}, {32, 27}, {37, 23}, {42, 26}, {46, 22} }))
cap:clip(c:ellipse(31.5, 33, 13.5, 15.5))
c:build{
  { "stem", c:rrect(30, 12, 33, 20, 1), "moss" },
  { "body", body, "wood" },
  { "cap", cap, GV.ramp("#8a4f2a"), { light = body } },
}
c:part(c:line({ {26, 40}, {28, 42}, {32, 43}, {36, 42}, {38, 40} }, 2), GV.ramp("#f1ece0"), { flat = true })
c:fill(c:line({ {22, 34}, {26, 34} }, 2), "#a8582f")
c:ground(31.5, 49, 10, 1.5)
local t = c:save(O .. "aseprite/ph/shea.aseprite", O .. "png/ph/shea.png")
print(GV.report(t))
