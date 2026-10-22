local D = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/"
local GV = dofile(D .. "gvlib/gvlib.lua")
local O = D .. "img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- pelt: wavy top/bottom, notched flaps on each side
local pelt = c:poly({
  {14, 15}, {18, 11}, {23, 15}, {28, 11}, {33, 15}, {38, 11}, {43, 15}, {47, 11}, {50, 15},
  {51, 20}, {56, 23}, {55, 29}, {49, 31}, {49, 38}, {55, 42}, {54, 48}, {48, 47},
  {45, 52}, {41, 48}, {36, 52}, {31, 48}, {26, 52}, {21, 48}, {17, 52},
  {14, 47}, {8, 48}, {7, 42}, {13, 38}, {13, 31}, {7, 29}, {6, 23}, {11, 20},
})
local p = c:build{
  { "pelt", pelt, "cream", { stitch = true } },
}
local tan = "#c9a96e"
-- three curved tufts
c:paint({ ".tt", "t..", "t..", ".tt" }, 19, 22, { t = tan })
c:paint({ "tt.", "..t", "..t", "tt." }, 39, 22, { t = tan })
c:paint({ "t...t", ".ttt." }, 29, 38, { t = tan })
c:ground(32, 55, 18, 1.5)
local t = c:save(O .. "aseprite/ph/white-pelt.aseprite", O .. "png/ph/white-pelt.png")
print(GV.report(t))
