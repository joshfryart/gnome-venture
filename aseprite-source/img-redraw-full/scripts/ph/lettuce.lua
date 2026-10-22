local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
-- pointed leafy head with ruffled edges
local head = c:ellipse(32, 38, 17, 16)
head:add(c:poly({ {32, 7}, {16, 34}, {48, 34} }))
head:add(c:ellipse(32, 22, 11, 12))
-- ruffle bumps along the sides (wavy leaf edge)
local bumps = { {21,16,3}, {43,16,3}, {17,24,3}, {47,24,3}, {15,32,3}, {49,32,3}, {15,41,3}, {49,41,3}, {19,49,3}, {45,49,3} }
for _, b in ipairs(bumps) do head:add(c:ellipse(b[1], b[2], b[3], b[3])) end
local p = c:build{
  { "head", head, "moss", { gloss = { 22, 20 } } },
}
-- inner ruffle lobes (lighter), drawn flat inside the sides
local lobeL = c:ellipse(21, 38, 4, 8):clip(head:shrink(3))
local lobeR = c:ellipse(43, 38, 4, 8):clip(head:shrink(3))
c:part(lobeL, "#a4b86a", { flat = true, contour = false, contact = false, solid = false })
c:part(lobeR, "#a4b86a", { flat = true, contour = false, contact = false, solid = false })
-- vein tree: light so it reads
local V = "#c8d77a"
c:fill(c:line({ {32, 15}, {32, 52} }, 2):clip(head), V)
c:fill(c:line({ {32, 38}, {22, 30} }, 1), V)
c:fill(c:line({ {33, 30}, {42, 22} }, 1), V)
c:fill(c:line({ {32, 45}, {24, 39} }, 1), V)
c:fill(c:line({ {33, 46}, {41, 39} }, 1), V)
c:fill(c:line({ {33, 22}, {38, 17} }, 1), V)
c:fill(c:line({ {32, 24}, {27, 19} }, 1), V)
local t = c:save(O .. "aseprite/ph/lettuce.aseprite", O .. "png/ph/lettuce.png")
print(GV.report(t))
