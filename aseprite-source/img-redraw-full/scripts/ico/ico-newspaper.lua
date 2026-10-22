local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local grey = GV.ramp("#968f96")
local page = c:rrect(8, 11, 56, 54, 3)
-- folded top-right corner (dog-ear)
page:cut(c:poly({ {50, 11}, {57, 11}, {57, 18} }))
c:build{
  { "page", page, GV.ramp("#f8eed2"), { pale = true } },
  { "head", c:rect(14, 16, 39, 26), "dusk", { gloss = { 16, 18 } } },
  { "col",  c:rect(43, 16, 50, 34), grey, { gloss = false } },
  { "bar1", c:rect(14, 30, 39, 34), grey, { gloss = false } },
  { "bar2", c:rect(14, 38, 50, 42), grey, { gloss = false } },
  { "bar3", c:rect(14, 46, 44, 50), grey, { gloss = false } },
}
-- dog-ear flap
c:part(c:poly({ {50, 11}, {57, 18}, {50, 18} }), GV.ramp("#e8d8b0"), { flat = true })
local t = c:save(O .. "aseprite/ico/ico-newspaper.aseprite", O .. "png/ico/ico-newspaper.png")
print(GV.report(t))
