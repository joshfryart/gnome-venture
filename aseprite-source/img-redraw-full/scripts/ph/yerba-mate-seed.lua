local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- squat sack body: wide bottom, narrows toward neck
local body = c:ellipse(31.5, 41, 18, 14)
body:add(c:poly({ {21, 30}, {43, 30}, {48, 40}, {16, 40} }))
body:add(c:rrect(15, 40, 48, 55, 6))
local neck = c:poly({ {25, 17}, {39, 17}, {41, 29}, {23, 29} })
local tuft = c:poly({ {20, 9}, {27, 12}, {31, 18}, {25, 18} })
tuft:add(c:poly({ {44, 9}, {37, 12}, {33, 18}, {39, 18} }))
tuft:add(c:rect(29, 11, 34, 18))
local twine = c:rrect(23, 21, 41, 24, 1)
local leaf = c:poly({ {32, 30}, {39, 37}, {40, 42}, {36, 47}, {32, 48}, {28, 47}, {24, 42}, {25, 37} })
local burlap = GV.ramp("#c9a96e")
local p = c:build{
  { "tuft", tuft, burlap, { gloss = false } },
  { "body", body, burlap, { stitch = { side = "lit" } } },
  { "neck", neck, burlap, { gloss = false } },
  { "twine", twine, GV.ramp("#8a4f2a"), { flat = true } },
  { "leaf", leaf, "moss", { gloss = { 27, 37 } } },
}
-- knot and tails
c:paint({ ".kk.", "kkkk", "kKKk", ".kk." }, 37, 23, { k = "#8a4f2a", K = "#5e2f1e" })
c:paint({ "k.", "k.", ".k" }, 38, 27, { k = "#8a4f2a" })
-- neck folds
for _, x in ipairs({ 28, 32, 36 }) do
  c:fill(c:rect(x, 26, x, 28), "#9a6b3f")
  c:fill(c:rect(x, 17, x, 20), "#9a6b3f")
end
-- tuft fold lines
c:px(26, 14, "#9a6b3f"); c:px(27, 15, "#9a6b3f"); c:px(37, 14, "#9a6b3f"); c:px(36, 15, "#9a6b3f")
-- leaf veins
c:fill(c:rect(32, 33, 32, 46), "#2f5a2a")
c:paint({ "v...v", ".v.v.", "..." }, 30, 37, { v = "#2f5a2a" })
c:paint({ "v...v", ".v.v." }, 30, 41, { v = "#2f5a2a" })
-- seam around leaf patch
c:seam({ {32, 28}, {41, 37}, {42, 42}, {37, 49}, {32, 50}, {27, 49}, {22, 42}, {23, 37}, {32, 28} })
-- weave dots
for _, x in ipairs({ 23, 31, 39 }) do c:fill(c:rect(x, 51, x + 1, 52), "#8a4f2a") end
c:ground(31.5, 56, 15, 1.5)
local t = c:save(O .. "aseprite/ph/yerba-mate-seed.aseprite", O .. "png/ph/yerba-mate-seed.png")
print(GV.report(t))
