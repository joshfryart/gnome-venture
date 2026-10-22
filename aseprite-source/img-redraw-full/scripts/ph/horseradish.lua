local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- leaves: two big upright pointed leaves
local lleaf = c:poly({ {31,25}, {24,21}, {19,13}, {20,7}, {25,10}, {30,17}, {34,25} })
local rleaf = c:poly({ {30,25}, {34,15}, {39,9}, {45,6}, {45,13}, {41,19}, {35,25} })
-- root: fat top, tapering to a point
local root = c:poly({ {21,22}, {43,22}, {44,28}, {42,38}, {38,47}, {35,52}, {33,57}, {31,57}, {29,51}, {25,44}, {21,34}, {20,27} })
root:add(c:rrect(20, 20, 44, 28, 4))
local rootlet = c:line({ {38,45}, {42,48}, {45,50}, {46,53} }, 2)
local p = c:build{
  { "lleaf", lleaf, "#4a8a3e" },
  { "rleaf", rleaf, "#6a9a3a" },
  { "rootlet", rootlet, GV.ramp("#e9d3a2"), { flat = true } },
  { "root", root, GV.ramp("#e9d3a2", { shade = "#c9a96e" }) },
}
-- leaf mid-veins
c:fill(c:line({ {22,10}, {25,14}, {29,20}, {31,22} }, 1):clip(p.lleaf.m), "#2f5a2a")
c:fill(c:line({ {43,9}, {39,13}, {36,18}, {33,22} }, 1):clip(p.rleaf.m), "#2f5a2a")
-- ring creases (curved dashes)
c:paint({ "rrr.", "...r" }, 24, 29, { r = "#9a6b3f" })
c:paint({ ".rrr", "r..." }, 35, 35, { r = "#9a6b3f" })
c:paint({ "rrr.", "...r" }, 26, 43, { r = "#9a6b3f" })
c:paint({ "rr", "..r" }, 30, 49, { r = "#9a6b3f" })
-- crown top: small dimple
c:paint({ "ssss" }, 30, 21, { s = "#c9a96e" })
local t = c:save(O .. "aseprite/ph/horseradish.aseprite", O .. "png/ph/horseradish.png")
print(GV.report(t))
