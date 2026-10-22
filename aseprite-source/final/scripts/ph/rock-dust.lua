local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- squat trapezoid sack, wider at the bottom
local body = c:poly({ {16,19}, {22,14}, {41,14}, {47,19}, {52,44}, {49,50}, {40,52}, {23,52}, {14,50}, {11,44} })
local cuff = c:poly({ {19,10}, {44,10}, {47,22}, {16,22} })
local patch = c:ellipse(31.5, 36, 10, 8)
local p = c:build{
  { "sack",  body,  GV.ramp("#a5663a"), { stitch = { side = "lit" } } },
  { "cuff",  cuff,  GV.ramp("#dcb06a") },
  { "patch", patch, GV.ramp("#968f96") },
}
-- fold crease on the cuff
c:fill(c:line({ {21,15}, {42,15} }, 1), "#c4925f")
c:seam({ {17,20}, {46,20} })
-- V chevron
c:fill(c:line({ {26,32}, {31,39} }, 2):add(c:line({ {32,39}, {37,32} }, 2)), "#6a6070")
-- dust specks
c:px(21, 27, "#c9c5bc"); c:px(43, 46, "#c9c5bc"); c:px(28, 30, "#c9c5bc")
c:ground(31.5, 52, 17, 1)
local t = c:save(D .. "img-redraw-full/aseprite/ph/rock-dust.aseprite", D .. "img-redraw-full/png/ph/rock-dust.png")
print(GV.report(t))
