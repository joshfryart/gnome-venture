local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local T = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local mound = c:ellipse(20, 28, 7, 6):add(c:ellipse(30.5, 23, 9, 8)):add(c:ellipse(42, 25, 8, 7))
mound:add(c:ellipse(48, 30, 5, 4)):add(c:ellipse(15, 31, 4, 3)):add(c:rect(12, 28, 52, 33))
local bowl = c:ellipse(32, 32, 22, 18):cut(c:rect(0, 0, 63, 32))
bowl:add(c:rect(10, 33, 54, 35))
local rim = c:rect(10, 31, 54, 34)

c:build{
  { "mound",  mound, GV.ramp("#3f93b2") },
  { "dark",   c:ellipse(22.5, 26, 3.5, 3.5), GV.ramp("#256a80"), { gloss = false } },
  { "leaf",   c:ellipse(34, 19.5, 4, 3.5), "moss", { gloss = false } },
  { "leaf2",  c:ellipse(16.5, 30, 3, 2.5), "moss", { gloss = false } },
  { "dark2",  c:ellipse(46.5, 30, 3, 2.5), GV.ramp("#256a80"), { gloss = false } },
  { "tomato", c:ellipse(43.5, 26, 3, 3), "red", { gloss = false } },
  { "bowl",   bowl, "cream", { gloss = { 20, 39 } } },
  { "rim",    rim,  GV.ramp("#d6c9b6"), { gloss = false } },
}
c:px(42, 25, GV.R.red.dot)
c:paint({ "g.gg", ".g.." }, 27, 18, { g = "#c8ecdc" })
c:seam({ {12, 33}, {52, 33} })
c:ground(32, 51, 15, 1.5)

local t = c:save(T .. "aseprite/ph/garden-salad.aseprite", T .. "png/ph/garden-salad.png")
print(GV.report(t))
