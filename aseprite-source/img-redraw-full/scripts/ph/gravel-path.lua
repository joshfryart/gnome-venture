local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local dark = c:ellipse(26.5, 20, 11, 7.5)
local light = c:ellipse(43.5, 33, 12.5, 8.5)
local mid = c:ellipse(21.5, 45, 12.5, 8)
local p = c:build{
  { "dark", dark, GV.ramp("#6a6070") },
  { "light", light, GV.ramp("#d6c9b6") },
  { "mid", mid, GV.ramp("#968f96") },
}
c:paint({ "k..", ".kk", "...k" }, 30, 21, { k = "#2a1a10" })
c:paint({ "kk.", "..k", "..k" }, 15, 46, { k = "#2a1a10" })
c:paint({ "k", ".kk" }, 46, 36, { k = "#4a2c1a" })
local t = c:save(O .. "aseprite/ph/gravel-path.aseprite", O .. "png/ph/gravel-path.png")
print(GV.report(t))
