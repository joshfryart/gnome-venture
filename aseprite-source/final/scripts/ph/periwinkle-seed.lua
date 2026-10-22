local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local fray = c:poly({{22,22},{24,13},{29,21}})
fray:add(c:poly({{29,21},{32,10},{36,21}}))
fray:add(c:poly({{35,21},{41,13},{42,22}}))
local body = c:ellipse(31, 39, 18, 12)
body:add(c:ellipse(40, 44, 10, 8)):add(c:ellipse(22, 45, 8, 6))
local p = c:build{
  { "fray", fray, "#9a6b3f" },
  { "neck", c:rrect(25, 19, 39, 30, 3), "#c9a96e" },
  { "body", body, "#c9a96e", { stitch = true } },
  { "badge", c:ellipse(32, 40, 6.5), "#dcb06a" },
  { "patch", c:rrect(17, 44, 23, 50, 1), "#7a4a1f", { flat = true } },
}
-- seed on badge
c:part(c:ellipse(31.5, 41, 2.5, 3.5), "#9a6b3f", { flat = true, contact = false })
local leaf = c:ellipse(36, 35, 2.5, 1.5)
c:part(leaf, "#58a03e", { flat = true, contact = false })
-- twine
local tw = c:line({{23,23},{41,23}}, 2)
tw:add(c:line({{24,24},{22,30}}, 2)):add(c:line({{40,24},{43,29}}, 2))
c:part(tw, "#a5663a", { flat = true })
c:seam({ {25,23}, {39,23} }, { free = true })
-- patch stitches
c:paint({ "g.g.g" }, 18, 44, { g = "#f5cf6a" })
c:ground(31, 52, 17, 1.5)
local t = c:save(O .. "aseprite/ph/periwinkle-seed.aseprite", O .. "png/ph/periwinkle-seed.png")
print(GV.report(t))
