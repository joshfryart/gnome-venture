local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local foot = c:rrect(22, 50, 41, 55, 2)
local body = c:ellipse(31.5, 38, 18, 15)
local lid  = c:ellipse(31.5, 30, 14, 10):cut(c:rect(0, 31, 63, 63))
lid:add(c:rrect(16, 28, 47, 31, 1))
local knob = c:ellipse(31.5, 18, 4, 3.5)
local nut  = c:ellipse(31.5, 42, 7, 7.5)
local cap  = c:ellipse(31.5, 36, 7.5, 3):cut(c:rect(0, 39, 63, 63))
cap:add(c:rect(24, 36, 39, 37))

local p = c:build{
  { "foot", foot, GV.ramp("#b07a45") },
  { "body", body, GV.ramp("#f1ece0", { shade = "#dcb06a" }) },
  { "lid",  lid,  GV.ramp("#a5663a") },
  { "knob", knob, GV.ramp("#8a4f2a") },
  { "nut",  nut,  GV.ramp("#a5663a") },
  { "cap",  cap,  GV.ramp("#8c4a1a"), { gloss = false } },
}
-- cap texture dots and stem stub
c:paint({ "x.x.x.x", ".x.x.x." }, 28, 36, { x = "#5e2f1e" })
c:fill(c:rect(31, 31, 32, 33), "#2f5a2a")
-- lid seam and button
c:seam({ {18, 31}, {45, 31} })
c:button(22, 25)
c:ground(31.5, 56, 13, 1.5)
local t = c:save(O .. "aseprite/ph/hazelnut-seed.aseprite", O .. "png/ph/hazelnut-seed.png")
print(GV.report(t))
