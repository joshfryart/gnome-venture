local GV = dofile("/home/user/gnome-venture/aseprite-source/gvlib/gvlib.lua")
local O = "/home/user/gnome-venture/aseprite-source/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stemR = GV.ramp("#4a8a3e", { rim = "#7ab55c", shade = "#2f5a2a" })
local leafL = GV.ramp("#6a9a3a", { shade = "#4a8a3e", rim = "#a4b86a", gloss = "#c8d77a" })
local leafR = GV.ramp("#7ab55c", { shade = "#4a8a3e" })
local back = GV.ramp("#b8452f", { shade = "#ae2a2a", deep = "#6b1b2c" })
local cupL = c:ellipse(31.5, 22, 16, 11):cut(c:rect(0, 0, 63, 15))
local stem = c:rect(31, 28, 33, 56)
local lleaf = c:poly({ {33,56}, {26,52}, {19,46}, {14,38}, {12,31}, {17,36}, {23,41}, {29,46}, {34,50} })
local rleaf = c:poly({ {32,48}, {38,43}, {44,38}, {48,35}, {52,32}, {48,38}, {42,43}, {36,47}, {33,50} })
local back_m = cupL:copy()
local lp = c:ellipse(23, 23, 8, 9):add(c:poly({ {15,23}, {16,12}, {18,7}, {22,10}, {29,20} }))
local rp = c:ellipse(40, 23, 8, 9):add(c:poly({ {48,23}, {47,12}, {45,7}, {41,10}, {34,20} }))
local cp = c:ellipse(31.5, 24, 8, 9):add(c:poly({ {24,22}, {28,11}, {31,6}, {33,6}, {36,11}, {40,22} }))
local cup = back_m:copy():add(lp):add(rp):add(cp)
c:build{
  { "stem", stem, stemR },
  { "lleaf", lleaf, leafL },
  { "rleaf", rleaf, leafR },
  { "back", back_m, back, { light = cup } },
  { "lp", lp, "red", { light = cup, gloss = { 19, 14 } } },
  { "rp", rp, "red", { light = cup } },
  { "cp", cp, "red", { light = cup, gloss = { 28, 12 } } },
}
local t = c:save(O .. "aseprite/ph/darwin-tulip.aseprite", O .. "png/ph/darwin-tulip.png")
print(GV.report(t))
