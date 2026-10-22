local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local bodyM = c:ellipse(32, 39, 18, 15)
local neck = c:poly({ {25, 20}, {40, 20}, {38, 28}, {27, 28} })
local ruffle = c:ellipse(25, 18, 4, 4):add(c:ellipse(32, 16, 4.5, 4.5)):add(c:ellipse(39, 18, 4, 4)):add(c:rect(21, 18, 43, 22))
local P = c:build{
  { "body", bodyM, "#dcb06a", { stitch = { side = "lit" } } },
  { "neck", neck, "#d9a660", { gloss = false } },
  { "ruffle", ruffle, "#dcb06a", { gloss = { 30, 14 } } },
}
c:part(c:ellipse(32, 41, 7, 7.5), "#f1ece0", { gloss = false, cres = 2, deep = 1 })
c:part(c:ellipse(32, 42, 4.5, 4.5), "#a5663a", { gloss = { 30, 40 } })
c:part(c:ellipse(35.5, 35, 2.5, 1.5), "#58a03e", { flat = true, contact = false })
c:fill(c:line({ {20, 42}, {21, 47} }, 1), "#b07a45")
c:fill(c:line({ {44, 42}, {43, 47} }, 1), "#b07a45")
local cord = GV.ramp("#a8582f")
c:part(c:line({ {25, 24}, {39, 24} }, 2), cord, { flat = true, contact = false })
c:part(c:line({ {28, 25}, {24, 31} }, 2), cord, { flat = true, contact = false })
c:part(c:line({ {37, 25}, {41, 33} }, 2), cord, { flat = true, contact = false })
c:part(c:rrect(22, 31, 25, 34, 1), cord, { flat = true, contact = false })
c:part(c:rrect(40, 33, 43, 36, 1), cord, { flat = true, contact = false })
local t = c:save(D .. "img-redraw-full/aseprite/ph/heliconia-seed.aseprite", D .. "img-redraw-full/png/ph/heliconia-seed.png")
print(GV.report(t))
