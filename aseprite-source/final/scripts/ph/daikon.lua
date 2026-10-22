local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

-- tapered root: rounded shoulders, long taper to a point
local root = c:poly({ {22, 24}, {42, 24}, {41, 34}, {38, 44}, {35, 52}, {33, 58}, {31, 58}, {28, 50}, {25, 40}, {22, 30} })
root:add(c:ellipse(31.5, 24, 10, 4))
-- curled leaves, bending different ways
local leafL = c:poly({ {30, 21}, {26, 17}, {22, 12}, {20, 7}, {23, 6}, {27, 9}, {31, 14}, {33, 20} })
leafL:add(c:ellipse(25, 11, 3.5, 4))
local leafR = c:poly({ {31, 21}, {34, 15}, {38, 10}, {43, 6}, {46, 7}, {45, 11}, {40, 16}, {34, 21} })
leafR:add(c:ellipse(41.5, 10, 4, 3.5))
local leaf = GV.ramp("#58a03e", { rim = "#7ab55c" })
local p = c:build{
  { "leafL", leafL, leaf, { gloss = { 22, 9 } } },
  { "leafR", leafR, leaf, { gloss = { 39, 9 } } },
  { "root", root, GV.ramp("#f1ece0"), { gloss = { 26, 27 } } },
  { "crown", c:rrect(29, 18, 34, 21, 1), GV.ramp("#2f5a2a"), { flat = true } },
}
-- leaf midribs
c:line({ {29, 18}, {25, 13}, {23, 9} }, 1):each(function(x, y) if p.leafL.m:has(x, y) then c:px(x, y, leaf.shade) end end)
c:line({ {34, 17}, {38, 13}, {42, 9} }, 1):each(function(x, y) if p.leafR.m:has(x, y) then c:px(x, y, leaf.shade) end end)
-- root grooves
c:fill(c:rect(25, 34, 29, 34), "#d6c9b6")
c:fill(c:rect(34, 40, 37, 40), "#d6c9b6")
c:fill(c:rect(29, 47, 31, 47), "#d6c9b6")
local t = c:save(O .. "aseprite/ph/daikon.aseprite", O .. "png/ph/daikon.png")
print(GV.report(t))
