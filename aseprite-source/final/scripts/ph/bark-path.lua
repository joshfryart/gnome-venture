local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local top   = c:ellipse(27, 18, 10, 6.5)
local right = c:ellipse(44.5, 32, 11, 7)
local left  = c:ellipse(20, 46, 12, 7)

c:build{
  { "top",   top,   GV.ramp("#6a6070"), { gloss = false } },
  { "right", right, GV.ramp("#d6c9b6") },
  { "left",  left,  GV.ramp("#968f96"), { gloss = false } },
}
-- surface pits
c:paint({ "uu" }, 24, 18, { u = "#4a2c1a" })
c:paint({ "uu" }, 46, 33, { u = "#4a2c1a" })
c:paint({ "uu" }, 15, 45, { u = "#4a2c1a" })
c:paint({ "uu" }, 27, 21, { u = "#4a2c1a" })
c:paint({ "uu" }, 20, 49, { u = "#4a2c1a" })

local t = c:save(O .. "aseprite/ph/bark-path.aseprite", O .. "png/ph/bark-path.png")
print(GV.report(t))
