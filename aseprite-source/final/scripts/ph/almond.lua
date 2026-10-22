local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
-- teardrop almond: round bottom, tapered top
local body = c:ellipse(31.5, 38, 14, 16)
body:add(c:poly({ {19, 34}, {31, 15}, {33, 15}, {45, 34} }))
body:add(c:ellipse(31.5, 26, 9, 10))
local cap = body:copy():clip(c:ellipse(31.5, 14, 18, 13))
local stem = c:rect(30, 10, 33, 17)
local p = c:build{
  { "stem", stem, GV.ramp("#2f5a2a"), { flat = true } },
  { "body", body, GV.ramp("#dcb06a") },
  { "cap", cap, GV.ramp("#a5663a"), { light = body, contact = false } },
}
-- groove (shell seam) on lower face
c:paint({
  "g....",
  "gg...",
  ".g...",
  ".gg..",
  "..g..",
  "..gg.",
  "...gg",
}, 35, 40, { g = "#8a4f2a" })
-- shell grain
c:paint({ "b..", ".b.", ".b.", "..b" }, 24, 32, { b = "#b07a45" })
c:paint({ "b.", "b.", ".b" }, 29, 44, { b = "#b07a45" })
local t = c:save(O .. "aseprite/ph/almond.aseprite", O .. "png/ph/almond.png")
print(GV.report(t))
