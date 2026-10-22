local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }

local linen = GV.ramp("#dcb06a")
local str = GV.ramp("#8c4a1a")

-- gathered ruffle top: flared, with scalloped crown
local top = c:poly({ {22,15}, {43,15}, {37,25}, {28,25} })
top:add(c:ellipse(24.5, 15, 3, 2.5)):add(c:ellipse(32.5, 14, 3.5, 3)):add(c:ellipse(40, 15, 3, 2.5))
-- lumpy bundle body
local bod = c:ellipse(32, 39, 17, 14)
bod:add(c:ellipse(22, 45, 9, 8)):add(c:ellipse(42, 45, 9, 8))
local tie = c:rrect(26, 22, 38, 25, 1)
local bow = c:ellipse(25.5, 20, 4, 3):add(c:ellipse(38.5, 20, 4, 3))
bow:cut(c:ellipse(25.5, 20, 1.5, 1)):cut(c:ellipse(38.5, 20, 1.5, 1))
bow:add(c:line({ {29, 25}, {26, 28} }, 2)):add(c:line({ {35, 25}, {38, 28} }, 2))
local knot = c:rrect(30, 20, 34, 25, 1)

c:build{
  { "top", top, linen },
  { "body", bod, linen, { stitch = { side = "lit" } } },
}
c:seam({ {32, 28}, {32, 53} })
c:paint({ "w.....", ".w....", "..w..." }, 18, 43, { w = "#b07a45" })
c:paint({ ".....w", "....w.", "...w.." }, 41, 43, { w = "#b07a45" })
c:build{
  { "fruit", c:ellipse(32.5, 39.5, 7, 7), GV.ramp("#3f93b2", { shade = "#256a80" }) },
  { "tie", tie, str, { flat = true } },
  { "bow", bow, str, { flat = true } },
  { "knot", knot, str },
}
-- tag on a string
c:fill(c:line({ {36, 22}, {42, 16} }, 2), "#8c4a1a")
c:part(c:poly({ {45,8}, {51,17}, {41,18} }):add(c:ellipse(45.5, 15, 4, 3)), GV.ramp("#2e5a2c"), { flat = true })
c:px(46, 12, "#4a8a3e"); c:px(46, 13, "#4a8a3e"); c:px(46, 14, "#4a8a3e")
local t = c:save(O .. "aseprite/ph/pandanus-seed.aseprite", O .. "png/ph/pandanus-seed.png")
print(GV.report(t))
