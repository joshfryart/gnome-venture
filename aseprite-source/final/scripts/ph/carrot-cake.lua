local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local icing = c:rrect(11, 28, 53, 36, 3)
for _, x in ipairs({ 15, 23, 31, 39, 47 }) do icing:add(c:ellipse(x + 1.5, 28, 4, 3)) end
icing:add(c:rrect(20, 34, 24, 41, 2)):add(c:rrect(30, 34, 34, 43, 2)):add(c:rrect(40, 34, 44, 40, 2))
local carrot = c:poly({ {28, 16}, {37, 16}, {33, 28}, {32, 28} })
carrot:add(c:ellipse(32.5, 16.5, 4.5, 2.5))
c:build{
  { "cake",  c:rrect(12, 32, 52, 53, 5), "#dcb06a", { stitch = { side = "lit" } } },
  { "icing", icing, "#f08a24" },
  { "tuft",  c:ellipse(29, 11, 2.5, 4):add(c:ellipse(36, 11, 2.5, 4)):add(c:rect(31, 12, 34, 15)), "#7ab55c", { gloss = false } },
  { "carrot", carrot, "#f2793a", { gloss = { 30, 16 } } },
}
-- cream layer
c:fill(c:rect(14, 45, 50, 46):cut(c:rect(0,0,63,43)), "#f1ece0")
-- carrot ridges
c:px(33, 20, "#ae2a2a"); c:px(34, 20, "#ae2a2a"); c:px(32, 24, "#ae2a2a"); c:px(33, 24, "#ae2a2a")
-- crumbs
for _, p in ipairs({ {17, 49}, {27, 49}, {38, 49}, {46, 48}, {44, 41} }) do
  c:fill(c:rect(p[1], p[2], p[1] + 1, p[2] + 1), "#a8582f")
end
c:seam({ {14, 38}, {50, 38} })
local t = c:save(O .. "aseprite/ph/carrot-cake.aseprite", O .. "png/ph/carrot-cake.png")
print(GV.report(t))
