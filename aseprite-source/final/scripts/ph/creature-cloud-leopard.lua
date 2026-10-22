local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local cream = GV.ramp("#f8eed2")
local brown = GV.ramp("#a5663a")
local tail = GV.ramp("#c4925f")
local ears = c:ellipse(18, 14, 4.5):add(c:ellipse(39, 14, 4.5))
local inner = c:ellipse(18, 15, 2.5):add(c:ellipse(39, 15, 2.5))
local p = c:build{
  { "tail",  c:line({ {41,46}, {46,45}, {49,43}, {51,39}, {51,35}, {49,32} }, 4), tail },
  { "ears",  ears, tan, { gloss = false } },
  { "inner", inner, cream, { flat = true } },
  { "paws",  c:ellipse(20, 50, 5, 2.5):add(c:ellipse(37, 50, 5, 2.5)), brown, { gloss = false } },
  { "body",  c:ellipse(28.5, 40, 15, 11), tan },
  { "belly", c:ellipse(28.5, 45, 6, 6), cream, { gloss = false } },
  { "head",  c:ellipse(28.5, 24, 12, 11.5), tan },
  { "muzzle", c:ellipse(28.5, 29.5, 6, 4), cream, { gloss = false } },
}
local S, G = "#7a4428", "#a5663a"
c:spot(c:ascii({ ".xxx", "xxxx", "xxx.", "x..." }, 14, 35), S, G)
c:spot(c:ascii({ "xxx.", "xxxx", ".xxx", "...x" }, 39, 34), S, G)
c:spot(c:ascii({ "xx.", "xxx", "xxx", ".xx" }, 16, 43), S, G)
c:spot(c:ascii({ ".xx", "xxx", "xxx", "xx." }, 39, 43), S, G)
c:spot(c:ascii({ ".xxxx", "xxxx." }, 26, 37), S, G)
c:eye(21, 19); c:eye(31, 19)
c:paint({ "xxxx", ".xx." }, 27, 27, { x = "#2a1a10" })
c:paint({ "x....x", ".xxxx." }, 26, 30, { x = "#4a2c1a" })
local t = c:save(O .. "aseprite/ph/creature-cloud-leopard.aseprite", O .. "png/ph/creature-cloud-leopard.png")
print(GV.report(t))
