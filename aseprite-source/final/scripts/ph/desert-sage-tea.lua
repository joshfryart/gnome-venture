local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- handle: C ring
local handle = c:ellipse(46, 36, 9, 8):cut(c:ellipse(46, 36, 4, 3.5))
handle:cut(c:rect(0, 0, 41, 63))
-- body: flat top, rounded bottom
local body = c:rect(14, 22, 44, 38)
body:add(c:ellipse(29, 38, 15, 15):cut(c:rect(0, 0, 63, 37)))
body:cut(c:rect(0, 53, 63, 63))
body:add(c:rrect(20, 50, 38, 53, 2))
local tea = c:ellipse(29, 24, 13, 3.5)
local p = c:build{
  { "handle", handle, "#d6c9b6" },
  { "body", body, "#d6c9b6" },
  { "tea", tea, "moss", { gloss = { 21, 23 } } },
}
-- rim ring around tea
local rim = c:ellipse(29, 24, 15, 5):cut(c:ellipse(29, 24, 13, 3.5))
rim:clip(body)
c:fill(rim:copy():cut(c:rect(0, 0, 28, 63)), "#968f96")
c:fill(rim:copy():clip(c:rect(0, 0, 28, 63)), "#b5afb5")
-- sage leaf diamonds
c:paint({ ".a.", "aaa", ".a." }, 22, 38, { a = "#a4b86a" })
c:paint({ ".a.", "aaa", ".a." }, 30, 43, { a = "#7ab55c" })
c:paint({ ".a.", "aaa", ".a." }, 25, 46, { a = "#a4b86a" })
local t = c:save(O .. "aseprite/ph/desert-sage-tea.aseprite", O .. "png/ph/desert-sage-tea.png")
print(GV.report(t))
