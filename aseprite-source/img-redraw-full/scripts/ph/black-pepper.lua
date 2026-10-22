local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- crescent spray: thick sweeping arc from lower left to upper right
local arc = c:line({ {11, 49}, {18, 50}, {26, 48}, {35, 43}, {44, 35}, {50, 27}, {54, 17} }, 4)
arc:add(c:line({ {20, 48}, {30, 45}, {40, 38}, {47, 30} }, 7))
local spray = GV.ramp("#3a2236", { rim = "#7b66b4" })
local corn = GV.ramp("#7a7084", { gloss = "#c8bcd8", rim = "#9a8fb0", shade = "#3e2f66" })

c:build{
  { "stem", c:line({ {12, 49}, {6, 53} }, 3), GV.ramp("#2e5a2c") },
  { "spray", arc, spray, { gloss = false } },
  { "pc3", c:ellipse(43, 20, 7), corn },
  { "pc2", c:ellipse(31, 29, 7), corn },
  { "pc1", c:ellipse(19, 38, 7), corn, { gloss = { 15, 34 } } },
}
-- wrinkle along the spray, below the balls
c:paint({ "ww.ww" }, 24, 48, { w = "#6a6070" })
c:paint({ "ww.ww" }, 34, 44, { w = "#6a6070" })
c:paint({ "w", "w", ".", "w", "w" }, 49, 27, { w = "#6a6070" })

local t = c:save(O .. "aseprite/ph/black-pepper.aseprite", O .. "png/ph/black-pepper.png")
print(GV.report(t))
