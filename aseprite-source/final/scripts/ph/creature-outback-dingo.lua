local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local sand  = GV.ramp("#dcb06a")
local brown = GV.ramp("#a5663a")
local cream = GV.ramp("#f8eed2")

-- curled tail on the right, sweeping up from the haunch
local tail = c:line({ {42, 51}, {48, 51}, {52, 48}, {54, 43}, {54, 38}, {52, 34} }, 5)
local tip  = c:ellipse(52, 33, 3, 3.5)
tail:cut(tip)
local ears = c:poly({ {18, 27}, {19, 9}, {29, 20} }):add(c:poly({ {35, 20}, {45, 9}, {46, 27} }))
local inner = c:poly({ {21, 23}, {21, 14}, {27, 20} }):add(c:poly({ {37, 20}, {43, 14}, {43, 23} }))
local feet = c:ellipse(24, 54, 5, 3):add(c:ellipse(39, 54, 5, 3))
local body = c:ellipse(31.5, 44, 13, 11)
local chest = c:ellipse(31.5, 47, 7, 7)
local head = c:ellipse(31.5, 29, 12, 10.5)
local muzzle = c:ellipse(31.5, 35, 5.5, 4.5)

c:build{
  { "tail",   tail,   brown },
  { "tip",    tip,    cream, { gloss = false } },
  { "ears",   ears,   sand },
  { "inner",  inner,  brown, { flat = true } },
  { "feet",   feet,   brown },
  { "body",   body,   sand },
  { "chest",  chest,  cream, { gloss = false } },
  { "head",   head,   sand },
  { "muzzle", muzzle, cream, { gloss = false } },
}
-- nose
c:paint({ ".nnnn.", "nnnnnn", ".nnnn." }, 29, 31, { n = "#2a1a10" })
c:px(30, 31, "#5e2a3a")
-- mouth
c:paint({ "..m..", ".m.m." }, 30, 34, { m = "#74462a" })
c:eye(24, 23); c:eye(34, 23)
c:ground(31.5, 57, 17, 1.5)
local t = c:save(O .. "aseprite/ph/creature-outback-dingo.aseprite", O .. "png/ph/creature-outback-dingo.png")
print(GV.report(t))
