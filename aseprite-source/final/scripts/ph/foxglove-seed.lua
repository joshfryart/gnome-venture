local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local tan = GV.ramp("#dcb06a")
local cone = c:poly({ {13, 22}, {51, 22}, {34, 56}, {30, 56} })
local p = c:build{
  { "tuft",  c:poly({ {22, 15}, {24, 5}, {29, 12}, {32, 4}, {35, 12}, {40, 5}, {42, 15} }), "wood", { gloss = false } },
  { "twist", c:poly({ {25, 13}, {39, 13}, {37, 24}, {27, 24} }), tan },
  { "cone",  cone, "cream" },
  { "seed",  c:ellipse(34, 36, 5, 5), GV.ramp("#dcb06a", { shade = "#a5663a" }) },
  { "leaf",  c:ellipse(39.5, 29, 3, 1.5), "#58a03e", { flat = true } },
}
-- fold line
c:fill(c:line({ {20, 25}, {30, 50} }, 2):clip(cone):cut(p.seed.m:grow(1)), "#dcb06a")
-- twist ticks
c:paint({ "g..", ".g.", "..g" }, 28, 16, { g = "#f5cf6a" })
c:paint({ "g..", ".g.", "..g" }, 33, 17, { g = "#e8a317" })
c:seam({ {49, 25}, {35, 52} })
c:ground(32, 58, 9, 2, "#6a4528")
local t = c:save(O .. "aseprite/ph/foxglove-seed.aseprite", O .. "png/ph/foxglove-seed.png")
print(GV.report(t))
