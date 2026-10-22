local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "icon" }
local dark = GV.ramp("#3a2418")
local head = c:ellipse(31.5, 34, 21, 19)
local ears = c:ellipse(14, 17, 6.5, 6.5):add(c:ellipse(49, 17, 6.5, 6.5))
local sL = c:line({ {25,13}, {22,22}, {21,30}, {23,38}, {27,43} }, 8)
local sR = c:line({ {38,13}, {41,22}, {42,30}, {40,38}, {36,43} }, 8)
local stripes = sL:add(sR):clip(head:shrink(1))
stripes:cut(c:ellipse(22, 30, 3.5, 3.5)):cut(c:ellipse(41, 30, 3.5, 3.5))
local p = c:build{
  { "ears",    ears,    dark },
  { "head",    head,    GV.ramp("#f8eed2") },
  { "stripes", stripes, GV.ramp("#4a2c1a"), { gloss = false } },
  { "nose",    c:ellipse(31.5, 47, 5, 3.5), dark, { cres = 2 } },
}
c:eye(20, 28); c:eye(39, 28)
c:paint({ "u....u", ".uuuu." }, 29, 52, { u = "umber" })
local t = c:save(O .. "aseprite/ico/ico-badger.aseprite", O .. "png/ico/ico-badger.png")
print(GV.report(t))
