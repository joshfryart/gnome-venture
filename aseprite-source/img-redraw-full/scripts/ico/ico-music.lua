local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.ramp("#6a6070")

local beam = c:poly({ {24, 15}, {54, 9}, {54, 19}, {24, 25} })
local p = c:build{
  { "beam", beam, R },
  { "lstem", c:rect(24, 15, 28, 46), R, { gloss = false } },
  { "rstem", c:rect(49, 9, 53, 40), R, { gloss = false } },
  { "lhead", c:ellipse(19, 46, 9, 7), R },
  { "rhead", c:ellipse(44, 40, 9, 7), R },
}
local t = c:save(O .. "aseprite/ico/ico-music.aseprite", O .. "png/ico/ico-music.png")
print(GV.report(t))
