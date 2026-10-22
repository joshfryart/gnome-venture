local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local body = c:ellipse(31.5, 37, 16, 15)
local under = body:copy():cut(c:ellipse(30.5, 33, 17, 15.5))
local stem = c:line({ {31, 24}, {31, 16} }, 3)
local leaf = c:poly({ {32, 19}, {35, 15}, {40, 12}, {46, 11}, {44, 15}, {40, 18}, {35, 21} })
c:build{
  { "stem", stem, GV.ramp("#3f7a34"), { flat = true } },
  { "leaf", leaf, "leaf" },
  { "body", body, GV.ramp("#7a3c1c"), { gloss = { 22, 28 } } },
  { "under", under, GV.ramp("#4e2418"), { flat = true, contour = false, contact = false } },
}
local d = "#5e2f1e"
c:paint({ "dd....", "..ddd.", "......" }, 23, 31, { d = d })
c:paint({ ".ddd..", "d...dd" }, 33, 37, { d = d })
c:paint({ "dd.ddd" }, 26, 44, { d = d })
local t = c:save(O .. "aseprite/ph/date.aseprite", O .. "png/ph/date.png")
print(GV.report(t))
