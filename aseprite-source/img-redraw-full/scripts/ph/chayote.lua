local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(32, 23, 8.5, 9):add(c:ellipse(32, 41, 17, 14)):closed(5)
local stem = c:rrect(30, 8, 33, 15, 1)
local leaf = c:ellipse(39, 11, 4, 2.5)
local p = c:build{
  { "stem", stem, "wood", { flat = true } },
  { "leaf", leaf, "leaf", { flat = true } },
  { "body", body, GV.ramp("#8cc464", { rim = "#a4b86a" }), { gloss = { 22, 27 } } },
}
-- ridges
c:fill(c:line({ {28, 18}, {25, 28}, {22, 40}, {23, 50} }, 1), "#4a8a3e")
c:fill(c:line({ {32, 16}, {32, 50} }, 1), "#4a8a3e")
c:fill(c:line({ {36, 18}, {39, 28}, {42, 40}, {41, 50} }, 1), "#4a8a3e")
-- pursed wrinkled slit at the base
c:paint({
  ".d.d.d.d.",
  "ddddddddd",
  "..d.d.d..",
}, 28, 49, { d = "#2f5a2a" })
c:ground(32, 56, 14, 1.5)
local t = c:save(O .. "aseprite/ph/chayote.aseprite", O .. "png/ph/chayote.png")
print(GV.report(t))
