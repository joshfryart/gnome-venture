local R = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(R .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local tent  = c:poly({ {32, 12}, {57, 55}, {7, 55} })
local shade = c:poly({ {32, 12}, {57, 55}, {32, 55} })
local door  = c:poly({ {32, 28}, {42, 55}, {22, 55} })
local hem   = c:rect(8, 52, 56, 54):clip(tent):cut(door)
local knob  = c:ellipse(32, 11, 4, 4)

local p = c:build{
  { "tent",  tent,  "moss", { stitch = { side = "lit" } } },
  { "shade", shade, GV.ramp("#3f7a36"), { gloss = false, rim = false } },
  { "hem",   hem,   GV.ramp("#4a8a3e"), { flat = true } },
}
c:fill(door, "#2a1a10")
c:fill(c:poly({ {32, 33}, {38, 52}, {35, 52} }), "#3e2f66")
c:part(knob, GV.ramp("#b6814d", { rim = "#f0d49a" }))

c:seam({ {31, 30}, {23, 52} }, { free = true })
c:seam({ {33, 30}, {41, 52} }, { free = true })
c:button(30, 25)

local t = c:save(R .. "img-redraw-full/aseprite/ico/ico-tent.aseprite", R .. "img-redraw-full/png/ico/ico-tent.png")
print(GV.report(t))
