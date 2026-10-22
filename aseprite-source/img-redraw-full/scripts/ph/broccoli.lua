local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local stalkR = GV.ramp("#b4c878")
local crownR = GV.ramp("#4f9638")
-- pale thick stalk with two little side branches
local stalk = c:poly({ {25, 38}, {39, 38}, {37, 57}, {27, 57} })
stalk:add(c:line({ {28, 46}, {22, 40} }, 3))
stalk:add(c:line({ {36, 45}, {42, 40} }, 3))
-- round lumpy cloud crown
local crown = c:ellipse(20, 30, 10, 9)
crown:add(c:ellipse(44, 30, 10, 9))
crown:add(c:ellipse(32, 19, 11, 10))
crown:add(c:ellipse(23, 19, 8, 7))
crown:add(c:ellipse(41, 19, 8, 7))
crown:add(c:ellipse(32, 32, 12, 9))
crown:add(c:ellipse(13, 24, 4, 4)); crown:add(c:ellipse(51, 24, 4, 4))
local p = c:build{
  { "stalk", stalk, stalkR },
  { "crown", crown, crownR, { gloss = { 20, 17 } } },
}
-- dark gaps between lobes
c:fill(c:line({ {25, 29}, {27, 33} }, 2), crownR.deep)
c:fill(c:line({ {37, 33}, {39, 29} }, 2), crownR.deep)
c:fill(c:line({ {30, 24}, {34, 24} }, 2), crownR.deep)
c:fill(c:line({ {19, 24}, {21, 23} }, 1), crownR.shade)
c:fill(c:line({ {44, 23}, {46, 24} }, 1), crownR.shade)
-- floret bumps
for _, d in ipairs({ {26, 14}, {38, 14}, {14, 27}, {31, 29}, {45, 26}, {21, 33} }) do
  c:paint({ ".l.", "lll", ".s." }, d[1], d[2], { l = "#7ab55c", s = crownR.shade })
end
local t = c:save(O .. "aseprite/ph/broccoli.aseprite", O .. "png/ph/broccoli.png")
print(GV.report(t))
