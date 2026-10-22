local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cream = GV.ramp("#e8dcc8", { gloss = "#fff3c8", dot = "#ffffff", rim = "#f5b860", shade = "#c4b29a", deep = "#968f96" })
local gold = GV.ramp("#f5cf6a", { shade = "#e8a317" })
local cx = 30.5
local body = c:rect(15, 28, 46, 38):add(c:ellipse(cx, 38, 15.5, 15):cut(c:rect(0, 0, 63, 37)))
local handle = c:ellipse(46.5, 37, 7.5, 7.5):cut(c:ellipse(46.5, 37, 3.5, 3.5)):cut(c:rect(0, 0, 45, 63))
local whole = body:copy():add(handle)
local p = c:build{
  { "handle", handle, cream, { light = whole, gloss = false } },
  { "bowl",   body, cream, { light = whole } },
  { "rim",    c:ellipse(cx, 28, 15.5, 5.5), cream, { light = whole, gloss = false } },
  { "porr",   c:ellipse(cx, 28, 12.5, 3.5):add(c:ellipse(26, 25.5, 4.5, 2.5)):add(c:ellipse(34, 25, 5, 3)), gold, { gloss = { 25, 24 } } },
}
-- wavy swirl on porridge top
c:paint({ "ss...ss", "..sss.." }, 27, 28, { s = "#e8a317" })
c:px(35, 24, "#fff1c8")
-- seam band below rim
c:seam({ { 17, 36 }, { 44, 36 } })
c:ground(cx, 56, 14, 1.5)
local t = c:save(O .. "aseprite/ph/goat-milk-porridge.aseprite", O .. "png/ph/goat-milk-porridge.png")
print(GV.report(t))
