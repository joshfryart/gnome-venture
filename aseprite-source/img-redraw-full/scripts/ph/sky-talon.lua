local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- crescent claw: convex upper-left back, concave lower-right inner curve, tip hooking right
local body = c:poly({
  {41, 7}, {44, 7}, {44, 9}, {38, 11}, {33, 15}, {29, 21}, {27, 28}, {27, 36},
  {29, 43}, {33, 50}, {39, 57},
  {14, 57}, {11, 48}, {11, 38}, {13, 29}, {17, 21}, {23, 14}, {30, 9}, {36, 7},
})
local shade = c:poly({
  {44, 5}, {50, 5}, {50, 60}, {28, 60}, {23, 50}, {21, 40}, {21, 31}, {24, 22}, {29, 15}, {36, 10},
}):clip(body)
local p = c:build{
  { "claw",  body,  GV.ramp("#dcb06a", { rim = "#d9a660" }), { gloss = { 16, 31 } } },
  { "shade", shade, GV.ramp("#a5663a"), { light = body, gloss = false, rim = false } },
}
-- pale ridge along the lit back
c:fill(c:line({ {17, 50}, {15, 42}, {16, 33}, {19, 26}, {24, 19} }, 2):clip(p.claw.m:shrink(2)), "#f1ece0")
-- growth rings
c:fill(c:line({ {28, 18}, {32, 21} }, 1):clip(body), "#5e2f1e")
c:fill(c:line({ {20, 32}, {26, 33} }, 1):clip(body), "#5e2f1e")
c:fill(c:line({ {20, 43}, {27, 42} }, 1):clip(body), "#5e2f1e")

local t = c:save(O .. "aseprite/ph/sky-talon.aseprite", O .. "png/ph/sky-talon.png")
print(GV.report(t))
