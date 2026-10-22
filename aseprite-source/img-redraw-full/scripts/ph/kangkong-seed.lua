local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local leafm = c:ellipse(32, 41.5, 7, 6.5):add(c:poly({ {26, 39}, {32, 33}, {39, 39} }))
local p = c:build{
  { "packet", c:rrect(12, 12, 51, 51, 2), "#f1ece0" },
  { "flap",   c:poly({ {12, 12}, {52, 12}, {32, 31} }), GV.ramp("#dcb06a") },
  { "frame",  c:rrect(17, 31, 46, 50, 4), "gold" },
  { "panel",  c:rrect(19, 33, 44, 48, 3), GV.ramp("#f4f0e0"), { gloss = false } },
  { "leaf",   leafm, "moss" },
}
c:fill(c:line({ {32, 33}, {32, 46} }, 2):shift(0, 0), "#2e5a2c")
c:paint({ "v.....v", ".v...v.", "..v.v.." }, 29, 37, { v = "#2e5a2c" })
c:paint({ "v.......v", ".v.....v.", "..v...v.." }, 28, 41, { v = "#2e5a2c" })
c:seam({ {13, 13}, {31, 29} }); c:seam({ {33, 29}, {50, 13} })
c:button(30, 27)
local t = c:save(O .. "aseprite/ph/kangkong-seed.aseprite", O .. "png/ph/kangkong-seed.png")
print(GV.report(t))
