-- ph/stone-lantern
local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local stone = GV.ramp("#6a6070", { rim = "#8b8f96" })

c:build{
  { "foot", c:rrect(23, 49, 40, 54, 2), stone, { gloss = false } },
  { "post", c:rect(28, 35, 35, 50), stone, { gloss = false } },
  { "box",  c:rrect(18, 19, 45, 37, 4), stone, { gloss = { 21, 22 } } },
  { "lamp", c:rrect(23, 23, 40, 34, 2), "gold", { gloss = { 25, 25 } } },
  { "roof", c:poly({ {12, 22}, {32, 10}, {52, 22} }):add(c:rect(13, 19, 50, 21)), stone, { gloss = { 27, 15 } } },
  { "knob", c:ellipse(31.5, 9, 2.5, 2), stone, { flat = true } },
}
-- flame in the window
c:paint({
  "..f..",
  ".fff.",
  ".fyf.",
  "fyyyf",
  "fyyyf",
  ".fff.",
}, 30, 26, { f = "#d0862a", y = "#fff1c8" })
-- cap / box join
c:fill(c:rect(19, 22, 44, 22), "#4a2c1a")
c:ground(31.5, 55, 13, 1.5)

local t = c:save(O .. "aseprite/ph/stone-lantern.aseprite", O .. "png/ph/stone-lantern.png")
print(GV.report(t))
