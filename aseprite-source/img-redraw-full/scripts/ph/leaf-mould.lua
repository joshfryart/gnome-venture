local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- sack with a ragged open mouth (zigzag top edge)
local sack = c:rrect(10, 22, 54, 56, 6):add(c:poly({
  {10, 24}, {10, 18}, {15, 15}, {19, 19}, {24, 16}, {29, 19}, {35, 16}, {40, 19}, {45, 15}, {50, 19}, {55, 17}, {55, 24} }))
local heap = c:ellipse(32, 18, 17, 7):add(c:ellipse(24, 14, 6, 5)):add(c:ellipse(34, 11, 8, 6)):add(c:ellipse(43, 14, 6, 5))
heap:cut(c:rect(0, 23, 63, 63))
local leaf = c:poly({ {32, 30}, {37, 33}, {39, 37}, {36, 41}, {32, 45}, {28, 41}, {25, 37}, {27, 33} })
local p = c:build{
  { "sack", sack, GV.ramp("#7a4a1f"), { stitch = { side = "lit" } } },
  { "heap", heap, GV.ramp("#3d2a1c") },
  { "label", c:ellipse(32, 38, 12, 10), GV.ramp("#f08a24") },
  { "leaf", leaf, GV.ramp("#b6814d", { rim = "#f0d49a" }), { gloss = false } },
}
c:fill(c:line({ {32, 31}, {32, 46} }, 1), "#5e2f1e")
c:fill(c:line({ {32, 36}, {29, 34} }, 1), "#5e2f1e")
c:fill(c:line({ {32, 36}, {35, 34} }, 1), "#5e2f1e")
c:fill(c:line({ {32, 40}, {29, 38} }, 1), "#5e2f1e")
c:fill(c:line({ {32, 40}, {35, 38} }, 1), "#5e2f1e")
-- loose crumbs, part of silhouette
c:part(c:rect(14, 10, 15, 11), GV.ramp("#3d2a1c"), { flat = true })
c:part(c:rect(51, 11, 52, 12), GV.ramp("#3d2a1c"), { flat = true })
c:seam({ {12, 24}, {53, 24} })
c:button(13, 22)
c:ground(32, 57, 20, 1.5)
local t = c:save(O .. "aseprite/ph/leaf-mould.aseprite", O .. "png/ph/leaf-mould.png")
print(GV.report(t))
