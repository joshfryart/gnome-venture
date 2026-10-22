local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mound = c:ellipse(19, 33, 9, 10)
mound:add(c:ellipse(37, 31, 10, 11))
mound:add(c:ellipse(45, 41, 9, 8))
mound:add(c:rrect(9, 36, 53, 50, 4))
mound:cut(c:rect(0, 47, 63, 63))
local slab = c:rrect(10, 44, 54, 53, 2)
local p = c:build{
  { "mound", mound, "red", { gloss = { 16, 28 }, light = mound:copy():add(slab) } },
  { "slab", slab, "wood" },
}
-- crumbs
c:part(c:rect(56, 49, 57, 50), "red", { flat = true })
c:part(c:rect(5, 50, 6, 51), "red", { flat = true })
-- jagged crack
c:paint({
  "u...",
  ".u..",
  ".u..",
  "..u.",
  ".u..",
  ".u..",
  "..u.",
  "..uu",
  "...u",
}, 31, 26, { u = "umber" })
c:paint({ "u..", ".uu" }, 22, 38, { u = "umber" })
-- slab texture
c:paint({ "s..s....s", }, 18, 49, { s = "#5e2f1e" })
c:paint({ "s...s" }, 38, 47, { s = "#5e2f1e" })
c:ground(31.5, 54, 22, 1.5)
local t = c:save(O .. "aseprite/ph/red-ochre.aseprite", O .. "png/ph/red-ochre.png")
print(GV.report(t))
