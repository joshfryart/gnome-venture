local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/"
local GV = dofile(D .. "gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/test100/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local R = GV.R
local below = c:rect(-20, 45, 90, 90)
c:build{
  { "board", c:rrect(11, 42, 53, 48, 2), GV.ramp("#a5663a") },
  { "leafL", c:ellipse(20, 25, 6.5, 4.5), GV.ramp("#58a03e"), { gloss = false } },
  { "leafR", c:ellipse(44, 25, 6.5, 4.5), GV.ramp("#58a03e"), { gloss = false } },
  { "leafM", c:ellipse(30, 19.5, 7, 5), GV.ramp("#58a03e") },
  { "tomato", c:ellipse(39.5, 21, 5.5), GV.ramp("#c0352a") },
  { "bread", c:ellipse(32, 45, 20, 19):cut(below), GV.ramp("#dcb06a"), { stitch = { side = "lit" } } },
  { "inner", c:ellipse(32, 45, 14, 13):cut(below), GV.ramp("#e9b98a"), { gloss = false, contact = false } },
}
for _, p in ipairs({ {21,38}, {31,35}, {41,38} }) do c:paint({ "gg.", ".gg" }, p[1], p[2], { g = "#8c4a1a" }) end
c:seam({ {14, 46}, {50, 46} })
local t = c:save(O .. "aseprite/ico/ico-flatbread.aseprite", O .. "png/ico/ico-flatbread.png")
print("ico-flatbread " .. GV.report(t))
