local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local cloth = GV.ramp("#f1ece0")
local body = c:ellipse(31.5, 41, 19, 15)
local neck = c:poly({ {26,20}, {38,20}, {41,30}, {23,30} })
local earL = c:poly({ {27,23}, {18,12}, {22,9}, {32,21} })
local earR = c:poly({ {32,21}, {42,9}, {46,12}, {37,23} })
local mid = c:ellipse(32, 17, 3, 4)
local p = c:build{
  { "earL", earL, cloth },
  { "earR", earR, cloth },
  { "mid", mid, cloth, { gloss = false } },
  { "body", body, cloth, { gloss = { 19, 33 } } },
  { "neck", neck, cloth, { gloss = false } },
  { "twine", c:rrect(24, 22, 40, 25, 1), "#dcb06a", { gloss = false } },
}
c:stitch(p.body.m, { side = "lit" })
c:seam({ {25,23}, {39,23} })
c:button(30, 21)
-- broccoli stamp
local flo = c:ellipse(27, 39, 4.5, 4):add(c:ellipse(36, 39, 4.5, 4)):add(c:ellipse(31.5, 35, 4.5, 4)):add(c:ellipse(31.5, 41, 5, 3))
local stem = c:poly({ {29,43}, {35,43}, {36,51}, {28,51} })
c:part(stem, "#7ab55c", { flat = true })
c:part(flo, "#58a03e", { flat = true })
for _, pt in ipairs({ {28,38}, {33,34}, {36,38}, {31,41} }) do c:px(pt[1], pt[2], "#2e5a2c") end
c:line({ {32,44}, {32,50} }, 1):each(function(x,y) c:px(x,y,"#4a8a3e") end)
local t = c:save(O .. "aseprite/ph/broccoli-seed.aseprite", O .. "png/ph/broccoli-seed.png")
print(GV.report(t))
