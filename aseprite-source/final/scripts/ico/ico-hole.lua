local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }

local grass = GV.ramp("#58a03e")
local tuftR = GV.ramp("#3e7a2c")
local soil  = GV.ramp("#8c4a1a")

local tufts = c:poly({ {13, 27}, {15, 16}, {18, 24}, {20, 18}, {23, 27} })
  :add(c:poly({ {41, 27}, {44, 18}, {46, 24}, {49, 16}, {51, 27} }))
local p = c:build{
  { "tufts", tufts, tuftR, { gloss = false } },
  { "grass", c:ellipse(31.5, 35, 21, 15), grass },
  { "soil", c:ellipse(31.5, 36.5, 17, 11), soil, { gloss = { 20, 31 } } },
  { "pit", c:ellipse(31.5, 38, 11, 6.5), "#2a1e18", { flat = true, rim = false, contact = false } },
}
-- inner wall: lit soil face on the far (top) side of the pit
c:fill(c:ellipse(31.5, 38, 11, 6.5):cut(c:ellipse(31.5, 39.5, 10, 6)), "#3d2a1c")
-- crumbs
c:paint({ ".c.", "ccc", ".c." }, 17, 39, { c = "#c47a3e" })
c:paint({ ".c.", "ccc", ".c." }, 44, 38, { c = "#c47a3e" })

local t = c:save(O .. "aseprite/ico/ico-hole.aseprite", O .. "png/ico/ico-hole.png")
print(GV.report(t))
