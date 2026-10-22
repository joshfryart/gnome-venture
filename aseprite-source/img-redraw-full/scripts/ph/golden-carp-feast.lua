local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fish = c:ellipse(29, 35, 13, 8.5)
local tail = c:poly({ {39, 35}, {50, 27}, {47, 35}, {50, 43} })
local p = c:build{
  { "rim",  c:ellipse(31.5, 41, 21.5, 11), GV.ramp("#d6c9b6"), { gloss = false } },
  { "well", c:ellipse(31.5, 40, 16, 7.5), GV.ramp("#f4f0e0"), { gloss = false } },
  { "tail", tail, "gold", { gloss = false } },
  { "fish", fish, "gold", { gloss = { 21, 31 } } },
  { "fin",  c:poly({ {26, 26}, {33, 22}, {35, 28} }), "gold", { flat = true } },
  { "herb", c:ellipse(43, 45, 3, 2.5), "moss", { gloss = { 42, 44 } } },
}
c:paint({ "ddd", "ddd", "ddd" }, 20, 33, { d = "#2a1a10" })
c:px(20, 33, "#f2e4c0")
-- gill and scale arcs
c:paint({ ".s", "s.", "s.", ".s" }, 24, 33, { s = "#b8661a" })
c:paint({ ".s.", "s.s" }, 28, 38, { s = "#b8661a" })
c:paint({ ".s.", "s.s" }, 33, 36, { s = "#b8661a" })
c:paint({ ".s.", "s.s" }, 31, 32, { s = "#b8661a" })
local t = c:save(O .. "aseprite/ph/golden-carp-feast.aseprite", O .. "png/ph/golden-carp-feast.png")
print(GV.report(t))
