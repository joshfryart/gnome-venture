local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#c9a96e")
local ruffle = c:poly({ { 21, 10 }, { 26, 16 }, { 32, 8 }, { 38, 16 }, { 43, 10 }, { 41, 21 }, { 23, 21 } })
local p = c:build{
  { "leaf",   c:ellipse(37, 11, 3.5, 2), "#58a03e" },
  { "ruffle", ruffle, "#b07a45" },
  { "neck",   c:rrect(26, 18, 38, 28, 3), tan, { gloss = false } },
  { "sack",   c:ellipse(31.5, 39, 17, 15), tan, { stitch = { side = "lit" } } },
  { "twine",  c:rect(24, 24, 40, 26), "#a8582f", { flat = true } },
  { "seed",   c:ellipse(31.5, 41, 6.5, 6.5), GV.ramp("#7a5cc0", { shade = "#4e3a8a" }) },
}
c:paint({ ".kk.", "kkkk", "kkkk", ".kk." }, 30, 23, { k = "#8a4f2a" })
c:paint({ "k..k", ".kk." }, 30, 27, { k = "#8a4f2a" })
c:seam({ { 43, 32 }, { 44, 38 }, { 43, 46 } })
c:ground(31.5, 54, 15, 2)
local t = c:save(O .. "aseprite/ph/florentine-iris-seed.aseprite", O .. "png/ph/florentine-iris-seed.png")
print(GV.report(t))
