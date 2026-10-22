local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local legs = c:rect(14, 38, 18, 52):add(c:rect(36, 38, 40, 52))
local box = c:rrect(8, 20, 46, 40, 5)
local wheel = c:ellipse(27, 32, 9, 9)
local handle = c:line({ {44, 30}, {55, 20} }, 5)
local feet = c:rrect(12, 51, 20, 54, 1):add(c:rrect(34, 51, 42, 54, 1))

local stone = GV.ramp("#968f96")
local p = c:build{
  { "legs", legs, stone },
  { "box", box, GV.ramp("#d6c9b6") },
  { "wheel", wheel, stone },
  { "handle", handle, GV.ramp("#b6814d", { gloss = "#f0d49a" }) },
  { "feet", feet, GV.ramp("#5b6470"), { flat = true } },
}
-- wheel spokes and hub
c:paint({ "..s..", "..s..", "sshss", "..s..", "..s.." }, 25, 30, { s = "#6e6870", h = "#5b6470" })
c:fill(c:rect(26, 31, 28, 33), "#5b6470")
c:px(26, 31, "#c9c5bc")
-- grip end of the handle
c:fill(c:rect(53, 19, 55, 21), "#8a4f2a"); c:px(53, 19, "#ecc58a")
c:seam({ {13, 23}, {41, 23} })
c:button(10, 26)
local t = c:save(O .. "aseprite/ph/seed-drill.aseprite", O .. "png/ph/seed-drill.png")
print(GV.report(t))
