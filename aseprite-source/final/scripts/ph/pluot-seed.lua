local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy sack: main ellipse plus side lumps
local sack = c:ellipse(31.5, 42, 20, 13):add(c:ellipse(18, 46, 7, 7)):add(c:ellipse(45, 46, 7, 7))
sack:add(c:poly({ {22, 30}, {42, 30}, {46, 36}, {18, 36} }))
-- flared ears with fray notches
local ears = c:poly({ {17, 12}, {31, 28}, {21, 29} }):add(c:poly({ {47, 12}, {33, 28}, {43, 29} }))
ears:add(c:rrect(24, 22, 39, 29, 2))
ears:cut(c:rect(19, 12, 20, 13)):cut(c:rect(44, 12, 45, 13)):cut(c:rect(18, 16, 19, 16)):cut(c:rect(45, 16, 46, 16))
local tan = GV.ramp("#c9a96e")
local p = c:build{
  { "sack", sack, tan, { stitch = { side = "lit" } } },
  { "ears", ears, tan, { gloss = { 22, 18 } } },
  { "twine", c:rrect(23, 26, 40, 30, 2), "#7a4a1f", { gloss = false } },
}
c:part(c:line({ {37, 31}, {41, 37} }, 2), "#7a4a1f", { flat = true })
c:build{
  { "patch", c:rrect(22, 34, 41, 51, 3), "#9a6b3f", { gloss = false } },
}
-- pluot: green top, violet lower crescent
local fruit = c:ellipse(31.5, 43.5, 6, 6)
c:part(fruit, "moss", { gloss = { 28, 40 } })
local low = fruit:copy():cut(c:ellipse(29.5, 41.5, 6, 6))
c:fill(low, "#7b66b4")
c:fill(low:copy():cut(c:ellipse(30.5, 42.5, 6, 6)), "#3e2f66")
c:fill(c:rect(31, 36, 32, 37), "#5e2f1e")
c:paint({ "ll.", "lll" }, 33, 36, { l = "#4a8a3e" })
-- burlap flecks
c:px(16, 42, "#7a4a1f"); c:px(46, 40, "#7a4a1f"); c:px(44, 52, "#7a4a1f")
c:seam({ {20, 34}, {20, 49} })
local t = c:save(O .. "aseprite/ph/pluot-seed.aseprite", O .. "png/ph/pluot-seed.png")
print(GV.report(t))
