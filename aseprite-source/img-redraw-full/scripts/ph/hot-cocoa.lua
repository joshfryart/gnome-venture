local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local mugR = GV.ramp("#e8dcc4")
-- handle: ring on the right
local handle = c:ellipse(46, 38, 8, 8):cut(c:ellipse(46, 38, 4, 4)):cut(c:rect(0, 0, 41, 63))
local body = c:rrect(14, 25, 43, 55, 9):add(c:rect(14, 25, 43, 40))
local cocoa = c:ellipse(28.5, 26, 12, 3)
local cream = c:ellipse(25, 23, 3, 2.5):add(c:ellipse(30.5, 21.5, 4, 3.5)):add(c:ellipse(35, 23, 3, 2.5))
cream:add(c:ellipse(30.5, 18, 2, 1.5))
local p = c:build{
  { "handle", handle, mugR },
  { "body", body, mugR },
  { "stripe", c:rect(14, 37, 43, 40):clip(body), "#a8582f", { gloss = false } },
  { "cocoa", cocoa, GV.ramp("#8c4a1a"), { gloss = false, contact = false } },
  { "cream", cream, "cream" },
}
-- swirl line on cream
c:paint({ "..ss", "s..." }, 28, 21, { s = "#f5b860" })
-- rim seam
c:seam({ {16, 29}, {42, 29} })
-- steam wisps, free 2px curls
local steam = "#f2e4c0"
c:fill(c:line({ {24,15}, {22,12}, {24,9}, {23,6} }, 2), "#c9a96e")
c:fill(c:line({ {36,15}, {38,12}, {36,9}, {37,6} }, 2), "#c9a96e")
local t = c:save(O .. "aseprite/ph/hot-cocoa.aseprite", O .. "png/ph/hot-cocoa.png")
print(GV.report(t))
