local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "scene" }
local tile = c:rrect(3, 3, 60, 60, 7)
-- sky in hard bands, lighter toward the horizon
c:fill(tile, "#9fcfe6")
c:fill(c:rect(0, 14, 63, 33):clip(tile), "#a9d6ea")
c:fill(c:rect(0, 26, 63, 33):clip(tile), "#b9def0")
-- small clouds
c:fill(c:rrect(9, 11, 20, 13, 1):add(c:rrect(12, 9, 17, 11, 1)), "#e4f2f6")
c:fill(c:rrect(26, 20, 33, 21, 1), "#e4f2f6")
-- sun
c:part(c:ellipse(48, 15, 5, 5), GV.ramp("#f5cf6a"), { gloss = false, flat = true })
c:fill(c:rect(46, 12, 47, 13), "#fff1c8")
-- sea
local sea = c:rect(0, 34, 63, 63):clip(tile)
c:fill(sea, "#3f93b2")
c:fill(c:rect(0, 34, 63, 36):clip(tile), "#256a80")
c:fill(c:rect(0, 37, 63, 37):clip(tile), "#2f7f9c")
-- wave crests (scallops)
c:paint({ ".ww...ww...ww...ww", "w..w.w..w.w..w.w..w" }, 7, 41, { w = "#f4f0e0" })
c:paint({ ".ww...ww...ww", "w..w.w..w.w..w" }, 30, 38, { w = "#f4f0e0" })
-- sand with a wavy shore
local sand = c:poly({ {3, 50}, {10, 49}, {18, 50}, {27, 51}, {36, 50}, {45, 49}, {53, 50}, {61, 49}, {61, 61}, {3, 61} }):clip(tile)
c:fill(sand, "#dcb06a")
c:fill(sand:copy():cut(sand:shift(0, 1)), "#f4f0e0")   -- surf line on the shore
c:fill(c:rect(0, 57, 63, 63):clip(tile):clip(sand), "#c99a55")
-- shell
c:part(c:ellipse(15, 54, 2.5, 2), GV.ramp("#f6b8cf"), { gloss = false, flat = true })
c:paint({ "..r..", ".r.r." }, 13, 53, { r = "#e46a9b" })
-- boat: hull + red sail
c:part(c:poly({ {43, 45}, {57, 45}, {55, 48}, {45, 48} }), GV.ramp("#5e3a26"), { flat = true })
c:fill(c:rect(46, 36, 46, 44), "#44281c")
c:part(c:poly({ {47, 44}, {47, 36}, {55, 43} }), GV.ramp("#d6322b"), { flat = true })
-- frame outline + hem stitch
c:outline(tile)
c:seam({ {9, 5}, {54, 5} }, { free = true })
c:seam({ {9, 58}, {54, 58} }, { free = true })
local t = c:save(O .. "aseprite/ph/land-coast.aseprite", O .. "png/ph/land-coast.png")
print(GV.report(t))
