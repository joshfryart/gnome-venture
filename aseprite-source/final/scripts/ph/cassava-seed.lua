local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- lumpy sack: shoulders + rounded bottom + side bulges
local sack = c:poly({ {15,34}, {22,29}, {42,29}, {50,34}, {50,44}, {14,44} })
sack:add(c:rrect(13, 33, 51, 53, 6))
sack:add(c:ellipse(16, 44, 4, 7)):add(c:ellipse(48, 43, 4, 7))
local neck = c:poly({ {25,22}, {39,22}, {41,32}, {23,32} })
local root = c:poly({ {27,13}, {37,13}, {36,20}, {34,27}, {30,27}, {28,20} })
root:add(c:ellipse(32, 13.5, 5, 2.5))
local leafL = c:poly({ {31,13}, {24,6}, {20,8}, {23,12} }):add(c:ellipse(24, 9, 3.5, 2.5))
local leafR = c:poly({ {33,13}, {40,6}, {44,8}, {41,12} }):add(c:ellipse(40, 9, 3.5, 2.5))
local p = c:build{
  { "leafL", leafL, "#58a03e", { gloss = false } },
  { "leafR", leafR, "#58a03e", { gloss = false } },
  { "root", root, "#dcb06a" },
  { "sack", sack, "#c9a96e", { stitch = { side = "lit" } } },
  { "neck", neck, "#b07a45", { gloss = false } },
  { "twine", c:rrect(21, 29, 43, 31, 1), "#7a4a1f", { flat = true } },
  { "patch", c:rrect(25, 37, 39, 48, 1), "#f4f0e0", { gloss = false } },
}
-- root ring marks
c:paint({ "ss.s" }, 30, 18, { s = GV.ramp("#dcb06a").shade })
c:paint({ "s.ss" }, 31, 23, { s = GV.ramp("#dcb06a").shade })
-- leaf veins
c:line({ {30,12}, {24,8} }, 1):each(function(x,y) if leafL:has(x,y) then c:px(x,y,GV.ramp("#58a03e").shade) end end)
c:line({ {34,12}, {40,8} }, 1):each(function(x,y) if leafR:has(x,y) then c:px(x,y,GV.ramp("#58a03e").shade) end end)
-- twine bow knot
c:paint({ "t...t", "ttktt", "t...t" }, 30, 29, { t = "#7a4a1f", k = "#5a3414" })
c:paint({ "t.t", "t.t" }, 31, 32, { t = "#7a4a1f" })
-- burlap weave flecks
local fl = GV.ramp("#c9a96e").shade
for _, q in ipairs({ {20,38}, {44,37}, {21,46}, {45,47}, {41,41}, {22,42} }) do c:px(q[1], q[2], fl); c:px(q[1]+1, q[2]+1, fl) end
-- patch stitches
c:seam({ {27,39}, {37,39} }); c:seam({ {27,46}, {37,46} })
c:paint({ "d...d", ".d.d.", "..d..", ".d.d.", "d...d" }, 30, 41, { d = "#c47a52" })
c:seam({ {18,36}, {17,50} }); c:seam({ {22,51}, {44,51} })
c:button(30, 35)
local t = c:save(O .. "aseprite/ph/cassava-seed.aseprite", O .. "png/ph/cassava-seed.png")
print(GV.report(t))
