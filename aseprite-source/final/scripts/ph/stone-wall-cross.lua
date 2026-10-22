local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local B = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local LIGHT, DARK = GV.ramp("#d6c9b6"), GV.ramp("#8b8f96")
local whole = c:rect(25, 11, 38, 52):add(c:rect(11, 25, 52, 38))

local parts = {}
local function stone(name, x0, y0, x1, y1, ramp, gl)
  parts[#parts + 1] = { name, c:rrect(x0, y0, x1, y1, 3), ramp, { gloss = gl or false } }
end
-- outer stones (dark), then inner stones (light), overlapping 1 px
stone("vt1", 25, 11, 38, 18, DARK, true)
stone("hl1", 11, 25, 18, 38, DARK, true)
stone("vb1", 25, 45, 38, 52, DARK)
stone("hr1", 45, 25, 52, 38, DARK)
stone("vt2", 25, 18, 38, 26, LIGHT, true)
stone("hl2", 18, 25, 26, 38, LIGHT, true)
stone("vb2", 25, 37, 38, 45, LIGHT)
stone("hr2", 37, 25, 45, 38, LIGHT)
parts[#parts + 1] = { "hub", c:rrect(24, 24, 39, 39, 4), GV.ramp("#6a6070"), { gloss = false } }
parts[#parts + 1] = { "inset", c:rrect(27, 27, 36, 36, 3), GV.ramp("#968f96"), { gloss = { 29, 29 } } }
c:build(parts)
local t = c:save(B .. "aseprite/ph/stone-wall-cross.aseprite", B .. "png/ph/stone-wall-cross.png")
print(GV.report(t))
