local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local body  = c:rrect(13, 24, 51, 54, 3)
local lid   = c:rrect(11, 13, 53, 25, 3)
local hinge = c:rect(9, 17, 14, 27)
local label = c:rrect(19, 29, 45, 49, 4)
-- seed: tilted pill (cucumber seed, pointed oval)
local seed = c:line({ {25, 43}, {38, 36} }, 6)
seed:add(c:line({ {24, 44}, {39, 35} }, 3))
local cap = c:ellipse(40.5, 35.5, 2.5, 2.5)

local p = c:build{
  { "body",  body,  GV.ramp("#c9c5bc") },
  { "lid",   lid,   GV.ramp("#8b8f96") },
  { "hinge", hinge, GV.ramp("#5b6470"), { flat = true } },
  { "label", label, GV.ramp("#f1ece0"), { contour = "#74462a" } },
  { "seed",  seed,  GV.ramp("#dcb06a") },
  { "cap",   cap,   GV.ramp("#2e5a2c"), { flat = true } },
}
-- seed centre groove
c:paint({ "ss", "..ss", "....ss" }, 28, 39, { s = "#c4925f" })
-- hinge knuckles
c:px(11, 20, "#3a414c"); c:px(11, 24, "#3a414c")
c:seam({ {14, 25}, {51, 25} })
c:button(30, 16)
c:px(26, 52, "#8c4a1a"); c:px(32, 52, "#8c4a1a"); c:px(38, 52, "#8c4a1a")
c:ground(32, 57, 18, 1.5)
local t = c:save(O .. "aseprite/ph/cucumber-seed.aseprite", O .. "png/ph/cucumber-seed.png")
print(GV.report(t))
