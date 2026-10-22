local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local p = c:build{
  { "body",  c:rrect(13, 24, 51, 54, 4), "#8b8f96" },
  { "lid",   c:rrect(11, 12, 53, 26, 4), "#c9c5bc", { gloss = { 16, 15 } } },
  { "hingeL", c:rect(16, 26, 20, 29), "#5b6470", { flat = true } },
  { "hingeR", c:rect(44, 26, 48, 29), "#5b6470", { flat = true } },
  { "label", c:rrect(19, 31, 45, 51, 5), "#f4f0e0", { gloss = false } },
  { "seed",  c:ellipse(32, 42, 7), "#dcb06a" },
  { "stem",  c:rect(31, 33, 32, 37), "#2e5a2c", { flat = true } },
  { "leaf",  c:ellipse(35.5, 33, 2.5, 1.5), "#58a03e", { flat = true } },
  { "clasp", c:rrect(28, 23, 35, 30, 1), "#e8a317", { flat = true } },
}
c:seam({ {14, 25}, {26, 25} }); c:seam({ {37, 25}, {50, 25} })
local t = c:save(O .. "aseprite/ph/rhododendron-seed.aseprite", O .. "png/ph/rhododendron-seed.png")
print(GV.report(t))
