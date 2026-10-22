local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- shaft: diagonal pole lower-left to upper-right
local shaft = c:line({ {22, 48}, {39, 18} }, 5)
local ferrule = c:line({ {21, 47}, {18, 51} }, 6)
local grip = c:line({ {28, 38}, {33, 29} }, 7)
local knob = c:ellipse(40.5, 15.5, 6, 6)
local loop = c:line({ {27, 40}, {23, 44}, {19, 44}, {17, 41} }, 2)

local p = c:build{
  { "loop", loop, GV.ramp("#6a6070"), { flat = true } },
  { "shaft", shaft, "wood" },
  { "ferrule", ferrule, "stone" },
  { "grip", grip, GV.ramp("#a8582f") },
  { "knob", knob, GV.ramp("#8b8f96") },
}
-- seam along the grip wrap
c:seam({ {30, 37}, {34, 30} })
-- grain marks on the shaft
c:px(36, 25, GV.R.wood.shade); c:px(35, 26, GV.R.wood.shade)
c:px(25, 43, GV.R.wood.shade); c:px(24, 44, GV.R.wood.shade)

local t = c:save(O .. "aseprite/ph/hiking-staff.aseprite", O .. "png/ph/hiking-staff.png")
print(GV.report(t))
