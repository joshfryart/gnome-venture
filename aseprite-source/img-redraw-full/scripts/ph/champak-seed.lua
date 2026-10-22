local GV = dofile("C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/gvlib/gvlib.lua")
local O = "C:/Users/hello/OneDrive/Desktop/claude/asperite/gnome-venture/img-redraw-full/"
local c = GV.canvas{ w = 64, h = 64, mode = "sticker" }
local ruffle = c:rect(22, 15, 42, 22)
ruffle:add(c:ellipse(25, 15, 3.5, 3)):add(c:ellipse(32, 14, 3.5, 3.5)):add(c:ellipse(39, 15, 3.5, 3))
ruffle:add(c:poly({ {20,13}, {24,15}, {24,22}, {22,22} })):add(c:poly({ {44,13}, {41,15}, {40,22}, {43,22} }))
local body = c:ellipse(32, 39, 19, 15):add(c:poly({ {26,22}, {38,22}, {46,30}, {18,30} }))
local dusk = GV.ramp("#7a5cc0", { shade = "#4f3e86", deep = "#3e2f66" })
local p = c:build{
  { "ruffle", ruffle, GV.ramp("#7b66b4", { rim = "#a894dc" }), { gloss = false } },
  { "body", body, dusk, { stitch = { side = "lit" } } },
}
c:seam({ {28,41}, {28,50} }, { gap = "#3e2f66", free = true })
local cord = c:rect(23, 22, 41, 24)
local loops = c:ellipse(25, 27, 2.5, 2):add(c:ellipse(39, 27, 2.5, 2))
local tails = c:line({ {28,24}, {25,33} }, 2):add(c:line({ {36,24}, {39,33} }, 2))
local knots = c:rect(23, 33, 26, 35):add(c:rect(38, 33, 41, 35))
c:part(cord:add(loops):add(tails):add(knots), "gold", { flat = true, contour = GV.C.umber })
c:outline(cord)
c:button(30, 21)
local t = c:save(O .. "aseprite/ph/champak-seed.aseprite", O .. "png/ph/champak-seed.png")
print(GV.report(t))
