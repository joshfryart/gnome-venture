local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local orange = GV.ramp("#f08a24")
local ember  = GV.ramp("#e0501f")
local white  = GV.ramp("#f8eed2")

local tail = c:ellipse(43, 47, 5, 5):add(c:ellipse(47, 41, 5.5, 6)):add(c:ellipse(49.5, 34, 4.5, 5.5))
local tip = c:ellipse(50, 30.5, 4.5, 3.5):clip(tail)
tail:cut(tip)
local ears = c:poly({ {17, 25}, {19, 8}, {29, 17} }):add(c:poly({ {32, 17}, {42, 8}, {44, 25} }))
local feet = c:ellipse(23.5, 52, 5, 2.5):add(c:ellipse(37.5, 52, 5, 2.5))
local body = c:ellipse(30.5, 42, 14, 10.5)
local chest = c:ellipse(30.5, 45, 7.5, 6.5)
local head = c:ellipse(30.5, 27, 12.5, 11.5)
local muzzle = c:ellipse(30.5, 33.5, 6, 5)

local p = c:build{
  { "tail", tail, ember },
  { "tip", tip, white, { pale = true } },
  { "ears", ears, orange },
  { "feet", feet, ember },
  { "body", body, orange },
  { "chest", chest, white, { pale = true } },
  { "head", head, orange, { stitch = { side = "lit" } } },
  { "muzzle", muzzle, white, { pale = true, gloss = false } },
}
-- inner ear wedges
local inner = c:poly({ {20, 22}, {20, 12}, {26, 18} }):add(c:poly({ {35, 18}, {41, 12}, {41, 22} })):cut(head)
c:fill(inner, "#b8452f")
-- nose + mouth
c:paint({ ".nnnn.", "nnnnnn", ".nnnn.", "..nn..", ".m..m." }, 28, 29, { n = "#2a1a10", m = "#74462a" })
c:px(29, 29, "#5e2a3a")
c:eye(21, 22); c:eye(35, 22)
local t = c:save(O .. "aseprite/ph/creature-red-fox.aseprite", O .. "png/ph/creature-red-fox.png")
print(GV.report(t))
